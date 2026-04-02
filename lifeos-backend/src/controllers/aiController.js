const axios = require("axios");
const prisma = require("../utils/prisma");

// Call GPT4All Flask server

async function callAI(prompt) {
  try {
    const res = await axios.post(
      "https://lifeos-1-ai.onrender.com/generate",
      { prompt },
      { headers: { "Content-Type": "application/json" }, timeout: 120000 }
    );

    return res.data.reply || null;
  } catch (err) {
    console.error("AI generate error:", err.message, err.response?.data);
    return null;
  }
}

//
// WEEKLY PLAN
//
async function weeklyPlan(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const aiResponse = await callAI(user.goals, user.tasks);

    if (!aiResponse) {
      return res.status(500).json({
        success: false,
        message: "Failed to generate weekly plan",
      });
    }

    res.json({ success: true, response: aiResponse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}
//
// DAILY FOCUS
//
async function dailyFocus(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { tasks: true },
    });

    const prompt = `
You are LifeOS AI.

Generate today's focus for the user.

Tasks:
${JSON.stringify(user.tasks)}

Rules:
- Output ONLY 2 sentences.
- Be direct and actionable.
`;

    const aiResponse = await callAI(prompt);

    if (!aiResponse) {
      return res.status(500).json({
        success: false,
        message: "Failed to generate daily focus",
      });
    }

    res.json({ success: true, response: aiResponse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

//
// OPPORTUNITIES
//
async function opportunities(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const prompt = `
You are LifeOS AI.

Generate exactly 3 opportunities that could improve this user's income, skills, or productivity.

User goals:
${JSON.stringify(user.goals)}

User tasks:
${JSON.stringify(user.tasks)}

Rules:
- Output ONLY valid JSON
- Do not include explanations
- Do not include User/Assistant text

Format EXACTLY like this:

{
  "opportunities": [
    {
      "title": "Opportunity title",
      "description": "Short description"
    },
    {
      "title": "Opportunity title",
      "description": "Short description"
    },
    {
      "title": "Opportunity title",
      "description": "Short description"
    }
  ]
}
`;

    const aiResponse = await callAI(prompt);

    if (!aiResponse) {
      return res.status(500).json({
        success: false,
        message: "Failed to generate opportunities",
      });
    }

    let parsed;

    try {
      parsed = JSON.parse(aiResponse);
    } catch (err) {
      console.error("[AI PARSE ERROR]", aiResponse);
      return res.status(500).json({
        success: false,
        message: "AI returned invalid JSON",
      });
    }

    res.json({
      success: true,
      opportunities: parsed.opportunities,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

module.exports = {
  weeklyPlan,
  dailyFocus,
  opportunities,
};