

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Salary_Dashboard_New]    
	   
	@Emp_Id   INT,    
	@Cmp_ID   INT,  
	@Year     INT    
	
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	/*Generate 12 Months for year*/
	IF OBJECT_ID('TempDB..#SalaryData') IS NOT NULL
        DROP TABLE #SalaryData

		 CREATE TABLE #SalaryData 
		 (
			MonthNum INT PRIMARY KEY CLUSTERED,
			Emp_Id         INT,
			Cmp_ID		   INT,
			Alpha_Emp_code Varchar(25),
			Emp_full_name  Varchar(400),
			Salary_Month   INT,
			Salary_Month_Name Char(3),
			Salary_Year    INT,
			Gross_salary   NUMERIC(18,2),
			Net_Amount      NUMERIC(18,2),
			Dedu_Amount    NUMERIC(18,2),
			Sort_No		   tinyint
		 )

	INSERT INTO #SalaryData (MonthNum,Emp_Id,Cmp_ID,Alpha_Emp_code,Emp_full_name,Salary_Month,Salary_Month_Name,Salary_Year,Gross_salary,Net_Amount,Dedu_Amount,Sort_No)
    SELECT MonthNum = Number,Emp_Id=@Emp_Id,Cmp_ID=@Cmp_ID,Alpha_Emp_code='',Emp_full_name='',Salary_Month=Number,Salary_Month_Name=SUBSTRING(DATENAME(month, DATEADD(month, Number-1, CAST(cast(@Year as VARCHAR) +'-01-01' AS datetime))),1,3),
			Salary_Year=@Year,Gross_salary=0,Net_Amount=0,Dedu_Amount=0,Sort_No=0
    FROM Master.dbo.spt_Values
    WHERE Name IS NULL
       AND Number BETWEEN 1 AND 12

		--SELECT * FROM #SalaryData

	Update	 SAl
	Set Gross_Salary=SAlC.Gross_Salary,
		Net_Amount=SAlC.net_amount,
		Dedu_Amount=SAlC.Dedu_Amount
	FROM #SalaryData SAl
	inner JOIN T0200_MONTHLY_SALARY SAlC on Sal.EMP_ID =SAlC.EMP_ID and Sal.Cmp_ID =SAlC.Cmp_ID and Sal.MonthNum =month(SAlC.month_end_date) and Sal.Salary_Year =year(SAlC.month_end_date)
	WHERE  year(month_end_date) = @Year 

  

  	Select Emp_ID,COL,[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec] 
	from (
			select Emp_ID,Salary_Month_Name,COL,VAL,SORT 
				from #SalaryData
			CROSS APPLY (VALUES 
							('Gross_Salary',Gross_Salary,1),
							('Net_Amount',Net_Amount,3),
							('Dedu_Amount',Dedu_Amount,2)
						)CS (COL,VAL,SORT))T
    PIVOT (SUM(VAL) FOR Salary_Month_Name IN ([Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec]))PVT
	ORDER BY SORT 

RETURN 
 
    
    

