

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Appraisal_Utility_Setting]
	   @Cmp_Id					numeric(18,0)
      ,@EffectiveDate			datetime
      ,@Segment_ID				numeric(18,0)	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Query as VARCHAR(MAX)
	DECLARE @Condition as VARCHAR(MAX) = ''
	
	IF EXISTS(SELECT 1 FROM T0050_Appraisal_Utility_Setting WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id and Segment_ID = @Segment_ID	 AND CONVERT(VARCHAR(10),EffectiveDate,120) = CONVERT(VARCHAR(10), @EffectiveDate,120) )
		BEGIN
			SELECT Achievement_Level,AchievementId,Effective_Date,AU.segment_Id,isnull(AU.Percentage,0)Percentage,au.Appraisal_Utility_Id
			FROM T0040_Achievement_Master WITH (NOLOCK) INNER JOIN
				   T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = T0040_Achievement_Master.Cmp_ID LEFT JOIN
				   T0050_Appraisal_Utility_Setting AU WITH (NOLOCK) on AU.Achivement_Id = T0040_Achievement_Master.AchievementId
						and ISNULL(AU.EffectiveDate,C.From_Date) = ISNULL(T0040_Achievement_Master.Effective_Date,c.From_Date)
			WHERE T0040_Achievement_Master.Cmp_ID= @Cmp_Id AND Achievement_Type = 2
				     AND CONVERT(VARCHAR(10),ISNULL(Effective_Date,C.From_Date),120) = CONVERT(VARCHAR(10), @EffectiveDate,120) 
				     AND SEGMENT_ID = @Segment_ID
			ORDER BY Achievement_Sort
		END
	ELSE
		BEGIN
			SELECT Achievement_Level,AchievementId,Effective_Date,null as segment_Id,0 as Percentage,null as Appraisal_Utility_Id
			FROM  T0040_Achievement_Master WITH (NOLOCK) INNER JOIN
				   T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = T0040_Achievement_Master.Cmp_ID
			WHERE T0040_Achievement_Master.Cmp_ID= @Cmp_Id AND Achievement_Type = 2
				     AND CONVERT(VARCHAR(10),ISNULL(Effective_Date,C.From_Date),120) = CONVERT(VARCHAR(10), @EffectiveDate,120) 
			ORDER BY Achievement_Sort
		END
		
		 
END

