



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0240_Perquisites_Employee]  
  @Cmp_ID   numeric  ,
  @fyYear varchar(30) ,
  @Emp_id numeric,
  @Tran_id numeric = 0
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    

	CREATE table #monthDetail 
	(
		Monthno numeric(18,0),
		Yearno nvarchar(10),
		MonthVal varchar(20),
		Rent numeric(18,2)
		
	)
		Declare @Per_id as numeric 
		Declare @Year1 as nvarchar(10) 
		Declare @Year2 as nvarchar(10) 
		
		set @Per_id = 1
		select @Year2 = right(@fyyear,4) , @Year1 = left(@fyyear,4)
		
		
		insert into #monthDetail values (4,@Year1,'April',0)
		insert into #monthDetail values (5,@Year1,'May',0)
		insert into #monthDetail values (6,@Year1,'June',0)
		insert into #monthDetail values (7,@Year1,'July',0)
		insert into #monthDetail values (8,@Year1,'Augest',0)
		insert into #monthDetail values (9,@Year1,'September',0)
		insert into #monthDetail values (10,@Year1,'October',0)
		insert into #monthDetail values (11,@Year1,'November',0)
		insert into #monthDetail values (12,@Year1,'December',0)
		insert into #monthDetail values (1,@Year2,'January',0)
		insert into #monthDetail values (2,@Year2,'February',0)
		insert into #monthDetail values (3,@Year2,'March',0)				
		
		if Not @Tran_id = 0
			Begin
				
				SELECT T0240_Perquisites_Employee.Tran_id, T0240_Perquisites_Employee.Cmp_id, T0240_Perquisites_Employee.Emp_id, T0240_Perquisites_Employee.Perquisites_id, 
                      T0240_Perquisites_Employee.Financial_Year, T0240_Perquisites_Employee.On_Rent, T0240_Perquisites_Employee.On_Rent_From, 
                      T0240_Perquisites_Employee.On_Rent_To, T0240_Perquisites_Employee.Cmp_Quarter, T0240_Perquisites_Employee.Cmp_Quarter_From, 
                      T0240_Perquisites_Employee.Cmp_Quarter_To, T0240_Perquisites_Employee.Salary, T0240_Perquisites_Employee.On_Rent_Per, 
                      T0240_Perquisites_Employee.Cmp_Quater_Per, T0240_Perquisites_Employee.Total_Rent_Amt, T0240_Perquisites_Employee.Total_Furnish_Amt, 
                      T0240_Perquisites_Employee.Population, T0240_Perquisites_Employee.On_Rent_days, T0240_Perquisites_Employee.Cmp_Quarter_days, 
                      T0240_Perquisites_Employee.Month, T0240_Perquisites_Employee.Per_Rent_Amt, T0240_Perquisites_Employee.Per_Quater_Amt, 
                      T0240_Perquisites_Employee.Change_Date,  T0080_EMP_MASTER.Alpha_Emp_Code + ' - ' + T0080_EMP_MASTER.Emp_Full_Name as Emp_Name
				FROM  T0240_Perquisites_Employee WITH (NOLOCK) INNER JOIN
                      T0080_EMP_MASTER WITH (NOLOCK) ON T0240_Perquisites_Employee.Emp_id = T0080_EMP_MASTER.Emp_ID where Tran_id = @Tran_id
				
				if exists(SELECT Perq_Tran_Id FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID)
					begin
						SELECT MONTH as Monthno, YEAR as Yearno,DATENAME(M,dbo.GET_MONTH_ST_DATE(month,YEAR)) as MonthVal, AMOUNT as Rent FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID
					end
				else
					begin
						select * from #monthDetail
					end
				
			End
		Else
			Begin		
	
				SELECT ALPHA_EMP_CODE + ' - ' + EMP_FULL_NAME as Emp_Name, EMP.Emp_ID FROM T0080_EMP_MASTER EMP WITH (NOLOCK)
				LEFT OUTER JOIN T0240_PERQUISITES_EMPLOYEE PME WITH (NOLOCK) ON EMP.EMP_ID = PME.EMP_ID
				WHERE EMP.CMP_ID = @Cmp_ID 
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)				
				
				select * from #monthDetail
			
			End
      

 RETURN   
  
  
  

