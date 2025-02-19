
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_LateMark_Rate_Designation]
	@Tran_Id AS NUMERIC,
	@Gen_Id	As numeric,
	@CMP_ID AS NUMERIC,
	@Designation_ID AS Numeric,		
	@Normal_Rate AS Numeric(18,2),
	@Lunch_Rate AS Numeric(18,2),		
	@tran_type VARCHAR(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	IF @tran_type  = 'I'
		BEGIN	
			SELECT @Tran_Id = Isnull(max(tran_Id),0) + 1 from T0050_LateMark_Rate_Designation WITH (NOLOCK)
								
			INSERT INTO T0050_LateMark_Rate_Designation(tran_Id,Gen_Id,cmp_ID,Desig_Id,Normal_Rate,Lunch_Rate)
			VALUES     (@Tran_Id,@Gen_Id,@CMP_ID,@Designation_ID,@Normal_Rate,@Lunch_Rate)
		END	
RETURN					
						
				


