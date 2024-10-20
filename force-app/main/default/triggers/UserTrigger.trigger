// 배치가 돌기전에 트리거되면?
// grade 트리거
// 파트너만 type
trigger UserTrigger on User (after insert, before update) {

    System.debug(TriggerExecutionFlags.isRegionGroupMemberUpdated);
    if (TriggerExecutionFlags.isRegionGroupMemberUpdated) {
        return;
    }

    String SEOUL = 'Seoul';
    String GYEONGGI = 'Gyeonggi';
    String CHUNGCHEONG = 'Chungcheong';
    String JEOLLA = 'Jeolla';
    String GANGWON = 'Gangwon';
    String GYEONGSANG = 'Gyeongsang';
    String JEJU = 'Jeju';
    List<String> regionList = new List<String>{SEOUL, GYEONGGI, CHUNGCHEONG, JEOLLA, GANGWON, GYEONGSANG, JEJU};
    regionList.sort();// 솥 없애기 노션 참고 how about type like this
    Map<String, String> groupPickvalueMap = new Map<String, String>();
    groupPickvalueMap.put(SEOUL, '서울');
    groupPickvalueMap.put(GYEONGGI, '경기');
    groupPickvalueMap.put(CHUNGCHEONG, '충청');
    groupPickvalueMap.put(JEOLLA, '전라');
    groupPickvalueMap.put(GANGWON, '강원');
    groupPickvalueMap.put(GYEONGSANG, '경상');
    groupPickvalueMap.put(JEJU, '제주');

    List<Group> regionGroups = [SELECT Id, Name FROM Group WHERE Name IN :regionList AND Type = 'Regular' ORDER BY Name]; // 오더바이 없애기 노션참고
    Map<String, Group> groupMap = new Map<String, Group>();

    for (Group regionGroup : regionGroups) {
        groupMap.put(regionGroup.Name, regionGroup);
    }



    List<GroupMember> groupMembersToDelete = new List<GroupMember>();
    List<GroupMember> groupMembersToInsert = new List<GroupMember>();


    //////////////////////////////////////////////////////////////////

    if (Trigger.isUpdate) {

        // 이거 그냥 해주는거? value는 id가 아니고 Group인데
        List<GroupMember> existingGroupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :Trigger.new AND GroupId IN :groupMap.values()];
        Map<Id, List<GroupMember>> userGroupMemberMap = new Map<Id, List<GroupMember>>();

        for (GroupMember gm : existingGroupMembers) {
            if (!userGroupMemberMap.containsKey(gm.UserOrGroupId)) {
                userGroupMemberMap.put(gm.UserOrGroupId, new List<GroupMember>());
            }
            userGroupMemberMap.get(gm.UserOrGroupId).add(gm);
        }

        for (User user : Trigger.new) {
            if (user.Region_Multiselect__c == null) {
                return; 
            }
            
            User oldUser = Trigger.oldMap.get(user.Id);
            Set<String> oldRegions = new Set<String>(); // {서울, 경기 ...}
            
            if (oldUser.Region_Multiselect__c != null) {
                oldRegions.addAll(oldUser.Region_Multiselect__c.split(';'));
            }

            System.debug(user.Region_Multiselect__c);
            
            Set<String> newRegions = new Set<String>(user.Region_Multiselect__c.split(';')); // {서울, 경기 ...}

            for (String regionEngName : regionList) { // 모든지역

                System.debug(newRegions);
                System.debug(groupPickvalueMap.get(regionEngName));
                System.debug(newRegions.contains(groupPickvalueMap.get(regionEngName)));
                System.debug(!oldRegions.contains(groupPickvalueMap.get(regionEngName)));

                if (newRegions.contains(groupPickvalueMap.get(regionEngName))) { // 현 체크리스트에 있는지역이면
                    if (!oldRegions.contains(groupPickvalueMap.get(regionEngName))) { // 근데 없던 지역이면
                        groupMembersToInsert.add(new GroupMember(GroupId = groupMap.get(regionEngName).Id, UserOrGroupId = user.Id));
                    }
                } else {  // 현 체크리스트에 없는지역
                    if (oldRegions.contains(groupPickvalueMap.get(regionEngName))) { // 근데 원래는 있던지역 
                        if (userGroupMemberMap.containsKey(user.Id)) { // 얘가 어떤 그룹에 속해있었으면
                            for (GroupMember gm : userGroupMemberMap.get(user.Id)) { // 나 자신인 그 그룹멤버들을 돌면서
                                if (gm.GroupId == groupMap.get(regionEngName).Id) {
                                    groupMembersToDelete.add(gm); 
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //////////////////////////////////////////////////////////////////

    if (Trigger.isInsert) { // not work
        
        for (User user : Trigger.new) {
            if (user.Region_Multiselect__c == null) {
                break; // break? handler? 
            }

            System.debug(user.Region_Multiselect__c);
        Set<String> newRegions = new Set<String>(user.Region_Multiselect__c.split(';')); // {서울, 경기 ...}

        System.debug(newRegions);
        for (String region : regionList) { // 모든지역
            if (newRegions.contains(groupPickvalueMap.get(region))) { // 현 체크리스트에 있는지역이면
                groupMembersToInsert.add(new GroupMember(GroupId = groupMap.get(region).Id, UserOrGroupId = user.Id));
            }
        }
    }
    }
    if (!groupMembersToDelete.isEmpty()) {
        delete groupMembersToDelete;
    }

    System.debug(groupMembersToInsert);
    if (!groupMembersToInsert.isEmpty()) {
        insert groupMembersToInsert;
    }



    TriggerExecutionFlags.isUserRegionUpdated = true;

}

// trigger UserTrigger on User (after insert, before update) {

// // Define region constants
// String SEOUL = 'Seoul';
// String GYEONGGI = 'Gyeonggi';
// String CHUNGCHEONG = 'Chungcheong';
// String JEOLLA = 'Jeolla';
// String GANGWON = 'Gangwon';
// String GYEONGSANG = 'Gyeongsang';
// String JEJU = 'Jeju';

// // Step 1: Define and sort the region list
// List<String> regionList = new List<String>{SEOUL, GYEONGGI, CHUNGCHEONG, JEOLLA, GANGWON, GYEONGSANG, JEJU};
// regionList.sort();

// // Step 2: Query the Group records
// List<Group> regionGroups = [SELECT Id, Name FROM Group WHERE Name IN :regionList AND Type = 'Regular' ORDER BY Name];
// Map<String, Group> groupMap = new Map<String, Group>();

// // Populate the group map
// for (Group group : regionGroups) {
//     groupMap.put(group.Name, group);
// }

// List<GroupMember> groupMembersToDelete = new List<GroupMember>();
// List<GroupMember> groupMembersToInsert = new List<GroupMember>();

// // Step 3: For updates, query existing GroupMember records for all users being modified
// Map<Id, List<GroupMember>> userGroupMemberMap = new Map<Id, List<GroupMember>>();
// if (Trigger.isUpdate) {
//     List<GroupMember> existingGroupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId IN :Trigger.new AND GroupId IN :groupMap.values()];

//     // Populate the map
//     for (GroupMember gm : existingGroupMembers) {
//         if (!userGroupMemberMap.containsKey(gm.UserOrGroupId)) {
//             userGroupMemberMap.put(gm.UserOrGroupId, new List<GroupMember>());
//         }
//         userGroupMemberMap.get(gm.UserOrGroupId).add(gm);
//     }
// }

// for (User user : Trigger.new) {
//     if (user.Region_Multiselect__c == null) {
//         continue; // Skip if the region is not set
//     }

//     // Get the old user record to check the previous state (only for updates)
//     User oldUser = Trigger.isUpdate ? Trigger.oldMap.get(user.Id) : null;
//     Set<String> oldRegions = new Set<String>();

//     // Collect the old regions
//     if (oldUser != null && oldUser.Region_Multiselect__c != null) {
//         oldRegions.addAll(oldUser.Region_Multiselect__c.split(';'));
//     }

//     // Step 4: Handle each region dynamically
//     Set<String> newRegions = new Set<String>(user.Region_Multiselect__c.split(';'));

//     for (String region : regionList) {
//         if (newRegions.contains(region)) { // If the user is in the current region
//             if (oldRegions == null || !oldRegions.contains(region)) { // Previously not in this region
//                 // Add user to the group
//                 groupMembersToInsert.add(new GroupMember(GroupId = groupMap.get(region).Id, UserOrGroupId = user.Id));
//             }
//         } else { // If the user is not in the current region
//             if (oldRegions != null && oldRegions.contains(region)) { // Previously in this region
//                 // Retrieve existing GroupMembers for this user in this group
//                 if (userGroupMemberMap.containsKey(user.Id)) {
//                     for (GroupMember gm : userGroupMemberMap.get(user.Id)) {
//                         if (gm.GroupId == groupMap.get(region).Id) {
//                             groupMembersToDelete.add(gm); // Add to delete list
//                             break; // No need to check further for this region
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

// // Perform deletion and insertion outside the loop
// if (!groupMembersToDelete.isEmpty()) {
//     delete groupMembersToDelete;
// }

// if (!groupMembersToInsert.isEmpty()) {
//     insert groupMembersToInsert;
// }
// }









// 나중에 하자
// List<String> regionList = new List<String>{'Jeolla', 'Gangwon','Seoul', 'Gyeonggi', 'Chungcheong',  'Gyeongsang', 'Jeju'};

// List<Group> regionGroups = [SELECT Id, Name FROM Group WHERE Name IN :regionList AND Type = 'Regular' ORDER BY Name DESC];
// System.debug(regionGroups);

// Map<String, Group> groupMap = new Map<String, Group>();

// for (Group gpgp : regionGroups) {
//     groupMap.put(gpgp.Name, gpgp);
// }

// Group seoulGroup = groupMap.get('Seoul');
// System.debug(groupMap);
// System.debug('Seoul Group ID: ' + seoulGroup.Id);


// System.debug(1);
// System.debug(1);





//     String SEOUL = 'Seoul';
//     String GYEONGGI = 'Gyeonggi';
//     String CHUNGCHEONG = 'Chungcheong';
//     String JEOLLA = 'Jeolla';
//     String GANGWON = 'Gangwon';
//     String GYEONGSANG = 'Gyeongsang';
//     String JEJU = 'Jeju';

//     List<String> rererererere = new List<String>{SEOUL, GYEONGGI, CHUNGCHEONG, JEOLLA, GANGWON, GYEONGSANG, JEJU};
//     rererererere.sort();


//     // 이거 가능하면 orderby 필요x
//     // Map<String, Group> groupMap = new Map<String, Group>([SELECT Name FROM Group WHERE Name IN :rererererere AND Type = 'Regular']);
//     List<Group> rgrgrgrgrgrg = [SELECT Id, Name FROM Group WHERE Name IN :rererererere AND Type = 'Regular' ORDER BY Name];
//     Map<String, Group> mgpmgpgmpgmp = new Map<String, Group>();

//     for (Group regionGroup : rgrgrgrgrgrg) {
//         mgpmgpgmpgmp.put(regionGroup.Name, regionGroup);
//     }
//     System.debug(mgpmgpgmpgmp);