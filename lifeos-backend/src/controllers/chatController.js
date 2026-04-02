const axios = require("axios");

exports.chatWithAI = async (req, res, next) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ message: "Message is required" });
    }

    // Call your local Python AI server
    const response = await axios.post("https://lifeos-1-ai.onrender.com/chat", {
      message,
    });

    res.json({
      reply: response.data.reply,
    });
  } catch (error) {
    console.error("AI Chat Error:", error.message);
    next(error);
  }
};