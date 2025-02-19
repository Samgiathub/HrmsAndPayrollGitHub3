
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_GENERAL_OT_RATE_SLABWISE]
	@Gen_ID			Numeric,
	@From_Hours		Numeric(9,2),
	@To_Hours		Numeric(9,2),
	@WD_Rate		Numeric(9,4),
	@WO_Rate		Numeric(9,4) = 0,
	@HO_Rate		Numeric(9,4) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN 		
		IF EXISTS(SELECT 1 FROM T0050_GENERAL_OT_RATE_SLABWISE WITH (NOLOCK) WHERE GEN_ID=@GEN_ID AND From_Hours = @From_Hours)
			UPDATE	OT
			SET		WD_Rate	= @WD_Rate,
					WO_Rate	= @WO_Rate,
					HO_Rate	= @HO_Rate,
					SystemDate = GETDATE()
			FROM	T0050_GENERAL_OT_RATE_SLABWISE OT
		ELSE
			INSERT INTO T0050_GENERAL_OT_RATE_SLABWISE(Gen_ID, From_Hours, To_Hours, WD_Rate, WO_Rate, HO_Rate, SystemDate)
			Values (@Gen_ID, @From_Hours, @To_Hours, @WD_Rate, @WO_Rate, @HO_Rate, GetDate())
	END
	

