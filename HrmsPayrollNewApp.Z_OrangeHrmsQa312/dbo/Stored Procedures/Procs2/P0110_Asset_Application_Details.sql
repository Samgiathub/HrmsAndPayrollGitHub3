        
        
        
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---        
CREATE PROCEDURE [dbo].[P0110_Asset_Application_Details]        
 --@Asset_ApplicationDet_ID numeric OUTPUT        
 @Asset_Application_ID numeric         
 ,@Cmp_ID numeric        
 ,@Asset_Id numeric        
 ,@AssetM_Id numeric        
 ,@status CHAR(1)        
 ,@Tran_type CHAR(1)        
AS        
SET NOCOUNT ON         
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
SET ARITHABORT ON        
        
 declare @Asset_ApplicationDet_ID numeric        
        
if @AssetM_Id=0        
 set @AssetM_Id =null        
        
IF @Tran_type = 'I'        
 BEGIN        
  select @Asset_ApplicationDet_ID = isnull(max(Asset_ApplicationDet_ID),0) + 1  from T0110_Asset_Application_Details WITH (NOLOCK)        
  insert into T0110_Asset_Application_Details (Asset_ApplicationDet_ID,Asset_Application_ID,Cmp_ID,Asset_Id,AssetM_Id,status)        
  Values(@Asset_ApplicationDet_ID,@Asset_Application_ID,@Cmp_ID,@Asset_Id,@AssetM_Id,@status)        
             
 END          
ELSE IF @Tran_type = 'U'        
 BEGIN         
  --if exists()        
  -- begin        
           
  -- end        
  --else        
   BEGIN        
            
    --delete from T0110_Asset_Application_Details where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id        
           
    select @Asset_ApplicationDet_ID = isnull(max(Asset_ApplicationDet_ID),0) + 1  from T0110_Asset_Application_Details WITH (NOLOCK)        
    insert into T0110_Asset_Application_Details (Asset_ApplicationDet_ID,Asset_Application_ID,Cmp_ID,Asset_Id,AssetM_Id,status)        
    Values(@Asset_ApplicationDet_ID,@Asset_Application_ID,@Cmp_ID,@Asset_Id,@AssetM_Id,@status)        
   end        
   --   update T0110_Asset_Application_Details         
   --set         
   -- Asset_Id=@Asset_Id,        
   -- AssetM_Id=@AssetM_Id,        
   -- status=@status        
   --where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id        
             
        
 End        
--Else if @Tran_Type = 'D'            
-- Begin        
--  Delete from T0100_Asset_Application where Asset_Application_ID = @Asset_Application_ID        
-- End           
         
RETURN        
        