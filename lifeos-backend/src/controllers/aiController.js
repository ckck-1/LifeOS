const axios = require("axios");
const prisma = require("../utils/prisma");

// صغير helper delay
const delay = (ms) => new Promise((res) => setTimeout(res, ms));

/**
 * 🔥 Robust AI call with retry + logging
 */
async function callAI(prompt, retries = 2) {
  try {
    const res = await axios.post(
      "https://lifeos-1-ai.onrender.com/generate",
      { prompt },
      {
        headers: { "Content-Type": "application/json" },
        timeout: 120000,
      }
    );

    return res.data.reply || null;
  } catch (err) {
    console.error("AI FULL ERROR:", {
      message: err.message,
      status: err.response?.status,
      data: err.response?.data,
    });

    // Retry if possible (for 429 / temporary issues)
    if (retries > 0) {
      await delay(1500);
      return callAI(prompt, retries - 1);
    }

    return null;
  }
}

/**
 * 🔥 Daily AI call (same robustness)
 */
async function getDaily(prompt, retries = 2) {
  try {
    const res = await axios.post(
      "https://lifeos-1-ai.onrender.com/daily-focus",
      { prompt },
      {
        headers: { "Content-Type": "application/json" },
        timeout: 120000,
      }
    );

    return res.data.reply || null;
  } catch (err) {
    console.error("DAILY AI ERROR:", {
      message: err.message,
      status: err.response?.status,
      data: err.response?.data,
    });

    if (retries > 0) {
      await delay(1500);
      return getDaily(prompt, retries - 1);
    }

    return null;
  }
}

/**
 * 📅 Weekly Plan
 */
async function weeklyPlan(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const prompt = `
You are LifeOS AI.

Generate a structured weekly execution plan.

GOALS:
${JSON.stringify(user.goals)}

TASKS:
${JSON.stringify(user.tasks)}

RULES:
- Be direct
- Focus on execution
- Break into days if possible
- No fluff
`;

    const aiResponse = await callAI(prompt);

    // ✅ Fallback if AI fails
    const finalResponse =
      aiResponse ||
      "Focus on your top 3 goals this week. Break them into daily actions and eliminate distractions.";

    // Save to DB
    const savedPlan = await prisma.weeklyPlan.create({
      data: { userId: req.user.id, content: finalResponse },
    });

    return res.json({
      success: true,
      response: savedPlan.content,
      id: savedPlan.id,
    });
  } catch (err) {
    console.error("WEEKLY PLAN ERROR:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
}

/**
 * 📌 Daily Focus
 */
async function dailyFocus(req, res) {
  try {
    const userId = req.user.id;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // ✅ 1. Check cache
    const existingFocus = await prisma.aIInsight.findFirst({
      where: {
        userId: userId,
        type: "daily-focus",
        createdAt: { gte: today },
      },
      orderBy: { createdAt: "desc" },
    });

    if (existingFocus) {
      return res.json({
        success: true,
        response: existingFocus.content.text,
      });
    }

    // ✅ 2. Get user data
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { tasks: true },
    });

    const prompt = `
You are LifeOS AI — a precision execution engine.

STRICT RULES:
- Maximum 2 sentences
- Short and actionable
- No fluff
- No explanations

USER TASKS:
${JSON.stringify(user.tasks)}
`;

    const aiResponse = await getDaily(prompt);

    // ✅ fallback
    const finalResponse =
      aiResponse ||
      "Complete your highest priority task first. Avoid distractions and finish what you start.";

    const saved = await prisma.aIInsight.create({
      data: {
        userId: userId,
        type: "daily-focus",
        content: { text: finalResponse },
      },
    });

    return res.json({
      success: true,
      response: finalResponse,
    });
  } catch (err) {
    console.error("DAILY FOCUS ERROR:", err.message);

    return res.status(500).json({
      success: false,
      message: err.message,
    });
  }
}

module.exports = {
  weeklyPlan,
  dailyFocus,
};