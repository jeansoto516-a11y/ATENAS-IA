const fs = require("fs");
const path = require("path");
const rService = require("../services/rService");

exports.uploadArquivo = async (req, res) => {
    if (!req.file) return res.status(400).json({ error: "Nenhum arquivo enviado!" });

    try {
        const nomeSaida = path.basename(req.body.saida || `ANALISE_${req.file.filename}.xlsx`);
        const caminhoScript = rService.criarScriptTemporario({
            entrada: req.file.path,
            aba: req.body.aba || "",
            saida: nomeSaida
        });
        await rService.executarScript(caminhoScript);

        const indicadoresGerados = path.join(path.dirname(req.file.path), "indicadores.json");
        const destinoIndicadores = path.join(__dirname, "..", "indicadores.json");
        const dashboardGerado = path.join(path.dirname(req.file.path), "dashboard.json");
        const destinoDashboard = path.join(__dirname, "..", "dashboard.json");
        if (!fs.existsSync(indicadoresGerados)) throw new Error("O script R não gerou os indicadores.");
        if (!fs.existsSync(dashboardGerado)) throw new Error("O script R não gerou os dados do dashboard.");
        fs.copyFileSync(indicadoresGerados, destinoIndicadores);
        fs.copyFileSync(dashboardGerado, destinoDashboard);

        return res.status(200).json({
            message: "Processamento concluído com sucesso!",
            arquivoSaida: nomeSaida,
            indicadores: JSON.parse(fs.readFileSync(destinoIndicadores, "utf8"))
        });
    } catch (erro) {
        console.error("Erro no processamento:", erro);
        return res.status(500).json({ error: "Erro ao executar o processamento.", detalhes: erro.message });
    }
};
