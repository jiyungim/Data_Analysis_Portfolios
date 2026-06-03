# Loan Approval Analysis

## Overview
This project explores the key factors affecting loan approval decisions through SQL-based data analysis and Tableau visualization. The analysis examines employment status, credit quality, income levels, and risk segmentation to uncover trends and support risk-based decision making.

## Tools
- SQL (data cleaning, aggregation, segmentation analysis)
- Tableau (interactive dashboard and data visualization)

## Skills & Techniques
- Data Cleaning & Validation
- CASE WHEN Segmentation
- Aggregate Analysis
- Risk Classification
- Approval Rate Analysis
- Dashboard Design
- Business Insight Generation
 
## Key Insights
- Employment status showed one of the strongest relationships with loan approval outcomes. Unemployed applicants consistently exhibited extremely low approval rates, even when combined with high income and excellent credit scores.
- Credit score and income level both demonstrated meaningful relationships with approval probability, but neither variable alone fully explained approval outcomes.
- Multi-factor analysis revealed that loan approval decisions appear to rely on combinations of financial strength and employment stability rather than isolated applicant characteristics.
 - The risk segmentation model created a clear separation between high-risk and low-risk applicant groups, suggesting that combined risk indicators may be useful for preliminary applicant screening.

## Business Recommendations
- Employment stability should remain a critical component of loan approval assessment, as unemployed applicants demonstrated substantially lower approval rates even under otherwise strong financial conditions.
- Introduce early-stage applicant risk segmentation to improve approval efficiency and reduce manual review workload for high-risk applications.
- Collect additional applicant variables such as existing debt, repayment history, loan purpose, and collateral information to improve predictive accuracy and explain unexpected approval patterns.

## Files
- SQL: [Loan Approval Analysis](https://github.com/jiyungim/Data_Analysis_Portfolios/blob/main/spotify-track-popularity-analysis/Spotify%20Track%20Popularity%20%26%20Streaming%20Trends%20Analysis.ipynb)
- Tableau: [Loan Approval Analysis Dashboard](https://public.tableau.com/views/LoanApprovalAnalysisDashboard_17805090891440/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)  (Link to Tableau)
- Dataset: [loan_data](https://github.com/jiyungim/Data_Analysis_Portfolios/blob/main/loan-approval-analysis/loan_data.csv)  (Source: Kaggle)
-   The dataset contains 5,000 loan application records including applicant demographics, employment status, income, credit score, loan amount, and approval outcomes.

## Dashboard Preview (Tableau)

![Dashboard Overview](https://github.com/jiyungim/Data_Analysis_Portfolios/blob/main/loan-approval-analysis/Loan%20Approval%20Analysis%20Dashboard.png)
