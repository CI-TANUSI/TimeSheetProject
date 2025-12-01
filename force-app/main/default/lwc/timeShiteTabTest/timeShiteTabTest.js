import { LightningElement, track, wire, api } from 'lwc';
import saveTimesheet from '@salesforce/apex/timeSheetController.saveTimesheet';
import getProjectCodes from '@salesforce/apex/TimeSheetEntry.getProjectCodes';

export default class TimesheetLWC extends LightningElement {
    @track weekStart = new Date();
    @track days = [];
    @track entries = [];
    @track projectCodeOptions = [];
    @track statusValue = '';
    @track technicalDesc = '';
    @track message = '';
    @track error = '';
    @track editMode = false;

    // 🔹 Modal tracking
    @track isModalOpen = false;
    @track currentTechDesc = '';
    @track selectedDayIndex = null;
    @track selectedDayName = '';
    @track selectedDate = '';

    entry = { technicalDesc: '' };

    connectedCallback() {
        this.initThisWeek();
        this.addRow();
    }

    handleAddWeek() {
        this.addRow();
    }

    addRow() {
        const newEntry = {
            id: Date.now(),
            ProjectCode__c: '',
            TechnicalDescription__c: '',
            Status__c: '',
            timeEntries: Array(7).fill(0),
            total: 0
        };
        this.entries = [...this.entries, newEntry];
    }

    initThisWeek() {
        const today = new Date();
        const day = today.getDay();
        const diffToMonday = (day === 0) ? -6 : 1 - day;
        const monday = new Date(today);
        monday.setDate(today.getDate() + diffToMonday);
        monday.setHours(0, 0, 0, 0);
        this.setWeekStart(monday);
    }

    setWeekStart(dateObj) {
        this.weekStart = new Date(dateObj);
        this.buildDays();
        this.clearMessages();
    }

    buildDays() {
        const arr = [];
        for (let i = 0; i < 7; i++) {
            const d = new Date(this.weekStart);
            d.setDate(this.weekStart.getDate() + i);
            arr.push({
                index: i,
                dateISO: d.toISOString().split('T')[0],
                dateDisplay: d.toLocaleDateString(undefined, { day: 'numeric', month: 'short' }),
                dayName: d.toLocaleDateString(undefined, { weekday: 'short' }),
                timeTaken: '',
                isEditing: false,
                technicalDesc: ''
            });
        }
        this.days = arr;
    }

    handleDeleteRow(event) {
        const index = event.target.dataset.index;
        this.entries.splice(index, 1);
        this.entries = [...this.entries];
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'Project Code') {
            this.projectCode = event.target.value;
        }
    }

    handleTimeChange(e) {
        const idx = parseInt(e.target.dataset.index, 10);
        let val = e.target.value;
        const parsed = parseInt(val, 10);
        this.days = this.days.map(d => d.index === idx ? { ...d, timeTaken: parsed } : d);
    }

    get totalTime() {
        let totalMin = 0;
        this.days.forEach(d => {
            const t = parseInt(d.timeTaken);
            if (!isNaN(t)) totalMin += t;
        });
        const totalHours = totalMin / 60;
        return totalHours.toFixed(2);
    }

    clearMessages() {
        this.message = '';
        this.error = '';
    }

    // 🔹 Pencil icon click => open modal
    handleEditClick(event) {
        const dayIndex = parseInt(event.target.dataset.index, 10);
        const day = this.days.find(d => d.index === dayIndex);

        this.isModalOpen = true;
        this.selectedDayIndex = dayIndex;
        this.selectedDayName = day.dayName;
        this.selectedDate = day.dateDisplay;
        this.currentTechDesc = day.technicalDesc || '';
    }

    // 🔹 Textarea typing in modal
    handleTechChange(event) {
        this.currentTechDesc = event.target.value;
    }

    // 🔹 Save button in modal
    saveTechDesc() {
        this.days = this.days.map(d =>
            d.index === this.selectedDayIndex
                ? { ...d, technicalDesc: this.currentTechDesc }
                : d
        );
        this.closeModal();
    }

    // 🔹 Close modal
    closeModal() {
        this.isModalOpen = false;
        this.currentTechDesc = '';
        this.selectedDayIndex = null;
    }

    // 🔹 Save all timesheet data (backend call)
    async saveTimesheet() {
        this.clearMessages();
        try {
            for (const day of this.days) {
                if (day.timeTaken && day.timeTaken > 0) {
                    const payload = {
                        ProjectCode__c: this.projectCode,
                        TimesheetDate__c: day.dateISO,
                        TimeTakenInMinutes__c: day.timeTaken,
                        Status__c: this.statusValue,
                        TechnicalDescription__c: day.technicalDesc,
                    };
                    await saveTimesheet({ timeSheetData: payload });
                }
            }
            this.message = 'Timesheet saved successfully!';
        } catch (error) {
            this.error = error.body?.message || error.message;
        }
    }
}