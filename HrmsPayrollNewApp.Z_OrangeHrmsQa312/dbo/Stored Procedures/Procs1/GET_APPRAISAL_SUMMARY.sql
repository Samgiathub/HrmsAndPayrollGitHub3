
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_APPRAISAL_SUMMARY]
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
	,HodComment			varchar(500) -- 15 Mar 2016
	,Is_Hod				int	-- 15 Mar 2016
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
	,Performance_Measure int
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
	,Answer				varchar(2000)
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
	,RM_Comments	varchar(5000)
	,HOD_Comments	varchar(5000)	
	,GH_Comments	varchar(5000)	
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
	,KPA_Achievement	varchar(100)
	,KPA_Critical		varchar(1000)
	,KPA_Weightage		NUMERIC(18,2) --added on 14 Mar  2015
	,KPA_AchievementEmp	varchar(100) --added on 25 Apr  2016	
	,KPA_AchievementRM  varchar(100) --added on 25 Apr  2016	
	,KPA_Target			varchar(MAX)
	,Actual_achievement		varchar(MAX)
	,KPA_AchievementHOD  NUMERIC(18,2)
	,KPA_AchievementGH  NUMERIC(18,2)
	,KPA_Type			varchar(100)
	,KPA_Performace_Measure varchar(300)
	,Achieve_Perc_EMP float
	,Achieve_Perc_RM float
	,Achieve_Perc_HOD float
	,Achieve_Perc_GH float
	,Attach_Docs		varchar(500)
	,Completion_Date DATETIME
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

CREATE TABLE #Table15
	(
		 Emp_Id				NUMERIC(18,0)
		,InitiateId			NUMERIC(18,0)
		,[Action]			VARCHAR(max)
		,Justification		VARCHAR(max)		
		,TimeFrame			VARCHAR(250)
		,from_date			DATETIME
		,to_date			DATETIME
		,Promo_Desig		VARCHAR(250)
		,Is_Applicable		NUMERIC(18,0)
	)
declare @col2 as numeric
declare @col4 as numeric
declare @col3 as numeric
declare @grd as numeric(18,0)
declare @Performance_Measure int
declare @kpa_score as int --added on 15 apr 2015
declare @kpa_default as INT -- added on 14 Mar 2016
---added on 2 Mar 2016
declare @cmp_frmdate datetime
select @cmp_frmdate = From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id
declare @startdate datetime
---added on 2 Mar 2016 end
declare @Self_Assessment_With_Answer int

select top 1 @kpa_default = isnull(KPA_Default,1),@Self_Assessment_With_Answer=Self_Assessment_With_Answer from T0050_AppraisalLimit_Setting WITH (NOLOCK)
where Cmp_ID= @cmp_id order by Limit_Id desc

