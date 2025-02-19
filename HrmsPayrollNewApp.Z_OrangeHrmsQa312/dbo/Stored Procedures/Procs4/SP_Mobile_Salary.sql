

CREATE PROCEDURE [dbo].[SP_Mobile_Salary]    
    
@Emp_ID numeric,        
@Month numeric = NULL,    
@Year numeric = NULL      
as        
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON   
   
CREATE TABLE #SalaryDetail        
(        
 HeadName varchar(50),  
 Amount varchar(50)  
)         
DECLARE @PresentDay as decimal(18,0)
DECLARE @PayDay as decimal(18,0)  
DECLARE @AbsentDay as  decimal(18,0)  
DECLARE @Basic as  decimal(18,2)  
DECLARE @NetSalary as  decimal(18,2)  
DECLARE @Company_ID as  numeric  
DECLARE @MonthName as varchar(20)  
DECLARE @StartDate datetime  
DECLARE @EndDate datetime  
DECLARE @Query varchar(Max)  
DECLARE @Publish_ID as  numeric  
  
IF NOT EXISTS(SELECT Publish_ID FROM T0250_SALARY_PUBLISH_ESS WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Month = @Month AND Year = @Year AND Is_Publish = 1)  
 BEGIN  
  SET @Publish_ID = 0  
  SELECT 'OK : No Salary Record For Selected Month.'
  RETURN  
 END  
         
SET @StartDate = CONVERT(datetime, CAST(@Month as varchar) + '/01/' + CAST(@Year as varchar))  
SET @EndDate = DATEADD(month, 1, CONVERT(datetime, CAST(@Month as varchar)+ '/01/' + CAST(@Year as varchar))) -1  
         
--SET @year = (select year(getdate()))        
SET @Company_ID = (select Cmp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @Emp_ID)     


    
SET @PresentDay = (select Present_Days from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)        
SET @AbsentDay = (select Absent_Days from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)        
SET @Basic = (select Salary_Amount from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)      
SET @NetSalary = (select Net_Amount from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)          
SET @MonthName = (Select DateName( month , DateAdd( month , @month , -1 )))      
SET @PayDay = (select Sal_Cal_Days from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_Id = @Emp_ID and month(Month_End_Date) = @Month and Year(Month_End_Date)= @Year)
       
INSERT INTO #SalaryDetail (HeadName,Amount)values('Salary of Month', @MonthName)         
INSERT INTO #SalaryDetail (HeadName,Amount)values('Year',@year )        
INSERT INTO #SalaryDetail (HeadName,Amount)values('Present Days',@PresentDay)        
INSERT INTO #SalaryDetail (HeadName,Amount)values('Absent Days',@AbsentDay)        
INSERT INTO #SalaryDetail (HeadName,Amount)values('Payable Days',@PayDay)
INSERT INTO #SalaryDetail (HeadName,Amount)values('Basic Salary',@Basic)        
           
CREATE TABLE #SalTemp   
(  
 Emp_Name varchar(50),  
 Grd_Name varchar(50),  
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
  
--INSERT INTO #SalTemp EXEC SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET @Company_ID,@StartDate,@EndDate,0,0,0,0,0,0,@Emp_ID,'',0,0,0,0,0,0,'','MOBILE'  
INSERT INTO #SalTemp EXEC SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET @Cmp_ID=@Company_ID,@From_Date=@StartDate,@To_Date=@EndDate,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@constraint='',@Sal_Type=0,@Salary_Cycle_id=0,@Segment_Id=0,@Vertical_Id=0,@SubVertical_Id=0,@SubBranch_Id=0,@Status='',@mobile_view='MOBILE'  
  
INSERT INTO #SalaryDetail (HeadName,Amount) SELECT ISNULL(AD_Name,AD_Description),AD_Amount FROM #SalTemp  WHERE (ISNULL(AD_Description,'0') = '0' OR  ISNULL(AD_Description,'0') <> 'Basic Salary')   
ORDER BY M_AD_Flag DESC ,AD_Level ASC  
  
INSERT INTO #SalaryDetail (HeadName,Amount)values('Net Salary',@NetSalary)        
  
SELECT HeadName as 'Particular' , Amount from #SalaryDetail   
    
DROP TABLE #SalaryDetail

