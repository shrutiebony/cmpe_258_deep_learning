-- First create the user in auth.users
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
) VALUES (
  '123e4567-e89b-12d3-a456-426614174999',
  '00000000-0000-0000-0000-000000000000',
  'shrutigebony@gmail.com',
  crypt('admin123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Shruti Goyal"}',
  false,
  'authenticated'
) ON CONFLICT (id) DO UPDATE
SET 
  encrypted_password = crypt('admin123', gen_salt('bf')),
  updated_at = now();

-- Then create the profile
INSERT INTO profiles (
  id,
  role,
  full_name,
  email,
  phone,
  visit_count,
  is_regular,
  total_spent,
  cancelled_bookings,
  no_show_count,
  created_at,
  updated_at
) VALUES (
  '123e4567-e89b-12d3-a456-426614174999',
  'admin',
  'Shruti Goyal',
  'shrutigebony@gmail.com',
  '4086463352',
  0,
  false,
  0,
  0,
  0,
  now(),
  now()
) ON CONFLICT (id) DO UPDATE
SET 
  role = 'admin',
  full_name = 'Shruti Goyal',
  email = 'shrutigebony@gmail.com',
  phone = '4086463352',
  updated_at = now();