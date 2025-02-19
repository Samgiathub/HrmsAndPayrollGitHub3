
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE[dbo].[SP_Mobile_HRMS_WebService_Salary_ALL]
	@Cmp_ID	numeric(18,0),
	@Month int,
	@Year int
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
   
DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
       
SET @StartDate = CONVERT(DATETIME, CAST(@Month AS VARCHAR) + '/01/' + CAST(@Year AS VARCHAR))  
SET @EndDate = DATEADD(MONTH, 1, CONVERT(DATETIME, CAST(@Month AS VARCHAR)+ '/01/' + CAST(@Year AS VARCHAR))) -1  
 
exec Rpt_Salary_Register_for_WebService @Company_Id=@Cmp_ID,@From_Date=@StartDate,@To_date=@EndDate,
@Branch_ID=0,@Grade_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Cat_ID=0,@is_column=2,
@Salary_Cycle_id=0,@Order_By='Code',@Show_Hidden_Allowance=1

--exec Rpt_Salary_Register_Export @Company_Id=@Cmp_ID,@From_Date=@StartDate,@To_date=@EndDate,@Branch_ID=0,@Grade_ID=0,
--@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Cat_ID=0,@Order_by='Code'

