import { LightningElement } from 'lwc';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import ID_FIELD from "@salesforce/schema/Contact.Id";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContacts from '@salesforce/apex/dapAugust2022Controller.getContactList';
import sendEmails from '@salesforce/apex/dapAugust2022Controller.sendOTPEmail';

export default class DapAugust2022Component extends LightningElement {
    showTable = false;
    showModal = false;
    userName;
    userEmail;
    userPhone;
    searchEmail;
    searchPhone;
    contacts = [];
    showPopUp = false;
    otp;
    selectedIntern;
    showInternDetail = false;
    internDetail = {};

    get options() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' },
            { label: 'Other', value: 'Other' },
        ];
    }
    readMode = true;
    isReadOnly = true;


    handleNew(){
        this.showModal = true;
    }

    handleCloseModal(){
        this.showModal = false;
    }

    handleNameChange(event){
        this.userName = event.target.value;
    }

    handleEmailChange(event){
        this.userEmail = event.target.value;
    }

    handlePhoneChange(event){
        this.userPhone  =  event.target.value;
    }

    handleInternDetails(){
        console.log('UserName =>'+this.userName);
        console.log('UserEmail =>' +this.userEmail);
        console.log('UserPhone =>' +this.userPhone);

        const fields = {};
        fields[LASTNAME_FIELD.fieldApiName] = this.userName;
        fields[EMAIL_FIELD.fieldApiName] = this.userEmail;
        fields[PHONE_FIELD.fieldApiName] = this.userPhone;

        const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact created successfully!',
                        variant: 'success',
                    }),
                );
                // Optionally, navigate to the new record or clear the form
                this.userName = '';
                this.userEmail = '';
                this.userPhone = '';
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });

        this.showModal = false;
    }

    handleEmailSearch(event){
        this.searchEmail = event.target.value;
    }

    handlePhoneSearch(event){
        this.searchPhone = event.target.value;
    }

    handleSearch(){
        console.log('Email =>'+this.searchEmail);
        console.log('Phone =>'+this.searchPhone);

        getContacts({mail: this.searchEmail, ph: this.searchPhone})
            .then(result => {
                console.log('Result =>'+JSON.stringify(result));
                this.showTable = true;
                this.contacts = result;
            })
            .catch(error => {
                console.log('Error =>'+error);
            });
    
    }

    handleNameClick(event){
        // console.log('Event =>'+ JSON.stringify(event));
        // console.log('Intern Record Id =>' + JSON.stringify(event.target));
        console.log('Con Id =>'+ event.target.dataset.id);
        this.selectedIntern = event.target.dataset.id
        let tempObj = {};
        this.contacts.find(itr => {
            if(itr.Id == this.selectedIntern){
                tempObj = itr;
            }
        })
        console.log('TempObj =>'+ JSON.stringify(tempObj));
        this.otp = String(Math.floor(100000 + Math.random() * 900000));
        console.log('OTP => '+ this.otp);
        
        let recepiantEmail = tempObj.Email ? tempObj.Email : '';

        sendEmails({emailAddress: recepiantEmail, otp: this.otp})
            .then(result => {
                console.log('Result =>'+result);
            })
            .catch(error => {
                console.log('Error =>'+error);
            })

        this.showPopUp = true;
    }

    handleClosePopUp(){
        this.showPopUp = false;
    }

    handleOTP(event){
        this.userOtpInput = event.target.value;
    }

    handleOTPValidation() {
        this.showPopUp = false;

        if (this.otp === this.userOtpInput) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'OTP verified successfully!',
                    variant: 'success',
                })
            );

            this.showInternDetail = true;

            this.contacts.find(itr => {
                if(itr.Id == this.selectedIntern){
                    this.internDetail = itr;
                }
            })

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Wrong OTP! Please try again.',
                    variant: 'error',
                })
            );
        }

    }

    handleEdit() {
        this.readMode = false;
        this.isReadOnly = false;
    }

    handleCancel() {
        if(this.readMode){
            this.readMode = false;
        } else{
            this.readMode = true;
        }

        if(this.isReadOnly){
            this.isReadOnly = false;
        } else{
            this.isReadOnly = true;
        }
    }

    handleFirstNameChange(e){
        this.internDetail.FirstName = e.target.value;
    }

    handleLastNameChange(e){
        this.internDetail.LastName = e.target.value;
    }

    handlePhoneNoChange(e){
        this.internDetail.Phone = e.target.value;
    }

    handleMailChange(e){
        this.internDetail.Email = e.target.value;
    }

    handleGenderChange(e){
        this.internDetail.Gender__c = e.target.value;
    }

    handleStreetChange(e){
        this.internDetail.MailingStreet = e.target.value;
    }

    handleCityChange(e){
        this.internDetail.MailingCity = e.target.value;
    }

    handleStateChange(e){
        this.internDetail.MailingState = e.target.value;
    }

    handleCountryChange(e){
        this.internDetail.MailingCountry = e.target.value;
    }

    handlePostalCodeChange(e){
        this.internDetail.MailingPostalCode = e.target.value;
    }  

    handleAddressChange(e) {
        this.internDetail.Is_Current_Permanent_Adress_Same__c = e.target.checked;
    }



    handlesave() {
        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.internDetail.Id;
        fields[FIRSTNAME_FIELD.fieldApiName] = this.internDetail.FirstName;
        fields[LASTNAME_FIELD.fieldApiName] = this.internDetail.LastName;
        fields[EMAIL_FIELD.fieldApiName] = this.internDetail.Email;
        fields[PHONE_FIELD.fieldApiName] = this.internDetail.Phone;
        fields['Gender__c'] = this.internDetail.Gender__c;
        fields['MailingStreet'] = this.internDetail.MailingStreet;
        fields['MailingCity'] = this.internDetail.MailingCity;
        fields['MailingState'] = this.internDetail.MailingState;
        fields['MailingCountry'] = this.internDetail.MailingCountry;
        fields['MailingPostalCode'] = this.internDetail.MailingPostalCode;
        fields['Is_Current_Permanent_Adress_Same__c'] = this.internDetail.Is_Current_Permanent_Adress_Same__c;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact updated successfully!',
                        variant: 'success',
                    })
                );

                this.readMode = true;
                this.isReadOnly = true;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
}