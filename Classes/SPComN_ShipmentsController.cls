/**
 * Apex Controller used for the
 * VF Page - SPComN_Shipments.
 *
 * @author      BuilderTek Inc
 * @since       08 Aug 2017
 * @revision    N/A
 */
public class SPComN_ShipmentsController {
    public List<bthousetracker__Shipments__c> shipments     { get; set; }
    public bthousetracker__Shipments__c shipment            { get; set; }
    public String shipmentId                                { get; set; }
    
    /**
     * ctor
     *
     * @see     BuilderTekUtils.getFieldSetMembers      Yields all the Fields in a given
     *                                                  Field Set defined on the given
     *                                                  Object.
     */
    public SPComN_ShipmentsController() {
        shipments = new List<bthousetracker__Shipments__c>();

        /**
         * Determine the columns for the
         * table that will list all the
         * Shipments. The fields aka. the
         * Columns for the tables are defined
         * on a Field Set created on the
         * Supplier Shipment object.
         */
        String query = 'SELECT ';             
        for( Schema.FieldSetMember fsMember : BuilderTekUtils.getFieldSetMembers
            ( 'bthousetracker__Shipments_Detail_view', 'bthousetracker__Shipments__c' ) ) {
            query += fsMember.getFieldPath() + ', ';
        }
     
        query += ' Id,bthousetracker__BT_Purchase_Order__c FROM bthousetracker__Shipments__c ORDER BY bthousetracker__Ship_Date__c DESC';
        
        shipments = Database.query( query );
    }
}