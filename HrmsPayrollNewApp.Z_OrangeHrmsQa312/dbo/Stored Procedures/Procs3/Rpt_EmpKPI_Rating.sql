


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec Rpt_EmpKPI_Rating 9,2014,0,0,0,0,0,0,0,'2028'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_EmpKPI_Rating]
	 @cmp_id			as numeric(18,0),
	 @finyear			as int,
	 @branch_Id			as varchar(max)='',--modify on 27 mar 2015
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
	set @branch_Id = null  --modify on 27 mar 2015  
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
		,AppType			varchar(100)
		,kPIPMS_Type		int
	)
-- to get KPI
	create table #table2
	(
		 FinancialYr			int
		,EmpKPI_Id				numeric(18,0)
		,Emp_Id					numeric(18,0)
		,KPI_Id					numeric(18,0)
		,KPI					varchar(250)
		,Weightage				numeric(18,0)
		,Branch_Id				varchar(max) --modify on 27 mar 2015  
		,IntScore				numeric(18,2)	
		,FinScore				numeric(18,2)	
		,IntScore_Manager		numeric(18,2)	 --modify on 14 Apr 2015 	
		,FinScore_Manager		numeric(18,2)	 --modify on 14 Apr 2015  
		,IntScore_Emp			numeric(18,2)	 --modify on 14 Apr 2015 
		,FinScore_Emp			numeric(18,2)	 --modify on 14 Apr 2015  
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
		 ,score				numeric(18,0)	
		 ,score_f			numeric(18,0)
	)
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
		 ,score				numeric(18,0)
		 ,score_f			numeric(18,0)
		 ,[status]			varchar(max)	--added on 28 Apr 2015 				
	)	
	
	declare @branchid numeric(18,0)
	declare @EmpKPI_Id numeric(18,0)
	
	declare @fyear int
	declare @EmpId numeric(18,0)
	declare @KPI_Id numeric(18,0)
	declare @SubKPI_Id numeric(18,0)
	declare @KPIAtt_Id numeric(18,0)
	declare @KPIObj_ID numeric(18,0) --added on 28 apr 2015
	
	DECLARE @query VARCHAR(max)
	DECLARE @columns VARCHAR(8000)
	
	declare cur cursor
	for 
	   select Emp_ID from @Emp_Cons
		open cur
			fetch next from cur into @col1
				while @@FETCH_STATUS = 0
				Begin
					Insert into #table1(CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Grade,Dob,Doj,ReportingManager,Branch,Branchid,AppType,kPIPMS_Type)
					(Select Cmp_Name,cmp_logo,@col1,e.Alpha_Emp_Code,e.Emp_Full_Name,Dept_Name,Desig_Name,grd_name,e.Date_Of_Birth,e.date_of_join,rm.Emp_Full_Name as 'Reporting Manager',b.branch_name,i.Branch_ID,k.KPIPMS_Name,k.kpipms_type
						  From T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
						 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
						 on i.Emp_ID = e.Emp_ID  left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
						 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
						 on g.Grd_ID = i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
						 on dg.Desig_ID = i.Desig_Id left join T0080_EMP_MASTER as rm WITH (NOLOCK)
						 on rm.Emp_ID= e.Emp_Superior left join T0030_BRANCH_MASTER as B WITH (NOLOCK)
						 on b.Branch_ID= e.Branch_ID left join T0080_KPIPMS_EVAL as k WITH (NOLOCK)
						 on k.Emp_ID=e.Emp_ID and k.KPIPMS_FinancialYr = @finyear
						 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
						 
						 Update #table1 
						set FinancialYr = e.FinancialYr,EmpKPI_Id =e.EmpKPI_Id 
						FROM(select FinancialYr,EmpKPI_Id from T0080_EmpKPI WITH (NOLOCK) where Emp_Id=@col1 and FinancialYr=@finyear )e
						 
						select @branch_Id = branchid from #table1 where Emp_id=@col1
						select @EmpKPI_Id = EmpKPI_Id from #table1 where Emp_id=@col1
						
						--insert into second table
						Insert into #table2(FinancialYr,EmpKPI_Id,Emp_Id,KPI_Id,KPI,Weightage,Branch_Id)
						(select @finyear,@EmpKPI_Id,@col1,KPI_Id,KPI,Weightage,Branch_Id from T0040_KPI_Master WITH (NOLOCK) where Cmp_Id=@cmp_id and Branch_Id like '%'+@branch_Id+'%')-- 27 mar 2015
						 
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
								
									--update score in #table2
									Update #table2 set IntScore = i.achievedWeight,IntScore_Emp=i.AchievedWeight_Emp,IntScore_Manager=i.AchievedWeight_Manager --added on 14 apr 2015
									FROM (select Avg(achievedWeight) achievedWeight,avg(r.AchievedWeight_Emp)AchievedWeight_Emp,avg(r.AchievedWeight_Manager)AchievedWeight_Manager
										  from T0080_KPIRating r WITH (NOLOCK) left join T0080_SubKPI_Master S WITH (NOLOCK)
										  on s.SubKPIId = r.SubKPIId left join T0040_KPI_Master m WITH (NOLOCK)
										  on m.KPI_Id = s.KPI_Id left join T0080_KPIPMS_EVAL E WITH (NOLOCK)
										  on e.KPIPMS_ID = r.KPIPMS_ID 
										  where m.KPI_Id = @kpi_id and e.KPIPMS_FinancialYr =@fyear and e.Emp_ID=@empid and e.KPIPMS_Type=1)i
									Where Emp_Id=@col1 and KPI_Id = @KPI_Id 
									
									Update #table2 set FinScore = i.achievedWeight,FinScore_Emp=i.AchievedWeight_Emp,FinScore_Manager=i.AchievedWeight_Manager --added on 14 apr 2015
									FROM (select Avg(achievedWeight) achievedWeight,avg(r.AchievedWeight_Emp)AchievedWeight_Emp,avg(r.AchievedWeight_Manager)AchievedWeight_Manager
										  from T0080_KPIRating r WITH (NOLOCK) left join T0080_SubKPI_Master S WITH (NOLOCK)
										  on s.SubKPIId = r.SubKPIId left join T0040_KPI_Master m WITH (NOLOCK)
										  on m.KPI_Id = s.KPI_Id left join T0080_KPIPMS_EVAL E WITH (NOLOCK)
										  on e.KPIPMS_ID = r.KPIPMS_ID 
										  where m.KPI_Id = @kpi_id and e.KPIPMS_FinancialYr =@fyear and e.Emp_ID=@empid and e.KPIPMS_Type=2)i
									Where Emp_Id=@col1 and KPI_Id = @KPI_Id 
									
									fetch next from cur1 into @kpi_id,@empid,@fyear
								End
						close cur1
						deallocate cur1	
						
						declare cur1 cursor
						for 	
							select SubKPIId,emp_id,FinancialYr from #table3 where emp_id=@col1 and FinancialYr=@finyear
						open cur1
							fetch next from cur1 into @SubKPI_Id,@empid,@fyear
								while @@FETCH_STATUS = 0
								BEGIN
									
									Update #table3 set score = w.AchievedWeight
									FROM(select distinct AchievedWeight from T0080_KPIRating WITH (NOLOCK) left join
									T0080_KPIPMS_EVAL k WITH (NOLOCK) on k.kpipms_id = T0080_KPIRating.kpipms_id  
									where SubKPIId=@SubKPI_Id and T0080_KPIRating.Emp_ID=@EmpId and k.KPIPMS_FinancialYr= @fyear and KPIPMS_Type=1 )w
									Where SubKPIId = @SubKPI_Id
																											
									Update #table3 set score_f = w.AchievedWeight
									FROM(select distinct AchievedWeight from T0080_KPIRating  WITH (NOLOCK) left join
									T0080_KPIPMS_EVAL k WITH (NOLOCK) on k.kpipms_id = T0080_KPIRating.kpipms_id 
									where SubKPIId=@SubKPI_Id and T0080_KPIRating.Emp_ID=@EmpId and k.KPIPMS_FinancialYr= @fyear and KPIPMS_Type=2 )w
									Where SubKPIId = @SubKPI_Id
								fetch next from cur1 into @SubKPI_Id,@empid,@fyear
								End
						close cur1
						deallocate cur1	
						 
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
									set Sub_KPI=s.Sub_KPI,Weightage=s.Weightage,KPI_Id=s.KPI_Id,score = s.score,score_f=s.score_f
									from (select Sub_KPI,Weightage,KPI_Id,score,score_f from #table3 where SubKPIId=@SubKPI_Id)s
									where SubKPIId=@SubKPI_Id
									fetch next from cur21 into @SubKPI_Id
								End
							close cur21
							deallocate cur21
					fetch next from cur into @col1
				end
		close cur
		deallocate cur
	
	
			--added on 28 apr 2015 - start
		declare cur22 cursor
			for 
				select KPIObj_ID from #table5 where emp_id = @col1 and FinancialYr = @finyear
			open cur22
			fetch next from cur22 into @KPIObj_ID
			while @@FETCH_STATUS = 0
				begin			
					update #table5 set status = p.kostatus from 
					(SELECT DISTINCT 
						  STUFF((SELECT distinct ',' + (ke.KPIPMS_Name+':'+ko.Status)
								  from T0090_KPIPMS_Objective ko WITH (NOLOCK) inner join 
									T0080_KPIPMS_EVAL ke WITH (NOLOCK) on ke.kpipms_id = ko.KPIPMS_ID and ke.Emp_ID = ko.Emp_ID
								 WHERE ke.emp_id = @col1 and ke.KPIPMS_FinancialYr = @finyear and ko.KPIObj_ID =@KPIObj_ID
									FOR XML PATH(''), TYPE
									).value('.', 'NVARCHAR(MAX)')
								,1,1,'') kostatus
						FROM T0090_KPIPMS_Objective p WITH (NOLOCK) ) p
					where #table5.emp_id = @col1 and #table5.FinancialYr = @finyear and #table5.KPIObj_ID = @KPIObj_ID
					
					fetch next from cur22 into @KPIObj_ID
				End
			close cur22
			deallocate cur22
		--added on 28 apr 2015 - end
	
			--SELECT @columns = COALESCE(@columns + ',[' + cast(AppType as nvarchar(100)) + ']',
			--	'[' + cast(AppType as nvarchar(100))+ ']')
			--	FROM #table1
			--	GROUP BY AppType
			--	order by AppType desc	
			
			SELECT @columns = COALESCE(@columns + ',[' + cast(kPIPMS_Type as nvarchar(100)) + ']',
				'[' + cast(kPIPMS_Type as nvarchar(100))+ ']')
				FROM #table1
				GROUP BY kPIPMS_Type
				order by kPIPMS_Type asc			

		
								
		SET @query = '	SELECT Emp_id,CompanyName,EmpKPI_Id,EmpCode,Emp_Full_Name,Department,Designation,Grade,ReportingManager,Dob,Doj,Branch,Branchid,FinancialYr,'+ @columns +'
						FROM (
							SELECT (kPIPMS_Type),
								CompanyName,Emp_id,EmpCode,EmpKPI_Id,Emp_Full_Name,Department,Designation,Grade,ReportingManager,Dob,Doj,Branch,Branchid,FinancialYr,Apptype
							FROM #table1
						) as s
						PIVOT
						(
							Max(Apptype)
							FOR [kPIPMS_Type] IN (' + @columns + ')
						)AS T'
																						
set @query = 'select    tbl1.CompanyName	
		,#table1.CompanyLogo					
		,tbl1.EmpCode	
		,tbl1.Emp_id		
		,tbl1.Emp_Full_Name		
		,tbl1.Department			
		,tbl1.Designation		
		,tbl1.Grade				
		,tbl1.ReportingManager	
		,convert(NVARCHAR(11),tbl1.Dob,103)as Dob						
		,convert(NVARCHAR(11),tbl1.Doj,103)as Doj	
		,tbl1.Branch				
		,tbl1.Branchid	
		,tbl1.EmpKPI_Id		
		,tbl1.FinancialYr
		,' + @columns + '
 	from (' + @query + ')as tbl1 inner join #table1 on #table1.EmpKPI_Id=tbl1.EmpKPI_Id'
 
 exec (@query)
	
 select * from #table2
 --select * from #table3
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
		Then  score else null end as 'score',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by SubKPIId) = 1
		Then  score_f else null end as 'score_f',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by SubKPIId) = 1
		Then  Weightage else null end as 'Weightage',
		--Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		--Then  KpiAtt_Id else null end as 'KpiAtt_Id',	
		KpiAtt_Id,
		Case When row_number() OVER ( PARTITION BY KpiAtt_Id order by SubKPIId) = 1
		Then  KPI else '' end as 'KPI',		
		KPIObj_ID,
		Objective,
		Metric,
		[status]
from #table5 order by KPI_Id,SubKPIId asc
	--select * from #table6 --added on 28 apr 2015
	
	drop table #table1
	drop table #table2
	drop table #table3
	drop table #table4			
	drop table #table5	
	--drop table #table6  --added on 28 apr 2015
		--DROP table #tbl1	
END

