



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_ApprisalNew_Summary_Format3]
	     @cmp_id    as numeric(18,0)
		,@deptId    as numeric(18,0)=null
		,@emp_id    as numeric(18,0)=null
		,@frmdate   as datetime 
		,@enddate   as datetime = getdate--'2014-04-08' 
		,@Constraint	varchar(max)
		,@dyQuery   varchar(max)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @sno	   as numeric(18,0)	
declare @col1      as numeric(18,0)

Set @sno =null
if @enddate is null
	begin
		set @enddate = GETDATE()
	end

Declare @Emp_Cons Table
	(
		Emp_ID	numeric
		--,initiateid	 numeric
	)	
	set @Constraint =''
if @Constraint <>''
	begin
		Insert Into @Emp_Cons(Emp_ID)
			--SELECT  cast(data  as numeric),InitiateId FROM dbo.Split (@Constraint,'#')  inner JOIN
			--T0050_HRMS_InitiateAppraisal  on Emp_Id= cast(data  as numeric)
		 --WHERE Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate
		 select CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
	end	
ELSE
	BEGIN
			Insert Into @Emp_Cons
			SELECT emp_id FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate
	END
	--select * from @Emp_Cons
CREATE table #FinalTable --final table to display all data
(
	 Emp_id				numeric(18,0) 
	,init_id			numeric(18,0)
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
	,Final_Score			numeric(18,2)  
	,Achievement		varchar(100) 
	,dob				date
	--,qualification		varchar(500)
	,monthlyctc			numeric(18,2)
	,CTC				numeric(18,2)
	,promotionDesig		varchar(50)
	,promotionGrade		varchar(50)
	,promotiondate		date
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
	,HodComm			varchar(1000)
	,GHcomm				varchar(1000)
	,Reviewercomm		varchar(1000)
	,finaleval			varchar(20)
	,duration			varchar(50)
)
--select * from @Emp_Cons
INSERT INTO #FinalTable(Emp_id,init_id,Department,deptid,EmployeeCode,EmployeeName,branchid,branchname,
						Designation,desigid,typeid,catid,Grade,grd_id,DoJ,ReportingManager,
						GH_Score,Final_Score,Achievement,dob,monthlyctc,CTC,appriseecomm,HodComm,GHcomm,Reviewercomm,HOD_Score,GH,
						expOrg,promotionDesig,promotionGrade,promotiondate,incrementcur,jobrot,HOD,RM_Score,totexp,
						finaleval,duration)
SELECT  distinct E.Emp_ID,IA.initiateid,DP.Dept_Name,IE.Dept_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,IE.Branch_ID,BM.Branch_Name,
		DG.Desig_Name,IE.Desig_Id,IE.Type_ID,IE.Cat_ID,G.Grd_Name,IE.Grd_ID,EM.Date_Of_Join,Manager_name,
		IA.Overall_Score_GH,IA.Overall_Score,RG.Range_Level,EM.Date_Of_Birth,IE.CTC,(Ie.CTC*12)Annual_CTC,IA.AppraiserComment,IA.HOD_Comment,IA.GH_Comment,IA.ReviewerComment,
		IA.HOD_Score,EGH.Emp_Full_Name,cast(FLOOR((datediff(DAY, em.Date_Of_Join, GETDATE())/365)) as VARCHAR)+ ' Years ' + cast(FLOOR((datediff(DAY, em.Date_Of_Join, GETDATE())%365/30)) as VARCHAR)+ ' Month ' +cast(FLOOR((datediff(DAY, em.Date_Of_Join, GETDATE())%30)) as varchar) +' Days',
		IDG.Desig_Name,isnull(IGRD.Grd_Name,''),IA.Promo_Wef,IA.Inc_YesNo,IA.JR_YesNo,EHOD.Emp_Full_Name,IA.RM_Score,
		EXD.experienceyear,case when isnull(IA.Final_Evaluation,1) =0 then 'Interim' else 'Final' end,
		dbo.F_GET_MONTH_NAME(ISNULL(IA.Duration_FromMonth,1))+'-'+dbo.F_GET_MONTH_NAME(ISNULL(IA.Duration_ToMonth,1))
