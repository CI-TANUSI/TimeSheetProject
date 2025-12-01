import { LightningElement, api, wire } from 'lwc';
import getAmounts from '@salesforce/apex/PerformanceTrackerController.getAmounts';

export default class AmountDisplay extends LightningElement {
  @api recordId;

  opportunity = 0;
  pm = 0;
  expense = 0;
  pnl = 0;
  rawPnl = 0;
  pnlPercent = 0;
  pnlColor='';
  currencyIsoCode;
  error;

  get currencySymbol() {
    switch (this.currencyIsoCode) {
      case 'USD':
      case 'AUD':
        return '$';
      case 'INR':
        return '₹';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      default:
        return this.currencyIsoCode || '';
    }
  }

  @wire(getAmounts, { recordId: '$recordId' })
  wiredData({ error, data }) {
    if (data) {
      const sales = parseFloat(data.opportunity);
      const revenue = parseFloat(data.pm);
      const expense = parseFloat(data.expense);

      this.opportunity = sales.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      });

      this.pm = revenue.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      });

      this.expense = expense.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      });

      
      const pnlValue = revenue - expense;
      const pnlPercentValue = revenue !== 0 ? (pnlValue / revenue) * 100 : (pnlValue/expense)*100;

      this.rawPnl= pnlValue;

      this.pnl = pnlValue.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      });

      this.pnlPercent = pnlPercentValue.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      });
      
      this.pnlColor = pnlValue >= 0 ? 'green' : 'red';

      this.currencyIsoCode = data.currencyIsoCode;

    } else if (error) {
      this.error = error;
    }
  }
  get pnlStyle() {
    return `color: ${this.pnlColor}`;
  }

  get formattedPnl() {
    const symbol = this.currencySymbol;
    const absValue = Math.abs(this.rawPnl).toLocaleString('en-US', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    });
    return this.rawPnl < 0 ? `- ${symbol}${absValue}` : `${symbol}${absValue}`;
  }
  

}