  
  
-- =============================================  
-- Author:  <Jaina>  
-- Create date: <27-12-2017>  
-- Description: <Travel Payment Process>  
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0302_Payment_Process_Travel_Details]  
 @Cmp_id numeric(18,0),  
 @Emp_id numeric (18,0),  
 @Travel_Approval_Id numeric(18,0),  
 @Travel_Set_Approval_Id numeric(18,0),  
 @Payment_Process_Id numeric(18,0),  
 @Process_Type varchar(500),  
 @Tran_type char   
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
   
    IF @Tran_type = 'I'  
    BEGIN     
    SET @Payment_Process_Id = @Payment_Process_Id + 1 -- added by Yogesh Patel on 20112023 to Resolved Rollback issue
  insert INTO T0302_Payment_Process_Travel_Details (Cmp_Id,Emp_Id,Travel_Approval_Id,Travel_Set_Approval_Id,Payment_Process_Id,Process_Type)  
  VALUES (@Cmp_Id,@Emp_Id,@Travel_Approval_Id,@Travel_Set_Approval_Id,@Payment_Process_Id,@Process_Type)  
    END  
END  
  