FROM  @Emp_Cons E INNER  JOIN
		T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_ID INNER JOIN
		T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) on ia.Emp_Id = e.Emp_Id INNER JOIN
        (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Cat_ID,
				I.CTC
                FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
                        (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
                         FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
                                (
                                        SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
                                        FROM T0095_INCREMENT WITH (NOLOCK)
                                        WHERE CMP_ID = @cmp_id  and Increment_Effective_Date <= @frmdate
                                        GROUP BY EMP_ID
                                ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
                         WHERE CMP_ID = @cmp_id
                         GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
                where I.Cmp_ID= @cmp_id 
        )IE on IE.Emp_ID = EM.Emp_ID LEFT JOIN
        T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id LEFT JOIN
        T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = IE.Branch_ID LEFT JOIN
        T0040_DEPARTMENT_MASTER DP WITH (NOLOCK) on DP.Dept_Id = IE.Dept_ID LEFT JOIN
        T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = IE.Grd_ID Left JOIN
        (SELECT R.EMP_ID,R.R_Emp_ID,(ERE.Alpha_Emp_Code+'-'+ERE.Emp_Full_Name)Manager_name
                FROM T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) INNER JOIN
                        (SELECT MAX(Row_ID) AS Row_ID,T0090_EMP_REPORTING_DETAIL.EMP_ID
                         FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Inner JOIN
                                (
                                        SELECT MAX(Effect_Date) AS Effect_Date , EMP_ID 
                                        FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
                                        WHERE CMP_ID = @cmp_id  and Effect_Date <= @frmdate
                                        GROUP BY EMP_ID
                                ) inqre on inqre.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
                         WHERE CMP_ID = @cmp_id
                         GROUP BY T0090_EMP_REPORTING_DETAIL.EMP_ID) QRE ON R.EMP_ID = QRE.EMP_ID  AND R.Row_ID = QRE.Row_ID
                Inner join T0080_EMP_MASTER ERE WITH (NOLOCK) on ERE.Emp_ID=r.R_Emp_ID
                where R.Cmp_ID= @cmp_id 
        )RE on RE.Emp_ID = EM.Emp_ID LEFT JOIN
        T0040_HRMS_RangeMaster RG WITH (NOLOCK) on RG.Range_ID = IA.Achivement_Id	LEFT JOIN
        T0040_DESIGNATION_MASTER IDG WITH (NOLOCK) on IDG.Desig_ID= ia.Promo_Desig left JOIN
        T0080_EMP_MASTER EHOD WITH (NOLOCK) on EHOD.Emp_ID = IA.HOD_Id LEFT JOIN
        (
			SELECT exp1.emp_id,(cast(FLOOR(exp1.expeyr/365) as VARCHAR) +' Year'+ cast(FLOOR(exp1.expeyr%365/30) as VARCHAR)+ ' Month ' + cast(floor(exp1.expeyr/30) as varchar) +'Days')experienceyear
			FROM	(select (DATEDIFF(YEAR,St_Date,End_Date))expeyr,Emp_ID
					from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
					where cmp_id=@cmp_id
					GROUP by Emp_ID,St_Date,End_Date)exp1
			
        )EXD on exd.Emp_ID=e.Emp_ID	left JOIN
        T0040_GRADE_MASTER IGRD WITH (NOLOCK) on IGRD.Grd_ID= ia.Promo_Grade LEFT JOIN
        T0080_EMP_MASTER EGH WITH (NOLOCK) on EGH.Emp_ID = IA.GH_Id
		where IA.Cmp_ID=@cmp_id and  SA_Startdate between @frmdate and @enddate
Order by E.Emp_ID

--select * from #FinalTable
declare @empid numeric(18,0)
declare @initid numeric(18,0)

DECLARE cur cursor
for
	select Emp_id,init_id from #FinalTable order by Emp_id,init_id
open cur
	fetch next from cur into @empid,@initid
	while @@fetch_status=0
		begin	
			-----------increment update
			Update #FinalTable
			SET  lastCTC =INC.CTC,
				 lastdesi = INC.Desig_Name,
				 lastinc = INC.Increment_Effective_Date,
				 lastpromo = INC.Increment_Effective_Date
			FROM (
					select i4.CTC,I4.Increment_Effective_Date,dg.Desig_Name
					from T0095_INCREMENT I4 WITH (NOLOCK) INNER JOIN
						(select max(I.Increment_ID)Increment_ID,i.Emp_ID
						from T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(
							select max(I2.Increment_Effective_Date)Increment_Effective_Date,I2.Emp_ID
							from T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN
							(
								SELECT MAX(I3.Increment_Effective_Date)Increment_Effective_Date,I3.Emp_ID
								FROM T0095_INCREMENT I3 WITH (NOLOCK) inner JOIN
								T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) on ia.InitiateId = @initid
								WHERE I3.Emp_ID=@empid and I3.Increment_Effective_Date<= IA.SA_Startdate
								GROUP by I3.Emp_ID
							)I33 on i33.Emp_ID = I2.Emp_ID	
							where I2.Increment_Effective_Date < i33.Increment_Effective_Date and I2.Emp_ID=@empid
							GROUP by I2.Emp_ID	
						)i22 on i22.Increment_Effective_Date = i.Increment_Effective_Date  
						where i.Emp_ID =@empid 
						GROUP by I.Emp_ID
					)I44 on I4.Increment_ID = i44.Increment_ID  Inner JOIN
					T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i4.Desig_Id 
					Where I4.Emp_ID = @empid 
				  )INC
			WHERE #FinalTable.Emp_id=@empid and init_id=@initid
			
			-----------joining details
			Update #FinalTable
			SET  joinCTC =INC.CTC,
				 joindesi = INC.Desig_Name
			FROM (
					select CTC,Increment_Effective_Date,DG.Desig_Name
					from T0095_INCREMENT WITH (NOLOCK) Inner JOIN
						T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = T0095_INCREMENT.Desig_Id 
					where Emp_ID=@empid and Increment_Type='Joining'
				)INC
				WHERE #FinalTable.Emp_id=@empid and init_id=@initid
				
				
			fetch next from cur into @empid,@initid
		end
