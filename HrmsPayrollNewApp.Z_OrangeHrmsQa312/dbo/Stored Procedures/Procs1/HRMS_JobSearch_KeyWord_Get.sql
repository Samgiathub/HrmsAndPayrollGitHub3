

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[HRMS_JobSearch_KeyWord_Get]
	 @searchword nvarchar(max) =''
	 ,@cmp_id	  numeric(18,0)=0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	
	CREATE TABLE #KeyWordTable
	(
		KeyWord NVARCHAR(max)
	)
	
	DECLARE @finalsearchword AS VARCHAR(max)
	SET @finalsearchword = (SELECT top 1 data FROM dbo.Split(@searchword,'#') 
							ORDER BY id DESC)
	
	PRINT @finalsearchword
	--SET @finalsearchword = @searchword
	
	
	IF @cmp_id<>0
		BEGIN
			--Job Title
			INSERT INTO #KeyWordTable
			SELECT Job_title
			FROM T0052_HRMS_Posted_Recruitment WITH (NOLOCK)
			WHERE Cmp_id = @cmp_id --and Job_title Like '%'+ @finalsearchword +'%'
			
			--Job Type
			INSERT INTO #KeyWordTable
			SELECT DISTINCT T.Type_Name
			FROM T0050_HRMS_Recruitment_Request R WITH (NOLOCK)
			INNER JOIN	T0040_TYPE_MASTER T WITH (NOLOCK) on t.Type_ID = R.Type_ID
			WHERE R.Cmp_id = @cmp_id --and Job_title Like '%'+ @finalsearchword +'%'
			
			--qualification
			INSERT INTO #KeyWordTable
			SELECT DISTINCT cs.Data
			FROM T0052_HRMS_Posted_Recruitment RQ WITH (NOLOCK)
			CROSS APPLY dbo.Split (Qual_Detail, ',') cs
			WHERE RQ.Cmp_id = @cmp_id --and Qual_Detail Like '%'+ @finalsearchword +'%'
			
			--skill
			INSERT INTO #KeyWordTable
			SELECT DISTINCT Skill_Name
			FROM T0055_RecruitmentSkill TS WITH (NOLOCK)
			INNER JOIN T0040_SKILL_MASTER S WITH (NOLOCK) on S.Skill_ID = TS.Skill_Id
			WHERE TS.Cmp_ID = @cmp_id --and S.Skill_Name Like '%'+ @finalsearchword +'%' 
			
			--Location
			INSERT INTO #KeyWordTable
			SELECT DISTINCT cs.Data
			FROM T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK)
			CROSS APPLY dbo.Split (RP.Location, '>') cs
			WHERE RP.Cmp_id = @cmp_id --and Location Like '%'+ @finalsearchword +'%'
			
			--Experience
			INSERT INTO #KeyWordTable
			SELECT DISTINCT RP.Experience
			FROM T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK)
			WHERE RP.Cmp_ID = @cmp_id --and RP.Experience Like '%'+ @finalsearchword +'%' 
		END
	ELSE
		BEGIN
			 DECLARE @incr INT 
			 DECLARE @cmp_criteria as INT
			 SET @incr = 1
			 WHILE @incr <= (SELECT COUNT(1) FROM V0100_GroupofCompany_Opening)
				BEGIN	
					SELECT @cmp_criteria = t.Cmp_Id
					FROM (
							SELECT Cmp_Id,ROW_NUMBER() OVER (ORDER BY Cmp_Id) AS rown
							FROM V0100_GroupofCompany_Opening
						)t
					WHERE rown = @incr	
					
					--Job Title
					INSERT INTO #KeyWordTable
					SELECT Job_title
					FROM T0052_HRMS_Posted_Recruitment WITH (NOLOCK)
					WHERE Cmp_id = @cmp_criteria --and Job_title Like '%'+ @finalsearchword +'%'
					
					--Job Type
					INSERT INTO #KeyWordTable
					SELECT DISTINCT T.Type_Name
					FROM T0050_HRMS_Recruitment_Request R WITH (NOLOCK)
					INNER JOIN	T0040_TYPE_MASTER T WITH (NOLOCK) on t.Type_ID = R.Type_ID
					WHERE R.Cmp_id = @cmp_criteria --and Job_title Like '%'+ @finalsearchword +'%'
			
					--qualification
					INSERT INTO #KeyWordTable
					SELECT DISTINCT cs.Data
					FROM T0052_HRMS_Posted_Recruitment RQ WITH (NOLOCK)
					CROSS APPLY dbo.Split (Qual_Detail, ',') cs
					WHERE RQ.Cmp_id = @cmp_criteria --and Qual_Detail Like '%'+ @finalsearchword +'%'
					
					--skill
					INSERT INTO #KeyWordTable
					SELECT DISTINCT Skill_Name
					FROM T0055_RecruitmentSkill TS WITH (NOLOCK)
					INNER JOIN T0040_SKILL_MASTER S WITH (NOLOCK) on S.Skill_ID = TS.Skill_Id
					WHERE TS.Cmp_ID = @cmp_criteria --and S.Skill_Name Like '%'+ @finalsearchword +'%' 
			
					--Location
					INSERT INTO #KeyWordTable
					SELECT DISTINCT cs.Data
					FROM T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK)
					CROSS APPLY dbo.Split (RP.Location, '>') cs
					WHERE RP.Cmp_id = @cmp_criteria --and Location Like '%'+ @finalsearchword +'%'
					
					--Experience
					INSERT INTO #KeyWordTable
					SELECT DISTINCT RP.Experience
					FROM T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK)
					WHERE RP.Cmp_ID = @cmp_criteria --and RP.Experience Like '%'+ @finalsearchword +'%' 
										
					SET @incr = @incr + 1
				END
		END
			
	SELECT DISTINCT KeyWord FROM #KeyWordTable WHERE isnull(KeyWord,'') <> ''

	DROP TABLE #KeyWordTable
END

