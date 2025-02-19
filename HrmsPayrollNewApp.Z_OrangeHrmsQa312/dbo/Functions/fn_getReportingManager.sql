
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[fn_getReportingManager] 
(	
	@Cmp_ID NUMERIC,
	@Emp_ID NUMERIC , 
	@Effect_Date DateTime
)
--CREATED ON 22/01/2019 BY RAMIZ FOR MAX REPORTING MANAGER -- DIRECT REPORTING MANAGER HAS HIGHER PRIORITY , SO USED SORTING
RETURNS @EmpManager TABLE 
(	
	Row_ID		NUMERIC NOT NULL,	--HERE ROW ID IS NOT DECLARED AS PRIMARY KEY BECOZ , IT WILL TAKE ORDER BY ACCORING TO ROW_ID , WHICH WE DONT WANT
	Emp_ID			NUMERIC NOT NULL,
	R_Emp_ID		NUMERIC NULL,
	Reporting_Method	VARCHAR(20)
) 
AS
	BEGIN
	
	IF @Emp_ID = 0
	 SET @Emp_ID = NULl
	
		IF (YEAR(ISNULL(@Effect_Date,'1900-01-01')) < 1901)
			SET @Effect_Date = GETDATE();
		
		INSERT INTO @EmpManager
		SELECT Row_ID , Emp_ID , R_Emp_ID , Reporting_Method
		FROM
			(
				SELECT Row_ID , ERD.Emp_ID , R_Emp_ID ,Reporting_Method ,  1 AS SortCol
				From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
					INNER JOIN 
						(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
						 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						 WHERE Effect_Date <= @Effect_Date And Emp_ID = ISNULL(@Emp_ID , Emp_ID)
						 GROUP BY EMP_ID
						) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
				WHERE ERD.Emp_ID = ISNULL(@Emp_ID , ERD.Emp_ID) and Reporting_Method = 'Direct'
				UNION
				SELECT Row_ID , ERD.Emp_ID , R_Emp_ID ,Reporting_Method ,  2 AS SortCol
				From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
					INNER JOIN 
						(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
						 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						 WHERE Effect_Date <= @Effect_Date And Emp_ID = ISNULL(@Emp_ID , Emp_ID)
						 GROUP BY EMP_ID
						) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
				WHERE ERD.Emp_ID = ISNULL(@Emp_ID , ERD.Emp_ID) and Reporting_Method = 'InDirect'
			)QRY
		ORDER BY SORTCOL
		
		RETURN;
	END

