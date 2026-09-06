Map<String, Object> inputs = new Map<String, Object>{
    'caseSubject' => 'Loan Rejection Inquiry',
    'caseDescription' => 'The customer inquired about the reason for their loan rejection.'
};

try {
    Flow.Interview.SvcCopilotTmpl.CreateCase interview = 
        new Flow.Interview.SvcCopilotTmpl.CreateCase(inputs);
    interview.start();
    System.debug('TEST LOG -> CreateCase Succeeded! Created case: ' + interview.getVariableValue('caseId'));
} catch (Exception e) {
    System.debug('TEST LOG -> CreateCase Error: ' + e.getMessage());
}
