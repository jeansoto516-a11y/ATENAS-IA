const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// Importa as rotas
const routes = require("./routes");
const uploadRoutes = require("./routes/uploadRoutes");

app.use("/", routes);
app.use("/upload", uploadRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`🚀 Atenas IA rodando na porta ${PORT}`);
});