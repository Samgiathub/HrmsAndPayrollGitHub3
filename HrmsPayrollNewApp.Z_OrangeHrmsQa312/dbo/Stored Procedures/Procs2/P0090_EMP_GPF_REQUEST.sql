


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 15-Jul-2015
-- Description:	To Insert,Update or Delete the record from T0090_EMP_GPF_REQUEST table.
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EMP_GPF_REQUEST] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric(18,0),
	@Tran_ID Numeric(18,0) Output,
	@Emp_ID Numeric(18,0),
	@AD_ID Numeric(18,0),
	@Effective_Date DateTime,
	@Amount Numeric(18,2),	
	@Tran_Type int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Tran_Type = 2 --For Delete
		BEGIN
			DELETE FROM T0090_EMP_GPF_REQUEST WHERE Tran_ID=@Tran_ID AND Cmp_ID=@Cmp_ID
		END
	ELSE
		BEGIN
			SET @Effective_Date = CONVERT(DATETIME, CONVERT(CHAR(10), @Effective_Date, 103), 103);
			
			
			IF EXISTS(SELECT 1 FROM T0090_EMP_GPF_REQUEST WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND Tran_ID <> @Tran_ID AND Effective_Date=@Effective_Date)
			BEGIN
				RAISERROR (N'There is already GPF Request exist for the same date.', 16, 2); 
				RETURN 1;
			END
			
			IF (
					(
						SELECT		Top 1 Amount 
						FROM		T0090_EMP_GPF_REQUEST WITH (NOLOCK)
						WHERE		Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID 
						Order By	Effective_Date DESC
					 ) = 0 
					 AND @Amount= 0 AND @Tran_Type = 1
				)
			BEGIN
				RAISERROR (N'There is already Cancel GPF Request exist.', 16, 2); 
				RETURN 1;
			END
			
			
			
			IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
					 WHERE	Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND S.Month_St_Date > @Effective_Date)
			BEGIN
				RAISERROR (N'Salary already exist!! You cannot create request for this date.', 16, 2); 
				RETURN 1;
			END
			
			IF NOT EXISTS(SELECT 1 FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID AND AD_ID=@AD_ID)
			BEGIN
				RAISERROR (N'Please select valid GPF Deduction from the dropdown list.', 16, 2); 
				RETURN 1;
			END
			
			IF @Tran_Type = 0 --For Insert
			BEGIN
				
				SET @Tran_ID = ISNULL((SELECT MAX(Tran_ID) FROM T0090_EMP_GPF_REQUEST WITH (NOLOCK)), 0) + 1 ;
		
				INSERT INTO T0090_EMP_GPF_REQUEST(Tran_ID, Cmp_ID,Emp_ID,AD_ID,Effective_Date,Amount,System_Date)
				VALUES (@Tran_ID,@Cmp_ID,@Emp_ID,@AD_ID,@Effective_Date,@Amount,GETDATE());
				
			END
			ELSE IF @Tran_Type = 1 --For Update
			BEGIN
				UPDATE	T0090_EMP_GPF_REQUEST
				SET		AD_ID=@AD_ID, Effective_Date=@Effective_Date,Amount=@Amount,System_Date=GETDATE()
				WHERE	Tran_ID=@Tran_ID AND Cmp_ID=@Cmp_ID
			END
		END 
				
END

