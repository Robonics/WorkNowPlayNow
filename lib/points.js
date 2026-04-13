const db = require('./supabase');

const POINTS = {
  task: 10,
  goal: 50,
};

/**
 * Awards points to a user for completing a task or goal.
 * @param {string} userId - The authenticated user's ID
 * @param {'task'|'goal'} sourceType - What triggered the award
 * @param {string} sourceId - The ID of the task or goal completed
 * @returns {Promise<{points: number, total: number}>}
 */
async function awardPoints(userId, sourceType, sourceId) {
  const points = POINTS[sourceType];
  if (!points) throw new Error(`Unknown source type: ${sourceType}`);

  const { error } = await db
    .from('user_points')
    .insert([{
      user_id: userId,
      source_type: sourceType,
      source_id: sourceId,
      points,
    }]);

  if (error) throw error;

  const total = await getTotalPoints(userId);
  return { points, total };
}

/**
 * Returns the total points for a user.
 * @param {string} userId
 * @returns {Promise<number>}
 */
async function getTotalPoints(userId) {
  const { data, error } = await db
    .from('user_points')
    .select('points')
    .eq('user_id', userId);

  if (error) throw error;

  return data.reduce((sum, row) => sum + row.points, 0);
}

/**
 * Returns the full points history for a user, most recent first.
 * @param {string} userId
 * @returns {Promise<Array>}
 */
async function getPointsHistory(userId) {
  const { data, error } = await db
    .from('user_points')
    .select('id, source_type, source_id, points, awarded_at')
    .eq('user_id', userId)
    .order('awarded_at', { ascending: false });

  if (error) throw error;

  return data;
}

module.exports = { awardPoints, getTotalPoints, getPointsHistory, POINTS };