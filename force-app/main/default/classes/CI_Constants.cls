public inherited sharing class CI_Constants {
    public static final String ACCOUNT_OBJECT = 'Account';
    public static final String OPPORTUNITY_OBJECT = 'Opportunity';
    public static final String LEAD_OBJECT = 'Lead';
    public static final String ACCOUNT_SHARING_PROVIDER = 'CI_AccountShare';
    public static final String OPPORTUNITY_SHARING_PROVIDER = 'CI_OpportunityShare';
    public static final String LEAD_SHARING_PROVIDER = 'CI_LeadShare';
    public static final String ROW_CAUSE_MANUAL = 'Manual';
    public static final String ACCESS_LEVEL_EDIT = 'Edit';
    public static final String ACCESS_LEVEL_NONE = 'None';

    public static final Map<String, String> dataProvider = new Map<String, String>{
        ACCOUNT_OBJECT => ACCOUNT_SHARING_PROVIDER,
        OPPORTUNITY_OBJECT => OPPORTUNITY_SHARING_PROVIDER,
        LEAD_OBJECT => LEAD_SHARING_PROVIDER
    }; 
}