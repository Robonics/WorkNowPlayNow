-- ============================================================
-- Work Now, Play Now — Database Schema
-- Run this in your Supabase SQL editor to set up the database
-- ============================================================


-- ── Tables ───────────────────────────────────────────────────────────────────

CREATE TABLE achievements (
  id          uuid        NOT NULL DEFAULT gen_random_uuid(),
  key         text        NOT NULL,
  title       text        NOT NULL,
  description text        NOT NULL,
  tier        text        NOT NULL,
  category    text        NOT NULL,
  points      integer     NOT NULL,
  icon        text        NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (key),
  CHECK (tier = ANY (ARRAY['bronze','silver','gold','platinum']))
);

CREATE TABLE categories (
  id         uuid    NOT NULL DEFAULT gen_random_uuid(),
  user_id    uuid    REFERENCES auth.users(id) ON DELETE CASCADE,
  name       text    NOT NULL,
  is_default boolean DEFAULT false,
  PRIMARY KEY (id)
);

CREATE TABLE goals (
  id           uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id      uuid                        REFERENCES auth.users(id) ON DELETE CASCADE,
  title        text                        NOT NULL,
  description  text,
  created_at   timestamp without time zone DEFAULT now(),
  completed    boolean                     DEFAULT false,
  completed_at timestamp without time zone,
  PRIMARY KEY (id)
);

CREATE TABLE tasks (
  id               uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id          uuid                        REFERENCES auth.users(id) ON DELETE CASCADE,
  goal_id          uuid                        REFERENCES goals(id) ON DELETE SET NULL,
  category_id      uuid                        REFERENCES categories(id) ON DELETE SET NULL,
  title            text                        NOT NULL,
  description      text,
  status           text                        DEFAULT 'pending',
  due_date         timestamp without time zone,
  reminder_time    timestamp without time zone,
  reminder_sent    boolean                     DEFAULT false,
  calendar_event_id text,
  created_at       timestamp without time zone DEFAULT now(),
  PRIMARY KEY (id),
  CHECK (status = ANY (ARRAY['pending','in_progress','completed']))
);

CREATE TABLE subtasks (
  id         uuid                        NOT NULL DEFAULT gen_random_uuid(),
  task_id    uuid                        REFERENCES tasks(id) ON DELETE CASCADE,
  title      text                        NOT NULL,
  completed  boolean                     DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  PRIMARY KEY (id)
);

CREATE TABLE notifications (
  id         uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id    uuid                        REFERENCES auth.users(id) ON DELETE CASCADE,
  task_id    uuid                        REFERENCES tasks(id) ON DELETE CASCADE,
  message    text,
  is_read    boolean                     DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  type       text                        DEFAULT 'task_reminder',
  read_at    timestamp without time zone,
  PRIMARY KEY (id)
);

CREATE TABLE reminder_settings (
  id                       uuid    NOT NULL DEFAULT gen_random_uuid(),
  user_id                  uuid    REFERENCES auth.users(id) ON DELETE CASCADE,
  default_reminder_minutes integer DEFAULT 60,
  PRIMARY KEY (id)
);

CREATE TABLE user_achievements (
  id             uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id        uuid                        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id uuid                        NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at    timestamp without time zone DEFAULT now(),
  PRIMARY KEY (id),
  UNIQUE (user_id, achievement_id)
);

CREATE TABLE user_points (
  id          uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id     uuid                        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  source_type text                        NOT NULL,
  source_id   uuid                        NOT NULL,
  points      integer                     NOT NULL,
  awarded_at  timestamp without time zone DEFAULT now(),
  PRIMARY KEY (id),
  CHECK (source_type = ANY (ARRAY['task','goal','streak','achievement']))
);

CREATE TABLE user_streaks (
  id             uuid                        NOT NULL DEFAULT gen_random_uuid(),
  user_id        uuid                        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  current_streak integer                     NOT NULL DEFAULT 0,
  longest_streak integer                     NOT NULL DEFAULT 0,
  last_login_date date,
  updated_at     timestamp without time zone DEFAULT now(),
  PRIMARY KEY (id),
  UNIQUE (user_id)
);


-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE achievements       ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories         ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals              ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks              ENABLE ROW LEVEL SECURITY;
ALTER TABLE subtasks           ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications      ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements  ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_points        ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_streaks       ENABLE ROW LEVEL SECURITY;

-- Achievements (public read, no writes via API)
CREATE POLICY "achievements_read"
  ON achievements FOR SELECT USING (true);

-- Categories
CREATE POLICY "Users can read categories"
  ON categories FOR SELECT USING (is_default = true OR auth.uid() = user_id);
CREATE POLICY "Users can insert own categories"
  ON categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own categories"
  ON categories FOR DELETE USING (auth.uid() = user_id);

-- Goals
CREATE POLICY "Users can access own goals"
  ON goals FOR ALL USING (auth.uid() = user_id);

-- Tasks
CREATE POLICY "Users can access own tasks"
  ON tasks FOR ALL USING (auth.uid() = user_id);

-- Subtasks
CREATE POLICY "Users can view their own subtasks"
  ON subtasks FOR SELECT USING (
    EXISTS (SELECT 1 FROM tasks WHERE tasks.id = subtasks.task_id AND tasks.user_id = auth.uid())
  );
