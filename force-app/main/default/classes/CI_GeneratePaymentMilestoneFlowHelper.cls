public with sharing class CI_GeneratePaymentMilestoneFlowHelper {
    

    @InvocableMethod(label='Generate Payment Milestones' description='Return the list of new payment milestones' category='Payment_Milestone__c')
    public static List<List<Payment_Milestone__c>> generatePaymentMilestones(List<InputWrapper> inputWrapperList) {

        List<List<Payment_Milestone__c>> paymentMilestoneList = new List<List<Payment_Milestone__c>>();
        for(InputWrapper wrap: inputWrapperList) {
            List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
            Integer count = 0;
            while(wrap.noOfPm > count) {

                pmList.add(new Payment_Milestone__c(
                    Invoice_Due_Date__c = getDueDate(wrap.startDate, wrap.interval, count),
                    Amount__c = wrap.amount,
                    Status__c = 'Draft',
                    Name = ''
                ));

                count++;
            }

            paymentMilestoneList.add(pmList);
        }

        return paymentMilestoneList;
    }

    private static Date getDueDate(Date startDate, String interval, Integer count) {
        if(interval == '1 Month') {
            return startDate.addMonths(1 * count);
        } else if(interval == '1 Week') {
            return startDate.addDays(7 * count);
        } else if(interval == '2 Week') {
            return startDate.addDays(14 * count);
        } else if(interval == '3 Week') {
            return startDate.addDays(21 * count);
        }
        return null;
    }

    public class InputWrapper {

        @InvocableVariable(label='Amount' required=true)
        public Decimal amount;

        @InvocableVariable(label='Start Date' required=true)
        public Date startDate;

        @InvocableVariable(label='Interval' required=true)
        public String interval;

        @InvocableVariable(label='No. of PM' required=true)
        public Integer noOfPm;
    }
}