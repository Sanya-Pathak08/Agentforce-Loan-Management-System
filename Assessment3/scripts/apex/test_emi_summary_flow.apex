Map<String, Object> inputs = new Map<String, Object>{
    'loanAccountId' => 'LACC-00001'
};

try {
    Flow.Interview.Generate_EMI_Schedule_Summary interview = 
        new Flow.Interview.Generate_EMI_Schedule_Summary(inputs);
    interview.start();
    System.debug('TEST LOG -> Total EMIs: ' + interview.getVariableValue('totalEMIs'));
    System.debug('TEST LOG -> Paid EMIs: ' + interview.getVariableValue('paidEMIs'));
    System.debug('TEST LOG -> Pending EMIs: ' + interview.getVariableValue('pendingEMIs'));
    System.debug('TEST LOG -> Next Due Date: ' + interview.getVariableValue('nextdueDate2'));
} catch (Exception e) {
    System.debug('TEST LOG -> Error: ' + e.getMessage() + ' | StackTrace: ' + e.getStackTraceString());
}
