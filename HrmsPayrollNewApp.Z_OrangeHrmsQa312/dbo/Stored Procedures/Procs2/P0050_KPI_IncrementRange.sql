


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_KPI_IncrementRange]
	 @KPI_IncrementRangeId	Numeric(18,0) output
	,@Cmp_Id				Numeric(18,0)
	,@RangeName				Varchar(80)
	,@RangeValue			Varchar(50)
	,@EffectiveDate			datetime = null
	,@tran_type				varchar(1) 
    ,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	IF Upper(@tran_type) ='I'
		BEGIN
			IF NOT EXISTS(select 1 from T0050_KPI_IncrementRange WITH (NOLOCK) where Cmp_Id = @Cmp_Id and EffectiveDate = @EffectiveDate and RangeName = @RangeName)
				BEGIN
					SELECT @KPI_IncrementRangeId =isnull(MAX(KPI_IncrementRangeId),0)+1 From T0050_KPI_IncrementRange WITH (NOLOCK)
											
					INSERT INTO T0050_KPI_IncrementRange
					(
					   KPI_IncrementRangeId
					  ,Cmp_Id
					  ,RangeName
					  ,RangeValue
					  ,EffectiveDate
					)Values
					(
					   @KPI_IncrementRangeId
					  ,@Cmp_Id
					  ,@RangeName
					  ,@RangeValue
					  ,@EffectiveDate
					)	
			END
			ELSE
				BEGIN
					SET @KPI_IncrementRangeId = 0
					RETURN
				END
		END
	ELSE IF Upper(@tran_type) ='U'
		BEGIN
			UPDATE T0050_KPI_IncrementRange
			SET    RangeName		= @RangeName
			      ,RangeValue		= @RangeValue
				  ,EffectiveDate	= @EffectiveDate
			WHERE  KPI_IncrementRangeId = @KPI_IncrementRangeId
		END
	ELSE IF Upper(@tran_type) ='D'
		BEGIN
			DELETE FROM T0050_KPI_IncrementRange where EffectiveDate = @EffectiveDate
		END
END

