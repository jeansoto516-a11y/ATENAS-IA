const fs = require("fs");
const path = require("path");
const OpenAI = require("openai");

function obterIndicadores() {
    const arquivo = path.join(__dirname, "..", "indicadores.json");
    return fs.existsSync(arquivo) ? JSON.parse(fs.readFileSync(arquivo, "utf8")) : { kpis: {} };
}

function formatarKpi(valor, sufixo = "") {
    return typeof valor === "number" ? `${valor.toLocaleString("pt-BR", { maximumFractionDigits: 2 })}${sufixo}` : "não disponível";
}

function respostaSemCreditos() {
    const kpis = obterIndicadores().kpis || {};
    return [
        "A IA da OpenAI está temporariamente indisponível porque a conta não possui créditos de API.",
        "Resumo da última análise:",
        `• SLA: ${formatarKpi(kpis.sla, "%")}`,
        `• TMA: ${formatarKpi(kpis.tma, "s")}`,
        `• HC planejado: ${formatarKpi(kpis.hcPlanejado)}`,
        `• HC real: ${formatarKpi(kpis.hcReal)}`,
        "Adicione créditos em https://platform.openai.com/settings/organization/billing para voltar a usar perguntas em linguagem natural."
    ].join("\n");
}

async function responderPergunta(mensagem, historico) {
    if (!process.env.OPENAI_API_KEY) {
        const erro = new Error("Chat não configurado. Adicione OPENAI_API_KEY ao arquivo backend/.env.");
        erro.codigo = "OPENAI_NAO_CONFIGURADA";
        throw erro;
    }

    const conversa = Array.isArray(historico) ? historico.slice(-8).map((item) => ({
        role: item.role === "assistant" ? "assistant" : "user",
        content: String(item.content || "").slice(0, 2000)
    })) : [];
    const cliente = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
    try {
        const response = await cliente.responses.create({
            model: process.env.OPENAI_MODEL || "gpt-5",
            store: false,
            instructions: `Você é Atenas, analista operacional de contact centers. Responda em português do Brasil, de forma objetiva. Use somente os KPIs fornecidos como fatos; não invente dados. Se faltar contexto, deixe isso claro.\n\nKPIs da última análise:\n${JSON.stringify(obterIndicadores().kpis || {}, null, 2)}`,
            input: [...conversa, { role: "user", content: mensagem }]
        });
        return { resposta: response.output_text || "Não foi possível gerar uma resposta para esta pergunta.", modo: "ia" };
    } catch (erro) {
        if (erro.status === 429) return { resposta: respostaSemCreditos(), modo: "resumo-local" };
        throw erro;
    }
}

module.exports = { responderPergunta };
