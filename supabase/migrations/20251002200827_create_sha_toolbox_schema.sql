/*
  # SHA Toolbox Database Schema

  1. New Tables
    - `execution_logs`
      - Stores all playbook execution logs
      - Tracks hostname, timestamp, role, action, status
      - Includes detailed execution information
    
    - `servers`
      - Inventory of managed servers
      - Stores server details (hostname, codeap, codescar, environment)
      - Tracks middleware installations
    
    - `filesystems`
      - Tracks created/managed filesystems
      - Records LV names, mount points, sizes
      - Links to servers
    
    - `applications`
      - Application inventory
      - Maps codeap/codescar to servers
      - Tracks application metadata

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated access
    - Audit trail for all operations

  3. Indexes
    - Performance indexes on frequently queried columns
*/

-- Execution Logs Table
CREATE TABLE IF NOT EXISTS execution_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostname text NOT NULL,
  timestamp timestamptz NOT NULL DEFAULT now(),
  role text NOT NULL,
  action text NOT NULL,
  environment text NOT NULL,
  executed_by text NOT NULL,
  status text NOT NULL CHECK (status IN ('success', 'failed', 'in_progress')),
  details jsonb DEFAULT '{}'::jsonb,
  error_message text,
  created_at timestamptz DEFAULT now()
);

-- Servers Table
CREATE TABLE IF NOT EXISTS servers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  hostname text UNIQUE NOT NULL,
  ip_address text,
  os_type text NOT NULL,
  os_version text,
  environment text NOT NULL CHECK (environment IN ('dev', 'qual', 'prod')),
  codeap text,
  codescar text,
  server_role text,
  middleware_installed jsonb DEFAULT '{}'::jsonb,
  last_seen timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Filesystems Table
CREATE TABLE IF NOT EXISTS filesystems (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  server_id uuid REFERENCES servers(id) ON DELETE CASCADE,
  lv_name text NOT NULL,
  vg_name text NOT NULL,
  mount_point text NOT NULL,
  size_gb integer NOT NULL,
  filesystem_type text DEFAULT 'xfs',
  created_by text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(server_id, mount_point)
);

-- Applications Table
CREATE TABLE IF NOT EXISTS applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codeap text NOT NULL,
  codescar text NOT NULL,
  id_suffix text,
  server_id uuid REFERENCES servers(id) ON DELETE CASCADE,
  app_type text,
  websphere_type text CHECK (websphere_type IN ('was', 'wlc', 'wlb', NULL)),
  version text,
  status text DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(codeap, codescar, id_suffix, server_id)
);

-- Enable Row Level Security
ALTER TABLE execution_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE servers ENABLE ROW LEVEL SECURITY;
ALTER TABLE filesystems ENABLE ROW LEVEL SECURITY;
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for execution_logs
CREATE POLICY "Anyone can insert execution logs"
  ON execution_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can read execution logs"
  ON execution_logs FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policies for servers
CREATE POLICY "Anyone can read servers"
  ON servers FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can insert servers"
  ON servers FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update servers"
  ON servers FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- RLS Policies for filesystems
CREATE POLICY "Anyone can read filesystems"
  ON filesystems FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can insert filesystems"
  ON filesystems FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policies for applications
CREATE POLICY "Anyone can read applications"
  ON applications FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can insert applications"
  ON applications FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can update applications"
  ON applications FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create Indexes
CREATE INDEX IF NOT EXISTS idx_execution_logs_hostname ON execution_logs(hostname);
CREATE INDEX IF NOT EXISTS idx_execution_logs_timestamp ON execution_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_execution_logs_status ON execution_logs(status);
CREATE INDEX IF NOT EXISTS idx_servers_hostname ON servers(hostname);
CREATE INDEX IF NOT EXISTS idx_servers_environment ON servers(environment);
CREATE INDEX IF NOT EXISTS idx_servers_codeap ON servers(codeap);
CREATE INDEX IF NOT EXISTS idx_filesystems_server_id ON filesystems(server_id);
CREATE INDEX IF NOT EXISTS idx_applications_codeap ON applications(codeap);
CREATE INDEX IF NOT EXISTS idx_applications_server_id ON applications(server_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_servers_updated_at'
  ) THEN
    CREATE TRIGGER update_servers_updated_at
      BEFORE UPDATE ON servers
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'update_applications_updated_at'
  ) THEN
    CREATE TRIGGER update_applications_updated_at
      BEFORE UPDATE ON applications
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;
