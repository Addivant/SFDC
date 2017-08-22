/**
 * The Apex Class that exposes methods
 * that yields various metrics to power
 * the Supplier Dashboard for the Supplier
 * Community.
 * 
 * @author      BuilderTek Inc.
 * @since       08 Aug 2017
 * @revisions   N/A
 */
public class SPComN_SupplierKPIDashboardAPI {
    /**
     * TO DO: As of today the Apex Class
     * simply provides sample data which needs
     * to be replaced with the actual data.
     */
     
    public static final Integer TOTAL_NUMBER_OF_RECORDS = 7;
    public static final List<String> colors             = new List<String>{ 'rgb(8, 109, 182)', 'rgb(76, 142, 189)', 'rgb(117, 160, 191)',  'rgb(175, 194, 208)' };
    
    /**
     * Class(es) Representing the Data
     * for the Tables.
     */
    public class Column {
        public String title;
        
        public Column( String title ) {
            this.title = title;
        }
    }
    
    public class TableData {
        public List<Column> columns;
        public List<List<String>> rows;
        
        public TableData() {
            columns = new List<Column>();
            rows    = new List<List<String>>();
        }
    }
    
    /**
     * Class(es) Representing the Data
     * for the Charts.
     */
    public class DataSet {
        public String type;
        public String label;
        public Object backgroundColor;
        public Object borderColor;
        public Integer borderWidth;
        public Boolean fill;
        public List<Decimal> data;

        public DataSet() {
            backgroundColor = new List<String>();
            data            = new List<Decimal>();
        }
    }
    
    public class ChartData {
        public List<String> labels;
        public List<DataSet> datasets;
        
        public ChartData() {
            labels      = new List<String>();
            datasets    = new List<DataSet>();
        }
    }
    
    /**
     * Metrics Data Powering the 
     * Tables.
     */
    public static TableData getKeyMetrics( Date startDate, Date endDate ) {
        TableData keyMetrics = new TableData();
        
        keyMetrics.columns.add( new Column( 'Pending Credit' ) );
        keyMetrics.columns.add( new Column( 'Pending Approved' ) );
        keyMetrics.columns.add( new Column( 'Open' ) );
        keyMetrics.columns.add( new Column( 'Closed YTd' ) );
        keyMetrics.columns.add( new Column( 'Closed MTD' ) );
        keyMetrics.columns.add( new Column( 'POs Past Due' ) );
        keyMetrics.columns.add( new Column( 'RFQs Past Due' ) );
        keyMetrics.columns.add( new Column( 'RFQs Average Response' ) );
        
        for( Integer i = 1; i <= TOTAL_NUMBER_OF_RECORDS; i++ ) {
            keyMetrics.rows.add( 
                new List<String> { 
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    '$' + String.valueOf( ( Math.random() * 100 ).round() )
                }
            );
        }
        
        return keyMetrics;
    }
    
    public static TableData getPastDuePOList( Date startDate, Date endDate ) {
        TableData pastDuePOList = new TableData();
        
        pastDuePOList.columns.add( new Column( 'PO #' ) );
        pastDuePOList.columns.add( new Column( 'Project Name' ) );
        pastDuePOList.columns.add( new Column( 'Builder Name' ) );
        pastDuePOList.columns.add( new Column( 'Ship Date' ) );
        pastDuePOList.columns.add( new Column( 'Days Past Due' ) );
        
        for( Integer i = 1; i <= TOTAL_NUMBER_OF_RECORDS; i++ ) {
            String shipDate = String.valueOf( ( Math.random() * 10 ).round() ) + '/' + String.valueOf( ( Math.random() * 100 ).round() ) + '/' + String.valueOf( ( Math.random() * 1000 ).round() );
            pastDuePOList.rows.add( 
                new List<String> { 
                    'PO# - ' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    'BuilderTek - ' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    'John ' + String.valueOf( ( Math.random() * 10000 ).round() ),
                    shipDate,
                    String.valueOf( ( Math.random() * 10 ).round() )
                }
            );
        }
        
        return pastDuePOList;
    }
    
    public static TableData getApproachingDeadlineRFQ( Date startDate, Date endDate ) {
        TableData approachingDeadlineRFQ = new TableData();
        
        approachingDeadlineRFQ.columns.add( new Column( 'Quote #' ) );
        approachingDeadlineRFQ.columns.add( new Column( 'Project Name' ) );
        approachingDeadlineRFQ.columns.add( new Column( 'Builder Name' ) );
        approachingDeadlineRFQ.columns.add( new Column( 'Due Date' ) );
        approachingDeadlineRFQ.columns.add( new Column( 'Days Past Due' ) );
        
        for( Integer i = 1; i <= TOTAL_NUMBER_OF_RECORDS; i++ ) {
            String dueDate = String.valueOf( ( Math.random() * 10 ).round() ) + '/' + String.valueOf( ( Math.random() * 10 ).round() ) + '/' +String.valueOf( ( Math.random() * 1000 ).round() );
            
            approachingDeadlineRFQ.rows.add( 
                new List<String> { 
                    'QO# - ' + String.valueOf( ( Math.random() * 10000 ).round() ), 
                    'Approaching Deadline ' + String.valueOf( ( Math.random() * 100 ).round() ), 
                    'Micheal ' + String.valueOf( ( Math.random() * 100 ).round() ), 
                    dueDate, 
                    String.valueOf( ( Math.random() * 100 ).round() )
                }
            );
        }
        
        return approachingDeadlineRFQ;
    }
    
