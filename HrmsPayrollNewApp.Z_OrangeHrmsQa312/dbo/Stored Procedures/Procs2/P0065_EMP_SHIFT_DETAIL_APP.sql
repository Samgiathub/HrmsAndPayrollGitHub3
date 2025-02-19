
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_SHIFT_DETAIL_APP]
	
	@CMP_ID			int,
	@SHIFT_ID		int ,
	@FOR_DATE		DATETIME = NULL,
	@OLD_JOIN_DATE	DATETIME = NULL,
	@SHIFT_TYPE		TINYINT = 0, --added by chetan 050917 for temprary shift option
	@Emp_Tran_ID bigint =0 ,
	@Emp_Application_ID int =0 ,
	@Approved_Emp_ID int=0,
	@Approved_Date datetime = Null,
	@Rpt_Level int=0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @SHIFT_TRAN_ID	NUMERIC
	
	DECLARE @FLAG NUMERIC
	SET @FLAG = 0
	
	
	
	Declare @FirstDefaultShiftDate DateTime
	SELECT	@FirstDefaultShiftDate  = Min(Approved_Date) FROM T0065_EMP_SHIFT_DETAIL_APP WITH (NOLOCK)
	WHERE   Emp_Tran_ID= @Emp_Tran_ID AND SHIFT_TYPE = 0
					
	IF @FirstDefaultShiftDate = @For_Date AND @SHIFT_TYPE = 1
		BEGIN
			Raiserror('@@You cannot modify the Default Shift specified on Date of Joining@@',16,2)
			return -1
		END

	
	SELECT @SHIFT_TRAN_ID = ISNULL(MAX(SHIFT_TRAN_ID),0) + 1 FROM T0065_EMP_SHIFT_DETAIL_APP WITH (NOLOCK)
	
	IF ISNULL(@OLD_JOIN_DATE,'') <> ''
		BEGIN
			IF EXISTS(SELECT Emp_Tran_ID FROM T0065_EMP_SHIFT_DETAIL_APP WITH (NOLOCK)
			WHERE Emp_Tran_ID= @Emp_Tran_ID  )
				BEGIN
				
						UPDATE T0065_EMP_SHIFT_DETAIL_APP
							SET SHIFT_ID = @SHIFT_ID 
								
								,Shift_Type = @SHIFT_TYPE 
								,Approved_Emp_ID=@Approved_Emp_ID
								,Approved_Date=@FOR_DATE
								,Rpt_Level=@Rpt_Level
						WHERE Emp_Tran_ID= @Emp_Tran_ID 
						
					
				END
			ELSE IF EXISTS(SELECT Emp_Tran_ID FROM T0065_EMP_SHIFT_DETAIL_APP WITH (NOLOCK)
							WHERE  Emp_Tran_ID= @Emp_Tran_ID )
				BEGIN
					UPDATE    T0065_EMP_SHIFT_DETAIL_APP
					SET       Shift_ID = @Shift_ID
							 ,Shift_Type = @SHIFT_TYPE 
							 ,Approved_Emp_ID=@Approved_Emp_ID
							 ,Approved_Date=@Approved_Date
							 ,Rpt_Level=@Rpt_Level
					WHERE	  Emp_Tran_ID= @Emp_Tran_ID  
				END
			ELSE
				BEGIN
					INSERT INTO T0065_EMP_SHIFT_DETAIL_APP
						(Shift_Tran_ID,  Cmp_ID, Shift_ID, Shift_Type,Emp_Tran_ID,Emp_Application_ID,Approved_Emp_ID,Approved_Date,Rpt_Level)
					VALUES(@Shift_Tran_ID,  @Cmp_ID, @Shift_ID,  @SHIFT_TYPE, @Emp_Tran_ID,@Emp_Application_ID,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
					SET @FLAG = 1
				END	
		END
	ELSE IF EXISTS(SELECT Emp_Tran_ID FROM T0065_EMP_SHIFT_DETAIL_APP WITH (NOLOCK)
	 WHERE Emp_Tran_ID= @Emp_Tran_ID )
		BEGIN
			UPDATE    T0065_EMP_SHIFT_DETAIL_APP
			SET       Shift_ID = @Shift_ID
					  ,Shift_Type = @SHIFT_TYPE 
					  ,Approved_Emp_ID=@Approved_Emp_ID
					  ,Approved_Date=@Approved_Date
					  ,Rpt_Level=@Rpt_Level
			WHERE	Emp_Tran_ID= @Emp_Tran_ID 
			
		END
	ELSE
		BEGIN
			INSERT INTO T0065_EMP_SHIFT_DETAIL_APP
						(Shift_Tran_ID,  Cmp_ID, Shift_ID, Shift_Type,Emp_Tran_ID,Emp_Application_ID,Approved_Emp_ID,Approved_Date,Rpt_Level)
					VALUES(@Shift_Tran_ID,  @Cmp_ID, @Shift_ID,  @SHIFT_TYPE, @Emp_Tran_ID,@Emp_Application_ID,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
			SET @FLAG = 1
		END
	
		
	RETURN
	

