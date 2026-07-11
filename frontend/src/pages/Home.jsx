import { useState } from "react";
import Card from "../components/ui/Card";
import Button from "../components/ui/Button";
import UploadArea from "../components/upload/UploadArea";
import { uploadArquivo } from "../services/uploadService";
import Input from "../components/ui/Input";

function Home() {
        const [formData, setFormData] = useState({
            file: null,
            entrada: "",
            aba: "",
            saida: "",
        });

        function handlechange(event) {
            const { name, value } = event.target;

            setFormData((prev) => ({
                ...prev,
                [name]: value,
            }));
        }

        async function handleUpload() {

    if (!file) {
    alert("Selecione um arquivo primeiro.");
    return;
    }

    try {

    const resposta = await uploadArquivo(file);

    console.log(resposta);

    alert("Arquivo enviado com sucesso!");

    } catch (erro) {

    console.error(erro);

    alert("Erro ao enviar arquivo.");

    }

}

    return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-6">

        <Card>

        <div className="flex flex-col gap-6 w-[450px]">

            <div className="text-center">
            <h1 className="text-4xl font-bold text-slate-800">
                Atenas IA
            </h1>

            <p className="text-slate-500 mt-2">
                Inteligência para Contact Centers
            </p>
            </div>

            <UploadArea
            file={formData.file}
            setFile={(file) =>
                setFormData((prev) => ({
                    ...prev, file,
                }))
            }
            />

            <Input
            label="Nome do arquivo de entrada"
            name="entrada"
            value={formData.entrada}
            onChange={handlechange}
            placeholder="Exemplo: indicadores_central.xlsx"
            />

            <Input
            label="Nome da aba"
            name="aba"
            value={formData.aba}
            onChange={handlechange}
            placeholder="Exemplo: CO_PJ"
            />

            <Input
            label="Nome do arquivo de saída"
            name="saida"
            value={formData.saida}
            onChange={handlechange}
            placeholder="Exemplo: ANALISE_INDICADORES"
            />

            <Button onClick={handleUpload}>
            Processar Arquivo
            </Button>

        </div>

        </Card>

    </div>
    );
}

export default Home;