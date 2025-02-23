-- EDA (Exploratory Data Analysis)

-- Finding total layoffs in the United States in 2023
SELECT sum(total_laid_off)
FROM layoffs_staging2
WHERE country = 'United States'
AND YEAR(`date`) = 2023
;

-- Ranking countries based on Year and total layoffs
SELECT YEAR(`date`), country, sum(total_laid_off),
RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY sum(total_laid_off) DESC) AS country_rank
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`), country
ORDER BY YEAR(`date`) DESC, country_rank
;

-- Identifying the worst year of layoffs
SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Identifying the worst stage of layoffs
SELECT stage, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;


-- Calculating the rolling sum of layoffs
SELECT substring(`date`, 1, 7) AS `MONTH`, 	SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY substring(`date`, 1, 7)
ORDER BY 1 ASC;

-- Using CTE to find rolling sum 
WITH Rolling_Total AS
(
SELECT substring(`date`, 1, 7) AS `MONTH`, 	SUM(total_laid_off) AS total_terminated
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY substring(`date`, 1, 7)
ORDER BY 1 ASC
)
SELECT `MONTH`, total_terminated,
SUM(total_terminated) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total
;


-- Ranking companies based on year of highest layoffs
-- Creating CTE and using dense rank
-- Creating another CTE to capture the top 5 ranks each year
WITH Company_Year (Company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;



