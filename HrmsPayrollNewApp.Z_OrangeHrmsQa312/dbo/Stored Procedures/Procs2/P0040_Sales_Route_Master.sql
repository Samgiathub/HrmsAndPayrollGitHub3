


-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 23-AUG-2016
-- Description:	This is a Product Master , Created for Sales Target Import
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Sales_Route_Master]  
    @Route_ID  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@Route_Num   numeric(18,0)  
   ,@Route_Name nvarchar(200) = ''
   ,@Route_Type varchar(20)
   ,@Route_Desc varchar(500) = ''
   ,@Is_Route_Active tinyint = 0
   ,@Route_InActive_Date Datetime = null
   ,@Tran_type  varchar(1) 
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 --  If @tran_type  = 'I' Or @tran_type = 'U'
	--BEGIN 
		 
	--	If @Route_Name = ''
	--		BEGIN
	--			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Reason Name is not Properly Inserted',0,'Enter Proper Reason Name',GetDate(),'Reason Master')						
	--			Return
	--		END
	--END
 If @Route_InActive_Date = ''
	Set @Route_InActive_Date = null
	
 IF @TRAN_TYPE  = 'I'  
	  BEGIN  
		  IF exists (Select Route_ID  from dbo.T0040_Sales_Route_Master WITH (NOLOCK) Where Upper(Route_Name) = Upper(@Route_Name) and Upper(Route_Type) = Upper(@Route_Type) and Cmp_ID = @CMP_ID)   
			BEGIN  
				 SET @Route_ID = 0
				 RAISERROR('@@Same Name Already Exists@@',16,2)  
				 Return  
			END
		      
			SELECT @Route_ID = ISNULL(MAX(Route_ID),0) + 1  FROM DBO.T0040_Sales_Route_Master WITH (NOLOCK)  
		    
			INSERT INTO dbo.T0040_Sales_Route_Master(Route_ID , CMP_ID ,Route_Num , Route_Name , Route_Type , Route_Desc, IS_ACTIVE , INACTIVE_DATE) 
			VALUES (@Route_ID , @CMP_ID ,@Route_Num, @Route_Name , @Route_Type ,@Route_Desc, @Is_Route_Active , @Route_InActive_Date)
	  END  
 ELSE IF @TRAN_TYPE = 'U'  
	  BEGIN  
		   IF Exists(select Route_ID From dbo.T0040_Sales_Route_Master WITH (NOLOCK) Where Upper(Route_Name) = Upper(@Route_Name) and Upper(Route_Type) = Upper(@Route_Type) and Route_ID <> @Route_ID and CMP_ID = @CMP_ID)  
				BEGIN  
					 SET @Route_ID = 0  
					 RAISERROR('@@Same Name Already Exists@@',16,2)  
					 RETURN   
				END  
	       
				UPDATE T0040_Sales_Route_Master
				SET	 Route_Num = @Route_Num
					,Route_Name = @Route_Name
					,Route_Type = @Route_Type
					,Route_Desc = @Route_Desc
					,Is_Active = @Is_Route_Active
					,InActive_Date = @Route_InActive_Date
				WHERE Route_ID = @Route_ID and Cmp_ID = @CMP_ID			
	  END  
 Else if @TRAN_TYPE = 'D'  
	  BEGIN  
		IF NOT EXISTS (SELECT 1 FROM T0040_SALES_ASSIGNED_TARGET WITH (NOLOCK) WHERE Route_ID = @Route_ID)
			BEGIN
				DELETE FROM dbo.T0040_Sales_Route_Master WHERE Route_ID = @Route_ID  
			END
		ELSE 
			BEGIN
				SET @Route_ID = 0  
				RAISERROR('@@Cannot Delete This Route , It is Assigned to Some Employees@@',16,2)  
				RETURN   
			END
	  END 
	   
 RETURN  
  



