const express = require("express");
const { startSession, endSession } = require("../controllers/sessionController");
const authenticate = require("../middlewares/authMiddleware.js");

const router = express.Router();

router.use(authenticate);

/**
 * @swagger
 * tags:
 *   name: Sessions
 *   description: Session tracking
 */

/**
 * @swagger
 * /sessions/start:
 *   post:
 *     summary: Start session
 *     tags: [Sessions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             taskId: "task_id_here"
 *             type: "focus"
 *     responses:
 *       200:
 *         description: Session started
 */
router.post("/start", startSession);

/**
 * @swagger
 * /sessions/end:
 *   post:
 *     summary: End session
 *     tags: [Sessions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             sessionId: "session_id_here"
 *     responses:
 *       200:
 *         description: Session ended
 */
router.post("/end", endSession);

module.exports = router;