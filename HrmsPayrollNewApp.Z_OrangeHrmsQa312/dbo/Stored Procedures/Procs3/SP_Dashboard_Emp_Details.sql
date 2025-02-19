
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Dashboard_Emp_Details] 
	@Cmp_ID numeric(18,0),
	@branch_ID numeric(18,0)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

     Declare @Emp_Details table
		 (
			  Cmp_ID numeric(18,0),
			  branch_id numeric(18,0),
			  branch_name varchar(50),
			  Description varchar(50),
			  Last_month numeric(18,0),
			  Quaterly numeric(18,0),
			  half_year numeric(18,0),		  
			  Yearly numeric(18,0),
			  id Numeric(18,0)
		 )
			-- For Left Employees Details --Start
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id)
			Select Cmp_ID,branch_id,branch_name,'Left Employees' as emp_Desc,
			Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-1,GetDate()) and emp_left='Y'  THEN Emp_ID END) as Last_month,
			Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-3,GetDate()) and emp_left='Y'  THEN Emp_ID END)  as Quaterly,
			Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-6,GetDate()) and emp_left='Y' THEN Emp_ID END)  as Half,
			Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-12,GetDate()) and emp_left='Y'  THEN Emp_ID END)  as Yearly,
			1
			from v0080_employee_master 
			where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
			group by branch_id,branch_name,Cmp_ID 
			
			-- For Left Employees Details --End
			
			-- For New Joinigs Details --Start
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id)
			Select Cmp_ID,branch_id,branch_name,'New Joinings' as emp_Desc,
			Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-1,GetDate())  THEN Emp_ID END) as Last_month,
			Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-3,GetDate())  THEN Emp_ID END)  as Quaterly,
			Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-6,GetDate())  THEN Emp_ID END)  as Half,
			Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-12,GetDate())  THEN Emp_ID END)  as Yearly,
			2
			from v0080_employee_master 
			where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
			group by branch_id,branch_name,Cmp_ID 
			-- For New Joinigs Details --End
			
			
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id) 
			Select Cmp_ID,branch_id,branch_name,'Increment' as emp_Desc,
			Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-1,GetDate())  THEN qry1.Emp_ID END) as Last_month,
			Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-3,GetDate())  THEN qry1.Emp_ID END)  as Quaterly,
			Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-6,GetDate())  THEN qry1.Emp_ID END)  as Half,
			Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-12,GetDate())  THEN qry1.Emp_ID END)  as Yearly,
			3
			from v0080_employee_master M   Left JOIN 
			(
				SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I  WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
				and EM.Emp_ID = I.Emp_ID
				where  I.Increment_Type = 'Increment' and I.Branch_ID = @branch_ID 
				GROUP BY I.Emp_ID
			)  as qry1 ON qry1.Emp_ID = M.Emp_ID	 
			where M.cmp_id = @Cmp_ID and M.Branch_ID = @branch_ID
			group by M.branch_id,M.branch_name,M.Cmp_ID 
			
			
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id)
			Select Cmp_ID,branch_id,branch_name,'Retired Employees' as emp_Desc,
			Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-1,GetDate())  THEN Emp_ID END) as Last_month,
			Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-3,GetDate())  THEN Emp_ID END)  as Quaterly,
			Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-6,GetDate())  THEN Emp_ID END)  as Half,
			Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-12,GetDate())  THEN Emp_ID END)  as Yearly,
			4
			from v0080_employee_master 
			where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
			group by branch_id,branch_name,Cmp_ID 
			
			
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id) 
			Select Cmp_ID,branch_id,branch_name,'Due for Increment' as emp_Desc,
			Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,1,GetDate())  THEN qry1.Emp_ID END) as Last_month,
			Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,3,GetDate())  THEN qry1.Emp_ID END)  as Quaterly,
			Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,6,GetDate())  THEN qry1.Emp_ID END)  as Half,
			Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,12,GetDate())  THEN qry1.Emp_ID END)  as Yearly,
			5
			from v0080_employee_master M   Left JOIN 
			(
				SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
				and EM.Emp_ID = I.Emp_ID
				where  I.Increment_Type = 'Increment'  and I.Branch_ID = @branch_ID 
				GROUP BY I.Emp_ID
			)  as qry1 ON qry1.Emp_ID = M.Emp_ID	 
			where M.cmp_id = @Cmp_ID and M.Branch_ID = @branch_ID
			group by M.branch_id,M.branch_name,M.Cmp_ID
			
			Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id)
			Select Cmp_ID,branch_id,branch_name,'Due for Retirement' as emp_Desc,
			Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,1,GetDate())  THEN Emp_ID END) as Last_month,
			Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,3,GetDate())  THEN Emp_ID END)  as Quaterly,
			Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,6,GetDate())  THEN Emp_ID END)  as Half,
			Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,12,GetDate())  THEN Emp_ID END)  as Yearly,
			6
			from v0080_employee_master 
			where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
			group by branch_id,branch_name,Cmp_ID 
			
			Select * From @Emp_Details where Cmp_ID = @Cmp_ID and Branch_ID = @branch_ID and id IN(1,2,3,4)  order by id
			Select * From @Emp_Details where Cmp_ID = @Cmp_ID and Branch_ID = @branch_ID and id IN(5,6)  order by id
			
			--Select * from v0080_employee_master 
			--where cmp_id = 55 and emp_left='Y' and Branch_ID = 232 
			--and Emp_Left_Date <= '2015-01-21 00:00:000' and Emp_Left_Date >= '2014-01-21 00:00:000' 
			--order by Emp_Left_Date desc 
			
			--Select * from v0080_employee_master 
			--where cmp_id = 55 and Branch_ID = 234 
			--and Date_of_Join <= '2015-01-21 00:00:000' and Date_of_Join >= '2014-01-21 00:00:000' 
			--order by Date_of_Join desc
END
