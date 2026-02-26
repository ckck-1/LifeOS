const express = require("express");
const router = express.Router();

const authMiddleware = require("../middlewares/authMiddleware.js");
const {
  weeklyPlan,
  dailyFocus,
  opportunities,
} = require("../controllers/aiController.js");

router.get("/weekly-plan", authMiddleware, weeklyPlan);
router.get("/daily-focus", authMiddleware, dailyFocus);
router.get("/opportunities", authMiddleware, opportunities);

module.exports = router;