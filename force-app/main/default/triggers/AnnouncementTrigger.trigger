trigger AnnouncementTrigger on Announcement__c (before insert, before update) {
    for (Announcement__c announcement : Trigger.new) {
        if (announcement.Partner_Region_Multiselect__c == null) {
            break; // break?  handler?
        }

        if (announcement.Partner_Region_Multiselect__c.contains('서울')) { // global picklist val?
            announcement.RegionSeoul__c = true; 
        } else {
            announcement.RegionSeoul__c = false;
        }

        if (announcement.Partner_Region_Multiselect__c.contains('경기')) {
            announcement.RegionGyeonggi__c = true; 
        } else {
            announcement.RegionGyeonggi__c = false;
        }

        if (announcement.Partner_Region_Multiselect__c.contains('충청')) {
            announcement.RegionChungcheong__c = true; 
        } else {
            announcement.RegionChungcheong__c = false;
        }

        if (announcement.Partner_Region_Multiselect__c.contains('전라')) {
            announcement.RegionJeolla__c = true; 
        } else {
            announcement.RegionJeolla__c = false;
        }

        if (announcement.Partner_Region_Multiselect__c.contains('경상')) {
            announcement.RegionGyeongsang__c = true; 
        } else {
            announcement.RegionGyeongsang__c = false;
        }

        if (announcement.Partner_Region_Multiselect__c.contains('제주')) {
            announcement.RegionJeju__c = true; 
        } else {
            announcement.RegionJeju__c = false;
        }
    }
}