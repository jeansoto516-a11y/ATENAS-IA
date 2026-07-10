import { useState } from "react";
import Card from "../components/ui/Card";
import Button from "../components/ui/Button";
import UploadArea from "../components/upload/UploadArea";

function Home() {
        const [file, setFile] = useState(null);

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
            file={file}
            setFile={setFile}
            />

            <Button>
            Processar Arquivo
            </Button>

        </div>

        </Card>

    </div>
    );
}

export default Home;