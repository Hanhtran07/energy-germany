#🇩🇪 Germany Energy Transition Analysis  

End – to – end data analytics project analyzing Germany’s energy generation transition toward renewable energy using Python for cleaning data, PostgreSQL for analyzing and Power BI for visualizing.  


## Project Overview  

This project explores Germany’s electricity generation mix patterns from 2018 to April 2026 using 282,432 data points at 15- minute resolution from Bundesnetzagentur SMARD.  

The analysis focuses on:  

    Renewable energy growth  

    Fossil fuel decline  

    Nuclear phase- out after 2023  

    Seasonal & hourly renewable patterns  

    Green energy intervals  

    Wind & solar dominance  

    Renewable percentage trends  

## Tech Stack  

    Python (pandas): Data cleaning & feature engineering  

    PostgreSQL: Data storage & SQL analysis  

    Power BI: Interactive dashboard  

## Data Source  

[Bundesnetzagentur SMARD](https://www.smard.de/downloadcenter) — Official German energy regulator data 

## Data Model  

Star schema with 3 tables:  

    fct_summary – 282,432 rows, 15-min generation data  

    dim_time – Time dimension  

    dim_energy_source  - Energy source classification  

## Key Insights  

    Renewable share increased from 38,6% to 58,24% (2018-2025) 

    Growth driven primarily by wind + solar expansion  

    Solar dominates summer, especially midday peaks  

    Wind dominates winter nighttime generation  

    Overall, wind generation is much more then solar  

    Nuclear phase-out (2023) successfully offset by renewables  

    Longest renewable streak: 887 consecutive hours (Feb 2020) 

    First sustained > 70% renewable month observed in June 2025 

    Fossil share declined over the period (2018 - 4/2026)  

## SQL Analysis  

Medium to advanced SQL techniques used: 

    Window functions (LAG, LEAD, RANK, ROW() )  

    Gaps & islands analysis (energy streaks)  

    Percentile analysis of renewable distribution  

    Time-based aggregations (hour / season level) 

    JOINS; Nested queries  

 

## Dashboard Overview  

Page 1 – Overview Page  

    KPI cards: Renewable TWh, Fossil TWh, Avg Renewable %, Green Intervals % 

    Renewale vs Fossil vs Nuclear trend line chart  

    Energy mix by year  

    Avg Renewable % by year  

Page 2 – Renewable Patterns  

    Solar vs Wind seasonal pattern  

    Year & Season heatmap  

    Renewable trends by year  

    Energy mix by source (renewable energy)  

 

 

 

 

 

 
