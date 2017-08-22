@isTest
public class SPComN_WrapperTest {
	    @TestSetup
    	public static void testSetupRecord(){
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Chatter External User' LIMIT 1];
        
            User newUser = new User(FirstName = 'Tony',
                                    LastName = 'Stark',
                                    Email = 'Tony@amamama.com',
                                    Username = 'tonystark@amam.com',
                                    CompanyName = 'TEST',
                                    Title = 'title',
                                    Alias = 'alias',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    EmailEncodingKey = 'UTF-8',
                                    LanguageLocaleKey = 'en_US',
                                    LocaleSidKey = 'en_US',
                                    ProfileId = profileId.Id);
            
            INSERT newUser;
            
            User getUser = [SELECT Id, Name FROM User WHERE FirstName = 'Tony' LIMIT 1];
            Account account = new Account(Name = 'TestAccount',
                                          Type = 'Owner',
                                          CurrencyIsoCode = 'USD',
                                          CAM__c = getUser.Id,
                                          Territory__c = 'North America',
                                          Physical_Country__c = 'United States');
        
            INSERT account;
            
            List<bthousetracker__Supplier_Product_Category__c>  listSupplierProductCategory = new List<bthousetracker__Supplier_Product_Category__c>();
        
            
            for(Integer i=0;i<2;i++){
                
                bthousetracker__Supplier_Product_Category__c newSupplierProductCategory;
                if(i/2==0){
                    newSupplierProductCategory = new bthousetracker__Supplier_Product_Category__c(Name='Supplier' + i,
                                                                                                  bthousetracker__Supplier__c = account.Id);
                    listSupplierProductCategory.add(newSupplierProductCategory);
                }else{
                    newSupplierProductCategory = new bthousetracker__Supplier_Product_Category__c(Name='Product' + i,
                                                                                                  bthousetracker__Supplier__c = account.Id);
                    listSupplierProductCategory.add(newSupplierProductCategory);
                }
            }
            
            INSERT listSupplierProductCategory;
            
            List<bthousetracker__Supplier_Product_Catalog__c> listsSupplierProductCatalog = new List<bthousetracker__Supplier_Product_Catalog__c>();
            
            bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog = new bthousetracker__Supplier_Product_Catalog__c(Name = 'testproduct'+1,
                                                                                                                                 bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[0].Id,
                                                                                                                                 bthousetracker__Status__c = 'Pending',
                                                                                                                                 bthousetracker__Activate_Date__c = System.today(),
                                                                                                                                 bthousetracker__Supplier__c = account.Id);
            
            listsSupplierProductCatalog.add(supplierProductCatalog);
            bthousetracker__Supplier_Product_Catalog__c supplierProductCatalog1 = new bthousetracker__Supplier_Product_Catalog__c(Name = 'testproduct'+2,
                                                                                                                                  bthousetracker__BBNA_Product_Category__c = listSupplierProductCategory[1].Id,
                                                                                                                                  bthousetracker__Status__c = 'Active',
                                                                                                                                  bthousetracker__Activate_Date__c = System.today(),
                                                                                                                                  bthousetracker__Supplier__c = account.Id);
            listsSupplierProductCatalog.add(supplierProductCatalog1);
            
            INSERT supplierProductCatalog;
            INSERT supplierProductCatalog1;            
        }

		@isTest
    	private static void positiveTest(){
            
            
            
        }   
            
}