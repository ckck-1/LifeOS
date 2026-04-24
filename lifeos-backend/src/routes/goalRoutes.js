const express = require("express");
const {
  addGoal,
  getGoals,
  updateGoalProgress,
} = require("../controllers/goalController");

const authenticate = require("../middlewares/authMiddleware.js");

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * tags:
 *   name: Goals
 *   description: Goal management
 */

/**
 * @swagger
 * /goals:
 *   post:
 *     summary: Add goal
 *     tags: [Goals]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             type: "fitness"
 *             description: "Lose 5kg"
 *             targetValue: 5
 *             priority: 1
 *     responses:
 *       200:
 *         description: Goal added
 */
router.post("/", addGoal);

/**
 * @swagger
 * /goals:
 *   get:
 *     summary: Get goals
 *     tags: [Goals]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of goals
 */
router.get("/", getGoals);

/**
 * @swagger
 * /goals/{id}/progress:
 *   patch:
 *     summary: Update goal progress
 *     tags: [Goals]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             value: 3
 *     responses:
 *       200:
 *         description: Goal progress updated
 */
router.patch("/:id/progress", updateGoalProgress);

module.exports = router;