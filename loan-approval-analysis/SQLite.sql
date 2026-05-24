/* =====================================================
Loan Approval Analysis
===================================================== */
/*-------------------------------------------------------------------------------------------
PART 1 - Data Cleaning
-------------------------------------------------------------------------------------------*/
-- Purpose:
-- Review overall data quality and identify potential issues before performing analysis.

-- Q1. Review Raw Data Structure
SELECT *
FROM loan_data
LIMIT 10;

-- Q2. Check for Duplicate Records
SELECT *,
       COUNT(*) AS duplicate_count
FROM loan_data
GROUP BY
    Age,
    Income,
    LoanAmount,
    CreditScore,
    YearsExperience,
    Gender,
    Education,
    City,
    EmploymentType,
    LoanApproved
HAVING COUNT(*) > 1;
-- Findings:
-- No unique identifier was available in the dataset, so exact duplicate applicants could not be confirmed.
-- However, duplicate full rows were checked for potential repeated records.



-- Q3. Check for Null or Blank Values
SELECT
SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS null_income,

SUM(CASE WHEN LoanAmount IS NULL THEN 1 ELSE 0 END) AS null_loanamount,

SUM(CASE WHEN CreditScore IS NULL THEN 1 ELSE 0 END) AS null_creditscore,

SUM(CASE WHEN YearsExperience IS NULL THEN 1 ELSE 0 END) AS null_yearsexperience,

SUM(CASE
        WHEN Gender IS NULL
          OR TRIM(Gender) = ''
        THEN 1 ELSE 0
    END) AS null_gender,

SUM(CASE
        WHEN Education IS NULL
          OR TRIM(Education) = ''
        THEN 1 ELSE 0
    END) AS null_education,

SUM(CASE
        WHEN City IS NULL
          OR TRIM(City) = ''
        THEN 1 ELSE 0
    END) AS null_city,

SUM(CASE
        WHEN EmploymentType IS NULL
          OR TRIM(EmploymentType) = ''
        THEN 1 ELSE 0
    END) AS null_employmenttype,

SUM(CASE WHEN LoanApproved IS NULL THEN 1 ELSE 0 END) AS null_loanapproved

FROM loan_data;
-- Findings:
-- Data quality checks identified a small number of null or blank values in the Income, CreditScore, and Education columns.
-- Results showed: null_income = 196, null_creditscore = 194, null_education = 198
-- Because the proportion of these records was relatively low and their absence may reflect real-world incomplete or undisclosed information, the values were retained in the dataset rather than removed or imputed.
-- The original dataset was preserved to avoid introducing assumptions during the data cleaning process.


-- Q4. Check for Potential Outliers and Invalid Values
-- Purpose:
-- Identify potentially unrealistic financial or demographic values that could affect analytical accuracy.
SELECT *
FROM loan_data
WHERE Age < 18
   OR YearsExperience < 0
   OR YearsExperience > Age
   OR Income < 0
   OR LoanAmount < 0
   OR CreditScore NOT BETWEEN 300 AND 850;
-- Validation Rules:
-- Applicants under 18 were considered unrealistic.
-- Work experience greater than applicant age was considered invalid.
-- Negative income and loan amounts were considered invalid.
-- Credit scores outside the standard 300–850 range were considered abnormal.

-- Q5. Count Invalid or Unrealistic Records
SELECT
SUM(CASE WHEN Age < 18 THEN 1 ELSE 0 END) AS invalid_age,
SUM(CASE WHEN YearsExperience < 0 THEN 1 ELSE 0 END) AS negative_experience,

SUM(CASE WHEN YearsExperience > Age THEN 1 ELSE 0 END) AS experience_gt_age,

SUM(CASE WHEN Income < 0 THEN 1 ELSE 0 END) AS negative_income,

SUM(CASE WHEN LoanAmount < 0 THEN 1 ELSE 0 END) AS negative_loanamount,

SUM(
    CASE
        WHEN CreditScore IS NOT NULL
         AND CreditScore NOT BETWEEN 300 AND 850
        THEN 1
        ELSE 0
    END
) AS invalid_creditscore
FROM loan_data;
-- Findings:
-- Results showed: experience_gt_age = 574, negative_income = 3, negative_loanamount = 28
-- These observations were retained in the raw dataset to preserve the original data.
-- Instead of deleting records, filtering conditions were applied selectively during analysis to reduce the impact of unrealistic values on analytical results.



