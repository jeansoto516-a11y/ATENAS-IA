import Card from "../components/ui/Card";
import Button from "../components/ui/Button";

function Home() {
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

            <div className="border-2 border-dashed border-slate-300 rounded-xl p-8 text-center">
            <p className="text-slate-500">
                Nenhum arquivo selecionado
            </p>
            </div>

            <Button>
            Processar Arquivo
            </Button>

        </div>
        </Card>
    </div>
    );
}

export default Home;