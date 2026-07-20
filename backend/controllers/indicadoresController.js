const fs = require("fs");
const path = require("path");

exports.buscarIndicadores = (req, res) => {

    try {

        const caminhoJson = path.join(
            "C:",
            "Users",
            "Samsung",
            "OneDrive",
            "Desktop",
            "HUB 2026",
            "ANALISES_R",
            "indicadores.json"
        );

        if (!fs.existsSync(caminhoJson)) {

            return res.status(404).json({
                erro: "indicadores.json não encontrado."
            });

        }

        const indicadores = JSON.parse(
            fs.readFileSync(caminhoJson, "utf8")
        );

        res.json(indicadores);

    } catch (error) {

        console.error(error);

        res.status(500).json({
            erro: "Erro ao ler indicadores."
        });

    }

};