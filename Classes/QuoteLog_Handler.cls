/**********************************************************
Created 9-10-2013 by ProCore rschrader
Handler class for the Quote Log Object
	-Accept inbound calls from the Quote Log Trigger
		-When Rev Number equals zero, and Dollars is not blank
			-Quotation Value on Master Opp = Dollars
			-Quotation Date on Master Opp = Act Comp Date
			-After Insert and After Update
	New Functionality 11-13-14 ProCore rschrader
		If the Quote Log Currency is the same as the Opportunity Currency then don't change the current functionality of updates in the trigger.
		If the Quote Log Currency is different from the Opportunity Currency then:
			Update the Dollars field from Quote Log onto the Quotation Value field on the Opportunity.
			Update the Dollars field from Quote Log onto the Amount of Expected Opportunity (Amount) field on Opportunity.
			Update the currency field of the opportunity with the currency field from the Quote Log
			Update Final Contract Value without tax (BMC_Revenue__c) field to $0 on the opportunity.		

**********************************************************/
public with sharing class QuoteLog_Handler {
	
	/*
	Old Code
	
	public static void updateOpps( list< Quote_Log__c > quoteLogs_List ){
		
		//Map of Opp Ids and the related Quote_Log
		map< string, Quote_Log__c > oppIdQuotelog_Map = new map< string, Quote_Log__c >();
		
		//add valid Quote Logs to the map
		for( Quote_Log__c ql : quoteLogs_List ){
			if( ql.Rev_Number__c == 0 && ql.Dollars__c != null ){
				oppIdQuotelog_Map.put( ql.Opportunity__c, ql );
			}
		}
		//List of Opportunities to update
		list< Opportunity > opportunity_List = [SELECT Id, Quotation_Date__c, Quotation_Value__c
													FROM Opportunity
													WHERE Id IN :oppIdQuotelog_Map.keyset()];
		//Update the Opp field values with the Quote Log Values
		for( Opportunity o : opportunity_List ){
			o.Quotation_Value__c = oppIdQuotelog_Map.get( o.Id ).Dollars__c;
			o.Quotation_Date__c = oppIdQuoteLog_Map.get( o.Id ).Act_Comp_Date__c;
		}
		
		//update the Opps
		update opportunity_List;
												
	}
	*/
	
	@future()
	public static void updateOpportunities(set<ID> opportunityIDs){
		list<Opportunity> opps = [Select ID, Name, Quotation_Value__c, Quote_Date__c, Quotation_Revision__c, CurrencyIsoCode,
									  (Select ID, Dollars__c, Rev_Number__c, Act_Comp_Date__c, CurrencyIsoCode
									   FROM Quote_Logs__r)
								  
								  FROM Opportunity where ID in :opportunityIDs];
								  
		map<Opportunity,Quote_Log__c> oppQLMap = new map<Opportunity,Quote_Log__c>();
		
		system.debug( 'Opp Count: ' +oppQLMap.values().size() );
		
		for(Opportunity o : opps){
			system.debug('Opp Rev Number ' + o.Quotation_Revision__c);
			for(Quote_Log__c ql : o.Quote_Logs__r){
				system.debug('QL Rev  Number ' + ql.Rev_Number__c);
				if(ql.Rev_Number__c == o.Quotation_Revision__c){
					//New logic 11-14-14
					system.debug( 'Currency Codes: '+ o.CurrencyIsoCode + ' ' + ql.CurrencyIsoCode  );
					if( o.CurrencyIsoCode != ql.CurrencyIsoCode ){
						//Update the Dollars field from Quote Log onto the Quotation Value field on the Opportunity.
						o.Quotation_Value__c = ql.Dollars__c;
						//Update the Dollars field from Quote Log onto the Amount of Expected Opportunity (Amount) field on Opportunity.
						o.Amount = ql.Dollars__c;
						//Update the currency field of the opportunity with the currency field from the Quote Log
						o.CurrencyIsoCode = ql.CurrencyIsoCode;
						//Update Final Contract Value without tax (BMC_Revenue__c) field to $0 on the opportunity.
						o.BMC_Revenue__c = 0.00;
					}else{
						system.debug( 'Inside Else'  );
						o.Quotation_Value__c = ql.Dollars__c;
						o.Quotation_Date__c = ql.Act_Comp_Date__c;
					}
				}
			}
		}

		update opps;
	}

}