function Button ({ children, onClick, disabled = false}) {
    return (
        <button
            onClick={onClick}
            disabled={disabled}
            className="
            w-full
            bg-blue-600
            hover:bg-blue-700
            text-white
            font-semibold
            py-3
            px-4
            rounded-x1
            transition
            duration-300
            disabled:bg-gray-400
            "
        >
            {children}
        </button>
    );
}

export default Button;