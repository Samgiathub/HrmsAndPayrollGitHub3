



  
  
  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0100_LOAN_APPLICATION]  
   @Loan_App_ID Numeric output  
  ,@Cmp_ID Numeric  
  ,@Emp_ID Numeric  
  ,@Loan_App_Date Datetime  
  ,@Loan_App_Code varchar(20)  
  ,@Loan_ID Numeric  
  ,@Loan_App_Amount Numeric  
  ,@Loan_App_No_of_Installment Numeric  
  ,@Loan_App_Installment_Amount Numeric(12,2)  
  ,@Loan_App_Comments varchar(250)  
  ,@Loan_Mode   char(1)  
  ,@contact_no  varchar(30)  
  ,@email_Id   varchar(50)  
  ,@Guarantor_Emp_ID  Numeric  --Ankit 02052014  
  ,@tran_type   varchar(1)  
  ,@Installment_Start_Date Datetime --Hardik 06/08/2014  
  ,@Interest_Type  varchar(20) = '' --Added by Gadriwala Muslim 10032015  
  ,@Interest_Per  numeric(18,4) = 0 --Added by Gadriwala Muslim 10032015  
  ,@Loan_Require_Date datetime = null --Added by Gadriwala Muslim 11032015  
  ,@Attachment_Path  varchar(max) = ''--Added by Gadriwala Muslim 11032015   
  ,@No_of_Inst_Loan_Amt numeric(18,0) = 0 --Added by nilesh patel on 17072015  
  ,@Total_Loan_Int_Amount numeric(18,2) = 0 --Added by nilesh patel on 20072015  
  ,@Loan_Int_Installment_Amount numeric(18,2) = 0 --Added by nilesh patel on 20072015  
  ,@Guarantor2_Emp_ID numeric(18,2) = 0  --Mukti 17112015  
  ,@User_Id numeric(18,0) = 0, -- Add By Mukti 07072016  
      @IP_Address varchar(30)= '' -- Add By Mukti 07072016  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 IF @Guarantor_Emp_ID = 0  
  Set @Guarantor_Emp_ID = Null  
    
  -- Add By Mukti 07072016(start)  
  declare @OldValue as  varchar(max)  
  Declare @String as varchar(max)  
  set @String=''  
  set @OldValue =''  
 -- Add By Mukti 07072016(end)   
   set @Loan_App_Comments = dbo.fnc_ReverseHTMLTags(@Loan_App_Comments)  --added by Ronak 100121  

 --  RAISERROR ('Reference exists, record can''t delete.', 16, 2) 							
	--return -1
 if @tran_type ='I'   
   begin  
     
 -- declare @Emp_Code as numeric  
 -- declare @str_Emp_Code as varchar(20)  
   select @Loan_App_ID = Isnull(max(Loan_App_ID),0) + 1  From dbo.T0100_LOAN_APPLICATION WITH (NOLOCK)  

	
       
   /* select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID  
      
    SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code)   
     
    select @Loan_App_Code =   cast(isnull(max(substring(Loan_App_Code,8,len(Loan_App_Code))),0) + 1 as varchar)    
      from T0100_LOAN_APPLICATION  where Emp_ID = @Emp_ID  
       
    If charindex(':',@Loan_App_Code) > 0   
     Begin  
      Select @Loan_App_Code = right(@Loan_App_Code,len(@Loan_App_Code) - charindex(':',@Loan_App_Code))  
     End  
      if @Loan_App_Code is not null  
       begin  
        while len(@Loan_App_Code) <> 4  
          begin  
            set @Loan_App_Code = '0' + @Loan_App_Code  
           end  
          set @Loan_App_Code = 'LA'+ @str_Emp_Code +':'+ @Loan_App_Code    
       end  
      else  
      Begin  
       SET @Loan_App_Code = 'LA' + @str_Emp_Code + ':' + '0001'   
      End  
      
     --Comment By Girish on 15-Mar-2010  
      --UPDATE    T0080_EMP_MASTER  
      --SET        Mobile_No = @contact_no,  
       --  Other_Email= @email_Id  
              
       -- WHERE     (Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID)  
       */  
	   --If exists(select Emp_ID From dbo.T0100_Loan_Application LA where Cmp_ID=@Cmp_ID and Loan_status='R' and Emp_ID=@Emp_ID)  
         
    --   BEGIN  
    --    Set @Loan_App_Code = 0  
    --    RAISERROR('@Loan application previously rejected',16,2)  
    --   RETURN   
    --  END 
    --  If exists(SELECT Emp_ID FROM V0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and loan_app_id IS NULL and Loan_Apr_Pending_Amount<>0.00)  
         
    --   BEGIN  
    --    Set @Loan_App_Code = 0  
    --    RAISERROR('@@Loan already Exist',16,2)  
    --   RETURN   
    --  END  
	  
      /* IF Exists Condition added by Mihir 06102011*/  

      If exists(select Emp_ID From dbo.T0100_Loan_Application LA  WITH (NOLOCK)        
       where LA.Cmp_ID = @Cmp_ID and LA.Emp_ID = @Emp_ID and LA.Loan_ID = @Loan_ID and LA.Loan_status <> 'A' and   
       LA.Loan_App_Date = @Loan_App_Date)  
         
       BEGIN  
        Set @Loan_App_Code = 0  
        RAISERROR('@@Loan already Exist',16,2)  
       RETURN   
      END  
	  
      ELSE  
      BEGIN  
	   If exists(SELECT Emp_ID FROM V0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and loan_app_id IS NULL and Loan_Apr_Pending_Amount<>0.00)  
         
       BEGIN  
        Set @Loan_App_Code = 0  
        RAISERROR('@@Loan already Exist',16,2)  
       RETURN   
      END  
       set @Loan_App_Code = cast(@Loan_App_ID as Varchar(20))  
       INSERT INTO dbo.T0100_LOAN_APPLICATION  
                            (Loan_App_ID, Cmp_ID, Emp_ID,Loan_App_Date,Loan_App_Code,Loan_ID,Loan_App_Amount,Loan_App_No_of_Insttlement,Loan_App_Installment_Amount,Loan_App_Comments,Loan_status,Guarantor_Emp_ID,Installment_Start_Date,Loan_Interest_Type,Loan_Interest_Per,Loan_Require_Date,Attachment_Path,No_of_Inst_Loan_Amt,Total_Loan_Int_Amount,Loan_Int_Installment_Amount,Guarantor_Emp_ID2)  
       VALUES      (@Loan_App_ID,@Cmp_ID, @Emp_ID,@Loan_App_Date,@Loan_App_Code,@Loan_ID,@Loan_App_Amount,@Loan_App_No_of_Installment,@Loan_App_Installment_Amount,@Loan_App_Comments,@Loan_Mode,@Guarantor_Emp_ID,@Installment_Start_Date,@Interest_Type,@Interest_Per,@Loan_Require_Date,@Attachment_Path,@No_of_Inst_Loan_Amt,@Total_Loan_Int_Amount,@Loan_Int_Installment_Amount,@Guarantor2_Emp_ID) --Added by Gadriwala Muslim 10032015  
         



		 
		 --Added by ronakk 24112022 for dynamic hierarchy

		 Declare @SCEID int 
 		 --select @SCEID = Scheme_ID from  V0095_EMP_SCHEME where Emp_ID=@Emp_ID and Scheme_Type = 'Loan'
		               --Change by ronakk 18012023
					  SELECT DISTINCT @SCEID = T.Scheme_Id from T0095_EMP_SCHEME T 
					  Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
					  WHERE
					  Emp_ID = @Emp_ID And 
					  Type = 'Loan'
					  AND Effective_Date = (SELECT max(Effective_Date) 
					  from T0095_EMP_SCHEME where Emp_ID = @Emp_ID And Type = 'Loan' 
					  AND Effective_Date <= getdate())  
					  and (SELECT distinct Loan_ID from T0100_LOAN_APPLICATION where Loan_App_ID = @Loan_App_ID) IN (select data from dbo.split(leave,'#')) 


		        insert into T0080_Loan_HycScheme
				select @Cmp_ID,SDM.Rpt_Level,SDM.Scheme_Id,DHV.DynHierColId,SDM.Leave,@Emp_ID,@Loan_App_ID,DHV.DynHierColValue,GETDATE()
				from T0040_Scheme_Master SM
				inner join T0050_Scheme_Detail  SDM on SDM.Scheme_Id = SM.Scheme_Id
				inner join T0080_DynHierarchy_Value DHV on DHV.DynHierColId = SDM.Dyn_Hier_Id  and DHV.Cmp_ID = SDM.Cmp_Id
				where SM.Cmp_Id=@Cmp_ID and SM.Scheme_Type='Loan' and Emp_ID=@Emp_ID and SDM.Scheme_Id = @SCEID
				and DHV.IncrementId = (select max(IncrementId) from T0080_DynHierarchy_Value where Emp_ID=@Emp_ID)

		--End by ronakk 24112022


       -- Add By Mukti 07072016(start)  
        exec P9999_Audit_get @table = 'T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output  
        set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
       -- Add By Mukti 07072016(end)   
      END  
 END   
 else if @tran_type ='U'   
    begin  
