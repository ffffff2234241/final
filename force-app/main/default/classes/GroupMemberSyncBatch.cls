public with sharing class GroupMemberSyncBatch implements Database.Batchable<SObject> {

    Map<String, String> groupPickvalueMap = new Map<String, String>{
        'Seoul' => '서울',
        'Gyeonggi' => '경기',
        'Chungcheong' => '충청',
        'Jeolla' => '전라',
        'Gangwon' => '강원',
        'Gyeongsang' => '경상',
        'Jeju' => '제주'
    };

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT GroupId, UserOrGroupId FROM GroupMember');
    }

    public void execute(Database.BatchableContext bc, List<GroupMember> scope) {
        // Map<Id, User> userMap = new Map<Id, User>();
        // List<User> usersToUpdate = new List<User>();

        List<Id> userOrGroupIds = new List<Id>();
        for (GroupMember gmember : scope) {
            userOrGroupIds.add(gmember.UserOrGroupId);
        } 

        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Region_Multiselect__c FROM User WHERE Id IN :userOrGroupIds]);
        for (User u : userMap.values()) {
            u.Region_Multiselect__c = null;
        }
        // Prepare group data
        List<String> regionList = new List<String>{
            'Seoul', 'Gyeonggi', 'Chungcheong', 'Jeolla', 'Gangwon', 'Gyeongsang', 'Jeju'
        };

        // Get Group data
        Map<String, Group> nameGroupMap = new Map<String, Group>();
        for (Group regionGroup : [SELECT Id, Name FROM Group WHERE Name IN :regionList AND Type = 'Regular']) {
            nameGroupMap.put(regionGroup.Name, regionGroup);
        }

        for (GroupMember gm : scope) {
            String prefix = String.valueOf(gm.UserOrGroupId).substring(0, 3);
            if (prefix != '005') {
                continue;
            }

            User us = userMap.get(gm.UserOrGroupId);
            // if (us == null) {
            //     // query in loop
            //     // for (gm) {userlist.add(gm.userOrGroupId)} && userMap = select from user where id in userlist
            //     User tmpUser = [SELECT Id, Region_Multiselect__c FROM User WHERE Id = :gm.UserOrGroupId LIMIT 1];
            //     if (tmpUser != null) {
            //         userMap.put(gm.UserOrGroupId, tmpUser);
            //         us = tmpUser;
            //     }
            // }

            if (us == null) continue; // Continue if user not found

            String groupName = getGroupName(gm.GroupId); // gpname map
            String korGroupName = groupPickvalueMap.get(groupName);

            List<String> regionsOfUser = us.Region_Multiselect__c != null ? us.Region_Multiselect__c.split(';') : new List<String>();

            if (!regionsOfUser.contains(korGroupName)) {
                regionsOfUser.add(korGroupName);
                us.Region_Multiselect__c = String.join(regionsOfUser, ';');
                // usersToUpdate.add(us);
            }

            // 이거 멀티랑 체크박스는 쪼개
            // if (isInsert) {
            //     if (!regionsOfUser.contains(korGroupName)) {
            //         regionsOfUser.add(korGroupName);
            //         us.Region_Multiselect__c = String.join(regionsOfUser, ';');
            //         usersToUpdate.add(us);
            //     }
            // } else {
            //     if (regionsOfUser.contains(korGroupName)) {
            //         regionsOfUser.remove(korGroupName);
            //         us.Region_Multiselect__c = String.join(regionsOfUser, ';');
            //         usersToUpdate.add(us);
            //     }
            // }
        }


        // 그사이 유저 deactive면?
        TriggerExecutionFlags.isRegionGroupMemberUpdated = true;
        if (!userMap.values().isEmpty()) {
            update userMap.values();
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optionally, do any final processing, like logging or notifications
    }

    private String getGroupName(Id groupId) {
        Group gppp = [SELECT Name FROM Group WHERE Id = :groupId LIMIT 1];
        return gppp.Name;
    }
}