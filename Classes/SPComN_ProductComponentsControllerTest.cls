@isTest
private class SPComN_ProductComponentsControllerTest {
    
    /**
     * @description :Create test date.
     */
    @testSetup
    static void createTestData() {
        Account accountRecord   = new Account();
        accountRecord.Name      = 'portalAccount';//create a portal account first
        INSERT accountRecord;
        
        Contact objContact  = new Contact();
        objContact.LastName = 'test';
        INSERT objContact;
        
        bthousetracker__Property__c  ObjProperty    = new bthousetracker__Property__c ();
        ObjProperty.Name                            = 'Test';
        ObjProperty.bthousetracker__Home_Buyer__c   = objContact.ID;
        INSERT ObjProperty;
        
        bthousetracker__Purchase_Orders__c objPO    = new bthousetracker__Purchase_Orders__c();
        objPO.Name                                  = 'TestPO';
        objPO.bthousetracker__Status__c             = 'Open';
        objPO.bthousetracker__Total_Costs__c        = 500;
        objPO.bthousetracker__PO_Number__c          = '125';
        objPO.bthousetracker__Supplier__c           = accountRecord.id;
        objPO.bthousetracker__Property__c           = ObjProperty.id;
        objPO.bthousetracker__Shipping_Address__c   = accountRecord.id;
        INSERT objPO;
        
        bthousetracker__Purchase_Order_Details__c poDetail      = new bthousetracker__Purchase_Order_Details__c();
        poDetail.Name                                           = 'Test POD';
        poDetail.bthousetracker__Purchase_Order__c              = objPO.Id;
        poDetail.bthousetracker__Ship_To__c                     = accountRecord.id;
        poDetail.bthousetracker__Part_Number__c                 = 'Test-12';
        poDetail.bthousetracker__Order_UOM__c                   = 'EA';
        poDetail.bthousetracker__Order_Qty__c                   = 10;
        poDetail.bthousetracker__Order_Type__c                  = 'BTEK-STD-BLDR';
        poDetail.bthousetracker__Unit_Price__c                  = 20.00;
        poDetail.bthousetracker__Unit_Cost__c                   = 10;
        poDetail.bthousetracker__Weight_UOM__c                  = '10';
        poDetail.bthousetracker__Line_Number__c                 = 1;
        poDetail.bthousetracker__Template_Name__c               = 'PURCHASED BUYOUT SUPPL\'R ITEM';
        poDetail.bthousetracker__Vendor_Name__c                 = accountRecord.id;
        poDetail.bthousetracker__Currency_Code__c               = 'USD';
        poDetail.bthousetracker__BT_AMOUNT__c                   = 50.00;
        poDetail.bthousetracker__Buyer_Name__c                  = 'BUILDERTEK';
        poDetail.bthousetracker__Last_Updated_Login__c          = 1;
        poDetail.bthousetracker__Line_Id__c                     = 2;
        poDetail.bthousetracker__Request_Id__c                  = 3;
        poDetail.bthousetracker__BT_Type__c                     = 'POL';
        poDetail.bthousetracker__Request_Date__c                = system.today();
        poDetail.bthousetracker__Schedule_Ship_Date__c          = system.today();
        poDetail.bthousetracker__Promise_Date__c                = system.today();
        poDetail.bthousetracker__Category_Set_Name__c           = 'Sales and Marketing';
        poDetail.bthousetracker__Freight_Cost__c                = 20.00;
        poDetail.bthousetracker__Rate__c                        = 10.00;
        INSERT poDetail;
        
        bthousetracker__Supplier_Product_Category__c category   = new bthousetracker__Supplier_Product_Category__c();
        category.Name                                           = 'test';
        INSERT category;
        
        bthousetracker__Supplier_Product_Catalog__c catalog = new bthousetracker__Supplier_Product_Catalog__c();
        catalog.Name                                        = 'test';
        catalog.bthousetracker__BBNA_Product_Category__c    = category.id;
        catalog.bthousetracker__Supplier__c                 = accountRecord.id;
        catalog.bthousetracker__Status__c                   = 'Active';
        INSERT catalog;
                
        bthousetracker__Supplier_Door_Products__c product2      = new bthousetracker__Supplier_Door_Products__c();
        product2.Name                                           = 'test';
        product2.bthousetracker__Supplier__c                    = accountRecord.id;
        product2.bthousetracker__Status__c                      = 'Active';
        product2.bthousetracker__Sourcing_Facility__c           = 'Chicago';
        product2.bthousetracker__Lead_Time__c                   = 1;
        product2.bthousetracker__Supplier_Part__c               = 'adasd';
        product2.bthousetracker__Supplier_Product_Catalog__c    = catalog.id;
        INSERT product2;
        
        bthousetracker__Supplier_Components__c component    = new bthousetracker__Supplier_Components__c();
        component.Name                                      = 'test';
        component.bthousetracker__Component_Part__c         = '454test';
        component.bthousetracker__Supplier_Id__c            = accountRecord.id;
        component.bthousetracker__Sourcing_Facility__c      = 'Chicago';
        INSERT component;
        
        bthousetracker__Supplier_Products_Components__c spComp  = new bthousetracker__Supplier_Products_Components__c();
        spComp.bthousetracker__Supplier__c                      = accountRecord.id;
        spComp.bthousetracker__Supplier_Component__c            = component.Id;
        INSERT spComp;
    }
    
