

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_ApprisalNew_Summary]
	     @cmp_id    as numeric(18,0)
		--,@deptId    as numeric(18,0)=null
		,@deptId    as varchar(max)='' --Mukti(16062017)
		,@emp_id    as numeric(18,0)=null
		,@frmdate   as datetime 
		,@enddate   as datetime = getdate--'2014-04-08' 
		,@Constraint as	varchar(max)
		,@dyQuery   varchar(max)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

declare @sno	   as numeric(18,0)	
declare @col1      as numeric(18,0)

Set @sno =null
if @enddate is null
	begin
		set @enddate = GETDATE()
	end
if @deptId IS NULL  --Mukti(17062017)
	BEGIN
		set @deptId = ''
	END
Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			if @frmdate is null
				begin
					Insert Into @Emp_Cons
					select emp_id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id 
				End
			Else
				begin
					Insert Into @Emp_Cons
					select emp_id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate
				End
		End	
CREATE TABLE #FinalTable --final table to display all data
(
	 Emp_id				numeric(18,0) 
	,Department			varchar(100)
	,deptid				numeric(18,0)
	,EmployeeCode		varchar(100)
	,EmployeeName		varchar(100)
	,branchid			numeric(18,0)
	,branchname			varchar(100)
	,Designation		varchar(100)
	,desigid			numeric(18,0)
	,catid				numeric(18,0)
	,typeid				numeric(18,0)
	,Grade				varchar(100)
	,grd_id       		numeric(18,0)
	,DoJ				date
	,ReportingManager	varchar(100)
	,RM_Score			numeric(18,2)  
	,HOD				varchar(100)
	,HOD_Score			numeric(18,2)  
	,GH					varchar(100)
	,GH_Score			numeric(18,2)  
	,Final_Score		numeric(18,2)  
	,MD_Score			numeric(18,2)  
	,Achievement		varchar(100) 
	,dob				date
	,qualification		varchar(500)
	,monthlyctc			numeric(18,2)
	,CTC				numeric(18,2)
	,promotionDesig		varchar(50)
	,promotiondate		VARCHAR(20)
	,incrementcur		varchar(50)
	,jobrot				varchar(50)
	,lastCTC			numeric(18,0)
	,lastdesi			varchar(50)
	,lastinc			date
	,lastpromo			date
	,joinCTC			numeric(18,2)
	,joindesi			varchar(50)
	,expOrg				varchar(50)
	,totexp		        varchar(50)
	,appriseecomm		varchar(1000)
	,HodComm			varchar(1000)--added on 15 Mar 2016
	,GHcomm				varchar(1000)
	,Reviewercomm		varchar(1000)
	,Inc_Reason			varchar(500)--added on 08 May 2017
)
--select @sno=Srno from #FinalTable

declare @lastdesi numeric(18,0)
declare @curdesi numeric(18,0)		
declare @last_ctc as numeric(18,0)
declare @last_desi as varchar(50)
declare @cnt as int 
declare @totexp as varchar(50)
declare @totexpyr as numeric(18,0)
declare @totexpmon as numeric(18,0)
declare @totexpday as numeric(18,0)
declare @dojexpyr as numeric(18,0)
declare @dojexpmon as numeric(18,0)
declare @dojexpday as numeric(18,0)
declare @col2 as numeric(18,0)
declare @dojexporg as varchar(50)
DECLARE @max_Increment_Effective_Date  DATETIME--added on 18/12/2017

