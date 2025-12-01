public class MilestoneBasedController {
    
    public Id milestoneId{ get; set; }
    
    public Payment_Milestone__c milestone{ get; set; }
    
    public Opportunity opp{ get; set; }
    
    public Account acc{ get; set; }
    
    public Date todayDate{ get; set; }
    
    public String formattedDate{ get; set; }
    
    public String formattedFutureDate{get; set;}
    
    public String description{ get; set; }
    
    public String paymentMilestone{ get; set; }
    
    public Ci_Billing_Address__mdt selectedBillingAddress{ get; set; }
    
    public CI_Bank_Account__mdt   selectedAccountAddress{ get; set;}
    
    public CI_Bank_Account__mdt   selectedAccountAddresses{ get; set;}
    
    public Boolean showGST{ get; set; }
    
    public Boolean showIGST{ get; set; }
    
    public Boolean showCGST_SGST{ get; set; }
    
    public Decimal grandTotal{ get; set;}
    
    public Decimal igst{ get; set;}
    
    public Decimal cgst{ get; set;}
    
    public Decimal sgst{ get; set;}
    
    public String result{ get; set; }
    
    public String igstValue{ get; set; }
    
    public String sgstValue{ get; set; }
    
    public String cgstValue{ get; set; }
    
    public Boolean showSign{ get; set; }
    
    public String formattedAmount{ get; set; }
    
    public String formatigst{ get; set; }
    
    public String formatcgst{ get; set; }
    
    public String formatsgst{ get; set; }
    
    public String formatmilestone{ get; set; }
    
    public String link{ get; set; }
    
    public String upwork{ get; set; }
    
    public MilestoneBasedController() {
        milestoneId = ApexPages.currentPage().getParameters().get('id');
        description = ApexPages.currentPage().getParameters().get('desc');
        paymentMilestone = ApexPages.currentPage().getParameters().get('milestone');
        String devName = ApexPages.currentPage().getParameters().get('devName');
        String accountDevName= ApexPages.currentPage().getParameters().get('AccountdevName');
        String accountDevNames= ApexPages.currentPage().getParameters().get('AccountdevNames');
        String accountWgDevNames= ApexPages.currentPage().getParameters().get('AccountWgdevNames');
        String gstApplicable = ApexPages.currentPage().getParameters().get('gst');
        String gstType= ApexPages.currentPage().getParameters().get('gstType');
        igstValue = ApexPages.currentPage().getParameters().get('igstValue');
        sgstValue = ApexPages.currentPage().getParameters().get('sgstValue');
        cgstValue = ApexPages.currentPage().getParameters().get('cgstValue');
        String sign= ApexPages.currentPage().getParameters().get('sign');
        link = ApexPages.currentPage().getParameters().get('link'); 
        upwork = ApexPages.currentPage().getParameters().get('upwork'); 
        
        todayDate= Date.today();
        formattedDate = System.now().format('dd-MM-YYYY');
        
        
        
        if (milestoneId != null) {
            milestone = [SELECT Id, Name,Amount__c,Account__c,Month__c,Rate__c,Billable_Hours_Day__c,Payment_Due_Dates__c, Opportunity__c FROM Payment_Milestone__c WHERE Id = :milestoneId LIMIT 1];
            opp = [SELECT Id, AccountId,CurrencyIsoCode,Deal_Source__c,Upwork_Profile__c FROM Opportunity WHERE Id = :milestone.Opportunity__c LIMIT 1];
            acc = [SELECT Id, Name, Phone,GST__c, BillingCity,billingCountry,BillingPostalCode,BillingState,BillingStreet FROM Account WHERE Id =:opp.AccountId LIMIT 1 ];
            
        }
        
        if (String.isNotBlank(devName)) {
            List<Ci_Billing_Address__mdt> BillingList =[SELECT id,DeveloperName,Company_Name__c, City__c,Country__c,GST_No__c,MSME_Reg_No__c,Pin_Code__c,SAC_Code__c,State__c,Street__c from CI_Billing_Address__mdt   
                                                        WHERE DeveloperName = :devName LIMIT 1];
            if(BillingList.size()>0){
                selectedBillingAddress= BillingList[0];
            } 
        }
        
        if (String.isNotBlank(accountDevName)) {
            List<CI_Bank_Account__mdt> AccountList = [SELECT Account_No__c,Bank_Code__c,Sort_code__c,Bank_name__c,Beneficiary_Name__c,Branch__c,IFSC__c,SWIFT_Code__c from CI_Bank_Account__mdt  
                                                      WHERE DeveloperName=:accountDevName LIMIT 1];
            if(AccountList.size()>0){
                selectedAccountAddress = AccountList[0];
            }
        }
        
        if (String.isNotBlank(accountDevNames)) {
            List<CI_Bank_Account__mdt> AccountList = [SELECT Account_No__c,Bank_Code__c,Bank_name__c,Sort_code__c,Beneficiary_Name__c,Branch__c,IFSC__c,SWIFT_Code__c from CI_Bank_Account__mdt  
                                                      WHERE DeveloperName=:accountDevNames LIMIT 1];
            if(AccountList.size()>0){
                selectedAccountAddresses = AccountList[0]; 
            }
            
        }
        
        if (String.isNotBlank(accountWgDevNames)) {
            List<CI_Bank_Account__mdt> AccountList = [SELECT Account_No__c,Bank_Code__c,Bank_name__c,Sort_code__c,Beneficiary_Name__c,Branch__c,IFSC__c,SWIFT_Code__c from CI_Bank_Account__mdt  
                                                      WHERE DeveloperName=:accountWgDevNames LIMIT 1];
            if(AccountList.size()>0){
                selectedAccountAddresses = AccountList[0]; 
            }
            
        }
        
        if (milestone.Payment_Due_Dates__c != null) {
            Date FutureDate= milestone.Payment_Due_Dates__c;
            String dayStr = futureDate.day() < 10 ? '0' + futureDate.day() : String.valueOf(futureDate.day());
            String monthStr = futureDate.month() < 10 ? '0' + futureDate.month() : String.valueOf(futureDate.month());
            String yearStr = String.valueOf(futureDate.year());
            formattedFutureDate = dayStr + '-' + monthStr + '-' + yearStr;
        }
        
        if (sign != null && sign == 'Yes') {
            showSign= true;
        }
        else {
            showSign = false; 
        }
        
        
        if (acc != null && acc.BillingCountry != null) {
            showGST = acc.BillingCountry.equalsIgnoreCase('India') && gstApplicable == 'Yes';
        }
        else {
            showGST = false;
        }
        
        
        showIGST = false;
        showCGST_SGST = false;
        
        if (showGST && String.isNotBlank(gstType)) {
            if (gsttype.equalsIgnoreCase('IGST')) {
                showIGST = true;
            }
            else {
                showCGST_SGST = true;
            }
        }
        
        
        if(milestone.Amount__c != null && milestone.Amount__c != null) {
            formatmilestone = CurrencyFormatter.formatAmount(milestone.Amount__c, opp.CurrencyIsoCode);
        }
        
        
        
        if (milestone != null && milestone.Amount__c != null && showIGST) {
            igst = ((milestone.Amount__c * 18) / 100).setScale(2, RoundingMode.HALF_UP);
            formatigst = CurrencyFormatter.formatAmount(igst, opp.CurrencyIsoCode);
            grandTotal = (milestone.Amount__c + igst).setScale(2, RoundingMode.HALF_UP);
            formattedAmount = CurrencyFormatter.formatAmount(grandTotal, opp.CurrencyIsoCode);
            
        }
        
        
        if (milestone != null && milestone.Amount__c != null && showCGST_SGST) {
            sgst = ((milestone.Amount__c * 9) / 100).setScale(2, RoundingMode.HALF_UP);
            formatsgst = CurrencyFormatter.formatAmount(sgst, opp.CurrencyIsoCode);
            cgst = ((milestone.Amount__c * 9) / 100).setScale(2, RoundingMode.HALF_UP);
            formatcgst = CurrencyFormatter.formatAmount(cgst, opp.CurrencyIsoCode);
            grandTotal = (milestone.Amount__c + sgst + cgst).setScale(2, RoundingMode.HALF_UP);
            formattedAmount = CurrencyFormatter.formatAmount(grandTotal, opp.CurrencyIsoCode);
            
        }
        
        
        if (!showGST) {
            if (milestone != null && milestone.Amount__c != null) {
                grandTotal = milestone.Amount__c;
                formattedAmount = CurrencyFormatter.formatAmount(grandTotal, opp.CurrencyIsoCode);
            }
        }
        
        
        if (grandTotal != null && (opp.CurrencyIsoCode=='AUD'|| opp.CurrencyIsoCode=='USD')) {
            result = NumberToWords.getAmountInDollars(grandTotal);
        }
        if (grandTotal != null && opp.CurrencyIsoCode=='GBP') {
            result = NumberToWords.getAmountInPounds(grandTotal);
        }
        if (grandTotal != null && opp.CurrencyIsoCode!='GBP' && opp.CurrencyIsoCode!='AUD' && opp.CurrencyIsoCode!='USD') {
            result = NumberToWords.getNumberInWords(grandTotal);
        }
        
    }
}