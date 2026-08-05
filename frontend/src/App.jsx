import { Routes, Route } from "react-router-dom";

import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/dashboard/diario" element={<Dashboard periodo="diario" />} />
      <Route path="/dashboard/horario" element={<Dashboard periodo="horario" />} />
    </Routes>
  );
}

export default App;
