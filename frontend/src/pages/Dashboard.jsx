import Siderbar from "../components/layout/Sidebar";
import Header from "../components/layout/Header";
import MainContent from "../components/layout/MainContent";

import AnalysisDashboard from "../components/dashboard/AnalysisDashboard";

function Dashboard({ periodo }) {
    return (
        <div className="flex h-screen">
            
            <Siderbar />
            <div className="flex flex-col flex-1">
                <Header />
                {periodo ? <AnalysisDashboard periodo={periodo} /> : <MainContent />}
            </div>
        </div>
    );
}

export default Dashboard;
