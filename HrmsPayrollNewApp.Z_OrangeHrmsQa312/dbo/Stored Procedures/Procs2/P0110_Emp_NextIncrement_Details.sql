CREATE PROCEDURE [dbo].[P0110_Emp_NextIncrement_Details]
 @Tran_id		NUMERIC OUTPUT
,@Cmp_ID		NUMERIC
,@Emp_Id	NUMERIC
,@Next_Incr_Date DATETIME
,@Tran_type	CHAR(1)
,@User_Id numeric(18,0) = 0 
,@IP_Address varchar(30)= '' 

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Tran_type = 'I'
	BEGIN		
		DECLARE @LAST_INCR_DATE AS DATETIME
		
		SELECT TOP 1 @LAST_INCR_DATE=Next_Increment_Date FROM T0110_Emp_NextIncrement_Details WHERE EMP_ID=@Emp_id AND CMP_ID=@Cmp_ID ORDER BY Next_Increment_Date DESC				
		IF @LAST_INCR_DATE > CONVERT(DATETIME,@NEXT_INCR_DATE,103)
			BEGIN
				SET @Tran_id =0
				RAISERROR('Next Increment date is small than Last Increment Date',16,2)
				RETURN
			END
		
		IF EXISTS(SELECT 1 FROM T0110_Emp_NextIncrement_Details WHERE Next_Increment_Date=@Next_Incr_Date AND EMP_ID=@Emp_id AND CMP_ID=@Cmp_ID)
		BEGIN
			SET @Tran_id =0
			RETURN
		END

		INSERT INTO T0110_Emp_NextIncrement_Details
		VALUES(@Cmp_ID,@Emp_id,@Next_Incr_Date,GETDATE(),@User_Id)
		set @Tran_id = @@IDENTITY
	END		
Else if @Tran_Type = 'D' 			
	Begin		
		Delete from T0110_Emp_NextIncrement_Details where Tran_Id = @Tran_id and cmp_id=@cmp_id			
	End			
		
RETURN



