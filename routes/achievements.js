const express = require('express');
const router = express.Router();
const { getAchievementsForUser, getUnlockedCount } = require('../lib/achievements');
const requireAuth = require('../middlewares/auth');

router.use(requireAuth);

// GET /achievements — all achievements with unlocked status for the current user
router.get('/', async (req, res, next) => {
  try {
    const achievements = await getAchievementsForUser(req.user.id, req.token);
    res.json({ achievements });
  } catch (err) {
    next(err);
  }
});

// GET /achievements/count — just the unlocked count for the stats sidebar
router.get('/count', async (req, res, next) => {
  try {
    const count = await getUnlockedCount(req.user.id, req.token);
    res.json({ count });
  } catch (err) {
    next(err);
  }
});

module.exports = router;