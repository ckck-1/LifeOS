require("dotenv").config();
const express = require("express");
const cors = require("cors");
const http = require("http");

const initSocket = require("./socket");

// Routes
const authRoutes = require("./../lifeos-backend/src/routes/authRoutes");
const goalRoutes = require("./../lifeos-backend/src/routes/goalRoutes");
const taskRoutes = require("./../lifeos-backend/src/routes/taskRoutes");
const sessionRoutes = require("./../lifeos-backend/src/routes/taskRoutes");
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
server.listen(PORT, () => {
  console.log(`🔥 LifeOS server running on port ${PORT}`);
});