const elements = document.querySelectorAll('[data-clipboard-target]');

if (elements) {
Array.from(elements).forEach(e => e.addEventListener("click", handleCopy));

}

async function handleCopy(event) {
    addToClipboard(event.target.innerText.trim());
    alert("Copied to clipboard");
}

async function addToClipboard(text) {
    const type = "text/plain";
    const clipboardItemData = {
        [type]: text,
    };
    const clipboardItem = new ClipboardItem(clipboardItemData);
    await navigator.clipboard.write([clipboardItem]);
}