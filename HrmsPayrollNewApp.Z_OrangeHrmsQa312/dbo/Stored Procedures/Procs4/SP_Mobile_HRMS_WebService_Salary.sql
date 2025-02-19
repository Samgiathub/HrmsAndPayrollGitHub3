
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Salary]
	@Emp_ID numeric(18,0),
	@Cmp_ID	numeric(18,0),
	@Month int,
	@Year int,
	@Type char(1) = 'V'
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    

DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME


IF @Type = 'V'   
	BEGIN
		CREATE TABLE #SalaryDetail        
		(        
			HeadName varchar(50),  
			Amount varchar(50),
			HeadType char(1) 
		)         
		DECLARE @PresentDay NUMERIC(18,2) 
		DECLARE @AbsentDay NUMERIC(18,2)
		DECLARE @HoliDay NUMERIC(18,2)
		DECLARE @Weekoff NUMERIC(18,2)
		DECLARE @WorkingDay NUMERIC(18,2)
		DECLARE @LeaveDay NUMERIC(18,2)
		DECLARE @Basic NUMERIC(18,2)
		DECLARE @GrossSalary NUMERIC(18,2)
		DECLARE @NetSalary NUMERIC(18,2)
		DECLARE @MonthName VARCHAR(20)
		
		DECLARE @Query VARCHAR(MAX)
		DECLARE @Publish_ID NUMERIC(18,0)

		DECLARE @TotalAddition NUMERIC(18,2)
		DECLARE @TotalDeduction NUMERIC(18,2)
		--DECLARE @PayeAmt numeric(18,2) 

		IF NOT EXISTS(SELECT Publish_ID FROM T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Month = @Month AND Year = @Year AND Is_Publish = 1)
			BEGIN  
				SET @Publish_ID = 0  
				SELECT 'OK # No Salary Record For Selected Month.'
				RETURN  
			END  
		         
		SET @StartDate = CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/01/' + CAST(@Year AS VARCHAR))  
		SET @EndDate = DATEADD(MONTH, 1, CONVERT(DATETIME, CAST(@Month AS VARCHAR)+ '/01/' + CAST(@Year AS VARCHAR))) -1  
		
		Declare @TotalSettAmt  numeric(18,0) = 0
		select @TotalSettAmt = sum(S_Basic_Salary) from T0201_MONTHLY_SALARY_SETT 
		where Emp_ID = @Emp_ID and month(S_Eff_Date) = @Month and Year(S_Eff_Date)= @Year 
		
		SELECT @PresentDay = Present_Days,@AbsentDay = Absent_Days,@HoliDay = Holiday_Days,
		@Weekoff = Weekoff_Days,@WorkingDay = Sal_Cal_Days,@LeaveDay = Total_Leave_Days
		, @Basic = (Salary_Amount + Arear_Basic + Basic_Salary_Arear_cutoff + isnull(@TotalSettAmt,0)), 
		@NetSalary = Net_Amount,@GrossSalary = Gross_Salary
		FROM T0200_MONTHLY_SALARY S   WITH (NOLOCK) 
		WHERE S.Emp_ID = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year
		    
		--SET @PresentDay = (select Present_Days from T0200_MONTHLY_SALARY where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)        
		--SET @AbsentDay = (select Absent_Days from T0200_MONTHLY_SALARY where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)        
		--SET @Basic = (select Salary_Amount from T0200_MONTHLY_SALARY where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)      
		--SET @NetSalary = (select Net_Amount from T0200_MONTHLY_SALARY where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)          

		SET @MonthName = (Select DateName( month , DateAdd( month , @month , -1 )))      

		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Present Days',@PresentDay,'H')        
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Absent Days',@AbsentDay,'H')        
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Holiday',@HoliDay,'H') 
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Week Off',@Weekoff,'H') 
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Paid Days',@WorkingDay,'H') 
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Leave Days',@LeaveDay,'H') 
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)values('Basic Salary',@Basic,'B')        
		       
		       
		--INSERT INTO #SalaryDetail (HeadName,Amount)values('Salary of Month', @MonthName)         
		--INSERT INTO #SalaryDetail (HeadName,Amount)values('Year',@year )        
		--INSERT INTO #SalaryDetail (HeadName,Amount)values('Present Days',@PresentDay)        
		--INSERT INTO #SalaryDetail (HeadName,Amount)values('Absent Days',@AbsentDay)        
		--INSERT INTO #SalaryDetail (HeadName,Amount)values('Basic Salary',@Basic)

	
		CREATE TABLE #SalTemp   
				(  
				 Emp_Name varchar(50),  
				 Grd_Name varchar(50),  
				 BandName varchar(50),
				 Comp_Name varchar(50),  
				 Branch_Address varchar(MAX),  
				 Emp_Code varchar(50),  
				 Type_Name varchar(50),  
				 Dept_Name varchar(50),  
				 Design_Name varchar(50),
				 Emp_First_Name varchar(50),  
				 AD_Name varchar(50),  
				 AD_Level varchar(50),  
				 Emp_ID numeric,  
				 Cmp_ID numeric,  
				 AD_ID numeric,  
				 SalTran_ID numeric,  
				 AD_Description varchar(max),  
				 AD_Amount numeric(18,2),  
				 AD_Actual_Amount numeric(18,2),  
				 AD_Calc_Amount numeric(18,2),  
				 For_Date datetime,  
				 M_AD_Flag varchar(10),  
				 Loan_ID numeric,  
				 Def_ID numeric,  
				 M_Arrear_Days numeric(18,2),  
				 YTD numeric(18,2),  
				 AD_Amt_OnBasic_For_Per numeric(18,2),  
				 Branch_ID numeric(18,2),  
				 Alpha_Emp_Code varchar(50)  
				 --Comment varchar(50)   
				)  
		
		        
		

		--SELECT @StartDate,@EndDate
		  
		--INSERT INTO #SalTemp EXEC SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET @Company_ID,@StartDate,@EndDate,0,0,0,0,0,0,@Emp_ID,'',0,0,0,0,0,0,'','MOBILE'  
		--INSERT INTO SalTemp 

		INSERT INTO #SalTemp
		EXEC SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET @Cmp_ID=@Cmp_ID,@From_Date=@StartDate,@To_Date=@EndDate,@Branch_ID=0
		,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@constraint=''
		,@Sal_Type=0,@Salary_Cycle_id=0,@Segment_Id=0,@Vertical_Id=0,@SubVertical_Id=0,@SubBranch_Id=0,@Status=''
		,@mobile_view='MOBILE'  

		
		
		SELECT @TotalAddition = SUM((AD_Amount + M_Arrear_Days)) FROM #SalTemp  WHERE (ISNULL(AD_Description,'0') = '0' OR  ISNULL(AD_Description,'0') <> 'Basic Salary') AND M_AD_Flag ='I'
		SELECT @TotalDeduction = SUM(AD_Amount) FROM #SalTemp  WHERE (ISNULL(AD_Description,'0') = '0' OR  ISNULL(AD_Description,'0') <> 'Basic Salary') AND M_AD_Flag ='D'

		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType) 
		SELECT ISNULL(AD_Name,AD_Description),(AD_Amount + M_Arrear_Days),M_AD_Flag 
		FROM #SalTemp WHERE (ISNULL(AD_Description,'0') = '0' OR  ISNULL(AD_Description,'0') <> 'Basic Salary') AND M_AD_Flag = 'I'   
		ORDER BY M_AD_Flag DESC ,AD_Level ASC

		--INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)VALUES('Total Earnings',@TotalAddition,'I') 

		
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)VALUES('Gross Salary',@GrossSalary,'B') 
		 
		INSERT INTO #SalaryDetail (HeadName,Amount) 
		SELECT ISNULL(AD_Name,AD_Description),AD_Amount
		FROM #SalTemp WHERE (ISNULL(AD_Description,'0') = '0' OR  ISNULL(AD_Description,'0') <> 'Basic Salary') AND M_AD_Flag = 'D'
		ORDER BY M_AD_Flag DESC ,AD_Level ASC  

		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)VALUES('Total Deduction',ISNULL(@TotalDeduction,0)	 ,'D') 
		  
		INSERT INTO #SalaryDetail (HeadName,Amount,HeadType)VALUES('Net Salary',@NetSalary,'B')        
		  
		SELECT HeadName AS 'Particular',ISNULL(Amount,0.00) AS Amount,ISNULL(HeadType,'') AS 'HeadType' FROM #SalaryDetail   -- Niraj(08102021)
		    
		DROP TABLE #SalaryDetail
	END
ELSE IF @Type = 'D'
	BEGIN
		IF NOT EXISTS(SELECT Publish_ID FROM T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Month = @Month AND Year = @Year AND Is_Publish = 1)
			BEGIN  
				SET @Publish_ID = 0  
				SELECT 'No Salary Record For Selected Month.#False#'
				RETURN  
			END  
		         
		SET @StartDate = CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/01/' + CAST(@Year AS VARCHAR))  
		SET @EndDate = DATEADD(MONTH, 1, CONVERT(DATETIME, CAST(@Month AS VARCHAR)+ '/01/' + CAST(@Year AS VARCHAR))) -1  	
		
		SELECT * FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID
		
	END

