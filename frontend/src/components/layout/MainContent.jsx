import KPIGrid from "../dashboard/KPIGrid";

function MainContent() {
    return (
        <main className="flex-1 bg-slate-100 p-6">

            <div className="bg-white rounded-x1 shadow p-6 h-full">

                <h2 className="text-3x1 font-bold">
                    Dashboard ATENAS-IA
                </h2>

                <P className="text-slade-500 mt-2 mb-8">
                    Indicadores da análise processada.
                </P>

                <KPIGrid />

            </div>
        </main>
    );
}

export default MainContent;