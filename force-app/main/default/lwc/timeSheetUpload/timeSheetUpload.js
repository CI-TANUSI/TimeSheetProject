import { LightningElement, track, api, wire } from 'lwc';
import updateStatus from '@salesforce/apex/TimeSheetUpload.updateStatus';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeSheetUpload extends LightningElement {
    @track tableData = [];
    @track columns = [];
    @track isDataLoaded = false;
    @track selectedStatus = '';
    @api recordId;

    statusOptions = [
        { label: 'Temporary Approved', value: 'Temporary approved' },
        { label: 'Unapproved', value: 'Unapproved' }
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId || currentPageReference.attributes.recordId;
        }
    }

    handleUploadClick() {
        this.template.querySelector('input[type="file"]').click();
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            const csvText = e.target.result;
            this.parseCSV(csvText);
        };
        reader.readAsText(file);
    }

    parseCSV(csvText) {
        const lines = csvText.split(/\r\n|\n/).filter(line => line.trim() !== '');

        const parseLine = (line) => {
            const values = [];
            let current = '';
            let inQuotes = false;

            for (let i = 0; i < line.length; i++) {
                const char = line[i];
                const nextChar = line[i + 1];

                if (char === '"' && inQuotes && nextChar === '"') {
                    current += '"';
                    i++;
                } else if (char === '"') {
                    inQuotes = !inQuotes;
                } else if (char === ',' && !inQuotes) {
                    values.push(current);
                    current = '';
                } else {
                    current += char;
                }
            }

            values.push(current);
            return values;
        };

        const headers = parseLine(lines[0]);

        this.columns = headers.map((header, index) => ({
            label: header.trim(),
            fieldName: 'col' + index,
            type: 'text'
        }));

        this.columns.push({
            label: 'Status',
            fieldName: 'status',
            type: 'text'
        });

        this.tableData = lines.slice(1).map((line, idx) => {
            const values = parseLine(line);
            let row = { id: idx, status: '' };

            values.forEach((val, i) => {
                let cleanVal = val.trim()
                    .replaceAll('\r', ' ')
                    .replaceAll('\n', ' ')
                    .replaceAll('"', '""');
                row['col' + i] = cleanVal;
            });

            return row;
        });

        this.isDataLoaded = this.tableData.length > 0;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    async handleUpdateClick() {
        if (!this.selectedStatus) {
            this.showToast('Error', 'Please select a status.', 'error');
            return;
        }

        const dataList = this.tableData.map(row => ({
            name: row.col0?.replace(/"/g, '').trim(), // Timesheet name
            timeTaken: Number((row.col4 || '0').replace(/"/g, '').trim()),
            approvedTime: Number((row.col5 || '0').replace(/"/g, '').trim())
        }));

        try {
            await updateStatus({ dataList, statusValue: this.selectedStatus, recordId: this.recordId });

            this.tableData = this.tableData.map(row => ({
                ...row,
                status: this.selectedStatus
            }));

            this.showToast('Success', 'Status updated successfully', 'success');
        } catch (error) {
            const message = error?.body?.message || error?.message || 'Unknown error occurred';
            this.showToast('Error', message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}