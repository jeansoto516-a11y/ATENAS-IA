const express = require("express");
const { conversar } = require("../controllers/chatController");

const router = express.Router();
router.post("/", conversar);

module.exports = router;
