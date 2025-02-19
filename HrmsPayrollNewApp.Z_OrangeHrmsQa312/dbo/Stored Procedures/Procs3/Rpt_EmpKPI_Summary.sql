


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Rpt_EmpKPI_Summary 9,2014,0,0,0,0,0,0,0,'1358'
-- exec Rpt_EmpKPI_Summary 9,2014,0,0,0,0,0,0,0,''
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_EmpKPI_Summary]
	 @cmp_id			as numeric(18,0),
	 @finyear			as int,
	 @branch_Id			as varchar(max)='', --modify on 27 mar 2015
	 @Cat_ID			as numeric = 0,	
	 @Grd_Id			as numeric(18,0)=0,
	 @Type_Id			as numeric(18,0)=0,
	 @Dept_Id			as numeric(18,0)=0,
	 @Desig_Id			as numeric(18,0)=0,
	 @Emp_Id			as numeric(18,0)=0,
	 @Constraint		as varchar(max)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


IF @branch_Id = ''  
	set @branch_Id = null   --modify on 27 mar 2015
 If @Grd_Id = 0  
	 set @Grd_Id = null  
 If @Emp_ID = 0  
	set @Emp_ID = null  
 If @Desig_ID = 0  
	set @Desig_ID = null  
 If @Dept_ID = 0  
	set @Dept_ID = null 
 If @Cat_ID = 0
	set @Cat_ID = null
	
declare @col1 as numeric(18,0)  

 Declare @Emp_Cons Table
(
	Emp_ID	numeric 
)    
	
if @Constraint <> ''
	begin
		Insert Into @Emp_Cons
		select CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
	end
Else
	Begin
		Insert Into @Emp_Cons
		--select emp_id from T0080_KPIPMS_EVAL where Cmp_ID=@cmp_id and  KPIMPS_StartedOn between cast(@From_Date AS date) and cast(@To_Date as date) and KPIPMS_Type=@type
		select emp_id from T0080_EmpKPI WITH (NOLOCK) where Cmp_ID=@cmp_id and FinancialYr=@finyear 
End
		
