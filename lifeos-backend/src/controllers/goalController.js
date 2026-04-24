const prisma = require("../utils/prisma");

async function addGoal(req, res) {
  const { type, description, targetValue, priority, expiresInHours } = req.body;

  const expiresAt = expiresInHours
    ? new Date(Date.now() + expiresInHours * 60 * 60 * 1000)
    : null;

  const goal = await prisma.goal.create({
    data: {
      type,
      description,
      targetValue,
      priority,
      expiresAt,
      userId: req.user.id,
    },
  });

  res.json(goal);
}
async function updateGoalProgress(req, res) {
  const { id } = req.params;
  const { value } = req.body;

  const goal = await prisma.goal.findUnique({
    where: { id: Number(id) },
  });

  if (!goal) {
    return res.status(404).json({ error: "Goal not found" });
  }

  let progress = 0;

  if (goal.targetValue) {
    progress = (value / goal.targetValue) * 100;
    if (progress > 100) progress = 100;
  }

  const updatedGoal = await prisma.goal.update({
    where: { id: Number(id) },
    data: {
      currentValue: value,
      progress,
      status: progress >= 100 ? "completed" : "active",
    },
  });

  res.json(updatedGoal);
}

async function getGoals(req, res) {
  const goals = await prisma.goal.findMany({
    where: {
      userId: req.user.id,
      status: { in: ["active", "completed","expired"] }, // hide expired if you want
    },
    orderBy: { createdAt: "desc" },
  });

  res.json(goals);
}
module.exports = {
  addGoal,
  getGoals,
  updateGoalProgress,
};

