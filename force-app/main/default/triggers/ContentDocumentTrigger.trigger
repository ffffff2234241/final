trigger ContentDocumentTrigger on ContentDocument (before insert) {
    System.debug('logLevel');
}