Set @cnt  = 0 
Set  @totexpyr =0
Set  @totexpmon =0
Set  @totexpday =0



		--if @deptId<>0
		if @deptId <> ''
			begin
				declare cur cursor
				for 
					select E.* from @Emp_Cons E inner join 
					  T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = E.Emp_ID 
					  where  SA_Startdate between @frmdate and @enddate
					open cur
					fetch next from cur into @col1
						while @@FETCH_STATUS = 0
						begin				
							--update emp basic details							
							insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,grd_id,Grade,DoJ,ReportingManager,dob,qualification)
										(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,e.Date_Of_Birth,
										(select STUFF((select distinct ',' + q.qual_name 
											from t0040_qualification_master as q WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq WITH (NOLOCK)
											on eq.Qual_ID=q.Qual_ID
											where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
											for XML Path (''),Type).value('.','NVARCHAR(MAX)')
											,1,1,'')qualification)as qualification
										 from T0080_EMP_MASTER E WITH (NOLOCK) left join T0040_DEPARTMENT_MASTER Dept WITH (NOLOCK) ON
												Dept.dept_id=e.Dept_ID  left join T0040_GRADE_MASTER G WITH (NOLOCK) on 
												G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S WITH (NOLOCK) on
												s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh WITH (NOLOCK) on 
												gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br WITH (NOLOCK) on
												br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct WITH (NOLOCK) on 
												ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty WITH (NOLOCK) on
												ty.Type_ID = e.Type_ID 
										  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 
										  --and e.Dept_ID=@deptId --commented by Mukti(17062017)
										  and ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										  and e.Date_Of_Join < @frmdate)	
										  
							--update emp initiation details					  
							--update #FinalTable --modified on 28 mar 2015
							--set		  promotionDesig=(select d.Desig_Name from T0050_HRMS_InitiateAppraisal as i left join T0040_DESIGNATION_MASTER as d on d.desig_id=i.Promo_Desig where i.Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate )
							--		,promotiondate  =(select promotiondate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,incrementcur = (select case when Inc_YesNo =1 then 'Yes' else 'No' end  from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)								
							--		,jobrot = (select case when JR_YesNo  =1 then 'Yes' else 'No' end  from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)									
							--		,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate )
							--		,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,Designation = (select (d.Desig_Name) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate ))
							--		,Desigid = (select max(i.Desig_Id) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,Grade = (select (g.Grd_Name) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))
							--		,grd_id = (select max(i.Grd_ID) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,deptid= (select max(i.Dept_ID) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,Department = (select (dp.Dept_Name) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))
							--		,appriseecomm = (select appraisercomment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,GHcomm = (select GH_Comment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,Reviewercomm = (select ReviewerComment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--Where Emp_id = @col1 		
																	
							update #FinalTable 
							set promotionDesig=(select d.Desig_Name from T0050_HRMS_InitiateAppraisal as i WITH (NOLOCK) left join T0040_DESIGNATION_MASTER as d WITH (NOLOCK) on d.desig_id=i.Promo_Desig where i.Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate )
							    ,promotiondate = s.Promo_Wef
							    ,incrementcur = s.Inc_YesNo
							    ,jobrot = s.JR_YesNo
							    ,RM_Score = s.Overall_Score_RM
							    ,HOD_Score = s.Overall_Score_HOD
							    ,GH_Score = s.Overall_Score_GH
							    ,MD_Score = s.Overall_Score_MD
							    ,Final_Score=s.Overall_Score
							    ,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							    ,appriseecomm = s.AppraiserComment
							    ,GHcomm = s.GH_Comment
							    ,HodComm = s.HOD_Comment
							    ,Reviewercomm = s.ReviewerComment
							    ,Inc_Reason = s.Inc_Reason
							    ,HOD=s.HOD_Name
							    ,GH=s.GH_Name
							From (select Promo_Wef, case when Inc_YesNo =1 then 'Yes' else 'No' end Inc_YesNo,case when JR_YesNo  =1 then 'Yes' else 'No' end JR_YesNo,
								  Overall_Score,appraisercomment,GH_Comment,HOD_Comment,ReviewerComment,Inc_Reason,Overall_Score_RM,Overall_Score_HOD,Overall_Score_GH,Overall_Score_MD,
								  EGH.Emp_Full_Name as GH_Name,EHOD.Emp_Full_Name AS HOD_Name
								 from T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) LEFT JOIN
								 T0080_EMP_MASTER EGH WITH (NOLOCK) on EGH.Emp_ID = IA.GH_Id LEFT JOIN
								 T0080_EMP_MASTER EHOD WITH (NOLOCK) on EHOD.Emp_ID = IA.HOD_Id
								 where IA.Cmp_ID=@cmp_id and IA.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)s
							Where Emp_id = @col1 
							
							update #FinalTable 
							set  Designation = s.Desig_Name
									,Desigid = s.Desig_Id
									,Grade = s.Grd_Name
									,grd_id = s.Grd_ID
									,deptid= s.Dept_ID
									,Department = s.Dept_Name
							From (select d.Desig_Name,i.Desig_Id,g.Grd_Name,i.Grd_ID,i.Dept_ID,dp.Dept_Name
								 from T0095_INCREMENT as i WITH (NOLOCK) left join 
									 T0040_DESIGNATION_MASTER as d WITH (NOLOCK) on d.Desig_ID=i.Desig_Id left JOIN
									 T0040_GRADE_MASTER as g WITH (NOLOCK) on g.Grd_ID=i.Grd_ID left JOIN
									 T0040_DEPARTMENT_MASTER as dp WITH (NOLOCK) on dp.Dept_Id=i.Dept_ID
								 where Emp_ID=@col1 --and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))s
										and I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 WITH (NOLOCK) where i2.Emp_ID = I.Emp_ID
										and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WITH (NOLOCK) WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= @frmdate )))s
							Where Emp_id = @col1 
							-- get prev ctc ,desig,promo,inc dates if 
							 
							 select @cnt=count(ctc) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type<>'Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=@col1)
								
								SELECT  @max_Increment_Effective_Date  = MAX(Increment_Effective_Date)
								FROM  T0095_INCREMENT WITH (NOLOCK)
								WHERE Emp_ID = @col1 AND Increment_Effective_Date <= @frmdate
								
								SELECT @last_ctc=isnull((ctc),0),@last_desi = isnull((DG.Desig_Name),'')
								FROM  T0095_INCREMENT I WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
											FROM T0095_INCREMENT WITH (NOLOCK)
											INNER JOIN (
															SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
															FROM T0095_INCREMENT WITH (NOLOCK)
															WHERE Emp_ID = @col1 AND Increment_Effective_Date <= @max_Increment_Effective_Date
															GROUP BY Emp_ID
														)I3 ON i3.Increment_Effective_Date = T0095_INCREMENT.Increment_Effective_Date
											WHERE T0095_INCREMENT.Emp_ID = @col1
											GROUP BY T0095_INCREMENT.Emp_ID
											)I1 ON i.Emp_ID = I1.Emp_ID
								LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id
								--if @cnt <>0
								--	begin
								--		--select @last_ctc=(ctc) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=@col1)
								--		SELECT @last_ctc=(ctc) 
								--		FROM T0095_INCREMENT  i  
								--		WHERE Increment_Type<>'Joining' and Emp_ID=@col1 
								--		and  i.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where  emp_id = @col1 and Increment_Type<>'Joining' and Increment_Effective_Date  < (select max(Increment_Effective_Date)from T0095_INCREMENT where emp_id =@col1 and Increment_Effective_Date <= @frmdate))

								--	End
								--Else
								--	begin
								--		select @last_ctc=(ctc) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1)
								--	End
							set @cnt=0
							
							--if exists(select (ds.Desig_Name) from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=i.emp_id))
							--		begin
							--			--select @last_desi=ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type<>'Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=@col1)
							--			select @last_desi=ds.Desig_Name from T0095_INCREMENT as i  left join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id WHERE Increment_Type<>'Joining' and Emp_ID=@col1 and  i.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where  emp_id = @col1 and Increment_Type<>'Joining' and Increment_Effective_Date  < (select max(Increment_Effective_Date)from T0095_INCREMENT where emp_id =@col1 and Increment_Effective_Date <= @frmdate))
							--		End
							--	Else
							--		begin
							--			select @last_desi =ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1)
							--		End
							-------------
							
							
							
								SELECT 
							 @dojexporg= ( cast(floor(experience / 365) as varchar) + '.' +
										   cast(floor(experience % 365 / 30) as varchar) + ' Years ' )
							FROM (select *, datediff(DAY, Date_Of_Join, getdate()) as experience
							FROM T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@col1 and Cmp_ID=@cmp_id) t
							
							---total exp----						
							
							--get prev experience--
							set @dojexpyr = 0
							set @dojexpmon =0
							set @dojexpday = 0
							set @totexpyr = 0
							set @totexpmon=0
							set @totexpday=0
							
							SELECT 
								 @dojexpyr=  floor(experience / 365) ,
								 @dojexpmon= floor(experience % 365 / 30),
								 @dojexpday= floor(experience % 30)
								FROM (select *, datediff(DAY, Date_Of_Join, GETDATE()) as experience
								FROM T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@col1 and Cmp_ID=@cmp_id) t							
								
																					
							
							declare cur1 cursor
							for 
								select row_id from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Cmp_ID=@cmp_id and Emp_ID=@col1
							open cur1
								fetch next from cur1 into @col2
								while @@FETCH_STATUS = 0
									begin
										SELECT 
											@totexpyr= @totexpyr +  floor(experience / 365) ,
											@totexpmon= @totexpmon +  floor(experience % 365 / 30),
											@totexpday= @totexpday +  floor(experience % 30)
											FROM (select *, datediff(DAY, St_Date, End_Date) as experience
										FROM T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Row_ID=@col2 and Cmp_ID=@cmp_id) t
										fetch next from cur1 into @col2
									End
							close cur1
							deallocate cur1
							
							
							--set @totexp = cast((@totexpyr + @dojexpyr) as varchar(50)) + ' Years ' +
							--			  cast((@totexpmon + @dojexpmon) as varchar(50)) + ' Months ' +	
							--			  cast((@totexpday + @dojexpday) as varchar(50)) + ' days '
							
							set @totexp = cast((@totexpyr + @dojexpyr) as varchar(50)) + '.' +
										  cast((@totexpmon + @dojexpmon) as varchar(50)) +' Years '
							----------------
							---------
							
							--update emp inc details	
							
							UPDATE #FinalTable 
							SET lastCTC = @last_ctc*12
							   ,lastdesi = @last_desi
							   ,lastinc = Intbl.Increment_Effective_Date
							   ,lastpromo = Intbl.Increment_Effective_Date
							   ,expOrg=@dojexporg
							   ,totexp=@totexp
							FROM (
									SELECT I.*
									FROM  T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN (SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
												FROM T0095_INCREMENT WITH (NOLOCK)
												INNER JOIN (
																SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
																FROM T0095_INCREMENT WITH (NOLOCK)
																WHERE Emp_ID = @col1 AND Increment_Effective_Date <= @max_Increment_Effective_Date
																GROUP BY Emp_ID
															)I3 ON i3.Increment_Effective_Date = T0095_INCREMENT.Increment_Effective_Date
												WHERE T0095_INCREMENT.Emp_ID = @col1
												GROUP BY T0095_INCREMENT.Emp_ID
												)I1 ON i.Emp_ID = I1.Emp_ID
									LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id
								 )Intbl
							WHERE #FinalTable.Emp_id = @col1
							
							UPDATE #FinalTable 
							SET joinCTC = Intbl.CTC *12
							   ,joindesi = Intbl. Desig_Name
							FROM (
									SELECT I.CTC,DG.Desig_Name
									FROM T0095_INCREMENT I WITH (NOLOCK)
									LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID= I.Desig_Id
									WHERE Emp_ID = @col1 AND Increment_Type ='Joining'
								 )Intbl
							WHERE #FinalTable.Emp_id = @col1
							
							UPDATE #FinalTable 
							SET CTC = Intbl.CTC *12
							   ,monthlyctc= Intbl.CTC
							FROM (
									SELECT I.CTC,DG.Desig_Name
									FROM T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN (
												 SELECT MAX(Increment_ID)Increment_ID,Emp_ID
												 FROM T0095_INCREMENT WITH (NOLOCK)
												 WHERE Increment_Effective_Date = @max_Increment_Effective_Date AND Emp_ID = @col1
												 GROUP BY Emp_ID
										)I1 ON I1.Increment_ID = I.Increment_ID 
									LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID= I.Desig_Id
									WHERE I.Emp_ID = @col1 
								 )Intbl
							WHERE #FinalTable.Emp_id = @col1
							
							--update #FinalTable 
							--set    
							--	  lastCTC = @last_ctc*12 --(select ctc from T0095_INCREMENT where Cmp_ID=@cmp_id  and Increment_Type='Increment' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Increment' and Emp_ID=@col1) )
							--      ,lastdesi = @last_desi  --(select ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Transfer' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Transfer' and Emp_ID=@col1) )							      
							--      --,lastinc  = (select Increment_Effective_Date from T0095_INCREMENT where Cmp_ID=@cmp_id  and Increment_Type='Increment' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Increment' and Emp_ID=@col1) )
							--      --,lastpromo = (select Increment_Effective_Date from T0095_INCREMENT as i   where i.Cmp_ID=@cmp_id  and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1) )							      
							--      ,lastinc  = (select Increment_Effective_Date from T0095_INCREMENT where Increment_Type='Increment' and Emp_ID=@col1 and Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where  emp_id = @col1 and Increment_Type='Increment' and  Increment_Effective_Date <= @frmdate))
							--      ,lastpromo = (select Increment_Effective_Date from T0095_INCREMENT where (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1 and Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where  emp_id = @col1 and (Increment_Type='Transfer' or Increment_Type='Increment') and  Increment_Effective_Date <= @frmdate))
							--      ,joinCTC= (select ctc*12 from T0095_INCREMENT where Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1) )
							--      ,joindesi = (select ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1) )							      
							--      ,CTC = (select ctc*12 from T0095_INCREMENT where Cmp_ID=@cmp_id   and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id  and Emp_ID=@col1) )
							--      ,monthlyctc = (select ctc from T0095_INCREMENT where Cmp_ID=@cmp_id   and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id  and Emp_ID=@col1) )
							--      ,expOrg=@dojexporg
							--      ,totexp=@totexp
							--Where Emp_id = @col1	
							fetch next from cur into @col1
						End
					close cur
					deallocate cur
			End
		else
			begin
			print 'm'
				declare cur cursor
				for 
					--select emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id  	and emp_id = isnull(@emp_id,emp_id)
					select E.* from @Emp_Cons	E inner join 
					  T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on I.Emp_Id = E.Emp_ID 
					  where  SA_Startdate between @frmdate and @enddate
					open cur
					fetch next from cur into @col1
						while @@FETCH_STATUS = 0
						begin						
						--update emp basic details							
							insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,grd_id,Grade,DoJ,ReportingManager,dob,qualification)
										(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,e.Date_Of_Birth,
											(select STUFF((select distinct ',' + q.qual_name 
											 from t0040_qualification_master as q WITH (NOLOCK) inner join  T0090_EMP_QUALIFICATION_DETAIL as eq WITH (NOLOCK)
											 on eq.Qual_ID=q.Qual_ID
											 where eq.Qual_ID=q.Qual_ID and eq.Emp_ID=e.emp_id
											 for XML Path (''),Type).value('.','NVARCHAR(MAX)')
											 ,1,1,'')qualification)as qualification
										 from T0080_EMP_MASTER E WITH (NOLOCK) left join T0040_DEPARTMENT_MASTER Dept WITH (NOLOCK) ON
												Dept.dept_id=e.Dept_ID  left join T0040_GRADE_MASTER G WITH (NOLOCK) on 
												G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S WITH (NOLOCK) on
												s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh WITH (NOLOCK) on 
												gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br WITH (NOLOCK) on
												br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct WITH (NOLOCK) on 
												ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty WITH (NOLOCK) on
												ty.Type_ID = e.Type_ID 
										  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 and e.Date_Of_Join < @frmdate)	
										  
							--update emp initiation details					  
							--update #FinalTable  --modified on 28 mar 2015
							--set		 promotionDesig=(select d.Desig_Name from T0050_HRMS_InitiateAppraisal as i left join T0040_DESIGNATION_MASTER as d on d.desig_id=i.Promo_Desig where i.Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate )
							--		,promotiondate  =(select promotiondate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,incrementcur = (select case when Inc_YesNo =1 then 'Yes' else 'No' end  from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1  and SA_Startdate between @frmdate and @enddate)								
							--		,jobrot = (select case when JR_YesNo  =1 then 'Yes' else 'No' end  from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)									
							--		,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,Designation = (select (d.Desig_Name) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate ))
							--		,Desigid = (select max(i.Desig_Id) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,Grade = (select (g.Grd_Name) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))
							--		,grd_id = (select max(i.Grd_ID) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,deptid= (select max(i.Dept_ID) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate)	)								
							--		,Department = (select (dp.Dept_Name) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))
							--		--,Designation = (select (d.Desig_Name) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 ) )
							--		--,Desigid = (select max(i.Desig_Id) from T0095_INCREMENT as i left join T0040_DESIGNATION_MASTER as d on d.Desig_ID=i.Desig_Id where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 )	 )								
							--		--,Grade = (select (g.Grd_Name) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 ))
							--		--,grd_id = (select max(i.Grd_ID) from T0095_INCREMENT as i left join T0040_GRADE_MASTER as g on g.Grd_ID=i.Grd_ID where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 )	)								
							--		--,deptid= (select max(i.Dept_ID) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 )	)								
							--		--,Department = (select (dp.Dept_Name) from T0095_INCREMENT as i left join T0040_DEPARTMENT_MASTER as dp on dp.Dept_Id=i.Dept_ID where Emp_ID=@col1 and i.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=@col1 ) )
							--		,appriseecomm = (select appraisercomment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,GHcomm = (select GH_Comment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,Reviewercomm = (select ReviewerComment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							--		,HodComm = (select HOD_Comment from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate) --15 Mar 2016
							--Where Emp_id = @col1								
											print 'kkk'					
							update #FinalTable 
							set promotionDesig=S.Desig_Name
							--(select top 1 d.Desig_Name from T0050_HRMS_InitiateAppraisal as i left join T0040_DESIGNATION_MASTER as d on d.desig_id=i.Promo_Desig where i.Cmp_ID=@cmp_id and Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate )
							    ,promotiondate =case when YEAR(s.From_Date)=1900 then '' else CONVERT(VARCHAR(15),s.From_Date,103) end
							    ,incrementcur = s.Inc_YesNo
							    ,jobrot = s.JR_YesNo
							    ,RM_Score = s.Overall_Score_RM
							    ,HOD_Score = s.Overall_Score_HOD
							    ,GH_Score = s.Overall_Score_GH
							    ,MD_Score = s.Overall_Score_MD
							    ,Final_Score=s.Overall_Score
							    ,Achievement = (select top 1 r.Range_Level from T0050_HRMS_InitiateAppraisal i WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)
							    ,appriseecomm = s.AppraiserComment
							    ,GHcomm = s.GH_Comment
							    ,HodComm = s.HOD_Comment
							    ,Reviewercomm = s.ReviewerComment
							    ,Inc_Reason = s.Inc_Reason
							    ,HOD=s.HOD_Name
							    ,GH=s.GH_Name
							From (select top 1 Promo_Wef, case when Inc_YesNo =1 then 'Yes' else 'No' end Inc_YesNo,
								  case when JR_YesNo  =1 then 'Yes' else 'No' end JR_YesNo,
								  Overall_Score,appraisercomment,GH_Comment,HOD_Comment,ReviewerComment,Inc_Reason,DM.Desig_Name,HAO.From_Date,
								  HI.Overall_Score_HOD,HI.Overall_Score_GH,HI.Overall_Score_MD,HI.Overall_Score_RM,EGH.Emp_Full_Name as GH_Name,EHOD.Emp_Full_Name AS HOD_Name
								 from T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK)
								 left join T0110_HRMS_Appraisal_OtherDetails HAO WITH (NOLOCK) on HI.InitiateId=HAO.InitiateId and HAO.AO_Id=5 and HAO.Is_Applicable=1
								 left join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID=HAO.Promo_Desig AND HAO.Cmp_ID=DM.Cmp_ID
								 LEFT JOIN T0080_EMP_MASTER EGH WITH (NOLOCK) on EGH.Emp_ID = HI.GH_Id 
								 LEFT JOIN T0080_EMP_MASTER EHOD WITH (NOLOCK) on EHOD.Emp_ID = HI.HOD_Id
								 where HI.Cmp_ID=@cmp_id and HI.Emp_Id=@col1 and SA_Startdate between @frmdate and @enddate)s
							Where Emp_id = @col1 
							
							update #FinalTable 
							set  Designation = s.Desig_Name
									,Desigid = s.Desig_Id
									,Grade = s.Grd_Name
									,grd_id = s.Grd_ID
									,deptid= s.Dept_ID
									,Department = s.Dept_Name
							From (select d.Desig_Name,i.Desig_Id,g.Grd_Name,i.Grd_ID,i.Dept_ID,dp.Dept_Name
								 from T0095_INCREMENT as i WITH (NOLOCK) left join 
									 T0040_DESIGNATION_MASTER as d WITH (NOLOCK) on d.Desig_ID=i.Desig_Id left JOIN
									 T0040_GRADE_MASTER as g WITH (NOLOCK) on g.Grd_ID=i.Grd_ID left JOIN
									 T0040_DEPARTMENT_MASTER as dp WITH (NOLOCK) on dp.Dept_Id=i.Dept_ID
								 where Emp_ID=@col1 --and i.Increment_Effective_Date=(select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID=@col1 and Increment_Effective_Date <= @frmdate))s
										and I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 WITH (NOLOCK) where i2.Emp_ID = I.Emp_ID
										and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WITH (NOLOCK) WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= @frmdate )))s
							Where Emp_id = @col1 
							
							-- get prev ctc ,desig,promo,inc dates if 
							
							 select @cnt=count(ctc) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type<>'Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and   Increment_Type<>'Joining' and Emp_ID=@col1)
								
								if @cnt =0
									begin
										select @last_ctc=(ctc) from T0095_INCREMENT as i WITH (NOLOCK) WHERE Increment_Type<>'Joining' and Emp_ID=@col1 and  i.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where  emp_id = @col1 and Increment_Type<>'Joining' and Increment_Effective_Date  < (select max(Increment_Effective_Date)from T0095_INCREMENT WITH (NOLOCK) where emp_id =@col1 and Increment_Effective_Date <= @frmdate))
										--select @last_ctc=(ctc) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID)-1 from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining'  and Emp_ID=@col1)
									End
								Else
									begin
										select @last_ctc=(ctc) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Joining'  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1)
									End
							set @cnt=0
							--select @cnt =count(ds.Desig_Name) from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Transfer' or Increment_Type='Increment' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Transfer' and Emp_ID=@col1)
							--	if @cnt =0
							if exists(select (ds.Desig_Name) from T0095_INCREMENT as i WITH (NOLOCK) left join  T0040_DESIGNATION_MASTER as ds WITH (NOLOCK) on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type<>'Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=i.emp_id))
									begin
										select @last_desi=ds.Desig_Name from T0095_INCREMENT as i WITH (NOLOCK)  left join T0040_DESIGNATION_MASTER as ds WITH (NOLOCK) on ds.Desig_ID = i.Desig_Id WHERE Increment_Type<>'Joining' and Emp_ID=@col1 and  i.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where  emp_id = @col1 and Increment_Type<>'Joining' and Increment_Effective_Date  < (select max(Increment_Effective_Date)from T0095_INCREMENT  WITH (NOLOCK) where emp_id =@col1 and Increment_Effective_Date <= @frmdate))
										--select @last_desi=ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type<>'Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type<>'Joining' and Emp_ID=@col1)
									End
								Else
									begin
										select @last_desi =ds.Desig_Name from T0095_INCREMENT as i WITH (NOLOCK) left join  T0040_DESIGNATION_MASTER as ds WITH (NOLOCK) on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1)
									End
							-------------
							
							--update org experience
							--SELECT 
							-- @dojexporg= ( cast(floor(experience / 365) as varchar) + ' years ' +
							--			   cast(floor(experience % 365 / 30) as varchar) + ' months ' +
							--               cast(experience % 30 as varchar) + ' days' )
							--FROM (select *, datediff(DAY, Date_Of_Join, getdate()) as experience
							--FROM T0080_EMP_MASTER where Emp_ID=@col1 and Cmp_ID=@cmp_id) t
							
							SELECT 
							 @dojexporg= ( cast(floor(experience / 365) as varchar) + '.' +
										   cast(floor(experience % 365 / 30) as varchar) + ' Years ' )
							FROM (select *, datediff(DAY, Date_Of_Join, getdate()) as experience
							FROM T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@col1 and Cmp_ID=@cmp_id) t
							
							---total exp----						
							
							--get prev experience
							
							set @dojexpyr = 0
							set @dojexpmon =0
							set @dojexpday = 0
							set @totexpyr = 0
							set @totexpmon=0
							set @totexpday=0
							
							SELECT 
								 @dojexpyr=  floor(experience / 365) ,
								 @dojexpmon= floor(experience % 365 / 30),
								 @dojexpday= floor(experience % 30)
								FROM (select *, datediff(DAY, Date_Of_Join, GETDATE()) as experience
								FROM T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@col1 and Cmp_ID=@cmp_id) t
							
							declare cur1 cursor
							for 
								select row_id from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Cmp_ID=@cmp_id and Emp_ID=@col1
							open cur1
								fetch next from cur1 into @col2
								while @@FETCH_STATUS = 0
									begin
										SELECT 
											@totexpyr= @totexpyr +  floor(experience / 365) ,
											@totexpmon= @totexpmon +  floor(experience % 365 / 30),
											@totexpday= @totexpday +  floor(experience % 30)
											FROM (select *, datediff(DAY, St_Date, End_Date) as experience
										FROM T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Row_ID=@col2 and Cmp_ID=@cmp_id) t
										fetch next from cur1 into @col2
									End
							close cur1
							deallocate cur1
							
							
							--set @totexp = cast((@totexpyr + @dojexpyr) as varchar(50)) + ' Years ' +
							--			  cast((@totexpmon + @dojexpmon) as varchar(50)) + ' Months ' +	
							--			  cast((@totexpday + @dojexpday) as varchar(50)) + ' days '
							
							set @totexp = cast((@totexpyr + @dojexpyr) as varchar(50)) + '.' +
										  cast((@totexpmon + @dojexpmon) as varchar(50)) +' Years '
							
							----------------
							---------
							
							--update emp inc details		
							update #FinalTable 
							set    
								  lastCTC = @last_ctc*12 --(select ctc from T0095_INCREMENT where Cmp_ID=@cmp_id  and Increment_Type='Increment' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Increment' and Emp_ID=@col1) )
							      ,lastdesi = @last_desi  --(select ds.Desig_Name from T0095_INCREMENT as i  left join  T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Transfer' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_Type='Transfer' and Emp_ID=@col1) )							      
							      ,lastinc  = (select Increment_Effective_Date from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id  and Increment_Type='Increment' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Increment' and Emp_ID=@col1) )
							      ,lastpromo = (select Increment_Effective_Date from T0095_INCREMENT as i WITH (NOLOCK)  where i.Cmp_ID=@cmp_id and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and (Increment_Type='Transfer' or Increment_Type='Increment') and Emp_ID=@col1) )							      
							      ,joinCTC= (select ctc*12 from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1) )
							      ,joindesi = (select ds.Desig_Name from T0095_INCREMENT as i WITH (NOLOCK)  left join  T0040_DESIGNATION_MASTER as ds WITH (NOLOCK) on ds.Desig_ID = i.Desig_Id  where i.Cmp_ID=@cmp_id  and Increment_Type='Joining' and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_Type='Joining' and Emp_ID=@col1) )							      
							      ,CTC = (select ctc*12 from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id  and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Emp_ID=@col1) )
							      ,monthlyctc = (select ctc from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id   and Emp_ID=@col1 and Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id  and Emp_ID=@col1) )
							      ,expOrg=@dojexporg
							      ,totexp=@totexp
							Where Emp_id = @col1	
							  fetch next from cur into @col1
						End
					close cur
					deallocate cur
			End

