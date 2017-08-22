/*
    Purpose : Controller class for Product Detail page
*/

public Class SPComN_DoorProductDetailCntrl{
    public String supplierId {get; set;}
    public String catalogName {get; set;}
    public Boolean filledRequiredFields {get; set;}
    public String catalogId {get; set;}
    public String partId {get; set;}
    public String partType {get; set;}

    public SPComN_DoorProductDetailCntrl(){
        supplierId = SPComN_Utils.getSupplierAccount();
        catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        String productId = Apexpages.currentPage().getParameters().get('productId');

        if(String.isNotBlank(catalogId))
            catalogName = SPComN_Utils.getCatalogName(catalogId);
            
        if(String.isNotBlank(productId)){   
            partId = productId;
            filledRequiredFields = checkForRequiredInputs(productId);
        }
        
        partType = 'Product';
    }
   
    /*
        @ Purpose     : Method to check whether all products have all is child records .
        @ Parameter   : ProductId.
        @ Return Type : Boolean.      
    */
    public Static Boolean checkForRequiredInputs(String productId){
        bthousetracker__Supplier_Door_Products__c currentProduct;
        try{
            currentProduct  = [SELECT Id, Name,
                                      (SELECT Id FROM bthousetracker__Supplier_Pricing_Tables__r WHERE bthousetracker__Status__c != 'Archive' OR bthousetracker__Status__c != 'Deleted' LIMIT 1), 
                                      (SELECT Id FROM bthousetracker__Lead_Times__r LIMIT 1),
                                      (SELECT Id FROM bthousetracker__Supplier_Products_Components__r LIMIT 1)
                               FROM bthousetracker__Supplier_Door_Products__c 
                               WHERE Id =: productId];
        }catch(Exception ex){
            system.debug('exception : '+ex.getMessage());
        }
      
        
        if(currentProduct != null && 
           currentProduct.bthousetracker__Supplier_Pricing_Tables__r != null && !currentProduct.bthousetracker__Supplier_Pricing_Tables__r.isEmpty() && 
           currentProduct.bthousetracker__Lead_Times__r != null && !currentProduct.bthousetracker__Lead_Times__r.isEmpty() && 
           currentProduct.bthousetracker__Supplier_Products_Components__r != null && !currentProduct.bthousetracker__Supplier_Products_Components__r.isEmpty()){
               
        
            return true;   
        }
        return false;  
    }
    
    /*
        @ Purpose     : Method to get product details with respect to given product Id.
        @ Parameter   : Product Id.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getCurrentProduct(String productId, String supplierId){
        bthousetracker__Supplier_Door_Products__c catalogProduct;

        if(String.isNotBlank(productId) && String.isNotBlank(supplierId)){
            
            String query = 'SELECT Id, Name, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, bthousetracker__Warranty__c, bthousetracker__Effective_Date__c, bthousetracker__Man_Lead_Times__c, bthousetracker__Supplier__c , bthousetracker__Supplier_Part__c, bthousetracker__isLocked__c, ' + 
                                  'bthousetracker__BBNA_Status__c, CreatedDate, bthousetracker__Approval_Status__c, bthousetracker__Cost__c, bthousetracker__Sourcing_Facility__c, bthousetracker__Status__c, bthousetracker__Active_Leafs__c, bthousetracker__Active_Leafs_Picklist__c, ' + 
                                  'bthousetracker__UOM__c, bthousetracker__Type__c, bthousetracker__Assembly__c, bthousetracker__Rating__c, bthousetracker__Series__c, bthousetracker__Sub_Category__c, bthousetracker__Door_Size__c, bthousetracker__Active_Date__c, ' + 
                                  'bthousetracker__Weight__c, bthousetracker__Paint_Color__c, bthousetracker__Paint_Type__c, bthousetracker__Lead_Time__c, bthousetracker__Markup__c, bthousetracker__Archived_Date__c, bthousetracker__Deactivate_Date__c, ' + 
                                  'bthousetracker__Supplier_Product_Catalog__r.Name, bthousetracker__Under_Approval__c,bthousetracker__Level_C__c, bthousetracker__Level_B__c, bthousetracker__Level_2__c, bthousetracker__Level_1__c, bthousetracker__Supplier_Door_Products__c.bthousetracker__Product_Category__c';
            
            Map<String, String> mapProposedFields = SPComN_Utils.getMapProposedFields();                    
            for(String currentField : mapProposedFields.values()){
                query += ', ' + currentField;
            }
                                
            query += ' FROM bthousetracker__Supplier_Door_Products__c WHERE Id =: productId AND bthousetracker__Supplier__c =: supplierId';
            System.debug('query'+ query );     
            try{                         
                catalogProduct = Database.query(query);
                System.debug('catalogProduct'+ catalogProduct);
                return new SPComN_Wrapper.Response(true,'Success in getting records', new SPComN_Wrapper.ProductInfoWrapper(catalogProduct), null);

            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false, 'Error: in fetching product details' + ex.getMessage(), null, null);
            }
        }
        return new SPComN_Wrapper.Response(false,'Error: in fetching product details..' ,null, null);
    }
    
     
    /*
        @ Purpose     : Method to get pricing details with respect to given product Id.
        @ Parameter   : ProductId, supplierId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getPricingTable(String productId, String supplierId) {
        List<bthousetracker__Supplier_Pricing_Table__c> pricingTableRecLst = new List<bthousetracker__Supplier_Pricing_Table__c>();
        List<SPComN_Wrapper.PricingWrapper> PricingTableWrapperList = new List<SPComN_Wrapper.PricingWrapper>();
        
        if(String.isNotBlank(productId) && String.isNotBlank(supplierId)) {
            try{
                pricingTableRecLst  = [SELECT Id, bthousetracker__Cost__c, bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c, bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c, bthousetracker__Supplier_Product__c, 
                                              bthousetracker__Supplier_Tier__r.bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Tier__r.bthousetracker__Supplier_Zone__r.Name, bthousetracker__Supplier_Zone__c,
                                              bthousetracker__Supplier_Zone__r.Name, bthousetracker__Effective_Date__c, bthousetracker__Zone__c, bthousetracker__Status__c, bthousetracker__Under_Approval__c, bthousetracker__Supplier_Status__c ,
                                              bthousetracker__Supplier_Product__r.bthousetracker__Effective_Date__c, bthousetracker__Supplier_Product__r.bthousetracker__BBNA_Status__c,
                                              bthousetracker__Supplier_Product__r.bthousetracker__isLocked__c
                                       FROM bthousetracker__Supplier_Pricing_Table__c 
                                       WHERE bthousetracker__Supplier_Product__c  =: productId
                                       AND bthousetracker__Supplier__c =:supplierId AND bthousetracker__Status__c != 'Deleted' AND bthousetracker__Status__c != 'Archive' AND bthousetracker__Cloned_From__c = null];
                //return new SPCom_Wrapper.Response(false, 'Success: In get Pricing Details',  pricingTableRecLst);
            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false, 'Error: in fetching Pricing details' + ex.getMessage(), null);
            }
            
            for(bthousetracker__Supplier_Pricing_Table__c  pricingRec : pricingTableRecLst){
                
                SPComN_Wrapper.PricingWrapper pricingWrap = new SPComN_Wrapper.PricingWrapper(pricingRec);

                pricingWrap.effectiveDate = pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Effective_Date__c != null ? pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Effective_Date__c.format() : '';
                pricingWrap.approvalStatus = pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__BBNA_Status__c != null ? pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__BBNA_Status__c : '';
                pricingWrap.isLocked = pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__isLocked__c != null ? pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__isLocked__c : false;
                
                if(pricingRec.bthousetracker__Supplier_Zone__c == null){
                    pricingWrap.zone = new SPComN_Wrapper.ZoneWrapper();
                    pricingWrap.zone.name = 'All';
                }
                
                 if(pricingRec.bthousetracker__Supplier_Tier__r == null){
                    pricingWrap.tier = new SPComN_Wrapper.TierWrapper();
                    pricingWrap.tier.minQty = '0';
                    pricingWrap.tier.maxQty = 'Max';
                }
                
               
                 
                PricingTableWrapperList.add(pricingWrap);
            }
            
            return new SPComN_Wrapper.Response(true, 'Success: In get Pricing Details',  PricingTableWrapperList);
            
        }
        return new SPComN_Wrapper.Response(false, 'Error: in fetching Pricing details', null);
    }
    
    
     /*
        @ Purpose     : Method to get ProductComponent[Assigned Component] details with respect to given productId.
        @ Parameter   : ProductId, supplierId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getProductsNComponents(String productId, String supplierId) {
        List<bthousetracker__Supplier_Products_Components__c> productNCompList;
        List<SPComN_Wrapper.ProductCompWrapper> ProductCompWrapperList = new List<SPComN_Wrapper.ProductCompWrapper>();

        if(String.isNotBlank(productId)) {
           try{
               
               productNCompList = [SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Supplier_Product__c,  bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c,                         
                                           bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, 
                                           bthousetracker__Supplier_Component__r.Name, bthousetracker__Default__c, bthousetracker__Status__c, bthousetracker__Supplier_Component__r.bthousetracker__Status__c 
                                    FROM bthousetracker__Supplier_Products_Components__c
                                    WHERE bthousetracker__Supplier_Product__c =: productId  
                                    AND bthousetracker__Supplier__c =: supplierId AND bthousetracker__Status__c != 'Deleted'];
                                    
               //return new SPCom_Wrapper.Response(false, 'Success: In getting Assiggned Components Details',  productNCompList);
            }catch(Exception ex){
               return new SPComN_Wrapper.Response(false, 'Error: in fetching Assiggned Components details' + ex.getMessage(), null);
            }
            
            for(bthousetracker__Supplier_Products_Components__c proCmpRec : productNCompList){
                ProductCompWrapperList.add(new SPComN_Wrapper.ProductCompWrapper(proCmpRec));            
            }
            
            return new SPComN_Wrapper.Response(true, 'Success: In getting Assiggned Components Details',  ProductCompWrapperList);
        }
        return new SPComN_Wrapper.Response(false, 'Error: in fetching Assiggned Components details', null);
    } 
    
     /*
        @ Purpose     : Method to get ProductComponent[Assigned Component] details with respect to given productId.
        @ Parameter   : ProductId, supplierId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getLeadTimes(String productId){
        List<bthousetracker__Lead_Time__c> leadTimesList; 
        List<SPComN_Wrapper.LeadTimeWrapper> LeadTimeWrapperList = new List<SPComN_Wrapper.LeadTimeWrapper>();
        if(String.isNotBlank(productId)){
            try{
                leadTimesList = [SELECT  Name, bthousetracker__Lead_Time__c, bthousetracker__Man_Lead_Time__c, bthousetracker__Sourcing_Facility__c, bthousetracker__Supplier_Door_Product__c,
                                         bthousetracker__Supplier_Door_Product__r.Name, bthousetracker__Sourcing_Facility_Single__c, bthousetracker__Supplier_Door_Product__r.bthousetracker__Door_Description__c,
                                         bthousetracker__Supplier_Door_Product__r.bthousetracker__Internal_Part_Number__c
                                 FROM bthousetracker__Lead_Time__c 
                                 WHERE  bthousetracker__Supplier_Door_Product__c=:productId];
               
                //return new SPCom_Wrapper.Response(false, 'Success: In getting Lead Time Details',  leadTimesList);
            }catch(exception ex){
                return new SPComN_Wrapper.Response(false, 'Error: in fetching Lead Time details' + ex.getMessage(), null);
            }
            
            for(bthousetracker__Lead_Time__c leadTimeRec : leadTimesList){
                LeadTimeWrapperList.add(new SPComN_Wrapper.LeadTimeWrapper(leadTimeRec));            
            }
            
            return new SPComN_Wrapper.Response(true, 'Success: In getting Lead Time Details',  LeadTimeWrapperList);
        }
        return new SPComN_Wrapper.Response(false, 'Error: in fetching Lead Time details', null);
    }
    
     /*
        @ Purpose     : Method to get purchase Order recordse.
        @ Parameter   : None.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getImpactedOrders(){
        return SPComN_Utils.getImpactedOrders();   
    } 
    
    /*
        @ Purpose     : Method to deactivate Product.
        @ Parameter   : recordId, jsonData.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response requestForDelete(String recordId, String jsonData){
        return SPComN_CatalogProductPageCntrl.requestForDelete(recordId, jsonData);     
    }
    
     /*
        @ Purpose     : Method to get Component Types records.
        @ Parameter   : supplierId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getComponetTypes(String supplierId){
        return SPComN_Utils.getComponetTypes(supplierId);
    }
    
    /*
        @ Purpose     : Method to redirect SPComN_CatalogComponentsPage to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public Static PageReference redirectToCatCompPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');
        String componentTypeId1 = Apexpages.currentPage().getParameters().get('componentTypeId');
        System.debug('!!!!!'+ Apexpages.currentPage().getParameters().get('componentTypeId'));
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);
            
        if(String.isNotBlank(componentTypeId1))
            paramMap.put('componentTypeId',componentTypeId1);

        return SPComN_Utils.routeTo('SPComN_CatalogComponentsPage', paramMap);
    }
    
     /*
        @ Purpose     : Method to redirect to SPComN_CatalogProductPage page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToCatProductPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');

        
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);

        return SPComN_Utils.routeTo('SPComN_CatalogProductPage', paramMap);
    }
    
     /*
        @ Purpose     : Method to submit product for approval.
        @ Parameter   : productId, effectiveDate.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response sendProductForApproval(String productId, String effectiveDate){
        if(String.isNotBlank(productId)){
            try{
                bthousetracker__Supplier_Door_Products__c product = [SELECT Id, bthousetracker__Effective_Date__c, Name 
                                                     FROM bthousetracker__Supplier_Door_Products__c 
                                                     WHERE Id =: productId];
                //product.Effective_Date__c = date.parse(effectiveDate);
                if(String.isNotBlank(effectiveDate))
                    product.bthousetracker__Effective_Date__c = Date.parse(effectiveDate);
                    
                update product;
                
                Boolean result = SPComN_Utils.requestApproval('', productId);//First parameter is supplierId.
                
                if(result){
                    return new SPComN_Wrapper.Response(true, 'Request has been submitted',product, null);
                }else{
                    return new SPComN_Wrapper.Response(false, 'Failed to request', null, null);
                }
            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false, 'Failed to request : '+ ex.getMessage(), null, null);
            }
        }
        return new SPComN_Wrapper.Response(false, 'Product Id not present', null, null);
    }
    
    /*
      @ Purpose     : Method to discard[delete] record.
      @ Parameter   : recordId.
      @ Return Type : SPCom_Wrapper.Response.
    */
   @remoteAction
   public static SPComN_Wrapper.Response discardProduct(String recordId){  
      return SPComN_Utils.discardRecord(recordId, 'bthousetracker__Supplier_Door_Products__c');
   }
   
    /*
      @ Purpose     : Method to Withdraw record.
      @ Parameter   : recordId,.
      @ Return Type : SPCom_Wrapper.Response.
    */
   @remoteAction
   public static SPComN_Wrapper.Response withdrawProduct(String recordId){ 
      
       if(String.isNotBlank(recordId)){
           try{
               bthousetracker__Supplier_Door_Products__c productRec = [SELECT Id, bthousetracker__BBNA_Status__c, bthousetracker__isLocked__c
                                                                       FROM bthousetracker__Supplier_Door_Products__c 
                                                                       WHERE Id =: recordId];
              
               //SPComN_Utils.unlockProduct(new List<bthousetracker__Supplier_Door_Products__c>{productRec});
               SPComN_Utils.unlockApproval(productRec.id);
               productRec.bthousetracker__isLocked__c = false;
               productRec.bthousetracker__BBNA_Status__c = 'Withdrawn';
               
               upsert productRec;
               return new SPComN_Wrapper.Response(true, 'Success: In getting Record', productRec, null);                                                          
                                                                       
           }catch(Exception ex){
               return new SPComN_Wrapper.Response(false, 'Error: In getting Record'+ ex.getMessage(), null, null);
           }    
       }
       return new SPComN_Wrapper.Response(false, 'Error: Record Id not present', null, null); 
   }
   
    /*
        @ Purpose     : Method to update pricing for product.
        @ Parameter   : records[list of Catalogs to edit].
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response updatePricings(String records){
        List<bthousetracker__Supplier_Pricing_Table__c> pricingList = new List<bthousetracker__Supplier_Pricing_Table__c>();
        List<SPComN_Wrapper.PricingWrapper> PricingWrapperList = (List<SPComN_Wrapper.PricingWrapper>)JSON.deserialize(records, List<SPComN_Wrapper.PricingWrapper>.class);
        System.debug('@@@@@' + PricingWrapperList);
        for(SPComN_Wrapper.PricingWrapper currRec : PricingWrapperList){
            bthousetracker__Supplier_Pricing_Table__c pricingRec = new bthousetracker__Supplier_Pricing_Table__c();
            
            pricingRec.Id = currRec.id;
            pricingRec.bthousetracker__Type__c = 'Product';            
            if(String.isNotBlank(currRec.proposedCost)){
                pricingRec.bthousetracker__Cost__c =  Decimal.valueOf(currRec.proposedCost);
            }/*else{
                pricingRec.bthousetracker__Cost__c = pricingRec.bthousetracker__Cost__c;
            }*/
            pricingList.add(pricingRec);
        }
        
        try{
            upsert pricingList;
            return new SPComN_Wrapper.Response(true, 'Changes saved',  pricingList);
        }catch(Exception ex){
            System.debug('Exception is'+ ex.getMessage());  
            return new SPComN_Wrapper.Response(false, ex.getMessage() , null);      
        }
        return new SPComN_Wrapper.Response(false, 'Error in saving', null);
    }
    
    /*
        @ Purpose     : Method to update lead time for product.
        @ Parameter   : records[list of Catalogs to edit].
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response updateLeadTime(String records){
        List<bthousetracker__Lead_Time__c> leadTimeList = new List<bthousetracker__Lead_Time__c>();
        List<SPComN_Wrapper.LeadTimeWrapper> LeadTimeWrapperList = (List<SPComN_Wrapper.LeadTimeWrapper>)JSON.deserialize(records, List<SPComN_Wrapper.LeadTimeWrapper>.class);
        
        for(SPComN_Wrapper.LeadTimeWrapper  currRec : LeadTimeWrapperList){
            bthousetracker__Lead_Time__c leadTimeRec = new bthousetracker__Lead_Time__c();            
                        
            if(String.isNotBlank(currRec.newDays)){
                leadTimeRec.Id = currRec.id;
                leadTimeRec.bthousetracker__Man_Lead_Time__c = Decimal.valueOf(currRec.newDays);
            }
            leadTimeList.add(leadTimeRec);
        }
        
        try{
            upsert leadTimeList;
            return new SPComN_Wrapper.Response(true, 'Changes saved',  leadTimeList);
        }catch(Exception ex){
            System.debug('Exception is'+ ex.getMessage());  
            return new SPComN_Wrapper.Response(false, ex.getMessage() , null);      
        }
        return new SPComN_Wrapper.Response(false, 'Error in saving', null);
    }
    
    /*
    */
    @remoteAction
    public static SPComN_Wrapper.Response sendApproval(String pricingJson, String effectiveDate, String supplierId, String productId){
        
        SPComN_Wrapper.Response result = updatePricings(pricingJson);        
        
        if(result.issuccess){
            List<SPComN_Wrapper.PricingWrapper> listPricingsWrap = (List<SPComN_Wrapper.PricingWrapper>) JSON.deserialize(pricingJson, List<SPComN_Wrapper.PricingWrapper>.class); 
            
            if(String.isNotBlank(productId)){
            
                bthousetracker__Supplier_Door_Products__c product;
                System.debug('productId' + productId); 
                               
                try{    
                    product = [SELECT Id, 
                                        Name, 
                                        bthousetracker__Effective_Date__c 
                                FROM bthousetracker__Supplier_Door_Products__c 
                                WHERE Id =: productId];
                                
                   if(String.isNotBlank(effectiveDate))
                       product.bthousetracker__Effective_Date__c = date.valueOf(effectiveDate);
                                 
                }catch(Exception ex){
                
                }   
                              
                try{
                    Update product;
                    SPComN_Utils.requestApproval(supplierId, product.Id);
                    SPComN_Wrapper.Response pricingResult  = getPricingTable(product.Id, supplierId); 
                    return new SPComN_Wrapper.Response(true,'Request has been submitted.', pricingResult.records);
                }catch(Exception ex){
                    System.debug('exception!!!'+ex.getMessage());
                    return new SPComN_Wrapper.Response(false,'Error '+ ex.getMessage(), null);
                }
            }                                                
        }    
        
        return result;            
    }
   
   /*
        @ Purpose     : Method to redirect SPComN_CatalogDetailPage to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public Static PageReference redirectToCatDetailPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');
        String status1 = Apexpages.currentPage().getParameters().get('status');
        
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);
        
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);           

        return SPComN_Utils.routeTo('SPComN_CatalogDetailPage', paramMap);
    }
    
    /*
    @ Purpose     : Method to get Products history for given product.
    @ Parameter   : productId.
    @ Return Type : SPCom_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response getProductsHistory(String productId){
        System.debug('^^^^' + productId);
        if(String.isNotBlank(productId)){
    
            Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
            List<SPComN_CatalogDetailPageCntrl.historyInfoWrapper> historyInfoWrapperList = new List<SPComN_CatalogDetailPageCntrl.historyInfoWrapper>();
            
            bthousetracker__Supplier_Door_Products__c supplierDoorProductsRec = [SELECT Id, Name, 
                                                                                        bthousetracker__Status__c         
                                                                                 FROM bthousetracker__Supplier_Door_Products__c
                                                                                 WHERE Id =: productId];
                     
            
            // Get the Supplier Door Products records 
            getSupplierDoorProductsHistory(productId,dateTimeStrMap);
            
            // Get the Supplier Products Components records 
            getSupplierProductsComponentsHistory(productId,dateTimeStrMap);
            
            // Get the Lead Time records 
            getLeadTimeHistory(productId,dateTimeStrMap);
            
            // Get the Supplier Pricing Table records 
            getSupplierPricingTableHistory(productId,dateTimeStrMap);
            List<ProcessInstance> ProcessInstanceList = new List<ProcessInstance>();
            
            if(supplierDoorProductsRec.bthousetracker__Status__c != 'Pending'){
                ProcessInstanceList = [SELECT Id, TargetObjectId, Status, 
                                               TargetObject.type, CompletedDate, 
                                               CreatedDate, SubmittedBy.Name, 
                                               LastActor.Name
                                       FROM ProcessInstance 
                                       WHERE TargetObjectId =: productId 
                                       ORDER BY CreatedDate DESC
                                       LIMIT 5];
            
            }
            
            if(!ProcessInstanceList.isEmpty()){
                getApprovalHistroy(productId,ProcessInstanceList,dateTimeStrMap);
            }
            
            List<DateTime> toSortDateDecList = new List<DateTime>(); 
            
            if(!dateTimeStrMap.isEmpty()){
            
                List<DateTime> toSortDateTimeList = new List<DateTime>();
                
                toSortDateTimeList.addAll(dateTimeStrMap.keySet());
                toSortDateTimeList.sort();
                                
                //Sort List in decenfing order
                for(Integer i = toSortDateTimeList.size()-1; i>=0;i--){
                    toSortDateDecList.add(toSortDateTimeList.get(i));
                }
                
               
                //Get top 5 recent history for parts
                for(Integer i=0; i<toSortDateDecList.size();i++){
                    SPComN_CatalogDetailPageCntrl.historyInfoWrapper historyInfoWrapperRec = new SPComN_CatalogDetailPageCntrl.historyInfoWrapper();
                    if(i<5){
                        historyInfoWrapperRec.historydate = toSortDateDecList.get(i).format();
                        historyInfoWrapperRec.historyStr = dateTimeStrMap.get(toSortDateDecList.get(i));
                        historyInfoWrapperList.add(historyInfoWrapperRec);
                    }
                }
                
            }
            
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response(true, 'Successful: In getting product histroy', historyInfoWrapperList);
            return response ;
        }
        return new SPComN_Wrapper.Response(false, 'Error: In getting histroy product not present', null);   
    }
    
    public static void getApprovalHistroy(String productId, List<ProcessInstance> ProcessInstanceList, Map<DateTime, String> dateTimeStrMap){
        bthousetracker__Supplier_Door_Products__c supplierDoorProductsRec = [SELECT Id, Name, CreatedDate, LastModifiedDate, 
                                                                                    bthousetracker__Product_Category__c, 
                                                                                    bthousetracker__Supplier_Part__c,
                                                                                    bthousetracker__Status__c,
                                                                                    bthousetracker__isDelete__c,
                                                                                    CreatedBy.Name 
                                                                            FROM bthousetracker__Supplier_Door_Products__c
                                                                            WHERE Id =: productId];
      
        String historyStr; 
        
        if(supplierDoorProductsRec != null){                                                                                                              
            for(ProcessInstance currRec : ProcessInstanceList){
    
                if(supplierDoorProductsRec.bthousetracker__isDelete__c != true){
                    if(supplierDoorProductsRec.bthousetracker__Status__c == 'Active'){
                        if(currRec.Status != 'Pending'){
    
                            historyStr = currRec.LastActor.Name +' '+ currRec.Status + 
                                         ' part #' + supplierDoorProductsRec.bthousetracker__Supplier_Part__c;       
                            dateTimeStrMap.put(currRec.CompletedDate, historyStr);           
    
                        }else{
    
                            historyStr = currRec.SubmittedBy.Name +' has submitted part #' + 
                                         supplierDoorProductsRec.bthousetracker__Supplier_Part__c;  
                            dateTimeStrMap.put(currRec.CreatedDate, historyStr);
    
                        }
                    }else{
                        if(currRec.Status != 'Pending'){
    
                            historyStr = currRec.LastActor.Name +' '+ currRec.Status + 
                                         'pricing update';       
                            dateTimeStrMap.put(currRec.CompletedDate, historyStr);           
    
                        }else{
    
                            historyStr = currRec.SubmittedBy.Name +' has submitted part #' + 
                                         supplierDoorProductsRec.bthousetracker__Supplier_Part__c +' for pricing update';  
                            dateTimeStrMap.put(currRec.CreatedDate, historyStr);
    
                        }
                    }
                }else{
             
                    if(currRec.Status != 'Pending'){
                   
                        historyStr = currRec.LastActor.Name +' '+ currRec.Status + ' deactivation of part #' + 
                                     supplierDoorProductsRec.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(currRec.CompletedDate, historyStr);
                      
                    }else{
                  
                        historyStr = currRec.SubmittedBy.Name +' has submitted part #' + 
                                     supplierDoorProductsRec.bthousetracker__Supplier_Part__c+' for deactivation';
                        dateTimeStrMap.put(currRec.CreatedDate, historyStr);
                      
                    }
                }
                
            }
        }                                                                                                               
    }


    private static void getSupplierDoorProductsHistory(String productId, Map<DateTime, String> dateTimeStrMap){
        if(String.isNotBlank(productId)){
            String historyStr;
            try{
                //fetch the Supplier Door Products history
                bthousetracker__Supplier_Door_Products__c supplierDoorProductsRec = 
                    
                                                            [SELECT Id, Name, CreatedDate, LastModifiedDate, 
                                                                    bthousetracker__Product_Category__c, 
                                                                    bthousetracker__Supplier_Part__c,
                                                                    CreatedBy.Name,
                                                                    LastModifiedBy.Name 
                                                            FROM bthousetracker__Supplier_Door_Products__c
                                                            WHERE Id =: productId];
                if(supplierDoorProductsRec != null) {
                
                    historyStr = supplierDoorProductsRec.CreatedBy.Name + ' Created part# ' + 
                                 supplierDoorProductsRec.bthousetracker__Supplier_Part__c;
                    dateTimeStrMap.put(supplierDoorProductsRec.CreatedDate, historyStr);
                    
                    System.debug('get info $$$' + dateTimeStrMap);
                    
                    if(supplierDoorProductsRec.LastModifiedDate != supplierDoorProductsRec.CreatedDate){
                        
                        historyStr = supplierDoorProductsRec.LastModifiedBy.Name + ' updated part# ' + 
                                     supplierDoorProductsRec.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(supplierDoorProductsRec.LastModifiedDate , historyStr);
                        System.debug('get info $$$' + dateTimeStrMap);
                    }   
                } 
                System.debug('get info $$$' + dateTimeStrMap);                                                  
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }                                                   
        }   
    }

    private static void getSupplierProductsComponentsHistory(String productId, Map<DateTime, String> dateTimeStrMap){
        String historyStr;
        if(String.isNotBlank(productId)){
            try{
                //fetch the Supplier Products Components history
                for(bthousetracker__Supplier_Products_Components__c supplierProductsComponentsRec :[SELECT Id, Name,
                                                                                                           CreatedDate, LastModifiedDate, 
                                                                                                           bthousetracker__Supplier_Product__c,
                                                                                                           CreatedBy.Name, 
                                                                                                           LastModifiedBy.Name
                                                                                                    FROM bthousetracker__Supplier_Products_Components__c
                                                                                                    WHERE bthousetracker__Supplier_Product__c =: productId
                                                                                                    ORDER BY LastModifiedDate DESC
                                                                                                    LIMIT 5]){
                                                                    
                    if(supplierProductsComponentsRec.CreatedDate == supplierProductsComponentsRec.LastModifiedDate){  
                                                                    
                        historyStr = supplierProductsComponentsRec.CreatedBy.Name + ' Created assigned component for part# ' + 
                                     supplierProductsComponentsRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(supplierProductsComponentsRec.LastModifiedDate, historyStr);
                        
                    }else{
                    
                       historyStr = supplierProductsComponentsRec.LastModifiedBy.Name + ' updated assigned component for part# ' + 
                                     supplierProductsComponentsRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c;
                       dateTimeStrMap.put(supplierProductsComponentsRec.LastModifiedDate, historyStr);
                                           
                    }     
                }
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }   
        }   
    }   

    private static void getLeadTimeHistory(String productId, Map<DateTime, String> dateTimeStrMap){
        String historyStr;
        if(String.isNotBlank(productId)){
            try{
                //fetch the Supplier Lead Time history
                for(bthousetracker__Lead_Time__c leadTimeRec : 
                
                                                    [SELECT Id, 
                                                            Name, 
                                                            bthousetracker__Supplier_Door_Product__c, 
                                                            bthousetracker__Supplier_Component__c, 
                                                            bthousetracker__Lead_Time__c, 
                                                            LastModifiedBy.Name,
                                                            CreatedDate, 
                                                            LastModifiedDate,
                                                            CreatedBy.Name,
                                                            bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c 
                                                    FROM bthousetracker__Lead_Time__c
                                                    WHERE bthousetracker__Supplier_Door_Product__c =: productId
                                                    ORDER BY LastModifiedDate DESC
                                                    LIMIT 5]){
                                                    
                    if(leadTimeRec.CreatedDate == leadTimeRec.LastModifiedDate){
                                                                      
                        historyStr = leadTimeRec.CreatedBy.Name + ' Created LeadTimes for part# ' + 
                                     leadTimeRec.bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(leadTimeRec.CreatedDate, historyStr);
                        
                    }else{
                    
                         historyStr = leadTimeRec.LastModifiedBy.Name + ' updated LeadTimes for part# ' + 
                                      leadTimeRec.bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(leadTimeRec.LastModifiedDate, historyStr);
                        
                    }    
                }
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }
        }   
    }   
 
    private static void getSupplierPricingTableHistory(String productId, Map<DateTime, String> dateTimeStrMap){
        String historyStr;
        if(String.isNotBlank(productId)){
            try{
                
                for(bthousetracker__Supplier_Pricing_Table__c supplierPricingTableRec : 
                
                                                    [SELECT Id, Name, bthousetracker__Supplier_Product__c, 
                                                            CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name 
                                                    FROM bthousetracker__Supplier_Pricing_Table__c
                                                    WHERE bthousetracker__Supplier_Product__c =: productId
                                                    ORDER BY LastModifiedDate DESC
                                                    LIMIT 5]){
                                                    
                    if(supplierPricingTableRec.CreatedDate ==  supplierPricingTableRec.LastModifiedDate){  
                                                                    
                        historyStr = supplierPricingTableRec.CreatedBy.Name + ' Created Pricing for part# ' + 
                                     supplierPricingTableRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(supplierPricingTableRec.CreatedDate, historyStr);
                        
                    }else{
                    
                         historyStr = supplierPricingTableRec.LastModifiedBy.Name + ' updated Pricing for part# ' + 
                                     supplierPricingTableRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c;
                        dateTimeStrMap.put(supplierPricingTableRec.LastModifiedDate, historyStr);
                    
                    }    
                }
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }
        }   
    }   
}