const prisma = require("../utils/prisma");

//  Add Task
async function addTask(req, res) {
  const { type, title, description, scheduledFor, aiGenerated } = req.body;

  const task = await prisma.task.create({
    data: {
      type,
      title,
      description,
      scheduledFor,
      aiGenerated,
      userId: req.user.id,
    },
  });

  res.json(task);
}

// Get Tasks
async function getTasks(req, res) {
  const tasks = await prisma.task.findMany({
    where: { userId: req.user.id },
    orderBy: { createdAt: "desc" },
  });

  res.json(tasks);
}

// Complete Task → auto delete in 10 mins
async function completeTask(req, res) {
  const { id } = req.params;

  const now = new Date();
  const deleteAt = new Date(now.getTime() + 10 * 60 * 1000); // +10 mins

  const task = await prisma.task.update({
    where: {
      id: Number(id),
    },
    data: {
      status: "completed",
      endTime: now,
      deleteAt,
    },
  });

  res.json({
    message: "Task completed. It will be deleted in 10 minutes.",
    task,
  });
}

module.exports = {
  addTask,
  getTasks,
  completeTask,
};