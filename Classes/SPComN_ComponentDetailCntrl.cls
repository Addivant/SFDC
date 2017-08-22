/**
    Purpose : Controller class for component Detail page.
*/

public Class SPComN_ComponentDetailCntrl{
    public String supplierId {get; set;}
    public String catalogName {get; set;}
    public Static String compTypeId {get; set;}
    public String catalogId {get; set;}
    public String partId {get; set;}
    public String partType {get; set;}

    public SPComN_ComponentDetailCntrl(){
        supplierId = SPComN_Utils.getSupplierAccount();
        catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        
        if(String.isNotBlank(catalogId)){
            catalogName = SPComN_Utils.getCatalogName(catalogId);
        }
        
        String componentId = Apexpages.currentPage().getParameters().get('componentId');
         if(String.isNotBlank(componentId)){   
            partId = componentId;             
        }
        partType = 'Component';
    }
    
    /*
        @ Purpose     : Method to get component details with respect to given component Id.
        @ Parameter   : componentId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getComponentDetails(String componentId){
        bthousetracker__Supplier_Components__c supplierCompRec = new bthousetracker__Supplier_Components__c();
        if(String.isNotBlank(componentId)){
            try {
                supplierCompRec = [SELECT Id, Name, bthousetracker__Status__c, bthousetracker__Active_Date__c, bthousetracker__Archived_date__c, bthousetracker__Effective_Date__c, bthousetracker__Deactivate_Date__c, CreatedDate, 
                                          LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name, bthousetracker__Component_Part__c, bthousetracker__Option_Description__c, bthousetracker__Size__c,
                                          bthousetracker__Attribute1__c, bthousetracker__Attribute2__c, bthousetracker__Pricing_level__c, bthousetracker__isDelete__c, bthousetracker__Approval_level__c, bthousetracker__BBNA_Status__c, 
                                          bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, isLocked__c 
                                   FROM bthousetracker__Supplier_Components__c  
                                   WHERE Id =: componentId];
                return new SPComN_Wrapper.Response(true, 'Success: In fetching component details', new SPComN_Wrapper.ComponentInfoWrapper(supplierCompRec), null );
            }catch(Exception ex){
                System.debug('Exception' + ex);
                return new SPComN_Wrapper.Response(false, 'Error: In fetching component details' + ex.getMessage(), null, null );
            }
        }
        return new SPComN_Wrapper.Response(false, 'Error: In fetching component details', null, null );
    }    
    
     /*
        @ Purpose     : Method to get leadTime records with respect to selected Component.
        @ Parameter   : supplierId, componentId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getLeadTime(String supplierId, String componentId) {
        
        List<SPComN_Wrapper.LeadTimeWrapper> LeadTimeWrapperList = new List<SPComN_Wrapper.LeadTimeWrapper>();
        List<bthousetracker__Lead_Time__c> leadTimeTableRecLst = new List<bthousetracker__Lead_Time__c>();
        if(String.isNotBlank(componentId) && String.isNotBlank(supplierId)) {
            try{
                leadTimeTableRecLst  = [SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Lead_Time__c, 
                                                bthousetracker__Sourcing_Facility_Single__c, bthousetracker__Supplier_Component__c
                                        FROM bthousetracker__Lead_Time__c 
                                        WHERE bthousetracker__Supplier_Component__c=: componentId];
               for(bthousetracker__Lead_Time__c currentPricing : leadTimeTableRecLst){
                   LeadTimeWrapperList.add(new SPComN_Wrapper.LeadTimeWrapper(currentPricing));                
               }
               return new SPComN_Wrapper.Response(true, 'Successfully fetched the data', LeadTimeWrapperList);
           }catch(Exception ex){
               System.debug('Exception is'+ ex.getMessage());
               return new SPComN_Wrapper.Response(false, 'Error: In fetching Lead time details' + ex.getMessage(), null);
           }
       }
       return new SPComN_Wrapper.Response(false, 'Error: In fetching Lead time details', null);                         
    }
    
     /*
        @ Purpose     : Method to get pricing records with respect to selected Component.
        @ Parameter   : supplierId, componentId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getPricings(String supplierId, String componentId) {
        
        List<SPComN_Wrapper.PricingWrapper> PricingTableWrapperList = new List<SPComN_Wrapper.PricingWrapper>();
        List<bthousetracker__Supplier_Pricing_Table__c> pricingTableRecLst = new List<bthousetracker__Supplier_Pricing_Table__c>();
        if(String.isNotBlank(componentId) && String.isNotBlank(supplierId)) {
            try{
                pricingTableRecLst  = [SELECT Id, bthousetracker__Effective_Date__c, 
                                              bthousetracker__Cost__c, bthousetracker__Max_Qty__c, bthousetracker__Min_Qty__c, 
                                              bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c, 
                                              bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c, 
                                              bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Zone__r.Name, 
                                              bthousetracker__Zone__c, bthousetracker__Supplier_Component__r.Name, 
                                              bthousetracker__Status__c, bthousetracker__Supplier_Product__c,
                                              bthousetracker__Supplier_Status__c,
                                              bthousetracker__Supplier_Product__r.Name, bthousetracker__Under_Approval__c
                                       FROM bthousetracker__Supplier_Pricing_Table__c 
                                       WHERE bthousetracker__Supplier_Component__c=: componentId AND bthousetracker__Supplier__c =: supplierId AND bthousetracker__Status__c != 'Deleted'];
               
               
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
                
                /*for(bthousetracker__Supplier_Pricing_Table__c currentPricing : pricingTableRecLst){
                    PricingTableWrapperList.add(new SPComN_Wrapper.PricingWrapper(currentPricing));                
                }*/
                
                return new SPComN_Wrapper.Response(true, 'Successfully fetched the data', PricingTableWrapperList);
            }catch(Exception ex){
                System.debug('Exception is'+ ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Error while fetching records'+ ex.getMessage(), null);
            }
       }
       return new SPComN_Wrapper.Response(false, 'Error while fetching records', null);
    }
    
     /*
        @ Purpose     : Method to update pricing for Component.
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
        @ Purpose     : Method to submit Component for approval.
        @ Parameter   : componentId, effectiveDate.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response sendComponentForApproval(String componentId, String effectiveDate){
        if(String.isNotBlank(componentId)){
            try{
                bthousetracker__Supplier_Components__c componentRec = [SELECT Id, 
                                                                              bthousetracker__Effective_Date__c, 
                                                                              Name 
                                                                       FROM bthousetracker__Supplier_Components__c 
                                                                       WHERE Id =: componentId];
                                                                       
                if(String.isNotBlank(effectiveDate))
                    componentRec.bthousetracker__Effective_Date__c = Date.parse(effectiveDate);
                    
                update componentRec;
                
                Boolean result = SPComN_Utils.requestApproval('', componentId);//First parameter is supplierId.
                
                if(result){
                    return new SPComN_Wrapper.Response(true, 'Request has been submitted',componentRec, null);
                }else{
                    return new SPComN_Wrapper.Response(false, 'Failed to request', null, null);
                }
            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false, 'Failed to request : '+ ex.getMessage(), null, null);
            }
        }
        return new SPComN_Wrapper.Response(false, 'component Id not present', null, null);
    }
    
      /*
    */
    @remoteAction
    public static SPComN_Wrapper.Response sendApproval(String pricingJson, String effectiveDate, String supplierId, String componentId){
        
        SPComN_Wrapper.Response result = updatePricings(pricingJson);        
        
        if(result.issuccess){
           return sendComponentForApproval(componentId, effectiveDate);
        }    
        
        return result;            
    }
    
      /*
        @ Purpose     : Method to update lead time for Component.
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
        @ Purpose     : Method to deactivate component records.
        @ Parameter   : recordId, jsonData.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response requestForDelete(String recordId, String jsonData){
        SPComN_Wrapper.ComponentDelete deletinfo = (SPComN_Wrapper.ComponentDelete) JSON.deserialize(jsonData, SPComN_Wrapper.ComponentDelete.Class);
        
        bthousetracker__Supplier_Components__c supplierComponent;
        string compType = '';
        
        try{
            supplierComponent = [SELECT id, bthousetracker__Status__c,
                                        bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c , 
                                        bthousetracker__isDelete__c  
                                 FROM bthousetracker__Supplier_Components__c 
                                 WHERE id = :recordId];
            compType = supplierComponent.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c; //For exception message.
        }catch(Exception ex){
            return new SPComN_Wrapper.Response(false, 'Error in fetching Component record', null);
        } 
        
        User userRec = [SELECT u.ManagerId, u.Id 
                        From User u 
                        WHERE Id =: userinfo.getuserid()];
        
        //If component status is pending then only change BBNA status to deleted and map rest of the data.
       
        if(supplierComponent != null && supplierComponent.bthousetracker__Status__c == 'Pending') {
            try{
                
                supplierComponent.bthousetracker__Deactivate_Date__c = deletinfo.deactivateDate != null && deletinfo.deactivateDate != '' ? date.parse(deletinfo.deactivateDate) : null;                
                supplierComponent.bthousetracker__Effective_Date__c = deletinfo.deactivateDate != null ? date.parse(deletinfo.deactivateDate) : null;                
                supplierComponent.bthousetracker__Reason_For_Delete__c = deletinfo.reasonToDelete != null ? deletinfo.reasonToDelete: '';
                supplierComponent.bthousetracker__Planing_To_Fulfil_Orders__c = deletinfo.fulfilOrders != null ? deletinfo.fulfilOrders : false;
                //supplierComponent.Status__c = 'Deleted';
                supplierComponent.bthousetracker__BBNA_Status__c = 'Deleted';
                supplierComponent.bthousetracker__Not_Fulfilling_Orders__c = deletinfo.reasonForNotFulfulling != null ? deletinfo.reasonForNotFulfulling: '';
                
            }catch(Exception Ex){
                System.debug('Exception :' + ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Can not be delete Component because of following error: '+ ex.getMessage(), null);
            }
            
            try{
                system.debug('bfr1 update');
                update supplierComponent;
                system.debug('after1 update');
                return new SPComN_Wrapper.Response(true, 'Component has been deleted!', null);
            }catch(Exception e) {
                system.debug('caught custom exception');
                return new SPComN_Wrapper.Response(false,'This is the only component for this '+compType+'. Please add another component before deleting this one.', null);
            } 
        }else If(supplierComponent != null && supplierComponent.bthousetracker__Status__c == 'Active'){
            try{
                supplierComponent.bthousetracker__Deactivate_Date__c = deletinfo.deactivateDate != null ? date.parse(deletinfo.deactivateDate) : null;
                supplierComponent.bthousetracker__Effective_Date__c = deletinfo.deactivateDate != null ? date.parse(deletinfo.deactivateDate) : null;                
                supplierComponent.bthousetracker__Reason_For_Delete__c = deletinfo.reasonToDelete != null ? deletinfo.reasonToDelete: '';
                supplierComponent.bthousetracker__Planing_To_Fulfil_Orders__c = deletinfo.fulfilOrders != null ? deletinfo.fulfilOrders : false;
                supplierComponent.bthousetracker__BBNA_Status__c = 'Pending';
                supplierComponent.bthousetracker__isDelete__c = true;
                
            } catch(Exception Ex){
                System.debug('Exception :' + ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Can not be delete supplierComponent because of following error: '+ ex.getMessage(), null);
            }
            
            try {
                system.debug('bfr update');
                update supplierComponent;
                system.debug('aftr update');
                if(userRec.ManagerId == null) {
                    return new SPComN_Wrapper.Response(false, 'There is no manager assigned to you, so you cannot deactivate the Component as it needs approval from manager.', null);
                }else{
                    Boolean isSuccess = SPComN_Utils.requestApproval('', recordId);// First parameter is supplierId which is blank in this case.
                    if(isSuccess){
                        return new SPComN_Wrapper.Response(true, 'Request has been submitted!', null);
                    }else{
                        return new SPComN_Wrapper.Response(false, 'This Component is under Approval, you cannot deactivate it', null); 
                    }
                }
            }catch(LastRecordDeleteException e) {
                system.debug('caught custom exception');
                return new SPComN_Wrapper.Response(false,'This is the only component for this '+compType+'. Please add another component before deleting this one.', null);
            }
            
        }else {
            return new SPComN_Wrapper.Response(false, 'Only Pending and Active records can be deleted.', null);
        }
        
        return new SPComN_Wrapper.Response(false, 'Failed!', null);
    }
    
    /*
        @ Purpose     : Method to get Assigned Products with respect to given componentId.
        @ Parameter   : supplierId, componentId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public static SPComN_Wrapper.Response getProductRules(String supplierId, String componentId) {
        List<ProductRuleWrapper> ProductRuleWrapperList = new List<ProductRuleWrapper>();
        List<bthousetracker__Supplier_Products_Components__c> productNCompList = new  List<bthousetracker__Supplier_Products_Components__c>();
        
        if(String.isNotBlank(componentId) && String.isNotBlank(supplierId)){
            String query = ' SELECT Id, Name, bthousetracker__Supplier__c, bthousetracker__Supplier_Product__r.bthousetracker__Door_Description__c,' +
                           ' bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c, bthousetracker__Supplier_Component__c'+
                           ' FROM bthousetracker__Supplier_Products_Components__c'+
                           ' WHERE bthousetracker__Supplier_Component__c =: componentId'+
                           ' AND bthousetracker__Supplier__c =: supplierId';
            System.debug('query' + query);
            try{
                productNCompList = Database.query(query);
                system.debug('productNCompList '+productNCompList);
            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false, 'Error: In fetching  Assigned Products' + ex.getMessage(), null );
            }
            
            for(bthousetracker__Supplier_Products_Components__c productCompRec : productNCompList){
                ProductRuleWrapperList.add(new ProductRuleWrapper(productCompRec));
            }
            
            return new SPComN_Wrapper.Response(true, 'Success: In fetching Assigned Products', ProductRuleWrapperList);
        }
        return new SPComN_Wrapper.Response(false, 'Error: In fetching Assigned Products', null);
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
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);
            
        if(String.isNotBlank(compTypeId))
            paramMap.put('componentTypeId',compTypeId);

        return SPComN_Utils.routeTo('SPComN_CatalogComponentsPage', paramMap);
    }
    
    /*
      @ Purpose     : Method to Withdraw record.
      @ Parameter   : recordId,.
      @ Return Type : SPCom_Wrapper.Response.
    */
   @remoteAction
   public static SPComN_Wrapper.Response withdrawComponent(String recordId){ 
      
       if(String.isNotBlank(recordId)){
           try{
               bthousetracker__Supplier_Components__c componentRec = [SELECT Id, bthousetracker__BBNA_Status__c, isLocked__c
                                                                      FROM bthousetracker__Supplier_Components__c
                                                                      WHERE Id =: recordId];
               
               SPComN_Utils.unlockApproval(componentRec.id);
               componentRec.isLocked__c = false;
               componentRec.bthousetracker__BBNA_Status__c = 'Withdrawn';
               
               upsert componentRec;
               return new SPComN_Wrapper.Response(true, 'Success: In getting Record', componentRec, null);                                                          
                                                                       
           }catch(Exception ex){
               return new SPComN_Wrapper.Response(false, 'Error: In getting Record'+ ex.getMessage(), null, null);
           }    
       }
       return new SPComN_Wrapper.Response(false, 'Error: Record Id not present', null, null); 
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
      @ Purpose     : Method to discard[delete] record.
      @ Parameter   : recordId, objectName.
      @ Return Type : SPCom_Wrapper.Response.
    */
    @remoteAction
    public static SPComN_Wrapper.Response discardComponent(String recordId){ 
        return SPComN_Utils.discardRecord(recordId, 'bthousetracker__Supplier_Components__c');
    }
    
    public class ProductRuleWrapper{
        public String partNumber;
        public String Description;
        
        public ProductRuleWrapper(bthousetracker__Supplier_Products_Components__c proCompRec){
        
             if(proCompRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c != null ){
                partNumber = String.valueOf(proCompRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c);
             }else{
                partNumber = '';
             }
             
             if(proCompRec.bthousetracker__Supplier_Product__r.bthousetracker__Door_Description__c != null ){
                Description = String.valueOf(proCompRec.bthousetracker__Supplier_Product__r.bthousetracker__Door_Description__c);
             }else{
                Description = '';
             } 
        }
        
    }
}