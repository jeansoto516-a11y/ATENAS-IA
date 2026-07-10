function Card({ children }) {
    return (
        <div className="bg-white rounded-2x1 shadow-x1 p-8">
            {children}
        </div>
    );
}

export default Card;