import { LightningElement, api } from 'lwc';
import getAnnouncementFile from '@salesforce/apex/AnnouncementFileController.getAnnouncementFile';

const columns = [
    { label: 'Title', fieldName: 'Title', type: 'text' },
    { label: 'Extension', fieldName: 'FileExtension', type: 'text' },
    { label: 'Size', fieldName: 'ContentSize', type: 'int' },
    { label: 'Last Modified', fieldName: 'LastModifiedDate', type: 'date' }
];

export default class announcementFile extends LightningElement {
    @api recordId;
    columns = columns;
    files;
    isError;

    connectedCallback() {
        this.recordId = this.getRecordIdFromUrl();
        console.log("Record ID: " + this.recordId);
        
        if(this.recordId) {
            this.getfile();
        }
    }

    getRecordIdFromUrl() {
        const url = window.location.pathname;
        const parts = url.split('/');
        const recordId = parts.find(part => part.startsWith('a00'));
        return recordId;
    }
   
    getfile() {
        getAnnouncementFile({ announcementId: this.recordId })
        .then(result => {
            if (result && result != null ) {
                this.files = result.map(file => ({
                    Id: file.Id,
                    Title: file.Title,
                    FileExtension: file.FileExtension,
                    ContentSize: file.ContentSize,
                    LastModifiedDate: file.LastModifiedDate
                }));
            }
            
        })
        .catch(error => {
            this.isError=true;
        });
   }
}