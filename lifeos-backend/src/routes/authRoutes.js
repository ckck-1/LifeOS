const express = require("express");
const { register, login, me } = require("./../controllers/authContoller.js");
// Import your middleware to verify the JWT token
const { authenticate } = require("../middleware/authMiddleware.js"); 

const router = express.Router();

/**
 * @swagger
 * tags:
 * name: Auth
 * description: Authentication routes
 */

/**
 * @swagger
 * /auth/register:
 * post:
 * summary: Register user
 * tags: [Auth]
 * requestBody:
 * required: true
 * content:
 * application/json:
 * example:
 * name: "CK"
 * email: "ck@example.com"
 * password: "123456"
 * responses:
 * 200:
 * description: User registered
 * content:
 * application/json:
 * example:
 * message: "User created"
 * userId: "uuid"
 */
router.post("/register", register);

/**
 * @swagger
 * /auth/login:
 * post:
 * summary: Login user
 * tags: [Auth]
 * requestBody:
 * required: true
 * content:
 * application/json:
 * example:
 * email: "ck@example.com"
 * password: "123456"
 * responses:
 * 200:
 * description: Login successful
 * content:
 * application/json:
 * example:
 * token: "jwt_token_here"
 */
router.post("/login", login);

/**
 * @swagger
 * /auth/me:
 * get:
 * summary: Get current user profile
 * tags: [Auth]
 * security:
 * - bearerAuth: []
 * responses:
 * 200:
 * description: User profile retrieved successfully
 * content:
 * application/json:
 * example:
 * id: 1
 * email: "ck@example.com"
 * name: "CK"
 * 401:
 * description: Unauthorized
 */
router.get("/me", authenticate, me);

module.exports = router;