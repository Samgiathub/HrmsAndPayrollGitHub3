

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 01-Mar-2019
-- Description:	To retrieve the Late/Early Adjustment Days based on criteria
-- =============================================
CREATE FUNCTION [DBO].[fn_getLateEarlyAdjustDays] 
(
	@LateDays		Numeric(9,4),
	@Balance		Numeric(9,4),
	@AllowFraction	BIT,
	@MinLeave		Numeric(9,4)
)
RETURNS Numeric(9,4)
AS
BEGIN	
	DECLARE @AdjustDays Numeric(9,4)	
	IF @AllowFraction = 1 
		BEGIN
			IF @MinLeave > 0
				BEGIN
					IF @LateDays % @MinLeave > 0 
						SET @LateDays = @LateDays - (@LateDays % @MinLeave)
				END			
		END
	ELSE IF @LateDays > 0
		BEGIN
			SET @LateDays = @LateDays + (1 - (@LateDays % @MinLeave))
		END
	IF @LateDays < @Balance 
		SET @AdjustDays =  @LateDays
	ELSE
		SET @AdjustDays =  @Balance 

	IF @AdjustDays < 0
		SET @AdjustDays = 0
	RETURN @AdjustDays
END