--select  ROW_NUMBER() OVER (ORDER BY emp_id) AS Srno,Department,EmployeeCode,EmployeeName,Designation,Grade,DoJ,ReportingManager,ApprisalGroupHead as 'Group Head',ApprisalstartDate,ApprisalEndDate,SelfAssessmentApprovedOn,SelfAssessmentApprovedby,FinalReviewBy as 'Final Review By',Score,Achievement from #FinalTable 

declare @query varchar(max)

if @dyQuery <> ''
	begin
		set @query='select  ROW_NUMBER() OVER (ORDER BY Department,branchname,EmployeeCode) AS Srno,Department,branchname as Branch,EmployeeCode,EmployeeName,Designation,Grade,convert(NVARCHAR(11),DoJ,103)AS DOJ,convert(NVARCHAR(11),dob,103) as ''Date of Birth'',qualification as Qualification,expOrg as ''Experience in Current Organization'',totexp as ''Total Experience'',monthlyctc as ''Monthly CTC'',CTC as ''Annually CTC'',lastCTC as ''Last CTC'',lastdesi as ''Last Designation'',lastinc as ''Last Increment'',lastpromo as ''Last Promotion'',joinCTC as ''CTC at Joining'',joindesi as ''Designation at Joining'',ReportingManager,RM_Score,HOD,HOD_Score,GH,GH_Score,Final_Score,MD_Score,Achievement as Rating,promotiondate as ''Current Year Promotion'',promotionDesig as ''Current Promotion Designation'',incrementcur as ''Increment'',Inc_Reason as ''Reason'',jobrot as ''Job Rotation'',appriseecomm as ''Appraiser Comments'',HODcomm as ''HOD Comments'',GHcomm as ''GH Comments'',Reviewercomm as ''Reviewer Comments''  from #FinalTable 	'
		--exec (@query + ' Where ' + @dyquery + ' Order By Srno,Department,branchname,EmployeeCode') 
		exec (@query + ' Where ' +  @dyquery + ' Order By Srno,Department,branchname,EmployeeCode') 
		print (@query + ' Where ' + @dyquery ) 
	End
