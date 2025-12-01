import { LightningElement, api, wire } from 'lwc';

export default class CalendarView extends LightningElement {
    @api personId;
    @api filledHoursByDate = {}; // Default to empty object
    @api year;
    @api month;

    weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    selectedDay = null;

    get monthName() {
        return new Date(this.year, this.month - 1).toLocaleString('default', { month: 'long' });
    }

    get calendarDays() {
        const days = [];
        const firstDay = new Date(this.year, this.month - 1, 1);
        const lastDay = new Date(this.year, this.month, 0);
        const numDays = lastDay.getDate();
        const today = new Date();
        today.setHours(0,0,0,0);

        // Calculate weekday of the first day (0=Sun, 1=Mon, ..., 6=Sat)
        let firstWeekday = firstDay.getDay();
        // Add empty cells for days before the first weekday (Su=0)
        for (let i = 0; i < firstWeekday; i++) {
            days.push({ key: 'empty-' + i, day: '', className: 'calendar-cell empty' });
        }

        // Fill days of the month, including weekends
        for (let d = 1; d <= numDays; d++) {
            const cellDate = new Date(this.year, this.month - 1, d);
            const dayOfWeek = cellDate.getDay();
            const dateStr = `${this.year}-${String(this.month).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
            let className = 'calendar-cell';
            cellDate.setHours(0,0,0,0);
            if (dayOfWeek === 0 || dayOfWeek === 6) {
                // For Saturday (6) and Sunday (0), do not apply color logic
                // Just use the default className
            } else if (cellDate <= today) {
                const filled = (this.filledHoursByDate && this.filledHoursByDate[dateStr]) || 0;
                if (filled >= 8) {
                    className += ' calendar-green';
                } else if (filled > 4 && filled < 8) {
                    className += ' calendar-orange';
                } else if (filled <= 4) {
                    className += ' calendar-red';
                }
            } else {
                className += ' calendar-white';
            }
            if (this.selectedDay === d) {
                className += ' calendar-selected';
            }
            days.push({ key: dateStr, day: d, className, dateStr });
        }
        return days;
    }

    handlePrevMonth() {
        let newMonth = this.month - 1;
        let newYear = this.year;
        if (newMonth < 1) {
            newMonth = 12;
            newYear--;
        }
        this.dispatchEvent(new CustomEvent('monthchange', {
            detail: { year: newYear, month: newMonth }
        }));
    }

    handleNextMonth() {
        let newMonth = this.month + 1;
        let newYear = this.year;
        if (newMonth > 12) {
            newMonth = 1;
            newYear++;
        }
        this.dispatchEvent(new CustomEvent('monthchange', {
            detail: { year: newYear, month: newMonth }
        }));
    }

    handleDayClick(event) {
        const day = event.currentTarget.dataset.day;
        if (day) {
            this.selectedDay = parseInt(day, 10);
            this.dispatchEvent(new CustomEvent('dayselect', {
                detail: { year: this.year, month: this.month, day: this.selectedDay }
            }));
        }
    }

}