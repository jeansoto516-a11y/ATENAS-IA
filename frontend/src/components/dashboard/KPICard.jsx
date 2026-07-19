function KPIcard({ titulo, valor, vriacao}) {
    return (
        <div className="
        bg-white
        rounded-x1
        shadow
        p-5
        border
        border-slate-200
        hover:shadow-lg
        transition
        ">
            <h3 className="text-sm text-slate-500">
                {titulo}
            </h3>

            <h2 className="text-3x1 font-bold mt-3 text-slate-800">
                {valor}
            </h2>

            <p className="text-green-600 font-medium mt-3">
                {variacao}
            </p>
        </div>
    );
}

export default KPIcard;