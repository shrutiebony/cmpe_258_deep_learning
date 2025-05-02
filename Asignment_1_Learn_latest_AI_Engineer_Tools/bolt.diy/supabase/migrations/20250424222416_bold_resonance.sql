/*
  # Insert mock restaurant data

  1. Data Population
    - Insert mock restaurant data into the restaurants table
    - Includes basic restaurant information like name, description, cuisine, etc.
    - Sets up initial test data for the application

  2. Security
    - No additional security measures needed as we're using existing RLS policies
*/

INSERT INTO restaurants (
  id,
  name,
  description,
  cuisine,
  price_range,
  street_address,
  city,
  state,
  postal_code,
  country,
  latitude,
  longitude,
  phone,
  email,
  website,
  images,
  features,
  approved
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  'Bella Italia',
  'Authentic Italian cuisine in a cozy atmosphere with traditional recipes passed down through generations.',
  ARRAY['Italian', 'Mediterranean'],
  2,
  '123 Main Street',
  'San Francisco',
  'CA',
  '94105',
  'USA',
  37.7749,
  -122.4194,
  '(415) 555-1234',
  'info@bellaitalia.com',
  'https://bellaitalia.example.com',
  ARRAY[
    'https://images.pexels.com/photos/67468/pexels-photo-67468.jpeg',
    'https://images.pexels.com/photos/1579739/pexels-photo-1579739.jpeg',
    'https://images.pexels.com/photos/2233729/pexels-photo-2233729.jpeg'
  ],
  ARRAY['Outdoor Seating', 'Takeout', 'Vegetarian Options', 'Vegan Options', 'Wine Bar'],
  true
);