/*
  # Fix Booking RLS Policies

  1. Changes
    - Add RLS policy for inserting bookings
    - Ensure customer_id is set to authenticated user's ID

  2. Security
    - Enable RLS on bookings table (if not already enabled)
    - Add policy for authenticated users to create bookings for themselves
*/

-- Enable RLS on bookings table if not already enabled
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Create policy for inserting bookings
CREATE POLICY "Users can create bookings for themselves"
ON bookings
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = customer_id);