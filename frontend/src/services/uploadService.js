import api from "./api";

export async function uploadArquivo(file) {
    const formData = new FormData();

    formData.append("arquivo", file);

    const response = await api.post("/upload", formData);

    return response.data;
}