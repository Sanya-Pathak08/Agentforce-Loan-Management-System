ContentWorkspace ws;
List<ContentWorkspace> existing = [SELECT Id, Name FROM ContentWorkspace WHERE Name = 'Loan_Policy_Library'];
if (existing.isEmpty()) {
    ws = new ContentWorkspace(Name = 'Loan_Policy_Library', Description = 'Agentforce Data Library for Loan Policies');
    insert ws;
    System.debug('Created ContentWorkspace: ' + ws.Id);
} else {
    ws = existing[0];
    System.debug('Existing ContentWorkspace: ' + ws.Id);
}

// Add the 3 documents to the workspace
Set<Id> docIds = new Set<Id>{
    '069NS00000e1c7RYAQ',
    '069NS00000e2EPdYAM',
    '069NS00000e2EPeYAM'
};

for (Id docId : docIds) {
    List<ContentWorkspaceDoc> cwdList = [SELECT Id FROM ContentWorkspaceDoc WHERE ContentWorkspaceId = :ws.Id AND ContentDocumentId = :docId];
    if (cwdList.isEmpty()) {
        insert new ContentWorkspaceDoc(ContentWorkspaceId = ws.Id, ContentDocumentId = docId);
        System.debug('Added document ' + docId + ' to workspace ' + ws.Id);
    }
}