/*     UPDATE    T0080_EMP_MASTER  
     SET        Mobile_No = @contact_no,  
         Other_Email= @email_Id  
     WHERE     (Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID)  
*/      
    -- Add By Mukti 05072016(start)  
      exec P9999_Audit_get @table='T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output  
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    -- Add By Mukti 05072016(end)  

    IF NOT EXISTS (SELECT 1 FROM dbo.T0040_LOAN_MASTER WHERE Loan_ID = @Loan_ID)
    BEGIN

        PRINT 'Invalid Loan_ID. Please check the Loan_ID before updating.';
        RETURN; 
    END
    UPDATE    T0100_LOAN_APPLICATION  
    SET  Cmp_ID = @Cmp_ID,  
         Emp_ID = @Emp_ID,  
         Loan_App_Date=@Loan_App_Date,  
         Loan_App_Code=@Loan_App_Code,  
         Loan_ID=@Loan_ID,  
         Loan_App_Amount=@Loan_App_Amount,  
         Loan_App_No_of_Insttlement=@Loan_App_No_of_Installment,  
         Loan_App_Installment_Amount=@Loan_App_Installment_Amount,  
         Loan_App_Comments=@Loan_App_Comments,  
         Loan_status=@Loan_Mode,  
         Guarantor_Emp_ID = @Guarantor_Emp_ID,  
         Installment_Start_Date = @Installment_Start_Date,  
         Loan_Interest_Type = @Interest_Type,   --Added by Gadriwala Muslim 10032015  
         Loan_Interest_Per = @Interest_Per, --Added by Gadriwala Muslim 10032015  
         Loan_Require_Date = @Loan_Require_Date, --Added by Gadriwala Muslim 11032015  
         Attachment_Path = @Attachment_Path, --Added by Gadriwala Muslim 11032015  
         No_of_Inst_Loan_Amt = @No_of_Inst_Loan_Amt, --Added by Nilesh Patel on 17072015  
         Total_Loan_Int_Amount = @Total_Loan_Int_Amount,  
         Loan_Int_Installment_Amount = @Loan_Int_Installment_Amount,  
         Guarantor_Emp_ID2=@Guarantor2_Emp_ID  --Mukti 17112015  
         where Loan_App_ID = @Loan_App_ID  
           
     -- Add By Mukti 05072016(start)  
      exec P9999_Audit_get @table = 'T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output  
      set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
     -- Add By Mukti 05072016(end)   
    end  
 else if @tran_type ='D'  
   
   --DELETE FROM T0100_LOAN_APPLICATION where Loan_App_ID = @Loan_App_ID  
     
   -- Ankit 21052014 --  
   IF  @Emp_ID = 0  
    Begin   
     If @Loan_App_ID <> Null Or @Loan_App_ID <> 0  
      Begin  
       --Delete From T0115_Loan_Level_Approval Where Loan_App_ID = @Loan_App_ID  
       if Exists(Select 1 From T0115_Loan_Level_Approval WITH (NOLOCK) Where Loan_App_ID = @Loan_App_ID)  
        BEGIN  
          Set @Loan_App_ID = 0  
          Return @Loan_App_ID  
        End  
      End  
    -- Add By Mukti 07072016(start)  
      exec P9999_Audit_get @table='T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output  
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    -- Add By Mukti 07072016(end)  
       
     DELETE FROM T0100_LOAN_APPLICATION where Loan_App_ID = @Loan_App_ID   
	  delete from T0080_Loan_HycScheme where AppId  = @Loan_App_ID  --Added by ronakk 18012023
    End  
   Else   
    Begin   
     declare @Tran_id as numeric(18,0)  
     declare @Rm_emp_id as numeric(18,0)  
     set @Rm_emp_id = 0  
     set @Tran_id = 0  
       
     select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_Loan_Level_Approval WITH (NOLOCK) where  Loan_App_ID = @Loan_App_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_Loan_Level_Approval WITH (NOLOCK) where Loan_App_ID = @Loan_App_ID )  
    
     If @Rm_emp_id = @Emp_ID And @Tran_id > 0  
      Begin  
       Delete T0115_Loan_Level_Approval where Tran_ID = @Tran_id and Loan_App_ID = @Loan_App_ID  
      End   
     Else  
      Begin   
       -- Add By Mukti 07072016(start)  
        exec P9999_Audit_get @table='T0100_LOAN_APPLICATION' ,@key_column='Loan_App_ID',@key_Values=@Loan_App_ID,@String=@String output  
        set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
       -- Add By Mukti 07072016(end)  
               
       DELETE FROM T0100_LOAN_APPLICATION where Loan_App_ID = @Loan_App_ID  
	   delete from T0080_Loan_HycScheme where AppId  = @Loan_App_ID  --Added by ronakk 18012023

      End         
       End  
   -- Ankit 21052014 --  
   exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Loan Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
RETURN  
  
  
  
  
