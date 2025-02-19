

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[HRMS_Resume_KeyWord_Get]
	  @searchword nvarchar(max) =''
	 ,@cmp_id	  numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	create table #KeyWordTable
	(
		KeyWord nvarchar(max)
	)
	
	--Resume code
	insert into #KeyWordTable
	select Resume_Code from 
	T0055_Resume_Master WITH (NOLOCK) 
	where Cmp_id = @cmp_id and resume_code Like '%'+ @searchword +'%'
	
	--Rec PostCode
	insert into #KeyWordTable
	select Rec_Post_Code from 
	T0052_HRMS_Posted_Recruitment WITH (NOLOCK)
	where Cmp_id = @cmp_id and Rec_Post_Code Like '%'+ @searchword +'%'
	
	--Job Title
	insert into #KeyWordTable
	select Job_title from 
	T0052_HRMS_Posted_Recruitment WITH (NOLOCK)
	where Cmp_id = @cmp_id and Job_title Like '%'+ @searchword +'%'
	
	--Skill
	insert into #KeyWordTable
	select distinct S.Skill_Name from 
	T0090_HRMS_RESUME_SKILL RS WITH (NOLOCK) inner JOIN
	T0040_SKILL_MASTER S WITH (NOLOCK) on rs.Skill_Id = s.Skill_ID
	where rs.Cmp_id = @cmp_id and Skill_Name Like '%'+ @searchword +'%'
	
	--Qualification
	insert into #KeyWordTable
	select distinct Q.Qual_Name from 
	T0090_HRMS_RESUME_QUALIFICATION RQ WITH (NOLOCK) inner JOIN
	T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on RQ.Qual_ID = Q.Qual_ID
	where RQ.Cmp_id = @cmp_id and Q.Qual_Name Like '%'+ @searchword +'%'
	
	--source 7 July 2016
	INSERT into #KeyWordTable
	select distinct Source_Name from 
	V0055_HRMS_RESUME_MASTER where Cmp_id = @cmp_id and Source_Name Like '%'+ @searchword +'%'
	
	select * from #KeyWordTable

	drop TABLE #KeyWordTable
		
END


