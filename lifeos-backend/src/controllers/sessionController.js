const prisma = require("../utils/prisma");

async function startSession(req, res) {
  const { taskId, type } = req.body;
  const session = await prisma.session.create({
    data: { taskId, type, sessionStart: new Date(), userId: req.user.id },
  });
  res.json(session);
}

async function endSession(req, res) {
  const { sessionId } = req.body;
  const session = await prisma.session.update({
    where: { id: sessionId },
    data: { sessionEnd: new Date(), duration: Math.floor((new Date() - new Date()) / 1000) },
  });
  res.json(session);
}

module.exports = { startSession, endSession };