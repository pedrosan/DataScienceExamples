    
## Model Parameters

### Buy, Rent and Tax Parameters

* House and Mortgage
    * Purchase Price ($)
    * Down Payment (%)
    * Mortgage Rate (%)
    * Duration (years)
    * Initial Fixed Costs ($): additional cost incurred when buying a property, e.g. closing costs, or repairs.
       
* Ownership Costs: Prop. Taxes, Insurance, Fees
    *Prop. Tax Rate (%)
    *Insurance Cost ($): home-owner insurance premium (annual).
    *HOA Monthly Fee ($): home-owner association fees (monthly).
          
* Rent
    * Rent, Monthly ($): ideally the monthly for a comparable property.
    * Renter Insurance ($)
    * Fraction of Saved Cash Re-invested (%): 
            if the total costs of renting are lower than those of owning, a portion of the saved cash can be re-invested.  
	    This parameter regulated the fraction of saved cash that is added to the investments.
    
* Income Tax Related
    * Marginal Income Tax (%): tax rate to use to calculate the potential tax-savings of the deduction of mortgage interests.
    * Other Itemized Deductions ($): the mortgage interest deduction can only be taken if one itemizes all deductions, thus
	                             losing the standard deduction (see next).  
				     Because of this, the actual benefit of the mortgage interest deduction is only 
                                     related to the portion that exceeds the standard deduction.
    * Standard Deduction: please note that it may be different if filing as married or separately.

### Annual Variations

* Property Appreciation (assuming uncorrelated normally distributed values)
    * Appreciation (%): mean yearly increase of property values.
    * Appreciation Std.Dev. (%): "volatility" of the property value changes.
          
* Cash Investment Return (assuming uncorrelated normally distributed values)
    * Return (%):  mean yearly return of cash investments.
    * Return Std.Dev. (%): "volatility" of cash investment returns.

* Inflation (assuming uncorrelated normally distributed values)
    * Inflation (%): mean yearly inflation rate.
    * Inflation Std.Dev. (%): "volatility" of inflation.
          
* Rent Increase
    * Extra Increase Over Inflation (%): Extra rate of increase of rent, on top of inflation.   
      Values are drawn from an exponential distribution with this mean.


