const express = require("express");
const router = express.Router();

const indicadoresController = require("../controllers/indicadoresController");

router.get("/", indicadoresController.buscarindicadores);

module.exports = router;