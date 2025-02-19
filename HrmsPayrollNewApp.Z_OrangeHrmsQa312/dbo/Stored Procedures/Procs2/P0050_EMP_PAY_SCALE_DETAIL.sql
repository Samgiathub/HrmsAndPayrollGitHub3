

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 08-Aug-2015
-- Description:	For Insert/Update/Delete Process in T0050_EMP_PAY_SCALE_DETAIL table
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_EMP_PAY_SCALE_DETAIL] 
	@Cmp_ID numeric, 
	@Tran_ID numeric output,
	@Emp_ID numeric,
	@PayScale_ID numeric,
	@Effective_Date DateTime,
	@Tran_type numeric
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
    IF @Tran_type = 3	--FOR DELETE
		BEGIN
			DELETE FROM T0050_EMP_PAY_SCALE_DETAIL WHERE Cmp_ID=@CMP_ID AND Tran_ID=@TRAN_ID
			RETURN;
		END
    ELSE     
		BEGIN			
			IF @Tran_type = 1	--FOR INSERT
				BEGIN
					SELECT	@TRAN_ID = ISNULL(MAX(TRAN_ID), 0) + 1
					FROM	T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK)
					
					INSERT INTO T0050_EMP_PAY_SCALE_DETAIL(Cmp_ID,Tran_ID,Emp_ID,Pay_Scale_ID,Effective_Date,System_date)
					VALUES (@Cmp_ID,@Tran_ID,@Emp_ID,@PayScale_ID,@Effective_Date,GETDATE())
				END
			ELSE IF @Tran_type = 2 --FOR UPDATE
				BEGIN
					UPDATE	T0050_EMP_PAY_SCALE_DETAIL
					SET		Effective_Date = @Effective_Date,
							Pay_Scale_ID=@PayScale_ID
					WHERE	Tran_ID=@TRAN_ID
				END
		END  
END

