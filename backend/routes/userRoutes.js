const express = require('express');
const router = express.Router();
const { getAllUsers, getUserById, getUsersByRole } = require('../controllers/userController');

/**
 * @route GET /api/v1/users
 * @desc Get all users from Firebase
 */
router.get('/', getAllUsers);

/**
 * @route GET /api/v1/users/:id
 * @desc Get user by ID from Firebase
 */
router.get('/:id', getUserById);

/**
 * @route GET /api/v1/users/role/:role
 * @desc Get users by role from Firebase
 */
router.get('/role/:role', getUsersByRole);

module.exports = router;