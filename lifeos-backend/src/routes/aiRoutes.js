const express = require("express");
const router = express.Router();

const authMiddleware = require("../middlewares/authMiddleware.js");
const {
  weeklyPlan,
  dailyFocus,
  opportunities,
} = require("../controllers/aiController.js");

/**
 * @swagger
 * tags:
 *   name: AI
 *   description: AI generated insights
 */

/**
 * @swagger
 * /ai/weekly-plan:
 *   get:
 *     summary: Get weekly plan
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Weekly plan generated
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               response: "Focus on your top 3 goals this week."
 */
router.get("/weekly-plan", authMiddleware, weeklyPlan);

/**
 * @swagger
 * /ai/daily-focus:
 *   get:
 *     summary: Get daily focus
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Daily focus generated
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               response: "Complete your most important task first."
 */
router.get("/daily-focus", authMiddleware, dailyFocus);

/**
 * @swagger
 * /ai/opportunities:
 *   get:
 *     summary: Get opportunities
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Opportunities generated
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               opportunities:
 *                 - title: "Freelance Web Dev"
 *                   description: "Build websites for local businesses"
 */
router.get("/opportunities", authMiddleware, opportunities);

module.exports = router;