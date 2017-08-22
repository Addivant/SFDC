/**
    Purpose : Controller class for Product catalog page
*/

public Class SPComN_CatalogProductPageCntrl{
    public String supplierId {get; set;}
    public String catalogName {get; set;}
    public String componentTypeId {get; set;}
    
    public SPComN_CatalogProductPageCntrl(){
        supplierId = SPComN_Utils.getSupplierAccount();
        
        String catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        
        if(String.isNotBlank(catalogId))
            catalogName = SPComN_Utils.getCatalogName(catalogId);

    }
   
    /*
        @ Purpose     : Method to get Supplier Products with respect to selected Catalog.
        @ Parameter   : supplierId, catalogId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getCatalogProducts(String supplierId, String catalogId){
        List<bthousetracker__Supplier_Door_Products__c> catalogProductList = new List<bthousetracker__Supplier_Door_Products__c>();
        List<SPComN_Wrapper.ProductInfoWrapper> ProductInfoWrapperList = new List<SPComN_Wrapper.ProductInfoWrapper>();
        System.debug('!!!! CatalogId' +  CatalogId);
        System.debug('!!!! CatalogId' +  supplierId);

        if(String.isNotBlank(catalogId) && String.isNotBlank(supplierId)){
                    System.debug('!!!! CatalogId' +  supplierId);

            try{
                catalogProductList  = [SELECT Id, Name,bthousetracker__Supplier__c, bthousetracker__Type__c, bthousetracker__Door_Description__c, bthousetracker__Door_Size__c, bthousetracker__Series__c, bthousetracker__Rating__c, bthousetracker__Assembly__c, CreatedDate,
                                              bthousetracker__Active_Leafs_Picklist__c, bthousetracker__Sub_Category__c, bthousetracker__Warranty__c, bthousetracker__Under_Approval__c , bthousetracker__Effective_Date__c, bthousetracker__Approval_Status__c,
                                              bthousetracker__Supplier_Delete__c, bthousetracker__BBNA_Delete__c, bthousetracker__Lead_Time__c, bthousetracker__BBNA_Status__c , LastModifiedDate, LastModifiedBy.Name, bthousetracker__Active_Date__c,
                                              bthousetracker__Supplier_Part__c, bthousetracker__Cost__c, bthousetracker__Status__c, bthousetracker__Product_Category__c, CreatedBy.Name, bthousetracker__Archived_Date__c, bthousetracker__Deactivate_Date__c
                                       FROM bthousetracker__Supplier_Door_Products__c
                                       WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId 
                                       AND bthousetracker__Supplier__c =: supplierId
                                       And bthousetracker__Status__c != 'Deleted'];
                                   
            }catch(Exception ex){
                System.debug('Exception is'+ ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Error while fetching records 456'+ ex.getMessage(), null);

            }
            
            for(bthousetracker__Supplier_Door_Products__c currProduct : catalogProductList){
                ProductInfoWrapperList.add(new SPComN_Wrapper.ProductInfoWrapper(currProduct));
            }
            
            return new SPComN_Wrapper.Response(true, 'Successfully fetched the data',  ProductInfoWrapperList);
        }
        return new SPComN_Wrapper.Response(false, 'Error while fetching records 123', null);
    }
    
    /*
        @ Purpose     : Method to get Component Types records.
        @ Parameter   : None.
        @ Return Type : Map<String, List<Supplier_Components__c>>.      
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
        @ Purpose     : Method to deactivate Product.
        @ Parameter   : recordId, jsonData.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response requestForDelete(String recordId, String jsonData){
        
        bthousetracker__Supplier_Door_Products__c supplierProduct = getCurrentProduct(recordId);
        
        System.debug('recordId=='+recordId);
        System.debug('supplierProduct=='+supplierProduct);
        
        User userRec = [Select u.ManagerId, u.Id From User u where Id =: userinfo.getuserid()];
        
        system.debug('userRec :'+userRec);
        SPComN_Wrapper.ProductDelete deletinfo = (SPComN_Wrapper.ProductDelete) JSON.deserialize(jsonData, SPComN_Wrapper.ProductDelete.Class);
        
        system.debug(' fulfilOrders '+deletinfo.fulfilOrders);  
        System.debug('supplierProduct.bthousetracker__Status__c=='+supplierProduct.bthousetracker__Status__c);
             
        if(supplierProduct != null && supplierProduct.bthousetracker__Status__c == 'Pending') {
            try{
                supplierProduct.bthousetracker__Deactivate_Date__c = deletinfo.deactivateDate != null && deletinfo.deactivateDate != '' ? date.parse(deletinfo.deactivateDate) : null;                
                supplierProduct.bthousetracker__Effective_Date__c = deletinfo.deactivateDate != null && deletinfo.deactivateDate != '' ? date.parse(deletinfo.deactivateDate) : null;                
                supplierProduct.bthousetracker__Reason_For_Delete__c = deletinfo.reasonToDelete != null ? deletinfo.reasonToDelete: '';
                supplierProduct.bthousetracker__Planing_To_Fulfil_Orders__c = (deletinfo.fulfilOrders != null && deletinfo.fulfilOrders == 'Yes' && deletinfo.fulfilOrders != '') ? true : false;
                supplierProduct.bthousetracker__Not_Fulfilling_Orders__c = deletinfo.reasonForNotFulfulling != null ? deletinfo.reasonForNotFulfulling: ''; 
                supplierProduct.bthousetracker__BBNA_Status__c = 'Deleted';
                
                update supplierProduct;
                return new SPComN_Wrapper.Response(true, 'Product has been deleted!', null);
            }catch(Exception Ex){
                System.debug('Exception :' + ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Can not be delete Product because of following error: '+ ex.getMessage(), null);
            }
        }else If(supplierProduct != null && supplierProduct.bthousetracker__Status__c == 'Active'){
            
            try{
                supplierProduct.bthousetracker__Deactivate_Date__c = deletinfo.deactivateDate != null ? date.parse(deletinfo.deactivateDate) : null;                
                supplierProduct.bthousetracker__Effective_Date__c = deletinfo.deactivateDate != null && deletinfo.deactivateDate != '' ? date.parse(deletinfo.deactivateDate) : null;                
                supplierProduct.bthousetracker__Reason_For_Delete__c = deletinfo.reasonToDelete != null ? deletinfo.reasonToDelete: '';
                supplierProduct.bthousetracker__Planing_To_Fulfil_Orders__c = (deletinfo.fulfilOrders != null && deletinfo.fulfilOrders == 'Yes' && deletinfo.fulfilOrders != '') ? true : false;
                supplierProduct.bthousetracker__BBNA_Status__c = 'Pending';
                supplierProduct.bthousetracker__isDelete__c = true;
                
                update supplierProduct;
                
                //check if manager is there
                system.debug('manager :'+userRec.ManagerId);
                if(userRec.ManagerId == null) {
                    return new SPComN_Wrapper.Response(false, 'There is no manager assigned to you, so you cannot deactivate the product as it needs approval from manager.', null);
                }
                Boolean isSuccess = SPComN_Utils.requestApproval('', recordId);
                
                system.debug('isSuccess :'+isSuccess);
                if(isSuccess ){
                    return new SPComN_Wrapper.Response(true, 'Request has been submitted!', null);
                }else{
                    return new SPComN_Wrapper.Response(false, 'This Product is under Approval, you cannot deactivate it', null); 
                }
            }catch(Exception Ex){
                System.debug('Exception :' + ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Can not be delete Product because of following error: '+ ex.getMessage(), null);
            }                        
        }
        return new SPComN_Wrapper.Response(false, 'Failed!', null);
    }
    
    /*
        @ Purpose     : Method to get products with respect to given productId.
        @ Parameter   : productId.
        @ Return Type : Supplier_Door_Products__c.      
    */
    public static bthousetracker__Supplier_Door_Products__c getCurrentProduct(String productId){
        String supplierId = SPComN_Utils.getSupplierAccount();
        System.debug('supplierId=='+supplierId);
        bthousetracker__Supplier_Door_Products__c catalogProduct;
        
        System.debug('productId'+ productId);
        
        if(String.isNotBlank(productId)){
            
            String query = 'SELECT Id, Name, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, bthousetracker__Warranty__c, bthousetracker__Effective_Date__c,bthousetracker__Man_Lead_Times__c,bthousetracker__Supplier__c , bthousetracker__Supplier_Part__c,' + 
                                     'bthousetracker__BBNA_Status__c, bthousetracker__Approval_Status__c, bthousetracker__Cost__c,bthousetracker__Sourcing_Facility__c, bthousetracker__Status__c, bthousetracker__Active_Leafs__c, bthousetracker__Active_Leafs_Picklist__c, ' + 
                                     'bthousetracker__UOM__c, bthousetracker__Type__c, bthousetracker__Assembly__c, bthousetracker__Rating__c, bthousetracker__Series__c, bthousetracker__Sub_Category__c, bthousetracker__Door_Size__c, bthousetracker__Active_Date__c, ' + 
                                     'bthousetracker__Weight__c, bthousetracker__Paint_Color__c, bthousetracker__Paint_Type__c, bthousetracker__Lead_Time__c, bthousetracker__Markup__c, bthousetracker__Archived_Date__c, bthousetracker__Deactivate_Date__c, ' + 
                                     'bthousetracker__Supplier_Product_Catalog__r.Name, bthousetracker__Under_Approval__c,bthousetracker__Level_C__c, bthousetracker__Level_B__c, bthousetracker__Level_2__c, bthousetracker__Level_1__c';
            
            Map<String, String> mapProposedFields = SPComN_Utils.getMapProposedFields();                    
            for(String currentField : mapProposedFields.values()){
                query += ', ' + currentField;
            }
                                
            query += ' FROM bthousetracker__Supplier_Door_Products__c WHERE Id =: productId AND bthousetracker__Supplier__c =: supplierId';
            System.debug('query'+ query);     
            try{                         
                catalogProduct = Database.query(query);
                System.debug('catalogProduct123'+ catalogProduct);
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: in fetching product details - ' + ex.getMessage()));
            }
        }
        return catalogProduct;  
    }
    
      /*
        @ Purpose     : Method to redirect to page.
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
        @ Purpose     : Method to redirect to product Detail page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToProDetailPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String status1 = Apexpages.currentPage().getParameters().get('status');
        String catalogId1 = Apexpages.currentPage().getParameters().get('catalogId');
        String productId1 = Apexpages.currentPage().getParameters().get('productId');
        if(String.isNotBlank(catalogId1))
            paramMap.put('catalogId', catalogId1);
            
        if(String.isNotBlank(status1))
            paramMap.put('status', status1);
            
        if(String.isNotBlank(productId1))
            paramMap.put('productId', productId1);

        return SPComN_Utils.routeTo('SPComN_DoorProductDetailPage', paramMap);
    }
   
}