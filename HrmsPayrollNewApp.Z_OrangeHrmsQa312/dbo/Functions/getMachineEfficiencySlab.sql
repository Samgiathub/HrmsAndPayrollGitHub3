

---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
CREATE  FUNCTION [dbo].[getMachineEfficiencySlab]
(
	@EfficiencyID Numeric
)  
RETURNS @RtnValue table 
(
	Slab_ID			NUMERIC,
	Cmp_ID			NUMERIC,
	Efficiency_ID	NUMERIC,
	Avg_Percent		NUMERIC(18,2),
	Basic_Amount	NUMERIC(18,2)
) 
AS  
BEGIN 
	
	INSERT INTO @RtnValue
		(Slab_ID,Cmp_ID,Efficiency_ID,Avg_Percent,Basic_Amount)
	SELECT Slab_ID,Cmp_ID,Efficiency_ID,Avg_Percent,Basic_Amount 
	FROM T0050_Machine_Efficiency_Slab WITH (NOLOCK)
	WHERE Efficiency_ID = @EfficiencyID
	
	RETURN
END




