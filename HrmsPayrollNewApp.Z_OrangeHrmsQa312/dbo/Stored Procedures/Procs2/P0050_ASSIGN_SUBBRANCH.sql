  --exec P0050_ASSIGN_VERTICAL_SUBVERTICAL '1','119','25394','#6/8/2021 12:00:00 AM#','48#51#46','7013','U'    
      
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---      
CREATE PROCEDURE [dbo].[P0050_ASSIGN_SUBBRANCH]      
      
   @TRAN_ID INT OUTPUT      
  ,@CMP_ID INT      
  ,@EMP_ID NUMERIC      
  ,@EFFECTIVE_DATE DATETIME      
  ,@SUBBRANCH_ID VARCHAR(500)      
  ,@LOGIN_ID INT = 0 -- UserID      
  ,@TRANS_TYPE CHAR(1)      
        
        
AS      
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
      
 IF @TRANS_TYPE ='I'       
  begin      
  select @EFFECTIVE_DATE
  -- code updated start'08-06-2021'    
   if exists(select emp_id from T0050_Assign_SubBranch WITH (NOLOCK) where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and Effective_Date = @EFFECTIVE_DATE)    
      begin     
   set @TRAN_ID = -1      
   return     
   end     
  -- code updated end'08-06-2021'    
   IF ISNULL(@EFFECTIVE_DATE,'') = ''      
    BEGIN      
     RAISERROR (N'Effective Date cannot b e blank.', 16, 2);       
    END      
       
   SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM dbo.T0050_Assign_SubBranch WITH (NOLOCK)      
          
   INSERT INTO dbo.T0050_Assign_SubBranch      
    (TRAN_ID,CMP_ID,EMP_ID,EFFECTIVE_DATE,SubBranch_ID,USER_ID)       
   VALUES      
    (@TRAN_ID,@CMP_ID,@EMP_ID,@EFFECTIVE_DATE,@SUBBRANCH_ID,@LOGIN_ID)         
   ------ AUDIT ----      
   -- exec P9999_Audit_get @table = 'T0050_ASSIGN_VERTICALSUBVERTICAL' ,@key_column='TRAN_ID',@key_Values=@TRAN_ID,@String=@String output      
   -- set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))        
   ------ AUDIT END ----      
        
  end       
 ELSE IF @TRANS_TYPE ='U'       
    BEGIN      
          
          
     --exec P9999_Audit_get @table='T0050_ASSIGN_VERTICALSUBVERTICAL' ,@key_column='TRAN_ID',@key_Values=@BOND_ID,@String=@String output      
     --set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      
        
 ---old code started    
     --DELETE FROM T0050_ASSIGN_VERTICALSUBVERTICAL WHERE TRAN_ID = @TRAN_ID      
    --INSERT INTO dbo.T0050_ASSIGN_VERTICALSUBVERTICAL      
     -- (TRAN_ID,CMP_ID,EMP_ID,EFFECTIVE_DATE,VERTICAL_ID,USER_ID)       
     --VALUES      
     -- (@TRAN_ID,@CMP_ID,@EMP_ID,@EFFECTIVE_DATE,@VERTICAL_ID,@LOGIN_ID)      
     ---old code ended    
       -- code updated start'08-06-202    
   update T0050_Assign_SubBranch set CMP_ID=@CMP_ID,    
    SubBranch_ID=@SUBBRANCH_ID,User_ID=@LOGIN_ID WHERE Emp_ID = @EMP_ID  and Tran_ID=@TRAN_ID and EFFECTIVE_DATE=@EFFECTIVE_DATE    
       -- code updated end '08-06-2021'    
    
  --SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1  FROM dbo.T0050_ASSIGN_VERTICALSUBVERTICAL WITH (NOLOCK)      
    
     --exec P9999_Audit_get @table = 'T0050_ASSIGN_VERTICALSUBVERTICAL' ,@key_column='TRAN_ID',@key_Values=@BOND_ID,@String=@String output      
     --set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))        
    END        
          
 ELSE IF @TRANS_TYPE ='D'      
   begin      
          
    --exec P9999_Audit_get @table='T0050_ASSIGN_VERTICALSUBVERTICAL' ,@key_column='TRAN_ID',@key_Values=@TRAN_ID,@String=@String output      
    --set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      
        
          
    DELETE  FROM dbo.T0050_Assign_SubBranch WHERE TRAN_ID = @TRAN_ID        
          
    --EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRANS_TYPE,'ASSIGN VERTICAL SUBVERTICAL',@OLDVALUE,@BOND_ID,@USER_ID,@IP_ADDRESS      
   End      
 ELSE IF @TRANS_TYPE='E'      
   BEGIN      
         
    SELECT TRAN_ID,CMP_ID,EMP_ID,EFFECTIVE_DATE,SubBranch_ID      
    FROM T0050_Assign_SubBranch WITH (NOLOCK)      
    WHERE CMP_ID=@CMP_ID AND TRAN_ID = @TRAN_ID      
          
   END      
         
RETURN      
      