-- =============================================
-- Author:		Binal Prajapati
-- Create date: 20-08-2020
-- Description:	Expense Type is not bind in Travel Settlement Pages for ESS and Admin.
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Travel_Mode_Type_Reset]
	
	
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


  
		UPDATE [dbo].[T0030_TRAVEL_MODE_MASTER]
		SET [Mode_Type]=1
		WHERE Travel_Mode_Name= 'Flight' 

		UPDATE [dbo].[T0030_TRAVEL_MODE_MASTER]
		SET [Mode_Type]=2
		WHERE Travel_Mode_Name= 'Train' 

		UPDATE [dbo].[T0030_TRAVEL_MODE_MASTER]
		SET [Mode_Type]=3
		WHERE Travel_Mode_Name= 'Car' 

		UPDATE [dbo].[T0030_TRAVEL_MODE_MASTER]
		SET [Mode_Type]=4 
		WHERE Travel_Mode_Name= 'Bus' 

		UPDATE [dbo].[T0030_TRAVEL_MODE_MASTER]
		SET [Mode_Type]=7
		WHERE Travel_Mode_Name= 'Other' 

		UPDATE T0030_TRAVEL_MODE_MASTER
		SET Mode_Type=7
		WHERE isnull(Mode_Type,0)=0 
END
