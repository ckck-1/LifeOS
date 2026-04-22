const { defineConfig } = require("prisma/config");
require("dotenv").config(); // 👈 important

module.exports = defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: process.env.DIRECT_URL,
  },
});