const { responderPergunta } = require("../services/chatService");

exports.conversar = async (req, res) => {
    const { mensagem, historico = [] } = req.body;
    if (!mensagem || typeof mensagem !== "string" || !mensagem.trim()) {
        return res.status(400).json({ erro: "Envie uma pergunta para a Atenas." });
    }

    try {
        return res.json(await responderPergunta(mensagem.trim(), historico));
    } catch (erro) {
        console.error("Erro no chat:", erro);
        if (erro.status === 429) {
            return res.status(429).json({ erro: "A conta da OpenAI está sem créditos. Adicione saldo em platform.openai.com/settings/organization/billing para reativar as respostas por IA." });
        }
        return res.status(erro.codigo === "OPENAI_NAO_CONFIGURADA" ? 503 : 500).json({ erro: erro.message });
    }
};
