/*
  # Insert restaurant hours

  1. Data Population
    - Insert operating hours for the mock restaurant
    - Sets up weekly schedule for Bella Italia
*/

INSERT INTO restaurant_hours (
  restaurant_id,
  day,
  open_time,
  close_time,
  is_closed
) VALUES 
  ('123e4567-e89b-12d3-a456-426614174000', 'monday', '11:00', '22:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'tuesday', '11:00', '22:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'wednesday', '11:00', '22:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'thursday', '11:00', '23:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'friday', '11:00', '23:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'saturday', '12:00', '23:00', false),
  ('123e4567-e89b-12d3-a456-426614174000', 'sunday', '12:00', '21:00', false);