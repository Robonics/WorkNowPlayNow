const express = require('express');
const router = express.Router();
const { recordLogin, getStreak } = require('../lib/streaks');
const requireAuth = require('../middlewares/auth');

router.use(requireAuth);

// POST /streaks/login - call this every time the user authenticates
// Returns current streak, longest streak, and any milestone bonus earned
router.post('/login', async (req, res, next) => {
  try {
    const result = await recordLogin(req.user.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// GET /streaks - get the current streak info for the signed-in user
router.get('/', async (req, res, next) => {
  try {
    const streak = await getStreak(req.user.id);
    res.json(streak);
  } catch (err) {
    next(err);
  }
});

module.exports = router;