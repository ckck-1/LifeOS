require("dotenv").config();

const { PrismaClient } = require("@prisma/client");
const { PrismaPg } = require("@prisma/adapter-pg");
const { Pool } = require("pg");

// --------------------
// PostgreSQL Pool
// --------------------
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

// --------------------
// Test connection (optional but useful)
// --------------------
pool.on("connect", () => {
  console.log("✅ PostgreSQL pool connected");
});

pool.on("error", (err) => {
  console.error("❌ PostgreSQL pool error:", err);
});

// --------------------
// Prisma Adapter
// --------------------
const adapter = new PrismaPg(pool);

// --------------------
// Singleton Prisma Client (IMPORTANT FIX)
// --------------------
let prisma;

if (!global.prisma) {
  prisma = new PrismaClient({
    adapter,
    log: ["error", "warn"],
  });

  global.prisma = prisma;
} else {
  prisma = global.prisma;
}

module.exports = prisma;