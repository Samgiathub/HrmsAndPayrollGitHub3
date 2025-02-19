  
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_PAY_SCALE_MASTER]      
  @Pay_Scale_ID NUMERIC(18,0) OUTPUT      
 ,@Cmp_ID NUMERIC(18,0)      
 ,@payscale_Name VARCHAR(100)      
 ,@payscale_Details VARCHAR(Max)        
 ,@Systemdate datetime=null  
 ,@tran_type VARCHAR(1)  
 ,@User_Id NUMERIC(18,0) = 0   
 ,@IP_Address VARCHAR(30)= ''    
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
 DECLARE @OldValue AS VARCHAR(5000)  
 DECLARE @OldPayscale_Name AS VARCHAR(500)  
 DECLARE @OldPayscale_Details AS VARCHAR(5000)  
 DECLARE @Oldsystemdate  AS VARCHAR(18)  
  
 Set @OldValue = ''  
 SET @OldPayscale_Name = ''  
 SET @OldPayscale_Details = ''  
 SET @Oldsystemdate = ''  
    
   
 if @Systemdate=''  
  set @Systemdate=null   
        set @payscale_Name = dbo.fnc_ReverseHTMLTags(@payscale_Name)  --added by Ronak 081021
	    set @payscale_Details = dbo.fnc_ReverseHTMLTags(@payscale_Details)  --added by Ronak 081021
 IF @tran_type ='I'       
  BEGIN      
   IF EXISTS(SELECT Pay_Scale_ID FROM T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID       
      AND UPPER(Pay_Scale_Name) = UPPER(@payscale_Name) )    
    BEGIN      
     SET @Pay_Scale_ID = 0      
     RETURN            
    END      
     
   SELECT @Pay_Scale_ID = ISNULL(MAX(Pay_Scale_ID),0) + 1  FROM T0040_PAY_SCALE_MASTER WITH (NOLOCK)     
           
   INSERT INTO T0040_PAY_SCALE_MASTER      
     (Pay_Scale_ID,Cmp_ID,Pay_Scale_Name,Pay_Scale_Detail,Systemdate)      
    VALUES (@Pay_Scale_ID, @Cmp_ID, @payscale_Name,@payscale_Details,@Systemdate)       
       
    SET @OldValue = 'New Value' + '#'+ 'Scale Name :' + ISNULL( @payscale_Name,'') + '#'  + 'pay of scale :' + ISNULL(@payscale_Details,'') + '#' + 'Sysdate :' + CAST(@Systemdate AS VARCHAR(18))  
         
  END     
      
 ELSE IF @tran_type ='U'       
  BEGIN      
   IF EXISTS(SELECT Pay_Scale_ID FROM T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID       
      AND UPPER(Pay_Scale_Name) = UPPER(@payscale_Name) AND Pay_Scale_ID <> @Pay_Scale_ID)   
    BEGIN      
     SET @Pay_Scale_ID = 0      
     RETURN            
    END     
     
   SELECT   @OldPayscale_Name = ISNULL(Pay_Scale_Name,''),  
      @OldPayscale_Details = ISNULL(Pay_Scale_Detail,''),  
      @Oldsystemdate=cast(Systemdate as varchar(50))  
    FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Pay_Scale_ID = @Pay_Scale_ID   
                
   UPDATE T0040_PAY_SCALE_MASTER      
     SET    
      Pay_Scale_Name = @payscale_Name,  
      Pay_Scale_Detail = @payscale_Details,  
      Systemdate = @Systemdate  
     WHERE (Pay_Scale_ID = @Pay_Scale_ID)      
         
   SET @OldValue = 'old Value' + '#'+ 'Scale Name :' + @OldPayscale_Name   + '#'  + 'pay of scale :' + @OldPayscale_Details  + '#' + 'Sysdate :' + @Oldsystemdate  
               + 'New Value' + '#'+ 'Scale Name :' + ISNULL( @payscale_Name,'') + '#'  + 'pay of scale :' + ISNULL(@payscale_Details,'') + '#' + 'Sysdate :' + CAST(@Systemdate AS VARCHAR(18))  
                     
    
  END      
    
 ELSE IF @tran_type ='d'      
  BEGIN      
   SELECT   @OldPayscale_Name = ISNULL(Pay_Scale_Name,''),  
      @OldPayscale_Details = ISNULL(Pay_Scale_Detail,''),  
      @Oldsystemdate=cast(Systemdate as varchar(50))  
    FROM dbo.T0040_PAY_SCALE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Pay_Scale_ID = @Pay_Scale_ID   
     
   DELETE FROM T0040_PAY_SCALE_MASTER WHERE Pay_Scale_ID = @Pay_Scale_ID      
     
   SET @OldValue = 'old Value' + '#'+ 'Scale Name :' + @OldPayscale_Name + '#'  + 'pay of scale :' + @OldPayscale_Details  + '#' + 'Sysdate :' + @Oldsystemdate   
  END      
     
   EXEC P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Pay Scale Master',@OldValue,@Pay_Scale_ID,@User_Id,@IP_Address  
   ------      
 RETURN  
  