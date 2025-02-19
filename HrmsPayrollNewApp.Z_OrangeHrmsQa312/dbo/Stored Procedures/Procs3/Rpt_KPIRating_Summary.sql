


-- =============================================
-- Author:		Sneha
-- Create date: 
-- Description:	exec Rpt_KPIRating_Summary 9,'2014-07-21','2014-07-30',0,0,0,0,0,0,0,'',1
-- exec Rpt_KPIRating_Summary 9,'2014-07-21','2014-07-21',0,0,0,0,0,0,0,'1358',1
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_KPIRating_Summary]
         @cmp_id			as numeric(18,0)
		,@From_Date			as datetime
		,@To_Date			as datetime
		,@branch_Id			as numeric(18,0)=0
		,@Cat_ID			as numeric = 0	
		,@Grd_Id			as numeric(18,0)=0
		,@Type_Id			as numeric(18,0)=0
		,@Dept_Id			as numeric(18,0)=0
		,@Desig_Id			as numeric(18,0)=0
		,@Emp_Id			as numeric(18,0)=0
		,@Constraint		as varchar(max)=''
		,@type				as int   -- to get whether interim or final		
AS
BEGIN


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
IF @branch_Id = 0  
	set @branch_Id = null   
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
			select emp_id from T0080_KPIPMS_EVAL WITH (NOLOCK) where Cmp_ID=@cmp_id and (KPIMPS_StartedOn >= cast(@From_Date AS date)  or  KPIMPS_StartedOn <= cast(@To_Date as date) )  and KPIPMS_Type=@type
		End
		
		declare @KPIPMS_ID as numeric(18)
		declare @FinancialYr as int
		declare @deptid as numeric(18)
		
	--create table1 to fetch data from 	
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
		,FinancialYr		int
		,KPIPMS_ID			numeric(18,0)
		,AppraisalType		varchar(50)
		,AppraisalName	    varchar(100)
		,KPIPMS_EmpEarlyComment varchar(500)
		,KPIPMS_SupEarlyComment varchar(500)
		,KPIPMS_EarlyComment varchar(500)
		,KPIPMS_Status		 int
	)
	-- create table2 for Main KPI
	create table #table2
	(
		 FinancialYr		int
		,KPIPMS_ID			numeric(18,0)
		,Emp_Id				numeric(18,0)
		,KPI_Id				numeric(18,0)
		,KPI				varchar(250)
		,Weightage			numeric(18,2)		
	)
	-- create table3 for sub KPI with rating & metric & objectives
	create table #table3
	(
		 FinancialYr		int
		,KPIPMS_ID			numeric(18,0)
		,Emp_Id				numeric(18,0)
		,SubKPIId			numeric(18,0)
		,KPI_Id				numeric(18,0)
		,Sub_KPI			varchar(50)
		,Weightage			numeric(18,0)
		,KPI_RatingID		numeric(18,0)		
		,Metric				varchar(500)
		,Rating				numeric(18,0)
		,RatingName			varchar(50)
		,objective			varchar(500)
		,AchievedWeightage  numeric(18,2)
	)
	-- create table4 for development plan
	create table #table4
	(
		 KPIPMS_ID			numeric(18,0)
		,Emp_Id				numeric(18,0)
		,KPI_DevelopmentID	numeric(18,0)
		,Strengths			varchar(200)
		,DevelopmentAreas	varchar(200)
		,ImprovementAction  varchar(200)
		,Timeline			varchar(200)
		,Status				varchar(200)
	)
	
