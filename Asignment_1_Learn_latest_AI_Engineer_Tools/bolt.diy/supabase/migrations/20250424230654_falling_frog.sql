-- Update admin user password
UPDATE auth.users 
SET encrypted_password = crypt('Qwerty', gen_salt('bf'))
WHERE email = 'shrutigebony@gmail.com';