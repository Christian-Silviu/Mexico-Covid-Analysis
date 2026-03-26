-- ======================================
-- COVID-19 Mexico Patient Data Analysis
-- ======================================

-- ==============
-- TABLE CREATION
-- ==============

-- CREATE TABLE covid_patients (
-- 	USMER SMALLINT,
-- 	MEDICAL_UNIT SMALLINT, 
-- 	SEX	SMALLINT, 
-- 	PATIENT_TYPE SMALLINT,
-- 	DATE_DIED VARCHAR(10),
-- 	INTUBED	SMALLINT,
-- 	PNEUMONIA SMALLINT,
-- 	AGE	SMALLINT, 
-- 	PREGNANT SMALLINT,
-- 	DIABETES SMALLINT, 
-- 	COPD SMALLINT,
-- 	ASTHMA SMALLINT, 
-- 	INMSUPR SMALLINT, 
-- 	HIPERTENSION SMALLINT,
-- 	OTHER_DISEASE SMALLINT, 
-- 	CARDIOVASCULAR SMALLINT,
-- 	OBESITY SMALLINT,
-- 	RENAL_CHRONIC SMALLINT,
-- 	TOBACCO SMALLINT,
-- 	CLASIFFICATION_FINAL SMALLINT,
-- 	ICU SMALLINT
-- );

-- ==============
-- DATA CLEANING
-- ==============

-- Convert comorbidity columns from 1/2/NULL to BOOLEAN
-- ALTER TABLE covid_patients
-- ALTER COLUMN pneumonia TYPE BOOLEAN USING
-- 	CASE WHEN pneumonia = 1 THEN TRUE
-- 		WHEN pneumonia = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN diabetes TYPE BOOLEAN USING
-- 	CASE WHEN diabetes = 1 THEN TRUE
-- 		WHEN diabetes = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN copd TYPE BOOLEAN USING
-- 	CASE WHEN copd = 1 THEN TRUE
-- 		WHEN copd = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN asthma TYPE BOOLEAN USING
-- 	CASE WHEN asthma = 1 THEN TRUE
-- 		WHEN asthma = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN inmsupr TYPE BOOLEAN USING
-- 	CASE WHEN inmsupr = 1 THEN TRUE
-- 		WHEN inmsupr = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN hipertension TYPE BOOLEAN USING
-- 	CASE WHEN hipertension = 1 THEN TRUE
-- 		WHEN hipertension = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN other_disease TYPE BOOLEAN USING
-- 	CASE WHEN other_disease = 1 THEN TRUE
-- 		WHEN other_disease = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN cardiovascular TYPE BOOLEAN USING
-- 	CASE WHEN cardiovascular = 1 THEN TRUE
-- 		WHEN cardiovascular = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN obesity TYPE BOOLEAN USING
-- 	CASE WHEN obesity = 1 THEN TRUE
-- 		WHEN obesity = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN renal_chronic TYPE BOOLEAN USING
-- 	CASE WHEN renal_chronic = 1 THEN TRUE
-- 		WHEN renal_chronic = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN tobacco TYPE BOOLEAN USING
-- 	CASE WHEN tobacco = 1 THEN TRUE
-- 		WHEN tobacco = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN intubed TYPE BOOLEAN USING
-- 	CASE WHEN intubed = 1 THEN TRUE
-- 		WHEN intubed = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN icu TYPE BOOLEAN USING
-- 	CASE WHEN icu = 1 THEN TRUE
-- 		WHEN icu = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN pregnant TYPE BOOLEAN USING
-- 	CASE WHEN pregnant = 1 THEN TRUE
-- 		WHEN pregnant = 2 THEN FALSE
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN date_died TYPE DATE USING
-- 	CASE WHEN date_died = '9999-99-99' THEN NULL
-- 	ELSE TO_DATE(date_died, 'DD/MM/YYYY')
-- END;

-- Fix column name typos
-- ALTER TABLE covid_patients
-- RENAME COLUMN hipertension TO hypertension;

-- ALTER TABLE covid_patients
-- RENAME COLUMN clasiffication_final TO classification_final;

-- Convert sex and patient_type to readable text
-- ALTER TABLE covid_patients
-- ALTER COLUMN sex TYPE VARCHAR(10) USING
-- 	CASE WHEN sex = 1 THEN 'Female'
-- 		WHEN sex = 2 THEN 'Male'
-- 		ELSE NULL
-- 	END;

-- ALTER TABLE covid_patients
-- ALTER COLUMN patient_type TYPE VARCHAR(20) USING
-- 	CASE WHEN patient_type = 1 THEN 'Returned Home'
-- 		WHEN patient_type = 2 THEN 'Hospitalized'
-- 		ELSE NULL
-- 	END;

