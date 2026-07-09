const multer = require("multer");
const path = require("path");

// Configuração do armazenamento
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "uploads/");
    },

    filename: (req, file, cb) => {
        const nomeArquivo = Date.now() + path.extname(file.originalname);
        cb(null, nomeArquivo);
    }
});

// Aceita apenas arquivos Excel
const fileFilter =(req, file, cb) => {
    const extensoes = ['.xlsx', '.xls'];
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