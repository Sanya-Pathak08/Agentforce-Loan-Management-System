List<ContentWorkspace> wsList = [SELECT Id, Name FROM ContentWorkspace WHERE Name = 'Loan Policy Documents'];
ContentWorkspace ws;
if (wsList.isEmpty()) {
    ws = new ContentWorkspace(Name = 'Loan Policy Documents');
    insert ws;
    System.debug('Created ContentWorkspace: ' + ws.Id);
} else {
    ws = wsList[0];
    System.debug('Existing ContentWorkspace: ' + ws.Id);
}
List<ContentWorkspaceDoc> cwdList = [SELECT Id FROM ContentWorkspaceDoc WHERE ContentWorkspaceId = :ws.Id AND ContentDocumentId = '069NS00000e1c7RYAQ'];
if (cwdList.isEmpty()) {
    insert new ContentWorkspaceDoc(ContentWorkspaceId = ws.Id, ContentDocumentId = '069NS00000e1c7RYAQ');
    System.debug('Added PDF to ContentWorkspaceDoc successfully!');
}
