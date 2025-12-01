import { LightningElement, api } from "lwc";

export default class CiStyleOverride extends LightningElement {
    @api cssString;

    renderedCallback() {
        const styleContainer = this.template.querySelector("div.style-overwrite__style-container");
        const styleTag = `
                <style>
                    ${this.cssString}
                </style>
            `;

        styleContainer.innerHTML = styleTag;
    }
}