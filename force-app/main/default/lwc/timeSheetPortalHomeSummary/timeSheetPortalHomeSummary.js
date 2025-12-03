import { LightningElement, track, api } from 'lwc';
import TimeSheetResource from '@salesforce/resourceUrl/TimeSheet';
import { loadScript } from 'lightning/platformResourceLoader';
import getChartDataApex from '@salesforce/apex/TimeSheetPortalController.getChartData';
//import getCalendertDataApex from '@salesforce/apex/TimeSheetPortalController.getCalendertData';



export default class TimeSheetPortalHomeSummary extends LightningElement {


    @api userId;

    chartInstance;
    chartFilter = '3Months';

    get filterOptions() {
        return [
            { label: '3 Months', value: '3Months' },
            { label: '6 Months', value: '6Months' },
            { label: '9 Months', value: '9Months' },
            { label: '12 Months', value: '12Months' },
        ];
    }

    async connectedCallback() {
        await loadScript(this, TimeSheetResource + '/lib/chart.js');

        this.initialiseData();
    }

    async initialiseData() {
        const resp = await getChartDataApex({userId : this.userId, filter: this.chartFilter});

        console.log('resp getChartDataApex----'+JSON.stringify(resp));
        
        if(resp && resp.isSuccess) {
            if(resp.data) {
                if(this.chartInstance) {
                    this.updateChartData(resp.data.labels, resp.data.datasets);
                } else {
                    this.initialiseChart(resp.data.labels, resp.data.datasets);
                }
            } else {
                // Debug error
            }
        } else {
            // Show Toast
        }
    }

    initialiseChart(lables, dataset) {

        const ctx = this.template.querySelector('canvas.myChart').getContext('2d');

        this.chartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: lables,
                datasets: dataset
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

    handleChartFilterChange(event) {
        this.chartFilter = event.detail.value;
        this.initialiseData();
    }

    updateChartData(labels, dataset) {

        this.chartInstance.data.labels = labels;
        this.chartInstance.data.datasets = dataset;

        this.chartInstance.update();
    }

}