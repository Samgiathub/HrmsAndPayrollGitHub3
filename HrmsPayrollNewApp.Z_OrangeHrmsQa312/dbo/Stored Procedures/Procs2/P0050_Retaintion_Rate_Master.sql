--select * from T0050_Retaintion_Rate_Master      
--Truncate table T0050_Retaintion_Rate_Master      
--exec P0050_Retaintion_Rate_Master @RRate_ID='0',@RRateDetail_ID='0', @Grd_ID=406,@Cmp_ID=120,@AD_ID=1129,@Eff_Date='2022-01-06 00:00:00',@Login_Id=7013,@Tran_Type='I'       
--exec P0050_Retaintion_Rate_Master 0,0,379,120,1129,'2020-01-01',1,'I'      
--exec P0050_Retaintion_Rate_Master @RRate_ID='2',@RRateDetail_ID=1,@Grd_ID=1129,@Cmp_ID=379,@AD_ID=120,@Eff_Date='2021-03-03 15:32:13.857',@Login_Id=0,@Tran_Type='D'       
CREATE PROCEDURE [dbo].[P0050_Retaintion_Rate_Master]        
    @RRate_ID numeric(9)       
   ,@RRateDetail_ID numeric(9)     
 --  ,@Branch_ID numeric(18,0)    
   ,@Cmp_ID   numeric(9)      
   ,@AD_ID   numeric(9)        
   ,@Grd_ID   numeric(9)        
   ,@Eff_Date Datetime      
   ,@Login_Id numeric(9)       
   ,@Tran_Type  varchar(1)      
AS        
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
          
  Declare @Uni_ID Numeric(18,0)      
  Set @Uni_ID = 0       
           
         
 IF @TRAN_TYPE  = 'I'        
  BEGIN          
  IF EXISTS (SELECT RRate_Id FROM dbo.T0050_Retaintion_Rate_Master WITH (NOLOCK) WHERE Grd_ID = @Grd_ID and Cmp_Id = @Cmp_ID and AD_ID = @AD_ID and Effective_date = @Eff_Date)         
  BEGIN      
  -- SET @RRate_ID = 0      
   --print @Tran_ID      
   select @RRate_ID as RRate_ID      
   RETURN      
  END      
        
  INSERT INTO T0050_Retaintion_Rate_Master      
   (Grd_ID,--Branch_ID,
   Cmp_ID,AD_ID,Effective_date,Login_Id,System_Date)      
  VALUES      
   (@Grd_ID,--@Branch_ID,
   @Cmp_ID,@AD_ID,@Eff_Date,@Login_Id,SYSDATETIME())       
        
  set @RRate_ID = Scope_Identity()       
  select @RRate_ID as RRate_ID      
  END         
 ELSE IF @Tran_Type = 'D'        
  BEGIN          
       
  --DECLARE @RateID int = 0      
  --Select @RateID = RRate_ID from T0051_Retaintion_Rate_Details WITH (NOLOCK) Where RRateDetail_ID = 1      
  --print @RateID      
  --Select Count(1) from T0051_Retaintion_Rate_Details WITH (NOLOCK) Where RRate_ID = (Select RRate_ID from T0051_Retaintion_Rate_Details WITH (NOLOCK) Where RRateDetail_ID = 1)      
  IF ((Select Count(1) from T0051_Retaintion_Rate_Details WITH (NOLOCK)       
   Where RRate_ID = (Select RRate_ID from T0051_Retaintion_Rate_Details WITH (NOLOCK)       
        Where RRateDetail_ID = @RRateDetail_ID)) = 1)      
   BEGIN       

       IF EXISTS(SELECT * FROM T0210_Retaining_Datewise_Payment WHERE Slab_Id = @RRateDetail_ID and remarks= 'FINAL')  
    BEGIN  
     RAISERROR ('Cannot be Deleted Reference Already Exist In Payment Process.',16,1);  
     RETURN   
    END  

     DELETE FROM dbo.T0050_Retaintion_Rate_Master       
     Where RRate_ID = (Select RRate_ID from T0051_Retaintion_Rate_Details WITH (NOLOCK)       
     Where RRateDetail_ID = @RRateDetail_ID)      
      
     DELETE FROM dbo.T0051_Retaintion_Rate_Details WHERE RRateDetail_ID = @RRateDetail_ID      
     select 0 as RRate_ID      
     RETURN      
   END      
   ELSE      
   BEGIN    
    IF EXISTS(SELECT * FROM T0210_Retaining_Datewise_Payment WHERE Slab_Id = @RRateDetail_ID and remarks= 'FINAL')  
    BEGIN  
     RAISERROR ('Cannot be Deleted Reference Already Exist In Payment Process.',16,1);  
     RETURN   
    END
     DELETE FROM dbo.T0051_Retaintion_Rate_Details WHERE RRateDetail_ID = @RRateDetail_ID      
     select 0 as RRate_ID      
     RETURN      
   END      
        
  END        
 RETURN 