declare cur cursor
	for 
	   select Emp_ID from @Emp_Cons
		open cur
			fetch next from cur into @col1
				while @@FETCH_STATUS = 0
				Begin			
				
				select @initid=initiateid,@startdate=SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)					
				 --- insert into 1st table----------------------------------(start)					
					insert into #table1 (CompanyName,CompanyLogo,Emp_id,Emp_Full_Name,EmpCode,Department,Grade,Dob,Doj,Location,Designation,Qualification,ReportingManager)--,GroupHead
					(select Cmp_Name,cmp_logo,e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,Grd_Name,e.Date_Of_Birth,e.Date_Of_Join,e.Loc_name,dg.Desig_Name,
					(select STUFF((select distinct ',' + q.qual_name 
						from t0040_qualification_master as q WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq WITH (NOLOCK)
						on eq.Qual_ID=q.Qual_ID
						where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
						for XML Path (''),Type).value('.','NVARCHAR(MAX)')
						,1,1,'')qualification)as qualification,(rm.Alpha_Emp_Code+'-'+rm.Emp_Full_Name)--,gh.Emp_Full_Name
					 from T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
					 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
					 on i.Emp_ID = e.Emp_ID  left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
					 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
					 on g.Grd_ID = i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
					 on dg.Desig_ID = i.Desig_Id left join T0080_EMP_MASTER as rm  WITH (NOLOCK)
					 on rm.Emp_ID=e.Emp_Superior left join T0080_EMP_MASTER as gh WITH (NOLOCK)
					 on gh.Alpha_Emp_Code = e.Old_Ref_No
					 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
																		
											
				    UPDATE #table1
									 SET InitiateId = tb.InitiateId 
										 ,stdate = tb.SA_Startdate
										 ,endate = tb.SA_Enddate
										 ,todate = @To_Date
										 ,AppriseeComment = tb.SA_EmpComments
										 ,AppriserComment = tb.SA_AppComments
										 ,Submittedon = tb.SA_SubmissionDate
										 ,ApprovedOn = tb.SA_ApprovedDate
										 ,kpascore = tb.KPA_Final
										 ,PaScore = tb.PF_Score
										 ,POAScore = tb.PO_Score
										 ,OverallScore = tb.Overall_Score
										 ,FinAppraiserComment = tb.AppraiserComment
										 ,GHComment	= tb.GH_Comment
										 ,HodComment = tb.HOD_Comment --15 mar 2016
										 ,Is_Hod = tb.SendToHOD -- 15 Mar 2016
										 ,Achivement_Id  = tb.Achivement_Id
										 ,Promo_YesNo = tb.Promo_YesNo
										 ,Promo_Wef = tb.Promo_Wef
										 ,JR_From = tb.JR_From 
										 ,JR_To  = tb.JR_To
										 ,Inc_YesNo = tb.Inc_YesNo
										 ,Inc_Reason= tb.Inc_Reason
										 ,ReviewerComment  = tb.ReviewerComment
										 ,Appraiser_Date = tb.Appraiser_Date	
										 ,GroupHead =   GHName --27 Feb 2017  
									 FROM	(Select InitiateId ,SA_Startdate,SA_Enddate,SA_EmpComments,SA_AppComments,SA_SubmissionDate,SA_ApprovedDate
											 ,isnull(KPA_Final,0)KPA_Final,isnull(PF_Score,0)PF_Score,isnull(PO_Score,0)PO_Score,isnull(Overall_Score,0) Overall_Score
											 ,AppraiserComment,GH_Comment,Achivement_Id,  case when Promo_YesNo=1 then 'Yes' else 'No' end Promo_YesNo
											 ,Promo_Wef,case when JR_YesNo =1 then 'Yes' else 'No' end JR_YesNo,JR_From,JR_To,case when Inc_YesNo=1 then 'Yes' else 'No' end Inc_YesNo
											 ,Inc_Reason,ReviewerComment,Appraiser_Date,HOD_Comment,SendToHOD  ,(gh.Alpha_Emp_Code +'-'+ GH.Emp_Full_Name)  as GHName
											 FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) left JOIN
												  T0080_EMP_MASTER GH WITH (NOLOCK) on GH.Emp_ID = I.Emp_Id and ISNULL(I.GH_Id,0)>0 
											 Where I.Emp_Id=@col1 AND  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime) )tb
									 WHERE #table1.Emp_id = @col1	
							 
					 select @kpa_score = KPA_Score,@Performance_Measure=ISNULL(Show_KPA_Measure,0)  from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
					 update #table1
					 set LastPromodate= (select Increment_Effective_Date from T0095_INCREMENT as i WITH (NOLOCK)  where i.Cmp_ID=@cmp_id  and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1) )						 
					     ,SA_ApprovedBy = (select isnull(e.Emp_Full_Name,'Admin') 
											from T0050_HRMS_InitiateAppraisal as i WITH (NOLOCK) left join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID= i.SA_ApprovedBy
											where i.Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))		
						 ,Per_ApprovedBy = (select isnull(e.Emp_Full_Name,'Admin') 
											from T0050_HRMS_InitiateAppraisal as i WITH (NOLOCK) left join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID= i.AppraiserId
											where i.Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						,Promo_desig =  (select Desig_Name from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) left join T0040_DESIGNATION_MASTER WITH (NOLOCK) on Desig_ID=Promo_Desig where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime))					
						,Performance_Measure=@Performance_Measure
					 where #table1.Emp_id = @col1
					 	
					 					
				   --- insert into 1st table----------------------------------(end)
					
					--select @initid=initiateid from T0050_HRMS_InitiateAppraisal where emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)

					
					--- insert into 2nd table----------------------------------(start)	
					--select @dept_id=dept_id from t0080_emp_master where emp_id=@col1					
					select  @dept_id=IE.Dept_ID,@Grd_Id = IE.Grd_ID
					from T0080_EMP_MASTER em WITH (NOLOCK)
					INNER JOIN	
					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID,I.Grd_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = @cmp_id
						 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= @cmp_id
					)IE on ie.Emp_ID = em.Emp_ID
					where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@col1
					
					--select @startdate=SA_Startdate from T0050_HRMS_InitiateAppraisal where Emp_Id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)--added on 2 Mar 2016
			    
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
					 INNER join T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id where O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )	
						 begin
							insert into #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid,RM_Comments,HOD_Comments,GH_Comments)
							(select o.OA_Id,isnull(o.OA_Title,'') as OA_Title,isnull(o.OA_Sort,0) as OA_Sort,isnull(F.EOA_Column1,0) as EOA_Column1,isnull(f.EOA_Column2,0) as EOA_Column2,f.Emp_OA_ID,Emp_Id,@initid,
							ISNULL(RM_Comments,'')RM_Comments,ISNULL(HOD_Comments,''),ISNULL(GH_Comments,'')GH_Comments from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)
							left join T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id where O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )
						 End
					Else
						Begin
							insert into #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid,RM_Comments,HOD_Comments,GH_Comments)
							(select o.OA_Id,isnull(o.OA_Title,'') as OA_Title,isnull(o.OA_Sort,0) as OA_Sort,'' as EOA_Column1,'' as EOA_Column2,0 as Emp_OA_ID,@col1 as emp_id,@initid as Initiation_Id,'','','' from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK) where O.Cmp_ID=@cmp_id) 
						End
					--- insert into 4th table----------------------------------(end)	
					--- insert into 5th table----------------------------------(start)
					insert into #table5(PerformanceF_ID,Performance_Name,Performance_Sort,emp_id,initiateid)
					(select PerformanceF_ID,Performance_Name,Performance_Sort,@col1,@initid from T0040_PerformanceFeedback_Master WITH (NOLOCK) where Cmp_ID=@cmp_id)
					
					--insert into #table5(PerformanceF_ID,PFAnswer_ID,Answer,initiateid,emp_id)
					--(select PerformanceF_ID,PFAnswer_ID,Answer,@initid,@col1 FROM  T0052_HRMS_PerformanceAnswer where  InitiateId= @initid and Emp_Id=@col1)
					
					update #table5 set PFAnswer_ID = p.PFAnswer_ID ,Answer=p.Answer 
					From(select PFAnswer_ID,Answer,PerformanceF_ID from T0052_HRMS_PerformanceAnswer WITH (NOLOCK) where  InitiateId= @initid and Emp_Id=@col1 )p
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
					
						 --added on 14 Mar 2016
					if @kpa_score = 1
						begin
							if @kpa_default = 1 --added on 14 Mar 2016
								BEGIN
									insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,KPA_Target,Actual_achievement,KPA_AchievementHOD,KPA_AchievementGH,KPA_Type,KPA_Performace_Measure,Achieve_Perc_EMP,Achieve_Perc_RM,Achieve_Perc_HOD,Achieve_Perc_GH,Attach_Docs,Completion_Date)
									(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,cast( cast(KPA_Achievement as int) as varchar(50))+'-'+ Range_Level,KPA_Critical ,
									isnull(KPA_Weightage,1),KPA_AchievementEmp,KPA_AchievementRM,ISNULL(KPA_Target,''),ISNULL(Actual_Achievement,''),ISNULL(KPA_AchievementHOD,0),ISNULL(KPA_AchievementGH,0),
									'','',0,0,0,0,'',Completion_Date
									from T0052_HRMS_KPA WITH (NOLOCK) cross join T0040_HRMS_RangeMaster as a  WITH (NOLOCK)
									where InitiateId=@initid and Emp_Id=@col1 and  (KPA_Achievement between Range_From and Range_To) and Range_Type=1 and a.Cmp_ID=@cmp_Id)
								END
							ELSE	
								BEGIN --added on 14 Mar 2016
									insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,KPA_Target,Actual_achievement,KPA_AchievementHOD,KPA_AchievementGH,KPA_Type,KPA_Performace_Measure,Achieve_Perc_EMP,Achieve_Perc_RM,Achieve_Perc_HOD,Achieve_Perc_GH,Attach_Docs,Completion_Date)
									(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,cast( cast(KPA_Achievement as int) as varchar(50))+'-'+ Range_Level,KPA_Critical ,
									KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,ISNULL(KPA_Target,''),ISNULL(Actual_Achievement,''),ISNULL(KPA_AchievementHOD,0),ISNULL(KPA_AchievementGH,0),
									KM.KPA_Type,ISNULL(KPA_Performace_Measure,''),ISNULL(Achievement_Percentage_Emp,0),ISNULL(Achievement_Percentage_RM,0),ISNULL(Achievement_Percentage_HOD,0),ISNULL(Achievement_Percentage_GH,0),ISNULL(Attach_Docs,''),Completion_Date
									from T0052_HRMS_KPA WITH (NOLOCK) left join 
									T0040_HRMS_KPAType_Master KM WITH (NOLOCK) ON T0052_HRMS_KPA.KPA_Type_ID=KM.KPA_Type_Id
									 cross join T0040_HRMS_RangeMaster as a  WITH (NOLOCK)
									where InitiateId=@initid and Emp_Id=@col1 and  (KPA_Achievement between Range_From and Range_To) and Range_Type=1 and a.Cmp_ID=@cmp_Id)
								END
						End
					else
						begin
							if @kpa_default = 1 --added on 14 Mar 2016
								BEGIN
									insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,KPA_Target,Actual_achievement,KPA_AchievementHOD,KPA_AchievementGH,KPA_Type,KPA_Performace_Measure,Achieve_Perc_EMP,Achieve_Perc_RM,Achieve_Perc_HOD,Achieve_Perc_GH,Attach_Docs,Completion_Date)
									(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,isnull(KPA_Weightage,1),KPA_AchievementEmp,KPA_AchievementRM,ISNULL(KPA_Target,''),ISNULL(Actual_Achievement,''),ISNULL(KPA_AchievementHOD,0),ISNULL(KPA_AchievementGH,0),'','',0,0,0,0,'',Completion_Date
									from T0052_HRMS_KPA WITH (NOLOCK) where InitiateId=@initid and Emp_Id=@col1 )
								END
							ELSE
								BEGIN
									insert into #table7(KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,KPA_Target,Actual_achievement,KPA_AchievementHOD,KPA_AchievementGH,KPA_Type,KPA_Performace_Measure,Achieve_Perc_EMP,Achieve_Perc_RM,Achieve_Perc_HOD,Achieve_Perc_GH,Attach_Docs,Completion_Date)
									(Select distinct KPA_ID,InitiateId,Emp_Id,KPA_Content,KPA_Achievement,KPA_Critical,KPA_Weightage,KPA_AchievementEmp,KPA_AchievementRM,ISNULL(KPA_Target,''),ISNULL(Actual_Achievement,''),ISNULL(KPA_AchievementHOD,0),ISNULL(KPA_AchievementGH,0),
									 KM.KPA_Type,ISNULL(KPA_Performace_Measure,''),ISNULL(Achievement_Percentage_Emp,0),ISNULL(Achievement_Percentage_RM,0),ISNULL(Achievement_Percentage_HOD,0),ISNULL(Achievement_Percentage_GH,0),ISNULL(Attach_Docs,''),Completion_Date
									from T0052_HRMS_KPA WITH (NOLOCK) LEFT JOIN
									T0040_HRMS_KPAType_Master KM WITH (NOLOCK) ON T0052_HRMS_KPA.KPA_Type_ID=KM.KPA_Type_Id
									where InitiateId=@initid and Emp_Id=@col1 )
								END
						End
					--- insert into 7th table----------------------------------(end)
					--- insert into 8th table----------------------------------(start)
					insert into #table8(PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,Att_Score,Att_Achievement,Att_Critical)
					(select distinct A.PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,cast(Att_Score as varchar(50))+'-'+b.Range_Level,Att_Achievement ,Att_Critical 
					 FROM  T0040_HRMS_AttributeMaster as A WITH (NOLOCK) left join
						   T0052_HRMS_AttributeFeedback as F WITH (NOLOCK) on f.PA_ID=a.PA_ID cross join T0040_HRMS_RangeMaster as b WITH (NOLOCK)					   
					 where isnull(PA_EffectiveDate,@cmp_frmdate) = ( 
							 select max(isnull(PA_EffectiveDate,@cmp_frmdate)) from T0040_HRMS_AttributeMaster am WITH (NOLOCK) where cmp_id=@cmp_id
							 and isnull(PA_EffectiveDate,@cmp_frmdate) <= @startdate 
							  and isnull(am.Ref_PAID,am.PA_ID) = isnull(a.Ref_PAID,a.PA_ID))and a.cmp_id=@cmp_id
							  and (@dept_id in (select data from dbo.Split(PA_DeptId,'#')) or a.PA_DeptId is null)and
							A.Cmp_ID=@Cmp_ID and b.Cmp_ID=@Cmp_ID and PA_Type='PA' and Emp_Id=@col1 and f.Initiation_Id=@initid and (Att_Score between Range_From and Range_To) and Range_Type=1)--modified on 2 Mar 2016
					--- insert into 8th table----------------------------------(end)
					--- insert into 9th table----------------------------------(start)
					insert into #table9(PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,Att_Score,Att_Achievement,Att_Critical)
					(select distinct A.PA_ID,PA_Title,PA_Weightage,EmpAtt_ID,Initiation_Id,Emp_Id,cast(Att_Score as varchar(50))+'-'+b.Range_Level,Att_Achievement ,Att_Critical
					 FROM  T0040_HRMS_AttributeMaster as A WITH (NOLOCK) left join
						   T0052_HRMS_AttributeFeedback as F WITH (NOLOCK) on f.PA_ID=a.PA_ID cross join T0040_HRMS_RangeMaster as b WITH (NOLOCK)
					 where isnull(PA_EffectiveDate,@cmp_frmdate) = ( 
							 select max(isnull(PA_EffectiveDate,@cmp_frmdate)) from T0040_HRMS_AttributeMaster am WITH (NOLOCK) where cmp_id=@cmp_id
							 and isnull(PA_EffectiveDate,@cmp_frmdate) <= @startdate 
							  and isnull(am.Ref_PAID,am.PA_ID) = isnull(a.Ref_PAID,a.PA_ID))and a.cmp_id=@cmp_id
							  and (@dept_id in (select data from dbo.Split(PA_DeptId,'#')) or a.PA_DeptId is null)and
					 A.Cmp_ID=@Cmp_ID and b.Cmp_ID=@Cmp_ID and PA_Type='PoA' and Emp_Id=@col1 and f.Initiation_Id=@initid and (Att_Score between Range_From and Range_To) and Range_Type=1)--modified on 2 Mar 2016
					--- insert into 9th table----------------------------------(end)
					--- insert into 10th table----------------------------------(start)
					insert into #table10(skillid,skillname,Initiation_Id,Emp_Id) (select Skill_ID,Skill_Name,@initid,@col1 FROM  T0040_SKILL_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID)
					declare @tskillatt as varchar(800)
					set @tskillatt = ''
					declare @tskillrec as varchar(800)
					set @tskillrec=''
					select @tskillatt= isnull(Attend_LastYear,''),@tskillrec=isnull(Recommended_ThisYear,'') from T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@initid and emp_id=@col1 and T0052_HRMS_AppTraining.Type='skill'
										
					declare cur2 cursor
					for 
						select items from dbo.split2(@tskillatt,'#')
						open cur2
							fetch next from cur2 into @col2
								while @@FETCH_STATUS = 0
									begin				
										update #table10 set attendlast ='Yes'  where  #table10.skillid=@col2 and Initiation_Id=@initid	 	--(Select skillname from T0040_SKILL_MASTER where Skill_ID= @col2)										
										fetch next from cur2 into @col2
									End
						close cur2
					deallocate cur2
					declare cur2 cursor
					for 
						select items from dbo.split2(@tskillrec,'#')
						open cur2
							fetch next from cur2 into @col2
								while @@FETCH_STATUS = 0
									begin							
										update #table10 set recommended =  'Yes' where  #table10.skillid=@col2 and Initiation_Id=@initid		  -- (Select skillname from T0040_SKILL_MASTER where Skill_ID= @col2) 											
										fetch next from cur2 into @col2
									End
						close cur2
					deallocate cur2
					--- insert into 10th table----------------------------------(end)
					--- insert into 11th table----------------------------------(start)
					declare @trainatt as varchar(800)
					set @trainatt=''
					declare @trainrec as varchar(800)
					set @trainrec=''
					insert into #table11(trainid,trainname,Initiation_Id,Emp_Id) (select Training_id,Training_name,@initid,@col1 FROM  T0040_Hrms_Training_master WITH (NOLOCK) where Cmp_ID=@Cmp_ID)
					select @trainatt= Attend_LastYear,@trainrec=Recommended_ThisYear from T0052_HRMS_AppTraining WITH (NOLOCK) where Cmp_ID=@Cmp_ID and InitiateId=@initid and T0052_HRMS_AppTraining.Type='GM'
					
					declare cur2 cursor
					for 
					select items from dbo.split2(@trainatt,'#')
						open cur2
						 fetch next from cur2 into @col4
							while @@FETCH_STATUS = 0
								begin							
									update #table11 set attendlast = 'Yes' where  #table11.trainid=@col4 and Initiation_Id=@initid -- (Select Training_name from T0040_Hrms_Training_master where Training_id= @col4) 	 											
									fetch next from cur2 into @col4
								End
						close cur2
					deallocate cur2
					declare cur2 cursor
					for 
						select items from dbo.split2(@trainrec,'#')
						open cur2
							fetch next from cur2 into @col3
								while @@FETCH_STATUS = 0
									begin							
										update #table11 set recommended =  'Yes' where  #table11.trainid=@col3  and Initiation_Id=@initid  --(Select Training_name from T0040_Hrms_Training_master where Training_id= @col3) 	 											
										fetch next from cur2 into @col3
									End
						close cur2
					deallocate cur2
					--- insert into 11th table----------------------------------(end)
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
					--select @Grd_Id = Grd_ID from T0080_EMP_MASTER where Emp_ID=@col1 and Cmp_ID=@cmp_id
					insert into #table6(Range_ID,Range_From,Range_To,Range_Level,Initiation_Id,Emp_Id)
					(select Range_ID,Range_From,Range_To,Range_Level,@initid,@col1 from T0040_HRMS_RangeMaster WITH (NOLOCK)
					where Range_Type = 2 and 
					@Dept_Id in (select CAST(data as numeric) from dbo.Split(Range_Dept,'#') where data <>'')
					and @Grd_Id in (select CAST(data as numeric) from dbo.Split(Range_Grade,'#') where data <>''))
					
					--- insert into 6th table----------------------------------(end)			
					
						  
					fetch next from cur into @col1
				End
		close cur
