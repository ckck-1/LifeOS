const prisma = require("../utils/prisma");

async function addGoal(req, res) {
  const { type, description, targetValue, priority } = req.body;
  const goal = await prisma.goal.create({
    data: { type, description, targetValue, priority, userId: req.user.id },
  });
  res.json(goal);
}

async function getGoals(req, res) {
  const goals = await prisma.goal.findMany({ where: { userId: req.user.id } });
  res.json(goals);
}

module.exports = { addGoal, getGoals };