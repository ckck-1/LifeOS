const express = require("express");
const router = express.Router();
const chatController = require("../controllers/chatController");
const authMiddleware = require("../middlewares/authMiddleware");

/**
 * @swagger
 * tags:
 *   name: Chat
 *   description: AI Chat
 */

/**
 * @swagger
 * /chat:
 *   post:
 *     summary: Chat with LifeOS AI
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           example:
 *             message: "How can I be more productive?"
 *     responses:
 *       200:
 *         description: AI response
 *         content:
 *           application/json:
 *             example:
 *               reply: "Focus on high-impact tasks first."
 */
router.post("/", authMiddleware, chatController.chatWithAI);

module.exports = router;