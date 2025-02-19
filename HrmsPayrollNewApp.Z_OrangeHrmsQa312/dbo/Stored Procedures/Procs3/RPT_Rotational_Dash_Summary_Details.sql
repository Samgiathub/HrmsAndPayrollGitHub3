-- =============================================
-- Author:		<Nilesh Patel>
-- Create date: <25/02/2015>
-- Description:	<Rotational Dashboard Summary Report>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Rotational_Dash_Summary_Details]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max)
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max)
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)
	,@Desig_ID		varchar(Max)
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Report_Type varchar(50) = ''
	,@Report_Type_Emp  Numeric = 0 -- 0 For Summary Report & 1 For Detiles Report
	,@Report_id Numeric(18,0) = 11
	,@Report_For Numeric = 0  --0 for left Employee & 1 for New Employee ''added jimit 01082015
	,@Bank_ID varchar(max)=''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
    CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,5,@Bank_ID    
 
 	
    IF @Report_Type_Emp = 0 
    Begin
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
			id Numeric(18,0),
			Company_Name varchar(200),
			Company_Address varchar(500)
		)
	

		Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address)
				Select EM.Cmp_ID,EM.branch_id,branch_name,'Left Employees' as emp_Desc,
				Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-1,GetDate()) and emp_left='Y'  THEN EM.Emp_ID END) as Last_month,
				Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-3,GetDate()) and emp_left='Y'  THEN EM.Emp_ID  END)  as Quaterly,
				Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-6,GetDate()) and emp_left='Y' THEN EM.Emp_ID  END)  as Half,
				Count(Case WHEN Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-12,GetDate()) and emp_left='Y'  THEN EM.Emp_ID  END)  as Yearly,
				1,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
				--where cmp_id = @Cmp_ID  and EM.Branch_ID = @branch_ID 
				group by EM.branch_id,branch_name,EM.Cmp_ID,CM.Cmp_Name,CM.Cmp_Address
				
		Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address)
				Select EM.Cmp_ID,EM.branch_id,branch_name,'New Joinings' as emp_Desc,
				Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-1,GetDate())  THEN EM.Emp_ID END) as Last_month,
				Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-3,GetDate())  THEN EM.Emp_ID END)  as Quaterly,
				Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-6,GetDate())  THEN EM.Emp_ID END)  as Half,
				Count(Case WHEN Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-12,GetDate())  THEN EM.Emp_ID END)  as Yearly,
				2,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID
				--where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
				group by EM.branch_id,branch_name,EM.Cmp_ID ,CM.Cmp_Name,CM.Cmp_Address
				
		Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address) 
				Select M.Cmp_ID,M.branch_id,branch_name,'Increment' as emp_Desc,
				Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-1,GetDate())  THEN qry1.Emp_ID END) as Last_month,
				Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-3,GetDate())  THEN qry1.Emp_ID END)  as Quaterly,
				Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-6,GetDate())  THEN qry1.Emp_ID END)  as Half,
				Count(Case WHEN qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-12,GetDate())  THEN qry1.Emp_ID END)  as Yearly,
				3,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master M   Left JOIN 
				(
					SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
					and EM.Emp_ID = I.Emp_ID
					where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
					GROUP BY I.Emp_ID
				)  as qry1 ON qry1.Emp_ID = M.Emp_ID inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
				--where M.cmp_id = @Cmp_ID and M.Branch_ID = @branch_ID
				group by M.branch_id,M.branch_name,M.Cmp_ID ,CM.Cmp_Name,CM.Cmp_Address
				
		 Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address)
				Select CM.Cmp_ID,EM.branch_id,branch_name,'Retired Employees' as emp_Desc,
				Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-1,GetDate())  THEN EM.Emp_ID END) as Last_month,
				Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-3,GetDate())  THEN EM.Emp_ID END)  as Quaterly,
				Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-6,GetDate())  THEN EM.Emp_ID END)  as Half,
				Count(Case WHEN Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-12,GetDate())  THEN EM.Emp_ID END)  as Yearly,
				4,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID	 
				--where cmp_id = @Cmp_ID  and Branch_ID = @branch_ID 
				where EM.Emp_Left_Date is null
				group by EM.branch_id,branch_name,CM.Cmp_ID,CM.Cmp_Name,CM.Cmp_Address
		 
		 
		 Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address) 
				Select CM.Cmp_ID,M.branch_id,branch_name,'Due for Increment' as emp_Desc,
				Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,1,GetDate())  THEN qry1.Emp_ID END) as Last_month,
				Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,3,GetDate())  THEN qry1.Emp_ID END)  as Quaterly,
				Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,6,GetDate())  THEN qry1.Emp_ID END)  as Half,
				Count(Case WHEN dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,12,GetDate())  THEN qry1.Emp_ID END)  as Yearly,
				5,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master M   Left JOIN 
				(
					SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
					and EM.Emp_ID = I.Emp_ID
					where  I.Increment_Type = 'Increment'  --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
					GROUP BY I.Emp_ID
				)  as qry1 ON qry1.Emp_ID = M.Emp_ID inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID		 
				--where M.cmp_id = @Cmp_ID and M.Branch_ID = @branch_ID 
				group by M.branch_id,M.branch_name,CM.Cmp_ID,CM.Cmp_Name,CM.Cmp_Address
				
		Insert into @Emp_Details(Cmp_ID,branch_id,branch_name,Description,Last_month,Quaterly,half_year,Yearly,id,Company_Name,Company_Address)
				Select CM.Cmp_ID,EM.branch_id,branch_name,'Due for Retirement' as emp_Desc,
				Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,1,GetDate())  THEN EM.Emp_ID END) as Last_month,
				Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,3,GetDate())  THEN EM.Emp_ID END)  as Quaterly,
				Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,6,GetDate())  THEN EM.Emp_ID END)  as Half,
				Count(Case WHEN Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,12,GetDate())  THEN EM.Emp_ID END)  as Yearly,
				6,CM.Cmp_Name,CM.Cmp_Address
				from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID	 
				where EM.Emp_Left_Date is null
				group by EM.branch_id,branch_name,CM.Cmp_ID,CM.Cmp_Name,CM.Cmp_Address
		
		if @Report_id = '11'
			Begin
				Select * From @Emp_Details where id IN(1,2) /*and(Last_month <> 0 or Quaterly <> 0 or half_year <> 0 or Yearly <> 0)*/ order BY id
			End 
		Else if @Report_id = '12'
			Begin
				Select * From @Emp_Details where id IN(3,5) order BY id
			End 
		Else if @Report_id = '13'
			Begin
				Select * From @Emp_Details where id IN(4,6) order BY id
			End
		End
	Else
		Begin
		  print 'a'
			Declare @Emp_Details_1 table
			(
				Sr_No Numeric(18,0),
				Cmp_ID numeric(18,0),
				branch_id numeric(18,0),
				branch_name varchar(50),
				Description varchar(50),
				Emp_Code Varchar(50),
				Emp_Name Varchar(500),
				Designation Varchar(200),
				DOB Varchar(50),
				Left_Date Varchar(50),
				id Numeric(18,0),
				Company_Name varchar(200),
				Company_Address varchar(500),
				id_Month Numeric(18,0),
				Left_Type Varchar(100),
				Gross_salary numeric(18,2),   --added jimit 01082015
				DOJ   Varchar(20),  --added by jimit 14062017
				Dept_name varchar(50)		--added by krushna 17-12-2018
			)
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-1,GetDate()) and emp_left='Y')
					BEGIN
					
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id,  EM.Cmp_ID,EM.branch_id,branch_name,'Left Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Emp_Left_Date,103),
						1,CM.Cmp_Name,CM.Cmp_Address,11,(case when isnull(LE.Is_Terminate,0)= 1 THEN 'Terminate' when isnull(LE.Is_Death,0) = 1 THEN 'Death' WHEN isnull(LE.Is_Retire,0)= 1 THEN 'Retire' else 'Resignation' END) as Left_Type,
						Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID 
						Left JOIN T0100_LEFT_EMP LE WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID	
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID					
						where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-1,GetDate()) and emp_left='Y'
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Left Employees' as emp_Desc,'','','','','',1,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-3,GetDate()) and emp_left='Y')
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id , EM.Cmp_ID,EM.branch_id,branch_name,'Left Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Emp_Left_Date,103),
						1,CM.Cmp_Name,CM.Cmp_Address,12,(case when isnull(LE.Is_Terminate,0)= 1 THEN 'Terminate' when isnull(LE.Is_Death,0) = 1 THEN 'Death' WHEN isnull(LE.Is_Retire,0)= 1 THEN 'Retire' else 'Resignation' END) as Left_Type
						,Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name						
						from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID 
						Left JOIN T0100_LEFT_EMP LE WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID 
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-3,GetDate()) and emp_left='Y' 
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Left Employees' as emp_Desc,'','','','','',1,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-6,GetDate()) and emp_left='Y')
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id , EM.Cmp_ID,EM.branch_id,branch_name,'Left Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Emp_Left_Date,103),
						1,CM.Cmp_Name,CM.Cmp_Address,13,(case when isnull(LE.Is_Terminate,0)= 1 THEN 'Terminate' when isnull(LE.Is_Death,0) = 1 THEN 'Death' WHEN isnull(LE.Is_Retire,0)= 1 THEN 'Retire' else 'Resignation' END) as Left_Type
						,Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID  
						Left JOIN T0100_LEFT_EMP LE WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID 
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-6,GetDate()) and emp_left='Y'
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Left Employees' as emp_Desc,'','','','','',1,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-12,GetDate()) and emp_left='Y')
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id , EM.Cmp_ID,EM.branch_id,branch_name,'Left Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Emp_Left_Date,103),
						1,CM.Cmp_Name,CM.Cmp_Address,14,(case when isnull(LE.Is_Terminate,0)= 1 THEN 'Terminate' when isnull(LE.Is_Death,0) = 1 THEN 'Death' WHEN isnull(LE.Is_Retire,0)= 1 THEN 'Retire' else 'Resignation' END) as Left_Type
						,Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID 
						Left JOIN T0100_LEFT_EMP LE WITH (NOLOCK) on LE.Emp_ID = EM.Emp_ID 
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Emp_Left_Date <= GetDate() And Emp_Left_Date >= dateadd(mm,-12,GetDate()) and emp_left='Y' 
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
									 id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Left Employees' as emp_Desc,'','','','','',1,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-1,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,id_Month,
									Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id , EM.Cmp_ID,EM.branch_id,branch_name,'New Joinings' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_Of_Join,103),
						2,CM.Cmp_Name,CM.Cmp_Address,11,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-1,GetDate())
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,
													Company_Address,id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','New Joinings' as emp_Desc,'','','','','',2,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-3,GetDate()))
					BEGIN
					
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,
													Company_Address,id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'New Joinings' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_Of_Join,103),
						2,CM.Cmp_Name,CM.Cmp_Address,12,''
						,Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID  
						Left Outer JOIN( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-3,GetDate())
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address
									             ,id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','New Joinings' as emp_Desc,'','','','','',2,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-6,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'New Joinings' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_Of_Join,103),
						2,CM.Cmp_Name,CM.Cmp_Address,13,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID 
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-6,GetDate())
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','New Joinings' as emp_Desc,'','','','','',2,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-12,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'New Joinings' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_Of_Join,103),
						2,CM.Cmp_Name,CM.Cmp_Address,14,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = Em.Dept_ID 
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Join <= GetDate() And Date_of_Join >= dateadd(mm,-12,GetDate())
					END
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','New Joinings' as emp_Desc,'','','','','',2,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-1,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id , M.Cmp_ID,M.branch_id,branch_name,'Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						3,CM.Cmp_Name,CM.Cmp_Address,11,''		
						,M.Basic_Salary as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID  
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-1,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Increment' as emp_Desc,'','','','','',3,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-3,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						3,CM.Cmp_Name,CM.Cmp_Address,12,''			
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID   
						INNER JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-3,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Increment' as emp_Desc,'','','','','',3,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-6,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						3,CM.Cmp_Name,CM.Cmp_Address,13,''			
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name 
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID   
						INNER JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-6,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Increment' as emp_Desc,'','','','','',3,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-12,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,DEpt_Name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						3,CM.Cmp_Name,CM.Cmp_Address,14,''		
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID  
						Left Outer JOIN( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  qry1.Increment_Effective_Date <= GetDate() And qry1.Increment_Effective_Date >= dateadd(mm,-12,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
														id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Increment' as emp_Desc,'','','','','',3,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-1,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'Retired Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						4,CM.Cmp_Name,CM.Cmp_Address,11,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-1,GetDate()) and EM.Emp_Left_Date is null
					
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Retired Employees' as emp_Desc,'','','','','',4,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
						
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-3,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'Retired Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						4,CM.Cmp_Name,CM.Cmp_Address,12,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID   
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-3,GetDate()) and EM.Emp_Left_Date is null
				
					END 
					
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Retired Employees' as emp_Desc,'','','','','',4,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-6,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'Retired Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						4,CM.Cmp_Name,CM.Cmp_Address,13,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID   
						Left Outer JOIN( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-6,GetDate()) and EM.Emp_Left_Date is null
					
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
											id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Retired Employees' as emp_Desc,'','','','','',4,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-12,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
											id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'Retired Employees' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						4,CM.Cmp_Name,CM.Cmp_Address,14,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement <= GetDate() And Date_of_Retirement >= dateadd(mm,-12,GetDate()) and EM.Emp_Left_Date is null
						
						

					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
											id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Retired Employees' as emp_Desc,'','','','','',4,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
										End
					
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I  WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,1,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
												id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Due for Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						5,CM.Cmp_Name,CM.Cmp_Address,11,''			
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK)  on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID   
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,1,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Increment' as emp_Desc,'','','','','',5,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End		
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,3,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Due for Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						5,CM.Cmp_Name,CM.Cmp_Address,12,''			
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,3,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Increment' as emp_Desc,'','','','','',5,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End	
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,6,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Due for Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						5,CM.Cmp_Name,CM.Cmp_Address,13,''			
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,6,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Increment' as emp_Desc,'','','','','',5,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(
						Select M.Emp_ID	from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I  WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,12,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
												id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY M.Emp_id) as id ,M.Cmp_ID,M.branch_id,branch_name,'Due for Increment' as emp_Desc,M.Alpha_Emp_Code,M.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),M.Date_Of_Birth,103),CONVERT(varchar(50),qry1.Increment_Effective_Date,103),
						5,CM.Cmp_Name,CM.Cmp_Address,14,''		
						,M.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),M.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master M   Left JOIN 
						(
							SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
							and EM.Emp_ID = I.Emp_ID
							where  I.Increment_Type = 'Increment' --and I.Branch_ID = @branch_ID --Comment due to transfer case not consider in increment count
							GROUP BY I.Emp_ID
						)  as qry1 ON qry1.Emp_ID = M.Emp_ID 
						inner JOIN #Emp_Cons EC on M.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = M.Cmp_ID	 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = M.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = M.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = M.INCREMENT_ID
						Where  dateadd(yyyy,1,qry1.Increment_Effective_Date) >= GetDate() And dateadd(yyyy,1,qry1.Increment_Effective_Date) <= dateadd(mm,12,GetDate())
					End 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Increment' as emp_Desc,'','','','','',5,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
					
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,1,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id ,EM.Cmp_ID,EM.branch_id,branch_name,'Due for Retirement' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						6,CM.Cmp_Name,CM.Cmp_Address,11,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID   
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,1,GetDate()) and EM.Emp_Left_Date is null
						
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Retirement' as emp_Desc,'','','','','',6,Cmp_Name,Cmp_Address,11,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
						
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,3,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id,EM.Cmp_ID,EM.branch_id,branch_name,'Due for Retirement' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						6,CM.Cmp_Name,CM.Cmp_Address,12,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID  
						Left Outer JOIN( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,3,GetDate()) and EM.Emp_Left_Date is null
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
										id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Retirement' as emp_Desc,'','','','','',6,Cmp_Name,Cmp_Address,12,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,6,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
												id_Month,Left_Type,Gross_salary,DOJ,Dept_Name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id, EM.Cmp_ID,EM.branch_id,branch_name,'Due for Retirement' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						6,CM.Cmp_Name,CM.Cmp_Address,13,''
						,EM.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_Name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,6,GetDate()) and EM.Emp_Left_Date is null
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Retirement' as emp_Desc,'','','','','',6,Cmp_Name,Cmp_Address,13,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End	
					
				
				if exists(Select EM.Emp_ID from v0080_employee_master EM inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,12,GetDate()))
					BEGIN
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ,dept_name)
						Select ROW_NUMBER() OVER(order BY EM.Emp_id) as id, EM.Cmp_ID,EM.branch_id,branch_name,'Due for Retirement' as emp_Desc,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,CONVERT(varchar(50),EM.Date_Of_Birth,103),CONVERT(varchar(50),EM.Date_of_Retirement,103),
						6,CM.Cmp_Name,CM.Cmp_Address,14,''
						,Em.Basic_Salary + qry.E_AD_AMOUNT as Gross_salary,
						CONVERT(varchar(50),EM.Date_Of_Join,103)
						,DEM.Dept_name
						from v0080_employee_master EM 
						inner JOIN #Emp_Cons EC on EM.Emp_ID = EC.Emp_ID 
						inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID 
						Left JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = EM.Desig_Id 
						left join T0040_DEPARTMENT_MASTER DEM WITH (NOLOCK) ON DEM.Dept_Id = EM.Dept_ID  
						Left Outer JOIN ( SELECT EED.INCREMENT_ID, SUM(EED.E_AD_AMOUNT) AS E_AD_AMOUNT 
									 FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
										T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID AND AM.Add_in_sal_amt = 1 
									 WHERE AM.CMP_ID = @Cmp_Id
									 GROUP by eed.INCREMENT_ID
									) qry ON qry.Increment_ID = EM.INCREMENT_ID
						where Date_of_Retirement >= GetDate() And Date_of_Retirement <= dateadd(mm,12,GetDate()) and EM.Emp_Left_Date is null
					END 
				Else
					Begin
						Insert into @Emp_Details_1(Sr_No,Cmp_ID,branch_id,branch_name,Description,Emp_Code,Emp_Name,Designation,DOB,Left_Date,id,Company_Name,Company_Address,
													id_Month,Left_Type,Gross_salary,DOJ)
						Select 0,0,0,'','Due for Retirement' as emp_Desc,'','','','','',6,Cmp_Name,Cmp_Address,14,'',0,'' from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End	
				if @Report_id = '11' 
					Begin
						Select * From @Emp_Details_1 where id In(1,2) order by Sr_No,id 
						RETURN
					End 
				Else if @Report_id = '12'
					Begin
						Select * From @Emp_Details_1 where id In(3,5) order by Sr_No,id 
					End
				Else if @Report_id = '13'
					Begin
						Select * From @Emp_Details_1 where id In(4,6) order by Sr_No,id 
					End
					
				if @Report_For = 0           --added jimit 01082015
					begin
						select * from @Emp_Details_1 where id IN(1,2)   order by Sr_No,id
					end	
				else if @Report_For = 1 
					begin
						select * from @Emp_Details_1 where id IN(1,2) and Description = 'Left Employees' order by Sr_No,id
					end
				else if @Report_For = 2
					begin
						select * from @Emp_Details_1 where id IN(1,2) and Description = 'New joinings' order by Sr_No,id
					end
			
		End
		
	
     

