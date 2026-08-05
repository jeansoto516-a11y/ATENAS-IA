const express = require("express");
const controller = require("../controllers/dashboardController");

const router = express.Router();
router.get("/:periodo", controller.buscarDados);
router.put("/:periodo", controller.atualizarDados);

module.exports = router;
