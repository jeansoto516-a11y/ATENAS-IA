function Input({
    label,
    value,
    onChange,
    placeholder
}) {
    return (
        <div className="flex flex-col gap-2">

            <label className="font-medium text-slate-700">
                {label}
            </label>

            <input
                type="text"
                value={value}
                onChange={onChange}
                placeholder={placeholder}
                className="
                border
                border-slate-300
                rounded-lg
                px-4
                py-2
                outline-none
                focus:border-slate-500
                "
            />
        </div>
    );
}

export default Input;