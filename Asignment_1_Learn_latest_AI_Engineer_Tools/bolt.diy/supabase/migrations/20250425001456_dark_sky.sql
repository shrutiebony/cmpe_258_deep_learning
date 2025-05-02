/*
  # Add Sample Restaurant Data

  1. New Data
    - Adds sample restaurants across different cuisines and cities
    - Includes operating hours for each restaurant
    - Sets up realistic test data for development

  2. Restaurant Categories
    - Italian restaurants
    - Japanese restaurants
    - Mexican restaurants
    - American restaurants
    - French restaurants

  3. Features
    - Varied price ranges (1-4)
    - Different locations across US cities
    - Realistic operating hours
    - Sample images from Pexels
*/

-- Insert dummy restaurants with diverse cuisines, price ranges, and locations

-- Italian Restaurants
INSERT INTO restaurants (
  name, description, cuisine, price_range,
  street_address, city, state, postal_code, country,
  phone, email, website, images, features, approved
) VALUES
  (
    'Trattoria Roma',
    'Family-owned Italian restaurant specializing in Roman cuisine and wood-fired pizzas.',
    ARRAY['Italian', 'Pizza'],
    2,
    '789 Italian Way',
    'Boston',
    'MA',
    '02108',
    'USA',
    '(617) 555-0123',
    'info@trattoriaroma.com',
    'https://trattoriaroma.example.com',
    ARRAY[
      'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg',
      'https://images.pexels.com/photos/905847/pexels-photo-905847.jpeg',
      'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg'
    ],
    ARRAY['Wood-Fired Pizza', 'Family Style', 'Wine Bar', 'Takeout'],
    true
  ),
  (
    'Osteria Toscana',
    'Elegant Tuscan dining featuring seasonal ingredients and an extensive wine list.',
    ARRAY['Italian', 'Mediterranean'],
    4,
    '456 Tuscany Lane',
    'Chicago',
    'IL',
    '60601',
    'USA',
    '(312) 555-0456',
    'info@osteriatoscana.com',
    'https://osteriatoscana.example.com',
    ARRAY[
      'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg',
      'https://images.pexels.com/photos/1109197/pexels-photo-1109197.jpeg',
      'https://images.pexels.com/photos/696218/pexels-photo-696218.jpeg'
    ],
    ARRAY['Fine Dining', 'Wine List', 'Private Rooms', 'Romantic'],
    true
  );

-- Japanese Restaurants
INSERT INTO restaurants (
  name, description, cuisine, price_range,
  street_address, city, state, postal_code, country,
  phone, email, website, images, features, approved
) VALUES
  (
    'Sakura Sushi',
    'Premium Japanese sushi and sashimi prepared by master chefs using the freshest ingredients.',
    ARRAY['Japanese', 'Sushi'],
    3,
    '123 Sushi Lane',
    'Seattle',
    'WA',
    '98101',
    'USA',
    '(206) 555-7890',
    'info@sakurasushi.com',
    'https://sakurasushi.example.com',
    ARRAY[
      'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg',
      'https://images.pexels.com/photos/2323398/pexels-photo-2323398.jpeg',
      'https://images.pexels.com/photos/684965/pexels-photo-684965.jpeg'
    ],
    ARRAY['Omakase', 'Sake Bar', 'Private Dining', 'Takeout'],
    true
  ),
  (
    'Ramen House',
    'Authentic Japanese ramen with homemade noodles and rich, flavorful broths.',
    ARRAY['Japanese', 'Ramen'],
    2,
    '567 Noodle Street',
    'Portland',
    'OR',
    '97201',
    'USA',
    '(503) 555-3456',
    'info@ramenhouse.com',
    'https://ramenhouse.example.com',
    ARRAY[
      'https://images.pexels.com/photos/884600/pexels-photo-884600.jpeg',
      'https://images.pexels.com/photos/1907244/pexels-photo-1907244.jpeg',
      'https://images.pexels.com/photos/3926133/pexels-photo-3926133.jpeg'
    ],
    ARRAY['Homemade Noodles', 'Vegetarian Options', 'Takeout'],
    true
  );

-- Mexican Restaurants
INSERT INTO restaurants (
  name, description, cuisine, price_range,
  street_address, city, state, postal_code, country,
  phone, email, website, images, features, approved
) VALUES
  (
    'Taqueria El Sol',
    'Authentic Mexican street tacos and traditional dishes in a vibrant atmosphere.',
    ARRAY['Mexican', 'Latin American'],
    1,
    '789 Taco Avenue',
    'Austin',
    'TX',
    '78701',
    'USA',
    '(512) 555-9012',
    'info@taqueriaelsol.com',
    'https://taqueriaelsol.example.com',
    ARRAY[
      'https://images.pexels.com/photos/4958641/pexels-photo-4958641.jpeg',
      'https://images.pexels.com/photos/2092507/pexels-photo-2092507.jpeg',
      'https://images.pexels.com/photos/2092897/pexels-photo-2092897.jpeg'
    ],
    ARRAY['Street Food', 'Margaritas', 'Outdoor Seating', 'Late Night'],
    true
  ),
  (
    'Casa Mexico',
    'Upscale Mexican restaurant featuring regional specialties and craft margaritas.',
    ARRAY['Mexican', 'Latin American'],
    3,
    '234 Agave Road',
    'Denver',
    'CO',
    '80202',
    'USA',
    '(303) 555-6789',
    'info@casamexicodenver.com',
    'https://casamexicodenver.example.com',
    ARRAY[
      'https://images.pexels.com/photos/2087748/pexels-photo-2087748.jpeg',
      'https://images.pexels.com/photos/5175537/pexels-photo-5175537.jpeg',
      'https://images.pexels.com/photos/7613568/pexels-photo-7613568.jpeg'
    ],
    ARRAY['Full Bar', 'Private Events', 'Valet Parking', 'Live Music'],
    true
  );

