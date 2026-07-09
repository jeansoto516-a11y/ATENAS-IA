const express = require("express");
const router = express.Router();

router.post("/", (req, res) => {
    res.json({
        mensagem: "Rota de upload funcionando!"
    });
});

module.exports = router;