declare cur cursor
	for 
	   select Emp_ID from @Emp_Cons
		open cur
			fetch next from cur into @col1
				while @@FETCH_STATUS = 0
					Begin
						--insert company & basic employee table in #table1
						Insert into #table1(CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Grade,Dob,Doj,ReportingManager)
						(Select Cmp_Name,cmp_logo,@col1,e.Alpha_Emp_Code,e.Emp_Full_Name,Dept_Name,Desig_Name,grd_name,e.Date_Of_Birth,e.date_of_join,rm.Emp_Full_Name as 'Reporting Manager'
						 From T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
						 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
						 on i.Emp_ID = e.Emp_ID  left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
						 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
						 on g.Grd_ID = i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
						 on dg.Desig_ID = i.Desig_Id left join T0080_EMP_MASTER as rm  WITH (NOLOCK)
						 on rm.Emp_ID= e.Emp_Superior
						 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
						 --update emp appraisal detail in #table1
						 update #table1
						 set   FinancialYr = (select KPIPMS_FinancialYr from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as date) ) and KPIPMS_Type=@type) 
							  ,KPIPMS_ID =  (select KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,AppraisalType =  case when @type=1 then 'Interim' else 'Final' end
							  ,AppraisalName = (select KPIPMS_Name from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,@KPIPMS_ID =	(select KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,@FinancialYr = (select KPIPMS_FinancialYr from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,KPIPMS_EmpEarlyComment = (select KPIPMS_EmpEarlyComment from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,KPIPMS_SupEarlyComment = (select KPIPMS_SupEarlyComment from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,KPIPMS_EarlyComment = (select KPIPMS_EarlyComment from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
							  ,KPIPMS_Status = (select KPIPMS_Status from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_Id=@col1 and (KPIMPS_StartedOn >= cast(@From_Date AS datetime)  or  KPIMPS_StartedOn <= cast(@To_Date as datetime) ) and KPIPMS_Type=@type) 
						 where #table1.Emp_id = @col1
						 
						 -- insert into #table2 
						 select @deptid=dept_id,@cat_id=Cat_ID from T0095_INCREMENT WITH (NOLOCK) where emp_id=@col1 and Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1)
						 				 
						 --Insert into #table2(FinancialYr,KPIPMS_ID,Emp_Id,KPI_Id,KPI,Weightage)
						 --(Select @FinancialYr,@KPIPMS_ID,@col1,KPI_Id,KPI,Weightage From T0040_KPI_Master Where Dept_Id like '%' + '' + cast(@deptid as varchar(50)) + '' + '%' and Category_Id=@Cat_ID)
						 
						 Insert into #table2(FinancialYr,KPIPMS_ID,Emp_Id,KPI_Id,Weightage,KPI)
						 (select @FinancialYr,@KPIPMS_ID,Emp_Id,EmpKPI_Id,Weightage,KPI from T0040_EmpKPI_Master WITH (NOLOCK) where Emp_Id=@col1 )
						 
						 --insert into #table3
						 Insert into #table3(FinancialYr,KPIPMS_ID,Emp_Id,SubKPIId,KPI_Id,Sub_KPI,Weightage,KPI_RatingID,Metric,Rating,RatingName,objective,AchievedWeightage)
						 (Select @FinancialYr,r.KPIPMS_ID,r.Emp_ID,s.SubKPIId,s.EmpKPI_Id,s.Sub_KPI,s.Weightage,r.KPI_RatingID,r.Metric,r.Rating,h.Rate_Text,'',r.AchievedWeight
						 from T0080_SubKPI_Master as s WITH (NOLOCK) left join T0080_KPIRating as r WITH (NOLOCK)
						 on r.SubKPIId=s.SubKPIId left join T0030_HRMS_RATING_MASTER as h WITH (NOLOCK)
						 on h.Rate_ID=r.Rating --left join T0080_KPIObjectives as o 
						 --on o.SubKPIId = s.SubKPIId
						 Where r.Emp_ID=@col1 and r.KPIPMS_ID=@KPIPMS_ID ) --ando.Emp_ID=r.Emp_ID and o.KPIObj_Financialyr = @FinancialYr
						
						 --insert into #table4
						 Insert into #table4(KPIPMS_ID,Emp_Id,KPI_DevelopmentID,Strengths,DevelopmentAreas,ImprovementAction,Timeline,Status)
						 (Select @KPIPMS_ID,emp_id,KPI_DevelopmentID,Strengths,DevelopmentAreas,ImprovementAction,Timeline,Status from T0080_KPI_DevelopmentPlan WITH (NOLOCK) where Emp_ID=@col1 and KPIPMS_ID=@KPIPMS_ID)
											
						 
						fetch next from cur into @col1
					End
		close cur
deallocate cur		


---select *  from #table1   
select CompanyName		
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
		,FinancialYr		
		,KPIPMS_ID			
		,AppraisalType		
		,AppraisalName	    
		,KPIPMS_EmpEarlyComment
		,KPIPMS_SupEarlyComment 
		,KPIPMS_EarlyComment 
		,KPIPMS_Status		 
		from #table1
select *  from #table2
--select *  from #table3  order by KPI_Id
--select *  from #table4	order by SubKPIId
Select 
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  FinancialYr else '' end as 'FinancialYr',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  KPIPMS_ID else KPIPMS_ID end as 'KPIPMS_ID',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  Emp_Id else Emp_Id end as 'Emp_Id',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  SubKPIId else SubKPIId end as 'SubKPIId',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  KPI_Id else KPI_Id end as 'KPI_Id',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  Sub_KPI else '' end as 'Sub_KPI',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  Weightage  end as 'Weightage',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  KPI_RatingID else KPI_RatingID end as 'KPI_RatingID',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  Metric else '' end as 'Metric',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  Rating else null end as 'Rating',
		Case When row_number() OVER ( PARTITION BY SubKPIId order by KPI_Id) = 1
		Then  RatingName else '' end as 'RatingName',
		Case When row_number() OVER (PARTITION BY SubKPIId order by KPI_Id) = 1
		Then AchievedWeightage else null end as 'AchievedWeightage',
		Objective
from #table3
select *  from #table4 

drop table #table1
drop table #table2
drop table #table3
drop table #table4
END


