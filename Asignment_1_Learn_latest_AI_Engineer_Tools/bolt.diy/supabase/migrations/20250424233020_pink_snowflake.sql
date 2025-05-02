/*
  # Add Checkpoints Table

  1. New Tables
    - `checkpoints`
      - Stores project checkpoints with metadata
      - Tracks version history and feature states
  
  2. Security
    - Enable RLS
    - Add policies for admin access
    - Create necessary indexes
*/

-- Create checkpoints table if it doesn't exist
DO $$ BEGIN
  CREATE TABLE IF NOT EXISTS checkpoints (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    timestamp timestamptz NOT NULL DEFAULT now(),
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
  );
EXCEPTION
  WHEN duplicate_table THEN
    NULL;
END $$;

-- Enable RLS if not already enabled
DO $$ BEGIN
  ALTER TABLE checkpoints ENABLE ROW LEVEL SECURITY;
EXCEPTION
  WHEN invalid_parameter_value THEN
    NULL;
END $$;

-- Drop existing policies to avoid conflicts
DO $$ BEGIN
  DROP POLICY IF EXISTS "Checkpoints are viewable by everyone" ON checkpoints;
  DROP POLICY IF EXISTS "Only admins can manage checkpoints" ON checkpoints;
END $$;

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

-- Create index if it doesn't exist
DO $$ BEGIN
  CREATE INDEX IF NOT EXISTS checkpoints_timestamp_idx ON checkpoints(timestamp);
EXCEPTION
  WHEN duplicate_table THEN
    NULL;
END $$;

-- Create trigger if it doesn't exist
DO $$ BEGIN
  CREATE TRIGGER update_checkpoints_updated_at
    BEFORE UPDATE ON checkpoints
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
EXCEPTION
  WHEN duplicate_object THEN
    NULL;
END $$;

-- Insert initial checkpoint if it doesn't exist
INSERT INTO checkpoints (
  name,
  description,
  metadata
)
SELECT
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
WHERE NOT EXISTS (
  SELECT 1 FROM checkpoints WHERE name = 'Initial Admin Dashboard'
);