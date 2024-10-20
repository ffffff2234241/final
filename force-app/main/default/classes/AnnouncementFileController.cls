public with sharing class AnnouncementFileController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getAnnouncementFile(String announcementId) {
        List<ContentDocumentLink> lstCDL= new List<ContentDocumentLink>();
        Set<Id> cdlId = new Set<Id>();
        lstCDL = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :announcementId
        ];
        for (ContentDocumentLink objCDL : lstCDL) {
            cdlId.add(objCDL.ContentDocumentId);
        }

        if (cdlId != null) {
            List<ContentDocument> files = new List<ContentDocument>();
            files = [
                SELECT Id, Title, FileExtension, ContentSize, LastModifiedDate, OwnerId
                FROM ContentDocument 
                WHERE Id IN :cdlId
            ];
            return files;
        }
        return null;
    }
}