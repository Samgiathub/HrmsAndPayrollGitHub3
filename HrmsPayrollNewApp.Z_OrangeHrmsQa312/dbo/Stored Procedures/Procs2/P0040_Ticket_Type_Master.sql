  
  
-- =============================================  
-- Author:  Nilesh Patel   
-- Create date: 08-08-2017  
-- Description: For Ticket Type Master  
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0040_Ticket_Type_Master]  
 -- Add the parameters for the stored procedure here  
 @Ticket_Type_ID Numeric(18,0) Output,  
 @Cmp_ID Numeric(18,0),  
 @Ticket_Type Varchar(500),  
 @Ticket_Dept_ID Numeric(5,0),  
 @Ticket_Dept_Name Varchar(100),  
 @User_ID Numeric(18,0),  
 @Tran_Type Char(1)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
    set @Ticket_Type = dbo.fnc_ReverseHTMLTags(@Ticket_Type)  --added by Ronak 081021
 If @Tran_Type = 'I'  
  Begin  
   IF Exists(SELECT 1 From T0040_Ticket_Type_Master WITH (NOLOCK) Where Upper(Ticket_Type) = UPPER(@Ticket_Type) and Cmp_ID = @Cmp_ID)  
    BEGIN  
     RAISERROR('@@Same Ticket Type Exists.@@.',16,2)  
     return  
    END  
      
   Select @Ticket_Type_ID = Isnull(MAX(Ticket_Type_ID),0) + 1 From T0040_Ticket_Type_Master WITH (NOLOCK)  
   Insert into T0040_Ticket_Type_Master(Ticket_Type_ID,Cmp_ID,Ticket_Type,Ticket_Dept_ID,Ticket_Dept_Name,Sys_Datetime,User_ID)  
    Values(@Ticket_Type_ID,@Cmp_ID,@Ticket_Type,@Ticket_Dept_ID,@Ticket_Dept_Name,GETDATE(),@User_ID)   
  End  
 Else IF @Tran_Type = 'D'  
  Begin  
   IF Exists(SELECT 1 From T0090_Ticket_Application WITH (NOLOCK) Where Ticket_Type_ID = @Ticket_Type_ID and Cmp_ID = @Cmp_ID)  
    BEGIN  
     RAISERROR('@@Referance Is Exists So You Can''t Deleted It.@@.',16,2)  
     return  
    END  
   Delete From T0040_Ticket_Type_Master Where Ticket_Type_ID = @Ticket_Type_ID and Cmp_ID = @Cmp_ID  
  End  
 Else IF @Tran_Type = 'U'  
  Begin  
   IF Exists(SELECT 1 From T0040_Ticket_Type_Master WITH (NOLOCK) Where Upper(Ticket_Type) = UPPER(@Ticket_Type) and Cmp_ID = @Cmp_ID AND Ticket_Type_ID <> @Ticket_Type_ID )  
    BEGIN  
     RAISERROR('@@Same Ticket Type Exists.@@.',16,2)  
     return  
    END  
   Update T0040_Ticket_Type_Master   
    SET   
     Ticket_Type = @Ticket_Type,  
     Ticket_Dept_ID = @Ticket_Dept_ID,  
     Ticket_Dept_Name = @Ticket_Dept_Name,  
     Sys_Datetime = GETDATE(),  
     User_ID = @User_ID  
    Where Ticket_Type_ID = @Ticket_Type_ID and Cmp_ID = @Cmp_ID  
  End  
END  
  