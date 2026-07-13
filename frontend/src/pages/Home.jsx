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

        function handleChange(event) {
            const { name, value } = event.target;

            setFormData((prev) => ({
                ...prev,
                [name]: value,
            }));
        }

        async function handleUpload() {

    if (!formData.file) {
    alert("Selecione um arquivo primeiro.");
    return;
    }

    try {

    const resposta = await uploadArquivo(formData);

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
                setFile={(file) => {

                    const nomesemextensão = file.name.replace(/\.[^/.]+$/, "");

                    setFormData((prev) => ({
                        ...prev,
                        file,
                        entrada: file.name,
                        aba: "ANALITICO",
                        saida: `${nomesemextensão}_TRATADO`,
                    }));
                
                }}
            />

            <Input
            label="Nome do arquivo de entrada"
            name="entrada"
            value={formData.entrada}
            onChange={handleChange}
            placeholder="Exemplo: indicadores_central.xlsx"
            />

            <Input
            label="Nome da aba"
            name="aba"
            value={formData.aba}
            onChange={handleChange}
            placeholder="Exemplo: CO_PJ"
            />

            <Input
            label="Nome do arquivo de saída"
            name="saida"
            value={formData.saida}
            onChange={handleChange}
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