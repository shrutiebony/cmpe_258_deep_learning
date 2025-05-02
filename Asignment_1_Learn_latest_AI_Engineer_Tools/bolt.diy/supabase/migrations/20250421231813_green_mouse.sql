/*
  # Initial Schema for BookTable Application

  1. New Tables
    - `profiles`
      - Extends auth.users with additional user profile information
      - Stores user role and profile details
    
    - `restaurants`
      - Stores restaurant information
      - Includes details like name, description, location, hours, etc.
    
    - `restaurant_hours`
      - Stores operating hours for each restaurant
      - Flexible schedule management
    
    - `tables`
      - Represents physical tables in restaurants
      - Tracks capacity and availability
    
    - `bookings`
      - Stores reservation information
      - Links customers, restaurants, and tables
    
    - `reviews`
      - Stores customer reviews and ratings
      - Links to restaurants and users
    
  2. Security
    - Enable RLS on all tables
    - Set up policies for each role (customer, restaurant_manager, admin)
    - Ensure data privacy and access control
*/

-- Create custom types
CREATE TYPE user_role AS ENUM ('customer', 'restaurant_manager', 'admin');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled', 'no_show');
CREATE TYPE day_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role user_role NOT NULL DEFAULT 'customer',
  full_name text,
  avatar_url text,
  phone text,
  email text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  cuisine text[] NOT NULL DEFAULT '{}',
  price_range smallint NOT NULL CHECK (price_range BETWEEN 1 AND 4),
  street_address text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  postal_code text NOT NULL,
  country text NOT NULL DEFAULT 'USA',
  latitude numeric(10,8),
  longitude numeric(11,8),
  phone text NOT NULL,
  email text NOT NULL,
  website text,
  images text[] NOT NULL DEFAULT '{}',
  features text[] NOT NULL DEFAULT '{}',
  approved boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create restaurant_hours table
CREATE TABLE IF NOT EXISTS restaurant_hours (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  day day_of_week NOT NULL,
  open_time time NOT NULL,
  close_time time NOT NULL,
  is_closed boolean NOT NULL DEFAULT false,
  UNIQUE(restaurant_id, day)
);

-- Create tables table
CREATE TABLE IF NOT EXISTS tables (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  name text NOT NULL,
  capacity smallint NOT NULL CHECK (capacity > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  table_id uuid REFERENCES tables(id) ON DELETE SET NULL,
  customer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  date date NOT NULL,
  time time NOT NULL,
  party_size smallint NOT NULL CHECK (party_size > 0),
  status booking_status NOT NULL DEFAULT 'pending',
  special_requests text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id uuid NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  text text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(restaurant_id, customer_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Create policies for restaurants
CREATE POLICY "Restaurants are viewable by everyone" ON restaurants
  FOR SELECT USING (approved = true);

CREATE POLICY "Restaurant managers can update own restaurant" ON restaurants
  FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Admins can manage all restaurants" ON restaurants
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- Create policies for restaurant_hours
CREATE POLICY "Restaurant hours are viewable by everyone" ON restaurant_hours
  FOR SELECT USING (true);

CREATE POLICY "Restaurant managers can manage own hours" ON restaurant_hours
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE id = restaurant_hours.restaurant_id
      AND owner_id = auth.uid()
    )
  );

-- Create policies for tables
CREATE POLICY "Tables are viewable by restaurant staff and admin" ON tables
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE id = tables.restaurant_id
      AND (
        owner_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM profiles
          WHERE id = auth.uid()
          AND role = 'admin'
        )
      )
    )
  );

CREATE POLICY "Restaurant managers can manage own tables" ON tables
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE id = tables.restaurant_id
      AND owner_id = auth.uid()
    )
  );

-- Create policies for bookings
CREATE POLICY "Users can view own bookings" ON bookings
  FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Restaurant managers can view own restaurant bookings" ON bookings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM restaurants
      WHERE id = bookings.restaurant_id
      AND owner_id = auth.uid()
    )
  );

CREATE POLICY "Customers can create bookings" ON bookings
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Users can update own bookings" ON bookings
  FOR UPDATE USING (auth.uid() = customer_id);

-- Create policies for reviews
CREATE POLICY "Reviews are viewable by everyone" ON reviews
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "Users can update own reviews" ON reviews
  FOR UPDATE USING (auth.uid() = customer_id);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS restaurants_owner_id_idx ON restaurants(owner_id);
CREATE INDEX IF NOT EXISTS restaurants_city_idx ON restaurants(city);
CREATE INDEX IF NOT EXISTS restaurants_cuisine_idx ON restaurants USING GIN(cuisine);
CREATE INDEX IF NOT EXISTS bookings_customer_id_idx ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS bookings_restaurant_id_idx ON bookings(restaurant_id);
CREATE INDEX IF NOT EXISTS bookings_date_idx ON bookings(date);
CREATE INDEX IF NOT EXISTS reviews_restaurant_id_idx ON reviews(restaurant_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurants_updated_at
  BEFORE UPDATE ON restaurants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tables_updated_at
  BEFORE UPDATE ON tables
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();