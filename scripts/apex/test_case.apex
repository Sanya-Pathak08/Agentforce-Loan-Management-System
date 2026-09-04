Group q = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Loan_Support_Queue' LIMIT 1];
Case c = new Case(
    Subject = 'Loan Inquiry – FAQ not found',
    Description = 'Customer asks: Why was my loan rejected?',
    Origin = 'Agentforce AI',
    Priority = 'Medium',
    OwnerId = q.Id
);
insert c;
c = [SELECT Id, CaseNumber, Subject, Origin, Priority, Owner.Name FROM Case WHERE Id = :c.Id];
System.debug('TEST LOG -> Created Case: ' + c.CaseNumber + ' | Owner: ' + c.Owner.Name + ' | Origin: ' + c.Origin);
