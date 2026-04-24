const express = require("express");
const { addTask, getTasks } = require("../controllers/taskController");
const authenticate = require("../middlewares/authMiddleware.js");

const router = express.Router();


router.use(authenticate);

/**
 * @swagger
 * tags:
 *   name: Tasks
 *   description: Task management
 */

/**
 * @swagger
 * /tasks:
 *   post:
 *     summary: Add task
 *     tags: [Tasks]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             type: "work"
 *             title: "Build API"
 *             description: "Finish backend endpoints"
 *             scheduledFor: "2026-03-30T10:00:00Z"
 *             aiGenerated: false
 *     responses:
 *       200:
 *         description: Task added
 */
router.post("/", addTask);

/**
 * @swagger
 * /tasks:
 *   get:
 *     summary: Get tasks
 *     tags: [Tasks]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of tasks
 */
router.get("/", getTasks);

module.exports = router;