-- American Restaurants
INSERT INTO restaurants (
  name, description, cuisine, price_range,
  street_address, city, state, postal_code, country,
  phone, email, website, images, features, approved
) VALUES
  (
    'The Capital Grille',
    'Premium steakhouse featuring dry-aged steaks and an award-winning wine list.',
    ARRAY['American', 'Steakhouse'],
    4,
    '100 Capital Street',
    'New York',
    'NY',
    '10022',
    'USA',
    '(212) 555-1234',
    'info@capitalgrille.com',
    'https://capitalgrille.example.com',
    ARRAY[
      'https://images.pexels.com/photos/3535383/pexels-photo-3535383.jpeg',
      'https://images.pexels.com/photos/3535383/pexels-photo-3535383.jpeg',
      'https://images.pexels.com/photos/3535383/pexels-photo-3535383.jpeg'
    ],
    ARRAY['Fine Dining', 'Wine List', 'Private Rooms', 'Valet Parking'],
    true
  ),
  (
    'Farm & Table',
    'Farm-to-table American cuisine focusing on seasonal ingredients and sustainable practices.',
    ARRAY['American', 'Contemporary'],
    3,
    '345 Garden Way',
    'Minneapolis',
    'MN',
    '55401',
    'USA',
    '(612) 555-7890',
    'info@farmandtable.com',
    'https://farmandtable.example.com',
    ARRAY[
      'https://images.pexels.com/photos/262047/pexels-photo-262047.jpeg',
      'https://images.pexels.com/photos/262048/pexels-photo-262048.jpeg',
      'https://images.pexels.com/photos/262049/pexels-photo-262049.jpeg'
    ],
    ARRAY['Farm-to-Table', 'Seasonal Menu', 'Weekend Brunch', 'Organic'],
    true
  );

-- French Restaurants
INSERT INTO restaurants (
  name, description, cuisine, price_range,
  street_address, city, state, postal_code, country,
  phone, email, website, images, features, approved
) VALUES
  (
    'Le Petit Bistrot',
    'Charming French bistro offering classic dishes and an authentic Parisian atmosphere.',
    ARRAY['French', 'European'],
    3,
    '567 Bistro Lane',
    'San Francisco',
    'CA',
    '94108',
    'USA',
    '(415) 555-4567',
    'info@lepetitbistrot.com',
    'https://lepetitbistrot.example.com',
    ARRAY[
      'https://images.pexels.com/photos/1267320/pexels-photo-1267320.jpeg',
      'https://images.pexels.com/photos/941861/pexels-photo-941861.jpeg',
      'https://images.pexels.com/photos/2878742/pexels-photo-2878742.jpeg'
    ],
    ARRAY['Wine Bar', 'Romantic', 'Outdoor Seating', 'Private Events'],
    true
  ),
  (
    'Provence',
    'Elegant French fine dining featuring classic Provençal cuisine and an extensive wine cellar.',
    ARRAY['French', 'Mediterranean'],
    4,
    '890 Lavender Way',
    'Miami',
    'FL',
    '33131',
    'USA',
    '(305) 555-8901',
    'info@provencemiami.com',
    'https://provencemiami.example.com',
    ARRAY[
      'https://images.pexels.com/photos/67468/pexels-photo-67468.jpeg',
      'https://images.pexels.com/photos/262978/pexels-photo-262978.jpeg',
      'https://images.pexels.com/photos/941861/pexels-photo-941861.jpeg'
    ],
    ARRAY['Fine Dining', 'Wine Cellar', 'Tasting Menu', 'Valet Parking'],
    true
  );

-- Add operating hours for each restaurant
DO $$
DECLARE
  r RECORD;
  d day_of_week;
BEGIN
  FOR r IN (
    SELECT id, price_range, name
    FROM restaurants 
    WHERE name IN (
      'Trattoria Roma', 'Osteria Toscana', 'Sakura Sushi', 'Ramen House',
      'Taqueria El Sol', 'Casa Mexico', 'The Capital Grille', 'Farm & Table',
      'Le Petit Bistrot', 'Provence'
    )
  ) LOOP
    FOR d IN (SELECT unnest(enum_range(NULL::day_of_week))) LOOP
      -- Delete any existing hours for this restaurant and day
      DELETE FROM restaurant_hours 
      WHERE restaurant_id = r.id AND day = d;
      
      -- Insert new hours
      INSERT INTO restaurant_hours (
        restaurant_id,
        day,
        open_time,
        close_time,
        is_closed
      ) VALUES (
        r.id,
        d,
        CASE 
          WHEN d IN ('saturday', 'sunday') THEN '10:00'::time
          ELSE '11:30'::time
        END,
        CASE 
          WHEN d IN ('friday', 'saturday') THEN '23:00'::time
          ELSE '22:00'::time
        END,
        CASE 
          WHEN d = 'monday' AND r.price_range >= 3 THEN true
          ELSE false
        END
      );
    END LOOP;
  END LOOP;
END $$;