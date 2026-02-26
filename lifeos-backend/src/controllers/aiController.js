const prisma = require("../utils/prisma");
const {
  generateWeeklyPlan,
  generateDailyFocus,
  generateOpportunities,
} = require("../utils/aiClient");

async function weeklyPlan(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const plan = await generateWeeklyPlan(user);
    res.json({ success: true, plan });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

async function dailyFocus(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { tasks: true },
    });

    const focus = await generateDailyFocus(user);
    res.json({ success: true, focus });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

async function opportunities(req, res) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      include: { goals: true, tasks: true },
    });

    const ops = await generateOpportunities(user);
    res.json({ success: true, opportunities: ops });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
}

module.exports = {
  weeklyPlan,
  dailyFocus,
  opportunities,
};