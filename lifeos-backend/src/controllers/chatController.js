const axios = require("axios");
const prisma = require("../lib/prisma"); // ✅ IMPORTANT: use singleton only

exports.chatWithAI = async (req, res, next) => {
  try {
    const { message } = req.body;
    const userId = req.user.id;

    if (!message) {
      return res.status(400).json({ message: "Message is required" });
    }

    // -------------------------
    // 1. Get or create conversation
    // -------------------------
    let conversation = await prisma.conversation.findFirst({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    if (!conversation) {
      conversation = await prisma.conversation.create({
        data: {
          userId,
          title: message.slice(0, 30),
        },
      });
    }

    // -------------------------
    // 2. Save user message
    // -------------------------
    await prisma.message.create({
      data: {
        conversationId: conversation.id,
        role: "user",
        content: message,
      },
    });

    // -------------------------
    // 3. Get conversation memory
    // -------------------------
    const history = await prisma.message.findMany({
      where: { conversationId: conversation.id },
      orderBy: { createdAt: "desc" },
      take: 10,
    });

    const formattedHistory = history.reverse().map((msg) => ({
      role: msg.role,
      content: msg.content,
    }));

    // -------------------------
    // 4. Call AI (with memory)
    // -------------------------
    const response = await axios.post(
      "https://lifeos-1-ai.onrender.com/chat",
      {
        message,
        history: formattedHistory,
      }
    );

    const aiReply = response.data.reply;

    // -------------------------
    // 5. Save AI response
    // -------------------------
    await prisma.message.create({
      data: {
        conversationId: conversation.id,
        role: "assistant",
        content: aiReply,
      },
    });

    // -------------------------
    // 6. Update conversation metadata
    // -------------------------
    await prisma.conversation.update({
      where: { id: conversation.id },
      data: {
        lastMessageAt: new Date(),
      },
    });

    // -------------------------
    // 7. Response
    // -------------------------
    return res.json({
      reply: aiReply,
      conversationId: conversation.id,
    });
  } catch (error) {
    console.error("AI Chat Error:", error);
    next(error);
  }
};