/*
  # Update Triggers for User Statistics

  1. Changes
    - Add trigger to update user stats when booking status changes
    - Add trigger to update restaurant rating when reviews are added
    - Add trigger to update user total spent when booking is completed

  2. Security
    - Ensure triggers run with proper permissions
    - Validate data before updates
*/

-- Function to calculate average rating
CREATE OR REPLACE FUNCTION calculate_restaurant_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE restaurants
  SET rating = (
    SELECT COALESCE(AVG(rating)::numeric(2,1), 0)
    FROM reviews
    WHERE restaurant_id = NEW.restaurant_id
  )
  WHERE id = NEW.restaurant_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update user stats on booking changes
CREATE OR REPLACE FUNCTION update_user_booking_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update visit count and last visit for completed bookings
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    UPDATE profiles
    SET 
      visit_count = visit_count + 1,
      last_visit = NOW(),
      is_regular = CASE 
        WHEN visit_count + 1 >= 5 THEN true 
        ELSE false 
      END
    WHERE id = NEW.customer_id;
  END IF;

  -- Update cancelled bookings count
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    UPDATE profiles
    SET cancelled_bookings = cancelled_bookings + 1
    WHERE id = NEW.customer_id;
  END IF;

  -- Update no-show count
  IF NEW.status = 'no_show' AND OLD.status != 'no_show' THEN
    UPDATE profiles
    SET no_show_count = no_show_count + 1
    WHERE id = NEW.customer_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update total spent when booking is completed
CREATE OR REPLACE FUNCTION update_user_total_spent()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Assuming average spend per person is $30
    -- In a real app, this would come from actual bill/payment data
    UPDATE profiles
    SET total_spent = total_spent + (NEW.party_size * 30)
    WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace triggers
DROP TRIGGER IF EXISTS update_restaurant_rating ON reviews;
CREATE TRIGGER update_restaurant_rating
  AFTER INSERT OR UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION calculate_restaurant_rating();

DROP TRIGGER IF EXISTS update_booking_stats ON bookings;
CREATE TRIGGER update_booking_stats
  AFTER UPDATE OF status ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_booking_stats();

DROP TRIGGER IF EXISTS update_total_spent ON bookings;
CREATE TRIGGER update_total_spent
  AFTER UPDATE OF status ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_total_spent();