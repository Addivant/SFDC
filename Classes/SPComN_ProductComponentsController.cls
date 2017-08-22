/**
 * This Apex Class is used as the
 * Controller for the VF Page - 
 * SPComN_ProductComponents.
 *
 * The Apex Page displays all the
 * attributes for a given Purchase
 * Order Id.
 *
 * @author      BuilderTek Inc.
 * @since       09 Aug 2017
 * @revisions   N/A
 */
public class SPComN_ProductComponentsController {    
    public List<SP_Components> sp_Components                                        { get; set; }
    public List<PO_Attributes> po_Attributes                                        { get; set; }
    public Map<String, List<SP_Components>> groupedComponents                       { get; set; }
    public String errorMessage                                                      { get; set; }
    public Boolean isError                                                          { get; set; }
    public Boolean isAttrError                                                      { get; set; }
    public Boolean isCompError                                                      { get; set; }
    
    private List<bthousetracker__Supplier_Products_Components__c> prodComponents    { get; set; }
    private Set<String> componentIds                                                { get; set; }
    private String purchaseOrderDetailId                                            { get; set; }
    private bthousetracker__Purchase_Order_Details__c purchaseOrderDetail           { get; set; }
    private String supplierProductId                                                { get; set; }
    
    /**
     * Constructor
     */
    public SPComN_ProductComponentsController() {
        purchaseOrderDetailId   = ApexPages.currentPage().getParameters().get( 'podid' );
        purchaseOrderDetail     = new bthousetracker__Purchase_Order_Details__c();
        groupedComponents       = new Map<String, List<SP_Components>>();
        
        errorMessage            = '';
        isError                 = FALSE;
        isAttrError             = FALSE;
        isCompError             = FALSE;
        
        if( purchaseOrderDetailId != NULL && purchaseOrderDetailId != '' ) { 
            if( ( ( Id ) purchaseOrderDetailId ).getSObjectType() == 
                                            Schema.bthousetracker__Purchase_Order_Details__c.SObjectType 
            ) {
                purchaseOrderDetail       = [ SELECT    bthousetracker__Supplier_Door_Product__c,
                                                        bthousetracker__Attribute1__c,bthousetracker__Attribute11__c,
                                                        bthousetracker__Attribute2__c,bthousetracker__Attribute12__c,
                                                        bthousetracker__Attribute3__c,bthousetracker__Attribute13__c,
                                                        bthousetracker__Attribute4__c,bthousetracker__Attribute14__c,
                                                        bthousetracker__Attribute5__c,bthousetracker__Attribute15__c,
                                                        bthousetracker__Attribute6__c,bthousetracker__Attribute16__c,
                                                        bthousetracker__Attribute7__c,bthousetracker__Attribute17__c,
                                                        bthousetracker__Attribute8__c,bthousetracker__Attribute18__c,
                                                        bthousetracker__Attribute9__c,bthousetracker__Attribute19__c,
                                                        bthousetracker__Attribute10__c,bthousetracker__Attribute20__c
                                             FROM       bthousetracker__Purchase_Order_Details__c
                                             WHERE      Id = :purchaseOrderDetailId
                                             LIMIT      1
                                            ];
                
                addAttributes();
                if( purchaseOrderDetail.bthousetracker__Supplier_Door_Product__c != NULL ) {
                    supplierProductId = purchaseOrderDetail.bthousetracker__Supplier_Door_Product__c;
                    getProductComponents();
                }
                else {
                    isCompError = TRUE;
                }
            }
            else {
                errorMessage    = 'Id missing or invalid!';
                isError         = TRUE;
                isCompError     = TRUE;
                isAttrError     = TRUE;
            }
        }
        else {
            errorMessage    = 'Id missing or invalid!';
            isError         = TRUE;
            isCompError     = TRUE;
            isAttrError     = TRUE;
        }
    }
    
    ///////////////////////////
    //Private Helper Methods //
    ///////////////////////////
    private void addAttributes() {
        PO_Attributes attribute = NULL;
        po_Attributes           = new List<PO_Attributes>();
        String attrLabel;
        Map<String, Schema.SObjectField> objectFields = 
                    Schema.getGlobalDescribe().get( 'bthousetracker__Purchase_Order_Details__c' ).getDescribe().fields.getMap();
        
        for( String key : objectFields.keySet() ) {
            /**
             * TODO : Need to find a better way to do this.
             * One of the option is to use FieldSet and include
             * all the fields to be displayed under Attributes.
             */ 
            if( key.containsIgnoreCase( 'Attribute' ) ) {
                if( purchaseOrderDetail.get( key ) != NULL && purchaseOrderDetail.get( key ) != '' ) {
                    attrLabel   = objectFields.get( key ).getDescribe().getLabel();
                    attribute   = new PO_Attributes( attrLabel, String.valueOf( purchaseOrderDetail.get( key ) ) );
                    po_Attributes.add( attribute );
                }
            }
        }
        
        if( po_Attributes.size() == 0 )
            isAttrError = TRUE;
    }
    
    private void getProductComponents() {
        prodComponents          = new List<bthousetracker__Supplier_Products_Components__c>();
        componentIds            = new Set<String>();
        
        prodComponents  = [ SELECT bthousetracker__Supplier_Component__c,
                                   bthousetracker__Supplier_Product__c
                            FROM   bthousetracker__Supplier_Products_Components__c
                            WHERE  bthousetracker__Supplier_Product__c = :supplierProductId 
                          ];
        
        for( bthousetracker__Supplier_Products_Components__c spc : prodComponents ) {
            componentIds.add( spc.bthousetracker__Supplier_Component__c );
        }
        
        if( !componentIds.isEmpty() ) {
            getComponentTypes();
        }
        else {
            isCompError = TRUE;
        }
    }
    
    private void getComponentTypes() {
        sp_Components               = new List<SP_Components>();
        SP_Components sp_Component  = NULL;
        
        for( bthousetracker__Supplier_Components__c spc : 
                                [ SELECT    Name,
                                            bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c
                                  FROM      bthousetracker__Supplier_Components__c
                                  WHERE     Id IN :componentIds
                                ] 
        ) {
            sp_Component = new SP_Components(   spc.Name, 
                                                spc.bthousetracker__Supplier_Component_Type__r.bthousetracker__Description__c );
            sp_Components.add( sp_Component );
        }
        
        groupComponents();
    }
    
    private void groupComponents() {
        groupedComponents = new Map<String, List<SP_Components>>();
        
        for( SP_Components sp_com : sp_Components ) {
            if( groupedComponents.containsKey( sp_com.componentTypeDesc ) ) {
                groupedComponents.get( sp_com.componentTypeDesc ).add( sp_com );
            }
            else {
                groupedComponents.put( sp_com.componentTypeDesc, new List<SP_Components>{ sp_com } );
            }
        }
    }
    
    /////////////////
    //Helper Class //
    /////////////////
    public class SP_Components {
        public String componentName             { get; set; }
        public String componentTypeDesc         { get; set; }
        
        public SP_Components( String compName, String compTypeDesc ) {
            componentName       = compName;
            componentTypeDesc   = compTypeDesc;
        }
    }
    
    public class PO_Attributes {
        public String attributeLabel        { get; set; }
        public String attributeValue        { get; set; }
        
        public PO_Attributes( String attrLabel, String attrValue ) {
            attributeLabel = attrLabel;
            attributeValue = attrValue;
        }
    }
}