else
	begin
		select  ROW_NUMBER() OVER (ORDER BY Department,branchname,EmployeeCode) AS Srno,isnull(Department,'')Department,branchname as Branch,EmployeeCode,EmployeeName,Designation,Grade,convert(NVARCHAR(11),DoJ,103)AS DOJ,convert(NVARCHAR(11),dob,103) as 'Date of Birth',qualification as Qualification,expOrg as 'Experience in Current Organization',totexp as 'Total Experience',monthlyctc as 'Monthly CTC' ,CTC as 'Annually CTC',lastCTC as 'Last CTC',lastdesi as 'Last Designation',lastinc as 'Last Increment',lastpromo as 'Last Promotion',joinCTC as 'CTC at Joining',joindesi as 'Designation at Joining',ReportingManager,RM_Score,HOD,HOD_Score,GH,GH_Score,Final_Score,MD_Score,Achievement as Rating,promotiondate as 'Current Year Promotion',promotionDesig as 'Current Promotion Designation',incrementcur as 'Increment',Inc_Reason as 'Reason',jobrot as 'Job Rotation',appriseecomm as 'Appraiser Comments',HodComm as 'HOD Comments',GHcomm as 'GH Comments',Reviewercomm as 'Reviewer Comments'  from #FinalTable 	
		order by Srno,Department,branchname,EmployeeCode
	End

