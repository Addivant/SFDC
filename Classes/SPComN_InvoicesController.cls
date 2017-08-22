public class SPComN_InvoicesController {
    
    public List<InvoiceWrapper> wrappedInvoicesList {get; set;}
        
        public SPComN_InvoicesController(){
            List<bthousetracker__Bill__c> invoices = [ SELECT Id, bthousetracker__Bill__c, 
                                                      bthousetracker__Status__c, bthousetracker__Bill_Date__c, 
                                                      bthousetracker__Purchase_Order__c,
                                                      bthousetracker__Purchase_Order__r.bthousetracker__PO__c,
                                                      bthousetracker__Project__r.Name,
                                                      bthousetracker__Ship_Id__c, bthousetracker__Ship_Id__r.bthousetracker__Ship_Id__c,
                                                      bthousetracker__Ship_Id__r.bthousetracker__Ship_Date__c,
                                                      bthousetracker__Ship_Id__r.bthousetracker__Ship_To__c,
                                                      bthousetracker__Ship_Id__r.bthousetracker__Freight__c,
                                                      bthousetracker__Ship_Id__r.bthousetracker__Builder_Account__r.Name,
                                                      bthousetracker__Project__c, bthousetracker__Total__c
                                                      FROM bthousetracker__Bill__c
                                                      ORDER BY bthousetracker__Bill_Date__c ASC
                                                      LIMIT 5000];
            if(invoices.size() > 0){
                
                wrappedInvoicesList = new List<InvoiceWrapper>();
                for(bthousetracker__Bill__c invoice : invoices){
                    InvoiceWrapper invoiceWrapperRecord = InvoiceHelper.parseToInvoiceWrapper(invoice);
                    wrappedInvoicesList.add(invoiceWrapperRecord);
                }
            }
        }
}