import { LightningElement, track } from 'lwc';
import getTimeSheet from '@salesforce/apex/timeSheetPortalController.getTimeSheetDatas'; 
export default class ProjectTimeSheet extends LightningElement {
    @track weekDays = [];
    @track projectList = [];
    @track dayTotals = [];
    @track selectedProjectCodes = '';
    @track todayDate;
    @track timeTakenInMin;
    @track recordId;
    @track type;
    @track status;
    @track functionDes;
    @track technicalDes;
    @track draft;

    showForm = false;
    selectedDay;
    selectedProjectId;

    projectOptions = [
        { label: 'P001 - Website Revamp', value: 'P001' },
        { label: 'P002 - Mobile App', value: 'P002' },
        { label: 'P003 - Salesforce Integration', value: 'P003' },
        { label: 'P004 - CRM Setup', value: 'P004' },
    ];

    connectedCallback() {
        console.log('connectedCallback');
        this.generateWeek();
        this.projectList = [];
        this.updateDayTotals();
        getTimeSheet()
            .then(result => {
                this.initializeProjects(result);
            })
            .catch(error => {
                console.error('error', error);
            });

    }
initializeProjects(result) {
    const projects = [];
    let idCounter = 1;

    result.forEach(record => {
        // Skip if no time taken
        if (!record.Time_Taken_min__c || Number(record.Time_Taken_min__c) <= 0) {
            return;
        }

        const projectCode = record.Project_code__c || '';

        // Check if project already exists
        let proj = projects.find(p => p.projectCode === projectCode);

        if (!proj) {
            proj = this.createEmptyProject(idCounter++);
            proj.projectCode = projectCode;
            projects.push(proj);
        }

        const recordDate = new Date(record.Date__c);
        this.weekDays.forEach(d => {
            const dayDate = new Date(d.fullDate);
            if (this.isSameDate(recordDate, dayDate)) {
                const hours = Number(record.Time_Taken_min__c || 0);
                if (hours > 0) {
                    proj.hours[d.label] = hours;

                    const cell = proj.hoursArray.find(x => x.label === d.label);
                    if (cell) {
                        cell.value = hours;
                        cell.isDisabled = record.Draft__c ? false : true;
                        cell.timeTaken = record.Time_Taken_min__c || 0;
                        cell.recordId = record.Id;
                        cell.Type = record.Type__c || ''; // Fixed casing
                        //cell.Status = record.WorkStatus__c || '';
                        cell.technicalDescription = record.Technical_Description__c || '';
                        cell.draft = record.Draft__c || '';
                    }

                    proj.functionDescription = record.Function_Description__c || '';
                    proj.submittedDays[d.label] = true;
                }
            }
        });

        // 🔄 Always recalculate totalHours (whether updated or new)
        proj.totalHours = Object.values(proj.hours).reduce((a, b) => a + b, 0);
    });

    // Set to projects if any exist, else show 1 blank row
    this.projectList = projects.length ? projects :[this.createEmptyProject(1)];

    this.updateDayTotals();
}




isSameDate(d1, d2) {
    return (
        d1.getFullYear() === d2.getFullYear() &&
        d1.getMonth() === d2.getMonth() &&
        d1.getDate() === d2.getDate()
    );
}
    generateWeek() {
        const today = new Date();
        const weekStart = new Date(today);
        weekStart.setDate(today.getDate() - today.getDay() + 1);
        const labels = ['M', 'T', 'W', 'Th', 'F'];

        this.weekDays = labels.map((label, index) => {
            const date = new Date(weekStart);
            date.setDate(weekStart.getDate() + index);
            return { label, date: date.getDate(), month: date.getMonth() + 1 ,fullDate:date};
        });
    }

    createEmptyProject(id) {
        const hours = {};
        const hoursArray = [];
        const submittedDays = {};
        this.weekDays.forEach(d => {
            console.log('d',JSON.stringify(d));
            hours[d.label] = 0;
            hoursArray.push({ label: d.label, value: 0, isDisabled: false, date: d.fullDate});
            submittedDays[d.label] = false;
        });

        return { id, projectCode: '', hours, hoursArray, totalHours: 0, submittedDays };
    }

    handleProjectChange(event) {
        this.selectedProjectCodes = event.target.value;
        const id = event.target.dataset.id;
        const value = event.target.value;
        const index = this.projectList.findIndex(p => p.id == id);
        if (index > -1) {
            const updated = structuredClone(this.projectList[index]);
            updated.projectCode = value;
            const copy = structuredClone(this.projectList);
            copy[index] = updated;
            this.projectList = copy;
        }
    }