drop table #FinalTable
	
	
	
--commented on 25 apr 2014	
--CREATE TABLE #FinalTable --final table to display all data
--(
--	 --Srno			numeric(18,0)
--	Emp_id         numeric(18,0) 
--	,Department		varchar(100)
--	,deptid			numeric(18,0)
--	,EmployeeCode	varchar(100)
--	,EmployeeName	varchar(100)
--	,branchid      numeric(18,0)
--	,branchname   varchar(100)
--	,Designation	varchar(100)
--	,desigid			numeric(18,0)
--	,catid           numeric(18,0)
--	,typeid			numeric(18,0)
--	,Grade			varchar(100)
--	,grd_id       	numeric(18,0)
--	,DoJ			date
--	,ReportingManager   varchar(100)
--	,ApprisalGroupHead  varchar(100)
--	,ApprisalstartDate  date
--	,ApprisalEndDate    date
--	,SelfAssessmentApprovedOn date
--	,SelfAssessmentApprovedby varchar(100)
--	,PerformanceAssessmentApprovedOn date
--	,FinalReviewBy   varchar(100)
--	,Score           numeric(18,2)  
--	,Achievement    varchar(100) 
--)
----select @sno=Srno from #FinalTable

--if @frmdate is null
--	begin	
--		if @deptId<>0
--			begin
--				declare cur cursor
--				for 
--					--select emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and emp_id =( isnull(@emp_id,emp_id))
--					select * from @Emp_Cons
--					open cur
--					fetch next from cur into @col1
--						while @@FETCH_STATUS = 0
--						begin							
--						--set @sno = ISNULL(@sno,0)+1					
--							insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,desigid,Designation,grd_id,Grade,DoJ,ReportingManager,ApprisalGroupHead)
--							(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,desi.Desig_ID,desi.Desig_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,gh.Emp_Full_Name 
--							 from T0080_EMP_MASTER E left join T0040_DEPARTMENT_MASTER Dept ON
--									Dept.dept_id=e.Dept_ID  left join T0040_DESIGNATION_MASTER desi on 
--									desi.Desig_ID = e.Desig_Id  left join T0040_GRADE_MASTER G on 
--									G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S on
--									s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh on 
--									gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br on
--									br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct on 
--									ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty on
--									ty.Type_ID = e.Type_ID
--							  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 and e.Dept_ID=@deptId)											  
							  