deallocate cur		
	DECLARE @SendToHOD as int
	DECLARE @SA_SendToRM as INT
	DECLARE @GH_Id as INT
	DECLARE @emp_id1 as INT
	DECLARE @init_id as INT
	DECLARE @flag as varchar(15)	
	DECLARE other_details CURSOR FOR						
		select DISTINCT ISNULL(i.SendToHOD,0),ISNULL(i.Rm_Required,0),ISNULL(i.GH_Id,0),i.Emp_Id,i.InitiateId from T0050_HRMS_InitiateAppraisal i WITH (NOLOCK)
		inner join @Emp_Cons e1 on i.Emp_Id=e1.Emp_ID
		WHERE   i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date
	OPEN other_details
		fetch next from other_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			while @@fetch_status = 0
				Begin
				--select @SA_SendToRM,@SendToHOD,@GH_Id
					if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='Final')
						BEGIN
							set @flag='Final'
						END
					else if @GH_Id > 0
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='GH')
							set @flag='GH'
						END
					else if @SendToHOD=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='HOD')
							set @flag='HOD'
						END
					else if @SA_SendToRM=1
						BEGIN
							if EXISTS(SELECT InitiateId from T0110_HRMS_Appraisal_OtherDetails WITH (NOLOCK) where Emp_ID=@emp_id1 and InitiateId=@init_id and Approval_Level='RM')
							set @flag='RM'
						END
						
					PRINT @flag		
									
					insert into #Table15
					SELECT hao.Emp_ID,hao.InitiateId,ao.[Action],Justification,tm.TimeFrame,hao.From_Date,hao.To_Date,ISNULL(dm.Desig_Name,''),hao.Is_Applicable					
					from T0030_Appraisal_OtherDetails ao WITH (NOLOCK)
					inner join T0110_HRMS_Appraisal_OtherDetails hao WITH (NOLOCK) on hao.AO_Id=ao.AO_Id and hao.cmp_id=ao.cmp_id and 
					hao.InitiateId=@init_id and hao.Approval_Level=@flag
					inner join T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) on i.InitiateId=hao.InitiateId and i.Emp_Id=hao.Emp_ID
					LEFT join T0040_HRMS_TimeFrame_Master tm WITH (NOLOCK) on tm.TimeFrame_Id=hao.TimeFrame_Id
					LEFT join T0040_DESIGNATION_MASTER dm WITH (NOLOCK) on dm.Desig_ID=hao.Promo_Desig
					where hao.Cmp_ID =@cmp_id and hao.Emp_ID=@emp_id1 and hao.InitiateId=@init_id
						  and i.SA_Startdate >= @From_Date and i.SA_Startdate<=@To_Date 
				fetch next from other_details into @SendToHOD,@SA_SendToRM,@GH_Id,@emp_id1,@init_id
			End
	close other_details	
	deallocate other_details
	
