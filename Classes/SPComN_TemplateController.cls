public Class SPComN_TemplateController {


    //public List<bthousetracker__Supplier_Product_Catalog__c> catalogs {get; set;}
    public List<Catalog> activeCatalogs {get; set;}
    public List<Catalog> pendingCatalogs {get; set;}
    public List<Catalog> archivedCatalogs {get; set;}
    public String currentPage {get; set;}
    public String currentCatalogId {get; set;}
    public String catalogStatus {get; set;}
    public Boolean isSideBarCollapsed {get; set;}
    public String openedMenuId {get; set;}
    public String openedSubMenuId {get; set;}
    
    public SPComN_TemplateController () {                

        currentPage = Apexpages.currentPage().getParameters().get('currentPage');
        currentCatalogId = Apexpages.currentPage().getParameters().get('catalogId');
        catalogStatus = Apexpages.currentPage().getParameters().get('catalogStatus');
        openedMenuId = '';
        openedSubMenuId = '';

        Cookie sideBarCookie= Apexpages.currentPage().getCookies().get('sidebar');        //this cookie is used to save the state of the sidebar (collapsed vs uncollapsed), and the value of it is set in javascript

        if (sideBarCookie != null) {

            String sideBarCookieValue = sideBarCookie.getValue();                        

            if (sideBarCookieValue == 'collapsed') {
                isSideBarCollapsed = true;
            }
        }        

        Cookie uncollapsedMenuCookie = Apexpages.currentPage().getCookies().get('uncollapsedMenu');         //this cookie is used to save the state of the uncollapsed menu item in the sidebar, the value is set in javascript

        if (uncollapsedMenuCookie != null) {

            openedMenuId = uncollapsedMenuCookie.getValue();

            //String uncollapsedMenuCookieValue = uncollapsedMenuCookie.getValue();

            //if (uncollapsedMenuCookieValue == 'catalogs-collapse') {
            //    isCatalogsMenuOpened = true;
            //}

        }

        Cookie uncollapsedSubMenuCookie = Apexpages.currentPage().getCookies().get('uncollapsedSubMenu');         //this cookie is used to save the state of the uncollapsed menu item in the sidebar, the value is set in javascript

        if (uncollapsedSubMenuCookie != null) {

            openedSubMenuId = uncollapsedSubMenuCookie.getValue();            

        }


        //catalogs = getCatalogs('Active');
        
        activeCatalogs = getCatalogs('Active');
        pendingCatalogs = getCatalogs('Pending');
        archivedCatalogs = getCatalogs('Archived');
    }  

    public List<Catalog> getCatalogs(String requestedStatus) {        

        List<Catalog> catalogsToReturn = new List<Catalog>();

        if (requestedStatus == 'Active') {

            Catalog doorCatalog = new Catalog();

            doorCatalog.id = '1';
            doorCatalog.name = 'Door Catalog Active';
            doorCatalog.status = 'Active';
            doorCatalog.productCategory = 'Door';

            catalogsToreturn.add(doorCatalog);

        }

        if (requestedStatus == 'Pending') {

            Catalog doorCatalog = new Catalog();

            doorCatalog.id = '2';
            doorCatalog.name = 'Door Catalog Pending';
            doorCatalog.status = 'Pending';
            doorCatalog.productCategory = 'Door';

            catalogsToreturn.add(doorCatalog);

        }

        if (requestedStatus == 'Archived') {

            Catalog doorCatalog = new Catalog();

            doorCatalog.id = '3';
            doorCatalog.name = 'Door Catalog Archived';
            doorCatalog.status = 'Archived';
            doorCatalog.productCategory = 'Door';

            catalogsToreturn.add(doorCatalog);
        }
      
      return catalogsToreturn;

    }

    //public List<bthousetracker__Supplier_Product_Catalog__c> getCatalogs(String status) {        
    
    //    List<bthousetracker__Supplier_Product_Catalog__c> catalogsToreturn = new List<bthousetracker__Supplier_Product_Catalog__c>();
        
    //    String query = 'SELECT Id, Name, bthousetracker__BBNA_Product_Category__r.Name, bthousetracker__BBNA_Product_Category__c, bthousetracker__Status__c ' +
    //                   ' FROM bthousetracker__Supplier_Product_Catalog__c WHERE bthousetracker__Status__c = :status ';
        
    //    catalogsToreturn = Database.query(query);
        
    //    return catalogsToreturn;
    //}


    private Class Catalog {

        public String id {get; set;}
        public String name {get; set;}
        public String status {get; set;}
        public String productCategory {get; set;}

    }



}