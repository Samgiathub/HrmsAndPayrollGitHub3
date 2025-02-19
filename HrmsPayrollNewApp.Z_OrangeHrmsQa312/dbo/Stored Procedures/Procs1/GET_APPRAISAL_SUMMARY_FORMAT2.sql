



CREATE PROCEDURE [dbo].[GET_APPRAISAL_SUMMARY_FORMAT2]
	-- @Cmp_ID		numeric	
	--,@Initiate_Id	numeric(18,0)=0
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
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN	
			
	Declare @empid as numeric
	declare @edeptid as numeric
	declare @eGrdid as numeric
	declare @initid as numeric(18)
	
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
			select emp_id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
		End
	
	
-- create table for emp basic details		
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
	,Qualification		varchar(100)
	,Dob				datetime
	,Doj				datetime
	,Location			varchar(100)
	,InitiateId			numeric(18,0)
	,stdate				datetime
	,endate				datetime
	,todate				datetime
	,AppriserComment	varchar(500)
	,Submittedon		datetime
	,AppriseeComment	varchar(500)
	,ApprovedOn			datetime
	,LastPromodate      datetime
	,kpascore			numeric(18,2)
	,PaScore			numeric(18,2)
	,PoAScore			numeric(18,2)
	,OverallScore		numeric(18,2)
	,FinAppraiserComment varchar(500)
	,GHComment			varchar(500)
	,Achivement_Id      numeric(18,0)
	,Promo_YesNo		varchar(50)
	,Promo_desig		varchar(50)
	,Promo_Wef			datetime
	,JR_YesNo			varchar(50)
	,JR_From			datetime
	,JR_To				datetime
	,Inc_YesNo			varchar(50)
	,Inc_Reason			varchar(500)
	,ReviewerComment    varchar(500)
	,Appraiser_Date     datetime
	,ReportingManager	varchar(100)
	,GroupHead			varchar(100)
	,SA_ApprovedBy		varchar(100)
	,Per_ApprovedBy		varchar(100)
	,Range_To			numeric(18,2) --Mukti(25022016)
)
-- create table for self appraisal Questions			
create table #table2
(
	SApparisal_ID		numeric(18,0)
	,Cmp_ID				numeric(18,0)
	,SDept_Id			numeric(18,0)
	,SApparisal_Content varchar(1000)
	,SAppraisal_Sort	numeric(18,0)
	,SIsMandatory		int
	,SWeight			numeric(18,0)
	,initiateid			numeric(18,0)
	,emp_id				numeric(18,0)
)
-- create table for self appraisal Questions Answered by employee
create table #table3
(
	SelfApp_Id			numeric(18,0)
	,SAppraisal_ID		numeric(18,0)
	,Answer				varchar(1000)
	,Weightage			numeric(18,2)
	,initiateid			numeric(18,0)
)
-- create table for OA by employee
create table #table4
(
	OA_Id			numeric(18,0)
	,OA_Title		varchar(1000)
	,OA_Sort		numeric(18,0)
	,EOA_Column1	varchar(50)
	,EOA_Column2	varchar(50)
	,Emp_OA_ID		numeric(18,0)
	,Emp_id			numeric(18,0)
	,initiateid		numeric(18,0)
)	
-- create table for Performance Master 
create table #table5
(
	 PerformanceF_ID    numeric(18,0)
	,Performance_Name   varchar(100)
	,Performance_Sort   int   
	,PFAnswer_ID		numeric(18,0)
	,Answer				varchar(1000)
	,initiateid			numeric(18,0)
	,emp_id				numeric(18,0)
)
-- create table for Performance Master  Answered by employee
--create table #table6
--(
--	 PFAnswer_ID		numeric(18,0)
--	,InitiateId			numeric(18,0)
--	,PerformanceF_ID	numeric(18,0)   
--	,Answer				varchar(1000)
--	,Emp_Id				numeric(18,0)	
--)
-- create table for KPA  Answered by employee
create table #table7
(
	 KPA_ID				numeric(18,0)
	,InitiateId			numeric(18,0)
	,Emp_Id				numeric(18,0)
	,KPA_Content		varchar(1000)
	,KPA_Achievement	numeric(18,2)
	,KPA_Critical		varchar(1000)
	,KPA_Target         varchar(1000)   
	,KPA_AchievementEmp numeric(18,2) --Mukti(25022016)
	,KPA_Weightage  numeric(18,2) --Mukti(25022016)
)
-- create table for PA attribute
create table #table8
(
	 PA_ID				numeric(18,0)
	,PA_Title			varchar(250)
	,PA_Weightage		numeric(18,0)
	,EmpAtt_ID			numeric(18,0)
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)
	,Att_Score			varchar(50)
	,Att_Achievement	numeric(18,0)
	,Att_Critical		varchar(1000)
	,PA_Category		varchar(1000)
)
-- create table for PoA attribute
create table #table9
(
	 PA_ID				numeric(18,0)
	,PA_Title			varchar(250)
	,PA_Weightage		numeric(18,0)
	,EmpAtt_ID			numeric(18,0)
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)
	,Att_Score			varchar(50)
	,Att_Achievement	numeric(18,2)
	,Att_Critical		varchar(1000)
	,PA_Category		varchar(1000)
)
--All Training needs idebntification
--skill
 create table #table10