INSERT INTO #table2(EMP_ID, initiateid)
SELECT EMP_ID, initiateid from #table1 T
wHERE NOT EXISTS(SELECT 1 FROM #table2 T1 WHERE T.Emp_id=T1.emp_id AND T.InitiateId=T1.initiateid)	
	
select CompanyName as CMP_NAME,CompanyLogo,emp_id,EmpCode,Emp_Full_Name,Department,Designation,Grade,Qualification,convert(NVARCHAR(11),Dob,103)AS Dob,convert(NVARCHAR(11),Doj,103)AS Doj,Location,InitiateId,convert(NVARCHAR(11),stdate,103)AS stdate,convert(NVARCHAR(11),endate,103)AS endate ,
convert(NVARCHAR(11),todate,103)AS todate ,AppriserComment,convert(NVARCHAR(11),Submittedon,103)AS Submittedon ,
AppriseeComment,convert(NVARCHAR(11),ApprovedOn,103)AS ApprovedOn ,convert(NVARCHAR(11),LastPromodate,103)AS LastPromodate ,
kpascore,PaScore,PoAScore,OverallScore,FinAppraiserComment,GHComment,HodComment,Is_Hod,Achivement_Id,Promo_YesNo,
Promo_desig,convert(NVARCHAR(11),Promo_Wef,103)AS Promo_Wef,JR_YesNo,convert(NVARCHAR(11),JR_From,103)AS JR_From,
convert(NVARCHAR(11),JR_To,103)AS JR_To,Inc_YesNo,Inc_Reason,ReviewerComment,convert(NVARCHAR(11),Appraiser_Date,103)AS Appraiser_Date,
ReportingManager,GroupHead,SA_ApprovedBy,Per_ApprovedBy,Performance_Measure,@Self_Assessment_With_Answer as Self_Assessment_With_Answer  from #table1

select * from #table2
--exec Fill_Self_Assessment @cmp_id=@cmp_id,@init_id=@initid,@emp_id=@col1,@flag='2'

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
select * from #table15

	
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
drop table #table15
	
	
	
--	Select @initid = InitiateId from T0050_HRMS_InitiateAppraisal where InitiateId=@initid
--	select @edeptid= Dept_ID ,@eGrdid=Grd_ID from T0080_EMP_MASTER where Emp_ID=@empid	
--	--get emp details	
--	SELECT	Emp_id,Emp_Full_Name,Alpha_Emp_Code,(Alpha_Emp_Code+'-'+Emp_Full_Name) as Emp_Name,b.Branch_Name,e.Branch_ID,dp.Dept_Name,ds.Desig_Name,c.cmp_logo,c.Cmp_Name,
--			Grd_Name,Date_Of_Birth,Date_Of_Join,(Select top 1 q.Qual_Name from T0090_EMP_QUALIFICATION_DETAIL as eq left join T0040_QUALIFICATION_MASTER as q on q.Qual_Id=eq.Qual_Id  where Emp_ID=@empid  order by Row_ID desc) As Qual_Name
--	FROM	T0080_EMP_MASTER AS e Left Join 
--			T0030_BRANCH_MASTER AS b on b.Branch_ID = e.Branch_ID Left Join
--			T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id = e.Dept_ID Left Join
--			T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = e.Desig_Id Left Join
--			T0040_GRADE_MASTER as g on g.Grd_ID = e.Grd_ID  Left Join
--			T0010_COMPANY_MASTER as c on c.Cmp_Id=e.Cmp_ID
--	WHERE	Emp_ID=@empid
	
	
--	--All initiation details	
--	select * from T0050_HRMS_InitiateAppraisal where Cmp_ID=@Cmp_ID and InitiateId=@initid
	
--	-- get self assessment details
--	create table #tblSAMaster
--(
--	sappid  numeric(18,0)
--   ,scontent varchar(1000)
--)
--insert into #tblSAMaster(sappid,scontent) (select SApparisal_ID,SApparisal_Content FROM  T0040_SelfAppraisal_Master where Cmp_ID=@Cmp_ID and (SDept_Id like '%' +  cast(@edeptid as varchar(50)) + '%' or SDept_Id = '0') and (SType=1 or SType is null))	 

--create table #tblSA
--(
--	sappid  numeric(18,0)
--	,sanswer   varchar(1000)
--	,sweight  numeric(18)
--)

--insert into #tblSA
--(
--	sappid,
--	sanswer,
--	sweight
--)
--(
--	select SAppraisal_ID,T0052_Emp_SelfAppraisal.answer,Weightage FROM  T0052_Emp_SelfAppraisal where Cmp_ID=@Cmp_ID and InitiateId=@initid
--)

--create table #table1
--	(
--		 sappid  numeric(18,0)
--		 ,scontent varchar(1000)
--		 ,sanswer varchar(1000)
--		 ,sweight numeric(18)
--	)
	
--	insert into #table1
--	(
--		sappid  
--		 ,scontent 
--		 ,sanswer 
--		 ,sweight 
--	)
--	(
--		select t1.sappid
--			 ,t1.scontent	
--			 ,t2.sanswer
--			 ,t2.sweight			 
--		from #tblSAMaster t1 left join 
--		   #tblSA as t2 on t2.sappid=t1.sappid
--	)
		

--select *,@initid as initid
--			 ,@empid as empid from #table1

	
--	-- get other assessment details
	
--	create table #OAMaster
--	(
--		oa_id     numeric(18,0)
--	   ,OA_Title  varchar(1000)		
--	)
--	insert into #OAMaster(oa_id,OA_Title)(select oa_id,OA_Title from  T0040_HRMS_OtherAssessment_Master where Cmp_ID=9)


--create table #OAMasterAns
--	(
--		oa_id     numeric(18,0)
--	   ,EOA_Column1  varchar(1000)		
--	   ,EOA_Column2  varchar(1000)	
--	)

--insert into #OAMasterAns(oa_id,EOA_Column1,EOA_Column2)(Select T0050_HRMS_EmpOA_Feedback.OA_ID,EOA_Column1,EOA_Column2 from T0050_HRMS_EmpOA_Feedback where Initiation_Id=41)


--create table #FinalOA
--(
--	oa_id     numeric(18,0)
--	,OA_Title  varchar(1000)
--	,EOA_Column1  varchar(1000)		
--	,EOA_Column2  varchar(1000)		
--)

--insert into #FinalOA
--(
--	oa_id,
--	OA_Title
--	,EOA_Column1
--	,EOA_Column2
--)
--(
--	select 
--		m.oa_id
--		,m.OA_Title
--		,a.EOA_Column1
--		,a.EOA_Column2
--	from #OAMaster m left join 
--	#OAMasterAns a on a.oa_id = m.oa_id
--)

--select *,@initid as initid,@empid as empid from #FinalOA
	
--	--Select OA_Title,EOA_Column1,EOA_Column2 ,@Initiate_Id as initid,@empid as empid
--	--From T0040_HRMS_OtherAssessment_Master 
--	--	left join [T0050_HRMS_EmpOA_Feedback] on [T0050_HRMS_EmpOA_Feedback].OA_ID=T0040_HRMS_OtherAssessment_Master.OA_ID
--	--where Initiation_Id=@Initiate_Id	
	
	
--	-- get Performance feedback
--	create table #tblPer
--	(
--		PerformanceF_ID  numeric(18,0)
--			 ,Performance_Name varchar(50)
--	)
--	insert into #tblPer(PerformanceF_ID,Performance_Name) (select T0040_PerformanceFeedback_Master.PerformanceF_ID
--			,Performance_Name 
--			FROM  T0040_PerformanceFeedback_Master where Cmp_ID=@Cmp_ID)	 

