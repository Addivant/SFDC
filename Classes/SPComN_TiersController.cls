/**
 * The Apex Controller for the VF Page -
 * SPComN_Tiers. The Apex Class exposes
 * methods that will yield the Tier
 * Information.
 * 
 * @author      BuilderTek Inc
 * @since       08 Aug 2017
 * @revisions   N/A
 */
public class SPComN_TiersController {
    public List<Tier> createdTiers                          { get; set; }
    public String catalogStatus                             { get; set; }
    public String productCategory                           { get; set; }
    public String catalogName                               { get; set; }
    public String catalogId                                 { get; set; }
    public List<bthousetracker__Supplier_Tier__c> tiers     { get; set; }
    public string componentId                               { get; set; }

    public class Tier {
        public String id              { get; set; }
        public Decimal minQty         { get; set; }
        public Decimal maxQty         { get; set; }
    }
    
    /**
     * ctor
     */
    public SPComN_TiersController () {
        componentId = ApexPages.currentPage().getParameters().get( 'componentId' );
        createdTiers = new List<Tier>();                       
        getTiers();
    }
    
    /**
     * Fetch the Tier Information
     * to build the Tables.
     */
    public void getTiers() {
        if( ApexPages.currentPage().getParameters().get( 'catalogId' ) == NULL ) {
            tiers = [
                SELECT  Name
                        ,bthousetracker__Min_Qty__c
                        ,bthousetracker__Max_Qty__c
                        ,CreatedById 
                FROM    bthousetracker__Supplier_Tier__c
                WHERE   bthousetracker__Is_Master_Tier__c = FALSE 
                ORDER BY bthousetracker__Min_Qty__c ASC
            ];
            
            for( bthousetracker__Supplier_Tier__c tier : tiers ) {
                Tier newTier = new Tier();
                newTier.id      = tier.Name;
                newTier.minQty  = tier.bthousetracker__Min_Qty__c;
                newTier.maxQty  = tier.bthousetracker__Max_Qty__c;
                
                createdTiers.add( newTier );
            }
        }
        else {
            catalogId = ApexPages.currentPage().getParameters().get( 'catalogId' );
            tiers = [
                SELECT  Name
                        ,bthousetracker__Min_Qty__c
                        ,bthousetracker__Max_Qty__c
                        ,CreatedById 
                FROM    bthousetracker__Supplier_Tier__c
                WHERE   bthousetracker__Is_Master_Tier__c = FALSE
                AND     bthousetracker__Supplier_Product_Catalog__c = :catalogId 
                ORDER BY bthousetracker__Min_Qty__c ASC
            ];
            
            for( bthousetracker__Supplier_Tier__c tier : tiers ) {
                Tier newTier = new Tier();
                newTier.id      = tier.Name;
                newTier.minQty  = tier.bthousetracker__Min_Qty__c;
                newTier.maxQty  = tier.bthousetracker__Max_Qty__c;
                
                createdTiers.add( newTier );
            }
        }
        
        if( componentId != NULL ) {
            createdTiers = new List<Tier>();
            
            tiers = [
                SELECT  Name
                        ,bthousetracker__Min_Qty__c
                        ,bthousetracker__Max_Qty__c
                        ,CreatedById 
                FROM    bthousetracker__Supplier_Tier__c
                WHERE   bthousetracker__Is_Master_Tier__c = FALSE
                AND     bthousetracker__Components__c = :componentId 
                ORDER BY bthousetracker__Min_Qty__c ASC
            ];
            
            for( bthousetracker__Supplier_Tier__c tier : tiers ) {
                Tier newTier = new Tier();
                newTier.id      = tier.Name;
                newTier.minQty  = tier.bthousetracker__Min_Qty__c;
                newTier.maxQty  = tier.bthousetracker__Max_Qty__c;
                
                createdTiers.add( newTier );
            }
        }
    }
}