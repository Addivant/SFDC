/*
@ Purpose : Test class for .
@ Created Date : 03-Aug-2017.
*/

public Class SPComN_LeadTimesCntrl{

    public PageVariables variables {get; set;}
    
    public SPComN_LeadTimesCntrl(){
        variables = new PageVariables();
        
        String catalogId = ApexPages.currentPage().getParameters().get('catalogId');
        
        if(String.isNotBlank(catalogId)){
            variables.catalogId = catalogId;         
        }
        
        variables.supplierId = SPComN_Utils.getSupplierAccount(); 
        System.debug('variables.supplierId '+variables.supplierId) ;       
    }  
    
    /*
        @ Purpose     : Method to get part Ids[Products] for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : Set<Id>.      
    */
    public Static Set<Id> getPartsIds(String CatalogId){
        Set<Id> partsIds = new Set<Id>();
        
        if(String.isNotBlank(CatalogId)){
            try{
                //Get product Ids as parts.
                bthousetracker__Supplier_Product_Catalog__c productCatalogRec = [SELECT Id,
                
                                                                                        (SELECT Id, CreatedDate, 
                                                                                                bthousetracker__Supplier_Part__c,
                                                                                                CreatedBy.Name
                                                                                         FROM bthousetracker__Supplier_Products__r)
                                                                                         
                                                                                 FROM bthousetracker__Supplier_Product_Catalog__c 
                                                                                 WHERE Id =: CatalogId];
                
                System.debug('productCatalogRec  '+ productCatalogRec.bthousetracker__Supplier_Products__r );                                                
                for(bthousetracker__Supplier_Door_Products__c prodRec : productCatalogRec.bthousetracker__Supplier_Products__r){
                    partsIds.add(prodRec.Id);               
                }
                
                System.debug('partsIds'+ partsIds);
                /*for(bthousetracker__Supplier_Components__c compRec : productCatalogRec.bthousetracker__Supplier_Components__r){
                    partsIds.add(compRec.Id);           
                }*/
                
                return partsIds;
                                                                
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }                                               
        }
        return null;
    }      
    
     /*
        @ Purpose     : Method to get leadTime records with respect to given catalogId.
        @ Parameter   : paramJson.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response getLeadTimes(String paramJson){
    
        Map<String, string> mapParams = deserializeParam(paramJson);
        String catalogId = mapParams.containsKey('catalogId') ? mapParams.get('catalogId') : '';
        
        List<bthousetracker__Lead_Time__c> leadTimeList =  new List<bthousetracker__Lead_Time__c>(); 
        List<CatalogLeadTimeWrraper> CatalogLeadTimeWrraperList = new List<CatalogLeadTimeWrraper>();
        
        if(String.isNotBlank(catalogId)){
        
            Set<Id> partsIdSet = getPartsIds(catalogId);
            
            if(!partsIdSet.isEmpty()){
                
                try{
                    leadTimeList = [SELECT Id, 
                                           bthousetracker__Man_Lead_Time__c,
                                           bthousetracker__Sourcing_Facility_Single__c,
                                           bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c,
                                           bthousetracker__Supplier_Door_Product__r.Name                                       
                                    FROM bthousetracker__Lead_Time__c
                                    WHERE bthousetracker__Supplier_Door_Product__c IN: partsIdSet];
                                    
                    for(bthousetracker__Lead_Time__c leadTimeRec : leadTimeList){
                        CatalogLeadTimeWrraperList.add(new CatalogLeadTimeWrraper(leadTimeRec));
                    }
                                    
                }catch(Exception ex){
                    return new SPComN_Wrapper.Response(false, 'Error: In getting Records '+ ex.getMessage(), null);   
                }
            }
            
            String catalogName = SPComN_Utils.getCatalogName(catalogId);
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response();
            response.isSuccess = true;           
            response.record = catalogName;
            response.records =  CatalogLeadTimeWrraperList;          
            return response;                 
        }
        
        
        
        return new SPComN_Wrapper.Response(false, 'Error: unable to find Catalog Id', null);  

    }            
    /*
        @ Purpose     : Method to update leadTime records with respect to given catalogId.
        @ Parameter   : paramJson.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response updateLeadTime(String paramJson){
        system.debug('paramJson' + paramJson);
        Map<String, string> mapParams = deserializeParam(paramJson);
        
        System.debug('mapParams=='+mapParams);
        
        String leadTimeJson = mapParams.containsKey('leadTimeJson') ? mapParams.get('leadTimeJson') : '';

        System.debug('leadTimeJson=='+leadTimeJson);        
        
        List<CatalogLeadTimeWrraper> leadTimeWrraperList = (List<CatalogLeadTimeWrraper>) JSON.deserialize(leadTimeJson, List<CatalogLeadTimeWrraper>.class); 
        List<bthousetracker__Lead_Time__c> leadTimeList = new List<bthousetracker__Lead_Time__c>();        
                        
        for(CatalogLeadTimeWrraper CatalogLeadTimeWrraperRec : leadTimeWrraperList){ 
               
            bthousetracker__Lead_Time__c leadTimeAdd = deserializeLeadTime(CatalogLeadTimeWrraperRec);
            
            if(String.isNotBlank(CatalogLeadTimeWrraperRec.newleadTime)){
                leadTimeAdd.bthousetracker__Man_Lead_Time__c = Integer.valueOf(CatalogLeadTimeWrraperRec.newleadTime);
            }
            
            leadTimeList.add(leadTimeAdd);                            
        }       
        
        if(leadTimeList != null && !leadTimeList.isempty()){
            try{
                upsert leadTimeList;
                
                SPComN_Wrapper.Response result = getLeadTimes(paramJson);                
                return new SPComN_Wrapper.Response(true,'Data is saved successfully', result.records);                
            }catch(Exception ex){
                return new SPComN_Wrapper.Response(false,'Error: In saving data '+ ex.getMessage(), null); 
            }
        }
        return new SPComN_Wrapper.Response(false,'Error: In saving data ', null);
    }
    
     /*
        @ Purpose     : Method to get Supplier Products with respect to selected Catalog.
        @ Parameter   : supplierId, catalogId.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response getCatalogProducts(String supplierId, String catalogId){
       SPComN_Wrapper.Response response = SPComN_CatalogProductPageCntrl.getCatalogProducts(supplierId, catalogId);
       Set<String> sourcings = SPComN_Utils.getSourcingFacilties();
       response.record = sourcings ;
       
       return response;
    }
    
     /*
        @ Purpose     : Method to create LeadTime wtih respect to given product Ids.
        @ Parameter   : leadTimeJson.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response createLeadTime(String supplierId, String leadTimeJson){
        CreateLeadTimeWrapper CreateLeadTimeWrapperRec = (CreateLeadTimeWrapper) JSON.deserialize(leadTimeJson, CreateLeadTimeWrapper.class); 
        
        System.debug('CreateLeadTimeWrapperRec=='+CreateLeadTimeWrapperRec);
        
        List<SPComN_Wrapper.ProductInfoWrapper> productList = CreateLeadTimeWrapperRec.parts;
        
        System.debug('productList=='+productList);
        List<bthousetracker__Lead_Time__c> leadTimeList = new List<bthousetracker__Lead_Time__c>();
        
        for(SPComN_Wrapper.ProductInfoWrapper product : productList){
        
            bthousetracker__Lead_Time__c leadTimeRec = new bthousetracker__Lead_Time__c();
            
            leadTimeRec.bthousetracker__Sourcing_Facility_Single__c = CreateLeadTimeWrapperRec.sourcing;
            leadTimeRec.bthousetracker__Man_Lead_Time__c = Integer.valueOf(CreateLeadTimeWrapperRec.leadTime);
            leadTimeRec.bthousetracker__Supplier_Door_Product__c = product.id;
            List<bthousetracker__Lead_Time__c> leadTimeLists = new List<bthousetracker__Lead_Time__c>();
            leadTimeLists = [Select id from bthousetracker__Lead_Time__c where 
                            bthousetracker__Sourcing_Facility_Single__c = :leadTimeRec.bthousetracker__Sourcing_Facility_Single__c
                            and bthousetracker__Supplier_Door_Product__c =:leadTimeRec.bthousetracker__Supplier_Door_Product__c];
            System.debug(leadTimeLists);
            if(!leadTimeLists.isEmpty()){
                 return new SPComN_Wrapper.Response(false, 'Error: Lead time already exist for select Part No at selected sourcing facility', null);
            } else{              
            leadTimeList.add(leadTimeRec);
            try{
            insert leadTimeList;
            return new SPComN_Wrapper.Response(true, 'Success: In creating LeadTime', leadTimeList);
            }catch(Exception ex){
            
                return new SPComN_Wrapper.Response(false, 'Error: In creating LeadTime '+ ex.getMessage(), null);
            }
        }
       }
       return new SPComN_Wrapper.Response(false, 'Error: Lead time already exist for select Part No at selected sourcing facility', null);
       } 
        /*if(!leadTimeList.isEmpty()){
            try{
            
                insert leadTimeList;
                return new SPComN_Wrapper.Response(true, 'Success: In creating LeadTime', leadTimeList);
                
            }catch(Exception ex){
            
                return new SPComN_Wrapper.Response(false, 'Error: In creating LeadTime '+ ex.getMessage(), null);
            }
        }
        
        return new SPComN_Wrapper.Response(false, 'Error: Lead time already exist for select Part No at selected sourcing facility', null);
    }*/
    
    /*
        @ Purpose     : Method to Delete LeadTime.
        @ Parameter   : leadTimeId.
        @ Return Type : SPComN_Wrapper.Response.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.Response deleteLeadTime(String leadTimeId){
    
        if(String.isNotBlank(leadTimeId)){        
            try{
            
                delete new bthousetracker__Lead_Time__c(Id = leadTimeId);
                return new SPComN_Wrapper.Response(true, 'Success: In deleting record', null);
                
            }catch(Exception ex){
                
               return new SPComN_Wrapper.Response(false, 'Error: In deleting record'+ ex.getMessage(), null);
            
            }              
        } 
               
        return new SPComN_Wrapper.Response(false, 'Error: In deleting record', null);
        
    }

    
    /*
        @ Purpose     : Method to deserialize leadTime records.
        @ Parameter   : wrapper.
        @ Return Type : bthousetracker__Lead_Time__c .      
    */
    public static  bthousetracker__Lead_Time__c deserializeLeadTime(CatalogLeadTimeWrraper wrapper){
    
        bthousetracker__Lead_Time__c  leadTimeRec = new bthousetracker__Lead_Time__c();
        
        if(String.isNotBlank(wrapper.id)){
            leadTimeRec.id = wrapper.id;
        }
                
        if(String.isNotBlank(wrapper.leadTime)){
            leadTimeRec.bthousetracker__Man_Lead_Time__c = Integer.valueOf(wrapper.leadTime);
        }
        
        return leadTimeRec;
    }
    
    
     /*
        @ Purpose     : Method to deserialize parameters JSON.
        @ Parameter   : paramJson.
        @ Return Type : Map<String, String>.      
    */
    public static Map<String, String> deserializeParam(String paramJson){    
    
        Map<String, String> mapParams = (Map<String, String>)JSON.deserialize(paramJson, Map<String, String>.class);
        System.debug('mapParams=='+mapParams);
        return mapParams;         
    }
    
    public class CreateLeadTimeWrapper{
        public List<SPComN_Wrapper.ProductInfoWrapper> parts;
        public String sourcing;
        public String leadTime;
        
        public CreateLeadTimeWrapper(){}
    }
    
    public Class PageVariables {
        public String supplierId {get; set;}
        public String catalogId {get; set;}
        public String productId {get; set;}
        
        public PageVariables (){}
    }
    
    public Class CatalogLeadTimeWrraper{
        public String Id;
        public String leadTime;
        public String newleadTime;
        public String partNumber;
        public String description;
        public String sourcingFacility;
        
        public CatalogLeadTimeWrraper(bthousetracker__Lead_Time__c leadTimeRec){
           
           if(leadTimeRec.id != null) {
               id = leadTimeRec.Id;                  
           }
           
           if(leadTimeRec.bthousetracker__Supplier_Door_Product__c != null){
           
               partNumber = leadTimeRec.bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c != null ? String.valueOf(leadTimeRec.bthousetracker__Supplier_Door_Product__r.bthousetracker__Supplier_Part__c): '';
               description = leadTimeRec.bthousetracker__Supplier_Door_Product__r.Name != null ? String.valueOf(leadTimeRec.bthousetracker__Supplier_Door_Product__r.Name): '';

           }
           
           leadTime = leadTimeRec.bthousetracker__Man_Lead_Time__c != null ? String.valueOf(leadTimeRec.bthousetracker__Man_Lead_Time__c): '';
           sourcingFacility = leadTimeRec.bthousetracker__Sourcing_Facility_Single__c != null ? leadTimeRec.bthousetracker__Sourcing_Facility_Single__c : '';
        }
        
    }
}