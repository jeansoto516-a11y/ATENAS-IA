import KPICard from "./KPICard";

const configuracao = [
    ["sla", "SLA", "%"], ["forecast", "Forecast", "%"], ["hcPlanejado", "HC planejado", ""],
    ["hcReal", "HC real", ""], ["tma", "TMA", "s"], ["conversao", "Conversão", "%"],
    ["produtividade", "Produtividade", "%"]
];

function formatar(valor, sufixo) {
    if (valor === null || valor === undefined || Number.isNaN(Number(valor))) return "—";
    const numero = Number(valor);
    return `${numero.toLocaleString("pt-BR", { maximumFractionDigits: 2 })}${sufixo}`;
}

function KPIGrid({ dados }) {
    const kpis = dados?.kpis || {};
    return (
        <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {configuracao.map(([chave, titulo, sufixo]) => (
                <KPICard key={chave} titulo={titulo} valor={formatar(kpis[chave], sufixo)} />
            ))}
        </section>
    );
}

export default KPIGrid;
