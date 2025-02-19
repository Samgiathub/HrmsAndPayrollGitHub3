
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_GrievHearing]
	@Cmp_ID numeric(18,0) 
  ,@start_date varchar(30)
  ,@End_date varchar(30)


AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
		SELECT  id,title,isMultipleDay,url,description,start,backgroundColor,borderColor,CONVERT(VARCHAR, CONVERT(DATETIME, Hdate), 108) AS [end],
		convert(varchar, Hdate, 103) as Hdate,Cmp_ID,G_AllocationID
		FROM V0080_GRIEVANCE_HEAIRNG_CALENDAR WHERE HDATE >=@start_date AND HDATE<= @End_date and Cmp_ID = @Cmp_ID 
END

