/**
 * The Apex Controller for the VF Page -
 * SPComN_Dashboard_KPIS. The Class exposes
 * Remote Actions that will be invoked
 * from the JavaScript on the "SPComN_Dashboard_KPIS"
 * page to produce Charts/Tables.
 * 
 * @author      BuilderTek Inc
 * @since       08 Aug 2017
 * @revision    N/A
 */
global class SPComN_Dashboard_KPISCtrl {
    /**
     * ctor
     */
    public SPComN_Dashboard_KPISCtrl() {
        
    }
    
    @RemoteAction
    public static ActionResponse getKeyMetrics() {
        SPComN_SupplierKPIDashboardAPI.TableData keyMetrics = SPComN_SupplierKPIDashboardAPI.getKeyMetrics( NULL, NULL );
        return new ActionResponse( TRUE, NULL, keyMetrics );
    }
    
    @RemoteAction
    public static ActionResponse getPastDuePOList() {
        SPComN_SupplierKPIDashboardAPI.TableData pastDuePOList = SPComN_SupplierKPIDashboardAPI.getPastDuePOList( NULL, NULL );
        return new ActionResponse( TRUE, NULL, pastDuePOList );
    }
    
    @RemoteAction
    public static ActionResponse getApproachingDeadlineRFQ() {
        SPComN_SupplierKPIDashboardAPI.TableData approachingDeadlineRFQ = SPComN_SupplierKPIDashboardAPI.getApproachingDeadlineRFQ( NULL, NULL );
        return new ActionResponse( TRUE, NULL, approachingDeadlineRFQ );
    }
    
    @RemoteAction
    public static ActionResponse getUnreviewedRFQ() {
        SPComN_SupplierKPIDashboardAPI.TableData unreviewedRFQ = SPComN_SupplierKPIDashboardAPI.getUnreviewedRFQ( NULL, NULL );
        return new ActionResponse( TRUE, NULL, unreviewedRFQ );
    }
    
    @RemoteAction
    public static ActionResponse getPOForecastHistorical() {
        SPComN_SupplierKPIDashboardAPI.ChartData poForecastHistorical = SPComN_SupplierKPIDashboardAPI.getPOForecastHistorical( NULL, NULL );
        return new ActionResponse( TRUE, NULL, poForecastHistorical );
    }
    
    @RemoteAction
    public static ActionResponse getMTDSalesByProduct() {
        SPComN_SupplierKPIDashboardAPI.ChartData mtdSalesByProduct = SPComN_SupplierKPIDashboardAPI.getMTDSalesByProduct( NULL, NULL, NULL );
        return new ActionResponse( TRUE, NULL, mtdSalesByProduct );
    }
    
    @RemoteAction
    public static ActionResponse getYTDSalesByProduct() {
        SPComN_SupplierKPIDashboardAPI.ChartData ytdSalesByProduct = SPComN_SupplierKPIDashboardAPI.getYTDSalesByProduct( NULL, NULL, NULL );
        return new ActionResponse( TRUE, NULL, ytdSalesByProduct );
    }
    
    @RemoteAction
    public static ActionResponse getRFQByMonth() {
        SPComN_SupplierKPIDashboardAPI.ChartData rfqByMonth = SPComN_SupplierKPIDashboardAPI.getRFQByMonth( NULL, NULL );
        return new ActionResponse( TRUE, NULL, rfqByMonth );
    }
}