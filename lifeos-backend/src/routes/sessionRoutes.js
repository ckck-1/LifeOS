const express = require("express");
const { startSession, endSession } = require("../controllers/sessionController");
const authenticate = require("../middlewares/authMiddleware.js");

const router = express.Router();

router.use(authenticate);

router.post("/start", startSession);
router.post("/end", endSession);

module.exports = router;