/**
    Purpose : Controller class for catalog component page
*/

public Class SPComN_CatalogComponentsPageCntrl {
    public String supplierId {get; set;}
    public String catalogName {get; set;}
    public String compTypeDesc {get; set;}
    public String componentTypeIdURL {get; set;}
    
    public SPComN_CatalogComponentsPageCntrl (){
        supplierId = SPComN_Utils.getSupplierAccount();
        String catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        String cmpTypeId = Apexpages.currentPage().getParameters().get('componentTypeId');

        
        if(String.isNotBlank(catalogId))
            catalogName = SPComN_Utils.getCatalogName(catalogId);
            
        if(String.isNotBlank(cmpTypeId)){
            compTypeDesc = getCompTypeDesc(cmpTypeId);
        }else{
            compTypeDesc = 'All';
        }

    }
    
     /*
        @ Purpose     : Method to get Component Types Name.
        @ Parameter   : cmpTypeId.
        @ Return Type : String.      
    */
    public String getCompTypeDesc(String cmpTypeId){
       String componentTypeDesc = [SELECT Id, bthousetracker__Description__c
                                   FROM bthousetracker__Supplier_Component_Types__c
                                   WHERE Id =: cmpTypeId].bthousetracker__Description__c;
       
       return componentTypeDesc;                                    
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
        @ Purpose     : Method to get purchase Order recordse.
        @ Parameter   : None.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getImpactedOrders(){
        return SPComN_Utils.getImpactedOrders();   
    }
    
    /*
        @ Purpose     : Method to get Component records with respect to Component type and Catalog Id.
        @ Parameter   : supplierId, catalogId, componentId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getComponets(String supplierId, String catalogId, String componentTypeId){
        List<bthousetracker__Supplier_Components__c> componentList = new List<bthousetracker__Supplier_Components__c>();
        List<SPComN_Wrapper.ComponentInfoWrapper> ComponentInfoWrapperList = new List<SPComN_Wrapper.ComponentInfoWrapper>();

       String query = ' SELECT Name, bthousetracker__Cost__c, bthousetracker__Default__c, bthousetracker__Status__c, bthousetracker__Supplier_Id__c, bthousetracker__isDelete__c, bthousetracker__Supplier_Option_Id__c, bthousetracker__Component_Part__c, bthousetracker__Pricing_Approval_Status__c,'+
                      ' bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, bthousetracker__Supplier_Component_Type__c, bthousetracker__Supplier_Component_Type__r.Name, bthousetracker__Attribute1__c, bthousetracker__Attribute2__c, bthousetracker__Supplier_Product_Catalog__c'+
                      ' FROM bthousetracker__Supplier_Components__c WHERE ';
                      
        if(String.isNotBlank(supplierId) && String.isNotBlank(catalogId)){               
            if(String.isNotBlank(componentTypeId)){
                query += ' bthousetracker__Supplier_Component_Type__c = \'' + componentTypeId+ '\' AND ';
            }
            query += ' bthousetracker__Supplier_Product_Catalog__c = \'' + catalogId + '\' AND ';
            query += 'bthousetracker__Status__c != \'Deleted\' AND ';
            query += 'bthousetracker__Supplier_Id__c = \'' + supplierId + '\'';
            
            System.debug('query'+ query);
            try{
                componentList = Database.query(query);
            }catch(Exception ex){
                System.debug('Exception is'+ ex.getMessage());
                return new SPComN_Wrapper.Response(false, ex.getMessage(), null);

            }
            
             if(componentList !=  null && !componentList.isEmpty()){
                for(bthousetracker__Supplier_Components__c currCmp : componentList){
                    ComponentInfoWrapperList.add(new SPComN_Wrapper.ComponentInfoWrapper(currCmp));
                }
            } 
            return new SPComN_Wrapper.Response(true, 'Successfully fetched the data',  ComponentInfoWrapperList);
        }                   
        return new SPComN_Wrapper.Response(false, 'Error while fetching records', null);
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
            supplierComponent = [SELECT id, bthousetracker__Status__c, bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c , bthousetracker__isDelete__c  
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
        @ Purpose     : Method to redirect SPComN_CatalogProductPage page.
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
        @ Purpose     : Method to redirect SPComN_ComponentDetailPage page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToCompDetailPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');
        String componentId1 = Apexpages.currentPage().getParameters().get('componentId');
        String componentTypeId1 = Apexpages.currentPage().getParameters().get('componentTypeId');

        
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);
        
        if(String.isNotBlank(componentId1))
            paramMap.put('componentId', componentId1);
            
         if(String.isNotBlank(componentId1))
            paramMap.put('compTypeId', componentTypeId1);

        return SPComN_Utils.routeTo('SPComN_ComponentDetailPage', paramMap);
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
        @ Purpose     : Method to redirect to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToCatCompPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');
        String componentTypeId1 = Apexpages.currentPage().getParameters().get('componentTypeIdURL');
        System.debug('!!!!!'+ componentTypeIdURL);
        
        PageReference pageRef = page.SPComN_CatalogComponentsPage;
        pageRef.getParameters().put('status', status1);
        pageRef.getParameters().put('catalogId', catalogId1);
        pageRef.getParameters().put('componentTypeId', componentTypeIdURL);
        pageRef.setRedirect(true);
        return pageRef ; 
    }
}