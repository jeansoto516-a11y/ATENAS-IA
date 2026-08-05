function KPICard({ titulo, valor }) {
    return (
        <article className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm transition hover:shadow-md">
            <h3 className="text-sm font-medium text-slate-500">{titulo}</h3>
            <p className="mt-3 text-3xl font-bold text-slate-800">{valor}</p>
        </article>
    );
}

export default KPICard;