    public static TableData getUnreviewedRFQ( Date startDate, Date endDate ) {
        TableData unreviewedRFQ = new TableData();
        
        unreviewedRFQ.columns.add( new Column( 'Quote #' ) );
        unreviewedRFQ.columns.add( new Column( 'Project Name' ) );
        unreviewedRFQ.columns.add( new Column( 'Builder Name' ) );
        unreviewedRFQ.columns.add( new Column( 'Due Date' ) );
        unreviewedRFQ.columns.add( new Column( 'Days Past Due' ) );
        
        for( Integer i = 1; i <= TOTAL_NUMBER_OF_RECORDS; i++ ) {
            String dueDate = String.valueOf( ( Math.random() * 10 ).round() ) + '/' + String.valueOf( ( Math.random() * 100 ).round() ) + '/' + String.valueOf( ( Math.random() * 1000 ).round() );
            
            unreviewedRFQ.rows.add( 
                new List<String> { 
                    'QO# - ' + String.valueOf( ( Math.random() * 1000 ).round() ),
                    'Approaching Deadline ' + String.valueOf( ( Math.random() * 100 ).round() ),
                    'Micheal ' + String.valueOf( ( Math.random() * 100 ).round() ),
                    dueDate, 
                    String.valueOf( ( Math.random() * 100 ).round() )
                }
            );
        }
        
        return unreviewedRFQ;
    }
    
    /**
     * Metrics Data Powering the 
     * Charts.
     */
    public static ChartData getPOForecastHistorical( Date startDate, Date endDate ) {
        ChartData poForecastHistorical = new ChartData();
        
        poForecastHistorical.labels = new List<String>{ 'J', 'A', 'S', 'O', 'N', 'D', 'J', 'F', 'M', 'A', 'M', 'J' };
        List<String> groupings      = new List<String>{ 'Credit Hold', 'Approval Hold', 'Open', 'Closed' };
        
        for( Integer i = 0; i < groupings.size(); i++ ) {
            DataSet ds          = new DataSet();
            
            ds.label            = groupings[i];
            ds.backgroundColor  = colors[i];
        
            for( Integer j = 0; j < poForecastHistorical.labels.size(); j++ ) {
                ds.data.add( ( Math.random() * 100 ).round() );
            }
            
            poForecastHistorical.datasets.add( ds );
        }
        
        return poForecastHistorical;
    }
    
    public static ChartData getMTDSalesByProduct( String productName, String startDate, String endDate ) {
        ChartData mtdSalesByProduct = new ChartData();
        
        mtdSalesByProduct.labels    = new List<String>{ 'A', 'B', 'C', 'D', 'E' };
        
        DataSet ds          = new DataSet();
        ds.label            = 'MTD Sales by Product';
        ds.backgroundColor  = colors;
    
        for( Integer i = 0; i < mtdSalesByProduct.labels.size(); i++ ) {
            ds.data.add( ( Math.random() * 100 ).round() );
        }
        
        mtdSalesByProduct.datasets.add( ds );
        
        return mtdSalesByProduct;
    }
    
    public static ChartData getYTDSalesByProduct( String productName, String startDate, String endDate ) {
        ChartData ytdSalesByProduct = new ChartData();
        
        ytdSalesByProduct.labels    = new List<String>{ 'A', 'B', 'C', 'D', 'E' };
        
        DataSet ds          = new DataSet();
        ds.type             = 'pie';
        ds.label            = 'YTD Sales by Product';
        ds.backgroundColor  = colors;
    
        for( Integer i = 0; i < ytdSalesByProduct.labels.size(); i++ ) {
            ds.data.add( ( Math.random() * 100 ).round() );
        }
        
        ytdSalesByProduct.datasets.add( ds );
        
        return ytdSalesByProduct;
    }
    
    public static ChartData getRFQByMonth( Date startDate, Date endDate ) {
        ChartData rfqByMonth = new ChartData();
        
        rfqByMonth.labels = new List<String>{ 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D', 'J', 'F', 'M', 'A' };
        
        DataSet dsLine          = new DataSet();
        dsLine.label            = '$s';
        dsLine.type             = 'line';
        dsLine.borderColor      = colors[1];
        dsLine.borderWidth      = 2;
        dsLine.fill             = FALSE;
    
        for( Integer i = 0; i < rfqByMonth.labels.size(); i++ ) {
            dsLine.data.add( ( Math.random() * 100 ).round() );
        }
        
        DataSet dsBar          = new DataSet();
        dsBar.label            = 'Month';
        dsBar.type             = 'bar';
        dsBar.backgroundColor  = colors[0];
    
        for( Integer i = 0; i < rfqByMonth.labels.size(); i++ ) {
            dsBar.data.add( ( Math.random() * 100 ).round() );
        }
        
        rfqByMonth.datasets.add( dsBar );
        
        rfqByMonth.datasets.add( dsLine );
        
        return rfqByMonth;
    }
}