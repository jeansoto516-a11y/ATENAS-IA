const rService = require("../services/rService");

exports.uploadArquivo = (req, res) => {

    if (!req.file) {
        return res.status(400).json({
            error: "Nenhum arquivo enviado!"
        });
    }

    try {

        const caminhoScript = rService.criarScriptTemporario({
            entrada: req.body.entrada,
            aba: req.body.aba,
            saida: req.body.saida
        });

        console.log("Script temporário criado:");
        console.log(caminhoScript);

        res.status(200).json({
            message: "Script temporário criado com sucesso!",
            arquivo: req.file.filename
        });

    } catch (erro) {

        console.error(erro);

        res.status(500).json({
            error: "Erro ao criar script temporário."
        });

    }

};