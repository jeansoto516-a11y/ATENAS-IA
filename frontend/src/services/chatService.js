import api from "./api";

export async function enviarPergunta(mensagem, historico) {
    const response = await api.post("/api/chat", { mensagem, historico });
    return response.data.resposta;
}
