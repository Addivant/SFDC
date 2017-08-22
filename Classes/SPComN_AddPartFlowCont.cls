public Class SPComN_AddPartFlowCont {
    
    public PageVariables pageVariable {get; set;}
        
    public SPComN_AddPartFlowCont(){
        pageVariable = new pageVariables();
        
        pageVariable.supplierId = SPComN_Utils.getSupplierAccount();
        pageVariable.catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        
        System.debug('pageVariable.catalogId '+pageVariable.catalogId);
        
        if(String.isNotBlank(pageVariable.catalogId)){
            pageVariable.catalogName= getCatalogName(pageVariable.catalogId);
        }
        
        System.debug('pageVariable.catalogName '+pageVariable.catalogName);
        
        pageVariable.productId = Apexpages.currentPage().getParameters().get('productId');
        pageVariable.componentId = Apexpages.currentPage().getParameters().get('componentId');                      
    }                  
    
    @remoteAction
    public static SPComN_Wrapper.Response getAttributeData(String paramJson) {
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        String type = mapParams.containsKey('type') ? mapParams.get('type') : '';
    
        SPComN_Wrapper.partFlowAttrSecWrapper attrSecData = new SPComN_Wrapper.partFlowAttrSecWrapper();
        
        if(type == 'Product') {
            SPComN_Wrapper.Response response = getProductPicklists();
            if(response != null && response.record != null){
                attrSecData.productPicklistJson = String.valueOf(response.record); 
            }else{
                attrSecData.productPicklistJson = '';
            }             
            attrSecData.componentPicklistJson = '';
        }else{
            SPComN_Wrapper.Response response = getComponentPicklists();
            if(response != null && response.record != null){
                attrSecData.componentPicklistJson = String.valueOf(getComponentPicklists().record);  
            }else{
                attrSecData.componentPicklistJson = '';
            } 
             
            attrSecData.productPicklistJson = '';
        }
        
        attrSecData.catalogName = getCatalogName(catalogId);
        SPComN_Wrapper.Response response = getComponentTypes(supplierId);
        if(response != null && response.records != null){
            List<SPComN_Wrapper.componentTypeWrapper> componentTypes = (List<SPComN_Wrapper.componentTypeWrapper>) response.records;
            attrSecData.componentTypes = componentTypes;
        }
        
        SPComN_Wrapper.Response result = new SPComN_Wrapper.Response();
        result.isSuccess = true;
        result.record = attrSecData;
        return result;        
    }
    
    public static String getCatalogName(String catalogId){
        
        try{
            bthousetracker__Supplier_Product_Catalog__c catalog = [SELECT Id, Name FROM bthousetracker__Supplier_Product_Catalog__c WHERE Id=: catalogId];
            System.debug('catalog '+catalog );
            return catalog.name;
        }catch(Exception ex){
            System.debug('Exception '+ ex.getMessage());
        }
        
        return '';               
    }
    
    @remoteAction
    public static SPComN_Wrapper.response getProductPicklists() {
        
        String namespace = 'bthousetracker__' ;
        
        Set<String> fieldNames = new Set<String>{ namespace + 'Active_Leafs_Picklist__c', namespace + 'Assembly__c', 
                                                  namespace + 'Color__c', namespace + 'Door_Size__c', 
                                                  namespace + 'Paint_Color__c', namespace + 'Paint_Type__c',
                                                  namespace + 'Product_Category__c', namespace + 'Rating__c',
                                                  namespace + 'Series__c', namespace + 'Sub_Category__c', 
                                                  namespace + 'Type__c', namespace + 'UOM__c',
                                                  namespace + 'Warranty__c'};
        
        String picklistJson = SPComN_Utils.getPicklistValues(namespace + 'Supplier_Door_Products__c', fieldNames);            
       
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;
        response.record = picklistJson;
        return response;
    }  

    @remoteAction
    public static SPComN_Wrapper.response getComponentPicklists() {
        
        String namespace = 'bthousetracker__' ;
        
        Set<String> fieldNames = new Set<String>{ namespace + 'Attribute1__c'};
        
        String picklistJson = SPComN_Utils.getPicklistValues(namespace + 'Supplier_Components__c', fieldNames);            
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;
        response.record = picklistJson;
        return response;
    }   
    
    @remoteAction 
    public  static SPComN_Wrapper.response getComponentTypes(String supplierId){
                
        List<SPComN_Wrapper.componentTypeWrapper> componentTypes = new List<SPComN_Wrapper.componentTypeWrapper>();
        componentTypes.add(new SPComN_Wrapper.componentTypeWrapper('', 'All'));
        
        for(bthousetracker__Supplier_Component_Types__c componenType : [SELECT Id, Name, bthousetracker__Description__c  
                                                      FROM bthousetracker__Supplier_Component_Types__c 
                                                      WHERE bthousetracker__Supplier_Id__c =: supplierId]){
            
            componentTypes.add(new SPComN_Wrapper.componentTypeWrapper(componenType));
        }
        
        return new SPComN_Wrapper.response(true, '', componentTypes);        
    }       
    
    @remoteAction
    public static SPComN_Wrapper.Response getPricingSecData(String paramJson) {
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
       
        //-- get Tiers
        List<SPComN_Wrapper.TierWrapper> tiersWrapper = new List<SPComN_Wrapper.TierWrapper>();     
        for(bthousetracker__Supplier_Tier__c tier : [SELECt Id, Name, bthousetracker__min_Qty__c, bthousetracker__max_Qty__c,  bthousetracker__Supplier_Product_Catalog__c 
                                     FROM bthousetracker__Supplier_Tier__c
                                     WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                     ORDER BY bthousetracker__min_Qty__c ASC ]){
                                     
            SPComN_Wrapper.TierWrapper tierWrap = new SPComN_Wrapper.TierWrapper(tier);
            tierWrap.tierId = tier.id;
            tierWrap.id = null;
            tiersWrapper.add(tierWrap);                         
        }
        
        //-- get zones
        List<SPComN_Wrapper.ZoneWrapper> zoneWrapper = new List<SPComN_Wrapper.ZoneWrapper>();  
        for(bthousetracker__Supplier_Zones__c zone : [SELECt Id, Name, bthousetracker__Supplier__c 
                                     FROM bthousetracker__Supplier_Zones__c
                                     WHERE bthousetracker__Supplier__c =: supplierId]){
                                     
            SPComN_Wrapper.ZoneWrapper zoneWrap = new SPComN_Wrapper.ZoneWrapper(zone);
            zoneWrap.zoneId = zone.id;
            zoneWrap.id = null;
            zoneWrapper.add(zoneWrap);                          
        }
        
        SPComN_Wrapper.ZoneTierWrapper wrapperToReturn = new SPComN_Wrapper.ZoneTierWrapper(tiersWrapper, zoneWrapper);
        return new SPComN_Wrapper.Response(true, '', wrapperToReturn, null);
    }
    
    @remoteAction
    public static SPComN_Wrapper.Response getLeadTimes() {
    
        Set<String> sourcingFacilities = SPComN_Utils.getSourcingFacilties();   
        
        if(sourcingFacilities != null && !sourcingFacilities.isEmpty()) {
            List<SPComN_Wrapper.LeadTimeWrapper> leadTimes = new List<SPComN_Wrapper.LeadTimeWrapper>();
            for(String sourcing : sourcingFacilities) {
                SPComN_Wrapper.LeadTimeWrapper leadTimeWrap = new SPComN_Wrapper.LeadTimeWrapper();
                leadTimeWrap.plant = sourcing;
                leadTimes.add(leadTimeWrap);            
            }   
            
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.records = leadTimes;
            return response;
        }       
        return new SPComN_Wrapper.Response(false, 'No plants found' , null);        
    }
     
    @remoteAction
    public static SPComN_Wrapper.Response getAssignmentData(String paramJson) {  
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        String type = mapParams.containsKey('type') ? mapParams.get('type') : '';
        
        if(type == 'Product') {
            return getComponents(catalogId, null);
        } else {
            
            return getProducts(catalogId, null);
        } 
                
        return null;
    }   
    
    public static SPComN_Wrapper.Response getComponents(String catalogId, Set<Id> existingPartIds) {
    
        List<bthousetracker__Supplier_Components__c> components;
        
        System.debug('catalogId '+catalogId + 'existingPartIds  '+json.serialize(existingPartIds));
        if(String.isNotBlank(catalogId)){
            String query = 'SELECT Id, Name, bthousetracker__Cost__c, bthousetracker__Supplier_Component_Type__r.Name, bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, '+ 
                                     'bthousetracker__Active_Date__c, bthousetracker__Archived_date__c, bthousetracker__Effective_Date__c, bthousetracker__BBNA_Status__c, bthousetracker__Status__c, bthousetracker__Component_Part__c, ' +
                                     'bthousetracker__Option_Description__c, bthousetracker__Default__c, bthousetracker__Supplier_Option_Id__c, bthousetracker__Supplier_Product_Catalog__c, bthousetracker__Supplier_Id__c   ' +
                           'FROM bthousetracker__Supplier_Components__c ' +
                           'WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId AND bthousetracker__Status__c != \'Archive\' AND bthousetracker__Status__c != \'Deleted\' ';
                           
           if(existingPartIds != null && !existingPartIds.isEmpty()){               
               query += ' AND Id Not IN : existingPartIds';
           } 
           
           query += ' ORDER BY Name ASC';  
           
           system.debug('query: '+ query);
           try{
               components = Database.query(query);
           }catch(Exception ex){
               System.debug('Exception '+ ex.getMessage());
               return new SPComN_Wrapper.Response(false, ex.getMessage(), null);
           }  
        }else{
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = false;
            response.messagingStr = 'Could not found catalog with given Id.';
            return response;
        }
        
        List<SPComN_Wrapper.ProductruleWrapper> listToReturn = new List<SPComN_Wrapper.ProductruleWrapper>();                        
        if(components != null && !components.isEmpty()){
            for(bthousetracker__Supplier_Components__c component: components) {
                SPComN_Wrapper.ProductruleWrapper productRuleWrapper = new SPComN_Wrapper.ProductruleWrapper(component);                                                
                listToReturn.add(productRuleWrapper);                                    
            }                                       
        }  
        
        System.debug('listToReturn '+ listToReturn.size());   
        System.debug('listToReturn '+ JSON.serialize(listToReturn));
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;          
        response.records = listToReturn;
        return response;     
    }
    
    public static SPComN_Wrapper.Response getProducts(String catalogId,  Set<Id> existingPartIds) {
    
        List<bthousetracker__Supplier_Door_Products__c> products;
                
        if(String.isNotBlank(catalogId)){
            String query = 'SELECT Id, Name, bthousetracker__Supplier_Part__c, bthousetracker__Supplier__c, ' +
                                     'bthousetracker__BBNA_Status__c, bthousetracker__Approval_Status__c, bthousetracker__Cost__c, ' +
                                     'bthousetracker__Status__c, bthousetracker__isLocked__c, ' +
                                     'bthousetracker__Supplier_Product_Catalog__c, ' +
                                     'bthousetracker__Supplier_Product_Catalog__r.Name, bthousetracker__Under_Approval__c ' +
                           'FROM bthousetracker__Supplier_Door_Products__c ' +
                           'WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId AND bthousetracker__Status__c != \'Archive\' AND bthousetracker__Status__c != \'Deleted\' ';
                           
           if(existingPartIds != null && !existingPartIds.isempty()){               
               query += ' AND Id Not IN : existingPartIds';
           } 
           
           query += ' ORDER BY Name ASC';  
           
           try{
               products = Database.query(query);
           }catch(Exception ex){
               System.debug('Exception '+ ex.getMessage());
               return new SPComN_Wrapper.Response(false, ex.getMessage(), null);
           }            
           
        }else{
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = false;
            response.messagingStr = 'Could not found catalog with given Id.';
            return response;
        }
                
        List<SPComN_Wrapper.ProductruleWrapper> listToReturn = new List<SPComN_Wrapper.ProductruleWrapper>();                          
        if(products != null && !products.isEmpty()){
            for(bthousetracker__Supplier_Door_Products__c product : products) {
                SPComN_Wrapper.ProductruleWrapper productRuleWrapper = new SPComN_Wrapper.ProductruleWrapper(product);                                              
                listToReturn.add(productRuleWrapper);                                    
            }                                       
        } 
        
        System.debug('listToReturn '+ listToReturn.size());   
        System.debug('listToReturn '+ JSON.serialize(listToReturn));
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;          
        response.records = listToReturn;
        return response;   
    }
    
    public static Map<String, String> deserializeParam(String paramJson){    
    
       Map<String, String> mapParams = (Map<String, String>)JSON.deserialize(paramJson, Map<String, String>.class);
       return mapParams;         
    }
    
    @remoteAction 
    public static SPComN_Wrapper.response saveData(String paramJson, String partInfoJson){
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        String partType = mapParams.containsKey('type') ? mapParams.get('type') : '';
        
        
        SPComN_Wrapper.PartFlowData partData = (SPComN_Wrapper.PartFlowData) JSON.deserialize(partInfoJson, SPComN_Wrapper.PartFlowData.class);
        
        if(partData.product != null && partType == 'Product'){
            SPComN_Wrapper.response productSaveResponse = saveProduct(catalogId, SupplierId, partData.product);
            if(productSaveResponse != null && productSaveResponse.issuccess){
                partData.product = (SPComN_Wrapper.ProductInfoWrapper)productSaveResponse.record;                             
            }else{
                return productSaveResponse;
            }
        }
        
        if(partData.component != null && partType == 'Component'){
            SPComN_Wrapper.response componentSaveResponse = saveComponent(catalogId, SupplierId, partData.component);
            if(componentSaveResponse != null && componentSaveResponse.issuccess){
                partData.component = (SPComN_Wrapper.ComponentInfoWrapper)componentSaveResponse.record; 
                partData.component.catalogId = catalogId;              
            }else{
                 return componentSaveResponse;
            }        
        }
        
        string partId;
        if(partType == 'Product') {
            partId = partData.product.id;
        }else{
            partId = partData.component.id;
        }
        
        //--pricing
        if(partData.zonePricings != null){            
            
            SPComN_Wrapper.response pricingSaveResponse = savePricing(partId, partType, catalogId, supplierId, partData.zonePricings);
            if(pricingSaveResponse != null && pricingSaveResponse.issuccess){
                partData.zonePricings.pricingList = (List<SPComN_Wrapper.ZonePricing>) pricingSaveResponse.records;                
            }else{
                 return pricingSaveResponse ;
            } 
        }        
        
        //- LeadTime
        if(partData.leadTimes != null){
            SPComN_Wrapper.response leadTimeSaveResponse = saveLeadTimes(partId, partType, partData.leadTimes);
            if(leadTimeSaveResponse != null && leadTimeSaveResponse.issuccess){
                partData.leadTimes = (List<SPComN_Wrapper.LeadTimeWrapper>) leadTimeSaveResponse.records;                
            }else{
                 return leadTimeSaveResponse;
            }        
        }
        
        //- productRule
        if(partData.productRules != null){
            SPComN_Wrapper.response productRuleSaveResponse = saveProductRules(supplierId, partId, partType, partData.productRules);
            if(productRuleSaveResponse != null && productRuleSaveResponse.issuccess){
                partData.productRules = (List<SPComN_Wrapper.ProductruleWrapper>) productRuleSaveResponse.records;                
            }else{
                 return productRuleSaveResponse;
            }        
        }
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;
        response.record = partData;
        response.messagingStr = 'Part has been created.';
        return response; 
        
        return null;
    }
        
    public static SPComN_Wrapper.response saveProduct(String catalogId, String SupplierId, SPComN_Wrapper.productInfoWrapper productWrap ){
            
        
        bthousetracker__Supplier_Door_Products__c product = SPComN_Utils.deserializeProduct(productWrap);
        product.bthousetracker__Supplier__c = SupplierId;
        product.bthousetracker__Supplier_Product_Catalog__c = catalogId;        
        product.bthousetracker__Status__c = 'Pending';
        try{ 
            UPSERT product; 
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(product.id != null) {                
            productWrap.id = product.id;             
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.record = productWrap;
            response.messagingStr = 'Product has been saved.';
            return response;    
        }
        
        
        return new SPComN_Wrapper.Response(false,'could not save', null);
    }
    
    public static SPComN_Wrapper.response savePricing(String partId, String partType,
                                                      String catalogId, String supplierId, 
                                                      SPComN_Wrapper.PricingDataWrapper pricingData ){
                                                      
        String zoneStructure = pricingData.zoneStructure;
        String tierStructure = pricingData.tierStructure;
        List<SPComN_Wrapper.ZonePricing> ListZonePricingWrapper = pricingData.pricingList; 
        if(pricingData.pricingList != null){        
            Map<Id, bthousetracker__Supplier_Pricing_Table__c> existingPricings;
            if(partType == 'Product'){
                existingPricings = new Map<Id, bthousetracker__Supplier_Pricing_Table__c>([SELECt Id, 
                                                                                            bthousetracker__Supplier_Component__c,
                                                                                            bthousetracker__Supplier_Product__c
                                                                                            FROM bthousetracker__Supplier_Pricing_Table__c
                                                                                            WHERE bthousetracker__Supplier_Product__c =: partId AND bthousetracker__Status__c = 'Pending']);
            }else{
                existingPricings = new Map<Id, bthousetracker__Supplier_Pricing_Table__c>([SELECt Id, 
                                                                                            bthousetracker__Supplier_Component__c,
                                                                                            bthousetracker__Supplier_Product__c
                                                                                            FROM bthousetracker__Supplier_Pricing_Table__c
                                                                                            WHERE bthousetracker__Supplier_Component__c =: partId  AND bthousetracker__Status__c = 'Pending']);
            }
            
            List<bthousetracker__Supplier_Pricing_Table__c> newPricings = new List<bthousetracker__Supplier_Pricing_Table__c>();                                    
            
            for(SPComN_Wrapper.ZonePricing zonePricing : ListZonePricingWrapper) {
                if(zonePricing.isChecked ) {
                    for(SPComN_Wrapper.PricingWrapper pricingWrap : zonePricing.pricings){
                            
                            if(String.isNotBlank(pricingWrap.id) && existingPricings.containsKey(Id.valueOf(pricingWrap.id))){
                                existingPricings.remove(Id.valueOf(pricingWrap.id));
                            }
                        
                            bthousetracker__Supplier_Pricing_Table__c pricingToadd = SPComN_Utils.deserializePricing(pricingWrap);
                            
                            if(zonePricing.ZoneId != 'All' && String.isNotBlank(zonePricing.ZoneId)){
                                pricingToadd.bthousetracker__Supplier_Zone__c = zonePricing.ZoneId;
                            }   
                            
                            if(partType=='Product'){
                                pricingToadd.bthousetracker__Supplier_Product__c = partId;
                                pricingToadd.bthousetracker__Type__c = 'Product';
                            }else if(partType=='Component'){
                                pricingToadd.bthousetracker__Supplier_Component__c= partId;
                                pricingToadd.bthousetracker__Type__c = 'Component';
                            }
                            
                            pricingToadd.bthousetracker__Status__c = 'Pending';
                            pricingToadd.bthousetracker__Supplier_Product_Catalog__c = catalogId; 
                            pricingToadd.bthousetracker__Supplier__c = supplierId ; 
                            newPricings.add(pricingToadd);                                                                  
                    } 
                }             
            }
            
            try{
                DELETE existingPricings.values();
                UPSERT newPricings;            
            }catch(exception ex){
                System.debug('exception : '+ex.getMessage());
                return new SPComN_Wrapper.response(false, ex.getMessage(), null);
            }
            
            SPComN_Wrapper.response response = getPricingJson(catalogId, supplierId, zoneStructure, tierStructure, newPricings);
            return response;
        }
        
        return new SPComN_Wrapper.response(true, 'No pricings updated',  pricingData, null);       
        
    }

    
    public static SPComN_Wrapper.response saveComponent(String catalogId, String SupplierId, SPComN_Wrapper.ComponentInfoWrapper componentWrap ){
            
        bthousetracker__Supplier_Components__c component = SPComN_Utils.deserializeComponent(componentWrap);
        component.bthousetracker__Supplier_Product_Catalog__c = catalogId;
        component.bthousetracker__Supplier_Id__c = supplierId;
        System.debug('component  '+component );
        
        try{ 
            UPSERT component; 
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(component.id != null) {                
            componentWrap.id = component.id;             
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.record = componentWrap;
            response.messagingStr = 'Product has been saved.';
            return response;    
        }
        
        
        return new SPComN_Wrapper.Response(false,'could not save', null);
    }
    
    @remoteAction
    public static SPComN_Wrapper.response saveLeadTimes(String partId, String partType, List<SPComN_Wrapper.LeadTimeWrapper> leadTimeWrappers){
        
        List<bthousetracker__Lead_Time__c> leadTimes = new List<bthousetracker__Lead_Time__c>();
        List<SPComN_Wrapper.LeadTimeWrapper> emptyLeadTimes = new List<SPComN_Wrapper.LeadTimeWrapper>();
        List<bthousetracker__Lead_Time__c> leadTimesToDelete = new List<bthousetracker__Lead_Time__c>();
        
        for(SPComN_Wrapper.LeadTimeWrapper leadTimeWrap : leadTimeWrappers){
            
                bthousetracker__Lead_Time__c leadTime = SPComN_Utils.deserializeLeadTime (leadTimeWrap );
                
                if(partType == 'Product'){
                    leadTime.bthousetracker__Supplier_Door_Product__c = partId;
                }else{
                    leadTime.bthousetracker__Supplier_Component__c = partId;
                }
                System.debug('leadTime '+leadTime );
            
            if(String.isNotBlank(leadTimeWrap.days)){
                leadTimes.add(leadTime);            
            }else{
                emptyLeadTimes.add(leadTimeWrap );
                if(leadTime.id != null){
                    leadTimesToDelete.add(leadTime);
                }
            }
        }
        
        try{ 
            UPSERT leadTimes;
            DELETE leadTimesToDelete; 
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(leadTimes != null && !leadTimes.isEmpty()) {                
            List<SPComN_Wrapper.LeadTimeWrapper> wrapperToReturn = getLeadTimeWrapper(leadTimes); 
            wrapperToReturn.addAll(emptyLeadTimes);
            //getLeadTimeWrapper();         
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.records = wrapperToReturn ;
            response.messagingStr = 'Product has been saved.';
            return response;    
        }
        
        
        return new SPComN_Wrapper.Response(false,'could not save', null);
    }
    
    public static List<SPComN_Wrapper.LeadTimeWrapper> getLeadTimeWrapper(List<bthousetracker__Lead_Time__c> leadTimes){
        try{
            leadTimes = [SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Sourcing_Facility_Single__c
                         FROM bthousetracker__Lead_Time__c 
                         WHERE Id IN : leadTimes ];
                         
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        
        List<SPComN_Wrapper.LeadTimeWrapper> leadTimeWrappers = createLeadTimeWrapper(leadTimes);
                       
        return leadTimeWrappers;
    }
    
    public static List<SPComN_Wrapper.LeadTimeWrapper> createLeadTimeWrapper(List<bthousetracker__Lead_Time__c> leadTimes){
        List<SPComN_Wrapper.LeadTimeWrapper> leadTimeWrappers = new List<SPComN_Wrapper.LeadTimeWrapper>();
        
        for(bthousetracker__Lead_Time__c leadTime : leadTimes){
            SPComN_Wrapper.LeadTimeWrapper leadTimeWrap = new SPComN_Wrapper.LeadTimeWrapper(leadTime);
            leadTimeWrappers.add(leadTimeWrap);
        }
        
        return leadTimeWrappers;
    }
    
    public static SPComN_Wrapper.response saveProductRules(String supplierId, String partId, String partType, List<SPComN_Wrapper.ProductruleWrapper> productRuleWrappers){
        
        system.debug('productRuleWrappers '+productRuleWrappers);
        
        Map<id, bthousetracker__Supplier_Products_Components__c> existingRules;
        if(partType == 'Product'){
            existingRules = new Map<Id, bthousetracker__Supplier_Products_Components__c>([SELECT Id, bthousetracker__Supplier_Product__c, bthousetracker__Supplier_Component__c 
                                                                                         FROM bthousetracker__Supplier_Products_Components__c
                                                                                         WHERE bthousetracker__Supplier_Product__c =: partId]);
        }else{
            existingRules = new Map<Id, bthousetracker__Supplier_Products_Components__c>([SELECT Id, bthousetracker__Supplier_Product__c, bthousetracker__Supplier_Component__c 
                                                                                         FROM bthousetracker__Supplier_Products_Components__c
                                                                                         WHERE bthousetracker__Supplier_Component__c =: partId]);
        }
                
        List<bthousetracker__Supplier_Products_Components__c> productRules = new List<bthousetracker__Supplier_Products_Components__c>();
        
        for(SPComN_Wrapper.ProductruleWrapper productRuleWrap : productRuleWrappers){
            if(String.isNotBlank(productRuleWrap.id) && existingRules.containsKey(Id.valueOf(productRuleWrap.id))){
                existingRules.remove(Id.valueOf(productRuleWrap.id));
            }
            
            bthousetracker__Supplier_Products_Components__c productRule = SPComN_Utils.deserializeProductRule(productRuleWrap);
            productRule.bthousetracker__Supplier__c = supplierId;
            
            if(partType == 'Product'){
                productRule.bthousetracker__Supplier_Product__c = partId;
            }else{
                productRule.bthousetracker__Supplier_Component__c = partId;
            }
            
            System.debug('productRule '+productRule );
            productRules.add(productRule);
           
        }
        
        for(bthousetracker__Supplier_Products_Components__c productRuleToDelete : existingRules.values()){
            if(partType== 'Product'){
                
            }   
        }
        
        try{ 
            UPSERT productRules; 
            DELETE existingRules.values();
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(productRules != null && !productRules.isEmpty()) {                
            List<SPComN_Wrapper.ProductruleWrapper> wrapperToReturn = getProductRuleWrapper(productRules); 
            //getLeadTimeWrapper();         
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.records = wrapperToReturn ;
            response.messagingStr = 'Product has been saved.';
            return response;    
        }
                
        return new SPComN_Wrapper.Response(false,'could not save', null);
    } 
    
    public static List<SPComN_Wrapper.ProductruleWrapper> getProductRuleWrapper(List<bthousetracker__Supplier_Products_Components__c> productRules){
    
        try{
            productRules = [SELECT Id, bthousetracker__Supplier_Component__r.bthousetracker__Option_Description__c, bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c,
                               bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, 
                               bthousetracker__Supplier_Product__r.Name, bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c
                           FROM bthousetracker__Supplier_Products_Components__c
                           WHERE Id IN : productRules];
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        
        List<SPComN_Wrapper.ProductruleWrapper> productRuleWrappers = createProductRuleWrapper(productRules);
                
        return productRuleWrappers;
        
    } 
    
    public static List<SPComN_Wrapper.ProductruleWrapper> createProductRuleWrapper(List<bthousetracker__Supplier_Products_Components__c> productRules){
        
        List<SPComN_Wrapper.ProductruleWrapper> productRuleWrappers = new List<SPComN_Wrapper.ProductruleWrapper>();
        
        if(productRules != null && !productRules.isEmpty()){
            for(bthousetracker__Supplier_Products_Components__c productRule : productRules){
                SPComN_Wrapper.ProductruleWrapper productRuleWrapper = new SPComN_Wrapper.ProductruleWrapper(productRule );
                productRuleWrapper.id = productRule.id;
                productRuleWrappers.add(productRuleWrapper);
            }
        }
        return productRuleWrappers;
   }        
    
    public static SPComN_Wrapper.response getPricingJson(String catalogId, String supplierId, String zoneStructure, String tierStructure, List<bthousetracker__Supplier_Pricing_Table__c> newPricings){
        Map<String, List<SPComN_Wrapper.PricingWrapper>> mapZonePricing = new Map<STring, List<SPComN_Wrapper.PricingWrapper>>();
        List<bthousetracker__Supplier_Pricing_Table__c > pricingTableRecLst;
        if(newPricings != null) {
               
            pricingTableRecLst  = [SELECT Id, bthousetracker__Cost__c, bthousetracker__Supplier_Tier__c, bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c, bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c, bthousetracker__Supplier_Product__c, 
                                          bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Zone__r.Name,  bthousetracker__Effective_Date__c, bthousetracker__Zone__c, bthousetracker__Status__c, 
                                          bthousetracker__Under_Approval__c, bthousetracker__BBNA_Status__c, bthousetracker__Supplier_Product_Catalog__c
                                   FROM bthousetracker__Supplier_Pricing_Table__c 
                                   WHERE Id IN: newPricings
                                   ORDER BY bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c Asc];
                                   
            
            System.debug('pricingTableRecLst  ' +JSON.serialize(pricingTableRecLst ) );
            for(bthousetracker__Supplier_Pricing_Table__c pricing : pricingTableRecLst){
                System.debug('tier ' + pricing.bthousetracker__Supplier_Tier__c  + ' : ' + pricing.bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c );
                
                if(pricing.bthousetracker__Supplier_Zone__c != null){
                    if(!mapZonePricing.containsKey(String.valueOf(pricing.bthousetracker__Supplier_Zone__c))){
                        mapZonePricing.put(String.valueOf(pricing.bthousetracker__Supplier_Zone__c), new List<SPComN_Wrapper.PricingWrapper>());                    
                    }                   
                    mapZonePricing.get(pricing.bthousetracker__Supplier_Zone__c).add(new SPComN_Wrapper.PricingWrapper(pricing));
                    System.debug('mapZonePricing'+ mapZonePricing);
                }else{
                    
                    if(!mapZonePricing.containsKey('All')){
                        mapZonePricing.put('All', new List<SPComN_Wrapper.PricingWrapper>());                   
                    }                   
                    mapZonePricing.get('All').add(new SPComN_Wrapper.PricingWrapper(pricing));
                }
            }
        }
        
        
        List<SPComN_Wrapper.ZonePricing> ListZonePricingWrapper = new List<SPComN_Wrapper.ZonePricing>();
                
        List<SPComN_Wrapper.PricingWrapper> emptyPricings = getEmptyPricing(catalogId, tierStructure);
        if(zoneStructure == 'Zoned'){
            for(bthousetracker__Supplier_Zones__c zone : [SELECt Id, Name, bthousetracker__Supplier__c 
                                                             FROM bthousetracker__Supplier_Zones__c
                                                             WHERE bthousetracker__Supplier__c =: supplierId]){
                                         
                
                SPComN_Wrapper.ZonePricing ZonePricingWrapper = new SPComN_Wrapper.ZonePricing();
                ZonePricingWrapper.zoneName = zone.Name;
                ZonePricingWrapper.zoneId = zone.id;            
                
                
                if(mapZonePricing.containsKey( zone.id)){
                    ZonePricingWrapper.pricings = mapZonePricing.get( zone.id);
                    ZonePricingWrapper.isChecked = true;
                }else{
                    ZonePricingWrapper.pricings = emptyPricings;
                    ZonePricingWrapper.isChecked = false;
                }
                
                ListZonePricingWrapper.add(ZonePricingWrapper);         
            }       
        }else{
            SPComN_Wrapper.ZonePricing ZonePricingWrapper = new SPComN_Wrapper.ZonePricing();
            ZonePricingWrapper.zoneName = 'All';
            ZonePricingWrapper.zoneId = 'All';
            
            if(mapZonePricing.containsKey( 'All')){
                ZonePricingWrapper.pricings = mapZonePricing.get( 'All');
                ZonePricingWrapper.isChecked = true;
            }else{
                ZonePricingWrapper.pricings = emptyPricings;
                ZonePricingWrapper.isChecked = false;
            }
    
            ListZonePricingWrapper.add(ZonePricingWrapper);
        }
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
        response.isSuccess = true;
        response.records = ListZonePricingWrapper;   
        return response; 
    }
    
    public static List<SPComN_Wrapper.PricingWrapper> getEmptyPricing(String catalogId, String tierStructure){
        List<SPComN_Wrapper.PricingWrapper> emptyPricings = new List<SPComN_Wrapper.PricingWrapper>();
        
        if(tierStructure == 'Tiered'){
            
            for(bthousetracker__Supplier_Tier__c tier : [SELECt Id, Name, bthousetracker__min_Qty__c, bthousetracker__max_Qty__c,  bthousetracker__Supplier_Product_Catalog__c 
                                         FROM bthousetracker__Supplier_Tier__c
                                         WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                         ORDER BY bthousetracker__min_Qty__c ASC ]){
                
                SPComN_Wrapper.PricingWrapper pricingWrapper = new SPComN_Wrapper.PricingWrapper(tier, '', '');
                emptyPricings.add(pricingWrapper);
            }
        }else{
            SPComN_Wrapper.PricingWrapper pricingWrapper = new SPComN_Wrapper.PricingWrapper();
            pricingWrapper.cost = '';
            pricingWrapper.status = 'Pending';
            
            emptyPricings.add(pricingWrapper);
        }
        
        return emptyPricings;
    }  
    
    @remoteAction
    public static SPComN_Wrapper.Response submitForApproval(String paramJson, String effectiveDate,  String partInfoJson) {
    
        Map<String, string> mapParams = deserializeParam(paramJson);
               
        String partType = mapParams.containsKey('type') ? mapParams.get('type') : '';
        
        SPComN_Wrapper.Response response = saveData(paramJson, partInfoJson);
        System.debug('response.record '+response.record);
        SPComN_Wrapper.PartFlowData partData = (SPComN_Wrapper.PartFlowData) response.record;
        
        
         String partId = '';
        if(partType == 'Product' ){
           
            try{
                if(String.isNotBlank(partData.product.id)){
                    partId = partData.product.id; 
                }
                
                bthousetracker__Supplier_Door_Products__c product = [SELECT Id, Name, bthousetracker__Effective_Date__c 
                                                                     FROM bthousetracker__Supplier_Door_Products__c 
                                                                     WHERE Id=:partId];
                                                     
                product.bthousetracker__Effective_Date__c = date.parse(effectiveDate);
                Update product;
                System.debug('product  '+product);
                SPComN_Utils.requestApproval('', product.Id);
                return new SPComN_Wrapper.Response(true ,'Request has been submitted.', null);
            }catch(Exception ex){
                System.debug('exception : '+ex.getMessage());
            }  
        }else{
            
            if(String.isNotBlank(partData.component.id)){
                partId = partData.component.id; 
            }
                            
            try{
                
                bthousetracker__Supplier_Components__c component = [SELECT Id, Name, bthousetracker__Effective_Date__c 
                                                                    FROM bthousetracker__Supplier_Components__c
                                                                    WHERE Id=:partId ];
                                                                    
                component.bthousetracker__Effective_Date__c = date.parse(effectiveDate);
                Update component;
                SPComN_Utils.requestApproval('', component.id);
                return new SPComN_Wrapper.Response(true ,'Request has been submitted.', null);
            }catch(Exception ex){
                System.debug('exception : '+ex.getMessage());
            }  
        }
        
         return new SPComN_Wrapper.Response(false,'Could not submitted.', null);
    } 
    
    /**** Edit Pricing section */
    @remoteAction
    public static SPComN_wrapper.response editPricing(String paramJson){
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String partId = mapParams.containsKey('catalogId') ? mapParams.get('partId') : '';
        String partType = mapParams.containsKey('catalogId') ? mapParams.get('partType') : '';
        String zoneStructure = mapParams.containsKey('catalogId') ? mapParams.get('zoneStructure') : '';
        String tierStructure = mapParams.containsKey('catalogId') ? mapParams.get('tierStructure') : '';
                                
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
       
        SPComN_Wrapper.EditPricingWrapper editPricingData = new SPComN_Wrapper.EditPricingWrapper();
        
        SPComN_Wrapper.ZoneTierWrapper zoneTier = (SPComN_Wrapper.ZoneTierWrapper)getPricingSecData(paramJson).record;
        editPricingData.tiers = zoneTier.tiers;
        editPricingData.zones = zoneTier.zones;  
        SPComN_Wrapper.response pricingResponse = getEditPricingJson(partId, partType, catalogId, supplierId, zoneStructure, tierStructure);                
        editPricingData.pricingList = (List<SPComN_Wrapper.ZonePricing>) pricingResponse.records;
        
        PricingStructureWrapper zoneTierStructure  = (PricingStructureWrapper )pricingResponse.record;
        editPricingData.zoneStructure = zoneTierStructure.zoneStructure;
        editPricingData.tierStructure = zoneTierStructure.tierStructure;
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();                
        
        response.isSuccess = true;
        response.record = editPricingData;
        return response;        
    }  
   
    public static SPComN_Wrapper.response getEditPricingJson(String partId, String partType, String catalogId, String supplierId, String zoneStructure, String tierStructure){
        Map<String, List<SPComN_Wrapper.PricingWrapper>> mapZonePricing = new Map<STring, List<SPComN_Wrapper.PricingWrapper>>();
        List<bthousetracker__Supplier_Pricing_Table__c > pricingTableRecLst;
        if(String.isnotBlank(partType) && String.isnotBlank(partId)) {
               
            if(partType == 'Product'){
                pricingTableRecLst  = [SELECT Id, bthousetracker__Cost__c, bthousetracker__Supplier_Tier__c, bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c, bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c, bthousetracker__Supplier_Product__c, 
                                          bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Zone__r.Name,  bthousetracker__Effective_Date__c, bthousetracker__Zone__c, bthousetracker__Status__c, 
                                          bthousetracker__Under_Approval__c, bthousetracker__BBNA_Status__c, bthousetracker__Supplier_Product_Catalog__c
                                   FROM bthousetracker__Supplier_Pricing_Table__c 
                                   WHERE bthousetracker__Supplier_Product__c =: partId AND bthousetracker__Status__c != 'Archive' AND bthousetracker__Status__c != 'Deleted' AND bthousetracker__Cloned_From__c = null
                                   ORDER BY bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c Asc];
            }else {
                pricingTableRecLst  = [SELECT Id, bthousetracker__Cost__c, bthousetracker__Supplier_Tier__c, bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c, bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c, 
                                          bthousetracker__Supplier_Product__c, bthousetracker__Supplier_Component__c, 
                                          bthousetracker__Supplier_Zone__c, bthousetracker__Supplier_Zone__r.Name,  bthousetracker__Effective_Date__c, bthousetracker__Zone__c, bthousetracker__Status__c, 
                                          bthousetracker__Under_Approval__c, bthousetracker__BBNA_Status__c, bthousetracker__Supplier_Product_Catalog__c
                                   FROM bthousetracker__Supplier_Pricing_Table__c 
                                   WHERE bthousetracker__Supplier_Component__c =: partId  AND bthousetracker__Status__c != 'Archive' AND bthousetracker__Status__c != 'Deleted' AND bthousetracker__Cloned_From__c = null
                                   ORDER BY bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c Asc];
            
            }
            
                                   
            
            System.debug('pricingTableRecLst  ' +JSON.serialize(pricingTableRecLst ) );
            
            for(bthousetracker__Supplier_Pricing_Table__c pricing : pricingTableRecLst){
                System.debug('tier ' + pricing.bthousetracker__Supplier_Tier__c  + ' : ' + pricing.bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c );
                
                if(pricing.bthousetracker__Supplier_Zone__c != null){
                    if(!mapZonePricing.containsKey(String.valueOf(pricing.bthousetracker__Supplier_Zone__c))){
                        mapZonePricing.put(String.valueOf(pricing.bthousetracker__Supplier_Zone__c), new List<SPComN_Wrapper.PricingWrapper>());                    
                    }                   
                    mapZonePricing.get(pricing.bthousetracker__Supplier_Zone__c).add(new SPComN_Wrapper.PricingWrapper(pricing));
                    System.debug('mapZonePricing'+ mapZonePricing);
                    
                    if(String.isBlank(zoneStructure)){
                        zoneStructure = 'Zoned';
                    }
                }else{
                    
                    if(!mapZonePricing.containsKey('All')){
                        mapZonePricing.put('All', new List<SPComN_Wrapper.PricingWrapper>());                   
                    }                   
                    mapZonePricing.get('All').add(new SPComN_Wrapper.PricingWrapper(pricing));
                    if(String.isBlank(zoneStructure)){
                        zoneStructure = 'Non-Zoned';
                    }
                }
            }
        }
        
        if(String.isBlank(tierStructure)){
            for(String zone :mapZonePricing.keyset()){
                if(mapZonePricing.get(zone).size() > 1){
                    tierStructure = 'Tiered';
                }else{
                    tierStructure = 'Non-Tiered';
                }
                break;
            }
        }
        
        PricingStructureWrapper pricingStructure = new PricingStructureWrapper();
        pricingStructure.tierStructure  = tierStructure;
        pricingStructure.zoneStructure = zoneStructure ;

        
        List<SPComN_Wrapper.ZonePricing> ListZonePricingWrapper = new List<SPComN_Wrapper.ZonePricing>();
                
        List<SPComN_Wrapper.PricingWrapper> emptyPricings = getEmptyPricing(catalogId, tierStructure);
        if(zoneStructure == 'Zoned'){
            for(bthousetracker__Supplier_Zones__c zone : [SELECt Id, Name, bthousetracker__Supplier__c 
                                                             FROM bthousetracker__Supplier_Zones__c
                                                             WHERE bthousetracker__Supplier__c =: supplierId]){
                                         
                
                SPComN_Wrapper.ZonePricing ZonePricingWrapper = new SPComN_Wrapper.ZonePricing();
                ZonePricingWrapper.zoneName = zone.Name;
                ZonePricingWrapper.zoneId = zone.id;            
                
                
                if(mapZonePricing.containsKey( zone.id)){
                    ZonePricingWrapper.pricings = mapZonePricing.get( zone.id);
                    ZonePricingWrapper.isChecked = true;
                }else{
                    ZonePricingWrapper.pricings = emptyPricings;
                    ZonePricingWrapper.isChecked = false;
                }
                
                ListZonePricingWrapper.add(ZonePricingWrapper);         
            }       
        }else{
            SPComN_Wrapper.ZonePricing ZonePricingWrapper = new SPComN_Wrapper.ZonePricing();
            ZonePricingWrapper.zoneName = 'All';
            ZonePricingWrapper.zoneId = 'All';
            
            if(mapZonePricing.containsKey( 'All')){
                ZonePricingWrapper.pricings = mapZonePricing.get( 'All');
                ZonePricingWrapper.isChecked = true;
            }else{
                ZonePricingWrapper.pricings = emptyPricings;
                ZonePricingWrapper.isChecked = false;
            }
    
            ListZonePricingWrapper.add(ZonePricingWrapper);
        }
        
        SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();                
        
        response.isSuccess = true;
        response.records = ListZonePricingWrapper;
        response.record = pricingStructure;
        return response;
    }
    
    @remoteAction
    public static SPComN_Wrapper.response editLeadTimeData(String partId, String partType) {
        List<bthousetracker__Lead_Time__c> leadTimes = new List<bthousetracker__Lead_Time__c>();
        
        try{
            if(partType == 'Product'){
                leadTimes = [SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Sourcing_Facility_Single__c, bthousetracker__Supplier_Door_Product__c 
                             FROM bthousetracker__Lead_Time__c 
                             WHERE bthousetracker__Supplier_Door_Product__c = : partId ];
             }else if(partType == 'Component'){
                 leadTimes = [SELECT Id, bthousetracker__Man_Lead_Time__c, bthousetracker__Sourcing_Facility_Single__c, bthousetracker__Supplier_Component__c 
                             FROM bthousetracker__Lead_Time__c 
                             WHERE bthousetracker__Supplier_Component__c = : partId ];
             }
                         
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
        
        Set<String> allSourcing =  SPComN_Utils.getSourcingFacilties();
        
        List<SPComN_Wrapper.LeadTimeWrapper> leadTimeWrappers = new List<SPComN_Wrapper.LeadTimeWrapper>();
        
        Map<String, bthousetracker__Lead_Time__c> leadTimeMap = new Map<String, bthousetracker__Lead_Time__c>();
        for(bthousetracker__Lead_Time__c leadTime : leadTimes){
            SPComN_Wrapper.LeadTimeWrapper leadTimeWrap = new SPComN_Wrapper.LeadTimeWrapper(leadTime);
            leadTimeWrappers.add(leadTimeWrap);
            leadTimeMap.put(leadTime.bthousetracker__Sourcing_Facility_Single__c, leadTime);            
        }
        
        List<SPComN_Wrapper.LeadTimeWrapper> emptyLeadTimes = new List<SPComN_Wrapper.LeadTimeWrapper>();
        for(String sourcing : allSourcing){
            if(!leadTimeMap.containsKey(sourcing)){
                SPComN_Wrapper.LeadTimeWrapper emptyLeadTime = new SPComN_Wrapper.LeadTimeWrapper();
                emptyLeadTime.plant = sourcing;  
                emptyLeadTimes.add(emptyLeadTime);              
            }
        }
                
        leadTimeWrappers.addAll(emptyLeadTimes);               
        
        return new SPComN_Wrapper.response(true, '', leadTimeWrappers);
    }
    
    @remoteAction
    public static SPComN_Wrapper.response editproductRulesData(String paramJson) {   
        
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String partId = mapParams.containsKey('catalogId') ? mapParams.get('partId') : '';
        String partType = mapParams.containsKey('catalogId') ? mapParams.get('partType') : '';
        String zoneStructure = mapParams.containsKey('catalogId') ? mapParams.get('zoneStructure') : '';
        String tierStructure = mapParams.containsKey('catalogId') ? mapParams.get('tierStructure') : '';
                                
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        
        List<bthousetracker__Supplier_Products_Components__c>  productRules;
        try{
            if(partType == 'Product'){
                productRules = [SELECT Id,bthousetracker__Supplier_Component__r.Name, bthousetracker__Supplier_Component__r.bthousetracker__Option_Description__c, bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c,
                                   bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, 
                                   bthousetracker__Supplier_Product__r.Name, bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c
                               FROM bthousetracker__Supplier_Products_Components__c
                               WHERE bthousetracker__Supplier_Product__c =: partId];
           }else{
                productRules = [SELECT Id, bthousetracker__Supplier_Component__r.bthousetracker__Option_Description__c, bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c,
                                   bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c, 
                                   bthousetracker__Supplier_Product__r.Name, bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c
                               FROM bthousetracker__Supplier_Products_Components__c
                               WHERE bthousetracker__Supplier_Component__c =: partId];
           }
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
        }
                
        List<SPComN_Wrapper.ProductruleWrapper> productRuleWrappers = new List<SPComN_Wrapper.ProductruleWrapper>();
        Set<Id> existingPartId = new set<Id>();
        
        if(productRules != null && !productRules.isEmpty()){
            for(bthousetracker__Supplier_Products_Components__c productRule : productRules){
                SPComN_Wrapper.ProductruleWrapper productRuleWrapper = new SPComN_Wrapper.ProductruleWrapper(productRule );                                
                productRuleWrapper.id = productRule.id;
                productRuleWrappers.add(productRuleWrapper);
                
                if(partType == 'Product'){
                    existingPartId.add(productRule.bthousetracker__Supplier_Component__c);
                }else{                    
                    existingPartId.add(productRule.bthousetracker__Supplier_Product__c);
                }
            }
        }
                
        List<SPComN_Wrapper.ProductruleWrapper> partsToAdd;
        if(partType == 'Product') {
            SPComN_Wrapper.response partResponse = getComponents(catalogId, existingPartId);
            partsToAdd = (List<SPComN_Wrapper.ProductruleWrapper>) partResponse.records;
        } else {            
            SPComN_Wrapper.response partResponse = getProducts(catalogId, existingPartId);
            partsToAdd = (List<SPComN_Wrapper.ProductruleWrapper>) partResponse.records;
        } 
        
        system.debug('partsToAdd  '+partsToAdd );
        SPComN_Wrapper.AssignmentWrapper assignmentData = new SPComN_Wrapper.AssignmentWrapper(productRuleWrappers, partsToAdd );
        return new SPComN_Wrapper.Response(true, '' ,  assignmentData, null );        
    } 
    
    @remoteAction
    public static SPComN_Wrapper.response updatePricing(String paramJson, 
                                                        String pricingJson, Boolean isEdit ){
                                                      
        SPComN_Wrapper.PricingDataWrapper pricingData = (SPComN_Wrapper.PricingDataWrapper) Json.deserialize(pricingJson, SPComN_Wrapper.PricingDataWrapper.class);
        
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String partId = mapParams.containsKey('catalogId') ? mapParams.get('partId') : '';
        String partType = mapParams.containsKey('catalogId') ? mapParams.get('partType') : '';
        String zoneStructure = mapParams.containsKey('catalogId') ? mapParams.get('zoneStructure') : '';
        String tierStructure = mapParams.containsKey('catalogId') ? mapParams.get('tierStructure') : '';
                                
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
                
        List<SPComN_Wrapper.ZonePricing> ListZonePricingWrapper = pricingData.pricingList; 
        if(pricingData.pricingList != null){ 
            Map<Id, bthousetracker__Supplier_Pricing_Table__c> existingPricings;
            
            String query = 'SELECt Id, bthousetracker__Supplier_Component__c, bthousetracker__Status__c, '+
                                  ' bthousetracker__Supplier_Product__r.bthousetracker__Status__c, bthousetracker__Supplier_Component__r.bthousetracker__Status__c, ' +
                                  ' bthousetracker__Supplier_Product__c ' +
                           'FROM bthousetracker__Supplier_Pricing_Table__c ';
                           
                           
            if(partType == 'Product'){
                query  += ' WHERE bthousetracker__Supplier_Product__c =: partId '; 
            }else{
                query  += ' WHERE bthousetracker__Supplier_Component__c =: partId ';
            }
            
            if(isEdit){
                query += ' AND bthousetracker__Cloned_From__c = null AND bthousetracker__Status__c != \'Archive\' And bthousetracker__Status__c != \'Deleted\'';
            }else{
                query += ' AND bthousetracker__Status__c = \'Pending\' ';
            }
            
            system.debug('query :'+query);
            try{
                existingPricings = new Map<Id, bthousetracker__Supplier_Pricing_Table__c>((List<bthousetracker__Supplier_Pricing_Table__c>)Database.query(query));
            }catch(Exception ex){
                System.debug('exception : '+ex.getMessage());
            }
            
            List<bthousetracker__Supplier_Pricing_Table__c> newPricings = new List<bthousetracker__Supplier_Pricing_Table__c>();                                    
            
            for(SPComN_Wrapper.ZonePricing zonePricing : ListZonePricingWrapper) {
                if(zonePricing.isChecked ) {
                    for(SPComN_Wrapper.PricingWrapper pricingWrap : zonePricing.pricings){
                            
                            if(String.isNotBlank(pricingWrap.id) && existingPricings.containsKey(Id.valueOf(pricingWrap.id))){
                                existingPricings.remove(Id.valueOf(pricingWrap.id));
                            }
                        
                            bthousetracker__Supplier_Pricing_Table__c pricingToadd = SPComN_Utils.deserializePricing(pricingWrap);
                            
                            if(zonePricing.ZoneId != 'All' && String.isNotBlank(zonePricing.ZoneId)){
                                pricingToadd.bthousetracker__Supplier_Zone__c = zonePricing.ZoneId;
                            }   
                            
                            if(partType=='Product'){
                                pricingToadd.bthousetracker__Supplier_Product__c = partId;
                                pricingToadd.bthousetracker__Type__c = 'Product';
                            }else if(partType=='Component'){
                                pricingToadd.bthousetracker__Supplier_Component__c= partId;
                                pricingToadd.bthousetracker__Type__c = 'Component';
                            }
                                                        
                            pricingToadd.bthousetracker__Supplier_Product_Catalog__c = catalogId; 
                            pricingToadd.bthousetracker__Supplier__c = supplierId ; 
                            newPricings.add(pricingToadd);                                                                  
                    } 
                }             
            }
            
            List<bthousetracker__Supplier_Pricing_Table__c> listToDelete = new List<bthousetracker__Supplier_Pricing_Table__c>();
            if(isEdit){
                //get cloned record if zone (having active records) is removed
                listToDelete = [SELECT Id 
                                FROM bthousetracker__Supplier_Pricing_Table__c 
                                WHERE bthousetracker__Cloned_From__c IN: existingPricings.values()]; 
                
                
                //Mark as deleted active pricings
                for(bthousetracker__Supplier_Pricing_Table__c pricing :existingPricings.values()){
                    if(pricing.bthousetracker__Status__c == 'Active'){
                        pricing.bthousetracker__isDelete__c = true;
                        newPricings.add(pricing); 
                        existingPricings.remove(pricing.id);
                    }            
                }
                
                listToDelete.addAll(existingPricings.values());                                
            }
            
            try{
                
                DELETE listToDelete;
                UPSERT newPricings;            
            }catch(exception ex){
                System.debug('exception : '+ex.getMessage());
                return new SPComN_Wrapper.response(false, ex.getMessage(), null);
            }
            
            if(isEdit){
                SPComN_Wrapper.response pricingResponse = getEditPricingJson(partId, partType, catalogId, supplierId, zoneStructure, tierStructure);
                
                SPComN_Wrapper.EditPricingWrapper editPricingData = new SPComN_Wrapper.EditPricingWrapper();
                editPricingData.pricingList = (List<SPComN_Wrapper.ZonePricing>) pricingResponse.records;                
                PricingStructureWrapper zoneTierStructure  = (PricingStructureWrapper )pricingResponse.record;
                editPricingData.zoneStructure = zoneTierStructure.zoneStructure;
                editPricingData.tierStructure = zoneTierStructure.tierStructure;
                
                SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();                        
                response.isSuccess = true;
                response.record = editPricingData;                
                return response;
            }else{
                SPComN_Wrapper.response response = getPricingJson(catalogId, supplierId, zoneStructure, tierStructure, newPricings);
                return response;
            }
            
        }
        
        return new SPComN_Wrapper.response(true, 'No pricings updated',  pricingData, null);        
    }
    
    @remoteAction
    public static SPComN_Wrapper.response updateLeadTime(String paramJson, 
                                                        String leadTimeJson, Boolean isEdit ){
                                                        
        List<SPComN_Wrapper.LeadTimeWrapper> leadTimeWrappers = (List<SPComN_Wrapper.LeadTimeWrapper>) JSON.deserialize(leadTimeJson, List<SPComN_Wrapper.LeadTimeWrapper>.class );
        
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String partId = mapParams.containsKey('catalogId') ? mapParams.get('partId') : '';
        String partType = mapParams.containsKey('catalogId') ? mapParams.get('partType') : '';
        String zoneStructure = mapParams.containsKey('catalogId') ? mapParams.get('zoneStructure') : '';
        String tierStructure = mapParams.containsKey('catalogId') ? mapParams.get('tierStructure') : '';
                                
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        
        
        List<bthousetracker__Lead_Time__c> leadTimes = new List<bthousetracker__Lead_Time__c>();
        List<SPComN_Wrapper.LeadTimeWrapper> emptyLeadTimes = new List<SPComN_Wrapper.LeadTimeWrapper>();
        List<bthousetracker__Lead_Time__c> leadTimesToDelete = new List<bthousetracker__Lead_Time__c>();
        
        for(SPComN_Wrapper.LeadTimeWrapper leadTimeWrap : leadTimeWrappers){
            
                bthousetracker__Lead_Time__c leadTime = SPComN_Utils.deserializeLeadTime (leadTimeWrap );
                
                if(partType == 'Product'){
                    leadTime.bthousetracker__Supplier_Door_Product__c = partId;
                }else{
                    leadTime.bthousetracker__Supplier_Component__c = partId;
                }
                System.debug('leadTime '+leadTime );
            
            if(String.isNotBlank(leadTimeWrap.days)){
                leadTimes.add(leadTime);            
            }else{
                emptyLeadTimes.add(leadTimeWrap );
                if(leadTime.id != null){
                    leadTimesToDelete.add(leadTime);
                }
            }
        }
        
        try{ 
            UPSERT leadTimes;
            DELETE leadTimesToDelete; 
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(leadTimes != null && !leadTimes.isEmpty()) {                
            List<SPComN_Wrapper.LeadTimeWrapper> wrapperToReturn = getLeadTimeWrapper(leadTimes); 
            wrapperToReturn.addAll(emptyLeadTimes);
            //getLeadTimeWrapper();         
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;
            response.records = wrapperToReturn ;
            response.messagingStr = 'Record has been saved.';
            return response;    
        }
        
        
        return new SPComN_Wrapper.Response(false,'could not save', null);
    }
       
    @remoteAction                                                
    public static SPComN_Wrapper.response updateProductRules(String paramJson, 
                                                        String productRulesJson, Boolean isEdit ){
        
        
        List<SPComN_Wrapper.ProductruleWrapper> productRuleWrappers = (List<SPComN_Wrapper.ProductruleWrapper>) JSON.deserialize(productRulesJson, List<SPComN_Wrapper.ProductruleWrapper>.class );
        
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        String partId = mapParams.containsKey('catalogId') ? mapParams.get('partId') : '';
        String partType = mapParams.containsKey('catalogId') ? mapParams.get('partType') : '';
        String zoneStructure = mapParams.containsKey('catalogId') ? mapParams.get('zoneStructure') : '';
        String tierStructure = mapParams.containsKey('catalogId') ? mapParams.get('tierStructure') : '';
                                
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        String supplierId = mapParams.containsKey('supplierId') ? mapParams.get('supplierId') : '';
        system.debug('productRuleWrappers '+productRuleWrappers);
        
        Map<id, bthousetracker__Supplier_Products_Components__c> existingRules;
        if(partType == 'Product'){
            existingRules = new Map<Id, bthousetracker__Supplier_Products_Components__c>([SELECT Id, bthousetracker__Supplier_Product__c, bthousetracker__Supplier_Product__r.Name, bthousetracker__Supplier_Component__c,
                                                                                                 bthousetracker__Supplier_Component__r.bthousetracker__Option_Description__c,  
                                                                                                 bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.Name
                                                                                         FROM bthousetracker__Supplier_Products_Components__c
                                                                                         WHERE bthousetracker__Supplier_Product__c =: partId]);
        }else{
            existingRules = new Map<Id, bthousetracker__Supplier_Products_Components__c>([SELECT Id, bthousetracker__Supplier_Product__c, bthousetracker__Supplier_Component__c, 
                                                                                                bthousetracker__Supplier_Component__r.bthousetracker__Option_Description__c,  
                                                                                                bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.Name
                                                                                         FROM bthousetracker__Supplier_Products_Components__c
                                                                                         WHERE bthousetracker__Supplier_Component__c =: partId]);
        }
                
        List<bthousetracker__Supplier_Products_Components__c> productRules = new List<bthousetracker__Supplier_Products_Components__c>();
        
        for(SPComN_Wrapper.ProductruleWrapper productRuleWrap : productRuleWrappers){
            if(String.isNotBlank(productRuleWrap.id) && existingRules.containsKey(Id.valueOf(productRuleWrap.id))){
                existingRules.remove(Id.valueOf(productRuleWrap.id));
            }
            
            bthousetracker__Supplier_Products_Components__c productRule = SPComN_Utils.deserializeProductRule(productRuleWrap);
            productRule.bthousetracker__Supplier__c = supplierId;
            
            if(partType == 'Product'){
                productRule.bthousetracker__Supplier_Product__c = partId;
            }else{
                productRule.bthousetracker__Supplier_Component__c = partId;
            }
            
            System.debug('productRule '+productRule );
            productRules.add(productRule);
           
        }                
        
        try{ 
            UPSERT productRules; 
            DELETE existingRules.values();
        }catch(Exception ex){
            String errorMsg = SPComN_Utils.checkDuplicatePart(ex.getMessage());                      
            return new SPComN_Wrapper.Response(false, errorMsg , null);
        }
        
        if(productRules != null && !productRules.isEmpty()) {                
            if(isedit){
                SPComN_Wrapper.Response response = editproductRulesData(paramJson);
                response.messagingStr = 'Record has been saved.';   
                return response;       
            }else{
                List<SPComN_Wrapper.ProductruleWrapper> wrapperToReturn = getProductRuleWrapper(productRules); 
                SPComN_Wrapper.Response response = new SPComN_Wrapper.Response(true, 'Product has been saved.', wrapperToReturn );                
                return response;
            }     
               
        }
                
        return new SPComN_Wrapper.Response(false,'could not save', null);
    }
    
            
    public Class PageVariables {
        public String currentView {get; set;}
        public String catalogId {get; set;}
        public String catalogName {get; set;}
        public String supplierId {get; set;}
        public String productId {get; set;}
        public String componentId {get; set;}
        public string type {get; set;}
        public bthousetracker__Supplier_Door_Products__c product{get; set;}
        
    }
    
    public class PricingStructureWrapper {
        public String zoneStructure ;
        public string tierStructure ;
    } 
}