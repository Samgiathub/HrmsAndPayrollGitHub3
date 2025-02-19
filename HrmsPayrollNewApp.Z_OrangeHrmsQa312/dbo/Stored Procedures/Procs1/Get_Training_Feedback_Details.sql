
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Training_Feedback_Details]
	 @Cmp_ID		Numeric(18,0)
	,@Training_apr_id	Numeric(18,0)
	,@flag Numeric(18,0)=0 --FLAG-0 FOR FORM LEVEL FACULTY FEEDBACK,1 FOR FACULTY FEEDBACK REPORT,2-FOR INDUCTION FEEDBACK
	,@From_Date DATETIME
	,@To_Date	DATETIME
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	
	if @Training_apr_id = 0
		set @Training_apr_id = NULL	
		
	if @flag=0  --FOR FORM LEVEL FACULTY FEEDBACK
		BEGIN	
			declare @Faculty as VARCHAR(MAX)	
			CREATE TABLE #Faculty_Details
			(	
				Training_apr_id Numeric(18,0),		
				Faculty_Name varchar(100),
				Faculty_ID NUMERIC,
			)		
			
			CREATE TABLE #training_det1
			(	
				--Srno NUMERIC(18,0),
				Faculty varchar(100),
				Faculty_id NUMERIC,
				Training_id Numeric(18,0),
				Training_apr_id Numeric(18,0),
				Training_app_id Numeric(18,0),
				Training_Name varchar(150),
				Training_Type varchar(100),
				Training_Director varchar(100),	
				Training_Cordinator varchar(100)		
			)		
				declare @training_faculty as VARCHAR(200)
				select @training_faculty=replace(Faculty,' ','') from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)
				where Training_Apr_ID=@Training_Apr_ID and Cmp_ID=@cmp_id
			
				INSERT INTO #training_det1 (Faculty, Faculty_id, Training_id, Training_apr_id,Training_app_id, Training_Name, Training_Type,
											Training_Director, Training_Cordinator)
				SELECT DISTINCT	replace(IsNull(EMF.Alpha_Emp_Code+'- '+EMF.Emp_Full_Name,TF.Faculty_Name),' ',''), isnull(emp_ID,TF.Training_FacultyId),
						TM.Training_id, Training_apr_id,TA.Training_App_ID, REPLACE(TA.Training_Code,' ','')+'-'+Training_Name,TT.Training_TypeName,
						TM.Training_Director,TM.Training_Cordinator
				FROM   T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK)
						left JOIN dbo.T0050_HRMS_Training_Provider_master  PM WITH (NOLOCK) ON TA.Training_id = PM.Training_id and PM.Training_Pro_ID=TA.Training_Pro_ID
						LEFT JOIN dbo.T0030_Hrms_Training_Type  TT WITH (NOLOCK) ON TT.Training_Type_ID=TA.Training_Type
						LEFT join T0040_Hrms_Training_master TM WITH (NOLOCK) on TA.Training_id=TM.Training_id			
						LEFT OUTER JOIN T0080_EMP_MASTER EMF WITH (NOLOCK) ON CHARINDEX('#' + CAST(EMF.Emp_ID AS VARCHAR(10)) + '#', '#' + PM.Provider_Emp_Id + '#') > 0 AND PM.Provider_TypeId=1
						LEFT OUTER JOIN T0055_Training_Faculty TF WITH (NOLOCK) ON CHARINDEX('#' + CAST(TF.Training_FacultyId AS VARCHAR(10)) + '#', '#' + PM.Provider_FacultyId + '#') > 0  AND isnull(PM.Provider_TypeId,0)=0				
				WHERE	TA.Cmp_ID = @Cmp_ID and TA.Training_Apr_ID=@Training_apr_id 
				--select * from #training_det1
				
				PRINT @training_faculty
				select * into #training_det from #training_det1
				where Faculty IN(select  cast(data  as varchar(100)) from dbo.Split (@training_faculty,',') WHERE DATA <> '')
			
		--	select * from #training_det
				select ROW_NUMBER() OVER (PARTITION BY Faculty_ID ORDER BY Faculty_ID)as SrNo,
				Training_Apr_ID,Faculty_ID,Rating
				into #Rating_Details from T0110_Faculty_Rating_Details WITH (NOLOCK)
				where Training_Apr_ID=@Training_apr_id and Cmp_ID = @Cmp_ID
				 
				--select * from #Rating_Details		
			
				SELECT DISTINCT E.Emp_ID
				INTO	#Emp_Details1
				FROM	T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  E WITH (NOLOCK)
						inner join T0150_EMP_Training_INOUT_RECORD IT WITH (NOLOCK) on e.Emp_ID=IT.emp_id and e.Training_Apr_ID=IT.Training_Apr_Id and e.cmp_id=IT.cmp_Id						
				where	E.Training_Apr_ID=@Training_apr_id and E.cmp_id=@cmp_id
				
				SELECT DISTINCT ROW_NUMBER() OVER (PARTITION BY TD.Faculty ORDER BY TD.Faculty, E.Emp_ID)as SrNo,
						TD.Faculty_id, TD.Faculty, E.Emp_ID,Cast(0 As DECIMAL(9,2)) As Rating
				INTO	#Emp_Details
				FROM	T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  E WITH (NOLOCK)
						inner join #Emp_Details1 IT on e.Emp_ID=IT.emp_id 
						CROSS JOIN #training_det TD 
						--LEFT OUTER JOIN #Rating_Details RD on RD.Training_Apr_ID=E.Training_Apr_ID 
				where	E.Training_Apr_ID=@Training_apr_id and E.cmp_id=@cmp_id
				
				UPDATE #Emp_Details 
				SET rating = i.rating
				FROM (
					SELECT rating,srno,Faculty_ID
					FROM #Rating_Details) i
				WHERE 
					i.srno = #Emp_Details.srno and i.Faculty_ID=#Emp_Details.Faculty_ID	
				
				--select 222,* from #Emp_Details
				
				INSERT INTO #Emp_Details
				SELECT 0, Faculty_id, Faculty, 0,Faculty_id
				FROM	#training_det
			
			select * from #training_det1
			select DISTINCT Training_id,TD.Training_apr_id,isnull(Training_Type,'')Training_Type,
				   Training_Name,ISNULL(Training_Director,'')Training_Director,isnull(Training_Cordinator,'')Training_Cordinator,isnull(FD.comments,'')as comments
			from #training_det TD
			left join T0110_Faculty_Rating_Details FD WITH (NOLOCK) on TD.Training_apr_id=FD.Training_apr_id 			
		
			
			SELECT @columns = COALESCE(@columns + ',', '') + '[' + CAST(Faculty AS VARCHAR(100)) + ']'
						FROM #training_det
						GROUP BY Faculty
						
			PRINT @columns
			SET @query = 'SELECT  SrNo,'+ @columns +'
						FROM (
							SELECT SrNo,Faculty,Rating
							FROM #Emp_Details					
							) as s
						PIVOT
						(
						 
							sum(Rating)
							FOR [Faculty] IN (' + @columns + ') 
						
						)AS T' 
			print @query
			
			EXEC(@query)
			
			SELECT DISTINCT SCHEDULE_ID,HTS.TRAINING_APP_ID,CONVERT(VARCHAR,FROM_DATE,103) AS FROM_DATE,
			CONVERT(VARCHAR,TO_DATE,103) AS TO_DATE,FROM_TIME,TO_TIME,DATEDIFF(D,FROM_DATE,TO_DATE) + 1 AS DAYS, 
			DATEADD(D,-TA.ALERTS_DAYS,FROM_DATE) AS LAST_DATE 
			FROM T0120_HRMS_TRAINING_SCHEDULE HTS WITH (NOLOCK)
			INNER JOIN T0120_HRMS_TRAINING_APPROVAL HTA WITH (NOLOCK) ON HTA.TRAINING_APP_ID = HTS.TRAINING_APP_ID LEFT OUTER JOIN T0130_HRMS_TRAINING_ALERT TA WITH (NOLOCK)
			ON HTA.TRAINING_APR_ID = TA.TRAINING_APR_ID  where HTA.Training_Apr_id =@Training_apr_id and HTA.cmp_id=@cmp_id
			
	   END
   ELSE IF @FLAG=1 --FOR FACULTY FEEDBACK REPORT
		BEGIN
			SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY training_name,training_name) AS 'Sr.No.',
			Training_name as[Training Title],CONVERT(VARCHAR(15),from_date,103) +'-'+ CONVERT(VARCHAR(15),HTS.To_date,103) as[Date],HTS.From_Time +'-'+ HTS.To_Time as [Duration],
			HTA.[Type] as[Training Type],training_director as[Training Director],training_cordinator as[Training Cordinator],
			FD.Emp_Full_Name as[Trainer Name],QRY.EMPCount as[No of Participant],FD.SUM_RATING as[Total Rating],
			Cast(Round((FD.SUM_RATING/QRY.EMPCount),2)AS numeric(18,2)) as[Average],FD.comments
			FROM V0120_HRMS_TRAINING_APPROVAL  HTA --on TD.Training_app_id=HTS.Training_app_id
			INNER JOIN T0120_HRMS_TRAINING_SCHEDULE HTS WITH (NOLOCK) ON HTA.TRAINING_APP_ID = HTS.TRAINING_APP_ID 
			LEFT OUTER JOIN T0130_HRMS_TRAINING_ALERT TA WITH (NOLOCK) ON HTA.TRAINING_APR_ID = TA.TRAINING_APR_ID 
			INNER JOIN 
			(SELECT SUM(Rating)SUM_RATING,Faculty_ID,Training_Apr_ID,comments,EM.Emp_Full_Name 
			FROM T0110_Faculty_Rating_Details FRD WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON FRD.Faculty_ID=EM.Emp_ID
			 GROUP BY Faculty_ID,Training_Apr_ID,comments,EM.Emp_Full_Name)
			FD ON  FD.Training_Apr_ID=HTA.Training_Apr_ID
			INNER JOIN (SELECT ISNULL(COUNT(Faculty_Rating_Id),0)EMPCount,Training_Apr_ID
			FROM  T0110_Faculty_Rating_Details WITH (NOLOCK) GROUP BY Training_Apr_ID)QRY ON QRY.Training_Apr_ID=HTA.Training_Apr_ID
			where HTA.Training_Apr_ID =ISNULL(@Training_apr_id,HTA.Training_Apr_id) and HTA.cmp_id=@cmp_id
			AND HTS.From_date BETWEEN @From_Date AND @To_date
		END
	ELSE  --FOR INDUCTION FEEDBACK REPORT
		BEGIN			
			select DISTINCT TA.Cmp_Id,TA.Answer,TA.Training_Induction_ID,TA.emp_Id,TQ.Question
			into #Training_Details
			from V0110_Training_Induction_Details TI
			inner join T0150_HRMS_TRAINING_Answers TA WITH (NOLOCK) on TI.Training_Induction_ID=TA.Training_Induction_ID  
			inner join T0150_HRMS_TRAINING_Questionnaire TQ WITH (NOLOCK) on TQ.Training_Que_ID=TA.Tran_Question_Id and TQ.Questionniare_Type=3 and Question_Type=4
			where TI.Training_Induction_ID=ISNULL(@Training_apr_id,TI.Training_Induction_ID) and TI.Cmp_ID=@Cmp_ID
			
			declare @Question_option as varchar(500)
			select @Question_option=Question_option from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) where Questionniare_Type=3 and Cmp_Id=@Cmp_ID and Question_Option <> ''

			--print @Question_option                                                    
			Select data into #Training_Options from dbo.Split(@Question_option,'#')WHERE data <> ''
			--select * from #Training_Options
			                     
			SELECT @columns = COALESCE(@columns + ',', ' ') + '[' + CAST(data AS VARCHAR(100)) + ']'
			FROM #Training_Options 
			--print @columns	

			select DISTINCT * into #Training_Questions  from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) where Questionniare_Type=3 and Cmp_Id=@Cmp_ID and Question_Type=4
			--select * from #Training_Details

				SET @query = 'SELECT  ROW_NUMBER() OVER (ORDER BY Question)as SrNo,Question,'+ @columns +',Average_Rating
							FROM (
								SELECT Question,answer,0 as Average_Rating
								FROM #Training_Details					
								) as s
							PIVOT	
							(				 
								count(answer)
								FOR [answer] IN (' + @columns + ') 				
							)AS T' 
				--print @query
				
				EXEC(@query)
				
			DROP TABLE #Training_Questions			
			DROP TABLE #Training_Details
			DROP TABLE #Training_Options
		END
END

