const fs = require('fs');
const path = require ("path")

function criarscriptTemporario({ entrada, aba, saida}) {

    const criptOriginal = path.join(
    __dirname,
    "../../scripts-r/Tratamento_indicadores.R"
    );

    const scriptTemporario = path.join(
    __dirname,
    "../temp/tratamento_temp.R"
    );

    let conteudo = fs.readFileSync(criptOriginal, "utf-8");

    conteudo = conteudo.replace(
        '"nome_arquivo_entrada <- ""',
        `nome_arquivo_entrada <- "${entrada}"`
    );

    conteudo = conteudo.replace(
        '"nome_aba_entrada <- ""',
        `nome_aba_entrada <- "${aba}"`
    );

    conteudo = conteudo.replace(
        '"nome_arquivo_saida <- ""',
        `nome_arquivo_saida <- "${saida}"`
    );

    fs.writeFileSync(scriptTemporario, conteudo);

    return scriptTemporario;
}

module.exports = {
    criarscriptTemporario
};