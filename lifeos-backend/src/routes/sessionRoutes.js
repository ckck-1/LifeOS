const express = require("express");
const { startSession, endSession } = require("../controllers/sessionController");
const { authenticate } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(authenticate);

router.post("/start", startSession);
router.post("/end", endSession);

module.exports = router;