    public static testMethod void productComponents_IdMissing_Test() {
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        System.assertEquals( TRUE, ctrl.isError );
    }
    
    public static testMethod void productComponents_IdInvalid_Test() {
        String compId = [ SELECT Id FROM bthousetracker__Supplier_Components__c LIMIT 1 ].Id;
        
        ApexPages.currentPage().getParameters().put( 'podid', compId );
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        
        System.assertEquals( TRUE, ctrl.isError );
    }
    
    public static testMethod void productComponents_NoComponents_Test() {
        String podId = [ SELECT Id FROM bthousetracker__Purchase_Order_Details__c LIMIT 1 ].Id;
        
        ApexPages.currentPage().getParameters().put( 'podid', podId );
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        
        System.assertEquals( TRUE, ctrl.isCompError );
    }
    
    public static testMethod void productComponents_NoAttributes_Test() {
        String podId = [ SELECT Id FROM bthousetracker__Purchase_Order_Details__c LIMIT 1 ].Id;
        
        ApexPages.currentPage().getParameters().put( 'podid', podId );
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        
        System.assertEquals( TRUE, ctrl.isAttrError );
    }
    
    public static testMethod void productComponents_Attributes_Test() {
        String podId = [ SELECT Id FROM bthousetracker__Purchase_Order_Details__c LIMIT 1 ].Id;
        
        bthousetracker__Purchase_Order_Details__c pod   = new bthousetracker__Purchase_Order_Details__c();
        pod.Id                                          = podId;
        pod.bthousetracker__Attribute1__c               = 'Att1';
        pod.bthousetracker__Attribute4__c               = 'Att4';
        pod.bthousetracker__Attribute7__c               = 'Att7';
        pod.bthousetracker__Attribute10__c              = 'Att10';
        UPDATE pod;
        
        ApexPages.currentPage().getParameters().put( 'podid', podId );
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        
        System.assertEquals( FALSE, ctrl.isAttrError );
        System.assertEquals( TRUE, ctrl.po_Attributes.size() > 0 );
    }
    
    public static testMethod void productComponents_Components_Test() {
        String podId        = [ SELECT Id FROM bthousetracker__Purchase_Order_Details__c LIMIT 1 ].Id;
        String spId         = [ SELECT Id FROM bthousetracker__Supplier_Door_Products__c LIMIT 1 ].Id;
        String spCompId     = [ SELECT Id FROM bthousetracker__Supplier_Products_Components__c LIMIT 1 ].Id;
        
        bthousetracker__Purchase_Order_Details__c pod   = new bthousetracker__Purchase_Order_Details__c();
        pod.Id                                          = podId;
        pod.bthousetracker__Supplier_Door_Product__c    = spId;
        UPDATE pod;
        
        bthousetracker__Supplier_Products_Components__c spComp  = new bthousetracker__Supplier_Products_Components__c();
        spComp.Id                                               = spCompId;
        spComp.bthousetracker__Supplier_Product__c              = spId;
        UPDATE spComp;
        
        ApexPages.currentPage().getParameters().put( 'podid', podId );
        SPComN_ProductComponentsController ctrl = new SPComN_ProductComponentsController();
        
        System.assertEquals( FALSE, ctrl.isCompError );
        System.assertEquals( TRUE, ctrl.sp_Components.size() > 0 );
    }
}