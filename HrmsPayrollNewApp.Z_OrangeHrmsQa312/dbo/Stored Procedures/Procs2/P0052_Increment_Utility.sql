



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_Increment_Utility]
	   @Increment_Utility_Id	numeric(18,0) 
      ,@Cmp_Id					numeric(18,0)
      ,@EffectiveDate			datetime	OUT
      ,@Segment_ID				numeric(18,0)
      ,@Grd_Id					numeric(18,0)
      ,@desig_Id				numeric(18,0)
      ,@Branch_Id				numeric(18,0)
      ,@dept_Id					numeric(18,0)
      ,@Amount					numeric(18,2)
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
	
	IF @desig_Id = 0 
		SET @desig_Id = NULL
	IF @Branch_Id = 0
		SET @Branch_Id = NULL
	IF @dept_Id = 0
		SET @dept_Id = NULL

		IF @tran_type = 'I'
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM T0052_Increment_Utility WITH (NOLOCK) WHERE EffectiveDate = @EffectiveDate AND Segment_ID = @Segment_ID AND
							Grd_Id = @Grd_Id and Achivement_Id = @Achivement_Id)
					BEGIN
						SELECT @Increment_Utility_Id = isnull(max(Increment_Utility_Id),0)+1  FROM T0052_Increment_Utility WITH (NOLOCK) 
						INSERT  INTO T0052_Increment_Utility
						(
							   Increment_Utility_Id
							  ,Cmp_Id
							  ,EffectiveDate
							  ,Segment_ID
							  ,Grd_Id
							  ,desig_Id
							  ,Branch_Id
							  ,dept_Id
							  ,Amount
							  ,Achivement_Id
							  ,Percentage
						)
						VALUES
						(
							  @Increment_Utility_Id
							  ,@Cmp_Id
							  ,@EffectiveDate
							  ,@Segment_ID
							  ,@Grd_Id
							  ,@desig_Id
							  ,@Branch_Id
							  ,@dept_Id
							  ,@Amount
							  ,@Achivement_Id
							  ,@Percentage
						)
					END
				ELSE
					BEGIN
						UPDATE T0052_Increment_Utility
						SET
							  Amount		 =	@Amount
							  --,Achivement_Id  =	@Achivement_Id
							  ,Percentage	 =	@Percentage
						WHERE Segment_ID= @Segment_ID and  Grd_Id = @Grd_Id and EffectiveDate = @EffectiveDate
							 and Achivement_Id  =	@Achivement_Id
					END
			END
		ELSE IF @tran_type = 'U'
			BEGIN				
				UPDATE T0052_Increment_Utility
				SET   Segment_ID	 =	@Segment_ID
					  ,Grd_Id		 =	@Grd_Id
					  ,desig_Id		 =	@desig_Id
					  ,Branch_Id	 =	@Branch_Id
					  ,dept_Id		 =	@dept_Id
					  ,Amount		 =	@Amount
					  ,Achivement_Id  =	@Achivement_Id
					  ,Percentage	 =	@Percentage
				WHERE Increment_Utility_Id = @Increment_Utility_Id
			END
		ELSE IF @tran_type = 'D'
			BEGIN
				DELETE FROM T0052_Increment_Utility_BaseAmount where Segment_ID =	@Segment_ID and  EffectiveDate = @EffectiveDate

				DELETE FROM T0052_Increment_Utility 
				WHERE Segment_ID =	@Segment_ID and  EffectiveDate = @EffectiveDate --Increment_Utility_Id = @Increment_Utility_Id 
				
				set @Increment_Utility_Id = 1
			END
END


