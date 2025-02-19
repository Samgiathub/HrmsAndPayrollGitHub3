CREATE  PROCEDURE [dbo].[SP_Mobile_Canteen_Application_RecordView]    
 --@Compoff_App_ID numeric(18,0),    
     
 @Cmp_Id numeric(9)      
,@Emp_Id numeric(9)       
 ,@App_Id nvarchar(50)    
     
     
    
    
     
     
    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
Declare @StrResult as varchar(50)    
   
--select @Cmp_Id,@Emp_Id,@App_Type,@Canteen_Id,@Foof_Type_Id    
If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where App_Id = @App_Id and Cmp_Id=@Cmp_Id and Emp_Id=@Emp_Id)      
 begin    
  
 SELECT * FROM V0080_Canteen_Application_Mobile WHERE App_Id=@App_Id and Emp_Id=@Emp_Id    
 end    
 else    
 begin    
 set @StrResult='Sucessfull'    
 end    
    
     
     
    
    
    
    
     
    
    
    
    