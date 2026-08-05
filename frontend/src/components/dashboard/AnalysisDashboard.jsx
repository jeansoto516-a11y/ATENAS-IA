import { useEffect, useMemo, useState } from "react";
import api from "../../services/api";

function LinhaChart({ dados }) {
    const valores = dados.flatMap((linha) => [linha.real, linha.plano]).filter((valor) => Number.isFinite(Number(valor)));
    if (!valores.length) return <p className="p-6 text-sm text-slate-500">Não há dados suficientes para este gráfico.</p>;
    const minimo = Math.min(...valores);
    const maximo = Math.max(...valores);
    const faixa = maximo - minimo || 1;
    const pontos = (chave) => dados.map((linha, indice) => {
        const x = dados.length === 1 ? 20 : 20 + (indice * 560) / (dados.length - 1);
        const y = 180 - ((Number(linha[chave]) - minimo) / faixa) * 150;
        return `${x},${Number.isFinite(y) ? y : 180}`;
    }).join(" ");
    return <svg viewBox="0 0 600 210" className="h-64 w-full"><line x1="20" y1="180" x2="580" y2="180" stroke="#cbd5e1" /><polyline fill="none" stroke="#2563eb" strokeWidth="3" points={pontos("real")} /><polyline fill="none" stroke="#f97316" strokeWidth="3" strokeDasharray="7 5" points={pontos("plano")} /><text x="22" y="202" fill="#64748b" fontSize="12">Real</text><text x="70" y="202" fill="#64748b" fontSize="12">Plano</text></svg>;
}

function AnalysisDashboard({ periodo }) {
    const [dados, setDados] = useState([]);
    const [metadata, setMetadata] = useState(null);
    const [indicador, setIndicador] = useState("");
    const [erro, setErro] = useState("");
    const [salvando, setSalvando] = useState(false);
    const titulo = periodo === "diario" ? "Dashboard diário" : "Dashboard por horário";

    useEffect(() => {
        api.get(`/api/dashboard/${periodo}`).then((resposta) => {
            setDados(resposta.data.dados || []); setMetadata(resposta.data.metadata);
            setIndicador(resposta.data.dados?.[0]?.indicador || "");
        }).catch((e) => setErro(e.response?.data?.erro || "Processe um arquivo para criar este dashboard."));
    }, [periodo]);

    const indicadores = useMemo(() => [...new Set(dados.map((linha) => linha.indicador))], [dados]);
    const dadosGrafico = dados.filter((linha) => linha.indicador === indicador);
    function editar(indice, campo, valor) { setDados((atual) => atual.map((linha, i) => i === indice ? { ...linha, [campo]: campo === "intervalo" ? valor : valor === "" ? null : Number(valor) } : linha)); }
    async function salvar() { setSalvando(true); try { const resposta = await api.put(`/api/dashboard/${periodo}`, { dados }); setDados(resposta.data.dados); } catch { setErro("Não foi possível salvar as alterações."); } finally { setSalvando(false); } }

    return <main className="flex-1 overflow-y-auto bg-slate-100 p-6"><div className="mx-auto max-w-7xl"><h2 className="text-3xl font-bold text-slate-900">{titulo}</h2><p className="mt-2 text-slate-500">Arquivo tratado: <strong>{metadata?.arquivo || "—"}</strong>{metadata?.dataProcessamento ? ` • ${metadata.dataProcessamento}` : ""}</p>{erro && <p className="mt-4 rounded-lg bg-amber-50 p-4 text-amber-800">{erro}</p>}{!erro && <><section className="mt-6 rounded-xl bg-white p-5 shadow-sm"><div className="mb-4 flex flex-wrap items-center justify-between gap-3"><div><h3 className="font-semibold text-slate-800">Plano × Real</h3><p className="text-sm text-slate-500">Azul: real · Laranja: plano</p></div><select value={indicador} onChange={(e) => setIndicador(e.target.value)} className="rounded-lg border border-slate-300 px-3 py-2">{indicadores.map((item) => <option key={item}>{item}</option>)}</select></div><LinhaChart dados={dadosGrafico} /></section><section className="mt-6 rounded-xl bg-white p-5 shadow-sm"><div className="mb-4 flex items-center justify-between"><div><h3 className="font-semibold text-slate-800">Editar dados</h3><p className="text-sm text-slate-500">Altere como em uma planilha e salve para atualizar o gráfico.</p></div><button onClick={salvar} disabled={salvando} className="rounded-lg bg-blue-600 px-4 py-2 font-medium text-white disabled:opacity-60">{salvando ? "Salvando…" : "Salvar alterações"}</button></div><div className="overflow-x-auto"><table className="w-full min-w-[680px] text-left text-sm"><thead className="border-b text-slate-500"><tr><th className="p-2">Intervalo</th><th className="p-2">Indicador</th><th className="p-2">Real</th><th className="p-2">Plano</th></tr></thead><tbody>{dados.map((linha, indice) => <tr key={`${linha.indicador}-${indice}`} className="border-b"><td className="p-2"><input value={linha.intervalo} onChange={(e) => editar(indice, "intervalo", e.target.value)} className="w-full rounded border p-1" /></td><td className="p-2">{linha.indicador}</td><td className="p-2"><input type="number" value={linha.real ?? ""} onChange={(e) => editar(indice, "real", e.target.value)} className="w-full rounded border p-1" /></td><td className="p-2"><input type="number" value={linha.plano ?? ""} onChange={(e) => editar(indice, "plano", e.target.value)} className="w-full rounded border p-1" /></td></tr>)}</tbody></table></div></section></>}</div></main>;
}

export default AnalysisDashboard;
