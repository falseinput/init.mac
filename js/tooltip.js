export class Tooltip {
    constructor() {
        this.tooltip = document.createElement("div");
        this.tooltip.className = "tooltip";
        document.body.appendChild(this.tooltip);
        this.hideTimeout = null;
    }

    show(event, message) {
        if (this.hideTimeout) {
            clearTimeout(this.hideTimeout);
            this.hideTimeout = null;
        }
        const posX = event.pageX;
        const posY = event.pageY;

        this.tooltip.innerText = message;
        this.tooltip.style.opacity = "1";
        this.tooltip.style.position = "absolute";
        this.tooltip.style.top = `${posY - this.tooltip.offsetHeight}px`;


        const width = this.tooltip.offsetWidth;
        this.tooltip.style.left = `${posX + width > window.innerWidth ? posX - width : posX}px`;

        this.hideTimeout = setTimeout(() => {
            this.#hide();
        }, 1000);
    }

    #hide() {
        this.tooltip.style.opacity = "0";
        this.hideTimeout = null;
    }
}