


-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 04-JAN-2018
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Machine_Master]  
    @Machine_ID			NUMERIC OUTPUT
   ,@Cmp_ID				NUMERIC  
   ,@Machine_Name		VARCHAR(100)
   ,@Machine_Code		VARCHAR(50)  = ''
   ,@Machine_Type		VARCHAR(50)  = ''
   ,@Machine_Remarks	VARCHAR(500) = ''
   ,@Tran_type			CHAR(1)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
 IF @TRAN_TYPE  = 'I'  
	  BEGIN  
		  IF EXISTS (Select Machine_ID  from dbo.T0040_Machine_Master WITH (NOLOCK) Where Upper(Machine_Name) = Upper(@Machine_Name) and Upper(Machine_Type) = Upper(@Machine_Type) and Cmp_ID = @CMP_ID)   
			BEGIN  
				 SET @Machine_ID = 0
				 RAISERROR('@@Same Machine Name Already Exists@@',16,2)  
				 Return  
			END
		 
		 IF EXISTS (Select Machine_ID  from dbo.T0040_Machine_Master WITH (NOLOCK) Where Upper(Machine_Code) = Upper(@Machine_Code) and Upper(Machine_Type) = Upper(@Machine_Type) and Cmp_ID = @CMP_ID)   
			BEGIN  
				 SET @Machine_ID = 0
				 RAISERROR('@@Same Machine Code Already Exists@@',16,2)  
				 Return  
			END
		 
			INSERT INTO dbo.T0040_Machine_Master
				( Cmp_ID,	Machine_Name,	Machine_Code,	Machine_Type,	Remarks )
			VALUES 
				( @Cmp_ID , @Machine_Name , @Machine_Code , @Machine_Type , @Machine_Remarks)
				
			SET @Machine_ID = @@IDENTITY
	  END  
 ELSE IF @TRAN_TYPE = 'U'  
	  BEGIN  
		   IF Exists(select Machine_ID From dbo.T0040_Machine_Master WITH (NOLOCK) Where Upper(Machine_Name) = Upper(@Machine_Name) and Upper(Machine_Type) = Upper(@Machine_Type) and Machine_ID <> @Machine_ID and CMP_ID = @CMP_ID)  
				BEGIN  
					 SET @Machine_ID = 0  
					 RAISERROR('@@Same Machine Name Already Exists@@',16,2)  
					 RETURN   
				END  
		 IF Exists(select Machine_ID From dbo.T0040_Machine_Master WITH (NOLOCK) Where Upper(Machine_Code) = Upper(@Machine_Code) and Upper(Machine_Type) = Upper(@Machine_Type) and Machine_ID <> @Machine_ID and CMP_ID = @CMP_ID)  
			BEGIN  
				 SET @Machine_ID = 0  
				 RAISERROR('@@Same Machine Code Already Exists@@',16,2)  
				 RETURN   
			END  
	       
				UPDATE T0040_Machine_Master
				SET	 Machine_Name = @Machine_Name
					,Machine_Code = @Machine_Code
					,Machine_Type = @Machine_Type
					,Remarks = @Machine_Remarks
				WHERE Machine_ID = @Machine_ID and Cmp_ID = @CMP_ID			
	  END  
 Else IF @TRAN_TYPE = 'D'  
	  BEGIN  
		 
		 IF EXISTS (SELECT 1 FROM T0040_MACHINE_ALLOCATION_MASTER WITH (NOLOCK) WHERE Machine_ID = @Machine_ID)
			BEGIN
				SET @Machine_ID = 0  
				RAISERROR('@@Cannot Delete , This Machine is Already Assigned@@',16,2)  
				RETURN   
			END
			
		 IF EXISTS (SELECT 1 FROM T0040_MACHINE_EFFICIENCY_MASTER WITH (NOLOCK) WHERE Machine_ID = @Machine_ID)
			BEGIN
				SET @Machine_ID = 0  
				RAISERROR('@@Cannot Delete , Slab Exists for this Machine@@',16,2)  
				RETURN 
			END
		
			DELETE FROM dbo.T0040_Machine_Master WHERE Machine_ID = @Machine_ID 
	  END 
	   
 RETURN  
  



