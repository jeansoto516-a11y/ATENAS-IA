import api from "./api";

export async function uploadArquivo(fromData) {

    const dados = new FormData();
    dados.append("arquivo", fromData.file);
    dados.append("entrada", fromData.entrada);
    dados.append("aba", fromData.aba);
    dados.append("saida", fromData.saida);

    const response = await api.post("/upload", dados);

    return response.data;

}