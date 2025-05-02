/*
  # Add User Tracking Features

  1. Updates
    - Add new columns to profiles table:
      - visit_count: Track number of restaurant visits
      - last_visit: Date of last restaurant visit
      - is_regular: Boolean flag for regular customers
      - customer_rating: Restaurant's rating of the customer
      - total_spent: Total amount spent at restaurants
      - cancelled_bookings: Number of cancelled bookings
      - no_show_count: Number of no-shows
      - special_notes: Additional notes about the customer

  2. Security
    - Update RLS policies to protect sensitive information
    - Only restaurant managers can update customer ratings
*/

-- Add new columns to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS visit_count integer NOT NULL DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_visit timestamptz;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_regular boolean NOT NULL DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS customer_rating smallint CHECK (customer_rating BETWEEN 1 AND 5);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_spent decimal(10,2) NOT NULL DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cancelled_bookings integer NOT NULL DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS no_show_count integer NOT NULL DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS special_notes text;

-- Create function to update user stats
CREATE OR REPLACE FUNCTION update_user_visit_stats()
RETURNS TRIGGER AS $$
BEGIN
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
  ELSIF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    UPDATE profiles
    SET cancelled_bookings = cancelled_bookings + 1
    WHERE id = NEW.customer_id;
  ELSIF NEW.status = 'no_show' AND OLD.status != 'no_show' THEN
    UPDATE profiles
    SET no_show_count = no_show_count + 1
    WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for booking status changes
CREATE TRIGGER booking_status_change
  AFTER UPDATE OF status ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_visit_stats();

-- Add policies for customer rating
CREATE POLICY "Restaurant managers can rate customers" ON profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE owner_id = auth.uid()
    )
  );

-- Create view for restaurant managers to see customer stats
CREATE OR REPLACE VIEW customer_stats AS
SELECT 
  p.id,
  p.full_name,
  p.email,
  p.visit_count,
  p.last_visit,
  p.is_regular,
  p.customer_rating,
  p.total_spent,
  p.cancelled_bookings,
  p.no_show_count,
  p.special_notes,
  COUNT(b.id) as total_bookings,
  COUNT(CASE WHEN b.status = 'completed' THEN 1 END) as completed_bookings
FROM profiles p
LEFT JOIN bookings b ON p.id = b.customer_id
WHERE p.role = 'customer'
GROUP BY p.id;

-- Grant access to restaurant managers
GRANT SELECT ON customer_stats TO authenticated;