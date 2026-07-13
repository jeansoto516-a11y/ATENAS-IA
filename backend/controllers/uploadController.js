exports.uploadArquivo = (req, res) => {

    if (!req.file) {
        return res.status(400).json({
            error: "Nenhum arquivo enviado!"
        });
    }

    console.log("Arquivo:", req.file.filename);

    console.log("Entrada:", req.body.entrada);

    console.log("Aba:", req.body.aba);

    console.log("Saída:", req.body.saida);

    res.status(200).json({
        message: "Arquivo recebido com sucesso!",
        arquivo: req.file.filename,
        entrada: req.body.entrada,
        aba: req.body.aba,
        saida: req.body.saida
    });

};