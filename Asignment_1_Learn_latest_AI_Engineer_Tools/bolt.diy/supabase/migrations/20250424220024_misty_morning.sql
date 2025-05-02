/*
  # Fix Profile Policies and Registration

  1. Changes
    - Update RLS policies for profiles table
    - Add policy for profile creation during registration
    - Fix policy for profile updates
  
  2. Security
    - Maintain security while allowing necessary operations
    - Ensure users can only access appropriate data
*/

-- Drop existing policies on profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Restaurant managers can rate customers" ON profiles;

-- Create new policies
-- Allow users to view public profile information
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

-- Allow users to create their own profile
CREATE POLICY "Users can create own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow restaurant managers to rate customers
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