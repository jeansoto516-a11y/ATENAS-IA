const express = require("express");
const router = express.Router();

const upload = require("../middlewares/uploadMiddleware");

// Rota para upload de arquivos
router.post("/", upload.single("arquivo"), (req, res) => {

    if (!req.file) {
        return res.status(400).json({ 
            error: "Nenhum arquivo enviado!" 
        });
    }

    res.status(200).json({
        message: "Arquivo enviado com sucesso!",
        arquivo: req.file.filename
    });
});

module.exports = router;