/*-------------------------------------------------------------------------------------------
PART 2 - Basic Approval Analysis
-------------------------------------------------------------------------------------------*/
-- Purpose:
-- Analyze overall loan approval trends across applicant groups.

-- Q1. Overall Loan Approval Rate
SELECT
ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data;
-- Findings: Calculated the overall percentage of approved loan applications.

-- Q2. Approval Rate by City
SELECT
    City,
    COUNT(*) AS total_apps,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY City
ORDER BY approval_rate DESC;
-- Findings:
-- Compared loan approval performance across cities.
-- Certain cities demonstrated consistently higher approval rates.


-- Q3. Approval Rate by Education Level
SELECT
    Education,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY Education
ORDER BY approval_rate DESC;
-- Findings:
-- Compared loan approval rates across education categories.
-- Education level appeared to have some relationship with approval outcomes.



/*-------------------------------------------------------------------------------------------
PART 3 - Risk & Financial Analysis
-------------------------------------------------------------------------------------------*/
-- Purpose:
-- Analyze how financial characteristics influence loan approval outcomes.


-- Q1. Approval Rate by Credit Score Category
SELECT
    CASE
        WHEN CreditScore < 600 THEN 'Poor'
        WHEN CreditScore < 700 THEN 'Fair'
        WHEN CreditScore < 750 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_category,
    COUNT(*) AS applicants,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY credit_category
ORDER BY approval_rate DESC;
-- Findings:
-- Applicants with higher credit scores showed significantly higher approval rates.
-- Credit score appeared to be strongly associated with approval probability.


-- Q2. Loan-to-Income Ratio Analysis
WITH ratios AS (
    SELECT *,
           LoanAmount / Income AS loan_income_ratio
    FROM loan_data
)

SELECT
    CASE
        WHEN loan_income_ratio < 0.3 THEN 'Low'
        WHEN loan_income_ratio < 0.6 THEN 'Medium'
        ELSE 'High'
    END AS risk_level,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM ratios
GROUP BY risk_level;
-- Findings:
-- Applicants with higher loan-to-income ratios generally showed lower approval rates.
-- Debt burden appeared negatively associated with approval probability.


/*-------------------------------------------------------------------------------------------
PART 4 - Intermediate SQL Analysis
-------------------------------------------------------------------------------------------*/
-- Purpose:
-- Use intermediate SQL techniques such as CTEs and window functions to perform comparative analysis.

-- Q1. Compare City Approval Rates to Overall Average
WITH city_rates AS (
    SELECT
        City,
        ROUND(AVG(LoanApproved) * 100, 2) AS city_approval_rate
    FROM loan_data
    GROUP BY City
),

overall_avg AS (
    SELECT
        ROUND(AVG(LoanApproved) * 100, 2) AS overall_approval_rate
    FROM loan_data
)

SELECT
    c.City,
    c.city_approval_rate,
    o.overall_approval_rate
FROM city_rates c
CROSS JOIN overall_avg o
ORDER BY c.city_approval_rate DESC;
-- Findings:
-- Compared each city's approval rate against the overall average approval rate.
-- Helped identify cities performing above or below the overall benchmark.



-- Q2. Rank Cities by Approval Rate
SELECT
    City,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate,
    RANK() OVER (
        ORDER BY AVG(LoanApproved) DESC
    ) AS city_rank
FROM loan_data
GROUP BY City;
-- Findings:
-- Ranked cities based on approval performance using a window function.
-- Helped identify the highest-performing approval regions.




-- Q3. Compare Approved vs Rejected Applicants
SELECT
    LoanApproved,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CreditScore), 2) AS avg_credit_score,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM loan_data
GROUP BY LoanApproved;
-- Findings:
-- Compared financial characteristics between approved and rejected applicants.
-- Approved applicants generally showed stronger financial profiles.


/*-------------------------------------------------------------------------------------------
PART 5 - Key Insights
-------------------------------------------------------------------------------------------*/
-- Applicants with higher credit scores showed significantly higher approval rates.
-- Loan-to-income ratio appeared negatively associated with approval probability.
-- Certain cities demonstrated consistently stronger approval performance.
-- Higher income alone did not guarantee loan approval, suggesting multiple risk factors influence decisions.
-- Financial and demographic variables together appeared to influence approval outcomes.
