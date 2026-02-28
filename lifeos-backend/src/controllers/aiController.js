const axios = require("axios");
const prisma = require("../utils/prisma");

// Helper to call the GPT4All Flask server
async function callAI(prompt) {
  try {
    const res = await axios.post("http://127.0.0.1:5001/generate", { prompt }, {
      headers: { "Content-Type": "application/json" },
      timeout: 360000, // 60s timeout
    });
    // Return the actual AI reply
    return res.data.reply || null;
  } catch (err) {
    console.error("AI generate error:", err.message);
    return null;
  }
}

// Controller functions
async function weeklyPlan(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const prompt = `
Summarize opportunities for this user in 2–3 sentences based on goals: ${JSON.stringify(user.goals)} 
and tasks: ${JSON.stringify(user.tasks)}. 

`;
const aiResponse = await callAI(prompt);
    if (!aiResponse) {
      return res.status(500).json({ success: false, message: "Failed to generate weekly plan" });
    }

    res.json({ success: true, response: aiResponse });
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

    const prompt = `Generate daily focus for this user based on tasks: ${JSON.stringify(user.tasks)}`;
    const aiResponse = await callAI(prompt);

    if (!aiResponse) {
      return res.status(500).json({ success: false, message: "Failed to generate daily focus" });
    }

    res.json({ success: true, response: aiResponse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

async function opportunities(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const prompt = `Generate opportunities for this user based on goals and tasks, you are strictly commanded to output 
    2 sentences response only: ${JSON.stringify(user)}`;
    //const prompt = `Hello there`
    const aiResponse = await callAI(prompt);

    if (!aiResponse) {
      return res.status(500).json({ success: false, message: "Failed to generate opportunities" });
    }

    res.json({ success: true, response: aiResponse });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
}

module.exports = {
  weeklyPlan,
  dailyFocus,
  opportunities,
};