

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Extra_Increment_Utility]
	   @Extra_Increment_Utility_Id		numeric(18,0)OUT
      ,@Cmp_Id							numeric(18,0)
      ,@EffectiveDate					datetime
      ,@EligibleType					tinyint
      ,@Res_Id							int
      ,@Emp_Id							numeric(18,0)
      ,@Amount							numeric(18,2)
      ,@Appraisal_From					datetime
      ,@Appraisal_To					datetime
	  ,@tran_type						varchar(1)	
	  ,@User_Id							numeric(18,0) = 0
	  ,@IP_Address						varchar(30)= ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	IF @tran_type = 'I'
		BEGIN
			SELECT @Extra_Increment_Utility_Id = isnull(max(Extra_Increment_Utility_Id),0)+1 FROM T0060_Extra_Increment_Utility WITH (NOLOCK) WHERE cmp_Id = @cmp_Id
			INSERT INTO T0060_Extra_Increment_Utility
			(
				Extra_Increment_Utility_Id
				,Cmp_Id
				,EffectiveDate
				,EligibleType
				,Res_Id
				,Emp_Id
				,Amount
				,Appraisal_From
				,Appraisal_To
			)
			VALUES
			(
				@Extra_Increment_Utility_Id
				,@Cmp_Id
				,@EffectiveDate
				,@EligibleType
				,@Res_Id
				,@Emp_Id
				,@Amount
				,@Appraisal_From
				,@Appraisal_To
			)
		END
	ELSE IF @tran_type = 'U'
		BEGIN
			UPDATE T0060_Extra_Increment_Utility
			SET	   Amount  =  @Amount
			WHERE  Extra_Increment_Utility_Id= @Extra_Increment_Utility_Id and emp_id = @emp_id --and Res_Id = @Res_Id
		END 
	Else IF @tran_type = 'D'
		BEGIN
			DELETE FROM T0060_Extra_Increment_Utility WHERE  EffectiveDate = @EffectiveDate AND EligibleType = @EligibleType AND Res_Id = @Res_Id
						AND Appraisal_From = @Appraisal_From AND Appraisal_To = @Appraisal_To 
		END
END

