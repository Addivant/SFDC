public Class SPComN_Wrapper {

    public class PageMessage{
        public Boolean isError {get; set;}
        public String message {get; set;}
        
        public PageMessage(Boolean isError, String message){
            this.isError = isError;
            this.message = message;
        }
    }
    
    public Class OrderWrapper{
        public String type {get; set;}
        public String reqNo {get; set;}
        public String id {get; set;}
        public String createDate {get; set;}
        public String shipDate {get; set;}
        public String qty {get; set;}
        public String status {get; set;}
        
        public OrderWrapper(bthousetracker__Purchase_Orders__c order){
            this.type = 'PO';
            this.id = order.id;
            this.reqNo = order.bthousetracker__PO__c != null ? String.valueOf(order.bthousetracker__PO__c) : ''; 
            this.createDate = order.bthousetracker__Date_Issued__c != null ? String.valueOf(order.bthousetracker__Date_Issued__c): '';
            this.shipDate = order.bthousetracker__Desired_Ship_Date__c != null ? String.valueOf(order.bthousetracker__Desired_Ship_Date__c)  :'';
            this.qty = '1';
            this.status = '';
        }
    }
    
    public Class ProductDelete {
        public String recordId {get; set;}
        public String deactivateDate {get; set;}
        public String reasonToDelete {get; set;}
        public String reasonForNotFulfulling {get; set;}
        public string fulfilOrders {get; set;}
        
        public ProductDelete(){}
    }
    
    public Class ProdCatalogWrapper{
        public String id;
        public String name;
        public String activeDate;
    }
    
    public Class ProdCatalogInfoWrapper {
        public String id;
        public String name;
        public String category;
        public String activateDate;
        public String archieveDate;
        public String activeDate;
        public String created;
        public String lastModified;
        public String status;
        public Boolean isUnderApproval;
                
        public ProdCatalogInfoWrapper(bthousetracker__Supplier_Product_Catalog__c  proCatalogRec){
            if(proCatalogRec != null){
                id = proCatalogRec.id;
                name = proCatalogRec.Name ;
                isUnderApproval = proCatalogRec.bthousetracker__Under_Approval__c;
                if(proCatalogRec.bthousetracker__BBNA_Product_Category__r.Name != null ){
                    category = proCatalogRec.bthousetracker__BBNA_Product_Category__r.Name;
                }else{
                    category = '';
                }
                
                if(proCatalogRec.bthousetracker__Activate_Date__c!= null ){
                    Date dateRec = proCatalogRec.bthousetracker__Activate_Date__c;
                    //String myDate = dateRec.format('yy-MM-dd');
                    //activeDate = DateTime.newInstance(dateRec.year(),dateRec.month(),dateRec.day()).format();
                    activateDate = dateRec.format();
                }else{
                    activateDate = '';
                }
                
                if(proCatalogRec.bthousetracker__Active_Date__c != null ){
                    Date dateRec = proCatalogRec.bthousetracker__Active_Date__c;
                    //String myDate = dateRec.format('yy-MM-dd');
                    //activeDate = DateTime.newInstance(dateRec.year(),dateRec.month(),dateRec.day()).format();
                    activeDate = dateRec.format();
                }else{
                    activeDate = '';
                }
                
                if(proCatalogRec.bthousetracker__Archived_Date__c!= null ){
                    Date dateRec = proCatalogRec.bthousetracker__Archived_Date__c;
                    //archieveDate = DateTime.newInstance(dateRec.year(),dateRec.month(),dateRec.day()).format();
                    archieveDate  = dateRec.format();
                }else{
                    archieveDate = '';
                }
                
                if(proCatalogRec.CreatedBy.Name != null ){
                    created = proCatalogRec.CreatedBy.Name;
                }else{
                    created = '';
                } 
                
                if(proCatalogRec.LastModifiedBy.Name != null ){
                    lastModified = proCatalogRec.LastModifiedBy.Name;
                }else{
                    lastModified = '';
                } 
                
                if(proCatalogRec.bthousetracker__Status__c != null ){
                    status = String.valueOf(proCatalogRec.bthousetracker__Status__c);
                }else{
                    status = '';
                }                    
            }
        }    
    }
    
    /*public class ProductInfoWrapper{
        public String id;
        public String name;
        public String partNumber;
        public String size;
        
        public String series;
        public String type;
        public String rating;
        public String assembly;
        
        public String leafs;
        public String category;
        public String bbnaStatus;
        public Boolean isUnderApproval;
        
        public String activeDate;
        public String archivedDate;
        public String effectiveDate;
        public String deactivateDate;
        
        public String updatedDate;
        public String createdDate;
        public String createdBy;
        public String updatedBy;
        public String approvalStatus;
        
        public String status;
                
        public ProductInfoWrapper(Supplier_Door_Products__c productRec){
            if(productRec != null){
                id = productRec.id;
                name = productRec.Name ;
                isUnderApproval = productRec.Under_Approval__c;
                
                if(productRec.Supplier_Part__c != null ){
                    partNumber = productRec.Supplier_Part__c;
                }else{
                    partNumber = '';
                }
                
                if(productRec.Status__c!= null ){
                    status = productRec.Status__c;
                }else{
                    status = '';
                }

                if(productRec.BBNA_Status__c != null ){
                    bbnaStatus = productRec.BBNA_Status__c;
                }else{
                    bbnaStatus = '';
                }
                
                if(productRec.Product_Category__c != null ){
                    category = productRec.Product_Category__c;
                }else{
                    category = '';
                }
                
                if(productRec.Door_Size__c != null ){
                    size = productRec.Door_Size__c;
                }else{
                    size = '';
                }
                
                if(productRec.Series__c != null ){
                    series = productRec.Series__c;
                }else{
                    series = '';
                }
                
                if(productRec.Type__c != null ){
                    type = productRec.Type__c;
                }else{
                    type = '';
                } 
                
                if(productRec.Rating__c != null ){
                    rating = productRec.Rating__c;
                }else{
                    rating = '';
                } 
                
                if(productRec.Active_Leafs_Picklist__c != null ){
                    leafs = productRec.Active_Leafs_Picklist__c;
                }else{
                    leafs = '';
                }  
                
                if(productRec.Assembly__c != null ){
                    assembly = productRec.Assembly__c;
                }else{
                    assembly = '';
                } 
                
                if(productRec.Active_Date__c != null ){
                    Date dateRec = productRec.Active_Date__c;
                    activeDate = dateRec.format();
                }else{
                    activeDate = '';
                } 
                
                if(productRec.Archived_Date__c != null ){
                    Date dateRec = productRec.Archived_Date__c;
                    archivedDate = dateRec.format();
                }else{
                    archivedDate = '';
                } 
                
                if(productRec.Effective_Date__c != null ){
                    Date dateRec = productRec.Effective_Date__c;
                    effectiveDate = dateRec.format();
                }else{
                    effectiveDate = '';
                } 
                
                if(productRec.Deactivate_Date__c != null ){
                    Date dateRec = productRec.Deactivate_Date__c;
                    deactivateDate = dateRec.format();
                }else{
                    deactivateDate = '';
                } 
                
                if(productRec.LastModifiedDate != null ){
                    Datetime dateRec = productRec.LastModifiedDate;
                    updatedDate = dateRec.format();
                }else{
                    updatedDate = '';
                } 
                
                if(productRec.CreatedDate != null ){
                    Datetime dateRec = productRec.CreatedDate;
                    createdDate = dateRec.format();
                }else{
                    createdDate = '';
                } 
                
                if(productRec.CreatedBy.Name != null ){
                    createdBy = productRec.CreatedBy.Name;
                }else{
                    createdBy = '';
                } 
                
                if(productRec.LastModifiedBy.Name != null ){
                    updatedBy = productRec.LastModifiedBy.Name;
                }else{
                    updatedBy = '';
                } 
                
                if(productRec.Approval_Status__c != null ){
                    approvalStatus = productRec.Approval_Status__c;
                }else{
                    approvalStatus = '';
                } 
                
            }
        }    
    }*/
    
    public Class ProductInfoWrapper {
        public String id {get; set;}
        public String name {get; set;} 
        public String cost {get; set;}
        public String warranty {get; set;} 
        public String partNumber {get; set;} 
        public String activeDate {get; set;}
        public String archiveDate {get; set;}
        public String effectiveDate {get; set;}
        public String catalogId {get; set;}
        public String catalogName {get; set;}
        public String approvalStatus {get; set;}
        public String bbnaStatus {get; set;}
        public String status {get; set;}
        public String supplier {get; set;}
        public String category {get; set;}
        public Boolean isLocked {get; set;}
        public Boolean isUnderApproval {get; set;}
        
        //-- attributes
        public String leafs {get; set;}
        public String uom {get; set;}
        public String type {get; set;}
        public String assembly {get; set;}
        public String rating {get; set;}
        public String series {get; set;}
        public String subCategory {get; set;}

        public String size {get; set;}
        public String markup {get; set;}
        public String weight {get; set;}
        public String paintColor {get; set;}    
        public String paintType {get; set;}         
        
        
        //-- 
        public String updatedDate {get; set;}
        public String createdDate {get; set;}
        public String createdBy {get; set;}
        public String updatedBy {get; set;}
        
        public Boolean isSelectedForComponent {get; set;}
        
        public ProductInfoWrapper(){}
        
        public ProductInfoWrapper(bthousetracker__Supplier_Door_Products__c  product){
                //String namePrefx = 'bthousetracker__';
                String namePrefx = '';
                Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(product));
                
                if(product.id != null){
                    Id = product.id;                    
                }
                System.debug('fieldMap '+ JSON.serialize(fieldMap) );
                name = fieldMap.get('Name') != null ? product.Name : '';
                partNumber = fieldMap.get('bthousetracker__Supplier_Part__c') != null ? product.bthousetracker__Supplier_Part__c : '';
                
                cost = fieldMap.get('bthousetracker__cost__c') != null ? String.valueOf(product.bthousetracker__cost__c) : '';                
                activeDate = fieldMap.get('bthousetracker__Active_Date__c') != null ? product.bthousetracker__Active_Date__c.format() : '';
                archiveDate = fieldMap.get('bthousetracker__Archived_date__c') != null ? product.bthousetracker__Archived_date__c.format() : '';
                effectiveDate = fieldMap.get('bthousetracker__Effective_Date__c') != null ? product.bthousetracker__Effective_Date__c.format() : '';
                approvalStatus = fieldMap.get('bthousetracker__Approval_Status__c') != null ? product.bthousetracker__Approval_Status__c : '';
                bbnaStatus = fieldMap.get('bthousetracker__BBNA_Status__c') != null ? product.bthousetracker__BBNA_Status__c : '';
                isUnderApproval = fieldMap.get('bthousetracker__Under_Approval__c') != null ? product.bthousetracker__Under_Approval__c : false;               
                status = fieldMap.get('bthousetracker__Status__c') != null ? product.bthousetracker__Status__c : '';
                category = fieldMap.get('bthousetracker__Sub_Category__c') != null ? product.bthousetracker__Sub_Category__c : '';
                supplier = fieldMap.get('bthousetracker__Supplier__c') != null ? String.valueOf(product.bthousetracker__Supplier__c) : '';
                
                isLocked = fieldMap.get('bthousetracker__isLocked__c') != null ? product.bthousetracker__isLocked__c : false; 
                
                if(fieldMap.get('bthousetracker__Supplier_Product_Catalog__c') != null ){
                    catalogId = product.bthousetracker__Supplier_Product_Catalog__c;
                    System.debug(fieldMap.get('bthousetracker__Supplier_Product_Catalog__r'));
                    if(fieldMap.containsKey(namePrefx + 'bthousetracker__Supplier_Product_Catalog__r')){
                        catalogName = product.bthousetracker__Supplier_Product_Catalog__r.Name;
                        System.debug(product.bthousetracker__Supplier_Product_Catalog__r.Name);
                    }
                }else{
                    catalogId = '';
                    catalogName = '';
                } 
                
                warranty = fieldMap.get('bthousetracker__Warranty__c') != null ? product.bthousetracker__Warranty__c : '';
                leafs = fieldMap.get('bthousetracker__Active_Leafs_Picklist__c') != null ? product.bthousetracker__Active_Leafs_Picklist__c : '';
                uom = fieldMap.get('bthousetracker__UOM__c') != null ? product.bthousetracker__UOM__c : '';
                type = fieldMap.get('bthousetracker__Type__c') != null ? product.bthousetracker__Type__c : '';
                assembly = fieldMap.get('bthousetracker__Assembly__c') != null ? product.bthousetracker__Assembly__c : '';
                rating = fieldMap.get('bthousetracker__Rating__c') != null ? product.bthousetracker__Rating__c : '';
                series = fieldMap.get('bthousetracker__Series__c') != null ? product.bthousetracker__Series__c : '';
                
                size = fieldMap.get('bthousetracker__Door_Size__c') != null ? product.bthousetracker__Door_Size__c : ''; 
                markup = fieldMap.get('bthousetracker__Markup__c') != null ? String.valueOf(product.bthousetracker__Markup__c) : '';
                weight = fieldMap.get('bthousetracker__Weight__c') != null ? String.valueOf(product.bthousetracker__Weight__c) : '';
                paintColor = fieldMap.get('bthousetracker__paint_color__c') != null ? product.bthousetracker__paint_color__c : '';
                paintType = fieldMap.get('bthousetracker__Paint_Type__c') != null ? product.bthousetracker__Paint_Type__c : '';
                subCategory = fieldMap.get('bthousetracker__Sub_Category__c') != null ? product.bthousetracker__Sub_Category__c : '';
                
                updatedDate = fieldMap.get('LastModifiedDate') != null ? product.LastModifiedDate.format() : '';
                createdDate = fieldMap.get( 'CreatedDate') != null ? product.CreatedDate.format() : '';
                createdBy = fieldMap.get( 'CreatedBy') != null ? product.CreatedBy.Name : '';
                updatedBy = fieldMap.get( 'LastModifiedBy') != null ? product.LastModifiedBy.Name : '';
                                           
                isSelectedForComponent = false;
        }                
       
    }
    
    /*public class ComponentInfoWrapper{
        public String id;
        public String name;
        public String partNumber;
        public String compType;
        public String attribute1;
        public String attribute2;
        public String status;
        public Boolean isDeleted;
                    
        public ComponentInfoWrapper(Supplier_Components__c compRec){
            if(compRec != null){
                id = compRec.id;
                name = compRec.Name ;
                isDeleted = compRec.isDelete__c;
                if(compRec.Component_Part__c != null ){
                    partNumber = compRec.Component_Part__c;
                }else{
                    partNumber = '';
                }
                
                if(compRec.Supplier_Component_Type__r.Name != null ){
                    compType = compRec.Supplier_Component_Type__r.Name;
                }else{
                    compType = '';
                }
                
                if(compRec.Attribute1__c != null ){
                    attribute1 = compRec.Attribute1__c;
                }else{
                    attribute1 = '';
                }
                
                if(compRec.Attribute2__c!= null ){
                    attribute2 = compRec.Attribute2__c;
                }else{
                    attribute2 = '';
                }
                
                if(compRec.Status__c!= null ){
                    status = compRec.Status__c;
                }else{
                    status = '';
                } 
            }
        }    
    }*/
    
    public class PricingTableWrapper{
        public String zone;
        public String minQty;
        public String maxQty;
        public String cost;
        public String status;
        public String ApprovalStatus;
        
        public PricingTableWrapper(bthousetracker__Supplier_Pricing_Table__c  pricingTableRec){                
             if(pricingTableRec.bthousetracker__Supplier_Zone__r.Name!= null ){
                zone = pricingTableRec.bthousetracker__Supplier_Zone__r.Name;
             }else{
                zone = '';
             } 
             
             if(pricingTableRec.bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c!= null ){
                minQty = String.valueOf(pricingTableRec.bthousetracker__Supplier_Tier__r.bthousetracker__Min_Qty__c);
             }else{
                minQty = '1';
             } 
             
             if(pricingTableRec.bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c != null ){
                maxQty = String.valueOf(pricingTableRec.bthousetracker__Supplier_Tier__r.bthousetracker__Max_Qty__c);
             }else{
                maxQty = 'Max';
             } 
             
             if(pricingTableRec.bthousetracker__Cost__c!= null ){
                cost = String.valueOf(pricingTableRec.bthousetracker__Cost__c);
             }else{
                cost = '';
             } 
             
             if(pricingTableRec.bthousetracker__Status__c!= null ){
                status = pricingTableRec.bthousetracker__Status__c;
             }else{
                status = '';
             } 
             
             if(pricingTableRec.bthousetracker__Status__c!= null ){
                ApprovalStatus = pricingTableRec.bthousetracker__Supplier_Status__c;
             }else{
                ApprovalStatus = '';
             } 
        }
    }
    
     public Class ComponentDelete{
        public String recordId {get; set;}
        public String deactivateDate {get; set;}
        public String reasonToDelete {get; set;}
        public Boolean fulfilOrders {get; set;}
        public string reasonForNotFulfulling {get;set;}
        
        public ComponentDelete(){}    
    }       
    
    public class ProductCompWrapper{
        public String partNumber;
        public String component;
        public String type;
        public String recDefault;
        
        public ProductCompWrapper(bthousetracker__Supplier_Products_Components__c proCmpRec){
             if(proCmpRec.bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c!= null ){
                partNumber = proCmpRec.bthousetracker__Supplier_Component__r.bthousetracker__Component_Part__c;
             }else{
                partNumber = '';
             } 
             
             if(proCmpRec.bthousetracker__Supplier_Component__r.Name!= null ){
                component = proCmpRec.bthousetracker__Supplier_Component__r.Name;
             }else{
                component = '';
             } 
             
             if(proCmpRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c!= null ){
                type = proCmpRec.bthousetracker__Supplier_Component__r.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c;
             }else{
                type = '';
             } 
             
             if(proCmpRec.bthousetracker__Default__c!= null ){
                recDefault = proCmpRec.bthousetracker__Default__c;
             }else{
                recDefault = '';
             } 
        } 
    }
    
    public class LeadTimeWrapper{
       public String plant {get; set;}
       public String days {get; set;}
       public String id {get; set;}
       public String productId {get; set;}
       public String componentId {get; set;}
       public String newDays;
       
       public LeadTimeWrapper(bthousetracker__Lead_Time__c  leadTimeRec){
           //String namePrefx = 'bthousetracker__';
           String namePrefx = '';
           Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(leadTimeRec));
           
           if(leadTimeRec.id != null) {
               id = leadTimeRec.id;                  
           }
           
           plant = fieldMap.get('bthousetracker__Sourcing_Facility_Single__c') != null ? leadTimeRec.bthousetracker__Sourcing_Facility_Single__c : '';
           days = fieldMap.get('bthousetracker__Man_Lead_Time__c') != null ? String.valueOf(leadTimeRec.bthousetracker__Man_Lead_Time__c) : '';
           componentId = fieldMap.get('bthousetracker__Supplier_Component__c') != null ? String.valueOf(leadTimeRec.bthousetracker__Supplier_Component__c) : '';
           productId = fieldMap.get('bthousetracker__Supplier_Door_Product__c') != null ? String.valueOf(leadTimeRec.bthousetracker__Supplier_Door_Product__c) : '';
                                   
       }
       
       public LeadTimeWrapper(){
           plant = '';
           days = '';
       }
       
   }
   
    public Class ComponentInfoWrapper {
        public String id {get; set;}
        public String name {get; set;}
        public String cost {get; set;}
        public String componentTypeId {get; set;}
        public String componentTypeName {get; set;}
        public String description {get; set;} 
        public String partNumber {get; set;} 
        public String activeDate {get; set;}
        public String archiveDate {get; set;}
        public String effectiveDate {get; set;}
        public String catalogId {get; set;}
        public String catalogName {get; set;}
        public String approvalStatus {get; set;}
        public String status {get; set;}
        public String attribute1 {get; set;}
        public String attribute2 {get; set;}
        public Boolean isDeleted {get; set;}
        public Boolean islocked {get; set;}
        public String size {get; set;}
        
        public String updatedDate {get; set;}
        public String createdDate {get; set;}
        public String createdBy {get; set;}
        public String updatedBy {get; set;}
        
        public String isDefault {get; set;}
        public Boolean isSelectedForProduct {get; set;}
        
        public Boolean approvalLevel {get; set;}
        public Boolean pricingLevel {get; set;}
                
        public ComponentInfoWrapper(){}
        
        public ComponentInfoWrapper(bthousetracker__Supplier_Components__c component){
            //String namePrefx = 'bthousetracker__';
            String namePrefx = '';
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(component));
                
            System.debug('!@!@!@!!'+ JSON.serialize(fieldMap));    
            if(component.id != null) {
                Id = component.id;                  
            }
            //islocked = component.isLocked__c;
            islocked  = fieldMap.get('isLocked__c') != null ? component.isLocked__c: false;
            name = fieldMap.get('Name') != null ? component.Name : '';
            partNumber = fieldMap.get('bthousetracker__Component_Part__c') != null ? component.bthousetracker__Component_Part__c: '';
            cost = fieldMap.get('bthousetracker__cost__c') != null ? String.valueOf(component.bthousetracker__cost__c) : '';
            description =  fieldMap.get('bthousetracker__Option_Description__c') != null ? component.bthousetracker__Option_Description__c : '';
            activeDate = fieldMap.get('bthousetracker__Active_Date__c') != null ? component.bthousetracker__Active_Date__c.format() : '';
            archiveDate = fieldMap.get('bthousetracker__Archived_date__c') != null ? component.bthousetracker__Archived_date__c.format() : '';
            effectiveDate = fieldMap.get('bthousetracker__Effective_Date__c') != null ? component.bthousetracker__Effective_Date__c.format() : '';
            approvalStatus = fieldMap.get('bthousetracker__BBNA_Status__c') != null ? component.bthousetracker__BBNA_Status__c : '';
            status = fieldMap.get('bthousetracker__Status__c') != null ? component.bthousetracker__Status__c : '';
            attribute1 = fieldMap.get('bthousetracker__Attribute1__c') != null ? component.bthousetracker__Attribute1__c : '';
            attribute2 = fieldMap.get('bthousetracker__Attribute2__c') != null ? component.bthousetracker__Attribute2__c : '';
            isDeleted = fieldMap.get('bthousetracker__isDelete__c') != null ? component.bthousetracker__isDelete__c : false;
            approvalLevel = fieldMap.get('bthousetracker__Approval_level__c') != null ? component.bthousetracker__Approval_level__c: false; 
            pricingLevel = fieldMap.get('bthousetracker__Pricing_level__c') != null ? component.bthousetracker__Pricing_level__c: false; 
 
            size = fieldMap.get('bthousetracker__Size__c') != null ? component.bthousetracker__Size__c: ''; 
            if(fieldMap.get('bthousetracker__Supplier_Component_Type__c') != null ){
                ComponentTypeId = component.bthousetracker__Supplier_Component_Type__c;
                if(fieldMap.containsKey('bthousetracker__Supplier_Component_Type__r')){
                    ComponentTypeName = component.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c;
                }
            }else{
                ComponentTypeId = '';
                ComponentTypeName = '';
            }
            
            if(fieldMap.get('bthousetracker__Supplier_Product_Catalog__c') != null ){
                catalogId = component.bthousetracker__Supplier_Product_Catalog__c;
                
                if(fieldMap.containsKey('bthousetracker__Supplier_Product_Catalog__r')){
                    catalogName = component.bthousetracker__Supplier_Product_Catalog__r.Name;
                }
            }else{
                catalogId = '';
                catalogName = '';
            } 
            
            updatedDate = fieldMap.get('LastModifiedDate') != null ? component.LastModifiedDate.format() : '';
            createdDate = fieldMap.get( 'CreatedDate') != null ? component.CreatedDate.format() : '';
            createdBy = fieldMap.get( 'CreatedBy') != null ? component.CreatedBy.Name : '';
            updatedBy = fieldMap.get( 'LastModifiedBy') != null ? component.LastModifiedBy.Name : '';
                                           
            //- for product rules - assign default values
            isDefault = 'No';
            isSelectedForProduct = false;                                         
        }
        
        public ComponentInfoWrapper(bthousetracker__Supplier_Components__c component, Boolean internalCall){
            if(internalCall){
                name = component.Name ;
                partNumber = component.bthousetracker__Component_Part__c ;
                description =  component.bthousetracker__Option_Description__c != null ? component.bthousetracker__Option_Description__c : '';            
            }
        }
    }
    
    public Class ProductruleWrapper {
        public SPComN_Wrapper.ComponentInfoWrapper component{get; set;}
        public ProductInfoWrapper product;
        public String isDefault {get; set;}
        public Boolean isSelectedForProduct {get; set;}
        public String id {get; set;}
        public Boolean isModified {get; set;}
        public String supplier {get; set;}
        
        public productruleWrapper(){
            isModified = false;    
        }
        
        public productruleWrapper(bthousetracker__Supplier_Components__c component){
            this.component = new SPComN_Wrapper.ComponentInfoWrapper(component);
            isDefault = 'No';
            isSelectedForProduct = false;
            isModified = false; 
            supplier = component.bthousetracker__Supplier_Id__c;
        }
        
        public productruleWrapper(bthousetracker__Supplier_Door_Products__c productRec){
            this.product = new ProductInfoWrapper(productRec);
            isModified = false; 
            supplier = productRec.bthousetracker__Supplier__c;
           
        }
        
        public productruleWrapper(bthousetracker__Supplier_Products_Components__c  productRule){
            this.id = productRule.id;
            
            System.debug('productRule '+productRule);
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(productRule));
            System.debug('fieldMap  '+fieldMap );
            
            if(fieldMap.containsKey('bthousetracker__Supplier_Product__r')){
                product = new ProductInfoWrapper();
                product.Id  = productRule.bthousetracker__Supplier_Product__c;
                
                Map<String, Object> fieldMap2 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fieldMap.get('bthousetracker__Supplier_Product__r')));
                
                product.Name = fieldMap2.get('Name') != null ? String.valueOf(fieldMap2.get('Name')) : ''; 
                product.partNumber = fieldMap2.get('bthousetracker__Supplier_Part__c') != null ? String.valueOf(fieldMap2.get('bthousetracker__Supplier_Part__c')) : '';                 
            }
            
            if(fieldMap.containsKey('bthousetracker__Supplier_Component__r')){
                component = new ComponentInfoWrapper();
                component.Id  = productRule.bthousetracker__Supplier_Component__c;
                
                Map<String, Object> fieldMap2 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fieldMap.get('bthousetracker__Supplier_Component__r')));
                
                System.debug('fieldMap2 : '+ fieldMap2 );
                
                component.Name = fieldMap2.get('Name') != null ? String.valueOf(fieldMap2.get('Name')) : '';
                component.description  = fieldMap2.get('bthousetracker__Option_Description__c') != null ? String.valueOf(fieldMap2.get('bthousetracker__Option_Description__c')) : ''; 
                component.partNumber = fieldMap2.get('bthousetracker__Component_Part__c') != null ? STring.valueOf(fieldMap2.get('bthousetracker__Component_Part__c')) : ''; 
                
                Map<String, Object> fieldMap3 = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fieldMap2.get('bthousetracker__Supplier_Component_Type__r')));
                component.componentTypeName = fieldMap2.get('bthousetracker__Supplier_Component_Type__r') != null ?             
                                              String.valueOf(fieldMap3.get('bthousetracker__Description__c')) : '';                 
            }            
        }
        
    }
    
    public class PricingWrapper {
        public TierWrapper tier {get; set;}
        public ZoneWrapper zone {get; set;}
        public String id {get; set;}
        public String cost {get; set;}
        public String catalogId {get; set;}
        public String componentId {get; set;}
        public String productId {get; set;} 
        public String status {get; set;}
        public String proposedCost {get; set;}
        public String clonedId {get; set;}
        public String supplierId {get; set;}
        
        public String partNumber {get; set;}
        public String partDescription {get; set;}
        public String approvalStatus {get; set;}
        public String pendingRemoval {get; set;}
        public Boolean isLocked {get;set;}
        public String effectiveDate {get; set;}
        
        public pricingWrapper(){}
        
        public PricingWrapper(bthousetracker__Supplier_Pricing_Table__c  pricingRec){
            //String namePrefx = 'bthousetracker__';
            String namePrefx = '';
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pricingRec));
                            
            if(pricingRec.id != null) {
                id = pricingRec.id;                  
            }else{
                id = null;
            }
            
            system.debug(fieldMap);
            
            cost = fieldMap.get('bthousetracker__Cost__c') != null ? String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Cost__c')) : '';
            supplierId = fieldMap.get('bthousetracker__Supplier__c') != null ? String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Supplier__c')) : '';
            
            tier = fieldMap.get('bthousetracker__Supplier_Tier__r') != null ? new TierWrapper(fieldMap.get(namePrefx + 'bthousetracker__Supplier_Tier__r')) : fieldMap.get(namePrefx + 'bthousetracker__Supplier_Tier__c') != null ? new TierWrapper(String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Supplier_Tier__c')), 1) : null;
            zone = fieldMap.get('bthousetracker__Supplier_Zone__r') != null ? new ZoneWrapper(fieldMap.get(namePrefx + 'bthousetracker__Supplier_Zone__r')) : fieldMap.get(namePrefx + 'bthousetracker__Supplier_Zone__c') != null ? new ZoneWrapper(String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Supplier_Zone__c')), 1) : null;                       
            catalogId = fieldMap.get('bthousetracker__Supplier_Product_Catalog__c') != null ? String.valueOf(pricingRec.bthousetracker__Supplier_Product_Catalog__c) : '';
            componentId = fieldMap.get('bthousetracker__Supplier_Component__c') != null ? String.valueOf(pricingRec.bthousetracker__Supplier_Component__c) : '';
            productId = fieldMap.get('bthousetracker__Supplier_Product__c') != null ? String.valueOf(pricingRec.bthousetracker__Supplier_Product__c) : '';
            status = fieldMap.get('bthousetracker__Status__c') != null ? pricingRec.bthousetracker__Status__c : '';
            proposedCost = fieldMap.get('bthousetracker__Proposed_Cost__c') != null ? String.valueOf(pricingRec.bthousetracker__Proposed_Cost__c) : '';
            
        }
        
        public PricingWrapper(bthousetracker__Supplier_Tier__c tierRec, String productId, String catalogId){
            
            if(tierRec != null){
                tier = new TierWrapper(tierRec);
            }
            
            this.productId = productId;
            this.status = 'Pending';
            this.catalogId = catalogId;
            this.componentId = '';
            this.id = '';
            this.cost = '';            
        }
    }
    
    public Class TierWrapper {
        public String minQty {get; set;}
        public String maxQty {get; set;}
        public String id {get; set;}
        public String tierId {get; set;}
        
        public TierWrapper(){}
        
        public TierWrapper(bthousetracker__Supplier_Tier__c tierRec){
            
            this.id = tierRec.id;
            this.minQty = String.valueOf(tierRec.bthousetracker__Min_Qty__c);
            this.maxQty = String.valueOf(tierRec.bthousetracker__Max_Qty__c);            
        }
        
        public TierWrapper(Object fieldObj){
            system.debug(' fieldObj '+fieldObj);
            
            String fieldJson = JSOn.serialize(fieldObj); 
            System.debug('fieldJson '+ fieldJson );           
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldJson);
            
            System.debug('fieldMap '+ fieldMap);
            
            //String namePrefx = 'bthousetracker__'; 
            String namePrefx = '';           
            id = fieldMap.get('Id') != null ? String.valueOf(fieldMap.get('Id')): '';
            
            minQty = fieldMap.get(namePrefx + 'bthousetracker__Min_Qty__c') != null ? String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Min_Qty__c')) : ''; 
            maxQty = fieldMap.get(namePrefx + 'bthousetracker__Max_Qty__c') != null ? String.valueOf(fieldMap.get(namePrefx + 'bthousetracker__Max_Qty__c')) : '';  
        }
        
        public TierWrapper(String id, Integer flag){            
            this.id = id;
        }                
    }
    
    public Class ZoneWrapper {
        public String id {get; set;}
        public String name {get; set;}
        public String zoneId {get; set;}
        public Boolean isChecked ;
        
        public ZoneWrapper(){
            isChecked = false;
        }
        
        public ZoneWrapper(Object  fieldObj){
            String namePrefx = 'bthousetracker__';
            system.debug('fieldObj '+fieldObj);
            
            String fieldJson = JSOn.serialize(fieldObj);            
            system.debug('fieldJson '+fieldJson );
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldJson);
            
            id = fieldMap.get('Id') != null ? String.valueOf(fieldMap.get('Id')) : '';
            name = fieldMap.get('Name') != null ?  String.valueOf(fieldMap.get('Name')) : '';    
            
            isChecked = false; 
        }
        
        public ZoneWrapper(String id, Integer flag){
            
            this.id = id;
            isChecked = false;
        }
        
        public ZoneWrapper(String id, String name){
            
            this.id = id;
            this.Name= name;
            isChecked = false;
            
        }
        
        public ZoneWrapper(bthousetracker__Supplier_Zones__c zone){
            
            this.id = zone.id;
            this.Name= zone.name;
            isChecked = false;
            
        }
    }
    
    public Class PricingInfo {       
        public String pricingType;
        public Integer size;
        public Integer deleteSize;   
        public List<SPComN_Wrapper.ZonePricing> pendingPricingsWrap;
        
        public PricingInfo(Integer length, String pricingType, Integer deleteSize, List<SPComN_Wrapper.ZonePricing> pendingPricingsWrap){
            this.size = length;
            this.pricingType = pricingType;
            this.deleteSize = deleteSize;
            if(pendingPricingsWrap != null){
                this.pendingPricingsWrap = pendingPricingsWrap;
            }else{
                this.pendingPricingsWrap = new List<SPComN_Wrapper.ZonePricing>();
            }
            
        }
    }
    
    public class ZonePricing{
        public ZoneWrapper zone;
        public List<PricingWrapper> pricings;
        public String zoneName;
        public String zoneId;  
        public Boolean isChecked;
              
        public Boolean isEdit;
        public String pricingType;
        public boolean temporaryDelete;
        public Boolean isDelete;
        
        public ZonePricing(){}
        
        public ZonePricing(ZoneWrapper zone, List<PricingWrapper> pricings){
            //this.zone = zone;
            if(zone != null){
                this.zoneName = zone.Name;
                this.zoneId = zone.id;
            }else{
                this.zoneName = '';
                this.zoneId = '';
            }
            
            this.pricings = pricings;    
            this.isDelete = false;     
        }       
    }
    
     /*public class Response{
       public Boolean isSuccess {get; set;}
       public String MessagingStr {get; set;}
       public List<Object> records{get; set;}
       public Object record {get; set;}
       
       public Response(Boolean isSuccess , String MessagingStr, List<Object> recordsList){
           records = new List<Object>();
           this.isSuccess = isSuccess;
           this.MessagingStr = MessagingStr;
           records = recordsList;
       }
           
    } */ 
     
    public Class EditPricingWrapper {
        public List<TierWrapper> tiers;
        public List<ZoneWrapper> zones;
        public String zoneStructure;
        public String tierStructure ;        
        public List<ZonePricing> pricingList;
    }
    
    public Class ZoneTierWrapper {
        public List<TierWrapper> tiers;
        public List<ZoneWrapper> zones;
        
        public ZoneTierWrapper (List<TierWrapper> tiers, List<ZoneWrapper> zones){
            this.tiers = tiers;
            this.zones = zones;     
        }
    }
    
    public class componentTypeWrapper{
        public String id;
        public string name;
        
        public componentTypeWrapper(){}
        
        public componentTypeWrapper(String id, String name){
            this.id = id;
            this.name = name;
        }
        
        public componentTypeWrapper(bthousetracker__Supplier_Component_Types__c componentType){
            this.id = componentType.id;
            this.name = componentType.Name;
        }
        
    }
    
    public Class catalogInfoWrraper{
        public Object otherDetails;
        public Boolean isSucess;
        Public Object record;
        public String message;
        
        public CatalogInfoWrraper(){}
        
        public CatalogInfoWrraper(Boolean isSucess, String otherDetails, String message){
            this.isSucess = isSucess;
            this.otherDetails = otherDetails;
            this.message = message;
        }
        
         public catalogInfoWrraper(Boolean isSucess, Object otherDetails, String message, Object record){
            this.isSucess = isSucess;
            this.otherDetails = otherDetails;
            this.message = message;
            this.record =  record;
        }
    }
    
     public class Response{
       public Boolean isSuccess {get; set;}
       public String MessagingStr {get; set;}
       public List<Object> records{get; set;}
       public Object record {get; set;}
       
       public Response(Boolean isSuccess , String MessagingStr, List<Object> recordsList){
           records = new List<Object>();
           this.isSuccess = isSuccess;
           this.MessagingStr = MessagingStr;
           records = recordsList;
           
       }   
       
       public Response(){}  
       
       public Response(Boolean isSuccess , String MessagingStr, Object objRecord, List<Object> recordsList){
           this.isSuccess = isSuccess;
           this.MessagingStr = MessagingStr;
           record = objRecord;
           records =  recordsList;          
       }     
    }
    
    public Class PartFlowAttrSecWrapper {
    
        public String productPicklistJson;
        public String componentPicklistJson ;
        public String catalogName;
        public List<ComponentTypeWrapper> componentTypes;
        
        public PartFlowAttrSecWrapper(){}
    }
    
    public class PartFlowData {
        public productInfoWrapper product;
        public componentInfoWrapper component;
        public pricingDataWrapper zonePricings;
        public List<LeadTimeWrapper> leadTimes;
        public List<ProductruleWrapper> productRules;
        public String type;
        
        public PartFlowData(){
            
        }
        
        
     }

    public class PurchaseOrder {
        public String PO_No;
        public String status;
        public String PODate;
        public String revisionDate ;
        public String billTo;
        public String billToAdd;
        public String POAmt;
        public String freight;
        public String total;
        public String totalQty;
        public String projectName;
        public String projectNo;
        public String builder;
        public String projectLocation;
        public String shipToLocation;
        public String shippingMethod;
        public String shipDate;
        public String weight;
        public String shipped;
        public String buyer;
        public String id;
        
        public PurchaseOrder(bthousetracker__Purchase_Orders__c purchaseOrder){
            id = purchaseOrder.Id;
            PO_No = purchaseOrder.bthousetracker__PO__c;
            status = purchaseOrder.bthousetracker__Status__c != null ? purchaseOrder.bthousetracker__Status__c : '';
            PODate = purchaseOrder.bthousetracker__Date_Issued__c != null? purchaseOrder.bthousetracker__Date_Issued__c.format() : ''; 
            revisionDate = purchaseOrder.bthousetracker__Revision_Date__c != null ? purchaseOrder.bthousetracker__Revision_Date__c.format() : '';
            
            //billTo = purchaseOrder.
            billTo = '';
            
            billToAdd = purchaseOrder.bthousetracker__Bill_To__c != null ? purchaseOrder.bthousetracker__Bill_To__c : '';
            POAmt = purchaseOrder.bthousetracker__Total_PO_Amount__c != null ? String.valueOf(purchaseOrder.bthousetracker__Total_PO_Amount__c) : '';
            
            freight = purchaseOrder.bthousetracker__Freight__c != null ? String.valueOf(purchaseOrder.bthousetracker__Freight__c) : '';
            total = purchaseOrder.bthousetracker__Total__c!= null ? String.valueOf(purchaseOrder.bthousetracker__Total__c) : '';
            totalQty = purchaseOrder.bthousetracker__Total_Quantity__c != null ? String.valueOf(purchaseOrder.bthousetracker__Total_Quantity__c) : '';
            projectName = purchaseOrder.bthousetracker__Project_Name__c != null ? purchaseOrder.bthousetracker__Project_Name__c :'';
            projectNo = purchaseOrder.bthousetracker__Property__c != null ? purchaseOrder.bthousetracker__Property__r.bthousetracker__Job_Number__c : '';
            
            //builder = purchaseOrder.
            builder = '';
            
            //projectLocation = purchaseOrder.
            projectLocation = '';
            
            shipToLocation = purchaseOrder.bthousetracker__Ship_To__c != null ? purchaseOrder.bthousetracker__Ship_To__c : '';
            shippingMethod = purchaseOrder.bthousetracker__Shipping_Method__c != null ? purchaseOrder.bthousetracker__Shipping_Method__c : '';
            shipDate = purchaseOrder.bthousetracker__Desired_Ship_Date__c != null ? purchaseOrder.bthousetracker__Desired_Ship_Date__c.format() : '';            
            weight = purchaseOrder.bthousetracker__Weight_lbs__c != null ? String.valueOf(purchaseOrder.bthousetracker__Weight_lbs__c) : '';
            shipped = purchaseOrder.bthousetracker__Shipped__c != null ? String.valueOf(purchaseOrder.bthousetracker__Shipped__c) : '';
            buyer = purchaseOrder.bthousetracker__Buyer_Name__c != null ? purchaseOrder.bthousetracker__Buyer_Name__r.Name : '';        
        }                
        
    }
    
    public Class PurchaseOrderDetails{
        public PurchaseOrder purchaseOrder;
        public ProductInfoWrapper product;
        public List<ComponentInfoWrapper> listComponents;
        public String lineNumber;
        public String orderQty;
        public String uom;
        public String price;
        public String status;
        public String qtyShipped;
        public String qtyBilled;
        public String qtyCancelled;
        public String qtyDue;
        public String requestedShipDate;
        public String lastShipDate;
        public String shipId; 
        public String extPrice;
        public String id;
        
        //--shipment Wizard
        public Boolean isSelected;
        public String qtyToShip;
        
        public  PurchaseOrderDetails(){
            isSelected = false;
            qtyToShip = '';
        }
        
        public  PurchaseOrderDetails(bthousetracker__Purchase_Order_Details__c lineItem){
            id = lineItem.Id;
            lineNumber = lineItem.bthousetracker__Line_Number__c != null ? String.valueOf(lineItem.bthousetracker__Line_Number__c) : '';
            orderQty = lineItem.bthousetracker__Order_Qty__c != null ? String.valueOf(lineItem.bthousetracker__Order_Qty__c) : '';
            uom = lineItem.bthousetracker__Order_UOM__c != null ? lineItem.bthousetracker__Order_UOM__c : '';
            price = lineItem.bthousetracker__Unit_Price__c != null ? String.valueOf(lineItem.bthousetracker__Unit_Price__c) : '';
            extPrice = lineItem.bthousetracker__Ext_Price__c != null ? String.valueOf(lineItem.bthousetracker__Ext_Price__c) : '';
            status = lineItem.bthousetracker__Line_Status__c != null ? lineItem.bthousetracker__Line_Status__c: '';
            qtyShipped = lineItem.bthousetracker__Quantity_Shipped__c != null ? String.valueOf(lineItem.bthousetracker__Quantity_Shipped__c) : '';
            qtyBilled = lineItem.bthousetracker__Quantity_Billed__c != null ? String.valueOf(lineItem.bthousetracker__Quantity_Billed__c) : '';
            qtyCancelled= lineItem.bthousetracker__Quantity_Cancelled__c != null ? String.valueOf(lineItem.bthousetracker__Quantity_Cancelled__c) : '';
            qtyDue = lineItem.bthousetracker__Quantity_Due__c != null ? String.valueOf(lineItem.bthousetracker__Quantity_Due__c) : '';
            requestedShipDate = lineItem.bthousetracker__Requested_Ship_Date__c != null ? lineItem.bthousetracker__Requested_Ship_Date__c.format() : '';
            //lastShipDate = lineItem.bthousetracker__Schedule_Ship_Date__c != null ? lineItem.bthousetracker__Schedule_Ship_Date__c : '';
            lastShipDate = '';
            shipId = lineItem.bthousetracker__Shipped__c != null ? String.valueOf(lineItem.bthousetracker__Shipped__c) : '';
            
            isSelected = false;
            qtyToShip = '';
        }  
        
                         
    }
    
     public Class ShipmentWrapper {
        public String shipId ;
        public String shipDate = '';
        public String invoiceNumber = '';
        public List<PurchaseOrderDetails> lineItems ;
        
        public ShipmentWrapper(){
        
        }     
     }          
     
     public Class pricingDataWrapper {
         public String zoneStructure;
         public String tierStructure ;        
         public List<ZonePricing> pricingList;           
     }
     
     public class AssignmentWrapper {
         public List<ProductruleWrapper> existingRules;
         public List<ProductruleWrapper > partsToAdd;
         
         public AssignmentWrapper(List<ProductruleWrapper> existingRules, List<ProductruleWrapper > partsToAdd){
             this.existingRules = existingRules;
             this.partsToAdd = partsToAdd;
             
         }
     
     }
    
}