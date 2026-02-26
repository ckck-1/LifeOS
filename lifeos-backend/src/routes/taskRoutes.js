const express = require("express");
const { addTask, getTasks } = require("../controllers/taskController");
const authenticate = require("../middlewares/authMiddleware.js"); 

const router = express.Router();

router.use(authenticate);

router.post("/", addTask);
router.get("/", getTasks);

module.exports = router;