  
--select * from T0051_Retain_Rate_Details          
--Truncate table T0051_Retain_Rate_Details          
--exec [P0040_Retaintion_Rate_Details] 0,1,119,1,2,'2020-01-01',1,'I'          
CREATE PROCEDURE [dbo].[P0040_Retaintion_Rate_Details]           
 @RRateDetail_ID numeric(9)= null Output            
   ,@RRate_ID numeric(9)           
   ,@Grd_Id numeric(9)  
   --,@Branch_ID numeric(18,0)    
   ,@mode varchar(50)          
   ,@Amount   numeric(9,2)            
   ,@From_Limit   numeric(9)            
   ,@To_Limit   numeric(9)            
   ,@Tran_Type  varchar(1)            
AS            
SET NOCOUNT ON           
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED          
SET ARITHABORT ON          
          
 IF @TRAN_TYPE  = 'I'            
  BEGIN          
    --IF EXISTS(SELECT * FROM T0051_Retaintion_Rate_Details WHERE From_Limit = @From_Limit and To_Limit=@To_Limit and Grd_Id=@Grd_Id  )  
    --BEGIN  
    -- RAISERROR ('Record Already Exist.',16,1);  
    -- RETURN   
    --END  
          
            
  INSERT INTO T0051_Retaintion_Rate_Details          
   (RRate_ID,Grd_Id,--Branch_ID,
   Mode,Amount,From_Limit,To_Limit)          
  VALUES          
   (@RRate_ID,@Grd_Id,--@Branch_ID,
   @Mode,@Amount,@From_Limit,@To_Limit)           
            
  --set @Rate_ID = Scope_Identity()           
  --select @Rate_ID as Rate_ID          
  END            
 RETURN   