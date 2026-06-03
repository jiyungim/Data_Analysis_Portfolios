/* =====================================================
Loan Approval Analysis
===================================================== */


/*-------------------------------------------------------------------------------------------
PART 1 - Data Cleaning
Review overall data quality and identify potential issues before performing analysis.
-------------------------------------------------------------------------------------------*/

/* Review Raw Data Structure */
SELECT *
FROM loan_data
LIMIT 10;



/* Check for Duplicate Records */
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
-- No duplicates found by checking full rows.



/* Check for Null or Blank Values */
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
-- Null values were identified in the Income (196), CreditScore (194), and Education (198) columns.
-- The records were retained because the proportion was low (< 5%).



/*Invalid Value Checks */
SELECT *
FROM loan_data
WHERE Age < 18
   OR YearsExperience < 0
   OR YearsExperience > Age
   OR Income < 0
   OR LoanAmount < 0
   OR CreditScore NOT BETWEEN 300 AND 850;
-- Findings: 
-- A large number of potentially invalid records were identified, so additional counts were performed for each validation rule.



/* Count Invalid Values */
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
-- Invalid values were identified in the experience_gt_age (574), negative_income (3), and negative_loanamount (28).
-- These records were retained in the raw dataset and filtered selectively during analysis.








/*-------------------------------------------------------------------------------------------
PART 2 - Basic Approval Analysis (City, Education, Gender, EmploymentType)
Analyze overall loan approval trends across applicant groups.
-------------------------------------------------------------------------------------------*/

/* Overall Loan Approval Rate */
SELECT
ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data;
-- Findings: overall loan approval rate = 23.02.



/* Approval Rate by City */
SELECT
    City,
    COUNT(*) AS total_applications,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY City
ORDER BY approval_rate DESC;
-- Findings (Format: [City, total_applications, approval_rate]):
-- [San Francisco, 1257, 23.87], [Chicago, 1304, 23.31], [New York, 1207, 23.03], [Houston, 1232, 21.83]
-- Location alone may not strongly influence loan approval.



/* Approval Rate by Education Level */
SELECT
    Education,
    COUNT(*) as total_applications,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY Education
ORDER BY approval_rate DESC;
-- Findings (Format: [Education, total_applications, approval_rate]):
-- [PhD, 1199, 25.1], [“ ”(Null values), 198, 23.74], [Masters, 1198, 23.29], [High School, 1185, 22.03], [Bachelors, 1220, 21.56]
-- Education alone may not strongly influence loan approval.



/* Approval Rate by Gender */
SELECT
    Gender,
    COUNT(*) as total_applications,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY Gender
ORDER BY approval_rate DESC;
-- Findings (Format: [Gender, total_applications, approval_rate]):
-- [Male, 2541, 23.69], [Female, 2459, 22.33]
-- Gender alone may not strongly influence loan approval.



/* Approval Rate by EmploymentType */
SELECT
    EmploymentType,
    COUNT(*) as total_applications,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY EmploymentType
ORDER BY approval_rate DESC;
-- Findings (Format: [EmploymentType, total_applications, approval_rate]):
-- [Salaried, 1610, 33.29], [Self-Employed, 1730, 32.54], [Unemployed, 1660, 3.13]
-- Approval rates are similar for Salaried and Self-Employed (~33%), but drop sharply for Unemployed (~3%), showing employment status is a key factor.








/*-------------------------------------------------------------------------------------------
PART 3 - Financial Analysis (CreditScore, LTI(Loan-to-Income))
Analyze how financial characteristics influence loan approval outcomes.
-------------------------------------------------------------------------------------------*/

/* Compare Approved vs Rejected Applicants */
SELECT
    LoanApproved,
    COUNT(*) AS applicants,
    ROUND(AVG(Income), 2) AS avg_income,
    ROUND(AVG(CreditScore), 2) AS avg_credit_score,
    ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
FROM loan_data
GROUP BY LoanApproved;
-- Findings (Format: [loanapproved, applicants, avg_income, avg_credit_score, avg_loan_amount]):
-- [0, 3849, 48164.51, 533.72, 19790.24], [1, 1151, 55018.22, 708.76, 20140.05]
-- Approved applicants had substantially higher average credit scores and moderately higher average incomes compared to rejected applicants.
-- Average requested loan amounts were relatively similar between the two groups, suggesting that credit score and income level may have influenced approval decisions more strongly than requested loan size alone.



