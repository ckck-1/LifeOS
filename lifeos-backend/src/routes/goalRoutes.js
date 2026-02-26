const express = require("express");
const { addGoal, getGoals } = require("../controllers/goalController");
// Import the function directly since module.exports = authenticate
const authenticate = require("../middlewares/authMiddleware.js"); 

const router = express.Router();

router.use(authenticate); 

router.post("/", addGoal); 
router.get("/", getGoals); 

module.exports = router;