--	create table #tbl
--	(
--		PerformanceF_ID  numeric(18,0)
--		,PerAnswer varchar(100)
--	)
--	insert into #tbl
--	(
--		PerformanceF_ID,
--		PerAnswer
--	)
--	(
--		select PerformanceF_ID,[T0052_HRMS_PerformanceAnswer].answer FROM  [T0052_HRMS_PerformanceAnswer] where Cmp_ID=@Cmp_ID  and InitiateId= @initid
--	)

--	create table #table2
--		(
--			 PerformanceF_ID  numeric(18,0)
--			 ,Performance_Name varchar(50)
--			 ,PerAnswer varchar(100)
--		)
	
--	insert into #table2
--	(
--		PerformanceF_ID
--		,Performance_Name
--		,PerAnswer
--	)
--	(
--		select t1.PerformanceF_ID
--			 ,t1.Performance_Name	
--			 ,t2.PerAnswer
--		from #tblPer t1 left join 
--		   #tbl as t2 on t2.PerformanceF_ID=t1.PerformanceF_ID
--	)
		
----	declare @tab as varchar(8000)
----	set @tab = '	
----		Select 
----		Case When row_number() OVER ( PARTITION BY PerformanceF_ID order by PerformanceF_ID) = 1
----		Then  cast(PerformanceF_ID AS varchar(100))
----		Else '''' End ''PerformanceF_ID'',	
----		Case When row_number() OVER ( PARTITION BY PerformanceF_ID order by PerformanceF_ID) = 1
----		Then  cast(Performance_Name AS varchar(100))
----		Else '''' End ''Performance_Name'',			
----		PerAnswer
----from #table2'
--select *,@initid as initid,@empid as empid from #table2
	
