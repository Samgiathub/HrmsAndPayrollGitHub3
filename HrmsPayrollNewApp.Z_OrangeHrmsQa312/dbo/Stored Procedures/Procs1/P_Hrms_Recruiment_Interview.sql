

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Hrms_Recruiment_Interview]
	-- Add the parameters for the stored procedure here
		@Cmp_ID numeric(18,0),  
		@Branch_ID numeric(18,0),
		@emp_id numeric(18,0)  
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.


	--For Recruitment alert
			declare @staus_re as int
	declare @for_date varchar(50) 
			set @for_date= cast(getdate() as varchar(11))
			
			
			
			Create TABLE #Data
			(
				Interview_Process_detail_ID numeric(18,0)
				,Rec_Post_ID numeric(18,0)
				,Process_ID numeric(18,0)
				,Process_Name varchar(50)
				,Job_title varchar(100)
				,from_date datetime
				,to_date datetime
				,noofInterviews INT
				--,from_time varchar(50)
				--,to_time varchar(50)
				,status int
			)
				--CREATE NONCLUSTERED INDEX IX_Data_Interview_Process_detail_ID_Rec_Post_ID_Process_ID on #Data (Interview_Process_detail_ID,Rec_Post_ID,Process_ID)
			
			SET @staus_re=1
			---added on 03/11/2017--(start)
			
			
			
			INSERT INTO #Data(Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews,status)			
			SELECT IPS2.Interview_Process_Detail_Id,IPS2.Rec_Post_Id,V.Process_ID,V.Process_Name,V.Job_title
				  ,IPS2.fdate,IPS2.tdate,IPS2.cnt,@staus_re --,IPS.From_Date,IPS.To_Date,IPS.From_Time,IPS.To_Time,0 
			FROM V0055_Interview_Process_Detail V 
			INNER JOIN (
							SELECT min(From_Date)fdate,max(To_Date)tdate,count(1)cnt,Interview_Process_Detail_Id,Rec_Post_Id
							FROM   T0055_HRMS_Interview_Schedule WITH (NOLOCK)
							WHERE Cmp_Id = @cmp_id AND Rating is NULL 
								  AND (S_Emp_Id = @emp_id OR S_Emp_Id2 = @emp_id
								  OR S_Emp_Id3 = @emp_id OR S_Emp_ID4 = @emp_id)
								  AND (From_Date > DATEADD(dd,-3,@for_date) and From_Date>=@for_date)
								  AND From_Time <> '0'
							GROUP BY Interview_Process_Detail_Id,Rec_Post_Id
						)IPS2 ON IPS2.Interview_Process_Detail_Id = V.Interview_Process_detail_ID and IPS2.Rec_Post_Id = V.Rec_Post_ID
			WHERE V.Cmp_ID = @cmp_id  
			ORDER BY IPS2.fdate
			
			SELECT Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews,status  
			FROM #Data



	--SET NOCOUNT ON;
	--		declare @for_date varchar(50) 
	--		set @for_date= cast(getdate() as varchar(11))
			
			
			
	--		Create TABLE #Data
	--		(
	--			Interview_Process_detail_ID numeric(18,0)
	--			,Rec_Post_ID numeric(18,0)
	--			,Process_ID numeric(18,0)
	--			,Process_Name varchar(50)
	--			,Job_title varchar(100)
	--			,from_date datetime
	--			,to_date datetime
	--			,noofInterviews INT
	--		)
			
			
			
	--		INSERT INTO #Data(Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews)
	--		SELECT IPS2.Interview_Process_Detail_Id,IPS2.Rec_Post_Id,V.Process_ID,V.Process_Name,V.Job_title
	--			  ,IPS2.fdate,IPS2.tdate,IPS2.cnt 
	--		FROM V0055_Interview_Process_Detail V 
	--		INNER JOIN (
	--						SELECT min(From_Date)fdate,max(To_Date)tdate,count(1)cnt,Interview_Process_Detail_Id,Rec_Post_Id
	--						FROM   T0055_HRMS_Interview_Schedule 
	--						WHERE Cmp_Id = @cmp_id AND Rating is NULL 
	--							  AND (S_Emp_Id = @emp_id OR S_Emp_Id2 = @emp_id
	--							  OR S_Emp_Id3 = @emp_id OR S_Emp_ID4 = @emp_id)
	--							  AND (From_Date > DATEADD(dd,-3,@for_date) and From_Date>=@for_date)
	--							  AND From_Time <> '0'
	--						GROUP BY Interview_Process_Detail_Id,Rec_Post_Id
	--					)IPS2 ON IPS2.Interview_Process_Detail_Id = V.Interview_Process_detail_ID and IPS2.Rec_Post_Id = V.Rec_Post_ID
	--		WHERE V.Cmp_ID = @cmp_id  
	--		ORDER BY IPS2.fdate
			
	--		SELECT Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews 
	--		FROM #Data
		
END

