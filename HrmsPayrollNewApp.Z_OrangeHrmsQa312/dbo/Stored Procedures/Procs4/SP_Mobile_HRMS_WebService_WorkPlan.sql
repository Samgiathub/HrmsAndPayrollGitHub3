-- =============================================
-- Author: satish viramgami
-- Create date: 28/8/2020
-- Description:	Add Work plan after the mobile-in/out in vivo WB 
----- Table T0130_EMP_WORKPLAN
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_WorkPlan]
	@Cmp_ID	numeric(18,0),
	@Emp_ID	numeric(18,0),
	@Work_Plan varchar(250),
	@Visit_Plan	varchar(250),
	@Work_Summary varchar(250),
	@Visit_Summary varchar(250),
	@INOUTFlag char(1),
	@Result VARCHAR(100) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;
	
	DECLARE @Time AS DATETIME
	DECLARE @Work_Tran_ID AS NUMERIC(18,0)

	SET @Time = CONVERT(datetime,CONVERT(varchar(11),GETDATE(),103) + ' ' + CONVERT(varchar(11),GETDATE(),108),103)
	
	IF @INOUTFlag = 'I'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM T0130_EMP_WORKPLAN WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND CAST(For_Date as date) = CAST(getdate() as date))
		BEGIN
			
			--SELECT @Work_Tran_ID = ISNULL(MAX(Work_Tran_ID),0) + 1 FROM T0130_EMP_WORKPLAN WITH (NOLOCK)
			
			INSERT INTO T0130_EMP_WORKPLAN
			(Cmp_ID,Emp_ID,For_Date,
			 Work_InTime,Work_OutTime,Work_Plan,
			 Visit_Plan,Work_Summary,Visit_Summary)
			VALUES
			(@Cmp_ID,@Emp_ID,GETDATE(),
			 @Time,'',@Work_Plan,
			 @Visit_Plan,'','')
				 
			set @Result = 'Record Insert Sucessfully#True'
			--Select @Result as Result
			
		END
		ELSE
		BEGIN 
			
			set @Result = 'Record already exists#False'
			--Select @Result as Result
			
		END
	END
	ELSE
	BEGIN
		
		IF EXISTS(SELECT 1 FROM T0130_EMP_WORKPLAN WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND CAST(For_Date as date) = CAST(getdate() as date))
		BEGIN
			
			SELECT @Work_Tran_ID = Work_Tran_ID
			FROM T0130_EMP_WORKPLAN WITH (NOLOCK) 
			WHERE Cmp_ID=@Cmp_ID 
			  AND Emp_ID=@Emp_ID
			  AND CAST(For_Date as date) = CAST(getdate() as date)
			
			UPDATE T0130_EMP_WORKPLAN
			SET Work_OutTime = @Time,
				Work_Summary = @Work_Summary,
				Visit_Summary = @Visit_Summary
			WHERE Work_Tran_ID = @Work_Tran_ID
				
			set @Result =  'Record Updated Sucessfully#True'
			--Select @Result as Result
		END
		ELSE
		BEGIN
			
			set @Result =  'First Submit Work Plan#False'
			--Select @Result as Result
		
		END
	END
	
END

