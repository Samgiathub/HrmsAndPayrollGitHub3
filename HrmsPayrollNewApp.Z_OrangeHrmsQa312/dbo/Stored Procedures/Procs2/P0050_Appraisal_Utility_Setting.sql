

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Appraisal_Utility_Setting]
	   @Appraisal_Utility_Id	numeric(18,0) OUT
      ,@Cmp_Id					numeric(18,0)
      ,@EffectiveDate			datetime
      ,@Segment_ID				numeric(18,0)	
      ,@Grd_Id					numeric(18,0)
      ,@desig_Id				numeric(18,0)
      ,@Branch_Id				numeric(18,0)
      ,@dept_Id					numeric(18,0)
      ,@Achivement_Id			numeric(18,0)
      ,@Percentage				numeric(18,2)
      ,@tran_type				varchar(1)	
	  ,@User_Id					numeric(18,0) = 0
	  ,@IP_Address				varchar(30)= ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Segment_ID = 0
		SET @Segment_ID = null
	IF @Grd_Id = 0
		SET @Grd_Id = null
	IF @desig_Id = 0
		SET @desig_Id = null
	IF @Branch_Id = 0
		SET @Branch_Id = null
	IF @dept_Id = 0
		SET @dept_Id = null
	IF @Achivement_Id = 0
		SET @Achivement_Id = null
	
   If (@tran_type) ='I'
		BEGIN		
			SELECT @Appraisal_Utility_Id = ISNULL(MAX(Appraisal_Utility_Id),0)+1 FROM T0050_Appraisal_Utility_Setting WITH (NOLOCK)
			INSERT INTO T0050_Appraisal_Utility_Setting
			(
				Appraisal_Utility_Id
			  ,Cmp_Id
			  ,EffectiveDate
			  ,Segment_ID
			  ,Grd_Id
			  ,desig_Id
			  ,Branch_Id
			  ,dept_Id
			  ,Achivement_Id
			  ,Percentage
			)VALUES
			(
				 @Appraisal_Utility_Id
				,@Cmp_Id
				,@EffectiveDate
				,@Segment_ID
				,@Grd_Id
				,@desig_Id
				,@Branch_Id
				,@dept_Id
				,@Achivement_Id
				,@Percentage
			)
		END
	ELSE IF (@tran_type) = 'U'
		BEGIN
			UPDATE T0050_Appraisal_Utility_Setting
			SET  
				   Segment_ID		=	@Segment_ID
				  ,Grd_Id			=	@Grd_Id
				  ,Branch_Id		=	@Branch_Id
				  ,dept_Id			=	@dept_Id
				  ,Achivement_Id	=	@Achivement_Id
				  ,Percentage		=	@Percentage
			WHERE Appraisal_Utility_Id = @Appraisal_Utility_Id
		END
	ELSE IF (@tran_type) = 'D'
		BEGIN
			DELETE FROM T0050_Appraisal_Utility_Setting WHERE Segment_ID = @Segment_ID AND	 EffectiveDate = @EffectiveDate
		END
END

