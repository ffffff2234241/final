List<ContentDocumentLink> contentLinks = [
    SELECT Id, Visibility 
    FROM ContentDocumentLink 
    WHERE LinkedEntityId = 'a00dM00000R1B9yQAF'
];

for (ContentDocumentLink link : contentLinks) {
    link.Visibility = 'AllUsers';
}

// Update the records
if (!contentLinks.isEmpty()) {
    update contentLinks;
}