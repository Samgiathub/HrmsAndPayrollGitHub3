
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 
 
CREATE PROCEDURE [dbo].[P0040_Vehicle_Master]

	@Vehicle_ID numeric(18,0) OUTPUT,
	@Vehicle_Name varchar(50), 
	@Vehicle_No varchar(50),
	@Vehicle_Type varchar(50),
	@Vehicle_Owner varchar(50), 
	@Owner_Name varchar(50), 
	@Owner_ContactNo varchar(50),
	@Driver_Name varchar(50),
	@Driver_ContactNo varchar(50),
	@Cmp_ID numeric(18,0),
	@Login_Id numeric(18,0),
	@Trans_Type char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Trans_Type  = 'I'
	BEGIN
		IF EXISTS(SELECT Vehicle_ID FROM T0040_Vehicle_Master WITH (NOLOCK) WHERE UPPER(Vehicle_Name) = UPPER(@Vehicle_Name) AND UPPER(Vehicle_No) = UPPER(@Vehicle_No))  
			BEGIN  
				SET @Vehicle_ID = 0  
				RETURN  
			END
		
		SELECT @Vehicle_ID = ISNULL(MAX(Vehicle_ID), 0) + 1 FROM T0040_Vehicle_Master WITH (NOLOCK) 
		
		INSERT INTO T0040_Vehicle_Master(Vehicle_ID,Vehicle_Name,Vehicle_No,Vehicle_Type,Vehicle_Owner,Owner_Name,Owner_ContactNo,
		Driver_Name,Driver_ContactNo,Cmp_ID,Created_By,Created_Date) VALUES(@Vehicle_ID,@Vehicle_Name,@Vehicle_No,@Vehicle_Type,
		@Vehicle_Owner,@Owner_Name,@Owner_ContactNo,@Driver_Name,@Driver_ContactNo,@Cmp_ID,@Login_Id,GETDATE())
	
	END
ELSE IF @Trans_Type  = 'U'	
	BEGIN
		IF EXISTS(SELECT Vehicle_ID FROM T0040_Vehicle_Master WITH (NOLOCK) WHERE Vehicle_ID <> @Vehicle_ID AND UPPER(Vehicle_Name) = UPPER(@Vehicle_Name) AND UPPER(Vehicle_No) = UPPER(@Vehicle_No))  
			BEGIN  
				SET @Vehicle_ID = 0  
				RETURN  
			END
		UPDATE T0040_Vehicle_Master SET Vehicle_Name = @Vehicle_Name,Vehicle_No = @Vehicle_No,Vehicle_Type = @Vehicle_Type,
		Vehicle_Owner = @Vehicle_Owner,Owner_Name = @Owner_Name,Owner_ContactNo = @Owner_ContactNo,Driver_Name = @Driver_Name,
		Driver_ContactNo = @Driver_ContactNo,Cmp_ID = @Cmp_ID,Modify_By = @Login_Id,Modify_Date = GETDATE()
		WHERE Vehicle_ID = @Vehicle_ID
	
	END
ELSE IF @Trans_Type  = 'D'	
	BEGIN
		DELETE FROM T0040_Vehicle_Master WHERE Vehicle_ID = @Vehicle_ID
	END

