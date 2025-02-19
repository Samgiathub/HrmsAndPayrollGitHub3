


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_SHIFT_ALLOWANCE_RATE_SELECT]
@Cmp_id numeric,
@Effective_Date datetime,
@Ad_id numeric(18,0) = 0  --Added by Jaina 28-05-2018
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
	if @Ad_id = 0
		set @Ad_id = NULL
			
	SELECT     sar.Tran_id, sar.Cmp_id, sar.Shift_id, sar.Rate, Effective_Date, Is_Emp_Rate , SM.Shift_Name,Sar.Minimum_Count,SAR.Ad_Id
		FROM         T0100_SHIFT_ALLOWANCE_RATE		 SAR WITH (NOLOCK)
		inner join T0040_SHIFT_MASTER SM WITH (NOLOCK) on SAR.Shift_id = SM.Shift_ID
	WHERE Effective_Date = @Effective_Date and sar.Cmp_id = @Cmp_id
		and SAR.Ad_Id = ISNULL(@Ad_id,SAR.Ad_Id)   --Added by Jaina 28-05-2018
		
	    
END


