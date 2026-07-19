import KPICard from "./KPICard";

function KPIGrid() {
    return (
        <div className="grid grid-cols-3 gap-6">

            <KPICard
                titulo="SLA"
                valor="92,4%"
                variacao="+1,2%"
            />

            <KPICard
                titulo="TMA"
                valor="235s"
                variacao="-8s"
            />

            <KPICard
                titulo="HC"
                valor="148"
                variacao="+3"
            />

            <KPICard
                titulo="Conversão"
                valor="38%"
                variacao="+5%"
            />

            <KPICard
                titulo="Forecast"
                valor="96%"
                variacao="-1%"
            />

            <KPICard
                titulo="Produtividade"
                valor="88%"
                variacao="+2%"
            />

        </div>
    );
}

export default KPIGrid;