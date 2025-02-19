CREATE PROCEDURE [dbo].[SP_Mobile_WebService_GrievanceApp]
	@From_Date datetime,
	@To_Date datetime,
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Type char(5) = 'P'
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Type = 'P'
	BEGIN		

	select * from V0080_Griev_App_Admin_Side
	where Cmp_ID = @Cmp_ID and EMP_IDF = @Emp_ID and cast(R_Date as date) Between @From_Date and @To_Date
	order by R_Date desc

		-- Select * from T0080_Griev_Application 
		-- WHERE Cmp_ID = @Cmp_ID and EMP_IDF = @Emp_ID and cast(Receive_Date as date) Between @From_Date and @To_Date
		-- ORDER BY GA_ID DESC
	END		
	
END


