/**
    Purpose : Controller class for Product catalog detail page to show product detail, Parts details, 
              pricing details, Tiers details, Zone States
*/
public Class SPComN_CatalogDetailPageCntrl{
    public String supplierId {get; set;}
    public String catalogId {get; set;}
    public String catalogName {get; set;}
    
    public SPComN_CatalogDetailPageCntrl(){
        supplierId = SPComN_Utils.getSupplierAccount();
        catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        
        if(String.isNotBlank(catalogId))
            catalogName = SPComN_Utils.getCatalogName(catalogId);

    }
    
     /*
        @ Purpose     : Method to get catalog details.
        @ Parameter   : catalogId.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.response getCatalogDetail(String catalogId){
        
        if(String.isNotBlank(catalogId)){
            ProcessInstance  ProcessInstanceRec = new ProcessInstance();
            try{
                bthousetracker__Supplier_Product_Catalog__c catalogRec = [SELECT Id, 
                                                                                 Name, 
                                                                                 bthousetracker__Status__c,bthousetracker__Approval_Status__c,bthousetracker__BBNA_Status__c,
                                                                                 bthousetracker__BBNA_Product_Category__r.Name,
                                                                                 CreatedBy.Name, 
                                                                                 LastModifiedDate, 
                                                                                 CreatedDate, 
                                                                                 LastModifiedBy.Name 
                                                                          FROM bthousetracker__Supplier_Product_Catalog__c
                                                                          WHERE Id =: catalogId];
                                                                          
               if(catalogRec.bthousetracker__BBNA_Status__c == 'Pending'){
                    ProcessInstanceRec = [SELECT Id, 
                                                 TargetObjectId,
                                                 Status, 
                                                 CompletedDate,
                                                 CreatedDate, 
                                                 SubmittedBy.Name, 
                                                 LastActor.Name
                                           FROM ProcessInstance 
                                           WHERE TargetObjectId =: catalogId 
                                           ORDER BY CreatedDate DESC
                                           LIMIT 1];
               
               } 
               
               return new SPComN_Wrapper.response(true,'Succesfully fetched the record', new catalogWrapper(catalogRec, ProcessInstanceRec),null );
            }catch(Exception ex){
                return new SPComN_Wrapper.response(false, 'Error while fetching records'+ ex.getMessage(), null, null);
            }
        }
        return new SPComN_Wrapper.response(false, 'Error: Catalog Id not present', null, null);
    }
    
     /*
        @ Purpose     : Method to Update Catalog Name.
        @ Parameter   : catalogId, catalogName.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.response updateCatalogName(String catalogId, String newCatalogName){
        
        if(String.isNotBlank(catalogId) && String.isNotBlank(newCatalogName)){
            try{
                bthousetracker__Supplier_Product_Catalog__c catalogRec = [SELECT Id,
                                                                                 Name
                                                                          FROM bthousetracker__Supplier_Product_Catalog__c
                                                                          WHERE Id =: catalogId];
                catalogRec.Name = newCatalogName;                                            
                upsert catalogRec;
                                            
                return new SPComN_Wrapper.response(true,'Succesfully updated the record', catalogRec,null );
            }catch(Exception ex){
                return new SPComN_Wrapper.response(false, 'Error while updating records'+ ex.getMessage(), null, null);
            }
        }
        return new SPComN_Wrapper.response(false, 'Error: Somthing went wrong with catalog Id or catalog Name', null, null);
    }
    
    /*
        @ Purpose     : Method to get part details with respect to there status.
        @ Parameter   : catalogId.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.catalogInfoWrraper getCatalogPartsCount(String catalogId){
        Integer totParts = 0;
        Integer totActiveParts = 0;
        Integer totPendingParts = 0;
        Integer toArchiveparts = 0;
        
        Map<String, Integer> partsCountMap = new Map<String, Integer>();
        
        if(String.isNotBlank(catalogId)){
            //Get Component count for parts depending on status.
            List<AggregateResult> compAggResList = [SELECT bthousetracker__Status__c, 
                                                           Count(Id)
                                                    FROM bthousetracker__Supplier_Components__c 
                                                    WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                    GROUP BY bthousetracker__Status__c];
            
            System.debug('compAggResList=='+compAggResList);
                                                    
            for (AggregateResult ar : compAggResList)  {
                if(ar.get('bthousetracker__Status__c') == 'Active'){
                    totActiveParts +=  (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Pending'){
                    totPendingParts += (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Archive'){
                    toArchiveparts += (Integer) ar.get('expr0');
                }
            }
            
            
           //Get product count for parts depending on status.
           List<AggregateResult> proAggResList = [SELECT bthousetracker__Status__c,
                                                         Count(Id)
                                                  FROM bthousetracker__Supplier_Door_Products__c
                                                  WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                  GROUP BY bthousetracker__Status__c];
                                                     
           for (AggregateResult ar : proAggResList)  {
                if(ar.get('bthousetracker__Status__c') == 'Active'){
                    totActiveParts +=  (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Pending'){
                    totPendingParts += (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Archive'){
                    toArchiveparts += (Integer) ar.get('expr0');
                }
            }
            
            totParts = totActiveParts + totPendingParts + toArchiveparts; // Total Parts.
            
            partsCountMap.put('totalParts', totParts);
            partsCountMap.put('activeParts', totActiveParts);
            partsCountMap.put('pendingParts', totPendingParts);
            partsCountMap.put('archiveParts', toArchiveparts);

            return new SPComN_Wrapper.catalogInfoWrraper(true, JSON.serialize(partsCountMap), 'Successfully fetched the records');
        }
        return new SPComN_Wrapper.catalogInfoWrraper(false, null, 'Could not find the catalog');
    }
    
    
     /*
        @ Purpose     : Method to get count of Pricing table with respect to given catalog Id.
        @ Parameter   : catalogId.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.catalogInfoWrraper getPricingCount(String catalogId){
        Integer totPricing = 0;
        Integer totActivePricing = 0;
        Integer totPendingPricing = 0;
        Integer toArchivePricing = 0;
        
        Map<String, Integer> PricingCountMap = new Map<String, Integer>();
        
        if(String.isNotBlank(catalogId)){        
            //Get pricing count for catalog depending on status.
            List<AggregateResult> pricingAggResList = [SELECT bthousetracker__Status__c, 
                                                              Count(Id)
                                                       FROM bthousetracker__Supplier_Pricing_Table__c
                                                       WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                       GROUP BY  bthousetracker__Status__c];
            
            System.debug('pricingAggResList=='+pricingAggResList);
                                                    
            for (AggregateResult ar : pricingAggResList)  {
                if(ar.get('bthousetracker__Status__c') == 'Active'){
                    totActivePricing +=  (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Pending'){
                    totPendingPricing += (Integer) ar.get('expr0');
                }else if(ar.get('bthousetracker__Status__c') == 'Archive'){
                    toArchivePricing += (Integer) ar.get('expr0');
                }
            }
            
            totPricing = totActivePricing + totPendingPricing + toArchivePricing; // Total Pricings.
            
            PricingCountMap.put('totalPricing', totPricing);
            PricingCountMap.put('activePricing', totActivePricing);
            PricingCountMap.put('pendingPricing', totPendingPricing);
            PricingCountMap.put('archivePricing', toArchivePricing);
            
            System.debug(JSON.serialize(PricingCountMap));
            return new SPComN_Wrapper.catalogInfoWrraper(true, JSON.serialize(PricingCountMap), 'Successfully fetched the records');
        }
        return new SPComN_Wrapper.catalogInfoWrraper(false, null, 'Could not find the catalog');
    }
    
    /*
        @ Purpose     : Method to get count of pricing with respect to zones and given catalog Id.
        @ Parameter   : catalogId.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.catalogInfoWrraper getPricingZoneDetails(String catalogId){
        Integer totZones = 0;
        Integer totZonedPricing = 0;
        Integer totNonZonePricing = 0;
        
        Map<String, Integer> ZonesCountMap = new Map<String, Integer>();
        
        //getCount on Zone
        AggregateResult zoneAggReslt = [SELECT Count(Id)
                                        FROM bthousetracker__Supplier_Zones__c];
                                        
        if(String.isNotBlank(catalogId)){
            //Get pricing count for zones for zoned and non zone.
            List<AggregateResult> pricingAggResList = [SELECT bthousetracker__Supplier_Zone__c, 
                                                              Count(Id)
                                                       FROM bthousetracker__Supplier_Pricing_Table__c
                                                       WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId 
                                                       GROUP BY bthousetracker__Supplier_Zone__c];
           
            for (AggregateResult ar : pricingAggResList)  {
                if(ar.get('bthousetracker__Supplier_Zone__c') == null){
                    totNonZonePricing +=  (Integer) ar.get('expr0');
                }else{ 
                    totZonedPricing += (Integer) ar.get('expr0');
                }
            }
            
            ZonesCountMap.put('totalZones', (Integer) zoneAggReslt.get('expr0'));
            ZonesCountMap.put('zoneRec', totZonedPricing);
            ZonesCountMap.put('nonZoneRec', totNonZonePricing);
            
            System.debug(JSON.serialize(ZonesCountMap));
            return new SPComN_Wrapper.catalogInfoWrraper(true, JSON.serialize(ZonesCountMap), 'Successfully fetched the records');
        }
        return new SPComN_Wrapper.catalogInfoWrraper(false, null, 'Could not find the catalog');
    }
    
    /*
        @ Purpose     : Method to get count of pricing with respect to tiers and given catalog Id.
        @ Parameter   : catalogId.
        @ Return Type : String.      
    */
    @RemoteAction
    public Static SPComN_Wrapper.catalogInfoWrraper getPricingTiersDetails(String catalogId){
        Integer totTiers = 0;
        Integer totTiersPricing = 0;
        Integer totNonTiersPricing = 0;
        
        Map<String, Integer> TiersCountMap = new Map<String, Integer>();
        
        //Gey Count for tier
        AggregateResult tiersAggReslt = [SELECT Count(Id)
                                        FROM bthousetracker__Supplier_Tier__c];
                                        
        if(String.isNotBlank(catalogId)){
            //Get pricing count for zoens for zoned and non zone.
            List<AggregateResult> pricingAggResList = [SELECT bthousetracker__Supplier_Tier__c, 
                                                              Count(Id)
                                                       FROM bthousetracker__Supplier_Pricing_Table__c
                                                       WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId 
                                                       GROUP BY bthousetracker__Supplier_Tier__c];
           
            for (AggregateResult ar : pricingAggResList)  {
                if(ar.get('bthousetracker__Supplier_Tier__c') == null){
                    totNonTiersPricing +=  (Integer) ar.get('expr0');
                }else{ 
                    totTiersPricing += (Integer) ar.get('expr0');
                }
            }
            
            TiersCountMap.put('totalTiers', (Integer) tiersAggReslt.get('expr0'));
            TiersCountMap.put('TieredRec', totTiersPricing);
            TiersCountMap.put('nonTieredRec', totNonTiersPricing);
            
            System.debug(JSON.serialize(TiersCountMap));
            return new SPComN_Wrapper.catalogInfoWrraper(true, JSON.serialize(TiersCountMap), 'Successfully fetched the records');
        }
        return new SPComN_Wrapper.catalogInfoWrraper(false, null, 'Could not find the catalog');
    }
    
    /*
        @ Purpose     : Method to send Pending Records for Approval.
        @ Parameter   : CatalogId.
        @ Return Type : SPCom_Wrapper.PageMessage.      
    */  
    @remoteAction
    public static SPComN_Wrapper.Response doApproval(String catalogId, String effectiveDate) {
        
        if(String.isNotBlank(catalogId)) {        
            bthousetracker__Supplier_Product_Catalog__c catalogRec;
            
            try{
                catalogRec = [SELECT Id, 
                                     Name,
                                     bthousetracker__Supplier__c, 
                                     bthousetracker__Status__c, 
                                     bthousetracker__Activate_Date__c
                              FROM bthousetracker__Supplier_Product_Catalog__c                                              
                              WHERE Id =: catalogId];
                
                catalogRec.bthousetracker__Activate_Date__c = date.parse(effectiveDate);    
                update catalogRec;                 
                            
            }catch(Exception ex){                
                System.debug('Exception '+ ex.getMessage());
                return new SPComN_Wrapper.Response(false, 'Could not find the catalog.', null); 
            }
            
            if(catalogRec.bthousetracker__Activate_Date__c != null){
                System.debug('catalogId'+ catalogId);
                try { 
                    Boolean isSuccess = SPComN_Utils.requestApproval('', catalogId);//
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
        return SPComN_ProductCatalogCntrl.archiveCatalog(catalogId);
    }

    /*
        @ Purpose     : Method to clone product catalogs.
        @ Parameter   : records[list of Catalogs to edit].
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response saveCatalog(String catalogToCloneId, String catalogName, String effectiveDate){
        String errorMessage;
        String namePrefx = 'bthousetracker__';
        if(String.isNotBlank(catalogToCloneId) && String.isNotBlank(catalogName)){
            
            Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMap = new Map<Id, bthousetracker__Supplier_Components__c>();
            Map<Id, bthousetracker__Supplier_Door_Products__c> oldIdClonedProductsMap = new Map<Id, bthousetracker__Supplier_Door_Products__c>();
            
            List<bthousetracker__Supplier_Products_Components__c> productRuleToInsertList = new List<bthousetracker__Supplier_Products_Components__c>();
            List<bthousetracker__Lead_Time__c> leadTimeList = new List<bthousetracker__Lead_Time__c>();
            List<bthousetracker__Supplier_Pricing_Table__c> pricingList = new List<bthousetracker__Supplier_Pricing_Table__c>();
            
            oldIdClonedComponentsMap = SPComN_Utils.getoldIdClonedComponentsMap(catalogToCloneId);
            oldIdClonedProductsMap = SPComN_Utils.getoldIdClonedProductsMap(catalogToCloneId);
            
            productRuleToInsertList = SPComN_Utils.getproductRulesToCloneList(catalogToCloneId);
            leadTimeList = SPComN_Utils.getLeadTimesToCloneList(catalogToCloneId);
            
            pricingList = SPComN_Utils.getPricingList(catalogToCloneId);
            System.debug('pricingList ..'+ pricingList);
            
            bthousetracker__Supplier_Product_Catalog__c catalogRec = [SELECT Id, 
                                                                             Name, 
                                                                             bthousetracker__Status__c, 
                                                                             bthousetracker__Approval_Status__c, 
                                                                             bthousetracker__BBNA_Status__c,
                                                                             bthousetracker__BBNA_Product_Category__r.Name, 
                                                                             CreatedBy.Name, 
                                                                             bthousetracker__BBNA_Product_Category__c,
                                                                             LastModifiedDate, 
                                                                             CreatedDate, 
                                                                             LastModifiedBy.Name 
                                                                      FROM bthousetracker__Supplier_Product_Catalog__c
                                                                      WHERE Id =: catalogToCloneId];
                          
            bthousetracker__Supplier_Product_Catalog__c newCatalog = new bthousetracker__Supplier_Product_Catalog__c();
            newCatalog.bthousetracker__Status__c = 'Pending';
            newCatalog.bthousetracker__BBNA_Product_Category__c = catalogRec.bthousetracker__BBNA_Product_Category__c;
            
            // Call method to generate SOQL for Supplier product catalog fields
            String query = SPComN_Utils.getCreatableFieldsSOQL(namePrefx+'Supplier_Product_Catalog__c', 'Id =: catalogToCloneId');
            
            // Query and clone current catalog
            if(String.isNotBlank(query)){
                
                bthousetracker__Supplier_Product_Catalog__c catalogToClone = new bthousetracker__Supplier_Product_Catalog__c();
                catalogToClone = Database.query(query);
                
                newCatalog = catalogToClone.clone(false, true);
                newCatalog.bthousetracker__Status__c = 'Pending'; 
                newCatalog.bthousetracker__Activate_Date__c = null;
                newCatalog.bthousetracker__BBNA_Status__c = 'Not Requested';
            } 
                     
            newCatalog.Name = catalogName;
            
            if(String.isNotBlank(effectiveDate))
                newCatalog.bthousetracker__Activate_Date__c = date.parse(effectiveDate);
            
            try{
                insert newCatalog;
                reparentingComponentAndProduct( newCatalog.Id, oldIdClonedComponentsMap.values(), oldIdClonedProductsMap.values() );
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Success! Supplier product catalog is updated!')); 
                //errorString = new SPCom_Wrapper.PageMessage(false, 'Supplier product catalog is updated!');           
            }
            catch(Exception e){
                System.debug('Exception in updating new datalog : ' + e.getMessage());
                if(e.getMessage().contains('Catalog Name Already Present For Give Supplier')){
                    errorMessage = 'Catalog Name Already Present For Given Supplier';
                }else{
                    errorMessage = e.getMessage();
                }
                return new SPComN_Wrapper.Response(false, errorMessage, null, null);
            }
            
            try{
                
                insert oldIdClonedComponentsMap.values();
                insert oldIdClonedProductsMap.values();
                
                reparentingProductRuleAndLeadTime( productRuleToInsertList, leadTimeList, oldIdClonedComponentsMap, oldIdClonedProductsMap );
                pricingList = reparentingPricing(newCatalog.id, pricingList, oldIdClonedComponentsMap, oldIdClonedProductsMap );
                
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Success! Supplier product catalog is updated!')) ;
                //errorString = new SPCom_Wrapper.PageMessage(false, 'Supplier product catalog is updated!');           
            }
            catch(Exception e){
                System.debug('Exception in updating new datalog : ' + e.getMessage());
                
                if(e.getMessage().contains('There is already a Component with given Product Name in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Component with given Product Name in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Component with given Part Number in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Component with given Part Number in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Product with given Product Name in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Product with given Product Name in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Product with given Part Number in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Product with given Part Number in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Component with given Component Name in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Component with given Component Name in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Component with given Part Number in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Component with given Part Number in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Product with given Component Name in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Product with given Component Name in this catalog. Please change and save again.';
                    
                }else if(e.getMessage().contains('There is already a Product with given Part Number in this catalog. Please change and save again')){
                    errorMessage = 'There is already a Product with given Part Number in this catalog. Please change and save again.';
                    
                }else{
                    errorMessage = e.getMessage();
                    
                }
                return new SPComN_Wrapper.Response(false, errorMessage, null, null);
            }
            
            System.debug('pricingList reparent...'+ pricingList);
            
            try{
                insert productRuleToInsertList;
                insert leadTimeList;
                insert pricingList;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info, 'Success! Supplier product catalog is updated!')) ;           
            }
            catch(Exception e){
                System.debug('Exception in updating new datalog : ' + e.getMessage());
                return new SPComN_Wrapper.Response(false, e.getMessage(), null, null);
            }
      
            if(String.isNotBlank(newCatalog.Id)) {
                return new SPComN_Wrapper.Response(true, 'Successfully cloned the catalog', newCatalog, null);
            }
        }
        return new SPComN_Wrapper.Response(false, 'Catalog Id not present', null, null);
    }
    
    
    /*
        @ Purpose     : methode to do reparenting for cloned elements.
        @ Parameter   : newCatalogId, oldIdClonedComponentsMapValues, oldIdClonedProductsMapValues.
        @ Return Type : Void. 
    */  
    public static void reparentingComponentAndProduct( String newCatalogId, List<bthousetracker__Supplier_Components__c>   oldIdClonedComponentsMapValues, List<bthousetracker__Supplier_Door_Products__c> oldIdClonedProductsMapValues ){
        if( oldIdClonedComponentsMapValues != NULL && !oldIdClonedComponentsMapValues.isEmpty() && String.isNotBlank(newCatalogId)){
            for( bthousetracker__Supplier_Components__c component : oldIdClonedComponentsMapValues ){
                component.bthousetracker__Supplier_Product_Catalog__c = newCatalogId;
            }
        }
        
        if( oldIdClonedProductsMapValues != NULL && !oldIdClonedProductsMapValues.isEmpty() && String.isNotBlank(newCatalogId)){
            for( bthousetracker__Supplier_Door_Products__c product : oldIdClonedProductsMapValues ){
                product.bthousetracker__Supplier_Product_Catalog__c = newCatalogId;
            }
        }
    }
    
     /*
        @ Purpose : methode to do reparenting for cloned elements.
        @ Parameter   : newCatalogId, oldIdClonedComponentsMapValues, oldIdClonedProductsMapValues.
        @ Return Type : Void. 
    */  
    public Static void reparentingProductRuleAndLeadTime( List<bthousetracker__Supplier_Products_Components__c> productRuleList, 
                                                    List<bthousetracker__Lead_Time__c> leadTimeList,
                                                    Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMapValues, 
                                                    Map<Id, bthousetracker__Supplier_Door_Products__c> oldIdClonedProductsMapValues ){
        
        if( oldIdClonedComponentsMapValues != NULL && !oldIdClonedComponentsMapValues.isEmpty() && 
            productRuleList != NULL && !productRuleList.isEmpty() ){
                
            for( bthousetracker__Supplier_Products_Components__c rule : productRuleList ){
                if(String.isNotBlank( rule.bthousetracker__Supplier_Component__c )){
                    if(oldIdClonedComponentsMapValues.containsKey(rule.bthousetracker__Supplier_Component__c)){
                        rule.bthousetracker__Supplier_Component__c = oldIdClonedComponentsMapValues.get(rule.bthousetracker__Supplier_Component__c).Id;
                    }
                }
            }
        }
        
        if( oldIdClonedProductsMapValues != NULL && !oldIdClonedProductsMapValues.isEmpty() && 
            productRuleList != NULL && !productRuleList.isEmpty() ){
            System.debug('...productRuleList'+productRuleList);
            for( bthousetracker__Supplier_Products_Components__c rule : productRuleList ){
                if(String.isNotBlank( rule.bthousetracker__Supplier_Product__c )){
                    if(oldIdClonedProductsMapValues.containsKey(rule.bthousetracker__Supplier_Product__c)){
                        rule.bthousetracker__Supplier_Product__c = oldIdClonedProductsMapValues.get(rule.bthousetracker__Supplier_Product__c).Id;
                    }
                }
            }
        }
        
        if( oldIdClonedComponentsMapValues != NULL && !oldIdClonedComponentsMapValues.isEmpty() && 
            leadTimeList != NULL && !leadTimeList.isEmpty() ){
                
            for( bthousetracker__Lead_Time__c leadTime : leadTimeList ){
                if(String.isNotBlank( leadTime.bthousetracker__Supplier_Component__c )){
                    if(oldIdClonedComponentsMapValues.containsKey(leadTime.bthousetracker__Supplier_Component__c)){
                        leadTime.bthousetracker__Supplier_Component__c = oldIdClonedComponentsMapValues.get(leadTime.bthousetracker__Supplier_Component__c).Id;
                    }
                }
            }
        }
        
        if( oldIdClonedProductsMapValues != NULL && !oldIdClonedProductsMapValues.isEmpty() && 
            leadTimeList != NULL && !leadTimeList.isEmpty() ){
            for( bthousetracker__Lead_Time__c leadTime : leadTimeList ){
                if(String.isNotBlank( leadTime.bthousetracker__Supplier_Door_Product__c )){                    
                    if(oldIdClonedProductsMapValues.containsKey(leadTime.bthousetracker__Supplier_Door_Product__c)){
                        leadTime.bthousetracker__Supplier_Door_Product__c = oldIdClonedProductsMapValues.get(leadTime.bthousetracker__Supplier_Door_Product__c).Id;
                    }
                }
            }
        }
        System.debug('...productRuleList'+productRuleList);
    }
    
    
     /*
        @ Purpose : methode to do reparenting for cloned elements.
        @ Parameter   : newCatalogId, pricingList, oldIdClonedComponentsMapValues, oldIdClonedProductsMapValues.
        @ Return Type : List<Supplier_Pricing_Table__c>. 
    */ 
    public Static List<bthousetracker__Supplier_Pricing_Table__c> reparentingPricing(ID newCatalogId, List<bthousetracker__Supplier_Pricing_Table__c> pricingList, 
                                                                     Map<Id, bthousetracker__Supplier_Components__c> oldIdClonedComponentsMapValues, 
                                                                     Map<Id, bthousetracker__Supplier_Door_Products__c> oldIdClonedProductsMapValues){
    
        if(pricingList != null && !pricingList.isEmpty()){
            for(bthousetracker__Supplier_Pricing_Table__c pricing : pricingList){
                if(pricing.bthousetracker__Supplier_Component__c != null && oldIdClonedComponentsMapValues.containsKey(pricing.bthousetracker__Supplier_Component__c)){
                    pricing.bthousetracker__Supplier_Component__c = oldIdClonedComponentsMapValues.get(pricing.bthousetracker__Supplier_Component__c).id;
                    pricing.bthousetracker__Supplier_Product_Catalog__c = newCatalogId;
                }
                
                if(pricing.bthousetracker__Supplier_Product__c != null && oldIdClonedProductsMapValues.containsKey(pricing.bthousetracker__Supplier_Product__c )){
                    pricing.bthousetracker__Supplier_Product__c = oldIdClonedProductsMapValues.get(pricing.bthousetracker__Supplier_Product__c ).id;
                    pricing.bthousetracker__Supplier_Product_Catalog__c = newCatalogId;
                }
                
                 
            }
        } 
        return pricingList;                       
    }
    
    /*
        @ Purpose     : Method to redirect to page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToDetailPage() {
        Map<String, String> paramMap = new Map<String, String>();
        PageReference pageRef = SPComN_Utils.routeTo('SPComN_CatalogDetailPage', paramMap);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
     /*
        @ Purpose     : Method to redirect to parts page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectTopartsPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        System.debug('CatalogId---->'+ catalogId);
        
        if(String.isNotBlank(catalogId))
            paramMap.put('catalogId', catalogId);
            
        PageReference pageRef =SPComN_Utils.routeTo('SPComN_CatalogProductPage', paramMap);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /*
        @ Purpose     : Method to redirect to Pricing page.
        @ Parameter   : None.
        @ Return Type : PageReference.      
    */
    public PageReference redirectToPricingPage() {
        Map<String, String> paramMap = new Map<String, String>();
        
        String catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        System.debug('CatalogId---->'+ catalogId);
        
        if(String.isNotBlank(catalogId))
            paramMap.put('catalogId', catalogId);
            
        PageReference pageRef =SPComN_Utils.routeTo('SPComN_PricingPage', paramMap);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
      /*
        @ Purpose     : Method to get part history for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response getPartsHistory(String catalogId){
        String historyStr;
        Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
        List<historyInfoWrapper> historyInfoWrapperList = new List<historyInfoWrapper>();
                                                            
        if(String.isNotBlank(catalogId)){
            //get history for component created.
            for(bthousetracker__Supplier_Components__c compRec : [SELECT Id, 
                                                                         CreatedDate, 
                                                                         bthousetracker__Supplier_Option_Id__c, 
                                                                         CreatedBy.Name,
                                                                         LastModifiedDate,
                                                                         LastModifiedBy.Name
                                                                  FROM bthousetracker__Supplier_Components__c 
                                                                  WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                                  ORDER BY CreatedDate DESC
                                                                  LIMIT 5]){
                 
                if(compRec.CreatedDate == compRec.LastModifiedDate){                    
                     historyStr = compRec.CreatedBy.Name + ' Created part# ' + compRec.bthousetracker__Supplier_Option_Id__c;
                     dateTimeStrMap.put(compRec.CreatedDate, historyStr);                    
                }else{
                    historyStr = compRec.LastModifiedBy.Name + ' Last Modified part #' + compRec.bthousetracker__Supplier_Option_Id__c;
                    dateTimeStrMap.put(compRec.CreatedDate, historyStr);
                }
                
            }
            
            //get history for Product created.
            for(bthousetracker__Supplier_Door_Products__c proRec : [SELECT Id, 
                                                                           CreatedDate, 
                                                                           bthousetracker__Supplier_Part__c, 
                                                                           CreatedBy.Name,
                                                                           LastModifiedDate,
                                                                           LastModifiedBy.Name
                                                                     FROM bthousetracker__Supplier_Door_Products__c
                                                                     WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                                     ORDER BY CreatedDate DESC
                                                                     LIMIT 5]){
                if(proRec.CreatedDate == proRec.LastModifiedDate){                                                       
                     historyStr = proRec.CreatedBy.Name + ' Created part# ' + proRec.bthousetracker__Supplier_Part__c;
                    dateTimeStrMap.put(proRec.CreatedDate, historyStr);
                }else{
                    historyStr = proRec.LastModifiedBy.Name + ' Last Modified part #' + proRec.bthousetracker__Supplier_Part__c;
                    dateTimeStrMap.put(proRec.CreatedDate, historyStr); 
                }
                 
            }
            
            Set<Id>  partsIds = getPartsIds(CatalogId); //get part Ids(Product and components). 
            Set<Id> processInstPartIds = new  Set<Id>(); //get targetId of processInstance.
            List<ProcessInstance> ProcessInstanceList;
            
            String prartName;
            
            System.debug('partsw Idss@@' + partsIds);
          
            if(!partsIds.isEmpty()){
                     ProcessInstanceList = [SELECT Id, 
                                                   TargetObjectId, 
                                                   Status, 
                                                   TargetObject.type, 
                                                   CompletedDate, 
                                                   CreatedDate, 
                                                   SubmittedBy.Name, 
                                                   LastActor.Name
                                             FROM ProcessInstance 
                                             WHERE TargetObjectId IN: partsIds 
                                             ORDER BY CreatedDate DESC
                                             LIMIT 5];
                    
                    System.debug('ProcessInstanceList @@@' + ProcessInstanceList); 
                                           
                    for(ProcessInstance currRec : ProcessInstanceList){
                        processInstPartIds.add(currRec.TargetObjectId);                          
                    }
                    
                    if(!processInstPartIds.isEmpty() && !ProcessInstanceList.isEmpty() && processInstPartIds != null && ProcessInstanceList != null){
                         Map<DateTime, String> apprvalHistoryMap = new Map<DateTime, String>();
                         
                         apprvalHistoryMap = getApprovalHistroyCmp(processInstPartIds, ProcessInstanceList);
                         
                         System.debug('### approval history map '+  apprvalHistoryMap);
                         if(apprvalHistoryMap != null){
                             dateTimeStrMap.putAll(apprvalHistoryMap );// Get Approval history for Components
                         }
                         
                         apprvalHistoryMap = getApprovalHistroyPro(processInstPartIds, ProcessInstanceList);
                         System.debug('### approval history map '+  apprvalHistoryMap);

                         if(apprvalHistoryMap != null){
                             dateTimeStrMap.putAll(apprvalHistoryMap);// Get Approval history for Products
                         }
                    }
                    
            }
            
            System.debug('### approval history map dateTimeStrMap '+  dateTimeStrMap);
            //dateTimeStrMap.putAll(getLastModifyHistroy(catalogId));
            
            System.debug('### approval history map dateTimeStrMap '+  dateTimeStrMap);
        
            Map<String, string> historyMap = new Map<String, string>();
            List<DateTime> toSortDateDecList = new List<DateTime>(); 
            
            if(!dateTimeStrMap.isEmpty()){
            
                List<DateTime> toSortDateTimeList = new List<DateTime>();
                
                toSortDateTimeList.addAll(dateTimeStrMap.keySet());
                toSortDateTimeList.sort();
                
                System.debug('Ace order list '+ toSortDateTimeList);
                
                //Sort List in decenfing order
                for(Integer i = toSortDateTimeList.size()-1; i>=0;i--){
                    toSortDateDecList.add(toSortDateTimeList.get(i));
                }
                
               
                //Get top 5 recent history for parts
                for(Integer i=0; i<toSortDateDecList.size();i++){
                    historyInfoWrapper historyInfoWrapperRec = new historyInfoWrapper();
                    if(i<5){
                        historyInfoWrapperRec.historydate = toSortDateDecList.get(i).format();
                        historyInfoWrapperRec.historyStr = dateTimeStrMap.get(toSortDateDecList.get(i));
                        historyInfoWrapperList.add(historyInfoWrapperRec);
                    }
                }
                
            }
            
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response(true, 'Successful: In getting par histroy', historyInfoWrapperList);
            return response ;
        }
        
        return new SPComN_Wrapper.Response(false, 'Error: In getting par histroy CatalogId not present', null);
    }
    
    /*
        @ Purpose     : Method to get Aprroval history for Component parts.
        @ Parameter   : Set<Id> processInstPartIds, List<ProcessInstance> ProcessInstanceList.
        @ Return Type : Map<DateTime, String>.      
    */ 
    public static Map<DateTime, String> getApprovalHistroyCmp(Set<Id> processInstPartIds, List<ProcessInstance> ProcessInstanceList){
       Map<Id, bthousetracker__Supplier_Components__c> compMap = new  Map<Id, bthousetracker__Supplier_Components__c>([SELECT Id, 
                                                                                                                              bthousetracker__Supplier_Option_Id__c, 
                                                                                                                              bthousetracker__isDelete__c
                                                                                                                       FROM bthousetracker__Supplier_Components__c
                                                                                                                       WHERE Id IN: processInstPartIds]);
      
       String historyStr;
       Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();  
                                                                                                                      
       for(ProcessInstance currRec : ProcessInstanceList){
       
           if(compMap.containsKey(currRec.TargetObjectId)){
           
              if(compMap.get(currRec.TargetObjectId).bthousetracker__isDelete__c != true){
              
                  if(currRec.Status != 'Pending'){
                  
                      historyStr = currRec.LastActor.Name +' '+ currRec.Status + ' part #' + compMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Option_Id__c;
                      dateTimeStrMap.put(currRec.CompletedDate, historyStr);
                      
                  }else{
                  
                      historyStr = currRec.SubmittedBy.Name +' has submitted part #' + compMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Option_Id__c;
                      dateTimeStrMap.put(currRec.CreatedDate, historyStr);
                      
                  }
              }else{
             
                   if(currRec.Status != 'Pending'){
                   
                      historyStr = currRec.LastActor.Name +' '+ currRec.Status + ' deactivation of part #' + compMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Option_Id__c;
                      dateTimeStrMap.put(currRec.CompletedDate, historyStr);
                      
                  }else{
                  
                      historyStr = currRec.SubmittedBy.Name +' has submitted part #' + compMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Option_Id__c;
                      dateTimeStrMap.put(currRec.CreatedDate, historyStr);
                      
                 }
              }
           }
       }
       
       if(!dateTimeStrMap.isEmpty()){       
           return dateTimeStrMap;  
       }else{
           return null;
       }                                                                                                                
    }
    
    
    /*
        @ Purpose     : Method to get Aprroval history for Product parts.
        @ Parameter   : Set<Id> processInstPartIds, List<ProcessInstance> ProcessInstanceList.
        @ Return Type : Map<DateTime, String>.      
    */
    public static Map<DateTime, String> getApprovalHistroyPro(Set<Id> processInstPartIds, List<ProcessInstance> ProcessInstanceList){
       Map<Id, bthousetracker__Supplier_Door_Products__c> proMap = new  Map<Id, bthousetracker__Supplier_Door_Products__c>([SELECT Id, 
                                                                                                                                   bthousetracker__Supplier_Part__c,
                                                                                                                                   bthousetracker__isDelete__c
                                                                                                                            FROM bthousetracker__Supplier_Door_Products__c
                                                                                                                            WHERE Id IN: processInstPartIds]);
      
       String historyStr;
       Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>(); 
                                                                                                                       
       for(ProcessInstance currRec : ProcessInstanceList){
       
           if(proMap.containsKey(currRec.TargetObjectId)){
           
              if(proMap.get(currRec.TargetObjectId).bthousetracker__isDelete__c != true){
              
                  if(currRec.Status != 'Pending'){
                  
                      historyStr = currRec.LastActor.Name +' '+ currRec.Status + ' part #' + proMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Part__c;
                      dateTimeStrMap.put(currRec.CompletedDate, historyStr);
                      
                  }else{
                  
                      historyStr = currRec.SubmittedBy.Name +' has submitted part #' + proMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Part__c;
                      dateTimeStrMap.put(currRec.CreatedDate, historyStr);
                  }
              }else{
                   if(currRec.Status != 'Pending'){
                      historyStr = currRec.LastActor.Name +' '+ currRec.Status + ' deactivation of part #' + proMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Part__c;
                      dateTimeStrMap.put(currRec.CompletedDate, historyStr);
                      
                  }else{
                  
                      historyStr = currRec.SubmittedBy.Name +' has submitted part #' + proMap.get(currRec.TargetObjectId).bthousetracker__Supplier_Part__c;
                      dateTimeStrMap.put(currRec.CreatedDate, historyStr);
                  }
              }
           }
       }
       
       if(!dateTimeStrMap.isEmpty()){
           return dateTimeStrMap;  
       }else{
           return null;
       }                                                                                                                
    }
    
    /*
        @ Purpose     : Method to get part Ids for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : Set<Id>.      
    */
    public Static Set<Id> getPartsIds(String CatalogId){
        Set<Id> partsIds = new Set<Id>();
        
        if(String.isNotBlank(CatalogId)){
            try{
                //Get product and component Ids as parts.
                bthousetracker__Supplier_Product_Catalog__c productCatalogRec = [SELECT Id,
    
                                                                        (SELECT Id, CreatedDate, bthousetracker__Supplier_Option_Id__c, 
                                                                                CreatedBy.Name
                                                                         FROM bthousetracker__Supplier_Components__r),
                                                                         
                                                                        (SELECT Id, CreatedDate, bthousetracker__Supplier_Part__c,
                                                                                CreatedBy.Name
                                                                         FROM bthousetracker__Supplier_Products__r)
                                                                        
                                                                FROM bthousetracker__Supplier_Product_Catalog__c 
                                                                WHERE Id =: CatalogId];
                for(bthousetracker__Supplier_Door_Products__c prodRec : productCatalogRec.bthousetracker__Supplier_Products__r){
                    partsIds.add(prodRec.Id);               
                }
                for(bthousetracker__Supplier_Components__c compRec : productCatalogRec.bthousetracker__Supplier_Components__r){
                    partsIds.add(compRec.Id);           
                }
                
                return partsIds;
                                                                
            }catch(Exception ex){
                System.debug('Expection has occured'+ ex.getMessage());
            }                                               
        }
        return null;
    }
    
    /*
        @ Purpose     : Method to get pricing created History for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : Map<DateTime, String>.      
    */
    public static Map<DateTime, String> getPricingHistoryInfo(String catalogId){
        String historyStr;
        Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
        
        if(String.isNotBlank(catalogId)){
           for(bthousetracker__Supplier_Pricing_Table__c pricingRec : [SELECT Id, 
                                                                              CreatedDate,
                                                                              CreatedBy.Name,
                                                                              LastModifiedDate, 
                                                                              LastModifiedBy.Name,
                                                                              bthousetracker__Type__c,
                                                                              bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c,
                                                                              bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Option_Id__c
                                                                       FROM bthousetracker__Supplier_Pricing_Table__c 
                                                                       WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId
                                                                       ORDER BY CreatedDate DESC
                                                                       LIMIT 5]){
                
                 if(pricingRec.CreatedDate == pricingRec.LastModifiedDate){
                     
                        historyStr = pricingRec.CreatedBy.Name + ' Created Pricng ';
                        if(pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c != null || 
                           pricingRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Option_Id__c != null){
                               historyStr += ' for part #'+ pricingRec.bthousetracker__Type__c == 'Product' ? pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c: pricingRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Option_Id__c;
                        }
                        dateTimeStrMap.put(pricingRec.CreatedDate, historyStr); 
                                                                           
                }else{
                    
                    historyStr = pricingRec.CreatedBy.Name + ' Updated Pricng';
                    if(pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c != null || 
                       pricingRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Option_Id__c != null){
                       historyStr += ' for part #'+ pricingRec.bthousetracker__Type__c == 'Product' ? pricingRec.bthousetracker__Supplier_Product__r.bthousetracker__Supplier_Part__c: pricingRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Option_Id__c;
                    }
                    dateTimeStrMap.put(pricingRec.CreatedDate, historyStr); 
                    
                }
            }
        }
        return dateTimeStrMap;
    }
    
    /*
        @ Purpose     : Method to get Zones last modified and created History for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : Map<DateTime, String>.      
    */
    public static Map<DateTime, String> getZonehistoryInfo(String catalogId){
        String historyStr;
        Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
        
        if(String.isNotBlank(catalogId)){
           for(bthousetracker__Supplier_Zones__c zonesRec : [SELECT Id, 
                                                                    LastModifiedDate, 
                                                                    LastModifiedBy.Name,
                                                                    CreatedDate,
                                                                    CreatedBy.Name,
                                                                    Name 
                                                             FROM bthousetracker__Supplier_Zones__c 
                                                             ORDER BY LastModifiedDate DESC
                                                             LIMIT 5]){
                                                            
                if(zonesRec.CreatedDate != zonesRec.LastModifiedDate){
                
                    historyStr = zonesRec.LastModifiedBy.Name + ' Updated Zone ' + zonesRec.Name;
                    dateTimeStrMap.put(zonesRec.CreatedDate, historyStr); 
                    
                }else{
                
                    historyStr = zonesRec.CreatedBy.Name + ' Created Zone ' + zonesRec.Name;
                    dateTimeStrMap.put(zonesRec.CreatedDate, historyStr); 
                }
                
            }
        }
        return dateTimeStrMap;
    }
    
     /*
        @ Purpose     : Method to get Tiers last modified and created History for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : Map<DateTime, String>.      
    */
    public static Map<DateTime, String> getTiershistoryInfo(String catalogId){
        String historyStr;
        Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
        
        if(String.isNotBlank(catalogId)){
           for(bthousetracker__Supplier_Tier__c TierRec : [SELECT Id, 
                                                                  LastModifiedDate, 
                                                                  LastModifiedBy.Name,
                                                                  CreatedDate,
                                                                  CreatedBy.Name,
                                                                  Name 
                                                           FROM bthousetracker__Supplier_Tier__c
                                                           WHERE bthousetracker__Supplier_Product_Catalog__c =: catalogId 
                                                           ORDER BY LastModifiedDate DESC
                                                           LIMIT 5]){
                                                            
                if(TierRec.CreatedDate != TierRec.LastModifiedDate){
                
                    historyStr = TierRec.LastModifiedBy.Name + ' Updated Tier ' + TierRec.Name;
                    dateTimeStrMap.put(TierRec.CreatedDate, historyStr); 
                    
                }else{
                
                    historyStr = TierRec.CreatedBy.Name + ' Created Tier ' + TierRec.Name;
                    dateTimeStrMap.put(TierRec.CreatedDate, historyStr); 
                }
                
            }
        }
        return dateTimeStrMap;
    }
    
    
     /*
        @ Purpose     : Method to get Pricing history for given catalog.
        @ Parameter   : CatalogId.
        @ Return Type : SPCom_Wrapper.Response.      
    */
    @remoteAction
    public static SPComN_Wrapper.Response getPricingHistory(String catalogId){
        String historyStr;
        Map<DateTime, String> dateTimeStrMap = new Map<DateTime, String>();
        List<historyInfoWrapper> historyInfoWrapperList = new List<historyInfoWrapper>();
                                                            
        if(String.isNotBlank(catalogId)){                    
            
            dateTimeStrMap.putAll(getPricingHistoryInfo(catalogId));       // Get Pricing Created History.
            dateTimeStrMap.putAll(getZonehistoryInfo(catalogId));        //Get Zone history.
            dateTimeStrMap.putAll(getTiershistoryInfo(catalogId));      //Get Tiers history.
            
            Map<String, string> historyMap = new Map<String, string>();
            List<DateTime> toSortDateDecList = new List<DateTime>(); 
            
            if(!dateTimeStrMap.isEmpty()){
            
                List<DateTime> toSortDateTimeList = new List<DateTime>();
                
                toSortDateTimeList.addAll(dateTimeStrMap.keySet());
                toSortDateTimeList.sort();
                
                System.debug('Ace order list '+ toSortDateTimeList);
                
                //Sort List in decending order
                for(Integer i = toSortDateTimeList.size()-1; i>=0;i--){
                    toSortDateDecList.add(toSortDateTimeList.get(i));
                }
                
               
                //Get top 5 recent history for Pricing.
                for(Integer i=0; i<toSortDateDecList.size();i++){
                    historyInfoWrapper historyInfoWrapperRec = new historyInfoWrapper();
                    if(i<5){
                        historyInfoWrapperRec.historydate = toSortDateDecList.get(i).format();
                        historyInfoWrapperRec.historyStr = dateTimeStrMap.get(toSortDateDecList.get(i));
                        historyInfoWrapperList.add(historyInfoWrapperRec);
                    }
                }
                
            }
            
            SPComN_Wrapper.Response response = new SPComN_Wrapper.Response(true, 'Successful: In getting Pricing histroy', historyInfoWrapperList);
            return response ;
        }
        
        return new SPComN_Wrapper.Response(false, 'Error: In getting par histroy CatalogId not present', null);
    }    
    
    public Class catalogWrapper{
        public String id;
        public String name;
        public String category;
        public String status;
        public String approvalStatus;
        public String BBNAStatus;
        public String createdDate;
        public String createdBy;
        public String submitedDate;
        public String submitedBy;
        public String completedDate;
        public String approverStatus;
        public String actulApprover;
        public String lastUpdatedDate;
        public String updatedBy;
        
        public catalogWrapper(){
            
        }
        
        public catalogWrapper(bthousetracker__Supplier_Product_Catalog__c  catalogRec, ProcessInstance processInstanceRec){
            id = String.valueOf(catalogRec.Id);
            
            name = catalogRec.Name != null ? String.valueOf(catalogRec.Name): '';
            category = catalogRec.bthousetracker__BBNA_Product_Category__r.Name != null ? String.valueOf(catalogRec.bthousetracker__BBNA_Product_Category__r.Name): '';
            approvalStatus = catalogRec.bthousetracker__Approval_Status__c != null ? String.valueOf(catalogRec.bthousetracker__Approval_Status__c): '';
            createdDate = catalogRec.CreatedDate != null ? String.valueOf(catalogRec.CreatedDate.format()): '';
            
            BBNAStatus = catalogRec.bthousetracker__BBNA_Status__c!= null ? String.valueOf(catalogRec.bthousetracker__BBNA_Status__c): '';
            createdBy = catalogRec.CreatedBy.Name != null ? String.valueOf(catalogRec.CreatedBy.Name): '';
            lastUpdatedDate = catalogRec.LastModifiedDate != null ? String.valueOf(catalogRec.LastModifiedDate.format()): '';
            updatedBy = catalogRec.LastModifiedBy.Name != null ? String.valueOf(catalogRec.LastModifiedBy.Name): '';
            status = catalogRec.bthousetracker__Status__c != null ? String.valueOf(catalogRec.bthousetracker__Status__c): '';
            
            actulApprover = processInstanceRec.LastActor.Name != null ? String.valueOf(processInstanceRec.LastActor.Name): '';            
            submitedDate = processInstanceRec.CreatedDate != null ? String.valueOf(processInstanceRec.CreatedDate.format()): '';
            completedDate = processInstanceRec.CompletedDate != null ? String.valueOf(processInstanceRec.CompletedDate.format()): '';
            submitedBy = processInstanceRec.SubmittedBy.Name != null ? String.valueOf(processInstanceRec.SubmittedBy.Name) : '';
            approverStatus = processInstanceRec.Status != null ? String.valueOf(processInstanceRec.Status) : '';

        }
    }
    
     public Class historyInfoWrapper{
        public String historydate;
        public String historyStr;
        
        public historyInfoWrapper(){}
      
     }
}