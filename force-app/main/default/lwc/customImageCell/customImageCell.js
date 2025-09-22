import { LightningElement, api } from 'lwc';

export default class DisplayCustomImage extends LightningElement {
    @api value;
    // @api conImg;

    renderedCallback() {
        const container = this.template.querySelector('.img-container');
        if (container && this.value) {
            container.innerHTML = this.value; 
        }

        // const container1 = this.template.querySelector('.contactImg-container');
        // if (container1 && this.conImg) {
        //     container1.innerHTML = this.conImg; 
        // }
    }


}