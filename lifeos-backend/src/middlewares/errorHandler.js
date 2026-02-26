/**
 * Centralized Error Handler Middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error("--- ERROR LOG ---");
  console.error(err.stack); // Logs the full stack trace to your terminal

  // Default status and message
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  // Prisma-specific error handling (optional but helpful)
  if (err.code === 'P2002') {
    return res.status(400).json({
      success: false,
      message: "Unique constraint failed. A record with this value already exists.",
    });
  }

  res.status(statusCode).json({
    success: false,
    message: message,
    // Only show stack trace in development mode
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = errorHandler;