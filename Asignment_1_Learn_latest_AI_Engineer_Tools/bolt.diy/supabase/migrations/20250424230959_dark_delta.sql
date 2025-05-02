/*
  # Fix Admin User Role

  1. Changes
    - Update user role to admin in profiles table
    - Ensure proper role metadata in auth.users table
    - Add necessary admin privileges

  2. Security
    - Maintains existing RLS policies
    - Updates only the specific user
*/

-- Update the profile role to admin
UPDATE profiles 
SET role = 'admin'
WHERE email = 'shrutigebony@gmail.com';

-- Update the user metadata in auth.users to include role
UPDATE auth.users 
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'shrutigebony@gmail.com';

-- Update the app metadata to include role claim
UPDATE auth.users 
SET raw_app_meta_data = jsonb_set(
  COALESCE(raw_app_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'shrutigebony@gmail.com';