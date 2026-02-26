const prisma = require("../utils/prisma");

async function addTask(req, res) {
  const { type, title, description, scheduledFor, aiGenerated } = req.body;
  const task = await prisma.task.create({
    data: { type, title, description, scheduledFor, aiGenerated, userId: req.user.id },
  });
  res.json(task);
}

async function getTasks(req, res) {
  const tasks = await prisma.task.findMany({ where: { userId: req.user.id } });
  res.json(tasks);
}

module.exports = { addTask, getTasks };