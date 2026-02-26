const { PrismaClient } = require("@prisma/client");
const { PrismaPg } = require("@prisma/adapter-pg");
const { Pool } = require("pg");
require('dotenv').config();

// 1. Create a standard PG pool
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// 2. Set up the Prisma adapter
const adapter = new PrismaPg(pool);

// 3. Pass the adapter to the client
const prisma = new PrismaClient({ adapter });

module.exports = prisma;