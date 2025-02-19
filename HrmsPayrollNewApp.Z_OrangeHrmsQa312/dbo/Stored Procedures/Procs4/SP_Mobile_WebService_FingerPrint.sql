---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_FingerPrint]
	@Cmp_ID numeric(18,0) = 0,
	@Emp_ID numeric(18,0) = 0,
	@FingerPrintfileName varchar(200) = NULL,
	@FingerNumber int = 0,
	@Type char(1),
	@Result varchar(100) OUTPUT
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @Type = 'I'
	BEGIN
		if ((select count(1) from T0051_WebService_FingerPrint_Details WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and FingerNumber = @FingerNumber) = 0)
		BEGIN
					
					DECLARE  @EmpFullName as Varchar(200) = NULL
					Select @EmpFullName = Alpha_Emp_Code +  ' - ' + Emp_Full_Name  from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Emp_Left = 'N'
					IF @EmpFullName <> ''
					BEGIN

						INSERT INTO T0051_WebService_FingerPrint_Details values (@Emp_ID,@EmpFullName,@Cmp_ID,@FingerPrintfileName,@FingerNumber,GETDATE())
						Declare @Fingercount int = 0
						select @Fingercount = count(1) from T0051_WebService_FingerPrint_Details WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
						SET @Result = 'Record Insert Successfully -' + cast(@Fingercount as varchar(2)) + '#True#'

					END
					ELSE
					BEGIN
						
						SET @Result = 'Employee Not Found#True#'
					END
					SELECT @Result
		END
		ELSE
		BEGIN
				SET @Result = 'Employee already registered#False#'
				SELECT @Result
		END
	END
	ELSE IF @Type = 'S'
	BEGIN
		if ((select count(1) from T0051_WebService_FingerPrint_Details WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) > 0)
		BEGIN
				SELECT FingerPrintfileName,Emp_full_Name,Cmp_ID,Emp_ID 
				FROM T0051_WebService_FingerPrint_Details WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
		END
		ELSE
		BEGIN
				SET @Result = 'Employee is not registered#False#'
				SELECT @Result
		END

	END
	ELSE IF @Type = 'D'
	BEGIN
		if ((select count(1) from T0051_WebService_FingerPrint_Details WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and FingerNumber = @FingerNumber) = 1)
		BEGIN
			Delete FROM T0051_WebService_FingerPrint_Details where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and FingerNumber = @FingerNumber
			SET @Result = 'Deleted Successfully#True#'
			SELECT @Result
		END
		Else 
		BEGIN
			SET @Result = 'Employee Is Not Registered#False#'
			SELECT @Result
		END
			
	END
END
