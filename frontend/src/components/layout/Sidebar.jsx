import { Link } from "react-router-dom";

function Sidebar() {
    return (
        <aside className="w-64 shrink-0 bg-slate-900 p-6 text-white">
            <h2 className="mb-10 text-2xl font-bold">Atenas IA</h2>
            <nav className="flex flex-col gap-3 text-sm">
                <Link to="/dashboard" className="rounded-lg px-3 py-2 hover:bg-slate-800">Visão geral</Link>
                <Link to="/dashboard/diario" className="rounded-lg px-3 py-2 hover:bg-slate-800">Dashboard diário</Link>
                <Link to="/dashboard/horario" className="rounded-lg px-3 py-2 hover:bg-slate-800">Dashboard horário</Link>
                <Link to="/" className="rounded-lg px-3 py-2 hover:bg-slate-800">Processar arquivo</Link>
            </nav>
        </aside>
    );
}

export default Sidebar;
