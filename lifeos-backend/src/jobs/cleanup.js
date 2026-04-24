const prisma = require("../utils/prisma");

function startCleanupJob() {
  setInterval(async () => {
    const now = new Date();

    try {
      // 🧹 1. Delete completed tasks after deleteAt
      const deletedTasks = await prisma.task.deleteMany({
        where: {
          deleteAt: { lte: now },
        },
      });

      // ⏰ 2. Expire goals (DON'T delete, just mark expired)
      const expiredGoals = await prisma.goal.updateMany({
        where: {
          expiresAt: { lte: now },
          status: "active",
        },
        data: {
          status: "expired",
        },
      });

      // optional logging (only if something happened)
      if (deletedTasks.count || expiredGoals.count) {
        console.log(
          `🧹 Tasks deleted: ${deletedTasks.count} | Goals expired: ${expiredGoals.count}`
        );
      }
    } catch (err) {
      console.error("❌ Cleanup job failed:", err.message);
    }
  }, 60 * 1000); // runs every 1 min
}

module.exports = startCleanupJob;