/* Approval Rate by Credit Score Category */
-- Credit score categories were defined using widely accepted FICO-based credit risk ranges commonly used across financial institutions and lending practices.
SELECT
    CASE
        WHEN CreditScore < 580 THEN 'Poor'
        WHEN CreditScore < 670 THEN 'Fair'
        WHEN CreditScore < 740 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_category,
    COUNT(*) AS applicants,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM loan_data
GROUP BY credit_category
ORDER BY approval_rate DESC;
-- Findings:
-- [Good, 617, 49.43], [Excellent, 1169, 41.06], [Fair, 806, 37,47], [Poor, 2408, 2.66]
-- A significant gap exists between the Poor category and the Fair, Good, and Excellent categories.
-- Approval rates increase significantly after the Poor category threshold, although the relationship is not perfectly monotonic across all higher credit tiers.
-- Notably, the Good credit score group exhibited higher approval rate than the Excellent group, indicating that credit score alone may not fully determine approval outcomes.


/* Approval Rate by Loan-to-Income Ratio */
-- Loan-to-income ratio thresholds were defined using commonly referenced lending risk guidelines and debt burden practices used across financial institutions.
WITH ratios AS (
    SELECT *,
           LoanAmount / Income AS loan_income_ratio
    FROM loan_data
    WHERE Income > 0
)

SELECT
    CASE
        WHEN loan_income_ratio < 0.35 THEN 'Low'
        WHEN loan_income_ratio < 0.5 THEN 'Medium'
        ELSE 'High'
    END AS risk_level,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM ratios
GROUP BY risk_level
ORDER BY approval_rate DESC;
-- Findings:
-- Applicants in the High loan-to-income ratio group showed a noticeably lower approval rate (17.09%) compared to the Low and Medium groups (~26%).
-- This suggests that higher relative debt burden is negatively associated with loan approval probability.



/* Approval Rate by Income */
-- Income thresholds were defined based on commonly referenced public income classifications and demographic income ranges used in economic and financial reporting.
SELECT
    income_group,
    COUNT(*) AS total_applicants,
    SUM(LoanApproved) AS approved,
    ROUND(SUM(LoanApproved) * 100.0 / COUNT(*), 2) AS approval_rate
FROM (
    SELECT *,
        CASE
            WHEN Income < 35000 THEN 'Low (<35K)'
            WHEN Income BETWEEN 35000 AND 65000 THEN 'Mid (35K-65K)'
            ELSE 'High (65K+)'
        END AS income_group
    FROM loan_data
    WHERE Income IS NOT NULL
) t
GROUP BY income_group
ORDER BY approval_rate DESC;
-- Findings (Format: [income_group, total_applicants, approved, approval_rate]):
-- [High (65K+), 773, 217, 28.07], [Mid (35K-65K), 3252, 861, 26,48], [Low (<35K), 779, 25, 3.21]
-- Income level demonstrated a more pronounced difference in approval rates than loan-to-income ratio, indicating a potentially stronger relationship with approval decisions.




/* Findings from PART 2, 3 */ 
-- Employment type, credit score, loan-to-income ratio, and income level were identified as factors showing meaningful relationships with loan approval outcomes.
-- Among these variables, income level appeared to demonstrate a stronger association with approval rates than loan-to-income ratio, suggesting that absolute earning power may have played a larger role in lending decisions within this dataset.
-- Interestingly, the Good credit score category showed a slightly higher approval rate than the Excellent category, suggesting that factors beyond credit score may also influence loan approval decisions.








/*-------------------------------------------------------------------------------------------
PART 4 - Multi-Factor Risk Analysis
Analyze how combinations of financial and employment-related factors influence loan approval outcomes and applicant risk profiles.
-------------------------------------------------------------------------------------------*/

/* Credit Score + Income Interaction Analysis */
SELECT
    credit_category,
    income_group,
    COUNT(*) AS applicants,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM (
    SELECT *,
        CASE
            WHEN CreditScore < 580 THEN 'Poor'
            WHEN CreditScore < 670 THEN 'Fair'
            WHEN CreditScore < 740 THEN 'Good'
            ELSE 'Excellent'
        END AS credit_category,

        CASE
            WHEN Income < 35000 THEN 'Low (<35K)'
            WHEN Income BETWEEN 35000 AND 65000 THEN 'Mid (35K-65K)'
            ELSE 'High (65K+)'
        END AS income_group
    FROM loan_data
    WHERE Income IS NOT NULL
      AND CreditScore IS NOT NULL
) t
GROUP BY credit_category, income_group
ORDER BY approval_rate DESC;
-- Findings:
-- Approval rates were highest among applicants with both strong credit scores and higher income levels, demonstrating that financial strength is more effectively reflected through the combination of multiple factors rather than a single variable alone.
-- However, even within the Excellent credit score group, applicants in the Low income category showed substantially lower approval rates, suggesting that income level may significantly influence lending decisions.
-- Interestingly, applicants in the Good credit category with high income showed slightly higher approval rates than those in the Excellent category, reinforcing the idea that approval decisions may involve additional underlying factors.



