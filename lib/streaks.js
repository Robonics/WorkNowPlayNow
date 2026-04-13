const db = require('./supabase');
const { awardPoints } = require('./points');

const STREAK_MILESTONES = [
  { days: 5,   points: 25  },
  { days: 30,  points: 100 },
  { days: 100, points: 500 },
];

/**
 * Records a login for a user and updates their streak.
 * Should be called once per session when the user authenticates.
 * @param {string} userId
 * @returns {Promise<{current_streak, longest_streak, milestoneReached, pointsAwarded}>}
 */
async function recordLogin(userId) {
  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

  // Fetch existing streak record for this user
  const { data: existing, error: fetchError } = await db
    .from('user_streaks')
    .select('id, current_streak, longest_streak, last_login_date')
    .eq('user_id', userId)
    .maybeSingle();

  if (fetchError) throw fetchError;

  // Already logged in today — return current state without changes
  if (existing?.last_login_date === today) {
    return {
      current_streak: existing.current_streak,
      longest_streak: existing.longest_streak,
      milestoneReached: null,
      pointsAwarded: null,
    };
  }

  let current_streak = 1;
  const longest_streak = existing?.longest_streak ?? 0;

  if (existing?.last_login_date) {
    const last = new Date(existing.last_login_date);
    const now  = new Date(today);
    const diffDays = Math.round((now - last) / (1000 * 60 * 60 * 24));

    if (diffDays === 1) {
      // Consecutive day — increment streak
      current_streak = (existing.current_streak ?? 0) + 1;
    } else {
      // Missed a day — reset streak
      current_streak = 1;
    }
  }

  const new_longest = Math.max(current_streak, longest_streak);

  // Upsert the streak record
  const { error: upsertError } = await db
    .from('user_streaks')
    .upsert({
      user_id: userId,
      current_streak,
      longest_streak: new_longest,
      last_login_date: today,
      updated_at: new Date().toISOString(),
    }, { onConflict: 'user_id' });

  if (upsertError) throw upsertError;

  // Check if this login hit a milestone
  let milestoneReached = null;
  let pointsAwarded = null;

  const milestone = STREAK_MILESTONES.find(m => m.days === current_streak);
  if (milestone) {
    milestoneReached = milestone.days;
    try {
      pointsAwarded = await awardPoints(userId, 'task', `streak-${milestone.days}-${today}`);
    } catch (err) {
      console.error('Streak milestone points award failed:', err.message);
    }
  }

  return {
    current_streak,
    longest_streak: new_longest,
    milestoneReached,
    pointsAwarded,
  };
}

/**
 * Returns the current streak record for a user.
 * @param {string} userId
 * @returns {Promise<{current_streak, longest_streak, last_login_date}>}
 */
async function getStreak(userId) {
  const { data, error } = await db
    .from('user_streaks')
    .select('current_streak, longest_streak, last_login_date')
    .eq('user_id', userId)
    .maybeSingle();

  if (error) throw error;

  return data ?? { current_streak: 0, longest_streak: 0, last_login_date: null };
}

module.exports = { recordLogin, getStreak, STREAK_MILESTONES };