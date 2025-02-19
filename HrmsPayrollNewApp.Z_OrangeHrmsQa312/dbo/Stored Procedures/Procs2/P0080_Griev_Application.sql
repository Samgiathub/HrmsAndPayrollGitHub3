      
      
      
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---      
CREATE PROCEDURE [dbo].[P0080_Griev_Application]      
 @GA_ID numeric(18, 0) output  
,@Receive_Date datetime =null 
,@From numeric(18, 0)  =null 
,@Emp_IDF numeric(18, 0) =null
,@NameF varchar(500) =null 
,@AddressF varchar(500) =null 
,@EmailF varchar(500) =null    
,@ContactF varchar(500) =null  
,@Receive_From numeric(18, 0)=null  
,@Griev_Against numeric(18, 0)=null   
,@Emp_IDT	numeric(18, 0)=null
,@NameT varchar(500)=null   
,@AddressT varchar(500)  =null 
,@EmailT varchar(500) =null  
,@ContactT varchar(500)=null   
,@SubjectLine varchar(MAX)=null   
,@Details varchar(MAX)=null 
,@DocumentName varchar(MAX) =null  
,@Cmp_ID numeric(18, 0) =null  
,@CreatedDate datetime =null  
,@UpdatedDate datetime  =null 
,@User_Id varchar(MAX) =null  
,@tran_type   varchar(1) = null     
AS      
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
 IF @GA_ID = 0      
  Set @GA_ID = Null      
        
  -- Add By Mukti 07072016(start)      
  declare @OldValue as  varchar(max)      
  Declare @String as varchar(max)      
  set @String=''      
  set @OldValue =''      
 SET IDENTITY_INSERT T0080_Griev_Application ON  
 if @tran_type ='I'       
   begin      
    
   select @GA_ID = Isnull(max(GA_ID),0) + 1  From dbo.T0080_Griev_Application WITH (NOLOCK)      
  
      If exists(select GA_ID From dbo.T0080_Griev_Application LA  WITH (NOLOCK)            
       where LA.Cmp_ID = @Cmp_ID and LA.Emp_IDF = @Emp_IDF)      
             
       BEGIN      
       -- Set @Loan_App_Code = 0      
       -- RAISERROR('@@Loan already Exist',16,2)      
       RETURN       
      END      
      ELSE      
      BEGIN      
      -- set @Loan_App_Code = cast(@Loan_App_ID as Varchar(20))      
       --INSERT INTO dbo.T0080_Griev_Application      
       --        (GA_ID,Receive_Date,[From],Emp_IDF,NameF,AddressF,EmailF,ContactF,Receive_From,Griev_Against,Emp_IDT,NameT  
       --      ,AddressT,EmailT,ContactT,SubjectLine,Details,DocumentName,Cmp_ID,CreatedDate)      
       --VALUES  (@GA_ID,@Receive_Date,@From,@Emp_IDF,@NameF,@AddressF,@EmailF,@ContactF,@Receive_From,@Griev_Against,@Emp_IDT,@NameT  
       --      ,@AddressT,@EmailT,@ContactT,@SubjectLine,@Details,@DocumentName,@Cmp_ID,GETDATE())  

          INSERT INTO dbo.T0080_Griev_Application      
              (GA_ID,Griev_Against,Emp_IDT,NameT,AddressT,EmailT,ContactT,SubjectLine,Details,DocumentName,Cmp_ID,CreatedDate)      
       VALUES  (@GA_ID,@Griev_Against,@Emp_IDT,@NameT,@AddressT,@EmailT,@ContactT,@SubjectLine,@Details,@DocumentName,@Cmp_ID,GETDATE())     
       -- Add By Mukti 07072016(start)      
      --  exec P9999_Audit_get @table = 'T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output      
        set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))        
       -- Add By Mukti 07072016(end)       
      END      
 END       
 else if @tran_type ='U'       
    begin      
      --exec P9999_Audit_get @table='T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output      
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))      
    -- Add By Mukti 05072016(end)      
          
    UPDATE    T0080_Griev_Application      
    SET        
 
 Griev_Against=@Griev_Against,  
 Emp_IDT=@Emp_IDT,  
 NameT=@NameT,  
 AddressT=@AddressT,  
 EmailT=@EmailT,  
 ContactT=@ContactT,  
 SubjectLine=@SubjectLine,  
 Details=@Details,  
 DocumentName=@DocumentName,  
 Cmp_ID=@Cmp_ID,  
 CreatedDate=GETDATE()  
    where GA_ID = @GA_ID      
               
     -- Add By Mukti 05072016(start)      
     -- exec P9999_Audit_get @table = 'T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output      
      --set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))        
     -- Add By Mukti 05072016(end)       
    end      
 else if @tran_type ='D'      
       
       
   IF  @Emp_IDF = 0      
    Begin       
     If @GA_ID <> Null Or @GA_ID <> 0      
      Begin      
       
     DELETE FROM T0080_Griev_Application where GA_ID = @GA_ID           
    End      
     
        
              
       End      
   
RETURN      
      
      