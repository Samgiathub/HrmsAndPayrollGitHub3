

 ---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Overhead_Master]    
@Overhead_ID NUMERIC output,    
@Project_ID numeric(18,0) = null,
@OverHead_Month varchar(50),
@OverHead_Year numeric(18,0),
--@Milestone_Description VARCHAR(MAX), 
--@Effect_Date datetime,
@Exchange_Rate numeric(18,2),
@Project_Cost numeric(18,2),
@Cmp_ID numeric(18,0),     
@Created_By numeric(18,0),     
@Trans_Type varchar(1)    
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

SET @Project_ID = null
	If @Trans_Type  = 'I'    
		Begin    
			If Exists (SELECT Overhead_ID FROM T0040_OverHead_Master WITH (NOLOCK)  WHERE Cmp_ID = @Cmp_ID AND Project_ID = @Project_ID AND OverHead_Month = @OverHead_Month AND OverHead_Year = @OverHead_Year )
				BEGIN    
					SET @Overhead_ID = 0    
					RETURN    
				END    
			SELECT @Overhead_ID = ISNULL(MAX(overhead_ID), 0) + 1 FROM T0040_OverHead_Master WITH (NOLOCK)    
			INSERT INTO T0040_OverHead_Master(overhead_ID,Project_ID,OverHead_Month,OverHead_Year,Exchange_Rate,Project_cost,Cmp_ID,Created_By,Created_Date)VALUES    
			(@Overhead_ID,@Project_ID,@OverHead_Month,@OverHead_Year,@Exchange_Rate,@Project_cost,@Cmp_ID,@Created_By,GETDATE() )    
		End    
	Else if @Trans_Type = 'U'    
		BEGIN   
			--If Exists (SELECT Overhead_ID FROM T0040_OverHead_Master WHERE Cmp_ID = @Cmp_ID AND Overhead_ID <> @Overhead_ID and Effective_date <> @Effect_Date)    
			If Exists (SELECT Overhead_ID FROM T0040_OverHead_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Project_ID = @Project_ID AND OverHead_Month = @OverHead_Month AND OverHead_Year = @OverHead_Year and Overhead_ID <> @Overhead_ID)
				BEGIN		
					SET @Overhead_ID = 0 
					Return    
				END    				
			UPDATE T0040_OverHead_Master SET Project_ID = @Project_ID,Project_Cost = @Project_cost,
			OverHead_Month = @OverHead_Month,OverHead_Year = @OverHead_Year,Exchange_Rate= @Exchange_Rate,
			Cmp_ID = @Cmp_ID,Modified_By = @Created_By,Modified_Date = GETDATE()     
			WHERE overhead_ID = @Overhead_ID
		END    
    Else if @Trans_Type = 'D'    
		BEGIN    
			DELETE FROM T0040_OverHead_Master WHERE Overhead_ID = @Overhead_ID    
		END