-- ==============
-- DATA ANALYSIS
-- ==============

-- High Level Overview
SELECT COUNT(*) AS total_patients,
	COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END) AS total_dead,
	COUNT(CASE WHEN patient_type = 'Hospitalized' THEN 1 END) AS total_hospitalized,
	COUNT(CASE WHEN classification_final <= 3 THEN 1 END) AS confirmed_cases,
	ROUND(COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS mortality_rate
FROM covid_patients;

-- Age Group Distribution Analysis
SELECT
	CASE WHEN age <= 17 THEN 'Minors (0-17)'
		WHEN age BETWEEN 18 AND 34 THEN 'Young Adults (18-34)'
		WHEN age BETWEEN 35 and 49 THEN 'Middle Aged (35-49)'
		WHEN AGE BETWEEN 50 AND 64 THEN 'Older Adults (50-64)'
		WHEN AGE BETWEEN 65 AND 79 THEN 'Seniors (65-79)'
		WHEN AGE >= 80 THEN 'Elderly (80+)'
	END AS age_group,
	COUNT(*) AS patient_count,
	COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END) as total_deaths,
	ROUND(COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS mortality_rate
FROM covid_patients
GROUP BY age_group
ORDER BY MIN(age);

-- Gender Based Mortality Rate Analysis
SELECT
	sex AS Gender,
	COUNT(*) AS patient_count,
	COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END) AS total_deaths,
	ROUND(COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100 , 2) AS Mortality_Rate
	FROM covid_patients
	GROUP BY sex;

-- Mortality Rate by Comorbidity
SELECT
	comorbidity,
	COUNT(*) as patient_count,
	COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END) as total_deaths,
	ROUND(COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) as mortality_rate
FROM covid_patients
CROSS JOIN UNNEST(ARRAY['diabetes','obesity','hypertension','cardiovascular', 'pneumonia','copd','asthma','tobacco','renal_chronic','inmsupr']) AS comorbidity
WHERE CASE comorbidity
	WHEN 'diabetes' THEN diabetes
	WHEN 'obesity' THEN obesity
	WHEN 'hypertension' THEN hypertension
	WHEN 'cardiovascular' THEN cardiovascular
	WHEN 'pneumonia' THEN pneumonia
	WHEN 'copd' THEN copd
	WHEN 'asthma' THEN asthma
	WHEN 'tobacco' THEN tobacco
	WHEN 'renal_chronic' THEN renal_chronic
	WHEN 'inmsupr' THEN inmsupr
END = TRUE
GROUP BY comorbidity
ORDER BY mortality_rate DESC;

-- Intubation and ICU rate (Confirmed Cases)
SELECT
	COUNT(*) as patient_count,
	COUNT(CASE WHEN icu IS true THEN 1 END) as total_icu,
	ROUND(COUNT(CASE WHEN icu IS true THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) as icu_rate,
	COUNT(CASE WHEN intubed IS true THEN 1 END) as total_intubed,
	ROUND(COUNT(CASE WHEN intubed IS true THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) as intubed_rate
FROM covid_patients
WHERE classification_final <= 3;

-- Hospitalization Rate by Age Analysis
SELECT
	CASE WHEN age <= 17 THEN 'Minors (0-17)'
		WHEN age BETWEEN 18 AND 34 THEN 'Young Adults (18-34)'
		WHEN age BETWEEN 35 and 49 THEN 'Middle Aged (35-49)'
		WHEN age BETWEEN 50 AND 64 THEN 'Older Adults (50-64)'
		WHEN age BETWEEN 65 AND 79 THEN 'Seniors (65-79)'
		WHEN age >= 80 THEN 'Elderly (80+)'
	END AS age_group,
	COUNT(*) as patient_count,
	COUNT(CASE WHEN patient_type = 'Hospitalized' THEN 1 END) as total_hospitalized,
	ROUND(COUNT(CASE WHEN patient_type = 'Hospitalized' THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) as hospitalization_rate
FROM covid_patients
GROUP BY age_group
ORDER BY MIN(age);

-- Mortality Rate per Total Number of Comorbidities
SELECT 
	(diabetes::INT + obesity::INT + hypertension::INT + cardiovascular::INT + pneumonia::INT + copd::INT + 
	asthma::INT + tobacco::INT + renal_chronic::INT + inmsupr::INT) AS num_comorbidities,
	COUNT(*) as patient_count,
	COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END) as total_deaths,
	ROUND(COUNT(CASE WHEN date_died IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) as mortality_rate
FROM covid_patients
GROUP BY num_comorbidities
ORDER BY num_comorbidities ASC;
