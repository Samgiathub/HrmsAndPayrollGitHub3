  
  
CREATE PROCEDURE [dbo].[P0120_LOAN_APPROVAL]  
  @Loan_Apr_ID   Numeric output  
 ,@Cmp_ID    Numeric  
 ,@Loan_App_ID   Numeric  
 ,@Emp_ID    Numeric  
 ,@Loan_Apr_Date   Datetime  
 ,@Loan_Apr_Code   varchar(20)  
 ,@Loan_ID    Numeric  
 ,@Loan_Apr_Amount    Numeric  
 ,@Loan_Apr_No_of_Installment Numeric  
 ,@Loan_Apr_Installment_Amount Numeric(18,2)  
 ,@Loan_Apr_Intrest_Type   Varchar(20)  
 ,@Loan_Apr_Intrest_Per   Numeric(12,2)  
 ,@Loan_Apr_Intrest_Amount  Numeric(18,2)  
 ,@Loan_Apr_Deduct_From_Sal  Numeric  
 ,@Loan_Apr_Pending_Amount  Numeric(18,2)  
 ,@Loan_apr_By     varchar(100)  
 ,@Loan_Apr_Payment_Date   Datetime = null  
 ,@Loan_Apr_Payment_Type   Varchar(20)  
 ,@Bank_ID      Numeric  
 ,@Loan_Apr_Cheque_No   Varchar(10)  
 ,@Loan_Mode      char  
 ,@Loan_Number                  varchar(50)  
 ,@Deduction_Type               varchar(20)  
 ,@Guarantor_Emp_ID    Numeric  --Ankit 02052014  
 ,@tran_type      varchar(1)  
 ,@Installment_Start_Date  datetime --Hardik 05/08/2014  
 ,@Loan_Approval_Remarks   Varchar(250)  
 ,@Subsidy_Recover_Perc   float = 0 -- Added By Gadriwala Muslim 25122014  
 ,@Attachment_Path    nvarchar(max)= '' -- Added By Gadriwala Muslim 16032015  
 ,@Actual_subsidy_start_date  datetime = null -- Added By Gadriwala Muslim 11062015  
 ,@Opening_subsidy_amount  numeric(18,2) = 0 -- Added By Gadriwala Muslim 11062015  
 ,@No_of_Inst_Loan_Amt   Numeric(18,0)  = 0 -- Added By Nilesh Patel on 20072015  
    ,@Total_Loan_Int_Amount   Numeric(18,2)  = 0 -- Added By Nilesh Patel on 20072015  
    ,@Loan_Int_Installment_Amount   Numeric(18,2) = 0 -- Added By Nilesh Patel on 20072015  
    ,@Guarantor_Emp_ID2    Numeric(18,2) = 0 --Mukti 17112015  
    ,@User_Id numeric(18,0) = 0 -- Add By Mukti 07072016  
 ,@IP_Address varchar(30)= '' -- Add By Mukti 07072016  
 ,@subsidy_Amount Numeric(18,2) = 0  
 ,@AD_ID Numeric(5,0) = 0 -- Added by nilesh patel on 20122016  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
  
 IF @Loan_Apr_Payment_Date = ''  
  SET @Loan_Apr_Payment_Date = NULL  
    
 IF @Loan_App_ID  =0   
  SET @Loan_App_ID  = NULL  
    
 IF  @Bank_ID = 0  
  SET @Bank_ID = NULL  
   
 IF @Guarantor_Emp_ID = 0  
  Set @Guarantor_Emp_ID = Null   
  
 If @Installment_Start_Date = ''  
  Set @Installment_Start_Date = Null  
    
 ---============INTEREST CALCULUATION OF LOAN========================   
 --IF  @Loan_Apr_Intrest_Per > 0  
 -- SET @Loan_Apr_Amount = @Loan_Apr_Amount * @Loan_Apr_Intrest_Per  
 ---============INTEREST CALCULUATION OF LOAN========================   
    
 DECLARE @CF_Loan_Amt numeric;  
 DECLARE @CF_Loan_Apr_ID numeric;  
   
 SET @CF_Loan_Amt = 0;  
 SET @CF_Loan_Apr_ID = 0;  
   
 -- Add By Mukti 07072016(start)  
  declare @OldValue as  varchar(max)  
  Declare @String as varchar(max)  
  set @String=''  
  set @OldValue =''  
 -- Add By Mukti 07072016(end)   


  set @Loan_Approval_Remarks = dbo.fnc_ReverseHTMLTags(@Loan_Approval_Remarks)  --added by Ronak 100121  
   
 IF @tran_type ='I'   
  BEGIN   
   --declare @Emp_Code as numeric  
   --declare @str_Emp_Code as varchar(20)  
   SELECT @Loan_Apr_ID = ISNULL(MAX(Loan_Apr_ID),0) + 1  FROM T0120_LOAN_APPROVAL WITH (NOLOCK)  
       
    IF EXISTS(SELECT 1 from T0040_LOAN_MASTER WITH (NOLOCK) WHERE  Loan_ID= @Loan_ID and Cmp_ID=@Cmp_ID AND Is_GPF=1)  
   BEGIN  
    SELECT TOP 1 @CF_Loan_Amt=LA.Loan_Apr_Pending_Amount + ISNULL(CF_Loan_Amt,0), @CF_Loan_Apr_ID=LA.Loan_Apr_ID   
    FROM T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER L WITH (NOLOCK) ON LA.Cmp_ID=L.Cmp_ID AND LA.Loan_ID=L.Loan_ID  
    WHERE LA.Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID AND L.Is_GPF=1 AND LA.Loan_Apr_ID < @Loan_Apr_ID  
    ORDER BY LA.Loan_Apr_ID DESC  
   END  
   ELSE  
   BEGIN  
    SET @CF_Loan_Amt = NULL;  
    SET @CF_Loan_Apr_ID = NULL;  
   END    
  
     
   /*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID  
     
   SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code)   
      
   select @Loan_Apr_Code =   cast(isnull(max(substring(Loan_Apr_Code,10,len(Loan_Apr_Code))),0) + 1 as varchar)    
     from T0120_Loan_APPROVAL where Emp_ID = @Emp_ID  
      
   If charindex(':',@Loan_Apr_Code) > 0   
    Select @Loan_Apr_Code = right(@Loan_Apr_Code,len(@Loan_Apr_Code) - charindex(':',@Loan_Apr_Code))  
      
   if @Loan_Apr_Code is not null  
    begin  
     while len(@Loan_Apr_Code) <> 4  
      begin  
       set @Loan_Apr_Code = '0' + @Loan_Apr_Code  
      end  
      set @Loan_Apr_Code = 'LAPR'+ @str_Emp_Code +':'+ @Loan_Apr_Code    
    end  
   else  
    SET @Loan_Apr_Code = 'LAPR' + @str_Emp_Code + ':' + '0001' */  
       
   SET @Loan_Apr_Code = cast(@Loan_Apr_ID as varchar(20))  
   UPDATE    T0100_LOAN_APPLICATION  
    SET         Loan_status = @Loan_Mode      
      WHERE     (Loan_App_ID = @Loan_App_ID and Cmp_ID=@Cmp_ID)  
  
