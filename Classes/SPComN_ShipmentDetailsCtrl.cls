/**
 * The Apex Controller used for the
 * VF Page - SPComN_ShipmentDetails.
 * The page displays the details of
 * the Shipment along with the Shipment
 * Line Items in a tabular fashion. The
 * Shipment Lines will also diplay the
 * attributes.
 *
 * @author      BuilderTek Inc.
 * @since       08 Aug 2017
 * @revisions   N/A
 */
public class SPComN_ShipmentDetailsCtrl {
    public String shipmentId                        { get; set; }
    public bthousetracker__Shipments__c shipment    { get; set; }
    
    /**
     * ctor
     *
     * @see     BuilderTekUtils.getFieldSetMembers      Yields all the Fields in a given
     *                                                  Field Set defined on the given
     *                                                  Object.
     */
    public SPComN_ShipmentDetailsCtrl() {
        String query = 'SELECT ';
        if( ApexPages.currentPage().getParameters().get( 'ShipmentId' ) != NULL ) {
            shipmentId = ApexPages.currentPage().getParameters().get( 'ShipmentId' );
            
            for( Schema.FieldSetMember fsMember : BuilderTekUtils.getFieldSetMembers
                ( 'bthousetracker__Shipments_Record_Detail_view', 'bthousetracker__Shipments__c' ) ) {
                query += fsMember.getFieldPath() + ', ';
            }
         
            query += ' Id, ( SELECT Id, Name, bthousetracker__Line__c, bthousetracker__Part_Number__c, bthousetracker__Description__c, bthousetracker__Qty_Due__c, bthousetracker__Qty_Shipped__c,'; 
            query += ' bthousetracker__UOM__c, bthousetracker__Weight__c, bthousetracker__Supplier_Door_Product__c, bthousetracker__Purchase_Order_Details__c FROM bthousetracker__Shipment_Details__r ),';
            query += ' ( SELECT Id, Name FROM Attachments ) FROM bthousetracker__Shipments__c WHERE Id = \'' + shipmentId + '\'';
            
            shipment = Database.query( query );
        }
    }
}