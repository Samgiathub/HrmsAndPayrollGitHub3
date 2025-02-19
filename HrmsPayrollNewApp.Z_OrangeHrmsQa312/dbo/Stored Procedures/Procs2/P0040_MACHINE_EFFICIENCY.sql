


-- =============================================
-- Author:		Shaikh Ramiz
-- Create date: 10-Jan-2018
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_MACHINE_EFFICIENCY]
	@Efficiency_ID		NUMERIC	OUTPUT,
	@Cmp_ID				NUMERIC,
	@Machine_ID			NUMERIC,
	@Effective_Date		DATETIME,
	@Percent			NUMERIC(18,2),
	@Basic_Salary		NUMERIC(18,2),
	@Tran_type			CHAR(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @MAX_EFFICIENCY AS NUMERIC	
	
	IF @Tran_type = 'I'
		BEGIN
			
			IF NOT EXISTS (SELECT 1 FROM T0040_Machine_Efficiency_Master WITH (NOLOCK) WHERE Machine_ID = @Machine_ID AND Effective_Date = @Effective_Date )
				BEGIN
					SELECT @MAX_EFFICIENCY = ISNULL(MAX(Efficiency_ID),0) + 1 FROM T0040_Machine_Efficiency_Master WITH (NOLOCK)
					
					INSERT INTO T0040_Machine_Efficiency_Master 
						(Efficiency_ID , Cmp_ID , Machine_ID , Effective_Date)
					VALUES 
						(@MAX_EFFICIENCY , @Cmp_ID , @Machine_ID , @Effective_Date )
				END
			ELSE
				BEGIN
					SELECT @MAX_EFFICIENCY = ISNULL(Efficiency_ID,0) FROM T0040_Machine_Efficiency_Master WITH (NOLOCK) WHERE Machine_ID = @Machine_ID AND Effective_Date = @Effective_Date 
				END
			
			IF 	@MAX_EFFICIENCY > 0
				BEGIN
					INSERT INTO T0050_MACHINE_EFFICIENCY_SLAB 
						( Cmp_ID , Efficiency_ID , Avg_Percent , Basic_Amount )
					VALUES
						( @Cmp_ID , @MAX_EFFICIENCY , @Percent , @Basic_Salary )
				END
		END
	ELSE IF @Tran_type = 'D'
		BEGIN
			SELECT @Efficiency_ID = ISNULL(Efficiency_ID , 0) FROM T0040_Machine_Efficiency_Master WITH (NOLOCK) WHERE Machine_ID = @Machine_ID AND Effective_Date = @Effective_Date
			
			DELETE FROM T0050_MACHINE_EFFICIENCY_SLAB WHERE Efficiency_ID = ISNULL(@Efficiency_ID,0)
			DELETE FROM T0040_Machine_Efficiency_Master WHERE Efficiency_ID = ISNULL(@Efficiency_ID,0)
		END
		
END


