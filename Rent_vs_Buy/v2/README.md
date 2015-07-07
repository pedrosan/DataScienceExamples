BvsR
====

## A _Buy vs. Rent_ calculator

### [[Running on ShinyApps]](https://pedrosan.shinyapps.io/AdvBvsR/)

A calculator for a more comprehensive and realistic scenario comparing the cost/benefits of 
buying a property vs. renting a comparable one.

It takes into account taxes, and tax benefits of the mortgage interest deduction (if applicable when compared
with a standard deduction), the benefits of re-investing money potentially saved by renting instead of buying,
as well of the benefit of the return of investment of the capital not put into a down-payment.

Given the parameter values, 250 simulations are performed, with stochastic 'predictions' of 
the property appreciation, (alternative) investment return, inflation, rent increase.

For each simulation a 'trade-off' value is computed, giving the difference between buying the given
property and renting (including the return of the investment of the cash not put into the property).
Positive values are in favor of buying, negative indicate that renting would be more beneficial financially.

Results are summarized in three plots, showing:

1. the trends of the 'tradeoff' amount, 
2. the fraction of simulations favoring buying over renting, over time,
3. the distribution of tradeoff amounts over time, highligthing the distributions at 1/2, 3/4 and at the end of the loan period."

### Terse explanation of the input parameters

#### House and Mortgage

* Purchase Price ($): 
* Down Payment (%) :
* Mortgage Rate (%):
* Duration (years):
* Initial Fixed Costs ($) : Additional cost incurred when buying a property, e.g. closing costs, or repairs.

#### Ownership Costs: Prop. Taxes, Insurance, Fees

* Prop. Tax Rate (%) :
* Insurance Cost ($) : home-owner insurance premium (annual).
* HOA Monthly Fee ($) : home-owner association fees (monthly).
          
#### Rent

* Rent, Monthly ($) : ideally the monthly for a comparable property.
* Renter Insurance ($) :
* Fraction of Saved Cash Re-invested (%) : if the total costs of renting are lower than those of owning, a portion of the saved cash can be re-invested.    
This parameter regulated the fraction of saved cash that is added to the investments.
    
#### Income Tax Related

* Marginal Income Tax (%) : tax rate to use to calculate the potential tax-savings of the deduction of mortgage interests.
* Other Itemized Deductions ($): the mortgage interest deduction can only be taken if one itemizes all deductions, thus losing the standard deduction (see next).  
				 Because of this, the actual benefit of the mortgage interest deduction is only related to the portion that exceeds the standard deduction.
* Standard Deduction : please note that it may be different if filing as married or separately.

#### Property Appreciation

Assuming uncorrelated normally distributed values.

* Appreciation (%) : mean yearly increase of property values.
* Appreciation Std.Dev. (%) : "volatility" of the property value changes.
          
#### Cash Investment Return

Assuming uncorrelated normally distributed values.

* Return (%) : mean yearly return of 'cash' investments.
* Return Std.Dev. (%) : "volatility" of 'cash' investment returns.

#### Inflation

Assuming uncorrelated normally distributed values".

* Inflation (%) : mean yearly inflation rate.
* Inflation Std.Dev. (%) : "volatility" of inflation.
          
#### Rent Increase

* Extra Increase Over Inflation (%) : Extra rate of increase of rent, on top of inflation.  
Values are drawn from an exponential distribution with this mean.