(
	 skillid numeric(18,0)
	,skillname varchar(100)
	,attendlast  varchar(100)
	,recommended  varchar(100)
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)
)
--training
create table #table11
(
	 trainid numeric(18,0)
	,trainname varchar(100)
	,attendlast  varchar(100)
	,recommended  varchar(100)	
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)	
)
--supportive
create table #table12
(
	 App_Trainingdetail_Id	numeric(18,0)
	,Initiation_Id			numeric(18,0)
	,Emp_Id					numeric(18,0)	
	,TrainingAreas			varchar(1000)
)
--Function
create table #table13
(
	 App_Trainingdetail_Id	numeric(18,0)
	,Initiation_Id			numeric(18,0)
	,Emp_Id					numeric(18,0)	
	,TrainingAreas			varchar(1000)
)
--training Feedback
create table #table14
(
	 Com_Observe		varchar(500)
	,GM_Observe			varchar(500)
	,GM_RecReason		varchar(500)
	,Sup_RecReason		varchar(500)
	,Fun_RecReason		varchar(500)
	,Other_Recommend	varchar(500)
	,Sup_AttendLast		varchar(500)
	,Fun_AttendLast		varchar(500)
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)	
)
--range master
create table #table6
(
	 Range_ID			numeric(18,0)
	,Range_From			numeric(18,0)
	,Range_To			numeric(18,0)
	,Range_Level		varchar(50)
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)
)

declare @col2 as numeric
declare @col4 as numeric
declare @col3 as numeric
declare @grd as numeric(18,0)

declare @kpa_score as int --added on 15 apr 2015

---added on 2 Mar 2016
declare @cmp_frmdate datetime
select @cmp_frmdate = From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id
declare @startdate datetime
---added on 2 Mar 2016 end
	--select * from @Emp_Cons
