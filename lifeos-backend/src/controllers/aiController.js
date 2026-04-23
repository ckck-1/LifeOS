const axios = require("axios");
const prisma = require("../utils/prisma");

async function callAI(prompt) {
  try {
    const res = await axios.post(
      "https://lifeos-1-ai.onrender.com/generate",
      { prompt },
      { headers: { "Content-Type": "application/json" }, timeout: 120000 }
    );
    return res.data.reply || null;
  } catch (err) {
    console.error("AI generate error:", err.message);
    return null;
  }
}

async function weeklyPlan(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const prompt = `Generate a direct detailed weekly plan for: ${JSON.stringify(user.goals)}. Tasks: ${JSON.stringify(user.tasks)}`;
    const aiResponse = await callAI(prompt);

    if (aiResponse) {
      // Save to DB
      const savedPlan = await prisma.weeklyPlan.create({
        data: { userId: req.user.id, content: aiResponse }
      });
      return res.json({ success: true, response: savedPlan.content, id: savedPlan.id });
    }
    
    res.status(500).json({ success: false, message: "AI Failure" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

async function dailyFocus(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { tasks: true },
    });

    const prompt = `Generate today's focus (2 sentences max). Tasks: ${JSON.stringify(user.tasks)}`;
    const aiResponse = await callAI(prompt);

    if (aiResponse) {
      await prisma.aiInsight.create({
        data: { userId: req.user.id, type: "daily-focus", content: { text: aiResponse } }
      });
    }

    res.json({ success: true, response: aiResponse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}