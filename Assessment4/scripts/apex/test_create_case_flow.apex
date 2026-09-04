Map<String, Object> inputs1 = new Map<String, Object>{
    'caseSubject' => 'Loan Rejection Inquiry',
    'caseDescription' => 'The customer inquired about the reason for their loan rejection.',
    'contactId' => '003NS000025SmM8YAK'
};

try {
    Flow.Interview.SvcCopilotTmpl.CreateCase interview = 
        new Flow.Interview.SvcCopilotTmpl.CreateCase(inputs1);
    interview.start();
    System.debug('TEST LOG -> CreateCase with contactId SUCCEEDED!');
} catch (Exception e) {
    System.debug('TEST LOG -> CreateCase with contactId Error: ' + e.getMessage());
}
