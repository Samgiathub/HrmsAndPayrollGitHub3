



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_Increment_Utility_BaseAmount]
	   @BaseAmt_Id			numeric(18,0) out
      ,@Cmp_Id				numeric(18,0)
      ,@EffectiveDate		datetime
      ,@Segment_ID			numeric(18,0)
      ,@Grd_Id				numeric(18,0)
      ,@desig_Id			numeric(18,0)
      ,@Branch_Id			numeric(18,0)
      ,@dept_Id				numeric(18,0)
      ,@Amount				numeric(18,2)
      ,@Percentage			numeric(18,2)=null
      ,@transType			int = 1
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @transType =1
	BEGIN
	SELECT @BaseAmt_Id = isnull(max(BaseAmt_Id),0)+1  FROM T0052_Increment_Utility_BaseAmount WITH (NOLOCK)
	INSERT  INTO T0052_Increment_Utility_BaseAmount
				(
					   BaseAmt_Id
					  ,Cmp_Id
					  ,EffectiveDate
					  ,Segment_ID
					  ,Grd_Id
					  ,desig_Id
					  ,Branch_Id
					  ,dept_Id
					  ,Amount
					  ,Percentage
				)
				VALUES
				(
					 @BaseAmt_Id
					  ,@Cmp_Id
					  ,@EffectiveDate
					  ,@Segment_ID
					  ,@Grd_Id
					  ,@desig_Id
					  ,@Branch_Id
					  ,@dept_Id
					  ,@Amount
					  ,@Percentage
				)
				
		END
	ELSE If @transType =2
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM T0052_Increment_Utility WITH (NOLOCK) where Segment_ID = @Segment_ID and EffectiveDate = @EffectiveDate)
				BEGIN
					DELETE FROM T0052_Increment_Utility_BaseAmount where Segment_ID = @Segment_ID and EffectiveDate = @EffectiveDate
				END
		END
			
END


