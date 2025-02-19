--SELECT * from T0040_MOBILE_STORE_MASTER_New
-- =============================================
-- Author: satish viramgami
-- Create date: 02/09/2020
-- Description:	Add Mobile brand and Sub-models master in vivo WB 
-- Table T0040_MOBILE_CATEGORY
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE  PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Mobile_Store_Employee]
	 @Mobile_Store_ID numeric(18,0),
	 @Cmp_ID numeric(18,0),
	 @Emp_Code varchar(50),
	 @Store_Id varchar(100),
	 @Effective_Date DateTime,
	 @Login_ID numeric(18,0),
	 @Tran_Type CHAR(1),
	 @Result VARCHAR(100) OUTPUT
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 
	 IF @Tran_Type='I'
	 BEGIN
			IF Exists (SELECT 1 FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID and Emp_Code = @Emp_Code 
					   AND Store_ID = @Store_Id AND Effective_Date = @Effective_Date)
			BEGIN
				SET @Result = ''
			END
			ELSE
			BEGIN
				DECLARE @Emp_ID AS NUMERIC(18,0)
				SELECT @Emp_ID = Emp_ID 
				FROM T0080_EMP_MASTER WITH (NOLOCK)
				WHERE Alpha_Emp_Code = @Emp_Code
				
				INSERT INTO T0040_EMP_MOBILE_STORE_ASSIGN_NEW VALUES (@Cmp_ID,@Emp_ID,@Emp_code,@Store_Id,@Effective_Date,Getdate(),@Login_ID)

				SET @Result = 'Record Insert Sucessfully#True'
			END
	 END
	ELSE IF @Tran_Type='D'
	BEGIN
		print 'D'
	 	DELETE FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW where STORE_TRAN_ID = @Mobile_Store_ID and Cmp_Id = @Cmp_ID
		SET @Result = 'Record Delete Sucessfully#True'
	END
END