/* Risk Segmentation Model */
-- Risk segments were defined based on combinations of commonly referenced lending risk indicators, including credit quality, income level, and employment stability. 
SELECT
    risk_level,
    COUNT(*) AS applicants,
    ROUND(AVG(LoanApproved) * 100, 2) AS approval_rate
FROM (
    SELECT *,
        CASE
            WHEN CreditScore < 580
                 OR Income < 35000
                 OR EmploymentType = 'Unemployed'
            THEN 'High Risk'

            WHEN CreditScore >= 740
                 AND Income >= 65000
                 AND EmploymentType IN ('Salaried', 'Self-Employed')
            THEN 'Low Risk'

            ELSE 'Medium Risk'
        END AS risk_level
    FROM loan_data
) t
GROUP BY risk_level
ORDER BY approval_rate DESC;
-- Findings:
-- The Low Risk segment showed an exceptionally high approval rate (96.34%), while the High Risk segment had a dramatically lower approval rate (2.87%).
-- These results suggest that combining credit score, income, and employment status into a multi-factor segmentation model provides a clearer differentiation of applicant risk profiles.
-- Despite strong financial indicators observed in previous analyses, employment status appeared to remain a potentially decisive factor.
-- The following analysis was conducted to further isolate the impact of employment stability.



/* Approval Rate by Employment Type Among High-Income Applicants with Excellent Credit */
SELECT
    EmploymentType,
    COUNT(*) AS total_applicants,
    SUM(LoanApproved) AS approved,
    ROUND(SUM(LoanApproved) * 100.0 / COUNT(*), 2) AS approval_rate
FROM loan_data
WHERE Income >= 65000
  AND CreditScore >= 740
GROUP BY EmploymentType
ORDER BY approval_rate DESC;
-- Findings (Format: [employmenttype, total_applicants, approved, approval_rate])
-- [Salaried, 35, 34, 97.14], [Self-Employed, 47, 45, 95.74], [Unemployed, 49, 2, 4.08]
-- Despite having both high income and excellent credit scores, unemployed applicants showed a dramatically lower approval rate compared to salaried and self-employed applicants.
-- This suggests that employment stability may function as a critical approval factor that can outweigh otherwise strong financial qualifications.








/*-------------------------------------------------------------------------------------------
PART 5 - Key Insights, Business Recommendations & Limitations
-------------------------------------------------------------------------------------------*/
/* Key Insights */

-- 1. Employment status showed one of the strongest relationships with loan approval outcomes. Unemployed applicants consistently exhibited extremely low approval rates, even when combined with high income and excellent credit scores.
-- 2. Credit score and income level both demonstrated meaningful relationships with approval probability, but neither variable alone fully explained approval outcomes.
-- 3. Multi-factor analysis revealed that loan approval decisions appear to rely on combinations of financial strength and employment stability rather than isolated applicant characteristics.
-- 4. The risk segmentation model created a clear separation between high-risk and low-risk applicant groups, suggesting that combined risk indicators may be useful for preliminary applicant screening.

/* Business Recommendations */ 
-- 1. Employment stability should remain a critical component of loan approval assessment, as unemployed applicants demonstrated substantially lower approval rates even under otherwise strong financial conditions.
-- 2. Introduce early-stage applicant risk segmentation to improve approval efficiency and reduce manual review workload for high-risk applications.
-- 3. Collect additional applicant variables such as existing debt, repayment history, loan purpose, and collateral information to improve predictive accuracy and explain unexpected approval patterns.


/* Limitations */ 
-- 1. The dataset did not include several potentially important lending variables such as existing debt obligations, repayment history, interest rates, or collateral information.
-- 2. Missing values and potentially invalid records were identified in several variables. Although retained to preserve dataset size, these records may affect analytical accuracy.





