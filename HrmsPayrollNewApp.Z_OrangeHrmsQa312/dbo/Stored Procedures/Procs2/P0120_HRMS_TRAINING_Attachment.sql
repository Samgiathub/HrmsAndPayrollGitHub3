


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0120_HRMS_TRAINING_Attachment]
	   @TrainingAttach_Id		numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@Training_Apr_Id			numeric(18,0)
      ,@Attachment				varchar(max)
      ,@VideoUrl				nvarchar(max)
      --,@Tran_Type				char(1)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @TrainingAttach_Id = 0--@Tran_Type = 'I'
		BEGIN
			SELECT @TrainingAttach_Id = ISNULL(MAX(TrainingAttach_Id),0) + 1 FROM T0120_HRMS_TRAINING_Attachment WITH (NOLOCK)
			INSERT INTO T0120_HRMS_TRAINING_Attachment
			(
				 TrainingAttach_Id
				,Cmp_Id
				,Training_Apr_Id
				,Attachment
				,VideoUrl
			)
			VALUES
			(
				 @TrainingAttach_Id
				,@Cmp_Id
				,@Training_Apr_Id
				,@Attachment
				,@VideoUrl
			)
		END
   ELSE --IF @Tran_Type = 'U'
		BEGIN
			UPDATE T0120_HRMS_TRAINING_Attachment
			SET  Attachment =    @Attachment
			    ,VideoUrl	=	@VideoUrl
			WHERE TrainingAttach_Id = @TrainingAttach_Id
		END
	--ELSE IF @Tran_Type = 'D'
	--	BEGIN
	--		DELETE FROM T0120_HRMS_TRAINING_Attachment WHERE TrainingAttach_Id = @TrainingAttach_Id
	--	END
END

