const fs = require("fs");
const path = require("path");

const arquivoDashboard = path.join(__dirname, "..", "dashboard.json");

function lerDashboard() {
    if (!fs.existsSync(arquivoDashboard)) throw new Error("dashboard.json não encontrado. Processe um arquivo primeiro.");
    return JSON.parse(fs.readFileSync(arquivoDashboard, "utf8"));
}

exports.buscarDados = (req, res) => {
    const periodo = req.params.periodo;
    if (!["diario", "horario"].includes(periodo)) return res.status(400).json({ erro: "Período inválido." });
    try {
        const dashboard = lerDashboard();
        return res.json({ metadata: dashboard.metadata, dados: dashboard[periodo] || [] });
    } catch (erro) {
        return res.status(404).json({ erro: erro.message });
    }
};

exports.atualizarDados = (req, res) => {
    const periodo = req.params.periodo;
    const { dados } = req.body;
    if (!["diario", "horario"].includes(periodo) || !Array.isArray(dados)) return res.status(400).json({ erro: "Dados inválidos." });
    try {
        const dashboard = lerDashboard();
        dashboard[periodo] = dados.map((linha) => ({
            intervalo: String(linha.intervalo || ""),
            indicador: String(linha.indicador || ""),
            real: linha.real === "" || linha.real === null ? null : Number(linha.real),
            plano: linha.plano === "" || linha.plano === null ? null : Number(linha.plano)
        }));
        fs.writeFileSync(arquivoDashboard, JSON.stringify(dashboard, null, 2));
        return res.json({ message: "Dados atualizados.", metadata: dashboard.metadata, dados: dashboard[periodo] });
    } catch (erro) {
        return res.status(500).json({ erro: "Não foi possível salvar os dados editados." });
    }
};
