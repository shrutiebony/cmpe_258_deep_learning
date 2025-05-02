/*
  # Create Checkpoints Table

  1. New Tables
    - `checkpoints`
      - Stores project checkpoints for version control
      - Includes metadata about project state
      
  2. Security
    - Enable RLS on checkpoints table
    - Only admins can manage checkpoints
    - Everyone can view checkpoints
*/

-- Create checkpoints table
CREATE TABLE IF NOT EXISTS checkpoints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  timestamp timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE checkpoints ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Checkpoints are viewable by everyone"
  ON checkpoints FOR SELECT
  USING (true);

CREATE POLICY "Only admins can manage checkpoints"
  ON checkpoints FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

-- Create index for faster timestamp-based queries
CREATE INDEX checkpoints_timestamp_idx ON checkpoints(timestamp);

-- Create trigger for updated_at
CREATE TRIGGER update_checkpoints_updated_at
  BEFORE UPDATE ON checkpoints
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert initial checkpoint
INSERT INTO checkpoints (
  name,
  description,
  metadata
) VALUES (
  'Initial Admin Dashboard',
  'Project checkpoint after setting up admin dashboard and user management features',
  jsonb_build_object(
    'version', '1.0.0',
    'features', array[
      'Admin dashboard',
      'Restaurant management',
      'User profiles',
      'Booking system',
      'Review system'
    ],
    'lastMigration', '20250424230959_dark_delta'
  )
);