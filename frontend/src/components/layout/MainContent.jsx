import { useEffect, useState } from "react";
import api from "../../services/api";
import KPIGrid from "../dashboard/KPIGrid";
import ChatPanel from "../dashboard/ChatPanel";

function MainContent() {
    const [indicadores, setIndicadores] = useState(null);
    const [erro, setErro] = useState("");

    useEffect(() => {
        api.get("/api/indicadores").then((response) => setIndicadores(response.data)).catch(() => setErro("Processe um arquivo para visualizar os indicadores."));
    }, []);

    return (
        <main className="flex-1 overflow-y-auto bg-slate-100 p-6">
            <div className="mx-auto max-w-7xl">
                <h2 className="text-3xl font-bold text-slate-900">Dashboard Atenas IA</h2>
                <p className="mb-6 mt-2 text-slate-500">Indicadores da última análise processada.</p>
                {erro ? <p className="rounded-lg bg-amber-50 p-4 text-amber-800">{erro}</p> : <KPIGrid dados={indicadores} />}
                <ChatPanel />
            </div>
        </main>
    );
}

export default MainContent;
