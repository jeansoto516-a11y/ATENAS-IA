import Siderbar from "../components/layout/Sidebar";
import Header from "../components/layout/Header";
import MainContent from "../components/layout/MainContent";

function Dashboard() {
    return (
        <div className="flex h-screen">
            
            <Siderbar />
            <div className="flex flex-col flex-1">
                <Header />
                <MainContent />
            </div>
        </div>
    );
}

export default Dashboard;