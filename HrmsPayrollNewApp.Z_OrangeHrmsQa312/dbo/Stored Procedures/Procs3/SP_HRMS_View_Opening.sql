---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_View_Opening]
	@Cmp_ID numeric(18,0) 
	,@Rec_Post_ID numeric(18,0)=null
	,@Search_KeyWord	varchar(max)=''

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


        IF  @Cmp_ID  = 0
        SET @Cmp_ID =null
        
        IF @Rec_Post_ID = 0
			SET @Rec_Post_ID = NULL
   
	Declare @Start_Date as Datetime
	Declare @End_Date as DateTime
	Declare @Today_date as DateTime
	set @Today_date = Cast(getdate() as varchar(12))
	
	CREATE TABLE #Skill
	(
		 Rec_Req_ID numeric(18,0)
		,Skill_Name	varchar(5000)
	)
 
 --added on 30/10/2017---
DECLARE @cmpIdstr VARCHAR(MAX)
 
 IF @Cmp_ID IS NOT NULL
	SET @cmpIdstr = @Cmp_ID
ELSE
	SELECT @cmpIdstr =  STUFF((
					select  ',' + CAST(cmp_id as VARCHAR)
					from V0100_GroupofCompany_Opening
				 FOR XML PATH('') ), 1, 1, '')
	FROM  V0100_GroupofCompany_Opening
 
declare	@i numeric(18,0)
SET @i= 1

WHILE @i<= (SELECT count(1) FROM dbo.Split(@cmpIdstr,',') where Data <> '')
	BEGIN
		SELECT @Cmp_ID = k.Data 
		FROM(Select data,ROW_NUMBER() OVER (ORDER BY Data) AS rown
							FROM dbo.Split(@cmpIdstr,',') 
							WHERE Data <> ''
			)k
		WHERE k.rown = @i				
			
		--Added By Mukti(start)03022016
			INSERT INTO #Skill(Rec_Req_ID,Skill_Name)
			SELECT  DISTINCT  B.Rec_Req_ID, STUFF
								  ((SELECT DISTINCT    ', ' + sm.Skill_Name
									  FROM         T0052_HRMS_Posted_Recruitment A WITH (NOLOCK)
									  INNER join T0055_RecruitmentSkill rs WITH (NOLOCK) on b.Rec_Req_ID=rs.Rec_Req_ID 
									  INNER join T0040_SKILL_MASTER sm WITH (NOLOCK) on sm.Skill_ID=rs.Skill_Id 
									  WHERE     A.[Cmp_id] = B.[Cmp_id] and A.cmp_id = @Cmp_ID AND Posted_Status = 1 AND ((GETDATE() >= Rec_Start_Date AND GETDATE() <= Rec_end_Date) OR
									  (Rec_End_Date >= GETDATE() AND Rec_end_date <= GETDATE())) FOR XML PATH('')), 1, 1, '') AS [Skill_Name]
			
			FROM         T0052_HRMS_Posted_Recruitment B WITH (NOLOCK)
			INNER join T0055_RecruitmentSkill rs WITH (NOLOCK) on b.Rec_Req_ID=rs.Rec_Req_ID 
			INNER join T0040_SKILL_MASTER sm WITH (NOLOCK) on sm.Skill_ID=rs.Skill_Id 
			WHERE     Posted_Status = 1 and B.cmp_id = @Cmp_ID AND ((GETDATE() >= Rec_Start_Date AND GETDATE() <= Rec_end_Date) OR
			(Rec_End_Date >= GETDATE() AND Rec_end_date <= GETDATE()))
		--Added By Mukti(end)03022016

		SELECT DISTINCT Q.*,datediff(dd,Q.Rec_Start_Date,Q.Rec_end_Date) as date_diff,'('+ cast(datediff(dd,GETDATE(),
		Q.Rec_end_Date) AS VARCHAR(20)) + ' days remaining)' as rec_days,case when hr.Gender_Specific='' then 'All' else hr.Gender_Specific end as Gender_Specific
		INTO #tbl_Opening		
		FROM    V0052_HRMS_recruitment_Posted q 		
		inner join V0050_HRMS_Recruitment_Request hr on q.Rec_Req_ID=hr.Rec_Req_ID
		left join #Skill s on q.Rec_Req_ID=s.Rec_Req_ID --Mukti(03022016)
		WHERE   Q.cmp_id = @Cmp_ID and q.Rec_Post_ID=isnull(@Rec_Post_ID,Rec_Post_ID)
			   --and Q.App_Status = 1 commented By Mukti 24122014
			   and Q.Posted_Status = 1  --added By Mukti 24122014
			   and ((@Today_date >= Q.Rec_Start_Date  and  
			   @Today_date <= Q.Rec_end_Date ) or
			  (q.Rec_End_Date >=  @Today_date and   Q.Rec_end_date  <= @Today_date))
		ORDER BY  Q.cmp_id,date_diff ASC
	
		
		SET @i = @i+1
	END
		
	IF @Search_KeyWord = ''
		BEGIN
			SELECT * FROM #tbl_Opening
		End	
	ELSE
		BEGIN
			DECLARE @search_criteria  VARCHAR(100)
			DECLARE @condition  VARCHAR(5000)
			SET @condition = ''
			DECLARE @query  VARCHAR(MAX)
		
			CREATE TABLE #key 
			 (
				key_detail varchar(100),
				id	INT
			 ) 
			 INSERT INTO #key
			 SELECT data,Id FROM dbo.Split(@Search_KeyWord,'#') WHERE Data <> ''
			 			 
			 DECLARE @incr INT 
			 SET @incr = 1
			 WHILE @incr <= (SELECT COUNT(1) FROM #key)
				BEGIN
					SELECT @search_criteria = key_detail FROM #key where id = @incr	
					IF @condition = ''
						SET @condition = @condition +  ' Where (Job_title = '''+ @search_criteria +''' or Experience = '''+ @search_criteria +''' or Type_Name= '''+ @search_criteria +''' or Location like ''%'+ @search_criteria +'%'' or Qual_detail = '''+ @search_criteria +''' or Skill_Name='''+ @search_criteria +''')'
					ELSE				
						SET @condition = @condition +  ' or (Job_title = '''+ @search_criteria +''' or Experience = '''+ @search_criteria +''' or Type_Name= '''+ @search_criteria +''' or Location like ''%'+ @search_criteria +'%'' or Qual_detail = '''+ @search_criteria +''' or Skill_Name='''+ @search_criteria +''')'
										
					SET @incr = @incr + 1
				END
				
					SET @query = 'SELECT * FROM #tbl_Opening ' + @condition
					PRINT @query
					
					EXEC(@query)
					
				DROP TABLE #key
				
		END
		
	DROP TABLE #tbl_Opening
	DROP TABLE #Skill
	RETURN





