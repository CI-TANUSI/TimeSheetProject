public with sharing class CI_GrantAccessToHierarchy implements Queueable, Database.Batchable<sObject> {

    Set<Id> recordList;
    String objectName;

    public CI_GrantAccessToHierarchy(String objectName) {
        this.objectName = objectName;
    }

    
    public CI_GrantAccessToHierarchy(Set<Id> recordList, String objectName) {
        this.recordList = recordList;
        this.objectName = objectName;
    }


    public void execute(QueueableContext context) {
        String dataProcessor = CI_Constants.dataProvider.get(objectName);
        Type typeObj = Type.forName(dataProcessor);
        CI_SharingInterface dataProcessorInstance = (CI_SharingInterface)typeObj.newInstance();
        try {
            dataProcessorInstance.shareRecord(recordList);
        } catch (Exception ex) {
            CI_ExceptionLogger.logException(ex);
        }
    }

    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(getQuery());
    }


    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Map<Id, sObject> scopeMap = new Map<Id, sObject>(scope);
        Set<Id> recordIdsToProcess = new Set<Id>();
        
        recordIdsToProcess.addAll(scopeMap.keyset());

        String dataProcessor = CI_Constants.dataProvider.get(objectName);
        Type typeObj = Type.forName(dataProcessor);
        CI_SharingInterface dataProcessorInstance = (CI_SharingInterface)typeObj.newInstance();
        
        try {
           
            dataProcessorInstance.shareRecord(recordIdsToProcess);
        } catch (Exception ex) {
            CI_ExceptionLogger.logException(ex);
        }
    }

    public void finish(Database.BatchableContext BC) {
        
    }

    private string getQuery() {
        return 'SELECT ID FROM ' + objectName;
    }
}