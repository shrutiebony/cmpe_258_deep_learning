-- Add rating and review_count columns to restaurants table
ALTER TABLE restaurants 
ADD COLUMN IF NOT EXISTS rating numeric(3,1) DEFAULT 0,
ADD COLUMN IF NOT EXISTS review_count integer DEFAULT 0;

-- Create function to calculate estimated spending based on price range
CREATE OR REPLACE FUNCTION calculate_estimated_spending(price_range integer, party_size integer)
RETURNS numeric AS $$
DECLARE
  base_price numeric;
BEGIN
  IF price_range = 1 THEN
    base_price := 15;
  ELSIF price_range = 2 THEN
    base_price := 30;
  ELSIF price_range = 3 THEN
    base_price := 60;
  ELSIF price_range = 4 THEN
    base_price := 100;
  ELSE
    base_price := 30;
  END IF;
  
  RETURN party_size * base_price;
END;
$$ LANGUAGE plpgsql;

-- Add sample reviews
INSERT INTO reviews (restaurant_id, customer_id, rating, text, created_at)
SELECT 
  r.id as restaurant_id,
  p.id as customer_id,
  floor(random() * 3 + 3)::integer as rating, -- Ratings between 3-5
  CASE floor(random() * 5)
    WHEN 0 THEN 'Excellent food and service! The atmosphere was perfect for our special occasion.'
    WHEN 1 THEN 'Great experience overall. The staff was very attentive and the food was delicious.'
    WHEN 2 THEN 'Really enjoyed our meal here. Will definitely be coming back!'
    WHEN 3 THEN 'Fantastic venue with amazing cuisine. Highly recommended!'
    ELSE 'Outstanding dining experience. The chef really knows what they''re doing.'
  END as text,
  NOW() - (random() * interval '90 days') as created_at
FROM restaurants r
CROSS JOIN profiles p
WHERE p.role = 'customer'
AND NOT EXISTS (
  SELECT 1 FROM reviews 
  WHERE restaurant_id = r.id 
  AND customer_id = p.id
)
LIMIT 50;

-- Update restaurant ratings based on reviews
UPDATE restaurants r
SET 
  rating = subquery.avg_rating,
  review_count = subquery.review_count
FROM (
  SELECT 
    restaurant_id,
    ROUND(AVG(rating)::numeric, 1) as avg_rating,
    COUNT(*) as review_count
  FROM reviews
  GROUP BY restaurant_id
) subquery
WHERE r.id = subquery.restaurant_id;

-- Create trigger function to update restaurant rating
CREATE OR REPLACE FUNCTION update_restaurant_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE restaurants
  SET 
    rating = (
      SELECT ROUND(AVG(rating)::numeric, 1)
      FROM reviews
      WHERE restaurant_id = NEW.restaurant_id
    ),
    review_count = (
      SELECT COUNT(*)
      FROM reviews
      WHERE restaurant_id = NEW.restaurant_id
    )
  WHERE id = NEW.restaurant_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update restaurant rating
DROP TRIGGER IF EXISTS update_restaurant_rating ON reviews;
CREATE TRIGGER update_restaurant_rating
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_restaurant_rating();

-- Fix the auto-complete bookings function to properly update total spent
CREATE OR REPLACE FUNCTION auto_complete_bookings()
RETURNS TRIGGER AS $$
DECLARE
  restaurant_price_range integer;
  estimated_spent numeric;
BEGIN
  -- Get restaurant price range
  SELECT price_range INTO restaurant_price_range
  FROM restaurants
  WHERE id = NEW.restaurant_id;

  -- Calculate estimated spending
  estimated_spent := calculate_estimated_spending(restaurant_price_range, NEW.party_size);

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
      total_spent = total_spent + estimated_spent
    WHERE id = NEW.customer_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Ensure restaurant hours are properly set with correct time format
DO $$ 
BEGIN
  -- Update weekday hours
  UPDATE restaurant_hours
  SET
    open_time = '11:30:00'::time,
    close_time = '22:00:00'::time,
    is_closed = false
  WHERE day NOT IN ('friday', 'saturday', 'sunday', 'monday');

  -- Update Friday and Saturday hours
  UPDATE restaurant_hours
  SET
    open_time = '11:30:00'::time,
    close_time = '23:00:00'::time,
    is_closed = false
  WHERE day IN ('friday', 'saturday');

  -- Update Sunday hours
  UPDATE restaurant_hours
  SET
    open_time = '10:00:00'::time,
    close_time = '22:00:00'::time,
    is_closed = false
  WHERE day = 'sunday';

  -- Update Monday hours for high-end restaurants
  UPDATE restaurant_hours
  SET
    is_closed = true
  WHERE day = 'monday'
  AND restaurant_id IN (
    SELECT id FROM restaurants WHERE price_range >= 3
  );

  -- Update Monday hours for other restaurants
  UPDATE restaurant_hours
  SET
    open_time = '11:30:00'::time,
    close_time = '22:00:00'::time,
    is_closed = false
  WHERE day = 'monday'
  AND restaurant_id IN (
    SELECT id FROM restaurants WHERE price_range < 3
  );
END $$;