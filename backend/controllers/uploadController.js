const rService = require("../services/rService");

exports.uploadArquivo = async (req, res) => {

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

        await rService.executarScript(caminhoScript);

        console.log("Script R executado com sucesso!");

        res.status(200).json({
            message: "Processamento concluído com sucesso!"
        });

    } catch (erro) {

        console.error("Erro no processamento:", erro);

        res.status(500).json({
            error: "Erro ao executar o processamento."
        });

    }

};