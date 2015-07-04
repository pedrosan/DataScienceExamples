# libraries
library(shiny)

# my functions
source("scripts/my_functions1.R")
source("scripts/my_functions2.R")

# list of variables names
# paramNamesMort <- c("start_prop_value", "down_payment_pct", "mortgage_rate", "n_years")

paramNames <- c("start_prop_value", "down_payment_pct", "mortgage_rate", "n_years", 
                "initial_fixed_costs",
                "prop_tax_rate_pct", "prop_insurance", "HOA_monthly_fee",
                "start_rent", "rent_insurance",
                "annual_appreciation", "annual_appreciation_sd",
                "annual_inv", "annual_inv_sd",
                "annual_inflation", "annual_inflation_sd",
                "annual_rent_extra_increase_mean",
                "fraction_extra_cash_invested_pct",
                "income_tax_rate_pct", "itemized_deductions", "std_deduction",
                "n_sim")

#---------------------------------------------------------------------------------------------------
shinyServer(function(input, output, session) {

  #-------------------------------------------------------------------------------
  # Function that generates and computes trade-off scenarios.
  # The expression is wrapped in a call to "reactive" and
  # therefore should be automatically re-executed when inputs change
  #
  sim.tradeoff <- reactive( do.call(simulate_tradeoff, getParams1(input, paramNames)) ) 

  # Expression that plot simulated data.
  # The expression is wrapped in a call to "renderPlot" and therefore
  # it is "reactive" and should be automatically re-executed when inputs change.
  # The output type is a plot.
  #
  output$multiPlot <- renderPlot({
        n.sim <- getParams1(input, "n_sim")[[1]]
        n.years <- getParams1(input, "n_years")[[1]]
  	plot_sims(n.sim, n.years, sim.tradeoff())
  })
})

