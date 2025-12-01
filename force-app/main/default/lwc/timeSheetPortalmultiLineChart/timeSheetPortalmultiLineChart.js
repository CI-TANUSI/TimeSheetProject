import { LightningElement } from 'lwc';
//import TimeSheetResource from '@salesforce/resourceUrl/TimeSheetPortalChartJs';
import { loadScript } from 'lightning/platformResourceLoader';

export default class MultiLineChartExample extends LightningElement {

    isChartJsInitialized = false;

    renderedCallback() {
        if (this.isChartJsInitialized) return;
        this.isChartJsInitialized = true;

        loadScript(this, chartjs)
            .then(() => {
                this.initializeChart();
            })
            .catch(error => {
                console.error('Error loading Chart JS', error);
            });
    }

    initializeChart() {
        const ctx = this.template.querySelector('canvas.multiLineChart').getContext('2d');

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],

                datasets: [
                    {
                        label: 'Product A',
                        data: [10, 15, 8, 18, 20],
                        borderColor: 'blue',
                        borderWidth: 2,
                        tension: 0.4,

                        pointRadius: 6,
                        pointBackgroundColor: 'white',
                        pointBorderColor: 'blue',
                        pointBorderWidth: 2
                    },
                    {
                        label: 'Product B',
                        data: [5, 12, 10, 7, 14],
                        borderColor: 'red',
                        borderWidth: 2,
                        tension: 0.4,

                        pointRadius: 6,
                        pointBackgroundColor: 'yellow',
                        pointBorderColor: 'red',
                        pointBorderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: true }
                }
            }
        });
    }
}