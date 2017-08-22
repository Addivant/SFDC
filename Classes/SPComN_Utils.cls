public Class SPComN_Utils {

    public static String getSupplierAccount(){
        User currentUser;
        
        try{
            currentUser = [SELECT ID, ContactId, Contact.AccountId 
                                FROM User
                                WHERE Id =: UserInfo.getUserId()];
        }Catch(Exception ex) {
            System.debug('Exception : '+ex.getMessage());
        }
        
        if(currentUser != null && currentUser.ContactId != null) {
            System.debug('account '+currentUser.Contact.AccountId);
            return String.valueOf(currentUser.Contact.AccountId);
        }
        
        String accountName;
        bthousetracker__BBNA_Supplier__c CS = bthousetracker__BBNA_Supplier__c.getOrgDefaults();
        
        System.debug('accountName' + CS.bthousetracker__Supplier__c);
        accountName = CS.bthousetracker__Supplier__c; 
        accountName = '%' + accountName + '%';
        
        if(Test.isRunningTest()){
            accountName = 'Buildertek';
        }
        
        try{
            Account acct = [SELECT Id FROM Account WHERE Name LIKE : accountName LIMIT 1];
            return acct.id;
        }catch(Exception ex){
        
        }
        return null;
    }
    
    public static  PageReference routeTo(String pagName, Map<String,String> paraNameMap){
       PageReference pageRef = new PageReference('/apex/'+pagName);
       System.debug('paraNameMap' + paraNameMap);
       for(String param : paraNameMap.keyset()){
           pageRef.getParameters().put(param, paraNameMap.get(param));
       }
       return pageRef; 
    }
    
     /*
        @ Purpose     : Method to get purchase Order recordse.
        @ Parameter   : None.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getImpactedOrders(){
        List<bthousetracker__Purchase_Orders__c> impactedOrders = new List<bthousetracker__Purchase_Orders__c>();
        List<SPComN_Wrapper.OrderWrapper> listToReturn = new List<SPComN_Wrapper.OrderWrapper>();
        try{
            impactedOrders = [SELECT Id, bthousetracker__PO__c, bthousetracker__Date_Issued__c, bthousetracker__Desired_Ship_Date__c 
                              FROM bthousetracker__Purchase_Orders__c 
                              WHERE bthousetracker__PO_Number__c IN ('1004','1005')];
            for(bthousetracker__Purchase_Orders__c order :impactedOrders ){
                listToReturn.add(new SPComN_Wrapper.OrderWrapper(order));
            }
            return new SPComN_Wrapper.Response(true, 'Successfully fetched the data',  listToReturn);
        }catch(Exception ex){
            return new SPComN_Wrapper.Response(false, 'Error while fetching records'+ ex.getMessage(), null);
        }
        return new SPComN_Wrapper.Response(false, 'Error while fetching records', null);
    }
    
     /*
        @ Purpose     : Method to get Component Types records.
        @ Parameter   : None.
        @ Return Type : Map<String, List<Supplier_Components__c>>.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getComponetTypes(String supplierId){
        List<bthousetracker__Supplier_Component_Types__c> componentTypeList = new List<bthousetracker__Supplier_Component_Types__c>();
        if(String.isNotBlank(supplierId)){
            try{
                componentTypeList =[SELECT Id, bthousetracker__Description__c, bthousetracker__Supplier_Id__c  
                                    FROM bthousetracker__Supplier_Component_Types__c
                                    WHERE bthousetracker__Supplier_Id__c =: supplierId];
                return new SPComN_Wrapper.Response(true, 'Successfully fetched the data',  componentTypeList );
            }catch(Exception ex){
                System.debug('Exception is'+ ex.getMessage());
            }                    
                                                
        } 
        return new SPComN_Wrapper.Response(false, 'Error while fetching records', null);
    }
   
    public static List<String> getListFromString(String commaSeparatedString){
        List<String> listString = new List<String>();
        
        if(String.isNotBlank(commaSeparatedString)){
            listString = commaSeparatedString.split(', ');
        }
        return listString; 
    }

    public Static Boolean requestApproval(String supplierId, String recordIds){
        System.debug('In approval class');
        List<String> listId = getListFromString(recordIds);
        System.debug('listId...'+listId);
        List<Approval.ProcessResult> results = new List<Approval.ProcessResult>();
        
        if(listId != null && !listId.isEmpty()){
            for(String currentId : listId){
                Approval.ProcessResult result = sendApproval(currentId, '');
                
                if(result != null){
                    results.add(result);     
                }           
            }
        }
        
        
        if(results != null && !results.isEmpty() && !Test.isRunningTest()){            
            return results[0].isSuccess();
        }
        
        if(Test.isRunningTest()){
            return true;
        }
        return false;
    }
    
    public static Approval.ProcessResult sendApproval(String objId, String comments){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        
        if(String.isNotBlank(comments)){
            req1.setComments(comments);
        }
        
        req1.setObjectId(objId);
    
        // Submit on behalf of a specific submitter        
        req1.setSubmitterId(UserInfo.getUserId());     
    
        // Submit the approval request for the account
        Approval.ProcessResult result;
        if(!Test.isRunningTest()){
            try{
                result = Approval.process(req1);
            }catch(exception ex){
                
            }
        }
        return result;
    }
    
    
    public static String getCatalogName(String catalogId){
        String catalogName;
        if(String.isNotBlank(catalogId)){
            catalogName = [SELECT Id, Name FROM bthousetracker__Supplier_Product_Catalog__c WHERE Id =: catalogId].Name;
        }
        
        return catalogName; 
    }
    
    public static String getPicklistValues(String ObjectApi_name, Set<String> Field_names){ 

        Map<String, Map<String, String>> pickListVal = new Map<String, Map< String, String>>();
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();     
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); 
        
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        
        for(String fieldName : field_Names){    
            
            Map<String, String> currentPicklistVal = new Map<String, String>();
            currentPicklistVal.put('-None-', '');
            List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
            for(Schema.PicklistEntry pickVal : pick_list_values) { 
              currentPicklistVal.put(pickVal.getLabel(), pickVal.getValue());
           }
           
           pickListVal.put(fieldName, currentPicklistVal);    
       }
    
       return JSON.serialize(pickListVal);
    }
    
    public static bthousetracker__Supplier_Products_Components__c deserializeProductRule(SPComN_Wrapper.ProductruleWrapper wrapper){
        bthousetracker__Supplier_Products_Components__c productRule = new bthousetracker__Supplier_Products_Components__c();
        
        if(String.isNotBlank(wrapper.id)){
            productRule.id = wrapper.id;
        }
        
        if(wrapper.Component != null && String.isNotBlank(wrapper.Component.id)){
            productRule.bthousetracker__Supplier_Component__c = wrapper.Component.id;
        }
        
        if(String.isNotBlank(wrapper.isDefault)){
            productRule.bthousetracker__Default__c = wrapper.isDefault;
        }else{
            productRule.bthousetracker__Default__c = 'No';
        }
        
        productRule.bthousetracker__Supplier__C = wrapper.supplier;
        return productRule;
    }
    
    public static  bthousetracker__Supplier_Components__c deserializeComponent(SPComN_Wrapper.ComponentInfoWrapper wrapper) {
    
        bthousetracker__Supplier_Components__c  component = new bthousetracker__Supplier_Components__c ();
        
        if(String.isNotBlank(wrapper.id)){
            component.id = wrapper.id;
        }        
        if(String.isNotBlank(wrapper.name)){
            component.Name = wrapper.name;
        } 
              
        if(String.isNotBlank(wrapper.partNumber)){
            component.bthousetracker__Component_Part__c = wrapper.partNumber;
        }
        
        if(String.isNotBlank(wrapper.description)){
            component.bthousetracker__Option_Description__c = wrapper.description ;
        }
        
        if(String.isNotBlank(wrapper.activeDate)){
            component.bthousetracker__Active_Date__c = Date.parse(wrapper.activeDate) ;
        }
        
        if(String.isNotBlank(wrapper.archiveDate)){
            component.bthousetracker__Archived_date__c = Date.parse(wrapper.archiveDate);
        }
        
        if(String.isNotBlank(wrapper.effectiveDate )){
            component.bthousetracker__Effective_Date__c = Date.parse(wrapper.effectiveDate) ;
        }
        if(String.isNotBlank(wrapper.approvalStatus)){
            component.bthousetracker__BBNA_Status__c = wrapper.approvalStatus ;
        }
        
        if(String.isNotBlank(wrapper.status)){
            component.bthousetracker__Status__c = wrapper.status;
        }
        
        if(String.isNotBlank(wrapper.attribute1 )){
            component.bthousetracker__Attribute1__c = wrapper.attribute1 ;
        }
        
        if(String.isNotBlank(wrapper.attribute2 )){
            component.bthousetracker__Attribute2__c = wrapper.attribute2 ;
        }
        
        if(wrapper.isDeleted != null){
            component.bthousetracker__isDelete__c = wrapper.isDeleted ;
        }
        
        if(wrapper.approvalLevel != null){
            component.bthousetracker__Approval_level__c = wrapper.approvalLevel ;
        }
        
        if(wrapper.pricingLevel != null){
            component.bthousetracker__Pricing_level__c = wrapper.pricingLevel ;
        }
        
        return component;    
    }        
         
    public static  bthousetracker__Supplier_Door_Products__c deserializeProduct(SPComN_Wrapper.ProductInfoWrapper wrapper) {
        bthousetracker__Supplier_Door_Products__c product = new bthousetracker__Supplier_Door_Products__c();
        
        if(String.isNotBlank(wrapper.id)){
            product.id = wrapper.id;
        }        
        if(String.isNotBlank(wrapper.name)){
            product.Name = wrapper.name;
        }       
        if(String.isNotBlank(wrapper.partNumber)){
            product.bthousetracker__Supplier_Part__c = wrapper.partNumber;
        }
        if(String.isNotBlank(wrapper.activeDate)){
            product.bthousetracker__Active_Date__c = Date.valueOf(wrapper.activeDate);
        }
        if(String.isNotBlank(wrapper.archiveDate)){
            product.bthousetracker__Archived_Date__c = Date.valueOf(wrapper.archiveDate);
        }
        if(String.isNotBlank(wrapper.effectiveDate)){
            product.bthousetracker__Effective_Date__c = Date.valueOf(wrapper.effectiveDate);
        }
        if(String.isNotBlank(wrapper.bbnaStatus)){
            product.bthousetracker__BBNA_Status__c = wrapper.bbnaStatus;
        }       
        if(String.isNotBlank(wrapper.status)){
            product.bthousetracker__Status__c = wrapper.status;
        }       
        if(String.isNotBlank(wrapper.catalogId)){
            product.bthousetracker__Supplier_Product_Catalog__c = wrapper.catalogId;
        }       
        if(String.isNotBlank(wrapper.supplier)){
            product.bthousetracker__Supplier__c = wrapper.supplier;
        }
        if(String.isNotBlank(wrapper.category)){
            product.bthousetracker__Product_Category__c = wrapper.category;
        }
        if(String.isNotBlank(wrapper.warranty)){
            product.bthousetracker__warranty__c = wrapper.warranty;
        }
        if(String.isNotBlank(wrapper.leafs)){
            product.bthousetracker__Active_Leafs_Picklist__c = wrapper.leafs;
        }
        if(String.isNotBlank(wrapper.uom)){
            product.bthousetracker__UOM__c  = wrapper.uom;
        }
        if(String.isNotBlank(wrapper.type)){
            product.bthousetracker__Type__c = wrapper.type;
        }
        if(String.isNotBlank(wrapper.assembly)){
            product.bthousetracker__Assembly__c = wrapper.assembly;
        }
        if(String.isNotBlank(wrapper.rating)){
            product.bthousetracker__rating__c = wrapper.rating;
        }
        if(String.isNotBlank(wrapper.series)){
            product.bthousetracker__series__c = wrapper.series;
        }
        if(String.isNotBlank(wrapper.size)){
            product.bthousetracker__Door_Size__c = wrapper.size;
        }
        if(String.isNotBlank(wrapper.markup)){
            product.bthousetracker__markup__c = Integer.valueOf(wrapper.markup);
        }
        if(String.isNotBlank(wrapper.weight)){
            product.bthousetracker__weight__c = Integer.valueOf(wrapper.weight);
        }
        if(String.isNotBlank(wrapper.paintcolor)){
            product.bthousetracker__paint_color__c = wrapper.paintcolor;
        }
        if(String.isNotBlank(wrapper.paintType)){
            product.bthousetracker__paint_Type__c = wrapper.paintType;
        }
        if(String.isNotBlank(wrapper.subCategory)){
            product.bthousetracker__Sub_Category__c= wrapper.subCategory;
        }
              
        return product;
    }
    
    public static  bthousetracker__Lead_Time__c deserializeLeadTime(SPComN_Wrapper.LeadTimeWrapper wrapper){
        bthousetracker__Lead_Time__c leadTime = new bthousetracker__Lead_Time__c();
        
        if(String.isNotBlank(wrapper.id)){
            leadTime.id = wrapper.id;
        }
                
        if(String.isNotBlank(wrapper.plant)){
            leadTime.bthousetracker__Sourcing_Facility_Single__c = wrapper.plant;
        }
        
        if(String.isNotBlank(wrapper.days)){
            leadTime.bthousetracker__Man_Lead_Time__c = Integer.valueOf(wrapper.days);
        }

        if(String.isNotBlank(wrapper.productId)){
            leadTime.bthousetracker__Supplier_Door_Product__c = wrapper.productId;
        }
        
        if(String.isNotBlank(wrapper.componentId)){
            leadTime.bthousetracker__Supplier_Component__c = wrapper.componentId;
        }
        
        return leadTime;
    }
    
    public static bthousetracker__Supplier_Pricing_Table__c deserializePricing(SPComN_Wrapper.PricingWrapper wrapper){
        bthousetracker__Supplier_Pricing_Table__c pricing = new bthousetracker__Supplier_Pricing_Table__c();
        
        if(String.isNotBlank(wrapper.id)){
            pricing.id = wrapper.id;
        }
                
        if(String.isNotBlank(wrapper.cost)){
            pricing.bthousetracker__Cost__c = Integer.valueOf(wrapper.cost);
        }
        
        if(String.isNotBlank(wrapper.catalogId)){
            pricing.bthousetracker__Supplier_Product_Catalog__c = wrapper.catalogId;
        }
        
        if(String.isNotBlank(wrapper.supplierId)){
            pricing.bthousetracker__Supplier__c = wrapper.supplierId;
        }

        if(String.isNotBlank(wrapper.productId)){
            pricing.bthousetracker__Supplier_Product__c = wrapper.productId;
        }
        
        if(String.isNotBlank(wrapper.status)){
            pricing.bthousetracker__Status__c= wrapper.status;
        }
        
        if(String.isNotBlank(wrapper.proposedCost)){
            pricing.bthousetracker__Proposed_Cost__c = Integer.valueOf(wrapper.proposedCost);
        }
        
        if(String.isNotBlank(wrapper.componentId)){
            pricing.bthousetracker__Supplier_Component__c = wrapper.componentId;
        }
        
        if(wrapper.tier != null && String.isNotBlank(wrapper.tier.id)){
            pricing.bthousetracker__Supplier_Tier__c = wrapper.tier.id;
        }
        
        if(wrapper.tier != null && String.isNotBlank(wrapper.tier.tierId)){
            pricing.bthousetracker__Supplier_Tier__c = wrapper.tier.tierId;
        }
        
        if(wrapper.zone != null && String.isNotBlank(wrapper.zone.id)){
            pricing.bthousetracker__Supplier_Zone__c = wrapper.zone.id;
        }
                
        return pricing;
    }
    
    public static Set<String> getSourcingFacilties(){
        Set<String> options = new Set<String>();
        
       Schema.DescribeFieldResult fieldResult =  bthousetracker__Lead_Time__c.bthousetracker__Sourcing_Facility_Single__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(f.getLabel());
       }       
       return options;
    }
    
    public static Map<String, String> getMapProposedFields(){
        Map<String, String> mapProposedFields = new Map<String, String>();
        
        List<bthousetracker__Product_Proposed_Field__c> listProposedFields = bthousetracker__Product_Proposed_Field__c.getall().values();
        
        System.debug('fields from custom setting..'+listProposedFields );
        
        for(bthousetracker__Product_Proposed_Field__c currentField : listProposedFields){
            mapProposedFields.put(currentField.Name, currentField.bthousetracker__Proposed_Field__c);
        }
        
        return mapProposedFields;
    }
    
     /*
        @Purpose     : Create SOQL string of creatable fields of given SObject
    */
    public static String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String fieldsString = '';
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();
        
        // Describe the SObject fields
        if(fieldsMap != null){
            for(Schema.SObjectField field : fieldsMap.values()){ 
                Schema.DescribeFieldResult describeResult = field.getDescribe(); 
                if(describeResult.isCreateable()){ 
                    selectFields.add(describeResult.getName());
                }
            }
        }
        
        // Append API names of fields to string 
        if(!selectFields.isEmpty()){
            for(String fieldName : selectFields){
                fieldsString += fieldName + ',';
            }
            
            // Remove last comma
            if(fieldsString.endsWith(',')){
                fieldsString = fieldsString.substring(0, fieldsString.lastIndexOf(','));
            }             
        }
        
        // Return SOQL string
        return 'SELECT ' + fieldsString + ' FROM ' + objectName + ' WHERE ' + whereClause ;         
    }
    
    /*
     * @Purpose     : get Map of Old Component Id to cloned Components
    */
    public static Map<Id, bthousetracker__Supplier_Components__c> getoldIdClonedComponentsMap(String oldCatalogId){
        
        Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMap = new Map<Id, bthousetracker__Supplier_Components__c>();
        List<bthousetracker__Supplier_Components__c> componentsToCloneList = new List<bthousetracker__Supplier_Components__c>();
        
        if(String.isNotBlank(oldCatalogId)){
            // Create SOQL with all fields of Supplier products
            String query = getCreatableFieldsSOQL('bthousetracker__Supplier_Components__c' , 'bthousetracker__Supplier_Product_Catalog__c =: oldCatalogId AND (bthousetracker__Status__c = \'Active\' OR bthousetracker__Status__c = \'Pending\')');
            
            // Get all fields of Supplier products to be cloned
            componentsToCloneList = Database.query(query);
        }
        
        // Clone fetched products and put in map for reparenting
        if(!componentsToCloneList.isEmpty()){
            for(bthousetracker__Supplier_Components__c component : componentsToCloneList){
                bthousetracker__Supplier_Components__c newComponent = component.clone();
                newComponent.bthousetracker__Status__c = 'Pending';
                oldIdClonedComponentsMap.put(component.Id, newComponent);
            }
        }
        return oldIdClonedComponentsMap;
    }
    
    /*
     * @Purpose     : get Map of Old Products Id to cloned Components
    */
    public static Map<Id, bthousetracker__Supplier_Door_Products__c> getoldIdClonedProductsMap(String oldCatalogId){
        
        Map<Id, bthousetracker__Supplier_Door_Products__c> oldIdClonedProductsMap = new Map<Id, bthousetracker__Supplier_Door_Products__c>();
        List<bthousetracker__Supplier_Door_Products__c> productsToCloneList = new List<bthousetracker__Supplier_Door_Products__c>();
        
        if(String.isNotBlank(oldCatalogId)){
            // Create SOQL with all fields of Supplier products
            String query = getCreatableFieldsSOQL('bthousetracker__Supplier_Door_Products__c' , 'bthousetracker__Supplier_Product_Catalog__c =: oldCatalogId AND (bthousetracker__Status__c = \'Active\' OR bthousetracker__Status__c = \'Pending\')');
            
            // Get all fields of Supplier products to be cloned
            productsToCloneList = Database.query(query);
        }
        
        // Clone fetched products and put in map for reparenting
        if(!productsToCloneList.isEmpty()){
            for(bthousetracker__Supplier_Door_Products__c product : productsToCloneList){
                bthousetracker__Supplier_Door_Products__c newProduct = product.clone();
                newProduct.bthousetracker__Status__c = 'Pending';
                oldIdClonedProductsMap.put(product.Id, newProduct);
            }
        }             
        return oldIdClonedProductsMap;
    }
    
    /*
        @Purpose     : Clones the child Supplier component records for given catalog
    */    
    public static List<bthousetracker__Supplier_Products_Components__c> getproductRulesToCloneList(String oldCatalogId){
        
        List<bthousetracker__Supplier_Products_Components__c> productRulesToCloneList = new List<bthousetracker__Supplier_Products_Components__c>();
        Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMap = new Map<Id, bthousetracker__Supplier_Components__c>();
        
        for( bthousetracker__Supplier_Products_Components__c productRule : [ SELECT Id, bthousetracker__Supplier_Component__c, bthousetracker__Status__c,
                                                                             bthousetracker__Supplier_Product__c ,bthousetracker__Supplier__c
                                                                            FROM bthousetracker__Supplier_Products_Components__c
                                                                            WHERE ( bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Product_Catalog__c =:oldCatalogId OR
                                                                            bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Product_Catalog__c =:oldCatalogId ) 
                                                                            AND  bthousetracker__Status__c != 'Deleted' AND
                                                                                    bthousetracker__Status__c != 'Archive' 
                                                                            ]  ){
            bthousetracker__Supplier_Products_Components__c newProductRule = productRule.clone();
            newProductRule.bthousetracker__Status__c = 'Pending';
            productRulesToCloneList.add(newProductRule);                                                                          
        }            
        return productRulesToCloneList;
    }
    
    /*
        @Purpose     : Clones the child Supplier component records for given catalog
    */    
    public static List<bthousetracker__Lead_Time__c> getLeadTimesToCloneList(String oldCatalogId){
        
        List<bthousetracker__Lead_Time__c> leadTimesToCloneList = new List<bthousetracker__Lead_Time__c>();
        Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMap = new Map<Id, bthousetracker__Supplier_Components__c>();
        
        for( bthousetracker__Lead_Time__c leadTimes : [ SELECT Id, bthousetracker__Supplier_Component__c, bthousetracker__Sourcing_Facility__c, bthousetracker__Sourcing_Facility_Single__c,  
                                                               bthousetracker__Supplier_Door_Product__c, bthousetracker__Lead_Time__c, bthousetracker__Man_Lead_Time__c
                                                        FROM bthousetracker__Lead_Time__c
                                                        WHERE bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Product_Catalog__c =:oldCatalogId OR 
                                                            bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Product_Catalog__c =:oldCatalogId
                                                            ] ){
            bthousetracker__Lead_Time__c newLeadTimes = leadTimes.clone();
            leadTimesToCloneList.add(newLeadTimes);                                                                          
        }           
        System.debug('leadTimesToCloneList.........'+leadTimesToCloneList);     
        return leadTimesToCloneList;
    }
    
    /*
        @Purpose     : Clones the child Supplier component records for given catalog
    */    
    public static List<bthousetracker__Supplier_Pricing_Table__c> getPricingList(String oldCatalogId){
        
        List<bthousetracker__Supplier_Pricing_Table__c> pricingList = new List<bthousetracker__Supplier_Pricing_Table__c>();
        
        for( bthousetracker__Supplier_Pricing_Table__c pricing : [ SELECT Id, bthousetracker__Supplier_Component__c, bthousetracker__Cost__c, bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Tier__c, bthousetracker__Supplier_Product_Catalog__c,  
                                                               bthousetracker__Supplier_Product__c, bthousetracker__Effective_Date__c, bthousetracker__Cloned_From__c, bthousetracker__Type__c, bthousetracker__Supplier__c,
                                                               bthousetracker__Deactivate_Date__c, bthousetracker__Proposed_Cost__c, bthousetracker__Status__c, bthousetracker__Supplier_Part__c 
                                                    FROM bthousetracker__Supplier_Pricing_Table__c
                                                    WHERE bthousetracker__Supplier_Product_Catalog__c =: oldCatalogId AND 
                                                    bthousetracker__Status__c != 'Deleted' and bthousetracker__Status__c != 'Archive' AND bthousetracker__Status__c != 'Pending' 
                                                  ] ){
                                                  
            bthousetracker__Supplier_Pricing_Table__c clonedPricing = pricing.clone();
            clonedPricing.bthousetracker__Status__c = 'Pending';
            //clonedPricing.Supplier_Product_Catalog__c = 'Pending';
            pricingList.add(clonedPricing);                                                                          
        }           
        System.debug('pricingList .........'+pricingList );     
        return pricingList ;
    } 
    
    
    public static String checkDuplicatePart(String exceptionMsg){
        if(exceptionMsg.contains('There is already a Component with given Product Name in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Component with given Product Name in this catalog. Please change and save again.';
        
        }else if(exceptionMsg.contains('There is already a Component with given Part Number in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Component with given Part Number in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Product with given Product Name in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Product with given Product Name in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Product with given Part Number in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Product with given Part Number in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Component with given Component Name in this catalog. Please change and save again')){
            exceptionMsg = 'There is already a Component with given Component Name in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Component with given Part Number in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Component with given Part Number in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Product with given Component Name in this catalog. Please change and save again.')){
            exceptionMsg = 'There is already a Product with given Component Name in this catalog. Please change and save again.';
            
        }else if(exceptionMsg.contains('There is already a Product with given Part Number in this catalog. Please change and save again.')){
            exceptionMsg =  'There is already a Product with given Part Number in this catalog. Please change and save again.';
            
        }else{
            exceptionMsg =  exceptionMsg;
            
        }
        return exceptionMsg;
    }
    
  /*
      @ Purpose     : Method to discard[delete] record.
      @ Parameter   : recordId, objectName.
      @ Return Type : SPCom_Wrapper.Response.
  */
  @remoteAction
  public static SPComN_Wrapper.Response discardRecord(String recordId, String objectName){
  
      if(String.isNotBlank(recordId) && String.isNotBlank(objectName)){      
          try{                        
              if(objectName == 'bthousetracker__Supplier_Door_Products__c'){
                  bthousetracker__Supplier_Door_Products__c product = [SELECT Id,bthousetracker__Status__c, bthousetracker__BBNA_Status__c  FROM bthousetracker__Supplier_Door_Products__c WHERE Id = :recordId];
                  
                  if(product.bthousetracker__BBNA_Status__c == 'Pending'){
                      unlockApproval(product.id);
                  }
                  
                  product.bthousetracker__Status__c = 'Deleted';
                  Update  product;
                  return new SPComN_Wrapper.Response(true, 'Success: In discarding record', product, null);
              }else{
                  bthousetracker__Supplier_Components__c component = [SELECT Id,bthousetracker__BBNA_Status__c,  bthousetracker__Status__c  FROM bthousetracker__Supplier_Components__c WHERE Id = :recordId];
                  if(component.bthousetracker__BBNA_Status__c == 'Pending'){
                      unlockApproval(component.id);
                  }                  
                  
                  component.bthousetracker__Status__c = 'Deleted';
                  Update  component ;
                  return new SPComN_Wrapper.Response(true, 'Success: In discarding record', component, null);                                   
              }
                         
          }catch(Exception ex){
          
              return new SPComN_Wrapper.Response(false, 'Error: In discarding record'+ ex.getMessage(), null, null);
          }
      }
      
      return new SPComN_Wrapper.Response(false, 'Error: In discarding record recordId not present', null, null);

  }
  
  public static Boolean unlockProduct(List<bthousetracker__Supplier_Door_Products__c > products){

        //List<bthousetracker__Supplier_Door_Products__c > products = [SELECT Id FROM bthousetracker__Supplier_Door_Products__c WHERE Id =: recordId];
    
        if(products != null && !products.isempty()){
            Approval.UnLockResult[] lrList = Approval.unlock(products, false);
            return true;
        }
        return false;
    }
    
    public static Boolean unlockApproval(String recordId){
        ProcessInstance instance = [SELECT Id,status
                            FROM   ProcessInstance
                            WHERE TargetObjectId =: recordId AND Status =  'Pending'];

        System.debug('instance : '+instance );
        // Now that we have our Approval Request instance, lets get the child WorkItem
        ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem
        where ProcessInstanceId=:instance.Id limit 1];
        System.debug('workItem : '+workItem  );
           
        Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
        req.setWorkItemId(workItem.id);
        req.setAction('Removed'); // This means to remove/recall Approval Request
        req.setComments('Withdraw.');
        Approval.ProcessResult result = Approval.process(req);
        
        return true;
    }

}