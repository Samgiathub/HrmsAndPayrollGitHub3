


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Rpt_SelfApprisal_Form]
		 @cmp_id			as numeric(18,0)
		,@From_Date			as datetime --varchar (12)=''
		,@To_Date			as datetime--varchar (12)=''
		,@branch_Id			as numeric(18,0)=0
		,@Cat_ID			as numeric = 0	
		,@Grd_Id			as numeric(18,0)=0
		,@Type_Id			as numeric(18,0)=0
		,@Dept_Id			as numeric(18,0)=0
		,@Desig_Id			as numeric(18,0)=0
		,@Emp_Id			as numeric(18,0)=0
		,@Constraint		as varchar(max)=''
	    	
		
		
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
    
    
    declare @initid as numeric(18)
    
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
	
	CREATE TABLE #table1
(
	 CompanyName		varchar(100)
	,Emp_id				numeric(18,0)
	,EmpCode			varchar(100)
	,Emp_Full_Name		varchar(500)
	,Department			varchar(100)
	,Designation		varchar(100)
	,Grade				varchar(100)
	,Qualification		varchar(500)
	,Dob				datetime
	,Doj				datetime
	,Location			varchar(100)
	,InitiateId			numeric(18,0)
	,stdate				datetime
	,endate				datetime
	,todate				datetime
	,AppriserComment	nvarchar(500)
	,Submittedon		datetime
	,AppriseeComment	nvarchar(500)
	,ApprovedOn			datetime
)

CREATE TABLE #table2
(
	SApparisal_ID		numeric(18,0)
	,Cmp_ID				numeric(18,0)
	,SDept_Id			NUMERIC(18,2)
	,SApparisal_Content nvarchar(1000)
	,SAppraisal_Sort	numeric(18,0)
	,SIsMandatory		int
	,SWeight			numeric(18,0)
	,initiateid			numeric(18,0)
	,emp_id				numeric(18,0)
)

CREATE TABLE #table3
(
	SelfApp_Id			NUMERIC(18,0)
	,SAppraisal_ID		NUMERIC(18,0)
	,Answer				nVARCHAR(2000)
	,Weightage			NUMERIC(18,2)
	,initiateid			NUMERIC(18,0)
	,Emp_Score			NUMERIC(18,2) --27 Mar 2017
	,EmpComments		nVARCHAR(500)  --27 Mar 2017
	,Manager_Score		NUMERIC(18,2) --27 Mar 2017
	,Manager_Comments	nVARCHAR(500)  --27 Mar 2017
)

CREATE TABLE #table4
(
	OA_Id			numeric(18,0)
	,OA_Title		nvarchar(1000)
	,OA_Sort		numeric(18,0)
	,EOA_Column1	nvarchar(50)
	,EOA_Column2	nvarchar(50)
	,Emp_OA_ID		numeric(18,0)
	,Emp_id			numeric(18,0)
	,initiateid		numeric(18,0)
)

---added on 2 Mar 2016
declare @cmp_frmdate datetime
select @cmp_frmdate = From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id
declare @startdate datetime
---added on 2 Mar 2016 end
DECLARE @cnt  INTEGER
SET @cnt = 1

