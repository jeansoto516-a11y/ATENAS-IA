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

module.exports = {
    criarScriptTemporario
};