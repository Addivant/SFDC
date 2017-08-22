/**
    Purpose : Controller class for CatalogModal. 
*/
public Class SPComN_CatalogDetailModalCntrl{
    public String catalogName {get; set;}
    
    public SPComN_CatalogDetailModalCntrl(){
        String catalogId = Apexpages.currentPage().getParameters().get('catalogId');
        if(String.isNotBlank(catalogId))
            catalogName = SPComN_Utils.getCatalogName(catalogId); //get Catalog Name 
    }
}