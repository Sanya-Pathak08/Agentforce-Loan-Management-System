EMIScheduleSummaryService.Request req = new EMIScheduleSummaryService.Request();
req.loanAccountId = 'LACC-00001';
try {
    List<EMIScheduleSummaryService.Response> res = EMIScheduleSummaryService.getSummary(new List<EMIScheduleSummaryService.Request>{req});
    System.debug('TEST LOG -> Success! Total: ' + res[0].totalEMIs);
} catch (Exception e) {
    System.debug('TEST LOG -> Exception: ' + e.getMessage());
}
