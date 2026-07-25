import { useEffect, useState  } from "react";
import axios from "axios";
import KPIGrid from "../dashboard/KPIGrid";

function MainContent() {

    const [indicadores, setIndicadores] = useState(null);

    useEffect(() => {

        async function carregarIndicadores() {

            try {

                const response = await axios.get("http://localhost:3000/api/indicadores");

                setIndicadores(response.data);

            } catch (error) {

                console.error("Erro ao buscar indicadores:", error);

            }

        }

        carregarIndicadores();

    }, []);

    return (
        <main className="flex-1 bg-slate-100 p-6">

            <div className="bg-white rounded-xl shadow p-6 h-full">

                <h2 className="text-3xl font-bold">
                    Dashboard Atenas IA
                </h2>

                <p className="text-slate-500 mt-2 mb-8">
                    Indicadores da análise processada.
                </p>

                <KPIGrid dados={indicadores} />

            </div>

        </main>
    );
}

export default MainContent;