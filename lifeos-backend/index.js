require("dotenv").config();
const express = require("express");
const cors = require("cors");
const http = require("http");
const swaggerUi = require("swagger-ui-express");
const swaggerSpec = require("./src/config/swagger");

const initSocket = require("./socket");

// Routes
const authRoutes = require("./../lifeos-backend/src/routes/authRoutes");
const goalRoutes = require("./../lifeos-backend/src/routes/goalRoutes");
const taskRoutes = require("./../lifeos-backend/src/routes/taskRoutes");
const sessionRoutes = require("./src/routes/sessionRoutes");
const aiRoutes = require("./../lifeos-backend/src/routes/aiRoutes");
const chatRoutes = require("./../lifeos-backend/src/routes/chatRoutes")

// Error handler
const errorHandler = require("../lifeos-backend/src/middlewares/errorHandler");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Route Mounting
app.use("/auth", authRoutes);
app.use("/goals", goalRoutes);
app.use("/tasks", taskRoutes);
app.use("/sessions", sessionRoutes);
app.use("/ai", aiRoutes);
app.use("/chat",chatRoutes)
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Health check route (optional but useful)
app.get("/", (req, res) => {
  res.json({ message: "LifeOS backend running 🚀" });
});

// Global Error Handler
app.use(errorHandler);

// Create HTTP server for Socket.io
const server = http.createServer(app);
initSocket(server);

// Start server
const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🔥 LifeOS server running on port ${PORT}`);
});