--						    update #FinalTable 
--							set		 ApprisalstartDate=(select SA_Startdate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1  )
--									,ApprisalEndDate  =(select SA_Enddate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,SelfAssessmentApprovedOn = (select SA_ApprovedDate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,SelfAssessmentApprovedby = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.SA_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									,PerformanceAssessmentApprovedOn = (select Appraiser_Date from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,FinalReviewBy  = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.Per_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--							Where Emp_id = @col1	
--							fetch next from cur into @col1
--						End
--					close cur
--					deallocate cur
--			End
--		else
--			begin
--				declare cur cursor
--				for 
--					--select emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id  	and emp_id = isnull(@emp_id,emp_id)
--					select * from @Emp_Cons	
--					open cur
--					fetch next from cur into @col1
--						while @@FETCH_STATUS = 0
--						begin						
--						--set @sno = ISNULL(@sno,0)+1	
--							insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,desigid,Designation,grd_id,Grade,DoJ,ReportingManager,ApprisalGroupHead)
--							(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,desi.Desig_ID,desi.Desig_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,gh.Emp_Full_Name 
--							 from T0080_EMP_MASTER E left join T0040_DEPARTMENT_MASTER Dept ON
--									Dept.dept_id=e.Dept_ID  left join T0040_DESIGNATION_MASTER desi on 
--									desi.Desig_ID = e.Desig_Id  left join T0040_GRADE_MASTER G on 
--									G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S on
--									s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh on 
--									gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br on
--									br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct on 
--									ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty on
--									ty.Type_ID = e.Type_ID
--							  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 and e.Dept_ID=@deptId)				
--							 update #FinalTable 
--									set		 ApprisalstartDate=(select SA_Startdate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1  )
--											,ApprisalEndDate  =(select SA_Enddate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,SelfAssessmentApprovedOn = (select SA_ApprovedDate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,SelfAssessmentApprovedby = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.SA_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--											,PerformanceAssessmentApprovedOn = (select Appraiser_Date from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,FinalReviewBy  = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.Per_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--											,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									Where Emp_id = @col1	
--							  fetch next from cur into @col1
--						End
--					close cur
--					deallocate cur
--			End
--	End
--Else
--	begin
--		if @deptId<>0
--			Begin
--				declare cur cursor
--				for 
--					--select emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate 	and emp_id = isnull(@emp_id,emp_id)	
--					select * from @Emp_Cons
--					open cur
--					fetch next from cur into @col1
--						while @@FETCH_STATUS = 0
--						begin	
--						--set @sno = ISNULL(@sno,0)+1					
--						insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,desigid,Designation,grd_id,Grade,DoJ,ReportingManager,ApprisalGroupHead)
--							(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,desi.Desig_ID,desi.Desig_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,gh.Emp_Full_Name 
--							 from T0080_EMP_MASTER E left join T0040_DEPARTMENT_MASTER Dept ON
--									Dept.dept_id=e.Dept_ID  left join T0040_DESIGNATION_MASTER desi on 
--									desi.Desig_ID = e.Desig_Id  left join T0040_GRADE_MASTER G on 
--									G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S on
--									s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh on 
--									gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br on
--									br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct on 
--									ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty on
--									ty.Type_ID = e.Type_ID
--							  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 and e.Dept_ID=@deptId)								  
							  
--						    update #FinalTable 
--							set		 ApprisalstartDate=(select SA_Startdate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1  )
--									,ApprisalEndDate  =(select SA_Enddate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,SelfAssessmentApprovedOn = (select SA_ApprovedDate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,SelfAssessmentApprovedby = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.SA_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									,PerformanceAssessmentApprovedOn = (select Appraiser_Date from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,FinalReviewBy  = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.Per_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--									,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--							Where Emp_id = @col1	
--							fetch next from cur into @col1
--						End
--					close cur
--					deallocate cur
--			End
--		Else
--			begin
--				declare cur cursor
--				for 
--					--select emp_id from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate and emp_id = isnull(@emp_id,emp_id)  	 	
--					select * from @Emp_Cons
--					open cur
--					fetch next from cur into @col1
--						while @@FETCH_STATUS = 0
--						begin										
--						--set @sno = ISNULL(@sno,0)+1	
--							insert into #FinalTable (Emp_id,branchid,branchname,deptid,typeid,Department,catid,EmployeeCode,EmployeeName,desigid,Designation,grd_id,Grade,DoJ,ReportingManager,ApprisalGroupHead)
--							(select e.Emp_ID,br.Branch_ID,br.Branch_Name,dept.Dept_Id,ty.Type_ID, dept.Dept_Name,ct.Cat_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,desi.Desig_ID,desi.Desig_Name,g.Grd_ID,g.Grd_Name,E.Date_Of_Join,S.Emp_Full_Name,gh.Emp_Full_Name 
--							 from T0080_EMP_MASTER E left join T0040_DEPARTMENT_MASTER Dept ON
--									Dept.dept_id=e.Dept_ID  left join T0040_DESIGNATION_MASTER desi on 
--									desi.Desig_ID = e.Desig_Id  left join T0040_GRADE_MASTER G on 
--									G.Grd_ID = e.Grd_ID left join T0080_EMP_MASTER as S on
--									s.Emp_ID= e.Emp_Superior left join T0080_EMP_MASTER as Gh on 
--									gh.Alpha_Emp_Code = e.Old_Ref_No left join T0030_BRANCH_MASTER as br on
--									br.Branch_ID = e.Branch_ID left join T0030_CATEGORY_MASTER as ct on 
--									ct.Cat_ID = e.Cat_ID left join t0040_type_master as ty on
--									ty.Type_ID = e.Type_ID
--							  where E.cmp_id=@cmp_id and e.Emp_ID=@col1 and e.Dept_ID=@deptId)					
--							 update #FinalTable 
--									set		 ApprisalstartDate=(select SA_Startdate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1  )
--											,ApprisalEndDate  =(select SA_Enddate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,SelfAssessmentApprovedOn = (select SA_ApprovedDate from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,SelfAssessmentApprovedby = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.SA_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--											,PerformanceAssessmentApprovedOn = (select Appraiser_Date from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,FinalReviewBy  = (select e.Emp_Full_Name from T0050_HRMS_InitiateAppraisal i left join T0080_EMP_MASTER e on e.Emp_ID=i.Per_ApprovedBy where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--											,Score    = (select Overall_Score from T0050_HRMS_InitiateAppraisal where Cmp_ID=@cmp_id and Emp_Id=@col1 )
--											,Achievement = (select r.Range_Level from T0050_HRMS_InitiateAppraisal i left join T0040_HRMS_RangeMaster r on r.Range_ID=i.Achivement_Id where i.Cmp_ID=@cmp_id and i.Emp_Id=@col1 )
--									Where Emp_id = @col1	
--							  fetch next from cur into @col1
--						End
--					close cur
--					deallocate cur
--			End
--	End
	
----select  ROW_NUMBER() OVER (ORDER BY emp_id) AS Srno,Department,EmployeeCode,EmployeeName,Designation,Grade,DoJ,ReportingManager,ApprisalGroupHead as 'Group Head',ApprisalstartDate,ApprisalEndDate,SelfAssessmentApprovedOn,SelfAssessmentApprovedby,FinalReviewBy as 'Final Review By',Score,Achievement from #FinalTable 

--declare @query varchar(max)

--if @dyQuery <> ''
--begin
--set @query='select  ROW_NUMBER() OVER (ORDER BY emp_id) AS Srno,Department,EmployeeCode,EmployeeName,Designation,Grade,DoJ,ReportingManager,ApprisalGroupHead as ''Group Head'',ApprisalstartDate,ApprisalEndDate,SelfAssessmentApprovedOn,SelfAssessmentApprovedby,FinalReviewBy as ''Final Review By'',Score,Achievement from #FinalTable'
--exec (@query + ' Where ' + @dyquery ) 
--print (@query + ' Where ' + @dyquery )
--End
--else
--select  ROW_NUMBER() OVER (ORDER BY emp_id) AS Srno,Department,EmployeeCode,EmployeeName,Designation,Grade,DoJ,ReportingManager,ApprisalGroupHead as 'Group Head',ApprisalstartDate,ApprisalEndDate,SelfAssessmentApprovedOn,SelfAssessmentApprovedby,FinalReviewBy as 'Final Review By',Score,Achievement from #FinalTable 	

--drop table #FinalTable
END
