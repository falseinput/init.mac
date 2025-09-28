const clipboardTargetElements = document.querySelectorAll('[data-clipboard-target]');
const lazyloadTooltip = tooltipFactory();
if (clipboardTargetElements) {
    Array.from(clipboardTargetElements).forEach(e => e.addEventListener("click", handleCopy));
}

async function handleCopy(event) {
    addToClipboard(event.target.innerText.trim());
    (await lazyloadTooltip()).show(event, "Copied to clipboard");
}

function tooltipFactory() {
    let tooltip;
    return async () => {
        if (!tooltip) {
            const tooltipModule = await import("./tooltip.js");
            tooltip = new tooltipModule.Tooltip();
        }
        return tooltip;
    }
}

async function addToClipboard(text) {
    const type = "text/plain";
    const clipboardItemData = {
        [type]: text,
    };
    const clipboardItem = new ClipboardItem(clipboardItemData);
    await navigator.clipboard.write([clipboardItem]);
}