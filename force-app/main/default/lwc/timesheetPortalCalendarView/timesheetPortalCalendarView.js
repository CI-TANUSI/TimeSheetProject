import { LightningElement, api, wire } from 'lwc';
import TimeSheetResource from '@salesforce/resourceUrl/TimeSheet';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getFilledHours from '@salesforce/apex/TimeSheetPortalController.getFilledHoursByDate';

export default class CalendarView extends LightningElement {
    @api userId;  
    calendarRendered = false; 
    async connectedCallback() {
        console.log('Inside calendar: connectedCallback');
        try {
            await Promise.all([
                loadScript(this, TimeSheetResource + "/lib/jquery.js"),
                loadScript(this, TimeSheetResource + "/lib/moment.js"),
                loadScript(this, TimeSheetResource + "/lib/fullcalendar.js"),
                loadStyle(this, TimeSheetResource + "/css/fullcalendar.css")
            ]);
            console.log('Scripts and Styles Loaded successfully');
            this.calendarRendered = true; 
            this.initialiseData();
        } catch (error) {
            console.error('Error loading FullCalendar resources:', error);
        }
    }
   
    renderedCallback() {
        if (this.calendarRendered && !this.isFullCalendarInitialized) {
            this.initialiseData();
            this.isFullCalendarInitialized = true;
        }
    }
    initialiseData() {
        const calendarEl = this.template.querySelector('div.fullcalendarjs');
        if (typeof $ !== 'undefined' && typeof $.fn.fullCalendar !== 'undefined' && calendarEl) {
            try {
                $(calendarEl).fullCalendar({
                    header: {
                        left: 'prev,next today',
                        center: 'title',
                        right: ''
                    },
                    defaultDate: new Date(),
                    editable: false,
                    selectable: true,
                    eventSources : [
                        {
                            events: this.eventSourceHandler.bind(this), 
                        }
                    ],
                });
            } catch (error) {
                console.error('FullCalendar Initialization Error:', error);
            }
        }
    }
   eventSourceHandler = async (start, end, timezone, callback) => {
    try {
        const result = await getFilledHours({ userId: this.userId });

        if (!result.isSuccess) {
            callback([]);
            return;
        }

        const records = result.data || [];
        const events = [];
        records.forEach(d => {
            events.push({
                start: d.dateStr,
                end: d.dateStr,                 
                rendering: 'background',
                backgroundColor: d.color,       
                allDay: true,
                overlap: false
            });
        });
        callback(events);
    } catch (error) {
        console.error(error);
        callback([]);
    }
};
}