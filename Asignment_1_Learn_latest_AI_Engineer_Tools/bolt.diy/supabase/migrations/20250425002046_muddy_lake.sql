/*
  # Update booking triggers for automatic statistics

  1. Changes
    - Add new trigger function to automatically complete bookings and update stats
    - Update existing trigger functions to handle spending calculations
    - Add trigger for automatic booking completion

  2. Details
    - Automatically marks bookings as completed after the booking time
    - Updates user statistics including total spent based on restaurant price range
    - Calculates spending based on party size and restaurant price range
*/

-- Function to calculate estimated spending based on price range
CREATE OR REPLACE FUNCTION calculate_estimated_spending(price_range integer, party_size integer)
RETURNS numeric AS $$
BEGIN
  RETURN (
    CASE price_range
      WHEN 1 THEN 15
      WHEN 2 THEN 30
      WHEN 3 THEN 60
      WHEN 4 THEN 100
      ELSE 0
    END * party_size
  )::numeric;
END;
$$ LANGUAGE plpgsql;

-- Update the function that handles booking status changes
CREATE OR REPLACE FUNCTION update_user_booking_stats()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    -- Increment cancelled bookings count
    UPDATE profiles 
    SET cancelled_bookings = cancelled_bookings + 1
    WHERE id = NEW.customer_id;
  ELSIF NEW.status = 'no_show' AND OLD.status != 'no_show' THEN
    -- Increment no-show count
    UPDATE profiles 
    SET no_show_count = no_show_count + 1
    WHERE id = NEW.customer_id;
  ELSIF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Update visit count and last visit
    UPDATE profiles 
    SET 
      visit_count = visit_count + 1,
      last_visit = NEW.date,
      -- Update is_regular if they've visited 5 or more times
      is_regular = CASE WHEN visit_count + 1 >= 5 THEN true ELSE is_regular END,
      -- Update total spent
      total_spent = total_spent + (
        SELECT calculate_estimated_spending(r.price_range, NEW.party_size)
        FROM restaurants r
        WHERE r.id = NEW.restaurant_id
      )
    WHERE id = NEW.customer_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a function to automatically complete confirmed bookings
CREATE OR REPLACE FUNCTION auto_complete_bookings()
RETURNS TRIGGER AS $$
BEGIN
  -- For confirmed bookings that are in the past
  IF NEW.status = 'confirmed' AND 
     (NEW.date < CURRENT_DATE OR 
      (NEW.date = CURRENT_DATE AND NEW.time < CURRENT_TIME)) THEN
    
    -- Mark as completed
    NEW.status = 'completed';
    
    -- Update user statistics
    UPDATE profiles 
    SET 
      visit_count = visit_count + 1,
      last_visit = NEW.date,
      is_regular = CASE WHEN visit_count + 1 >= 5 THEN true ELSE is_regular END,
      total_spent = total_spent + (
        SELECT calculate_estimated_spending(r.price_range, NEW.party_size)
        FROM restaurants r
        WHERE r.id = NEW.restaurant_id
      )
    WHERE id = NEW.customer_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-completing bookings
DROP TRIGGER IF EXISTS auto_complete_bookings ON bookings;
CREATE TRIGGER auto_complete_bookings
  BEFORE UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION auto_complete_bookings();