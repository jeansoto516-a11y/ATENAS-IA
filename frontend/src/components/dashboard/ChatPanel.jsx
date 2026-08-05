import { useState } from "react";
import { enviarPergunta } from "../../services/chatService";

function ChatPanel() {
    const [mensagens, setMensagens] = useState([{ role: "assistant", content: "Olá! Pergunte sobre os indicadores da última análise." }]);
    const [texto, setTexto] = useState("");
    const [carregando, setCarregando] = useState(false);

    async function enviar(event) {
        event.preventDefault();
        const pergunta = texto.trim();
        if (!pergunta || carregando) return;
        const historico = mensagens;
        setMensagens((atual) => [...atual, { role: "user", content: pergunta }]);
        setTexto("");
        setCarregando(true);
        try {
            const resposta = await enviarPergunta(pergunta, historico);
            setMensagens((atual) => [...atual, { role: "assistant", content: resposta }]);
        } catch (erro) {
            setMensagens((atual) => [...atual, { role: "assistant", content: erro.response?.data?.erro || "Não foi possível consultar a IA agora." }]);
        } finally {
            setCarregando(false);
        }
    }

    return (
        <section className="mt-6 rounded-xl border border-slate-200 bg-white shadow-sm">
            <div className="border-b border-slate-100 px-5 py-4"><h2 className="font-semibold text-slate-800">Chat com Atenas</h2><p className="text-sm text-slate-500">Respostas baseadas nos KPIs processados.</p></div>
            <div className="max-h-80 space-y-3 overflow-y-auto p-5">
                {mensagens.map((item, indice) => <div key={indice} className={`max-w-[85%] rounded-xl px-4 py-3 text-sm ${item.role === "user" ? "ml-auto bg-blue-600 text-white" : "bg-slate-100 text-slate-700"}`}>{item.content}</div>)}
                {carregando && <p className="text-sm text-slate-500">Atenas está analisando…</p>}
            </div>
            <form onSubmit={enviar} className="flex gap-3 border-t border-slate-100 p-4">
                <input value={texto} onChange={(event) => setTexto(event.target.value)} placeholder="Ex.: Qual indicador merece atenção?" className="min-w-0 flex-1 rounded-lg border border-slate-300 px-3 py-2 outline-none focus:border-blue-500" />
                <button disabled={carregando} className="rounded-lg bg-blue-600 px-4 py-2 font-medium text-white disabled:opacity-60">Enviar</button>
            </form>
        </section>
    );
}

export default ChatPanel;