    handleAdd() {
        const newProj = this.createEmptyProject(Date.now());
        this.projectList = [...structuredClone(this.projectList), newProj];
        this.updateDayTotals();
    }

    openTimesheetForm(event) {
        console.log('projectList>>>>',JSON.stringify(this.projectList));
        const projId = event.target.dataset.projid;
        const day = event.target.dataset.day;
        console.log('openTimesheetForm', projId, day);
        const proj = this.projectList.find(p => p.id == projId);
        if (proj && proj.Draft__c == false) return;
        this.selectedProjectCodes = event.target.dataset.projectcode;
        this.selectedProjectId = projId;
        this.selectedDay = day;
        this.showForm = true;
        this.todayDate = event.target.dataset.date;
        console.log('todayDate:::'+this.todayDate);
       console.log('event.target.dataset:::'+event.target.dataset)
       console.log('event.target.dataset.projectcode:::')
       console.log('event:::>>'+JSON.stringify(event.target.dataset))
       this.timeTakenInMin = event.target.dataset.timetaken;
       console.log('this.timeTakenInMin::'+this.timeTakenInMin);
       this.recordId = event.target.dataset.recordid;
       this.type = event.target.dataset.type;
       this.status = event.target.dataset.status;
       this.functionDes = event.target.dataset.functiondes ;
       this.technicalDes = event.target.dataset.technicaldes;
       console.log('event.target.dataset.draft;:::'+event.target.dataset.draft);
       this.draft = event.target.dataset.draft;
    }

    closeForm() {
        this.showForm = false;
    }

    handleHoursChange(event) {
        const projId = event.target.dataset.projid;
        const day = event.target.dataset.day;
        const value = Number(event.target.value) || 0; 

        const idx = this.projectList.findIndex(p => p.id == projId);
        if (idx > -1) {
            const copy = structuredClone(this.projectList);
            const proj = copy[idx];

            if (!proj.submittedDays[day]) {
                proj.hours[day] = value;
                // proj.hoursArray = this.weekDays.map(d => ({
                //     label: d.label,
                //     value: proj.hours[d.label] || 0,
                //     isDisabled: proj.submittedDays[d.label]
                // }));
                proj.hoursArray = this.weekDays.map(d => ({
                    label: d.label,
                    date: d.fullDate,
                    value: proj.submittedDays[d.label] ? Number(proj.hours[d.label]) : 0,
                    isDisabled: proj.submittedDays[d.label]
                }));
                proj.totalHours = Object.values(proj.hours).reduce((a, b) => a + Number(b || 0), 0);
                copy[idx] = proj;
                this.projectList = copy;
                this.updateDayTotals();
            }
        }
    }

    handleFormSubmit(event) {
        const { hours, status } = event.detail;
        if (status === 'Submitted') {
            const idx = this.projectList.findIndex(p => p.id == this.selectedProjectId);
            if (idx > -1) {
                const copy = structuredClone(this.projectList);
                const proj = copy[idx];

                if (!proj.submittedDays[this.selectedDay]) {
                    proj.hours[this.selectedDay] = Number(hours);
                    proj.submittedDays[this.selectedDay] = true;
                    proj.hoursArray = this.weekDays.map(d => ({
                        label: d.label,
                        date: d.fullDate,
                        value: proj.submittedDays[d.label] ? proj.hours[d.label] : 0,
                        isDisabled: proj.submittedDays[d.label]
                    }));
                    proj.totalHours = Object.entries(proj.hours)
                        .filter(([day]) => proj.submittedDays[day])
                        .reduce((sum, [_, val]) => sum + Number(val || 0), 0);
                }

                copy[idx] = proj;
                this.projectList = copy;
                this.updateDayTotals();
            }
        }
        this.showForm = false;
    }

    updateDayTotals() {
        this.dayTotals = this.weekDays.map(d => {
            let total = 0;
            this.projectList.forEach(proj => {
                total += Number(proj.hours[d.label]) || 0;
            });
            return { label: d.label, value: total };
        });
    }

    get grandTotal() {
        return this.projectList.reduce(
            (sum, p) => sum + Object.values(p.hours).reduce((s, v) => s + Number(v || 0), 0),
            0
        );
    }
}