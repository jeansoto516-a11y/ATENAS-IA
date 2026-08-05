const fs = require("fs");
const path = require("path");
const { execFile } = require("child_process");

function escaparStringR(valor) {
    return String(valor || "").replace(/\\/g, "/").replace(/"/g, '\\"');
}

function criarScriptTemporario({ entrada, aba, saida }) {
    const scriptOriginal = path.join(__dirname, "../../scripts-r/AUX_ANALISE.R");
    const scriptTemporario = path.join(__dirname, "../temp/tratamento_temp.R");
    let conteudo = fs.readFileSync(scriptOriginal, "utf-8");

    conteudo = conteudo.replace(/pasta_arquivo\s*<-\s*".*?"/, `pasta_arquivo <- "${escaparStringR(path.dirname(entrada))}"`);
    conteudo = conteudo.replace(/nome_arquivo_entrada\s*<-\s*".*?"/, `nome_arquivo_entrada <- "${escaparStringR(path.basename(entrada))}"`);
    conteudo = conteudo.replace(/aba\s*<-\s*".*?"/, `aba <- "${escaparStringR(aba)}"`);
    conteudo = conteudo.replace(/nome_arquivo_saida\s*<-\s*".*?"/, `nome_arquivo_saida <- "${escaparStringR(saida)}"`);
    fs.writeFileSync(scriptTemporario, conteudo);
    return scriptTemporario;
}

function executarScript(script) {
    return new Promise((resolve, reject) => {
        const caminhoR = process.env.RSCRIPT_PATH || "C:\\Program Files\\R\\R-4.6.0\\bin\\x64\\Rscript.exe";
        execFile(caminhoR, [script], { windowsHide: true }, (error, stdout, stderr) => {
            console.log(stdout);
            console.error(stderr);
            if (error) return reject(error);
            resolve({ stdout, stderr });
        });
    });
}

module.exports = { criarScriptTemporario, executarScript };
