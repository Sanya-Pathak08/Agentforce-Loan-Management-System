Map<String, Object> inputs = new Map<String, Object>{
    'loanApplicationId' => 'LA-00001'
};

try {
    Flow.Interview.Check_Loan_Application_Status interview = 
        new Flow.Interview.Check_Loan_Application_Status(inputs);
    interview.start();
    System.debug('TEST LOG -> Status: ' + interview.getVariableValue('applicationStatus'));
    System.debug('TEST LOG -> Reason: ' + interview.getVariableValue('rejectionReason'));
} catch (Exception e) {
    System.debug('TEST LOG -> Error: ' + e.getMessage() + ' | StackTrace: ' + e.getStackTraceString());
}