--for 1st data
	declare cur cursor
		for 
		   select Emp_ID from @Emp_Cons
		open cur
		fetch next from cur into @col1
		while @@FETCH_STATUS = 0
			Begin	
				SET @initid = null	
				
				insert into #table1 (CompanyName,Emp_id,Emp_Full_Name,EmpCode,Department,Grade,Dob,Doj,Location,Designation,Qualification)
				(select Cmp_Name,e.Emp_ID,Emp_Full_Name,Alpha_Emp_Code,d.Dept_Name,Grd_Name,e.Date_Of_Birth,e.Date_Of_Join,e.Loc_name,dg.Desig_Name,
				(select STUFF((select distinct ',' + q.qual_name 
					from t0040_qualification_master as q  WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq  WITH (NOLOCK)
					on eq.Qual_ID=q.Qual_ID
					where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
					for XML Path (''),Type).value('.','NVARCHAR(MAX)')
					,1,1,'')qualification)as qualification
				 from T0010_COMPANY_MASTER as c WITH (NOLOCK) left join V0080_Employee_Details as e 
				 on e.Emp_ID = @col1 left join T0095_INCREMENT as i WITH (NOLOCK)
				 on i.Emp_ID=@col1 	left join T0040_DEPARTMENT_MASTER as d WITH (NOLOCK)
				 on d.Dept_Id = i.Dept_ID left join T0040_GRADE_MASTER as g WITH (NOLOCK)
				 on g.Grd_ID =i.Grd_ID left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
				 on dg.Desig_ID = i.Desig_Id
				 where c.Cmp_Id=@cmp_id and e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col1))
				
				 --print @col1
				SET @cnt =1	--added on 21/11/2017  
			
				 WHILE @cnt <=  (select count(1) FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime) )
					BEGIN
					SET @initid = null		
										
					
						SELECT @initid = T.InitiateId
						FROM  (
								SELECT InitiateId,ROW_NUMBER() OVER (ORDER BY SA_Startdate)  as rownum
								FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
								WHERE emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
							 )T
						WHERE T.rownum = @cnt
					
				
						UPDATE #table1
						SET  InitiateId = k.InitiateId
						     ,stdate = k.SA_Startdate
						     ,endate = k.SA_Enddate
						     ,todate = @To_Date
						     ,AppriseeComment = k.SA_EmpComments
						     ,AppriserComment = k.SA_AppComments
						     ,Submittedon = k.SA_SubmissionDate
						     ,ApprovedOn = k.SA_ApprovedDate
						FROM (
									SELECT InitiateId,SA_Startdate,SA_Enddate,SA_EmpComments,SA_AppComments,SA_SubmissionDate,SA_ApprovedDate 
									FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
									WHERE Emp_Id=@col1 AND InitiateId = @initid
							  )K 
						WHERE #table1.Emp_id = @col1   
								
				--select @initid=initiateid from T0050_HRMS_InitiateAppraisal where emp_id=@col1 and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime) 	
				--for 2nd data	    
				--select @emp_id=emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and  SA_Startdate between cast(@frmdate AS datetime) and cast(@enddate as datetime)     
				--select @dept_id=dept_id from t0080_emp_master where emp_id=@col1
			      
					select  @dept_id=ISNULL(IE.Dept_ID,0),@desig_id=ISNULL(IE.Desig_Id,0),@branch_id=ISNULL(IE.Branch_ID,0)
					from T0080_EMP_MASTER em WITH (NOLOCK)
					INNER JOIN	
					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID
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
			
			      select @startdate=SA_Startdate from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@col1 and InitiateId = @initid --and  SA_Startdate between cast(@From_Date AS datetime) and cast(@To_Date as datetime)--added on 2 Mar 2016
			      	
			      IF @initid is not NULL	
					BEGIN  		  
					  insert into #table2(SApparisal_ID,Cmp_ID,SDept_Id,SApparisal_Content,SAppraisal_Sort,SIsMandatory,SWeight,initiateid,emp_id)
					  (SELECT SApparisal_ID,Cmp_ID,@dept_id,isnull(SApparisal_Content,'')as SApparisal_Content,isnull(SAppraisal_Sort,0)as SAppraisal_Sort,isnull(SIsMandatory,0)as SIsMandatory,isnull(SWeight,0)as SWeight,@initid,@col1 
					   from T0040_SelfAppraisal_Master h WITH (NOLOCK) where h.cmp_id=@cmp_id and 
						((@dept_id IS NULL or ISNULL(@dept_id,0) in (select data from dbo.Split(isnull(sdept_id,0),'#')) or isnull(SDept_Id,'')='') 
						and (@branch_id is null or ISNULL(@branch_id,0) in (select data from dbo.Split(isnull(SBranch_Id,0),'#')) or isnull(SBranch_Id,'')='') 
						and (@desig_id is NULL or ISNULL(@desig_id,0) in (select data from dbo.Split(isnull(SCateg_Id,0),'#')) or isnull(SCateg_Id,'')='')) 
						and isnull(SType,1)=1 and h.Effective_Date =(select max(Effective_Date) from T0040_SelfAppraisal_Master am WITH (NOLOCK) where cmp_id=@cmp_id
						and Effective_Date <= @startdate and isnull(am.Ref_SID,am.SApparisal_ID) = isnull(h.Ref_SID,h.SApparisal_ID))) 
				 	
						
						--for 3rd data	--Old Code --
							IF EXISTS(SELECT 1 from T0052_Emp_SelfAppraisal as o WITH (NOLOCK))
							begin 
								insert into #table3(SelfApp_Id,SAppraisal_ID,Answer,Weightage,initiateid,Emp_Score,EmpComments,Manager_Score,Manager_Comments)
								(Select SelfApp_Id,SAppraisal_ID,isnull(Answer,'') as Answer,isnull(Weightage,0) as Weightage,initiateid,isnull(Emp_Score,0) Emp_Score,isnull(Comments,''),isnull(Manager_Score,0),isnull(Manager_comments,'')--added score comments on 27 mar 2017
								 From T0052_Emp_SelfAppraisal WITH (NOLOCK)
								 where initiateid=@initid)
						 End
						 Else --added by Deepali- 11-07-2023
						 begin
						 	insert into #table3(SelfApp_Id,SAppraisal_ID,Answer,Weightage,initiateid,Emp_Score,EmpComments,Manager_Score,Manager_Comments)
							(Select KPA_Id,KPA_Type_ID,isnull(KPA_Content,'') as KPA_Content,isnull(KPA_Weightage,0) as Weightage,initiateid,
							isnull(KPA_AchievementEmp,0) KPA_AchievementEMP,isnull(Actual_Achievement,''),isnull(KPA_AchievementRM,0),isnull(RM_Comments,'')
							 From T0052_HRMS_KPA
							 where initiateid=@initid)
						 End

					END
				--(SELECT SApparisal_ID,Cmp_ID,@dept_id,isnull(SApparisal_Content,'')as SApparisal_Content,isnull(SAppraisal_Sort,0)as SAppraisal_Sort,isnull(SIsMandatory,0)as SIsMandatory,isnull(SWeight,0)as SWeight,@initid,@col1 
				--From T0040_SelfAppraisal_Master where Cmp_ID=@cmp_id  and (SDept_Id like '%' + cast (@dept_id as varchar(18)) + '%' or SDept_Id= '0') and (Stype is null or stype=1))
				
					
						-- for 4th table				
						IF EXISTS(SELECT 1 from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)
						 LEFT JOIN T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id WHERE O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )	
							 BEGIN 
								INSERT INTO #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid)
								(SELECT o.OA_Id,ISNULL(o.OA_Title,'') as OA_Title,ISNULL(o.OA_Sort,0) as OA_Sort,isnull(F.EOA_Column1,0) as EOA_Column1,isnull(f.EOA_Column2,0) as EOA_Column2,f.Emp_OA_ID,Emp_Id,@initid from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK)
								LEFT JOIN T0050_HRMS_EmpOA_Feedback as F WITH (NOLOCK) on F.OA_ID= O.OA_Id WHERE O.Cmp_ID=@cmp_id and f.Initiation_Id=@initid )
							 End
						Else	
							BEGIN 	
								INSERT INTO #table4(OA_Id,OA_Title,OA_Sort,EOA_Column1,EOA_Column2,Emp_OA_ID,Emp_id,initiateid)
								(SELECT o.OA_Id,isnull(o.OA_Title,'') AS OA_Title,isnull(o.OA_Sort,0) as OA_Sort,'' as EOA_Column1,'' as EOA_Column2,0 as Emp_OA_ID,@col1 as emp_id,@initid as Initiation_Id from T0040_HRMS_OtherAssessment_Master as o WITH (NOLOCK) where O.Cmp_ID=@cmp_id) 
							End	
					
						SET @cnt = @cnt +1
					END--added on 21/11/2017 
				fetch next from cur into @col1
			End
		close cur
		deallocate cur	

	select CompanyName as CMP_NAME,Emp_id,Emp_Full_Name,EmpCode,Department,Grade,convert(NVARCHAR(11),Dob,103)AS Dob,convert(NVARCHAR(11),DoJ,103)AS DOJ,Location,Designation,Qualification,InitiateId,convert(NVARCHAR(11),stdate,103)stdate,convert(NVARCHAR(11),endate,103) endate  ,todate ,AppriseeComment ,AppriserComment,convert(NVARCHAR(11),Submittedon,103)AS Submittedon,convert(NVARCHAR(11),ApprovedOn,103)AS ApprovedOn  from #table1
	select * from #table2
	select * from #table3
	select * from #table4
	
drop table #table1
drop table #table2
drop table #table3
drop table #table4
END

