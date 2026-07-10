import { useRef } from 'react';

function UploadArea({ file, setFile }) {
    const inputRef = useRef(null);

    function handleFile(event) {
        const selectedFile = event.target.files[0];

        if (selectedFile) {
            setFile(selectedFile);
        }
    }

    return (
        <>
        <input
            ref={inputRef}
            type="file"
            accept=".xlsx,.xls"
            onChange={handleFile}
            className="hidden"
        />
        
        <div
        onClick={() => inputRef.current.click()}
        className="
        border-2
        border-dashed
        border-slate-300
        rounded-xl
        p-8
        text-center
        cursor-pointer
        hover:border-slate-500
        transition
        "
        >
            {file ? (
                <p className="font-medium text-slate-700">
                    {file.name}
                </p>
                ) : (
                <p className="text-slate-500">
                    Clique aqui para selecionar um arquivo
                    </p>
                )}
        </div>
        </>
    );
}

export default UploadArea;