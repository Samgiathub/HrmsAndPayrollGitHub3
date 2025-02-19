
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_Perquisites_Employee_Monthly_GEW]  

  @Perq_Tran_id	numeric(18, 0) 
 ,@Month numeric(18,0)
 ,@Year numeric(18,0)
 ,@Amount numeric(18,0)
 ,@TRAN_TYPE varchar(1) = 'I'
 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		IF @TRAN_TYPE = 'I'
			BEGIN
				INSERT INTO T0250_Perquisites_Employee_Monthly_GEW
							(Perq_Tran_Id, Month, Year, Amount)
				VALUES     (@Perq_Tran_Id,@Month,@Year,@Amount)	
			END		
		ELSE IF @TRAN_TYPE = 'D'
			BEGIN	
				DELETE FROM T0250_Perquisites_Employee_Monthly_GEW where Perq_Tran_Id = @Perq_Tran_id
			END
	
RETURN



