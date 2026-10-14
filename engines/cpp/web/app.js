import createBrainfuckModule from "./brainfuck.js";
const sourceElement = document.querySelector("#source");
const inputElement = document.querySelector("#stdin");
const modeElement = document.querySelector("#mode");
const outputElement = document.querySelector("#output");
const statusElement = document.querySelector("#status");
const runButton = document.querySelector("#run");

const helloWorld = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";

let moduleInstance = null;

async function initialize() {
    try {
        moduleInstance = await createBrainfuckModule();
        runButton.disabled = false;
        runButton.textContent = "Run program";
        outputElement.textContent = "";
        statusElement.textContent = "Interpreter ready.";
    } catch (error) {
        outputElement.textContent = `Failed to load WebAssembly:\n${error.message}`;
        statusElement.textContent = "Initialization failed.";
        console.error(error);
    }
}

runButton.addEventListener("click", () => {
    // console.log("Run button clicked");

    if (!moduleInstance) {
        // console.error("WebAssembly module is not initialized");
        statusElement.textContent = "WebAssembly is not ready.";
        return;
    }

    runButton.disabled = true;
    runButton.textContent = "Running...";
    statusElement.textContent = "Executing program...";

    try {
        // console.log("Export:", typeof moduleInstance._run_brainfuck);

        const result = moduleInstance.ccall(
            "run_brainfuck",
            "string",
            ["string", "string", "string"],
            [
                sourceElement.value,
                modeElement.value,
                inputElement.value
            ]
        );

        // console.log("Execution result:", result);
        outputElement.textContent = result ?? "";
        statusElement.textContent = "Execution finished.";
    } catch (error) {
        console.error("WASM execution failed:", error);
        outputElement.textContent =
            `Execution failed:\n${error.message}`;
        statusElement.textContent = "Execution failed.";
    } finally {
        runButton.disabled = false;
        runButton.textContent = "Run program";
    }
});
document.querySelector("#example").addEventListener("click", () => {
    sourceElement.value = helloWorld;
    outputElement.textContent = "";
    statusElement.textContent = "Hello World example loaded.";
});
document.querySelector("#clear").addEventListener("click", () => {
    outputElement.textContent = "";
    statusElement.textContent = "Output cleared.";
});
initialize();
