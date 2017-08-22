/*
    @ Purpose : Controller class for Product catalog page.
    @ Created Date : 28-06-2017.
    
*/

public Class SPComN_ProductCatalogCntrl{
    public String supplierId{get; set;}
    public String catalogId{get; set;}
    
    public SPComN_ProductCatalogCntrl(){
        supplierId = SPComN_Utils.getSupplierAccount();
    }
    
    /*
        @ Purpose     : Method to update product catalogs.
        @ Parameter   : records[list of Catalogs to edit].
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response updateCatalogProducts(String records){
        List<bthousetracker__Supplier_Product_Catalog__c> catalogsList = new List<bthousetracker__Supplier_Product_Catalog__c>();
        List<SPComN_Wrapper.ProdCatalogWrapper> ProdCatalogWrapperList = (List<SPComN_Wrapper.ProdCatalogWrapper>)JSON.deserialize(records, List<SPComN_Wrapper.ProdCatalogWrapper>.class);
        
        for(SPComN_Wrapper.ProdCatalogWrapper currRec : ProdCatalogWrapperList){
            bthousetracker__Supplier_Product_Catalog__c catalogRec = new bthousetracker__Supplier_Product_Catalog__c();
            
            catalogRec.Id = currRec.id;
            catalogRec.Name = currRec.name;
            
            if(String.isNotBlank(currRec.activeDate)){
                catalogRec.bthousetracker__Activate_Date__c =  Date.parse(currRec.activeDate);
            }
            catalogsList.add(catalogRec);
        }
        
        try{
            upsert catalogsList;
            return new SPComN_Wrapper.Response(true, 'Changes saved',  catalogsList);
        }catch(Exception ex){
            System.debug('Exception is'+ ex.getMessage());  
            return new SPComN_Wrapper.Response(false, ex.getMessage() , null);      
        }
        return new SPComN_Wrapper.Response(false, 'Error in saving', null);
    }
      
    
    /*
        @ Purpose     : Method to get Catalogs with respect to status and category.
        @ Parameter   : supplierId, Status, category.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getCatalogs(String supplierId, String status, String category) {
        List<SPComN_Wrapper.ProdCatalogInfoWrapper> proCatalogWrapperList = new List<SPComN_Wrapper.ProdCatalogInfoWrapper>();  
        List<bthousetracker__Supplier_Product_Catalog__c> catalogsList = new List<bthousetracker__Supplier_Product_Catalog__c>();

        if(String.isNotBlank(supplierId)){
            String query = 'SELECT Id, Name, bthousetracker__BBNA_Product_Category__r.Name, bthousetracker__Under_Approval__c, CreatedBy.Name, LastModifiedBy.Name, bthousetracker__BBNA_Product_Category__c, bthousetracker__Status__c,bthousetracker__Active_Date__c, bthousetracker__Activate_Date__c, bthousetracker__Archived_Date__c' +
                           ' FROM bthousetracker__Supplier_Product_Catalog__c WHERE ';
                           
            if(String.isNotBlank(status) && !status.equalsIgnoreCase('All') && !status.equalsIgnoreCase('Deleted')) {
                query += 'bthousetracker__Status__c = \'' + status + '\' AND ';
            }else if(!status.equalsIgnoreCase('Deleted')){
                query += 'bthousetracker__Status__c != \'Deleted\' AND ';
            }
            
            System.debug('status '+status);
            if(String.isNotBlank(category)) {
                query += 'bthousetracker__BBNA_Product_Category__c =\'' + category+ '\' AND ';
            }
           
            query += 'bthousetracker__Supplier__c = \'' + supplierId + '\'';
            
            query += 'ORDER BY bthousetracker__Status__c ';
            
            System.debug('query '+query);
            
            try{
                catalogsList = Database.query(query);
            }catch(Exception ex){
                System.debug(ex.getMessage());
                return new SPComN_Wrapper.Response(false,ex.getMessage(), null);
            }
            
            for(bthousetracker__Supplier_Product_Catalog__c currProCatalog : catalogsList){
                proCatalogWrapperList.add(new SPComN_Wrapper.ProdCatalogInfoWrapper(currProCatalog));
            }
            return new SPComN_Wrapper.Response(true, 'Successfully fetched the data',  proCatalogWrapperList);
            
        }
        return new SPComN_Wrapper.Response(false, 'Error in Fetching records', null);
    }
    
    /*
        @ Purpose     : Method to redirect to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToDetailPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status1');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId1');
          
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);

        return SPComN_Utils.routeTo('SPComN_CatalogDetailPage', paramMap);
    }


    /*
        @ Purpose     : Method to send Pending Records for Approval.
        @ Parameter   : CatalogId.
        @ Return Type : SPComN_Wrapper.PageMessage.      
    */  
    @remoteAction
    public static SPComN_Wrapper.Response doApproval(String catalogId) {
        
        if(String.isNotBlank(catalogId)) {        
            bthousetracker__Supplier_Product_Catalog__c catalogRec;
            
            try{
                catalogRec = [SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Status__c, bthousetracker__Activate_Date__c 
                              FROM bthousetracker__Supplier_Product_Catalog__c                                              
                              WHERE Id =: catalogId];
                              
                            
            }catch(Exception ex){                
                System.debug('Exception '+ ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Could not find the catalog.', null); 
            }
            
            if(catalogRec.bthousetracker__Activate_Date__c != null){
                System.debug('catalogId'+ catalogId);
                try { 
                    Boolean isSuccess = SPComN_Utils.requestApproval('', catalogId);
                    if(isSuccess){
                        return new SPComN_Wrapper.Response(true, 'Request has been submitted.', null);
                    }else{
                        return new SPComN_Wrapper.Response(false, 'Failed to request', null);
                    }           
                } catch (Exception ex) {
                    // generic exception handling
                    System.Debug(ex.getMessage()); 
                    return new SPComN_Wrapper.Response(false, 'Failed to request due to the following error : '+ ex.getMessage(), null);
                }
            }else{
                return new SPComN_Wrapper.Response(false, 'Effective date is missing, please fill up effective date for this catalog', null); 
            }
        }
        return new SPComN_Wrapper.Response(false, 'Could not find the catalog.', null);   
    }
    
    /*
        @ Purpose     : Method to Archive catalog record[Delete].
        @ Parameter   : None.
        @ Return Type : Void.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response archiveCatalog(String catalogId) {
        
        if(String.isNotBlank(catalogId)){
            bthousetracker__Supplier_Product_Catalog__c catalog;
            try {
                catalog = [SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Status__c
                            FROM bthousetracker__Supplier_Product_Catalog__c                                              
                            WHERE Id =: catalogId];                                              
            }catch(Exception ex){
                System.debug('Exception' + ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: in fetch catalog details - ' + ex.getMessage()));
            }
            
            if(catalog != null) {
                if(catalog.bthousetracker__Status__c == 'pending') {
                    catalog.bthousetracker__Status__c = 'Deleted';
                    try{
                        update catalog;
                        return new SPComN_Wrapper.Response(true, 'Catalog has been deleted.', null);
                    }catch(Exception ex){
                        System.debug('Exception for delete'+ ex.getMessage());
                        return new SPComN_Wrapper.Response(false, ex.getMessage(), null);
                    }
                }else{
                    return new SPComN_Wrapper.Response(false, 'Only pending catalogs can be deleted.', null);
                }
            }  
        } 
        return new SPComN_Wrapper.Response(false, 'unable to find catalog..', null);                 
    }
    
      /*
        @ Purpose     : Method to clone product catalogs.
        @ Parameter   : records[list of Catalogs to edit].
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response saveCatalog(String catalogToCloneId, String catalogName, String effectiveDate){
       return SPComN_CatalogDetailPageCntrl.saveCatalog(catalogToCloneId, catalogName, effectiveDate);
    }

}