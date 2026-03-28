const swaggerJSDoc = require("swagger-jsdoc");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "LIFEOS AI API",
      version: "1.0.0",
      description: "API for AI-powered productivity system",
    },

    // 🔥 ADD THIS BLOCK
    tags: [
      { name: "Auth", description: "Authentication routes" },
      { name: "Goals", description: "Goal management" },
      { name: "AI", description: "AI generated insights" },
      { name: "Tasks", description: "Task management" },
      { name: "Sessions", description: "Session tracking" },
      { name: "Chat", description: "AI Chat" },
    ],

    servers: [
      {
        url: "http://localhost:5000",
      },
    ],

    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
    },
  },

  apis: ["./src/routes/*.js"],
};

const swaggerSpec = swaggerJSDoc(options);

module.exports = swaggerSpec;