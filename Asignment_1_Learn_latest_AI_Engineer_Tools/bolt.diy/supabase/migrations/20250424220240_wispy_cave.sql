/*
  # Fix profiles table RLS policies

  1. Changes
    - Remove recursive policies that were causing infinite loops
    - Replace with simplified policies that use auth.uid() and JWT claims
    - Maintain same access control logic but implement it more efficiently

  2. Security
    - Maintains existing access control rules:
      - Admins can read all profiles
      - Restaurant managers can read customer profiles
      - Users can read/update their own profiles
    - Uses JWT claims for role checks instead of recursive table queries
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
DROP POLICY IF EXISTS "Restaurant managers can read customer profiles" ON profiles;
DROP POLICY IF EXISTS "Restaurant managers can update customer ratings" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;

-- Create new non-recursive policies
CREATE POLICY "Admins can read all profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'role' = 'admin'
);

CREATE POLICY "Restaurant managers can read customer profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  (auth.jwt() ->> 'role' = 'restaurant_manager' AND role = 'customer')
);

CREATE POLICY "Restaurant managers can update customer ratings"
ON profiles
FOR UPDATE
TO authenticated
USING (
  (auth.jwt() ->> 'role' = 'restaurant_manager' AND role = 'customer')
)
WITH CHECK (
  (auth.jwt() ->> 'role' = 'restaurant_manager' AND role = 'customer')
);

CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = id
);

CREATE POLICY "Users can read own profile"
ON profiles
FOR SELECT
TO authenticated
USING (
  auth.uid() = id
);

CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  auth.uid() = id
)
WITH CHECK (
  auth.uid() = id
);