  
  
  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_BOND_MASTER]  
  
   @BOND_ID NUMERIC(18) OUTPUT  
  ,@CMP_ID NUMERIC(18,0)  
  ,@BOND_NAME VARCHAR(100)  
  ,@BOND_SHORT_NAME VARCHAR(50)  
  ,@BOND_AMOUNT NUMERIC(18,0)  
  ,@BOND_COMMENTS VARCHAR(100)  
  ,@NO_OF_INSTALLMENT NUMERIC(9,2) = 1   
  ,@Grade_Wise_Details VARCHAR(500)  
  ,@TRAN_TYPE CHAR(1)  
  ,@USER_ID NUMERIC(18,0) = 0  
  ,@IP_ADDRESS VARCHAR(30)= ''  
    
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
DECLARE @TRANS_ID   NUMERIC(18,0)   
DECLARE @ID     NUMERIC(18,0)   
DECLARE @AMOUNT    NUMERIC(18,0)  
DECLARE @MAX_DESIGN_TRAN_ID NUMERIC(18,0)  
DECLARE @OldValue  as  VARCHAR(MAX)  
DECLARE @String   as  VARCHAR(MAX)  
  
SET @String=''  
SET @OldValue =''  
  
   set @BOND_NAME = dbo.fnc_ReverseHTMLTags(@BOND_NAME) --Ronak_060121  
    set @BOND_SHORT_NAME = dbo.fnc_ReverseHTMLTags(@BOND_SHORT_NAME) --Ronak_060121  
	 set @BOND_COMMENTS = dbo.fnc_ReverseHTMLTags(@BOND_COMMENTS) --Ronak_060121  
  
 IF @TRAN_TYPE ='I'   
  begin  
   IF ISNULL(@BOND_NAME,'') = ''  
    BEGIN  
     RAISERROR (N'Bond Name cannot be blank.', 16, 2);   
    END  
    
    
   IF EXISTS(SELECT BOND_ID  FROM dbo.T0040_BOND_MASTER WITH (NOLOCK) WHERE (UPPER(BOND_NAME) = UPPER(@BOND_NAME))AND CMP_ID = @CMP_ID) OR   
    EXISTS(SELECT LOAN_ID  FROM dbo.T0040_LOAN_MASTER WITH (NOLOCK) WHERE (UPPER(LOAN_NAME) = UPPER(@BOND_NAME))AND CMP_ID = @CMP_ID)  
    BEGIN   
      
     SET @BOND_ID=0  
    END  
   ELSE  
    begin  
     IF @BOND_SHORT_NAME <> ''  
      BEGIN  
       IF EXISTS(SELECT BOND_ID  FROM dbo.T0040_BOND_MASTER WITH (NOLOCK) WHERE (UPPER(BOND_SHORT_NAME) = UPPER(@BOND_SHORT_NAME)) AND CMP_ID = @CMP_ID) OR   
        EXISTS(SELECT LOAN_ID  FROM dbo.T0040_LOAN_MASTER WITH (NOLOCK) WHERE (UPPER(LOAN_SHORT_NAME) = UPPER(@BOND_SHORT_NAME)) AND CMP_ID = @CMP_ID)  
       BEGIN  
        SET @BOND_ID=0  
       END  
      END  
          
     SELECT @BOND_ID = ISNULL(MAX(BOND_ID),0) FROM dbo.T0040_BOND_MASTER WITH (NOLOCK)  
  
     IF @BOND_ID IS NULL OR @BOND_ID = 0  
      SET @BOND_ID =1  
     ELSE  
      SET @BOND_ID = @BOND_ID + 1    
        
        
     INSERT INTO dbo.T0040_BOND_MASTER  
      (BOND_ID,CMP_ID,BOND_NAME,BOND_SHORT_NAME,BOND_AMOUNT,NO_OF_INSTALLMENT,BOND_COMMENTS,GRADE_DETAILS)   
     VALUES  
      (@BOND_ID,@CMP_ID,@BOND_NAME,@BOND_SHORT_NAME,@BOND_AMOUNT,@NO_OF_INSTALLMENT,@BOND_COMMENTS,@Grade_Wise_Details)  
       
       
   ---- AUDIT ----  
    exec P9999_Audit_get @table = 'T0040_BOND_MASTER' ,@key_column='BOND_ID',@key_Values=@BOND_ID,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
   ---- AUDIT END ----  
    end  
  end   
 ELSE IF @TRAN_TYPE ='U'   
    BEGIN  
      
     
      IF EXISTS (SELECT BOND_ID  FROM dbo.T0040_BOND_MASTER WITH (NOLOCK) WHERE (UPPER(BOND_NAME) = UPPER(@BOND_NAME) OR UPPER(BOND_SHORT_NAME) = UPPER(@BOND_SHORT_NAME))AND CMP_ID = @CMP_ID AND BOND_ID <> @BOND_ID) OR  
       EXISTS(SELECT LOAN_ID  FROM dbo.T0040_LOAN_MASTER WITH (NOLOCK) WHERE UPPER(LOAN_NAME) = UPPER(@BOND_NAME) AND CMP_ID = @CMP_ID)   
       BEGIN  
        SET @BOND_ID=0  
        RETURN  
       END  
      
       exec P9999_Audit_get @table='T0040_BOND_MASTER' ,@key_column='BOND_ID',@key_Values=@BOND_ID,@String=@String output  
       set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
       
       UPDATE dbo.T0040_BOND_MASTER   
       SET BOND_NAME = @BOND_NAME,  
        BOND_SHORT_NAME = @BOND_SHORT_NAME,  
        BOND_AMOUNT=@BOND_AMOUNT,  
        BOND_COMMENTS=@BOND_COMMENTS,  
        NO_OF_INSTALLMENT = @NO_OF_INSTALLMENT,  
        GRADE_DETAILS = @Grade_Wise_Details  
        WHERE BOND_ID = @BOND_ID AND CMP_ID = @CMP_ID   
        
       exec P9999_Audit_get @table = 'T0040_BOND_MASTER' ,@key_column='BOND_ID',@key_Values=@BOND_ID,@String=@String output  
       set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
      
    END    
      
 ELSE IF @TRAN_TYPE ='D' OR @TRAN_TYPE ='D'   
   begin  
      
    exec P9999_Audit_get @table='T0040_BOND_MASTER' ,@key_column='BOND_ID',@key_Values=@BOND_ID,@String=@String output  
    set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    
      
    DELETE  FROM dbo.T0040_BOND_MASTER WHERE BOND_ID=@BOND_ID     
      
    EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRAN_TYPE,'BOND MASTER',@OLDVALUE,@BOND_ID,@USER_ID,@IP_ADDRESS  
   End  
 ELSE IF @TRAN_TYPE='E'  
   BEGIN  
     
    SELECT BOND_ID,CMP_ID,BOND_NAME,BOND_SHORT_NAME,BOND_AMOUNT,NO_OF_INSTALLMENT,BOND_COMMENTS,GRADE_DETAILS   
    FROM T0040_BOND_MASTER WITH (NOLOCK)  
    WHERE CMP_ID=@CMP_ID AND BOND_ID = @BOND_ID  
      
   END  
     
RETURN  
  
  
   