

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_HRMS_Posted_Recruitment_Replicate]
	 @Rec_Post_Id  	 numeric(18,0)  
	,@cmp_id		 numeric(18,0)
	,@NoTimes		 int  
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Rec_Req_ID			NUMERIC(18,0),
	        @Rec_Post_date		DATETIME,
	        @Rec_Start_date		DATETIME,
	        @Rec_End_date		DATETIME,
	        @Qual_Detail		NVARCHAR(1000),
	        @Experience_year	NUMERIC(18,0),
	        @Location			VARCHAR(200),
	        @Experience			NVARCHAR(1000),
		    @Email_id			VARCHAR(50),
		    @Job_title			VARCHAR(50),
		    @Posted_status		TINYINT,
		    @Login_id			NUMERIC(18,0),
		    @S_Emp_id			NUMERIC(18,0),
		    @Other_Detail		NVARCHAR(1000),
		    @Position			VARCHAR(500),
		    @Venue_address		NVARCHAR(250)
	
	SELECT @Rec_Req_ID	=Rec_Req_ID,
	       @Rec_Post_date	= Rec_Post_date,
	       @Rec_Start_date	= Rec_Start_date,
	       @Rec_End_date	= Rec_End_date,
	       @Qual_Detail		= Qual_Detail,
	       @Experience_year = Experience_year,
	       @Location		= Location,
	       @Experience		= Experience,
		   @Email_id		= Email_id,
		   @Job_title		= Job_title,
		   @Posted_status	= Posted_status,
		   @Login_id		= Login_id,
		   @S_Emp_id		= S_Emp_id,
		   @Other_Detail	= Other_Detail,
		   @Position		= Position,
		   @Venue_address	= Venue_address
	FROM   T0052_HRMS_Posted_Recruitment WITH (NOLOCK)
	WHERE Rec_Post_Id = @Rec_Post_Id and Cmp_id = @cmp_id
	
	DECLARE @i as INT
	SET @i = 1;
	
	WHILE @i <= @NoTimes
		BEGIN 
			--SELECT @i ,
			--@Rec_Req_ID,'' ,@Rec_Post_date,
			--@Rec_Start_date,@Rec_End_date,
			--@Qual_Detail,@Experience_year,@Location,
			--@Experience,@Email_id,
			--@Job_title,@Posted_status,@Login_id,@cmp_id,@S_Emp_id,
			--@Other_Detail,@Position,'Insert',
			--@Venue_address,
			--0,null,
			--null
			
			EXEC P0052_HRMS_Posted_Recruitment @Rec_Post_Id=@i,
			@Rec_Req_ID=@Rec_Req_ID,@Rec_Post_Code='' ,@Rec_Post_date=@Rec_Post_date,
			@Rec_Start_date=@Rec_Start_date,@Rec_End_date=@Rec_End_date,
			@Qual_Detail=@Qual_Detail,@Experience_year=@Experience_year,@Location=@Location,
			@Experience=@Experience,@Email_id=@Email_id,
			@Job_title=@Job_title,@Posted_status=@Posted_status,@Login_id=@Login_id,@cmp_id=@cmp_id,@S_Emp_id=@S_Emp_id,
			@Other_Detail=@Other_Detail,@Position=@Position,@tran_type='Insert',
			@Venue_Address=@Venue_address,
			@Publish_ToEmp=0,@Publish_FromDate=null,
			@Publish_ToDate=null
					
			SET @i = @i + 1;	
		END
END

