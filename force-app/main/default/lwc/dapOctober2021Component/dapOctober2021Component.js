import { LightningElement, wire } from 'lwc';
import fetchProperties from '@salesforce/apex/dapOctober2021Controller.fetchProperties';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { refreshApex } from '@salesforce/apex';


export default class DapOctober2021Component extends NavigationMixin(LightningElement) {
    wiredPropertyRecords;
    tableData = [];
    tableColumns = [
        { label: 'Property Number', fieldName: 'Name' },
        {
            label: 'Property Image', type: 'customImage', typeAttributes: {
                value: { fieldName: "Property_Image__c" },
            },
        },
        { label: 'Price', fieldName: 'Price__c' },
        {
            label: '', type: 'action',
            typeAttributes: {
                rowActions: this.dynamicAction.bind(this)
            }
        }
    ];
    contactAdded = false; 
    showContacts = false;
    contactsList = [];
    // showModalToAddContact = false;
    // seletedPropertyId;

    @wire(fetchProperties)
    handleProperties(result) {
        this.wiredPropertyRecords = result;
        if (result.data) {
            this.tableData = result.data;
            //console.log('Table Data => ' + JSON.stringify(this.tableData));
        } else if (result.error) {
            console.error("Error => " + JSON.stringify(result.error));
        }
    }

    //building dynamic actions here
    dynamicAction(row, doneCallback) {
        let rowActions = [];

        if (row.isRowSelected) {
            rowActions.push(
                { label: 'Show Contact', name: 'show_contacts' },
                { label: 'Add Contact', name: 'add_contact' }
            );
        } else {
            rowActions.push({ label: 'Show Contact', name: 'show_contacts' });
        }

        doneCallback(rowActions);
    }

    renderedCallback() {
        if (this.contactAdded) {
            this.contactAdded = false; 
            refreshApex(this.wiredPropertyRecords);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        // console.log('Action name => '+ actionName);
        const row = event.detail.row;
        // console.log('Row =>'+JSON.stringify(row));
        switch (actionName) {
            case 'show_contacts':
                this.showContacts = true;

                const property = this.tableData.find(r => r.Id === row.Id);

                if (property && property.Contacts__r) {
                    this.contactsList = property.Contacts__r.map(con => {
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(con.Contact_Image__c, 'text/html');
                        console.log('doc =>', doc);
                        let imageLink = doc.querySelector('p img')?.src;
                        console.log('imageLink =>', imageLink);

                        return {
                            ...con,
                            imageLink: imageLink
                        }
                    });
                    console.log('Contact list => ' + JSON.stringify(this.contactsList));
                } else {
                    this.contactsList = [];
                }
                // console.log('Contact List => ' + JSON.stringify(this.contactsList));
                break;
            case 'add_contact':
               
                const defaultValues = encodeDefaultFieldValues({
                    Real_Estate_Property__c: row.Id,
                });

                this.contactAdded = true;
                
                this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: "Contact",
                    actionName: "new",
                },
                state: {
                    defaultFieldValues: defaultValues,
                    navigationLocation: 'RELATED_LIST'
                },
                });
                break;
            default:
        }
    }

    closeShowContactsModal() {
        this.showContacts = false;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected Rows => ' + JSON.stringify(selectedRows));
        const selectedIds = new Set(selectedRows.map(r => r.Id));

        this.tableData = this.tableData.map(row => {
            return {
                ...row,
                isRowSelected: selectedIds.has(row.Id)
            };
        });

    }

    openModelToaddProperty = false;
    handleNewRecord(){
        this.openModelToaddProperty = true;
    }

    closeAddPropertyModal(){
        this.openModelToaddProperty = false;
    }

    handleCancel(){
        this.openModelToaddProperty = false;
    }

    async handleSuccess() {
        await refreshApex(this.wiredPropertyRecords);
        this.openModelToaddProperty = false;
    }

}