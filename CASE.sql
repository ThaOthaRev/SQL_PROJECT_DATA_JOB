--Problem 1
SELECT 
    job_id,
    job_title,
    salary_year_avg,
    CASE 
    WHEN salary_year_avg >= 100000 THEN 'High salary'
    WHEN salary_year_avg BETWEEN 60000 AND 99999 THEN 'Standard salary'
    WHEN salary_year_avg < 60000 THEN 'Low salary'
    END AS salary_range
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
AND job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;

--Problem 2
SELECT
    COUNT(DISTINCT company_id),
    CASE
        WHEN job_work_from_home = TRUE THEN 'WFH'
        WHEN job_work_from_home = FALSE THEN 'Onsite'
    END AS wfh_policy 
FROM job_postings_fact
GROUP BY wfh_policy;

--Problem 2 *correct answer* (both answers work)
SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) as wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) as non_wfh_companies
FROM job_postings_fact;

--Problem 3
SELECT 
    job_id,
    salary_year_avg, 
    CASE
        WHEN job_title ILIKE '%Senior%' THEN 'Senior'
        WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manger'
        WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
        ELSE 'Not Specified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home THEN 'Yes'
        ELSE 'No'
    END AS remote_option
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_id;