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
    const userId = req.user.id;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 1. Efficiency Check: Look for a focus already generated today
    const existingFocus = await prisma.aIInsight.findFirst({
      where: {
        userId: userId,
        type: "daily-focus",
        createdAt: { gte: today },
      },
      orderBy: { createdAt: 'desc' }
    });

    if (existingFocus) {
      // Return cached version immediately
      return res.json({ 
        success: true, 
        response: existingFocus.content.text 
      });
    }

    // 2. Fallback: If none exists, generate via AI
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { tasks: true },
    });

    const prompt = `Generate today's focus (MANDATORY:2 sentences max). Tasks: ${JSON.stringify(user.tasks)}`;
  const aiResponse = await callAI([
  {
    role: "system",
    content: `
You are LifeOS AI — a precision daily execution engine.

STRICT RULES:
- Maximum 2 sentences ONLY
- Each sentence must be short and actionable
- No explanations
- No greetings
- No extra words before or after
- No formatting, no bullets

Focus on highest impact actions only.
`
  },
  {
    role: "user",
    content: `User tasks: ${JSON.stringify(user.tasks)}`
  }
]);

    if (aiResponse) {
      const saved = await prisma.aIInsight.create({
        data: { 
          userId: userId, 
          type: "daily-focus", 
          content: { text: aiResponse } 
        }
      });
      return res.json({ success: true, response: aiResponse });
    }

    res.status(500).json({ success: false, message: "AI generation failed" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

module.exports = {
  weeklyPlan,
  dailyFocus,
};