close cur
DEALLOCATE cur

--select * from #FinalTable

declare @query varchar(max)
if @dyQuery =''
	set @dyQuery =' 1=1 '

if @dyQuery <> ''
	begin
		set @query='select  ROW_NUMBER() OVER (ORDER BY Department,branchname,EmployeeCode) AS Srno,init_id,Department,branchname as Branch,EmployeeCode,EmployeeName,Designation,Grade,finaleval as ''Evaluation Type'',duration as Duration,convert(NVARCHAR(11),DoJ,103)AS DOJ,convert(NVARCHAR(11),dob,103) as ''Date of Birth'',expOrg as ''Experience in Current Organization'',totexp as ''Total Experience'',monthlyctc as ''Monthly CTC'',CTC as ''Annually CTC'',lastCTC as ''Last CTC'',lastdesi as ''Last Designation'',lastinc as ''Last Increment'',lastpromo as ''Last Promotion'',joinCTC as ''CTC at Joining'',joindesi as ''Designation at Joining'',ReportingManager,RM_score as ''RM score'',HOD,HOD_Score as ''HOD Score'',GH,GH_Score,Final_Score,Achievement as Rating,promotiondate as ''Current Year Promotion'',promotionDesig as ''Current Promotion Designation'',promotionGrade as ''Current Promotion Grade'',incrementcur as ''Increment'',jobrot as ''Job Rotation'',appriseecomm as ''Reporting Manager Comments'',HODcomm as ''HOD Comments'',GHcomm as ''GH Comments'',Reviewercomm as ''Final Reviewer Comments''  from #FinalTable 	'
		exec (@query + ' Where ' + @dyquery + ' Order By Srno,Department,branchname,EmployeeCode') 
		--print (@query + ' Where ' + @dyquery ) 
	End

PRINT @query
drop table #FinalTable
END



