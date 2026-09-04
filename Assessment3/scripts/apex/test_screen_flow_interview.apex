try {
    Map<String, Object> inputs = new Map<String, Object>{
        'recordId' => 'a0CNS00002oUe3q2AC'
    };
    Flow.Interview interview = Flow.Interview.createInterview('Show_Loan_Account_Summary', inputs);
    interview.start();
    System.debug('Screen flow started successfully: ' + interview);
} catch (Exception ex) {
    System.debug('Screen flow interview exception: ' + ex.getMessage());
}