CREATE POLICY "Users can create subtasks for their tasks"
  ON subtasks FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM tasks WHERE tasks.id = subtasks.task_id AND tasks.user_id = auth.uid())
  );
CREATE POLICY "Users can update their own subtasks"
  ON subtasks FOR UPDATE USING (
    EXISTS (SELECT 1 FROM tasks WHERE tasks.id = subtasks.task_id AND tasks.user_id = auth.uid())
  );
CREATE POLICY "Users can delete their own subtasks"
  ON subtasks FOR DELETE USING (
    EXISTS (SELECT 1 FROM tasks WHERE tasks.id = subtasks.task_id AND tasks.user_id = auth.uid())
  );

-- Notifications
CREATE POLICY "Users can access own notifications"
  ON notifications FOR ALL USING (auth.uid() = user_id);

-- Reminder settings
CREATE POLICY "Users can access own reminder settings"
  ON reminder_settings FOR ALL USING (auth.uid() = user_id);

-- User achievements
CREATE POLICY "Users can access own achievements"
  ON user_achievements FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- User points
CREATE POLICY "Users can access own points"
  ON user_points FOR ALL USING (auth.uid() = user_id);

-- User streaks
CREATE POLICY "Users can access own streaks"
  ON user_streaks FOR ALL USING (auth.uid() = user_id);


-- ── Seed: Achievements ────────────────────────────────────────────────────────

INSERT INTO achievements (key, title, description, tier, category, points, icon) VALUES
-- Streak
('streak_3',     'The Beginning',    'Log in 3 days in a row',                          'bronze',   'streak',  15,   'flame'),
('streak_7',     'Week Warrior',     'Log in 7 days in a row',                          'bronze',   'streak',  25,   'flame'),
('streak_30',    'Monthly Grind',    'Log in 30 days in a row',                         'silver',   'streak',  100,  'flame'),
('streak_100',   'Century Streak',   'Log in 100 days in a row',                        'gold',     'streak',  500,  'flame'),
('streak_365',   'Year of Wins',     'Log in 365 days in a row',                        'platinum', 'streak',  2000, 'flame'),
-- Tasks
('tasks_1',      'First Step',       'Complete your first task',                         'bronze',   'tasks',   10,   'check-circle'),
('tasks_10',     'Getting Momentum', 'Complete 10 tasks',                                'bronze',   'tasks',   30,   'check-circle'),
('tasks_50',     'Half Century',     'Complete 50 tasks',                                'silver',   'tasks',   100,  'check-circle'),
('tasks_100',    'Triple Digits',    'Complete 100 tasks',                               'silver',   'tasks',   200,  'check-circle'),
('tasks_500',    'Task Machine',     'Complete 500 tasks',                               'gold',     'tasks',   750,  'check-circle'),
('tasks_1000',   'Legendary Grind',  'Complete 1000 tasks',                              'platinum', 'tasks',   2500, 'check-circle'),
-- Goals
('goals_1',      'Goal Getter',      'Complete your first goal',                         'bronze',   'goals',   50,   'target'),
('goals_5',      'Five and Thriving','Complete 5 goals',                                 'silver',   'goals',   200,  'target'),
('goals_10',     'Goal Crusher',     'Complete 10 goals',                                'gold',     'goals',   500,  'target'),
('goals_25',     'Unstoppable',      'Complete 25 goals',                                'gold',     'goals',   1000, 'target'),
('goals_50',     'Legend',           'Complete 50 goals',                                'platinum', 'goals',   3000, 'target'),
-- Points
('points_100',   'Point Collector',  'Earn 100 total points',                            'bronze',   'points',  10,   'star'),
('points_500',   'Point Hoarder',    'Earn 500 total points',                            'bronze',   'points',  25,   'star'),
('points_1000',  'Four Figures',     'Earn 1,000 total points',                          'silver',   'points',  50,   'star'),
('points_5000',  'High Scorer',      'Earn 5,000 total points',                          'gold',     'points',  150,  'star'),
('points_10000', 'Point Legend',     'Earn 10,000 total points',                         'platinum', 'points',  500,  'star'),
-- Daily hustle
('daily_5',      'Daily Hustler',    'Complete 5 tasks in one day',                      'bronze',   'daily',   30,   'zap'),
('daily_10',     'Full Send',        'Complete 10 tasks in one day',                     'silver',   'daily',   75,   'zap'),
('daily_20',     'Absolute Unit',    'Complete 20 tasks in one day',                     'gold',     'daily',   200,  'zap'),
-- Speed
('speed_1hour',  'Quick Draw',       'Complete a task within 1 hour of creating it',     'bronze',   'speed',   20,   'timer'),
('speed_10',     'Speed Runner',     'Complete 10 tasks within 1 hour of creating them', 'silver',   'speed',   75,   'timer'),
-- Early/late
('early_bird',   'Early Bird',       'Complete a task before 8am',                       'bronze',   'daily',   20,   'sunrise'),
('night_owl',    'Night Owl',        'Complete a task after 11pm',                       'bronze',   'daily',   20,   'moon');
