const fs = require('fs');
const path = require ("path")

function criarScriptTemporario({ entrada, aba, saida}) {

    const scriptOriginal = path.join(
    __dirname,
    "../../scripts-r/AUX_ANALISE.R"
    );

    const scriptTemporario = path.join(
    __dirname,
    "../temp/tratamento_temp.R"
    );

    let conteudo = fs.readFileSync(scriptOriginal, "utf-8");

    conteudo = conteudo.replace(
        /nome_arquivo_entrada\s*<-\s*".*?"/,
        `nome_arquivo_entrada <- "${entrada}"`
    );

    conteudo = conteudo.replace(
        /aba\s*<-\s*".*?"/,
        `aba <- "${aba}"`
    );

    conteudo = conteudo.replace(
        /nome_arquivo_saida\s*<-\s*".*?"/,
        `nome_arquivo_saida <- "${saida}"`
    );

    fs.writeFileSync(scriptTemporario, conteudo);

    return scriptTemporario;
}
const { exec} = require("child_process");

function executarScript(script) {

    return new Promise((resolve, reject) => {

        const caminhoR =
            '"C:\\Program Files\\R\\R-4.6.0\\bin\\x64\\Rscript.exe"';

        exec(`${caminhoR} "${script}"`, (error, stdout, stderr) => {

            console.log("========== STDOUT ==========");
            console.log(stdout);

            console.log("========== STDERR ==========");
            console.log(stderr);

            if (error) {
                console.log("========== ERROR ==========");
                console.log(error);
                return reject(error);
            }

            console.log("R finalizou.");

            resolve();

        });

    });

}

module.exports = {
    criarScriptTemporario,
    executarScript
};