/*
 * @purpose:     Controller for PurchaseOrderChartCmp Component
 *               It shows total $ amount of Open PO’s - Purchase Order Object. 
 * @created Date: 28 March, 2017
 */
public class PurchaseOrderChartController {
  
    /*
     * @purpost: To create list of data to be shown in chart
     * @param:   -
     * @return:  List of Chart Data Wrapper
     */
    @RemoteAction
    public static List<ChartData>  getChartData(){
        
        List<ChartData> chartDataList = new List<ChartData>();
        List<bthousetracker__Purchase_Orders__c > purchaseOrderList = getListOfPurchaseOrder();
        
        for(bthousetracker__Purchase_Orders__c purchaseOrder: purchaseOrderList){
            chartDataList.add(new ChartData(purchaseOrder.Name, purchaseOrder.bthousetracker__Total_Bill_Amount__c));
        }
        
        return chartDataList;
    }

    /*
     * @purpose: To get list of open purchase order, with total amount.
     * @param:   -
     * @return: List of bthousetracker__Purchase_Orders__c.
     */
    public static List<bthousetracker__Purchase_Orders__c> getListOfPurchaseOrder(){
        
        List<bthousetracker__Purchase_Orders__c> purchaseOrderList = new List<bthousetracker__Purchase_Orders__c >();
        
        try{
            purchaseOrderList = [SELECT Name, bthousetracker__Total_Bill_Amount__c, bthousetracker__Status__c
                                 FROM bthousetracker__Purchase_Orders__c
                                 WHERE bthousetracker__Status__c =: 'Open' 
                                 Order By bthousetracker__Total_Bill_Amount__c desc  
                                 LIMIT 30];
        }
        catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }
        return purchaseOrderList;
    }
    
    //Wrapper contain Purchase Order Name and total Amount. 
    public class ChartData{
        
        String purchaseOrderName;
        Decimal totalBillAmount;
        public chartData(String purchaseOrderName, Decimal totalBillAmount){
            this.purchaseOrderName= purchaseOrderName;
            this.totalBillAmount= totalBillAmount;
        }
    }
}