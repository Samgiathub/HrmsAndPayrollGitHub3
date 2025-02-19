


CREATE PROCEDURE [dbo].[P_Salary_Dashboard]    
	   
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
			
			Emp_Id         INT,
			Cmp_ID		   INT,
			Salary_Month   INT,
			Salary_Month_Name Char(3),
			Salary_Year    INT,
			Gross_salary   NUMERIC(18,2),
			Net_Amount      NUMERIC(18,2),
			Dedu_Amount    NUMERIC(18,2)
			
		 )

	INSERT INTO #SalaryData (Emp_Id,Cmp_ID,Salary_Month,Salary_Month_Name,Salary_Year,Gross_salary,Net_Amount,Dedu_Amount)
    SELECT Emp_Id=@Emp_Id,Cmp_ID=@Cmp_ID,Salary_Month=Number,Salary_Month_Name=SUBSTRING(DATENAME(month, DATEADD(month, Number-1, CAST(cast(@Year as VARCHAR) +'-01-01' AS datetime))),1,3),
			Salary_Year=@Year,Gross_salary=0,Net_Amount=0,Dedu_Amount=0
    FROM Master.dbo.spt_Values
    WHERE Name IS NULL
       AND Number BETWEEN 1 AND 12

		--SELECT * FROM #SalaryData
	--select	SAlC.* 
	--from	#SalaryData SAl
	--		inner JOIN T0200_MONTHLY_SALARY SAlC on Sal.Salary_Month =month(SAlC.month_end_date) and Sal.Salary_Year =year(SAlC.month_end_date) and sal.Emp_Id =SAlC.Emp_ID
	--		inner join T0250_SALARY_PUBLISH_ESS SPE on SALC.Emp_ID = SPE.Emp_ID and SPE.Month = month(SAlC.month_end_date) and SPE.Year = year(SAlC.month_end_date)
	--WHERE	year(month_end_date) = 2019  and SAl.Emp_Id=14838 and SPE.Is_Publish = 1
		

	Update	 SAl
	Set Gross_Salary=SAlC.Gross_Salary,
		Net_Amount=SAlC.net_amount,
		Dedu_Amount=SAlC.Dedu_Amount
	FROM #SalaryData SAl
	inner JOIN T0200_MONTHLY_SALARY SAlC on Sal.Salary_Month =month(SAlC.month_end_date) and Sal.Salary_Year =year(SAlC.month_end_date) and sal.Emp_Id =SAlC.Emp_ID
	inner join T0250_SALARY_PUBLISH_ESS SPE on SALC.Emp_ID = SPE.Emp_ID and SPE.Month = month(SAlC.month_end_date) and SPE.Year = year(SAlC.month_end_date)
	WHERE  year(month_end_date) = @Year  and SAl.Emp_Id=@Emp_Id and SPE.Is_Publish = 1

  
 -- select * from T0200_MONTHLY_SALARY WHERE  year(month_end_date) = @Year  and Emp_Id=@Emp_Id



  	Select Emp_ID,COL,[Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec] 
	from (
			select Emp_ID,Salary_Month_Name,COL,VAL,SORT 
				from #SalaryData
			CROSS APPLY (VALUES 
							('Gross Salary',Gross_Salary,1),
							('Net Amount',Net_Amount,3),
							('Deduction Amount',Dedu_Amount,2)
						)CS (COL,VAL,SORT))T
    PIVOT (SUM(VAL) FOR Salary_Month_Name IN ([Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec]))PVT
	ORDER BY SORT

RETURN 
 
    
    