declare cur cursor
	for 
	   select Emp_ID from @Emp_Cons
		open cur
			fetch next from cur into @col1
				while @@FETCH_STATUS = 0
				Begin
					
				    --- insert into 1st table----------------------------------(start)					
					insert into #table1 (CompanyName,CompanyLogo,Emp_id,Emp_Full_Name,EmpCode,Department,Grade,Dob,Doj,Location,Designation,Qualification,ReportingManager,GroupHead)
					(select Cmp_Name,cmp_logo,e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,Grd_Name,e.Date_Of_Birth,e.Date_Of_Join,e.Loc_name,dg.Desig_Name,
					(select STUFF((select distinct ',' + q.qual_name 
						from t0040_qualification_master as q WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq WITH (NOLOCK) 
						on eq.Qual_ID=q.Qual_ID
						where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
						for XML Path (''),Type).value('.','NVARCHAR(MAX)')
						,1,1,'')qualification)as qualification,rm.Emp_Full_Name,gh.Emp_Full_Name
					 from T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
					 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
					 on i.Emp_ID = e.Emp_ID  left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
					 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
					 on g.Grd_ID = i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
					 on dg.Desig_ID = i.Desig_Id left join T0080_EMP_MASTER as rm WITH (NOLOCK)
					 on rm.Emp_ID=e.Emp_Superior left join T0080_EMP_MASTER as gh WITH (NOLOCK)
					 on gh.Alpha_Emp_Code = e.Old_Ref_No
					 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
			
					 update #table1
					 set  InitiateId = (select InitiateId from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,stdate = (select SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,endate = (select SA_Enddate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,todate = @To_Date
						 ,AppriseeComment=(select SA_EmpComments from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,AppriserComment=(select SA_AppComments from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,Submittedon= (select SA_SubmissionDate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 ,ApprovedOn =(select SA_ApprovedDate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))						
					     ,LastPromodate= (select Increment_Effective_Date from T0095_INCREMENT as i   WITH (NOLOCK) where i.Cmp_ID=@cmp_id  and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1) )	
					     ,kpascore = (select isnull(KPA_Final,0) from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
					     ,PaScore = (select isnull(PF_Score,0) from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))						
					     ,PoAScore = (select isnull(PO_Score,0) from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))												
					     ,OverallScore=(select isnull(Overall_Score,0) from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))												
					     ,FinAppraiserComment =(select AppriserComment from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
					     ,GHComment =(select GH_Comment from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))										
					     ,Achivement_Id =(select Achivement_Id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
					     ,Promo_YesNo =(select case when Promo_YesNo=1 then 'Yes' else 'No' end from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
					     ,Promo_desig =(select Desig_Name from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) left join T0040_DESIGNATION_MASTER WITH (NOLOCK) on Desig_ID=Promo_Desig where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																		
					     ,Promo_Wef =(select Promo_Wef from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																	
					     ,JR_YesNo =(select case when JR_YesNo =1 then 'Yes' else 'No' end from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																																			
					     ,JR_From =(select JR_From from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																
					     ,JR_To =(select JR_To from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
					     ,Inc_YesNo =(select case when Inc_YesNo=1 then 'Yes' else 'No' end from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																																																					
					     ,Inc_Reason=(select Inc_Reason from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																																																					
					     ,ReviewerComment =(select ReviewerComment from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))	
					     ,Appraiser_Date =(select Appraiser_Date from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)  where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																																																				
					     ,SA_ApprovedBy = (select isnull(e.Emp_Full_Name,'Admin') 
											from T0050_HRMS_InitiateAppraisal as i WITH (NOLOCK) left join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID= i.SA_ApprovedBy
											where i.Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
						 ,Per_ApprovedBy = (select isnull(e.Emp_Full_Name,'Admin') 
											from T0050_HRMS_InitiateAppraisal as i WITH (NOLOCK) left join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID= i.AppraiserId
											where i.Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))																																																																			
						,Range_To=(select Max(Range_To) from  T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and Range_PID=0)
					where #table1.Emp_id = @col1	
				   --- insert into 1st table----------------------------------(end)
					
					select @initid=initiateid from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
					--select * from #table1
					
					--- insert into 2nd table----------------------------------(start)	
					select @dept_id=dept_id from t0080_emp_master WITH (NOLOCK) where emp_id=@col1					
					select @startdate=SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)--added on 2 Mar 2016
			      
					insert into #table2(SApparisal_ID,Cmp_ID,SDept_Id,SApparisal_Content,SAppraisal_Sort,SIsMandatory,SWeight,initiateid,emp_id)
					(  SELECT SApparisal_ID,Cmp_ID,@dept_id,isnull(SApparisal_Content,'')as SApparisal_Content,isnull(SAppraisal_Sort,0)as SAppraisal_Sort,isnull(SIsMandatory,0)as SIsMandatory,isnull(SWeight,0)as SWeight,@initid,@col1
					   from T0040_SelfAppraisal_Master h WITH (NOLOCK) where isnull(Effective_Date,@cmp_frmdate) = ( 
					   select max(isnull(Effective_Date,@cmp_frmdate)) from T0040_SelfAppraisal_Master am WITH (NOLOCK) where cmp_id=@cmp_id
					   and isnull(Effective_Date,@cmp_frmdate) <= @startdate
					   and isnull(am.Ref_SID,am.SApparisal_ID) = isnull(h.Ref_SID,h.SApparisal_ID))and cmp_id=@cmp_id
					   and (@dept_id in (select data from dbo.Split(sdept_id,'#')) or isnull(h.SDept_Id,'0')='0') and isnull(SType,1)=1 
					)--modified on 2 Mar 2016
					
					--(SELECT SApparisal_ID,Cmp_ID,@dept_id,isnull(SApparisal_Content,'')as SApparisal_Content,isnull(SAppraisal_Sort,0)as SAppraisal_Sort,isnull(SIsMandatory,0)as SIsMandatory,isnull(SWeight,0)as SWeight,@initid,@col1 From T0040_SelfAppraisal_Master where Cmp_ID=@cmp_id  and (SDept_Id like '%' + cast (@dept_id as varchar(18)) + '%' or SDept_Id= '0') and (Stype is null or stype=1))	
					--- insert into 2nd table----------------------------------(end)
					
					--- insert into 3rd table----------------------------------(start)	
					insert into #table3(SelfApp_Id,SAppraisal_ID,Answer,Weightage,initiateid)
				    (Select SelfApp_Id,SAppraisal_ID,isnull(Answer,'') as Answer,isnull(Weightage,0) as Weightage,initiateid From T0052_Emp_SelfAppraisal WITH (NOLOCK) where initiateid=@initid)
					--- insert into 3rd table----------------------------------(end)	
					
					--- insert into 4th table----------------------------------(start)	
					if exists(select o.OA_Id,o.OA_Title,o.OA_Sort,F.EOA_Column1,f.EOA_Column2,f.Emp_OA_ID,Emp_Id,Initiation_Id from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)
					 left join T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id where O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )	
						 begin
							insert into #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid)
							(select o.OA_Id,isnull(o.OA_Title,'') as OA_Title,isnull(o.OA_Sort,0) as OA_Sort,isnull(F.EOA_Column1,0) as EOA_Column1,isnull(f.EOA_Column2,0) as EOA_Column2,f.Emp_OA_ID,Emp_Id,@initid from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)
							left join T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id where O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )
						 End
					Else
						Begin
							insert into #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid)
							(select o.OA_Id,isnull(o.OA_Title,'') as OA_Title,isnull(o.OA_Sort,0) as OA_Sort,'' as EOA_Column1,'' as EOA_Column2,0 as Emp_OA_ID,@col1 as emp_id,@initid as Initiation_Id from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)  where O.Cmp_ID=@cmp_id) 
						End
					--- insert into 4th table----------------------------------(end)	
					--- insert into 5th table----------------------------------(start)
					insert into #table5(PerformanceF_ID,Performance_Name,Performance_Sort,emp_id,initiateid)
					(select PerformanceF_ID,Performance_Name,Performance_Sort,@col1,@initid from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Cmp_ID=@cmp_id)
					
					--insert into #table5(PerformanceF_ID,PFAnswer_ID,Answer,initiateid,emp_id)
					--(select PerformanceF_ID,PFAnswer_ID,Answer,@initid,@col1 FROM  T0052_HRMS_PerformanceAnswer where  InitiateId= @initid and Emp_Id=@col1)
					
					update #table5 set PFAnswer_ID = p.PFAnswer_ID ,Answer=p.Answer 
					From(select PFAnswer_ID,Answer,PerformanceF_ID from T0052_HRMS_PerformanceAnswer WITH (NOLOCK)  where  InitiateId= @initid and Emp_Id=@col1 )p
					where  #table5.PerformanceF_ID = p.PerformanceF_ID
					
					declare @cnt int
					set @cnt = 0	
					declare cur2 cursor
					for 
						select PerformanceF_ID from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Cmp_ID=@cmp_id
						open cur2
							fetch next from cur2 into @col2
								while @@FETCH_STATUS = 0
									begin		
										 --select * from #table5			
										if  exists(select 1 from #table5 where PerformanceF_ID=@col2 and initiateid=@initid and emp_id=@col1)
											begin	
												update #table5 
												set Performance_Name = (select Performance_Name from T0040_PerformanceFeedback_Master WITH (NOLOCK) where  PerformanceF_ID=@col2)
												   ,Performance_Sort = (select Performance_Sort from T0040_PerformanceFeedback_Master WITH (NOLOCK) where  PerformanceF_ID=@col2)
												Where PerformanceF_ID=@col2
											End
										Else
											begin	
												insert into #table5(PerformanceF_ID,Performance_Name,Performance_Sort,emp_id,initiateid)
												 (select PerformanceF_ID,Performance_Name,Performance_Sort,@col1,@initid FROM  T0040_PerformanceFeedback_Master WITH (NOLOCK) where Cmp_ID=@cmp_id )													
											End			
										fetch next from cur2 into @col2
									End
						close cur2
					deallocate cur2
					
					
					--- insert into 5th table----------------------------------(end)	
					--- insert into 6th table----------------------------------(start)
					--insert into #table6(PFAnswer_ID,PerformanceF_ID,Answer,Emp_Id,InitiateId)
					--(select PFAnswer_ID,PerformanceF_ID,Answer,@col1,@initid FROM  T0052_HRMS_PerformanceAnswer where  InitiateId= @initid and Emp_Id=@col1)					
					--- insert into 6th table----------------------------------(end)
					--- insert into 7th table----------------------------------(start)
					select @kpa_score = KPA_Score  from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
					
					if @kpa_score = 1
						begin 
							insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Target,KPA_AchievementEmp,KPA_Weightage)
							(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,cast( cast(KPA_Achievement as int) as varchar(50))+'-'+ Range_Level,KPA_Critical,KPA_Target,KPA_AchievementEmp,KPA_Weightage 
							from T0052_HRMS_KPA WITH (NOLOCK) cross join T0040_HRMS_RangeMaster as a  WITH (NOLOCK)
							where InitiateId=@initid and Emp_Id=@col1 and  (KPA_Achievement between Range_From and Range_To) and Range_Type=1 and a.Cmp_ID=@cmp_Id)
						End
					else
						begin
							insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Target,KPA_AchievementEmp,KPA_Weightage)
							(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Target,KPA_AchievementEmp,KPA_Weightage  from T0052_HRMS_KPA WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 )
						End
					--- insert into 7th table----------------------------------(end)
					--- insert into 8th table----------------------------------(start)
					
					insert into #table8(PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,Att_Score,Att_Achievement,Att_Critical,PA_Category)
					(select distinct A.PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,cast(Att_Score as varchar(50))+'-'+b.Range_Level,Att_Achievement ,Att_Critical,PA_Category 
					 FROM  T0040_HRMS_AttributeMaster as A WITH (NOLOCK) left join
						   T0052_HRMS_AttributeFeedback as F WITH (NOLOCK) on f.PA_ID=a.PA_ID cross join T0040_HRMS_RangeMaster as b WITH (NOLOCK)					   
					 where A.Cmp_ID=@Cmp_ID and b.Cmp_ID=@Cmp_ID and PA_Type='PA' and Emp_Id=@col1 and f.Initiation_Id=@initid and (Att_Score between Range_From and Range_To) and Range_Type=1)
					-- insert into 8th table----------------------------------(end)
					--- insert into 9th table----------------------------------(start)
					insert into #table9(PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,Att_Score,Att_Achievement,Att_Critical,PA_Category)
					(select distinct A.PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,cast(Att_Score as varchar(50))+'-'+b.Range_Level,Att_Achievement ,Att_Critical,PA_Category
					 FROM  T0040_HRMS_AttributeMaster as A WITH (NOLOCK) left join
						   T0052_HRMS_AttributeFeedback as F WITH (NOLOCK) on f.PA_ID=a.PA_ID cross join T0040_HRMS_RangeMaster as b WITH (NOLOCK)
					 where A.Cmp_ID=@Cmp_ID and b.Cmp_ID=@Cmp_ID and PA_Type='PoA' and Emp_Id=@col1 and f.Initiation_Id=@initid and (Att_Score between Range_From and Range_To) and Range_Type=1)
					--- insert into 9th table----------------------------------(end)
					--- insert into 10th table----------------------------------(start)
					
					--SELECT s.Skill_ID,S.Skill_Name,@initid,@empid
					--FROM T0052_HRMS_AppTraining A inner JOIN
					--	 T0040_SKILL_MASTER S ON S.Skill_ID in (SELECT data FROM dbo.Split(a.Recommended_ThisYear,'#'))
					--WHERE InitiateId=@initid and emp_id=@col1 and a.Type='Skill' )
					
					---added on 15 Mar 2015--start
					INSERT INTO #table10(skillid,skillname,Initiation_Id,Emp_Id)
					(SELECT s.Skill_ID,S.Skill_Name,@initid,@empid
					FROM T0052_HRMS_AppTraining A WITH (NOLOCK) inner JOIN
						 T0040_SKILL_MASTER S WITH (NOLOCK) ON a.Recommended_ThisYear <>'' and S.Skill_ID in (SELECT data FROM dbo.Split(a.Recommended_ThisYear,'#'))
					WHERE InitiateId=@initid and emp_id=@col1 and a.Type='Skill' )
					---added on 15 Mar 2015--end
														
					---added on 15 Mar 2015--start
					INSERT INTO #table11(trainid,trainname,Initiation_Id,Emp_Id)
					(SELECT s.Training_id,S.Training_name,@initid,@empid
					FROM T0052_HRMS_AppTraining A WITH (NOLOCK) inner JOIN
						 T0040_Hrms_Training_master S WITH (NOLOCK) ON a.Recommended_ThisYear <>'' and S.Training_id in (SELECT data FROM dbo.Split(a.Recommended_ThisYear,'#'))
					WHERE InitiateId=@initid and emp_id=@col1 and a.Type='GM' )
					---added on 15 Mar 2015--end
						
					--- insert into 12th table----------------------------------(start)
					insert into #table12(App_Trainingdetail_Id,TrainingAreas,Emp_Id,Initiation_Id)
					select App_Trainingdetail_Id,TrainingAreas,@col1,@initid  from T0052_HRMS_AppTrainingDetail WITH (NOLOCK) where InitiateId=@initid and emp_id=@Col1 and T0052_HRMS_AppTrainingDetail.Type='Support'
					--- insert into 12th table----------------------------------(end)
					--- insert into 13th table----------------------------------(start)
					insert into #table13(App_Trainingdetail_Id,TrainingAreas,Emp_Id,Initiation_Id)
					select App_Trainingdetail_Id,TrainingAreas,@col1,@initid  from T0052_HRMS_AppTrainingDetail WITH (NOLOCK) where InitiateId=@initid and emp_id=@Col1 and T0052_HRMS_AppTrainingDetail.Type='Function'
					--- insert into 13th table----------------------------------(end)
					--- insert into 14th table----------------------------------(start)
					insert into #table14(emp_id,Initiation_Id)
					(select @col1,@initid)
				
					update #table14 set
						 Com_Observe= (select isnull(ObservableChanges,'') from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTraining.Type='skill' and App_Training_Id=(select MAX(App_Training_Id) from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1))
						 ,GM_Observe=(select ObservableChanges from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTraining.Type='GM' and App_Training_Id=(select MAX(App_Training_Id) from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1))
						 ,GM_RecReason=(select ReasonForRecommend from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTraining.Type='GM' and App_Training_Id=(select MAX(App_Training_Id) from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1))
						 ,Sup_RecReason=(select Recommended_ThisYear from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTrainDetail.Type='Support' )
						 ,Fun_RecReason=(select Recommended_ThisYear from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTrainDetail.Type='Function')
						 ,Other_Recommend=(select OtherTraining from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTrainDetail.Type='Function')
						 ,Sup_AttendLast =(select Attend_LastYear from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTrainDetail.Type='Support')
						 ,Fun_AttendLast =(select Attend_LastYear from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 and T0052_HRMS_AppTrainDetail.Type='Function')
					 Where Initiation_Id=@initid and Emp_Id=@col1
					-- insert into 14th table----------------------------------(end)
					--- insert into 6th table----------------------------------(start)
					select @Grd_Id = Grd_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@col1 and Cmp_ID=@cmp_id
					insert into #table6(Range_ID,Range_From,Range_To,Range_Level,Initiation_Id,Emp_Id)
					(select Range_ID,Range_From,Range_To,Range_Level,@initid,@col1 from T0040_HRMS_RangeMaster WITH (NOLOCK) where Range_Type = 2 and Range_Dept like '%' + cast (@Dept_Id as varchar(50)) + '%' and Range_Grade like '%' + cast(@Grd_Id as varchar(50)) + '%' )
					
					--- insert into 6th table----------------------------------(end)
					fetch next from cur into @col1
				End
		close cur
deallocate cur		
	
select CompanyName as CMP_NAME,CompanyLogo,emp_id,EmpCode,Emp_Full_Name,Department,Designation,Grade,Qualification,convert(VARCHAR(15),Dob,103)AS Dob,convert(VARCHAR(15),Doj,103)AS Doj,Location,InitiateId,convert(VARCHAR(15),stdate,103)AS stdate,convert(VARCHAR(15),endate,103)AS endate ,convert(VARCHAR(15),todate,103)AS todate ,AppriserComment,convert(VARCHAR(15),Submittedon,103)AS Submittedon ,AppriseeComment,convert(VARCHAR(15),ApprovedOn,103)AS ApprovedOn ,convert(VARCHAR(15),LastPromodate,103)AS LastPromodate ,kpascore,PaScore,PoAScore,OverallScore,FinAppraiserComment,GHComment,Achivement_Id,Promo_YesNo,Promo_desig,convert(VARCHAR(15),Promo_Wef,103)AS Promo_Wef,JR_YesNo,convert(VARCHAR(15),JR_From,103)AS JR_From,convert(VARCHAR(15),JR_To,103)AS JR_To,Inc_YesNo,Inc_Reason,ReviewerComment,convert(VARCHAR(15),Appraiser_Date,103)AS Appraiser_Date,ReportingManager,GroupHead,SA_ApprovedBy,Per_ApprovedBy,Range_To  from #table1
select * from #table2
select * from #table3
select * from #table4
select * from #table5 order by PerformanceF_ID,PFAnswer_ID
select * from #table6 order by Range_From desc
select * from #table7
select * from #table8
select * from #table9
select * from #table10
select * from #table11
select * from #table12
select * from #table13
select * from #table14

drop table #table1
drop table #table2
drop table #table3
drop table #table4	
drop table #table5
drop table #table6
drop table #table7
drop table #table8
drop table #table9
drop table #table10
drop table #table11
drop table #table12
drop table #table13
drop table #table14
END

