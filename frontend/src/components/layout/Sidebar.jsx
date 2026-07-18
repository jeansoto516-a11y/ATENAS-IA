function Sidebar() {
    return (
        <aside className="w-64 bg-slate-900 text-white h-screen p-6">
            <h2 className="text-2xl font-bold mb-10">
                Atenas IA
            </h2>

            <nav className="flex flex-col gap-4">

                <button className="text-left hover:text-blue-400">
                    📊 Dashboard
                </button>

                <button className="text-left hover:text-blue-400">
                    💬 Chat IA
                </button>

                <button className="text-left hover:text-blue-400">
                    📄 Histórico
                </button>

                <button className="text-left hover:text-blue-400">
                    ⚙ Configurações
                </button>

            </nav>
        </aside>
    );
}

export default Sidebar;