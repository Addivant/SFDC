public class SPComN_PendingChangesForCatalog {
    public String supplierId {get; set;}
    public String catalogs {get;set;}
    public String types {get; set;}
    public string selectedEffectiveDate {get; set;}
    public string selectedSubmittedDate {get; set;}
    public string selectedApp_RejDate {get; set;} 
    public string changeType {get;set;}
    public String status {get;set;}
    public Date DateString {get;set;}
    public List<PendingPartWrapper>  pendingPartsList {get;set;}
    
    public SPComN_PendingChangesForCatalog() {
        supplierId =  SPComN_Utils.getSupplierAccount();
        catalogs = '';
        types='';
        selectedEffectiveDate = null;
        selectedSubmittedDate = null;
        selectedApp_RejDate = null;
        changeType = '';
        status = '';
        pendingPartsList = new List<PendingPartWrapper>();
        pendingPartsList = getPendingParts();
        DateString = Date.Today();
        System.debug('DateString'+DateString);

        
    } 
    
    public void withdrawApprovalRequest() {
        string partId = ApexPages.currentPage().getParameters().get('partId');
        string partType = Apexpages.currentPage().getParameters().get('partType');
        system.debug('partId '+partId);
        if(partType == 'Product') {
            bthousetracker__Supplier_Door_Products__c product = [select Id, bthousetracker__BBNA_Status__c,
                                                                (select Id from ProcessInstances order by CreatedDate DESC LIMIT 1) 
                                                                from bthousetracker__Supplier_Door_Products__c
                                                                where Id =:partId];
            if(product.ProcessInstances.size() > 0) {
                ProcessInstance p = [Select p.TargetObjectId, Id, Status, (Select Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, 
                            ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                            From Workitems order by createdDate desc) From ProcessInstance p where Id = :product.ProcessInstances[0].Id];
                system.debug('p: '+p); 
                system.debug('work items '+p.Workitems);
                if(p.Workitems.size() > 0) {
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Withdraw Request');
                    PWR.setAction('Removed');
                    PWR.setWorkitemId(p.Workitems[0].Id);
                    Approval.ProcessResult result =  Approval.process(PWR);
                }
            }
            if(product != null && (product.bthousetracker__BBNA_Status__c == 'Approved' || product.bthousetracker__BBNA_Status__c == 'Pending')) {
                product.bthousetracker__BBNA_Status__c = 'Withdrawn';
                product.bthousetracker__isDelete__c = false;
                update product;
             }
        } else if(partType == 'Component') {
            bthousetracker__Supplier_Components__c component = [select Id, bthousetracker__BBNA_Status__c,
                                                            (select Id from ProcessInstances order by CreatedDate DESC LIMIT 1) 
                                                                from bthousetracker__Supplier_Components__c
                                                                where Id =:partId];
            if(component.ProcessInstances.size() > 0) {
                ProcessInstance p = [Select p.TargetObjectId, Id, Status, (Select Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, 
                            ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                            From Workitems order by createdDate desc) From ProcessInstance p where Id = :component.ProcessInstances[0].Id];
                system.debug('p: '+p); 
                system.debug('work items '+p.Workitems);
                if(p.Workitems.size() > 0) {
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Withdraw Request');
                    PWR.setAction('Removed');
                    PWR.setWorkitemId(p.Workitems[0].Id);
                    Approval.ProcessResult result =  Approval.process(PWR);
                }
            }           
            
            if(component != null && (component.bthousetracker__BBNA_Status__c == 'Approved' || component.bthousetracker__BBNA_Status__c == 'Pending')) {
                component.bthousetracker__BBNA_Status__c = 'Withdrawn';
                component.bthousetracker__isDelete__c = false;
                update component;
              }   
        }
        /*ProcessInstance p = [Select p.TargetObjectId, Id, (Select Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, 
                            ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                            From Workitems) From ProcessInstance p where TargetObjectId = :partId order by createdDate Desc LIMIT 1];
        system.debug('p: '+p); */
        pendingPartsList = getPendingParts();
        system.debug('@@@@');
    }
    
    public void discardChanges(){
        string partId = ApexPages.currentPage().getParameters().get('partId');
        string partType = Apexpages.currentPage().getParameters().get('partType');
        system.debug('partId1' +partId);
            if(partType == 'Product') {
                bthousetracker__Supplier_Door_Products__c product = [select Id, bthousetracker__BBNA_Status__c,
                                                                (select Id from ProcessInstances order by CreatedDate DESC LIMIT 1) 
                                                                from bthousetracker__Supplier_Door_Products__c
                                                                where Id =:partId];
                if(product.ProcessInstances.size() > 0) {
                ProcessInstance p = [Select p.TargetObjectId, Id, Status, (Select Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, 
                            ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                            From Workitems order by createdDate desc) From ProcessInstance p where Id = :product.ProcessInstances[0].Id];
                system.debug('p: '+p); 
                system.debug('work items '+p.Workitems);
                if(p.Workitems.size() > 0) {
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Withdraw Request');
                    PWR.setAction('Removed');
                    PWR.setWorkitemId(p.Workitems[0].Id);
                    Approval.ProcessResult result =  Approval.process(PWR);
                }
            }
             if(product != null && (product.bthousetracker__BBNA_Status__c == 'Not Requested' || product.bthousetracker__BBNA_Status__c == 'Withdrawn' || product.bthousetracker__BBNA_Status__c == 'rejected' )) {
                product.bthousetracker__BBNA_Status__c = 'Archive';
                product.bthousetracker__isDelete__c = false;
                update product;                                                
            }
    }else if(partType == 'Component') {
            bthousetracker__Supplier_Components__c component = [select Id, bthousetracker__BBNA_Status__c,
                                                            (select Id from ProcessInstances order by CreatedDate DESC LIMIT 1) 
                                                                from bthousetracker__Supplier_Components__c
                                                                where Id =:partId];
            if(component.ProcessInstances.size() > 0) {
                ProcessInstance p = [Select p.TargetObjectId, Id, Status, (Select Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, 
                            ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp 
                            From Workitems order by createdDate desc) From ProcessInstance p where Id = :component.ProcessInstances[0].Id];
                system.debug('p: '+p); 
                system.debug('work items '+p.Workitems);
                if(p.Workitems.size() > 0) {
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Withdraw Request');
                    PWR.setAction('Removed');
                    PWR.setWorkitemId(p.Workitems[0].Id);
                    Approval.ProcessResult result =  Approval.process(PWR);
                }
            }
            if(component != null && (component.bthousetracker__BBNA_Status__c == 'Not Requested' || component.bthousetracker__BBNA_Status__c == 'Withdrawn' || component.bthousetracker__BBNA_Status__c == 'Rejected')) {
                component.bthousetracker__BBNA_Status__c = 'Archive';
                component.bthousetracker__isDelete__c = false;
                update component;
              }   
        }
        pendingPartsList = getPendingParts();
        system.debug('@@@@');            
  }
    public List<PendingPartWrapper> getPendingParts() { 
         
        List<PendingPartWrapper> pendingPartsList = new List<PendingPartWrapper>();
        
        //system.debug('filteredData '+filteredData);
        //Map<String, String> filterStringMap = (Map<String, String>)JSON.deserialize(filteredData, Map<String, String>.class);
        //system.debug('filterStringMap '+filterStringMap);
        
        //String catalog  = filterStringMap.get('catalogFilter');
        //String type  = filterStringMap.get('typeFilter');
        //String approvalEvent  = filterStringMap.get('approvalEventFilter');
        //String effDate  = filterStringMap.get('effectiveDateFilter');
        //String subDate  = filterStringMap.get('submittedDateFilter');
        //string compDate = filterStringMap.get('app_rejDateFilter');
        //string status = filterStringMap.get('statusFilter');
        
        //system.debug('catalog '+catalog+ ' type '+type+ ' approvalEvent '+approvalEvent+ ' effDate '+effDate+' subDate '+ subDate+ ' compDate '+compDate);
        //if(string.isNotBlank(effDate))
            //system.debug('date sample '+date.valueOf(effDate));
        
        string clause1 = ' ';
            
        string queryProd = 'select Id, bthousetracker__Supplier_Part__c, Name, bthousetracker__Supplier_Status__c, '+
                           'bthousetracker__Approval_Event__c, bthousetracker__BBNA_Reject_Comments__c,bthousetracker__BBNA_Status__c, bthousetracker__Effective_Date__c, '+ 
                           '(Select Id, ProcessDefinitionId, CompletedDate, CreatedDate, CreatedById,CreatedBy.Name From ProcessInstances'+clause1+'order by CreatedDate DESC LIMIT 1) '+ 
                           'from bthousetracker__Supplier_Door_Products__c where '+
                           'bthousetracker__Supplier_Product_Catalog__r.bthousetracker__status__c = \'Active\''+
                           'AND bthousetracker__BBNA_Status__c != \'Deleted\'';
        string queryComp = 'select Id, Name, bthousetracker__Component_Part__c, bthousetracker__Pricing_Approval_Status__c, '+ 
                           'bthousetracker__Approved_Event__c, bthousetracker__BBNA_Reject_Comments__c,bthousetracker__BBNA_Status__c, bthousetracker__Effective_Date__c, '+
                           '(Select Id, ProcessDefinitionId, CompletedDate, CreatedDate, CreatedById,CreatedBy.Name From ProcessInstances'+clause1+'order by CreatedDate DESC LIMIT 1) '+
                           'from bthousetracker__Supplier_Components__c where '+
                           'bthousetracker__Supplier_Product_Catalog__r.bthousetracker__Status__c = \'Active\''+
                           'AND bthousetracker__BBNA_Status__c != \'Deleted\''; 

        List<bthousetracker__Supplier_Door_Products__c> suppProductList = new List<bthousetracker__Supplier_Door_Products__c>();  
        List<bthousetracker__Supplier_Components__c> suppCompList = new List<bthousetracker__Supplier_Components__c>();      
        /*if(String.isNotBlank(catalog)){
            queryProd += ' AND bthousetracker__Supplier_Product_Catalog__c=:catalog' ;
            queryComp += ' AND bthousetracker__Supplier_Product_Catalog__c=:catalog' ;
        }*/  
        if(String.isNotBlank(selectedEffectiveDate)){
            queryProd += ' AND bthousetracker__Effective_Date__c='+selectedEffectiveDate;
            queryComp += ' AND bthousetracker__Effective_Date__c='+selectedEffectiveDate;
        }  
        /*if(String.isNotBlank(approvalEvent)) {
            queryProd += ' AND bthousetracker__Approval_Event__c=: approvalEvent ';
            queryComp += ' AND bthousetracker__Approved_Event__c=: approvalEvent ';
        }*/     
        if(string.isNotBlank(status)) {
            queryProd += ' AND bthousetracker__BBNA_Status__c=: status ';
            queryComp += ' AND bthousetracker__BBNA_Status__c=: status ';
        }
        string subQuery = '';
        set<Id> partIds = new Set<Id>();
        List<ProcessInstance> pList = new List<ProcessInstance>();
        if(string.isNotBlank(selectedSubmittedDate) || string.isNotBlank(selectedApp_RejDate)) {
            if(string.isNotBlank(selectedSubmittedDate)) {
                subQuery = 'Select TargetObjectId From ProcessInstance where DAY_ONLY(createdDate) = '+selectedSubmittedDate+' order by createddate desc';
            }
            if(string.isNotBlank(selectedApp_RejDate) && string.isBlank(selectedSubmittedDate)){
                subQuery = 'Select TargetObjectId, status From ProcessInstance where DAY_ONLY(CompletedDate) = '+selectedApp_RejDate+' order by createddate desc';
            }
            if(string.isNotBlank(selectedSubmittedDate) && string.isNotBlank(selectedApp_RejDate)) {
                subQuery = 'Select TargetObjectId From ProcessInstance where DAY_ONLY(createdDate) = '+selectedSubmittedDate+' and DAY_ONLY(CompletedDate) = '+selectedApp_RejDate+' order by createddate desc';
            }
            pList = Database.query(subQuery);
            system.debug('pList' +pList);
            if(pList.size() > 0) {
                for(ProcessInstance i : pList) {
                    partIds.add(i.TargetObjectId);
                }
            }
        }
        if(types == 'Product' || types == ''){   
            suppProductList = Database.query(queryProd);
            for(bthousetracker__Supplier_Door_Products__c itr: suppProductList) {
                if(string.isNotBlank(selectedSubmittedDate) || string.isNotBlank(selectedApp_RejDate)) {
                    if(pList.size() > 0 && partIds.contains(itr.Id) && (itr.bthousetracker__BBNA_Status__c == 'Approved' || itr.bthousetracker__BBNA_Status__c == 'Rejected')) {
                        pendingPartsList.add(new PendingPartWrapper(itr));
                    }
                } else {
                    pendingPartsList.add(new PendingPartWrapper(itr));
                }
            } 
        }
        if(types == 'Component' || types == ''){
            suppCompList = Database.query(queryComp);
            for(bthousetracker__Supplier_Components__c itr: suppCompList) {
                if(string.isNotBlank(selectedSubmittedDate) || string.isNotBlank(selectedApp_RejDate)) {
                    if(pList.size() > 0 && partIds.contains(itr.Id)) {
                        if(string.isNotBlank(selectedApp_RejDate) && (itr.bthousetracker__BBNA_Status__c == 'Approved' || itr.bthousetracker__BBNA_Status__c == 'Rejected')) {
                            pendingPartsList.add(new PendingPartWrapper(itr));
                        } else if(string.isBlank(selectedApp_RejDate)) {
                            pendingPartsList.add(new PendingPartWrapper(itr));
                        }
                    }
                } else {
                    pendingPartsList.add(new PendingPartWrapper(itr));
                }
            }
        }
                                                 
        return pendingPartsList; 
                                         
    }       
    /*public void reRenderPanel() {
        String catalogFilter = Apexpages.currentPage().getParameters().get('catalogFilter');
        String typeFilter = Apexpages.currentPage().getParameters().get('typeFilter');
        String approvalEventFilter = Apexpages.currentPage().getParameters().get('approvalEventFilter');
        String effectiveDateFilter = Apexpages.currentPage().getParameters().get('effectiveDateFilter');
        String submittedDateFilter = Apexpages.currentPage().getParameters().get('submittedDateFilter');
        String app_rejDateFilter = Apexpages.currentPage().getParameters().get('app_rejDateFilter');
        string statusFilter = Apexpages.currentPage().getParameters().get('statusFilter');
        system.debug('catalogFilter'+catalogFilter);
        system.debug('typeFilter'+typeFilter);
        system.debug('approvalEventFilter'+approvalEventFilter);
        
        if(submittedDateFilter != null)
            selectedSubmittedDate = submittedDateFilter;
        if(app_rejDateFilter != null)
            selectedApp_RejDate = app_rejDateFilter;
        if(effectiveDateFilter != null)
            selectedEffectiveDate = effectiveDateFilter;
        if(approvalEventFilter != null)
            changeType = approvalEventFilter;
        if(typeFilter != null)
            types = typeFilter;
        if(catalogFilter != null)
            catalogs = catalogFilter;
        if(statusFilter != null) 
            status = statusFilter;
    }*/                                                                                              
     
    public List<SelectOption> getCatalogFilter() {
        List<bthousetracker__Supplier_Product_Catalog__c> catalogs;         
        List<SelectOption> catalogOptions = new List<SelectOption>();
        catalogOptions.add(new SelectOption('', 'All'));
     
     
        if(String.isNotBlank(supplierId)) { 
            try{ 
                catalogs =  [SELECT Id, Name  
                                   FROM bthousetracker__Supplier_Product_Catalog__c 
                                   WHERE  bthousetracker__Status__c= :'Active' AND bthousetracker__Supplier__c =: supplierId];
                                                 
            }catch(Exception ex){
            System.debug(ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: '+ ex.getMessage()));
        }
        
        if(catalogs != null && !catalogs.isEmpty()){
            for(bthousetracker__Supplier_Product_Catalog__c catalog : catalogs){
                catalogOptions.add(new SelectOption(String.valueOf(catalog.id), catalog.Name));
            }
        }
    }
    
    return catalogOptions;           
    }
    
    public List<SelectOption> getTypeFilter(){
        
        List<SelectOption> typeFilters = new List<SelectOption>();
        typeFilters.add(new SelectOption('','All'));     
        typeFilters.add(new SelectOption('Product', 'Product'));
        typeFilters.add(new SelectOption('Component', 'Component'));
        
        return typeFilters;
    }
    
    public List<SelectOption> getstatusFilter(){
        
        List<SelectOption> statusFilter = new List<SelectOption>();
        statusFilter.add(new SelectOption('','All'));     
        //statusFilter.add(new SelectOption('Not Requested', 'Not Requested'));
        statusFilter.add(new SelectOption('Pending', 'Submitted'));
        statusFilter.add(new SelectOption('Approved','Approved'));     
        statusFilter.add(new SelectOption('Rejected ', 'Rejected'));
        statusFilter.add(new SelectOption('Withdrawn', 'Withdrawn'));
        statusFilter.add(new SelectOption('Not Requested', 'Saved'));
        
        return statusFilter;
    }
   
    public List<SelectOption> getapprovalEventFilter(){
        
        List<SelectOption> approvalEventFilter = new List<SelectOption>();
        approvalEventFilter.add(new SelectOption('','All'));     
        approvalEventFilter.add(new SelectOption('Part Addition', 'Part Addition'));
        approvalEventFilter.add(new SelectOption('Part Deactivation', 'Part Deactivation'));
        approvalEventFilter.add(new SelectOption('Pricing', 'Pricing'));
        
        return approvalEventFilter;
    } 
    public PageReference goToDetailPage() {  
        string partId = Apexpages.currentPage().getParameters().get('partId');
        string partType = Apexpages.currentPage().getParameters().get('partType');
        string summaryView = Apexpages.currentPage().getParameters().get('summaryView');
        string changeType1 = Apexpages.currentPage().getParameters().get('changeType');
        string viewType = Apexpages.currentPage().getParameters().get('viewType');
        string catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        PageReference pageRef ;
        system.debug('partId' + partId);
        system.debug('partType' + partType);
        system.debug('summaryView' + summaryView);
        system.debug('changeType1' + changeType1);
        system.debug('catalogId' + catalogId); 
        if(partType == 'Product'){
            
            pageRef = Page.SPComN_DoorProductDetailPage;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('productId', partId);
            pageRef.getParameters().put('catalogId', catalogId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        }else if(partType == 'Component') {
            pageRef = Page.SPComN_ComponentDetailPage;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('componentId', partId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        } 
        pageRef.setRedirect(true);
        return pageRef;
    } 
    
    /*public PageReference goToDetailPage() {  
        string partId = Apexpages.currentPage().getParameters().get('partId');
        string partType = Apexpages.currentPage().getParameters().get('partType');
        string summaryView = Apexpages.currentPage().getParameters().get('summaryView');
        string changeType1 = Apexpages.currentPage().getParameters().get('changeType');
        string viewType = Apexpages.currentPage().getParameters().get('viewType');
        string catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        PageReference pageRef ;
        system.debug('partId' + partId);
        system.debug('partType' + partType);
        system.debug('summaryView' + summaryView);
        system.debug('changeType1' + changeType1);
        system.debug('catalogId' + catalogId); 
        if(partType == 'Product'){
            
            pageRef = Page.bthousetracker__spcom_creatproductpage;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('productId', partId);
            pageRef.getParameters().put('catalogId', catalogId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        }else if(partType == 'Component') {
            pageRef = Page.bthousetracker__spcom_componentdetails;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('componentId', partId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        } 
        pageRef.setRedirect(true);
        return pageRef;
    } 
    
    public PageReference goToDetailPage1() {  
        string partId = Apexpages.currentPage().getParameters().get('partId');
        string partType = Apexpages.currentPage().getParameters().get('partType');
        string summaryView = Apexpages.currentPage().getParameters().get('summaryView');
        string changeType1 = Apexpages.currentPage().getParameters().get('changeType');
        string viewType = Apexpages.currentPage().getParameters().get('viewType');
        string catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        PageReference pageRef ;
        system.debug('partId' + partId);
        system.debug('partType' + partType);
        system.debug('summaryView' + summaryView);
        system.debug('changeType1' + changeType1);
        system.debug('catalogId' + catalogId); 
        if(partType == 'Product'){
            
            pageRef = Page.SPComN_DoorProductDetailPage;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('productId', partId);
            pageRef.getParameters().put('catalogId', catalogId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        }else if(partType == 'Component') {
            pageRef = Page.SPComN_ComponentDetailPage;
            pageRef.getParameters().put('isFromPendingCatalog','Yes');
            pageRef.getParameters().put('PartType', partType);
            pageRef.getParameters().put('componentId', partId);
            if(string.isNotBlank(summaryView)) {
                pageRef.getParameters().put('summaryView', summaryView);
                if(!string.isNotBlank(viewType))
                  pageRef.getParameters().put('isSummary','Yes');
            }
            if(changeType1 == 'Pricing') {
              pageRef.getParameters().put('Pricing','Yes');
            }
        } 
        pageRef.setRedirect(true);
        return pageRef;
    }*/ 
    
    public class PendingPartWrapper {
        public string recordId {get;set;}
        public string partNum {get;set;}
        public string partName {get;set;}
        public string changeType {get;set;}
        public string approvalStatus {get;set;}
        public date effDate {get;set;}
        public string submittedBy {get;set;}
        public string submitDate {get;set;}
        public string dateCompleted {get;set;}
        public string comments {get;set;}
        public string partType {get;set;}
        public string requestId {get;set;}
        public bthousetracker__Supplier_Door_Products__c plist {get;set;}
    
        
        public PendingPartWrapper(bthousetracker__Supplier_Door_Products__c product) {
            if(product != null) {
                plist = product;
                partType = 'Product';
                recordId = product.Id;
                partNum = product.bthousetracker__Supplier_Part__c != null ? string.valueOf(product.bthousetracker__Supplier_Part__c) : '';
                partName = product.Name;
                changeType = product.bthousetracker__Approval_Event__c != null ? string.valueOf(product.bthousetracker__Approval_Event__c) : '';
                if(product.bthousetracker__BBNA_Status__c == 'Not Requested') {
                    approvalStatus = 'Saved';
                } else if(product.bthousetracker__BBNA_Status__c == 'Pending') {
                    approvalStatus = 'Submitted';
                } else {
                    approvalStatus = product.bthousetracker__BBNA_Status__c != null ? string.valueOf(product.bthousetracker__BBNA_Status__c): '';
                }
                effDate = product.bthousetracker__Effective_Date__c;
                submittedBy = product.ProcessInstances.size() != 0 ? product.ProcessInstances[0].createdBy.Name : '';
                submitDate = product.ProcessInstances.size() != 0 ? string.valueOf(product.ProcessInstances[0].createdDate.date()) : '';
                requestId = product.ProcessInstances.size() != 0 ? string.valueOf(product.ProcessInstances[0].Id) : '';
                dateCompleted = product.ProcessInstances.size() != 0 && product.ProcessInstances[0].CompletedDate != null ? string.valueOf(product.ProcessInstances[0].CompletedDate.date()) : '';
                comments = product.bthousetracker__BBNA_Reject_Comments__c != null ? product.bthousetracker__BBNA_Reject_Comments__c : '';
            }
        }
        public PendingPartWrapper(bthousetracker__Supplier_Components__c product) {
            if(product != null) {
                partType = 'Component';
                recordId = product.Id;
                partNum = product.bthousetracker__Component_Part__c != null ? string.valueOf(product.bthousetracker__Component_Part__c) : '';
                partName = product.Name;
                changeType = product.bthousetracker__Approved_Event__c != null ? string.valueOf(product.bthousetracker__Approved_Event__c) : '';
                if(product.bthousetracker__BBNA_Status__c == 'Not Requested') {
                    approvalStatus = 'Saved';
                } else if(product.bthousetracker__BBNA_Status__c == 'Pending') {
                    approvalStatus = 'Submitted';
                } else {
                    approvalStatus = product.bthousetracker__BBNA_Status__c != null ? string.valueOf(product.bthousetracker__BBNA_Status__c): '';
                }
                effDate = product.bthousetracker__Effective_Date__c;
                submittedBy = product.ProcessInstances.size() != 0 ? product.ProcessInstances[0].createdBy.Name : '';
                submitDate = product.ProcessInstances.size() != 0 ? string.valueOf(product.ProcessInstances[0].createdDate.date()) : '';
                requestId = product.ProcessInstances.size() != 0 ? string.valueOf(product.ProcessInstances[0].Id) : '';
                dateCompleted = product.ProcessInstances.size() != 0 && product.ProcessInstances[0].CompletedDate != null ? string.valueOf(product.ProcessInstances[0].CompletedDate.date()) : '';
                comments = product.bthousetracker__BBNA_Reject_Comments__c != null ? product.bthousetracker__BBNA_Reject_Comments__c : '';
                system.debug('comments' +comments);
            }
        }
    }
}