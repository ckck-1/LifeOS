require("dotenv").config();

const { PrismaClient } = require("@prisma/client");
const { PrismaPg } = require("@prisma/adapter-pg");
const { Pool } = require("pg");

// Create PostgreSQL pool with SSL (required for Supabase)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

// Optional: Test connection (runs once at startup)
pool.connect()
  .then(() => console.log("✅ Connected to PostgreSQL"))
  .catch((err) => console.error("❌ Database connection error:", err));

// Prisma adapter setup
const adapter = new PrismaPg(pool);

// Prisma client
const prisma = new PrismaClient({
  adapter,
  log: ["error", "warn"], // optional: helps debugging
});

module.exports = prisma;