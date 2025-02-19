
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel_Proof]
	 @Emp_ID numeric(18,0)
	,@Cmp_ID numeric(18,0) 
	,@TravelApp_Code varchar(10) 
	,@Image_Name VARCHAR(100)
	,@Image_Path VARCHAR(300)
	,@Travel_Proof_Type NUMERIC(18,0)
	,@Result VARCHAR(MAX) OUTPUT

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
		
		INSERT INTO T0080_Emp_Travel_Proof 
		(
		  Emp_ID,
		  Cmp_ID,
		  Image_Name,
		  Image_Path,
		  Travel_Proof_Type,
		  TravelApp_Code,
		  Effective_Date,
		  Travel_Mode
		  )
		VALUES
		  (
		  @Emp_ID,
		  @Cmp_ID,
		  @Image_Name,
		  @Image_Path,
		  @Travel_Proof_Type,
		  @TravelApp_Code,
			GETDATE(),
			'Mobile'
		)

				SET	@Result = 'Data Inserted Successfully'
				select @Result as Result

END
