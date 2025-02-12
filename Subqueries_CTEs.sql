--Problem 1 Subqs
Select 
    skills,
    number_of_jobs
FROM skills_dim
INNER JOIN (
    SELECT
    skill_id,
    COUNT(job_id) AS number_of_jobs
FROM skills_job_dim
GROUP BY skill_id
ORDER BY number_of_jobs DESC
LIMIT 5
    ) as top_5 ON top_5.skill_id = skills_dim.skill_id
ORDER BY number_of_jobs DESC;

--Problem 2
SELECT 
    name,
      CASE
        WHEN postings_count < 10 THEN 'Small'
        WHEN postings_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE'Large'
    END AS company_size
FROM company_dim
INNER JOIN(
    SELECT
    company_id,
    COUNT(job_id) AS postings_count
FROM job_postings_fact
GROUP BY company_id) AS company_count ON company_count.company_id = company_dim.company_id

--Problem 3
SELECT
    name,
    avg_company_salary
FROM company_dim
INNER JOIN 
(SELECT
    AVG(salary_year_avg) AS avg_company_salary,
    company_id
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY
    company_id) AS company_salary ON company_salary.company_id = company_dim.company_id
WHERE avg_company_salary > 
    (
    SELECT
    AVG(salary_year_avg) AS overall_average
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
);

--Problem 1 CTEs
WITH unique_jobs AS (
    SELECT
        job_postings_fact.company_id,
        name,
        COUNT(DISTINCT job_title) AS title_count
    FROM job_postings_fact
    JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
    GROUP BY
        job_postings_fact.company_id,
        name
    ORDER BY title_count DESC
)

SELECT *
FROM unique_jobs
LIMIT 10;

--Problem 2
WITH country_avg AS (
    SELECT
        AVG(salary_year_avg) AS avg_country_salary,
        job_country
    FROM job_postings_fact
    GROUP BY job_country
)

SELECT
    job_id,
    job_title,
    name AS company_name,
    j.salary_year_avg,
    CASE
        WHEN j.salary_year_avg > avg_country_salary THEN 'Above Average'
        ELSE 'Below Average'
    END AS national_salary_avg,
    EXTRACT(MONTH from job_posted_date) AS posted_month
FROM job_postings_fact j
INNER JOIN company_dim c ON c.company_id = j.company_id
INNER JOIN country_avg ON country_avg.job_country = j.job_country
ORDER BY name;

--Problem 3
WITH skills_per_company AS (
    SELECT
        company_dim.company_id,
        COUNT(DISTINCT skill_id) AS unique_skills,
        name
    FROM skills_job_dim
    RIGHT JOIN job_postings_fact on skills_job_dim.job_id = job_postings_fact.job_id
    INNER JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
    GROUP BY 
        name,
        company_dim.company_id
    ORDER BY unique_skills DESC
),

company_salary AS (
    SELECT
        MAX(salary_year_avg) AS max_skill_salary,
        j.company_id
    FROM job_postings_fact j
    INNER JOIN company_dim ON j.company_id = company_dim.company_id
    GROUP BY j.company_id
)

SELECT 
    name,
    unique_skills,
    max_skill_salary
FROM skills_per_company
LEFT JOIN company_salary ON skills_per_company.company_id = company_salary.company_id
ORDER BY name