--	--exec (@tab)
	
--	-- get KPA
--	select * from T0052_HRMS_KPA where InitiateId=@initid and Cmp_ID=@Cmp_ID
--	-- get Performance attributes
--	create table #table3
--	(
--		  PA_ID  numeric(18,0)
--		 ,PA_Title varchar(550)
--		 ,PA_Weightage numeric(18)
--		 ,PA_SortNo numeric(18)
--		 ,Att_Score numeric(18)
--		 ,Att_Achievement varchar(1000)
--		 ,Att_Critical varchar(1000)
--	)
	
	
--	insert into #table3(PA_ID,PA_Title,PA_Weightage,PA_SortNo) (select PA_ID,PA_Title,PA_Weightage,PA_SortNo FROM  T0040_HRMS_AttributeMaster where Cmp_ID=@Cmp_ID and PA_Type='PA')
--	update #table3 set Att_Score = (select [T0052_HRMS_AttributeFeedback].Att_Score FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table3.PA_ID and Initiation_Id=@initid),
--					   Att_Achievement = (select [T0052_HRMS_AttributeFeedback].Att_Achievement FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table3.PA_ID and Initiation_Id=@initid),
--						Att_Critical = (select [T0052_HRMS_AttributeFeedback].Att_Critical FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table3.PA_ID and Initiation_Id=@initid)
--	select *,@initid as initid,@empid as empid from #table3
	
