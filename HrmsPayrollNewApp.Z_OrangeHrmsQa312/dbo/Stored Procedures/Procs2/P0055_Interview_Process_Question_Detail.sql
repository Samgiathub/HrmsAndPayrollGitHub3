


-- =============================================
-- Author:		
-- Create date: 
-- Description:	
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_Interview_Process_Question_Detail]
	   @Rec_Posted_Question_Process_Id		Numeric(18,0)
      ,@Cmp_ID								Numeric(18,0)
      ,@Process_Id							Numeric(18,0)
      ,@Process_Q_ID						Numeric(18,0)
      ,@Rec_Post_Id							Numeric(18,0)
      ,@tran_type							char(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @tran_type = 'I'
		BEGIN
			SELECT @Rec_Posted_Question_Process_Id = ISNULL(MAX(Rec_Posted_Question_Process_Id),0)+1 FROM T0055_Interview_Process_Question_Detail WITH (NOLOCK) 
			INSERT INTO T0055_Interview_Process_Question_Detail
			(
				   Rec_Posted_Question_Process_Id
				  ,Cmp_ID
				  ,Process_Id
				  ,Process_Q_ID
				  ,Rec_Post_Id
			)VALUES
			(
				   @Rec_Posted_Question_Process_Id
				  ,@Cmp_ID
				  ,@Process_Id
				  ,@Process_Q_ID
				  ,@Rec_Post_Id
			)
		END
	ELSE IF @tran_type = 'U'
		BEGIN
			UPDATE T0055_Interview_Process_Question_Detail
			SET    Process_Id		=	@Process_Id
				  ,Process_Q_ID		=	@Process_Q_ID
				  ,Rec_Post_Id		=	@Rec_Post_Id
			WHERE  Rec_Posted_Question_Process_Id = @Rec_Posted_Question_Process_Id
		END
	ELSE IF @tran_type = 'D'
		BEGIN
			DELETE FROM T0055_Interview_Process_Question_Detail WHERE  Rec_Posted_Question_Process_Id = @Rec_Posted_Question_Process_Id
		END
END

