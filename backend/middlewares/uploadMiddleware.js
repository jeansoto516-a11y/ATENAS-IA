const multer = require("multer");
const path = require("path");
const fs = require("fs");

const uploadsDir = path.join(__dirname, "..", "uploads");
fs.mkdirSync(uploadsDir, { recursive: true });

// Configuração do armazenamento
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },

    filename: (req, file, cb) => {
        const nomeArquivo = Date.now() + path.extname(file.originalname);
        cb(null, nomeArquivo);
    }
});

// Aceita apenas arquivos Excel
const fileFilter =(req, file, cb) => {
    const extensoes = ['.xlsx', '.xls', '.csv'];
    const extensao = path.extname(file.originalname).toLowerCase();

    if (extensoes.includes(extensao)) {
        cb(null, true);
    } else {
        cb(new Error("Apenas arquivos Excel são permitidos!"));
    }

};

module.exports = multer({
    storage, 
    fileFilter 
});