--New Condition for Restricting Repeated Loan Entry , Added By Ramiz on 08/09/2016  
  If EXISTS (Select 1 from T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Loan_ID = @Loan_Id and Emp_ID = @Emp_Id and Loan_Apr_Amount = @Loan_Apr_Amount and Loan_Apr_Date = @Loan_Apr_Date and Installment_Start_Date =  @Installment_Start_Date )  
   BEGIN   
    RAISERROR ('@@Loan with Same Details Already Exists@@' , 16 , 2)  
    RETURN 0;  
   END  
--New Condition for Restricting Repeated Loan Entry Ends   
  
  
  
   INSERT INTO T0120_LOAN_APPROVAL  
     
   (Loan_Apr_ID  
   ,Cmp_ID  
   ,Loan_App_ID  
   ,Emp_ID  
   ,Loan_Apr_Date  
   ,Loan_Apr_Code  
   ,Loan_ID  
   ,Loan_Apr_Amount  
   ,Loan_Apr_No_of_Installment  
   ,Loan_Apr_Installment_Amount  
   ,Loan_Apr_Intrest_Type  
   ,Loan_Apr_Intrest_Per  
   ,Loan_Apr_Intrest_Amount  
   ,Loan_Apr_Deduct_From_Sal  
   ,Loan_Apr_Pending_Amount  
   ,Loan_apr_By  
   ,Loan_Apr_Payment_Date  
   ,Loan_Apr_Payment_Type  
   ,Bank_ID  
   ,Loan_Apr_Cheque_No  
   ,Loan_Apr_Status  
   ,Loan_Number  
   ,Deduction_Type  
   ,Guarantor_Emp_ID  
   ,Installment_Start_Date  
   ,Loan_Approval_Remarks  
   ,Subsidy_Recover_Perc  
   ,Attachment_Path -- Added by Gadriwala Muslim 16032015  
   ,Actual_subsidy_start_date -- Added by Gadriwala Muslim 11062015  
   ,Opening_subsidy_amount -- Added by Gadriwala Muslim 11062015  
   ,No_of_Inst_Loan_Amt  
   ,Total_Loan_Int_Amount  
   ,Loan_Int_Installment_Amount  
   ,CF_Loan_Amt    --Added by Nimesh on 28-Sep-2015 (for previous pending loan amount)  
   ,CF_Loan_Apr_ID    --Added by Nimesh on 28-Sep-2015 (for previous pending loan approval id)  
   ,Guarantor_Emp_ID2  --Mukti 17112015  
   ,subsidy_Amount  
   ,AD_ID  
   )  
  
   VALUES     
   (@Loan_Apr_ID  
   ,@Cmp_ID  
   ,@Loan_App_ID  
   ,@Emp_ID  
   ,@Loan_Apr_Date  
   ,@Loan_Apr_Code  
   ,@Loan_ID  
   ,@Loan_Apr_Amount  
   ,@Loan_Apr_No_of_Installment  
   ,@Loan_Apr_Installment_Amount  
   ,@Loan_Apr_Intrest_Type  
   ,@Loan_Apr_Intrest_Per  
   ,@Loan_Apr_Intrest_Amount  
   ,@Loan_Apr_Deduct_From_Sal  
   ,@Loan_Apr_Pending_Amount  
   ,@Loan_apr_By  
   ,@Loan_Apr_Payment_Date  
   ,@Loan_Apr_Payment_Type  
   ,@Bank_ID  
   ,@Loan_Apr_Cheque_No  
   ,@Loan_Mode  
   ,@Loan_Number  
   ,@Deduction_Type  
   ,@Guarantor_Emp_ID  
   ,@Installment_Start_Date  
   ,@Loan_Approval_Remarks  
   ,@Subsidy_Recover_Perc  
   ,@Attachment_Path -- Added by Gadriwala Muslim 16032015  
   ,@Actual_subsidy_start_date -- Added by Gadriwala Muslim 11062015  
   ,@Opening_subsidy_amount -- Added by Gadriwala Muslim 11062015  
   ,@No_of_Inst_Loan_Amt  -- Added By Nilesh Patel on 20072015  
   ,@Total_Loan_Int_Amount   -- Added By Nilesh Patel on 20072015  
   ,@Loan_Int_Installment_Amount -- Added By Nilesh Patel on 20072015  
   ,@CF_Loan_Amt     --Added by Nimesh on 28-Sep-2015 (for previous pending loan amount)  
   ,@CF_Loan_Apr_ID    --Added by Nimesh on 28-Sep-2015 (for previous pending loan approval id)  
   ,@Guarantor_Emp_ID2  --Mukti 17112015  
   ,@subsidy_Amount  
   ,@AD_ID  
   )  
  
   IF EXISTS(SELECT 1 from T0040_LOAN_MASTER WITH (NOLOCK) WHERE  Loan_ID= @Loan_ID and Cmp_ID=@Cmp_ID AND Is_GPF=1)  
   BEGIN  
    UPDATE T0120_LOAN_APPROVAL  
    SET  Loan_Apr_Pending_Amount = 0  
    WHERE Loan_Apr_ID = @CF_Loan_Apr_ID AND Cmp_ID=@Cmp_ID  
   END  
     
   -- Add By Mukti 07072016(start)  
    exec P9999_Audit_get @table = 'T0120_LOAN_APPROVAL' ,@key_column='Loan_Apr_ID',@key_Values=@Loan_Apr_ID,@String=@String output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
   -- Add By Mukti 07072016(end)    
  end   
 else if @tran_type ='U'   
    begin     
     UPDATE    T0100_LOAN_APPLICATION  
     SET         Loan_status = @Loan_Mode  
     WHERE     (Loan_App_ID = @Loan_App_ID and Cmp_ID=@Cmp_ID)  
          
  --    Select 'Nilay'  
  --    return  
  -- DELETE FROM T0120_LOAN_APPROVAL WHERE Loan_apr_ID = @Loan_Apr_ID   
      
  -- Add By Mukti 07072016(start)  
   exec P9999_Audit_get @table='T0120_LOAN_APPROVAL' ,@key_column='Loan_Apr_ID',@key_Values=@Loan_Apr_ID,@String=@String output  
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
  -- Add By Mukti 07072016(end)     
      
    UPDATE    T0120_LOAN_APPROVAL  
     SET                
       --Loan_Apr_Date=@Loan_Apr_Date,  
       --Loan_Apr_Code=@Loan_Apr_Code,  
       --Loan_ID=@Loan_ID,  
       --Loan_Apr_Amount=@Loan_Apr_Amount,  
       --Loan_Apr_No_of_Installment=@Loan_Apr_No_of_Installment,  
       Loan_Apr_Installment_Amount=@Loan_Apr_Installment_Amount,  
       --Loan_Apr_Intrest_Type=@Loan_Apr_Intrest_Type,  
       --Loan_Apr_Intrest_Per=@Loan_Apr_Intrest_Per,  
       --Loan_Apr_Intrest_Amount=@Loan_Apr_Intrest_Amount,  
       Loan_Apr_Deduct_From_Sal=@Loan_Apr_Deduct_From_Sal,--uncommented by Sumit 15042015  
       --Loan_Apr_Pending_Amount=@Loan_Apr_Pending_Amount,  
       --Loan_apr_By=@Loan_apr_By,  
       --Loan_Apr_Payment_Date=@Loan_Apr_Payment_Date,  
       Loan_Apr_Payment_Type=@Loan_Apr_Payment_Type,  
       Bank_ID=@Bank_ID,  
       Loan_Apr_Cheque_No=@Loan_Apr_Cheque_No,  
       Guarantor_Emp_ID = @Guarantor_Emp_ID,  
       Installment_Start_Date = @Installment_Start_Date,  
       Loan_Approval_Remarks = @Loan_Approval_Remarks,  
       Subsidy_Recover_Perc = @Subsidy_Recover_Perc,  
       Loan_Apr_Intrest_Per = @Loan_Apr_Intrest_Per,  
       Attachment_Path = @Attachment_Path, -- Added by Gadriwala Muslim 16032015  
       Actual_subsidy_start_date = @Actual_subsidy_start_date,-- Added by Gadriwala Muslim 11062015  
       Opening_subsidy_amount = @Opening_subsidy_amount, -- Added by Gadriwala Muslim 11062015  
       --No_of_Inst_Loan_Amt = @No_of_Inst_Loan_Amt,  
       --Total_Loan_Int_Amount =  @Total_Loan_Int_Amount,  
       -- Loan_Int_Installment_Amount =  @Loan_Int_Installment_Amount,  
        Guarantor_Emp_ID2=@Guarantor_Emp_ID2  --Mukti 17112015  
         ,subsidy_Amount = @subsidy_Amount  
         ,AD_ID = @AD_ID  
     Where Loan_Apr_ID = @Loan_Apr_ID       
            
    IF EXISTS(SELECT 1 from T0040_LOAN_MASTER WITH (NOLOCK) WHERE  Loan_ID= @Loan_ID and Cmp_ID=@Cmp_ID AND Is_GPF=1)  
     BEGIN  
      SELECT TOP 1 @CF_Loan_Amt=LA.Loan_Apr_Pending_Amount + ISNULL(CF_Loan_Amt,0), @CF_Loan_Apr_ID=LA.Loan_Apr_ID   
      FROM T0120_LOAN_APPROVAL LA WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER L WITH (NOLOCK) ON LA.Cmp_ID=L.Cmp_ID AND LA.Loan_ID=L.Loan_ID  
      WHERE LA.Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID AND L.Is_GPF=1 AND LA.Loan_Apr_ID < @Loan_Apr_ID   
      ORDER BY LA.Loan_Apr_ID DESC  
        
      IF (@CF_Loan_Amt > 0)  
      BEGIN  
       UPDATE T0120_LOAN_APPROVAL  
       SET  CF_Loan_Amt  = @CF_Loan_Amt, CF_Loan_Apr_ID=@CF_Loan_Apr_ID  
       WHERE Loan_Apr_ID=@Loan_Apr_ID       
         
       UPDATE T0120_LOAN_APPROVAL  
       SET  Loan_Apr_Pending_Amount=0  
       WHERE Loan_Apr_ID=@CF_Loan_Apr_ID       
      END  
     END  
    ELSE  
     BEGIN  
      SELECT @CF_Loan_Amt=CF_Loan_Amt , @CF_Loan_Apr_ID=CF_Loan_Apr_ID  
      FROM T0120_LOAN_APPROVAL WITH (NOLOCK)  
      WHERE Loan_Apr_ID=@Loan_Apr_ID  
        
      IF (@CF_Loan_Apr_ID > 0)  
      BEGIN  
       UPDATE T0120_LOAN_APPROVAL  
       SET  Loan_Apr_Pending_Amount=@CF_Loan_Amt  
       WHERE Loan_Apr_ID=@CF_Loan_Apr_ID  
         
       UPDATE T0120_LOAN_APPROVAL  
       SET  CF_Loan_Amt  = NULL, CF_Loan_Apr_ID=NULL  
       WHERE Loan_Apr_ID=@Loan_Apr_ID  
      END  
     END  
           
     --INSERT INTO T0120_LOAN_APPROVAL  
     --(Loan_Apr_ID  
     --,Cmp_ID  
     --,Loan_App_ID  
     --,Emp_ID  
     --,Loan_Apr_Date  
     --,Loan_Apr_Code  
     --,Loan_ID  
     --,Loan_Apr_Amount  
     --,Loan_Apr_No_of_Installment  
     --,Loan_Apr_Installment_Amount  
     --,Loan_Apr_Intrest_Type  
     --,Loan_Apr_Intrest_Per  
     --,Loan_Apr_Intrest_Amount  
     --,Loan_Apr_Deduct_From_Sal  
     --,Loan_Apr_Pending_Amount  
     --,Loan_apr_By  
     --,Loan_Apr_Payment_Date  
     --,Loan_Apr_Payment_Type  
     --,Bank_ID  
     --,Loan_Apr_Cheque_No  
     --,Loan_Apr_Status  
     --,Loan_Number  
     --,Deduction_Type)  
  
     --VALUES     
     --(@Loan_Apr_ID  
     --,@Cmp_ID  
     --,@Loan_App_ID  
     --,@Emp_ID  
     --,@Loan_Apr_Date  
     --,@Loan_Apr_Code  
     --,@Loan_ID  
     --,@Loan_Apr_Amount  
     --,@Loan_Apr_No_of_Installment  
     --,@Loan_Apr_Installment_Amount  
     --,@Loan_Apr_Intrest_Type  
     --,@Loan_Apr_Intrest_Per  
     --,@Loan_Apr_Intrest_Amount  
     --,@Loan_Apr_Deduct_From_Sal  
     --,@Loan_Apr_Pending_Amount  
     --,@Loan_apr_By  
     --,@Loan_Apr_Payment_Date  
     --,@Loan_Apr_Payment_Type  
     --,@Bank_ID  
     --,@Loan_Apr_Cheque_No  
     --,@Loan_Mode  
     --,@Loan_Number  
     --,@Deduction_Type)  
     if Exists(Select 1 From T0140_LOAN_TRANSACTION WITH (NOLOCK) where Emp_ID = @EMP_ID and Loan_ID = @Loan_ID and Is_Loan_Interest_Flag = 1 AND Loan_Issue <> 0 AND Loan_Return = 0)  
       BEGIN  
        
       UPDATE T0120_LOAN_APPROVAL  
       Set  
       No_of_Inst_Loan_Amt = @No_of_Inst_Loan_Amt,  
       Total_Loan_Int_Amount =  @Total_Loan_Int_Amount,  
        Loan_Int_Installment_Amount =  @Loan_Int_Installment_Amount,  
        Loan_Apr_Pending_Int_Amount = @Total_Loan_Int_Amount  
       Where Loan_Apr_ID = @Loan_Apr_ID   
         
       Update T0140_LOAN_TRANSACTION   
       Set Loan_Issue = @Total_Loan_Int_Amount,  
        Loan_Closing = @Total_Loan_Int_Amount  
       Where For_Date =(SELECT MIN(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)  
            Where Emp_ID= @EMp_ID and Cmp_ID = @Cmp_ID  AND For_Date >= @Loan_Apr_Date  
            and Loan_ID = @Loan_ID and Is_Loan_Interest_Flag = 1 and Loan_Issue <> 0)  
       and Emp_ID= @EMp_ID and Cmp_ID = @Cmp_ID and Loan_ID = @Loan_ID and Is_Loan_Interest_Flag = 1 and Loan_Issue <> 0  
         
       Declare @For_Date Datetime  
       Declare @Loan_Closing Numeric(18,2)  
         
       Select @For_Date = For_Date,@Loan_Closing = Loan_Closing From T0140_LOAN_TRANSACTION WITH (NOLOCK)  
       Where For_Date =(SELECT MIN(For_Date) From T0140_LOAN_TRANSACTION WITH (NOLOCK)  
            Where Emp_ID= @EMp_ID and Cmp_ID = @Cmp_ID  AND For_Date >= @Loan_Apr_Date  
            and Loan_ID = @Loan_ID and Is_Loan_Interest_Flag = 1 and Loan_Issue <> 0)  
       and Emp_ID= @EMp_ID and Cmp_ID = @Cmp_ID and Loan_ID = @Loan_ID and Is_Loan_Interest_Flag = 1 and Loan_Issue <> 0  
              
       update T0140_LOAN_TRANSACTION set Loan_Opening = @Loan_Closing + ISNULL(Loan_Issue,0) - ISNULL(Loan_Return,0)  
       ,Loan_Closing = @Loan_Closing + ISNULL(Loan_Issue,0) - ISNULL(Loan_Return,0)  
       where Loan_Id = @Loan_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID  
       and emp_Id = @emp_Id and Is_Loan_Interest_Flag = 1   
       End   
         
    -- Add By Mukti 05072016(start)  
      exec P9999_Audit_get @table = 'T0120_LOAN_APPROVAL' ,@key_column='Loan_Apr_ID',@key_Values=@Loan_Apr_ID,@String=@String output  
      set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
    -- Add By Mukti 05072016(end)   
    end  
 Else if @tran_type ='D'  
  Begin  
     --DELETE FROM T0120_LOAN_APPROVAL where Loan_Apr_ID = @Loan_Apr_ID  
     
     --UPDATE  T0100_LOAN_APPLICATION  
     --SET     Loan_status = 'N'  
     --WHERE Loan_App_ID = @Loan_App_ID  
   SET  @CF_Loan_Apr_ID = 0;  
   SET  @CF_Loan_Amt = 0;  
     
   SELECT @CF_Loan_Apr_ID = CF_Loan_Apr_ID, @CF_Loan_Amt= CF_Loan_Amt  
   FROM T0120_LOAN_APPROVAL WITH (NOLOCK)  
   WHERE Loan_Apr_ID= @Loan_Apr_ID and Cmp_ID=@Cmp_ID  
  
   ---Ankit 21052014---   
     
   IF Exists(Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_ID AND Cmp_ID=@Cmp_ID)  
    Begin   
     RAISERROR('Month Salary Exists',16,2)  
     Return -1  
    End  
     
   IF  @Loan_Mode = 'A' --and @Loan_App_ID > 0  
    Begin   
     If @Loan_App_ID <> Null Or @Loan_App_ID <> 0  
      Begin  
       Delete From T0115_Loan_Level_Approval Where Loan_App_ID = @Loan_App_ID  
      End  
       
   -- Add By Mukti 07072016(start)  
     exec P9999_Audit_get @table='T0120_LOAN_APPROVAL' ,@key_column='Loan_Apr_ID',@key_Values=@Loan_Apr_ID,@String=@String output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
   -- Add By Mukti 07072016(end)  
    
     DELETE FROM T0120_LOAN_APPROVAL where Loan_Apr_ID = @Loan_Apr_ID  
     
     UPDATE  T0100_LOAN_APPLICATION  
     SET     Loan_status = 'N'  
     WHERE Loan_App_ID = @Loan_App_ID  
    End  
   Else If @Loan_Mode = 'N' and @Loan_App_ID > 0  
    Begin   
      
     declare @Tran_id as numeric(18,0)  
     declare @Rm_emp_id as numeric(18,0)  
     set @Rm_emp_id = 0  
     set @Tran_id = 0  
       
     select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_Loan_Level_Approval WITH (NOLOCK) where  Loan_App_ID = @Loan_App_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_Loan_Level_Approval WITH (NOLOCK) where Loan_App_ID = @Loan_App_ID )  
      
     If @Rm_emp_id = @Emp_ID   
      Begin  
       Delete T0115_Loan_Level_Approval where Tran_ID = @Tran_id and Loan_App_ID = @Loan_App_ID  
      End  
        
     -- Add By Mukti 07072016(start)  
      exec P9999_Audit_get @table='T0120_LOAN_APPROVAL' ,@key_column='Loan_Apr_ID',@key_Values=@Loan_Apr_ID,@String=@String output  
      set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
     -- Add By Mukti 07072016(end)  
        
     DELETE FROM T0120_LOAN_APPROVAL where Loan_Apr_ID = @Loan_Apr_ID  
     
     UPDATE  T0100_LOAN_APPLICATION  
     SET     Loan_status = 'N'  
     WHERE Loan_App_ID = @Loan_App_ID  
       
    End   
      
   --Added By Nimesh 01-Sep-2015   
   --If Record is deleted then CF Amount should be restored for GPF Loan  
   IF NOT EXISTS(SELECT 1 FROM T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE Loan_Apr_ID=@Loan_Apr_ID)  
   BEGIN  
    IF (@CF_Loan_Amt > 0 AND @CF_Loan_Apr_ID > 0)  
    BEGIN  
     UPDATE T0120_LOAN_APPROVAL  
     SET  Loan_Apr_Pending_Amount = @CF_Loan_Amt  
     WHERE Loan_Apr_ID = @CF_Loan_Apr_ID  
    END  
   END  
  
   ---Ankit 21052014---  
   --Added by Gadriwala Muslim 25122014  
    delete from T0120_Installment_Amount_Details where Loan_Apr_ID = @Loan_Apr_ID   
    delete from T0120_Interest_Yearly_Details where Loan_Apr_ID = @Loan_Apr_ID   
  End   
 exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Loan Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
RETURN  