Id wsId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Loan_Policy_Library' LIMIT 1].Id;
Set<Id> docIds = new Set<Id>{
    '069NS00000e1c7RYAQ',
    '069NS00000e2EPdYAM',
    '069NS00000e2EPeYAM'
};
List<ContentWorkspaceDoc> toInsert = new List<ContentWorkspaceDoc>();
for (Id dId : docIds) {
    toInsert.add(new ContentWorkspaceDoc(ContentWorkspaceId = wsId, ContentDocumentId = dId));
}
insert toInsert;
System.debug('Successfully linked ' + toInsert.size() + ' documents to Loan_Policy_Library!');