--to get basic details
	create table #table1
	(
		 CompanyName		varchar(100)
		,CompanyLogo		image
		,Emp_id				numeric(18,0)
		,EmpCode			varchar(100)
		,Emp_Full_Name		varchar(100)
		,Department			varchar(100)
		,Designation		varchar(100)
		,Grade				varchar(100)
		,ReportingManager	varchar(100)
		,Dob				datetime
		,Doj				datetime
		,Branch				varchar(100)
		,Branchid			Numeric(18,0)
		,FinancialYr		int
		,EmpKPI_Id			numeric(18,0)
	)
	-- to get KPI
	create table #table2
	(
		 FinancialYr		int
		,EmpKPI_Id		numeric(18,0)
		,Emp_Id			numeric(18,0)
		,KPI_Id			numeric(18,0)
		,KPI			varchar(250)
		,Weightage		numeric(18,0)
		,Branch_Id		varchar(max) -- 27 mar 2015
	)
	-- to get Sub KPI
	create table #table3
	(
		  FinancialYr		int
		 ,Emp_Id			numeric(18,0)
		 ,SubKPIId			numeric(18,0)
		 ,KPI_Id			numeric(18,0)
		 ,Sub_KPI			varchar(250)
		 ,Weightage			numeric(18,2)
		 ,EmpKPI_Id			numeric(18,2)
	)
	-- to get KPI Attributes,objective,metric
	create table #Table4
	(
		  FinancialYr		int
		 ,Emp_Id			numeric(18,0)
		 ,EmpKPI_Id			numeric(18,2)
		 ,KpiAtt_Id			numeric(18,2)
		 ,SubKPIId			numeric(18,0)
		 ,KPI				varchar(250)
		 ,Kpi_Id			numeric(18,0)
		 ,KPIObj_ID			numeric(18,0)
		 ,Objective			varchar(max)
		 ,Metric			varchar(500)
	)
	
	create table #table5
	(
		 FinancialYr		int
		 ,Emp_Id			numeric(18,0)
		 ,EmpKPI_Id			numeric(18,2)
		 ,SubKPIId			numeric(18,0)
		 ,KPI_Id			numeric(18,0)
		 ,Sub_KPI			varchar(250)
		 ,Weightage			numeric(18,2)
		 ,KpiAtt_Id			numeric(18,2)
		 ,KPI				varchar(250)
		 ,KPIObj_ID			numeric(18,0)
		 ,Objective			varchar(max)
		 ,Metric			varchar(500)
	)
	
	declare @branchid varchar(max)--added on 27 mar 2015
	declare @EmpKPI_Id numeric(18,0)
	
	declare @fyear int
	declare @EmpId numeric(18,0)
	declare @KPI_Id numeric(18,0)
	declare @SubKPI_Id numeric(18,0)
	declare @KPIAtt_Id numeric(18,0)
	
	declare cur cursor
	for 
	   select Emp_ID from @Emp_Cons
		open cur
			fetch next from cur into @col1
				while @@FETCH_STATUS = 0
				Begin
				
					--insert into first table
					Insert into #table1(CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Grade,Dob,Doj,ReportingManager,Branch,Branchid)
					(Select Cmp_Name,cmp_logo,@col1,e.Alpha_Emp_Code,e.Emp_Full_Name,Dept_Name,Desig_Name,grd_name,e.Date_Of_Birth,e.date_of_join,rm.Emp_Full_Name as 'Reporting Manager',b.branch_name,i.Branch_ID
						 From T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
						 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
						 on i.Emp_ID = e.Emp_ID  left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
						 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
						 on g.Grd_ID = i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
						 on dg.Desig_ID = i.Desig_Id left join T0080_EMP_MASTER as rm  WITH (NOLOCK)
						 on rm.Emp_ID= e.Emp_Superior left join T0030_BRANCH_MASTER as B WITH (NOLOCK)
						 on b.Branch_ID= e.Branch_ID
						 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
											 
						Update #table1 
						set FinancialYr = e.FinancialYr,EmpKPI_Id =e.EmpKPI_Id 
						FROM(select FinancialYr,EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where Emp_Id=@col1 and FinancialYr=@finyear )e
						
						
					select @branch_Id = branchid from #table1 where Emp_id=@col1
					select @EmpKPI_Id = EmpKPI_Id from #table1 where Emp_id=@col1
						
					--insert into second table
					Insert into #table2(FinancialYr,EmpKPI_Id,Emp_Id,KPI_Id,KPI,Weightage,Branch_Id)
					(select @finyear,@EmpKPI_Id,@col1,KPI_Id,KPI,Weightage,Branch_Id from T0040_KPI_Master WITH (NOLOCK) where Cmp_Id=@cmp_id and Branch_Id like '%'+@branch_Id+'%' )-- 27 mar 2015
				
					--insert into third table
					declare cur1 cursor
					for 	
						select KPI_ID,Emp_Id,FinancialYr from #table2 where emp_id=@col1 and EmpKPI_Id=@EmpKPI_Id
					open cur1
						fetch next from cur1 into @kpi_id,@empid,@fyear
							while @@FETCH_STATUS = 0
							BEGIN
								Insert into #table3(FinancialYr,Emp_Id,KPI_Id,SubKPIId,Sub_KPI,Weightage,EmpKPI_Id)
								(select @fyear,@EmpId,KPI_Id,SubKPIId,Sub_KPI,Weightage,EmpKPI_Id from T0080_SubKPI_Master WITH (NOLOCK) where Emp_Id=@col1 and EmpKPI_Id=@EmpKPI_Id and KPI_Id=@KPI_Id)
								
								fetch next from cur1 into @kpi_id,@empid,@fyear
							End
					close cur1
					deallocate cur1	
					
					--insert into fourth table
						
							Insert into #Table4(FinancialYr,Emp_Id,EmpKPI_Id,KPIObj_ID,KpiAtt_Id,Objective,Metric)
							(Select @fyear,Emp_Id,EmpKPI_Id,KPIObj_ID,KpiAtt_Id,Objective,Metric from T0080_KPIObjectives WITH (NOLOCK) where emp_id=@EmpId and empkpi_id=@EmpKPI_Id)
																		
							declare cur21 cursor
							for 	
								select kpiatt_id from #table4 where emp_id=@col1 and EmpKPI_Id=@EmpKPI_Id
							open cur21
							fetch next from cur21 into @kpiatt_id
							while @@FETCH_STATUS = 0
								begin
									Update #Table4
									Set  SubKPIId = e.SubKPIId ,KPI =e.KPI, Kpi_Id=e.KPI_Id
									FROM (select m.SubKPIId,KPI,KPI_Id from T0040_EmpKPI_Master m WITH (NOLOCK) left join T0080_SubKPI_Master s WITH (NOLOCK) on s.SubKPIId = m.SubKPIId where m.emp_id=@EmpId and m.empkpi_id=@EmpKPI_Id  and KpiAtt_Id=@KPIAtt_Id)e
									where KpiAtt_Id = @KPIAtt_Id and Emp_Id=@EmpId and EmpKPI_Id=@EmpKPI_Id								
									fetch next from cur21 into @kpiatt_id
								End
							close cur21
							deallocate cur21						
						
						insert into #table5 (FinancialYr,Emp_Id,EmpKPI_Id,SubKPIId,KpiAtt_Id,KPIObj_ID,KPI,Objective,Metric)
					(select FinancialYr,Emp_Id,EmpKPI_Id,SubKPIId,KpiAtt_Id,KPIObj_ID,kpi,Objective,Metric from #Table4 where Emp_Id=@col1)
					
					
					declare cur21 cursor
							for 	
								select SubKPIId from #table5 where emp_id=@col1 
							open cur21
							fetch next from cur21 into @SubKPI_Id
							while @@FETCH_STATUS = 0
								begin
									update #table5 
									set Sub_KPI=s.Sub_KPI,Weightage=s.Weightage,KPI_Id=s.KPI_Id
									from (select Sub_KPI,Weightage,KPI_Id from #table3 where SubKPIId=@SubKPI_Id)s
									where SubKPIId=@SubKPI_Id
									fetch next from cur21 into @SubKPI_Id
								End
							close cur21
							deallocate cur21	
						
					fetch next from cur into @col1
				END
			close cur
		deallocate cur	
 
select 
CompanyName		
		,CompanyLogo		
		,Emp_id				
		,EmpCode			
		,Emp_Full_Name		
		,Department			
		,Designation		
		,Grade				
		,ReportingManager	
		,convert(NVARCHAR(11),Dob,103)as Dob						
		,convert(NVARCHAR(11),Doj,103)as Doj					
		,Branch				
		,Branchid			
		,FinancialYr		
		,EmpKPI_Id			
 from #table1
select * from #table2


select FinancialYr,
		Emp_Id,
		EmpKPI_Id,
		--Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		--Then  SubKPIId else null end as 'SubKPIId',
		SubKPIId,
		KPI_Id,
		Case When row_number() OVER ( PARTITION BY SubKPIId order by SubKPIId) = 1
		Then  Sub_KPI else null end as 'Sub_KPI',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by SubKPIId) = 1
		Then  Weightage else null end as 'Weightage',
		--Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		--Then  KpiAtt_Id else null end as 'KpiAtt_Id',	
		KpiAtt_Id,
		Case When row_number() OVER ( PARTITION BY KpiAtt_Id order by SubKPIId) = 1
		Then  KPI else '' end as 'KPI',		
		KPIObj_ID,
		Objective,
		Metric
from #table5 order by KPI_Id,SubKPIId asc
 
drop table #table1
drop table #table2
drop table #table3
drop table #table4			
	
END