--	-- get Potential attributes
--	create table #table4
--	(
--		  PA_ID  numeric(18,0)
--		 ,PA_Title varchar(550)
--		 ,PA_Weightage numeric(18)
--		 ,PA_SortNo numeric(18)
--		 ,Att_Score numeric(18)
--		 ,Att_Achievement varchar(1000)
--		 ,Att_Critical varchar(1000)
--	)
	
	
--	insert into #table4(PA_ID,PA_Title,PA_Weightage,PA_SortNo) (select PA_ID,PA_Title,PA_Weightage,PA_SortNo FROM  T0040_HRMS_AttributeMaster where Cmp_ID=@Cmp_ID and PA_Type='PoA')
--	update #table4 set Att_Score = (select [T0052_HRMS_AttributeFeedback].Att_Score FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table4.PA_ID and Initiation_Id=@initid),
--					   Att_Achievement = (select [T0052_HRMS_AttributeFeedback].Att_Achievement FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table4.PA_ID and Initiation_Id=@initid),
--						Att_Critical = (select [T0052_HRMS_AttributeFeedback].Att_Critical FROM  [T0052_HRMS_AttributeFeedback] where Cmp_ID=@Cmp_ID and [T0052_HRMS_AttributeFeedback].PA_ID= #table4.PA_ID and Initiation_Id=@initid)
--	select *,@initid as initid,@empid as empid from #table4
	
--	--bind Overall score
--	select Range_ID,Range_From,Range_To,Range_Level,@initid as initid,@empid as empid from T0040_HRMS_RangeMaster where Range_Type = 2 and Cmp_ID=@Cmp_ID and Range_Dept like '%#' + cast(@edeptid as varchar) + '#%'  and Range_Grade like '%#'+ cast(@eGrdid as varchar) +'#%' order by Range_From desc
	
	
	
--	--All Training needs idebntification
--	--skill
--	 create table #table5
--	(
--		 skillid numeric(18,0)
--		,skillname varchar(100)
--		,attendlast  varchar(100)
--		,recommended  varchar(100)
		
--	)
	
--	insert into #table5(skillid,skillname) (select Skill_ID,Skill_Name FROM  T0040_SKILL_MASTER where Cmp_ID=@Cmp_ID)
	
--	declare @tskillatt as varchar(800)
--	declare @tskillrec as varchar(800)
--	declare @col2 as numeric
--	select @tskillatt= Attend_LastYear,@tskillrec=Recommended_ThisYear from T0052_HRMS_AppTraining where Cmp_ID=@Cmp_ID and InitiateId=@initid and T0052_HRMS_AppTraining.Type='skill'
	
	
--	declare cur2 cursor
--		for 
--			select items from dbo.split2(@tskillatt,'#')
--			open cur2
--				fetch next from cur2 into @col2
--					while @@FETCH_STATUS = 0
--						begin							
--							update #table5 set attendlast ='Yes'  where  #table5.skillid=@col2	 	--(Select skillname from T0040_SKILL_MASTER where Skill_ID= @col2)										
--							fetch next from cur2 into @col2
--						End
--					close cur2
--				deallocate cur2
				
--	declare cur2 cursor
--		for 
--			select items from dbo.split2(@tskillrec,'#')
--			open cur2
--				fetch next from cur2 into @col2
--					while @@FETCH_STATUS = 0
--						begin							
--							update #table5 set recommended =  'Yes' where  #table5.skillid=@col2	  -- (Select skillname from T0040_SKILL_MASTER where Skill_ID= @col2) 											
--							fetch next from cur2 into @col2
--						End
--					close cur2
--				deallocate cur2
	
--	select *,@initid as initid,@empid as empid from #table5
--	--training - GM
--	create table #table6
--	(
--		 trainid numeric(18,0)
--		,trainname varchar(100)
--		,attendlast  varchar(100)
--		,recommended  varchar(100)
		
--	)
	
--	insert into #table6(trainid,trainname) (select Training_id,Training_name FROM  T0040_Hrms_Training_master where Cmp_ID=@Cmp_ID)
	
--	declare @trainatt as varchar(800)
--	declare @trainrec as varchar(800)
--	declare @col4 as numeric
--		declare @col3 as numeric
--	select @trainatt= Attend_LastYear,@trainrec=Recommended_ThisYear from T0052_HRMS_AppTraining where Cmp_ID=@Cmp_ID and InitiateId=@initid and T0052_HRMS_AppTraining.Type='GM'
		
--	declare cur2 cursor
--		for 
--			select items from dbo.split2(@trainatt,'#')
--			open cur2
--				fetch next from cur2 into @col4
--					while @@FETCH_STATUS = 0
--						begin							
--							update #table6 set attendlast = 'Yes' where  #table6.trainid=@col4 -- (Select Training_name from T0040_Hrms_Training_master where Training_id= @col4) 	 											
--							fetch next from cur2 into @col4
--						End
--					close cur2
--				deallocate cur2
				
				
--	declare cur2 cursor
--		for 
--			select items from dbo.split2(@trainrec,'#')
--			open cur2
--				fetch next from cur2 into @col3
--					while @@FETCH_STATUS = 0
--						begin							
--							update #table6 set recommended =  'Yes' where  #table6.trainid=@col3 --(Select Training_name from T0040_Hrms_Training_master where Training_id= @col3) 	 											
--							fetch next from cur2 into @col3
--						End
--					close cur2
--				deallocate cur2
	
--	select *,@initid as initid,@empid as empid from #table6
	
--	--training - Supportive
--		select TrainingAreas,@initid as initid,@empid as empid from T0052_HRMS_AppTrainingDetail where InitiateId=@initid and Cmp_ID=@Cmp_ID and T0052_HRMS_AppTrainingDetail.Type='Support'
--		select Attend_LastYear,Recommended_ThisYear,@initid as initid,@empid as empid from T0052_HRMS_AppTrainDetail where InitiateId=@initid and Cmp_ID=@Cmp_ID and T0052_HRMS_AppTrainDetail.Type='Support'
	
--	--training - Function
--		select TrainingAreas,@initid as initid,@empid as empid from T0052_HRMS_AppTrainingDetail where InitiateId=@initid and Cmp_ID=@Cmp_ID and T0052_HRMS_AppTrainingDetail.Type='Function'
--		select Attend_LastYear,Recommended_ThisYear,OtherTraining,@initid as initid,@empid as empid from T0052_HRMS_AppTrainDetail where InitiateId=@initid and Cmp_ID=@Cmp_ID and T0052_HRMS_AppTrainDetail.Type='Function'
		
		
--	drop table #tblSAMaster
--	drop table #tblSA
--	drop table #OAMaster
--	drop table #OAMasterAns
--	drop table #FinalOA
--	drop table #table1
--	drop table #tblPer
--	drop table #tbl
--	drop table #table2
--	drop table #table3
--	drop table #table4
--	drop table #table5
--	drop table #table6
END


