import { LightningElement, api, wire } from 'lwc';
import TimeSheetResource from '@salesforce/resourceUrl/TimeSheet';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class CalendarView extends LightningElement {

    @api userId;

    calendar;
    filledEvents = [];
    blankEvents = [];

    async connectedCallback() {
        console.log('Inside calendar');
        
        await Promise.all([
            loadScript(this, TimeSheetResource + "/lib/jquery.js"),
            loadScript(this, TimeSheetResource + "/lib/moment.js"),
            loadScript(this, TimeSheetResource + "/lib/fullcalendar.js"),
            loadStyle(this, TimeSheetResource + "/css/fullcalendar.css")
        ]).then(res => {
            console.log('Loaded'); 
        }).catch(err => {
            console.log(err);       
        })
        this.initialiseData();
    }
    initialiseData() {

        const calendar = this.template.querySelector('div.fullcalendarjs');
        try {
            $(calendar).fullCalendar({
            header: {
                left: 'prev,next today',
                center: 'title',
                right:''
            },
            defaultDate: new Date(),
            eventSources : [
                {
                    events: this.eventSourceHandler,
                }
            ],
            events: [
                {
                start: '2025-09-11T10:00:00',
                end: '2025-09-11T16:00:00',
                rendering: 'background'
                },
                {
                start: '2025-09-13T10:00:00',
                end: '2025-09-13T16:00:00',
                rendering: 'background'
                },
                {
                start: '2025-09-24',
                end: '2025-09-28',
                overlap: false,
                rendering: 'background',
                color: '#ff9f89'
                },
                {
                start: '2025-09-06',
                end: '2025-09-08',
                overlap: false,
                rendering: 'background',
                color: '#ff9f89'
                }
            ]
        });
        } catch (error) {
            console.log('error-----'+error);
            
        }
    }

    eventSourceHandler(info, successCallback, failureCallback) {

    }

}