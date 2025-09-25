import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/dapMay2023Controller.fetchContacts';
import linkContactsToAccount from '@salesforce/apex/dapMay2023Controller.linkContactsToAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DapMay2023Component extends LightningElement {
    showModal = false;
    contactView = false;
    accountId;
    contacts;
    result;
    selectedCounts=0;

    @wire(getContacts)
    fetchContacts(result) {
        const { data, error } = result;
        console.log(data,error);
        if (data) {
            // this.result = result.data;
            let temp= [...data];
            
            temp = temp.map(contact => {
                return {
                    ...contact,
                    checked: false // Initialize the Checked property   
                }
            }
            );
            this.contacts = temp;
            this.result = this.contacts;
            console.log('Contacts fetched successfully:', this.contacts);
        } else if (error) {
            this.contacts = undefined;
            console.error('Error fetching contacts:', error);
        }
    }

    handleCreateAccount() {
        this.showModal = true;
    }

    handleAccountSuccess(event) {
        this.accountId = event.detail.id;
        console.log('Account Id => '+ this.accountId);
        this.contactView = true;
        this.showModal = false;
    }

    handleCancel(){
        this.showModal = false;
        this.contactView = false;

    }

    checkboxClicked(event){
        console.log('Checkbox clicked => ', event.target.checked);
    
        const ele = event.target.dataset.id;
        this.contacts.find(contact => contact.Id === ele).checked = event.target.checked;
        this.result.find(contact => contact.Id === ele).checked = event.target.checked;
        console.log('Checked => ', this.contacts);
        this.selectedCounts = this.contacts.filter(contact => contact.checked).length;
        console.log('Checkbox state updated => ', JSON.stringify(this.contacts.find(contact => { return contact.Id === ele })));
    }

    handleFinalSave(){
        const selectedContacts = this.contacts.filter(contact => contact.checked);
        console.log('Selected Contacts => ', JSON.stringify(selectedContacts));
        if (selectedContacts.length > 0){
        linkContactsToAccount({contacts: selectedContacts, accountId: this.accountId}).then(()=>{
            this.contactView = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Account {0} created and contact linked`,
                messageData:[
                    {
                        url:`/${this.accountId}`,
                        label: this.accountId
                    }
                ],  
                variant: 'success'
            }));            
        }).catch(error => {
                    console.error(`Error updating contact ${contact.Id}:`, error);
        });
        }else{
            console.log('No contacts selected.');
        }
    }

    handleSearchChange(event) {
        const searchTerm = event.target.value.toLowerCase();
        console.log('Search term =>', searchTerm);
        if(searchTerm=='') {
            this.contacts = this.result;
            return;
        }
        if (this.result) {
            this.contacts = this.result.filter(contact => {

                return contact.FirstName?.toLowerCase().includes(searchTerm) ||
                    contact.LastName?.toLowerCase().includes(searchTerm) ||
                    contact.Email?.toLowerCase().includes(searchTerm) ||
                    contact.Phone?.includes(searchTerm);
            });
        }
    }

}