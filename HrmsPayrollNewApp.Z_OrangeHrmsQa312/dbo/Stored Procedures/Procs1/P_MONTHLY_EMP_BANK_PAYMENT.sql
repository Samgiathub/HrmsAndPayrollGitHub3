CREATE PROCEDURE [dbo].[P_MONTHLY_EMP_BANK_PAYMENT]        
     @Emp_ID numeric(18, 0)        
 ,@Cmp_ID numeric(18, 0)        
 ,@For_Date datetime        
 ,@Payment_Date datetime        
 ,@Emp_Bank_ID numeric(18, 0) = NULL        
 ,@Payment_Mode varchar(100)        
 ,@Net_Amount numeric(18, 0)        
 ,@Emp_Bank_AC_No varchar(50)        
 ,@Cmp_Bank_ID numeric(18, 0) = NULL        
 ,@Emp_Cheque_No varchar(20)        
 ,@Cmp_Bank_Cheque_No varchar(20)        
 ,@Cmp_Bank_AC_No varchar(20)         
 ,@Emp_Left char(1)        
 ,@Status varchar(10)         
 ,@tran_type varchar(1)        
 ,@Process_Type Varchar(500)=''        
 ,@Ad_Id numeric(18,0) = 0        
 ,@process_type_id numeric(18,0)= 0        
 ,@Payment_Process_Id numeric(18,0) = 0 output  --Added by Jaina 27-12-2017        
 ,@Bond_Apr_ID varchar(50) = null        
 ,@Claim_Apr_ID varchar(50) = null        
 ,@Claim_Apr_Detail_Id Numeric = 0 --Added by Mr.Mehul on 04-03-2023        
         
AS        
        
SET NOCOUNT ON         
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
SET ARITHABORT ON        
        
        
DECLARE @process_id numeric(18,0)        
 SET @process_id=0        
         
DECLARE @BOND_ID AS varchar(50)        
 SET @BOND_ID = ''         
        
 --Added by ronakk 14122022        
 if @Emp_Bank_ID = 0         
 set @Emp_Bank_ID = null        
        
        
DECLARE @Claim_ID as INT  = 0          
        
        --Comment by ronakk 13122022        
  --IF @process_type_id > 9000        
 --   SET @process_id = 0        
   --ELSE        
   --SET @process_id = @process_type_id        
        
        
        
         
 If @tran_type  = 'I'         
  BEGIN        
   --declare @payment_process_id numeric(18,0)        
   SET @Payment_Process_Id = 0        
           
   IF @Bond_Apr_ID > 0         
    BEGIN        
     SELECT @BOND_ID = BOND_ID FROM T0120_BOND_APPROVAL WITH (NOLOCK) WHERE         
     Bond_Apr_Id = @Bond_Apr_ID AND        
     Emp_ID =@Emp_ID        
     SET @Ad_Id = @BOND_ID --USING BOND ID IN AD_ID         
    END        
         
           
   IF @Claim_Apr_ID <> ''         
    BEGIN        
     SELECT @Claim_ID = Claim_Id FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK) WHERE         
     Claim_Apr_ID = @Claim_Apr_ID AND Cmp_ID = @Cmp_ID and        
     Emp_ID =@Emp_ID and Claim_Apr_Dtl_ID = @Claim_Apr_Detail_Id        
        
     --select * FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK) WHERE         
     --Claim_Apr_ID = @Claim_Apr_ID AND Cmp_ID = @Cmp_ID and        
     --Emp_ID =@Emp_ID and Claim_Apr_Dtl_ID = @Claim_Apr_Detail_Id        
        
    END        
        
            
           
   IF EXISTS (SELECT EMP_ID FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK) WHERE Emp_ID =@Emp_ID and For_Date = @For_Date and isnull(process_type,'') = @Process_Type         
   and isnull(Ad_id,0) = @ad_id         
   and ISNULL(process_type_id,0) = @process_id)        
    BEGIN        
            
     --Added by Jaina 28-12-2017 Start        
     IF @PROCESS_TYPE ='Travel Advance Amount' or @PROCESS_TYPE = 'Travel Amount'        
      BEGIN        
        
       SELECT @Payment_Process_Id = payment_process_id        
       FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK)        
       WHERE Emp_ID =@Emp_ID and For_Date = @For_Date and isnull(process_type,'') = @Process_Type         
       and isnull(Ad_id,0) = @ad_id         
       and ISNULL(process_type_id,0) = @process_id        
               
       UPDATE MONTHLY_EMP_BANK_PAYMENT        
       SET Net_Amount = Net_Amount + @Net_amount                 
       WHERE EMP_ID =@EMP_ID AND FOR_DATE = @FOR_DATE AND ISNULL(PROCESS_TYPE,'') = @PROCESS_TYPE         
       AND ISNULL(AD_ID,0) = @AD_ID         
       AND ISNULL(PROCESS_TYPE_ID,0) = @PROCESS_ID        
       RETURN        
      END        
              
     --Added by Jaina 28-12-2017 End        
     DELETE FROM MONTHLY_EMP_BANK_PAYMENT WHERE EMP_ID =@EMP_ID AND FOR_DATE = @FOR_DATE AND ISNULL(PROCESS_TYPE,'') = @PROCESS_TYPE         
     AND ISNULL(AD_ID,0) = @AD_ID         
     AND ISNULL(PROCESS_TYPE_ID,0) = @PROCESS_ID        
            
     IF @PROCESS_ID > 0        
      BEGIN        
       DELETE FROM T0302_PROCESS_DETAIL WHERE EMP_ID =@EMP_ID AND MONTH(FOR_DATE) = MONTH(@FOR_DATE) AND YEAR(FOR_DATE) = YEAR(@FOR_DATE) AND ISNULL(PROCESS_TYPE_ID ,0) = @PROCESS_ID        
      END        
     END        
        
            
    SELECT @Payment_Process_Id = IDENT_CURRENT('MONTHLY_EMP_BANK_PAYMENT')  --Added by Jaina 27-12-2017        
            
    Select top 1 @process_type_id = process_type_id from MONTHLY_EMP_BANK_PAYMENT order by process_type_id desc        
            
    SET @process_type_id = @process_type_id + 1 --ADDED BY MR.MEHUL ON 06-02-2023 (ADDING PROCESS TYPE ID TO RESOLVED/REMOVE ALREADY EXISTS ERROR)        
            
            
    IF @Emp_Bank_ID IS NULL        
    BEGIN         
     SET @Emp_Bank_ID = 0         
    END        
        
    IF @Emp_Bank_AC_No IS NULL        
    BEGIN         
     SET @Emp_Bank_AC_No = ''        
    END        
        
    IF @Cmp_Bank_ID IS NULL        
    BEGIN         
     SET @Cmp_Bank_ID = 0         
    END        
        
    IF @Emp_Cheque_No IS NULL        
    BEGIN         
     SET @Emp_Cheque_No = ''         
    END        
        
    IF @Cmp_Bank_Cheque_No IS NULL        
    BEGIN         
     SET @Cmp_Bank_Cheque_No = ''         
    END        
        
    IF @Cmp_Bank_AC_No IS NULL        
    BEGIN         
     SET @Cmp_Bank_AC_No = ''         
    END        
        
        
    INSERT INTO MONTHLY_EMP_BANK_PAYMENT        
     (Emp_ID, Cmp_ID, For_Date, Payment_Date, Emp_Bank_ID, Payment_Mode, Net_Amount, Emp_Bank_AC_No, Cmp_Bank_ID, Emp_Cheque_No,         
      Cmp_Bank_Cheque_No, Cmp_Bank_AC_No, Emp_Left, Status,Process_Type,        
      Ad_Id,process_type_id)        
    VALUES             
     (@Emp_ID,@Cmp_ID,@For_Date,@Payment_Date,@Emp_Bank_ID,@Payment_Mode,@Net_Amount,@Emp_Bank_AC_No,@Cmp_Bank_ID,@Emp_Cheque_No,        
      @Cmp_Bank_Cheque_No,@Cmp_Bank_AC_No,@Emp_Left,@Status,@Process_Type,        
      @Ad_Id,@process_type_id) -- @process_type_id added  by ronakk14122022        
          
            
    --SELECT @Payment_Process_Id = IDENT_CURRENT('MONTHLY_EMP_BANK_PAYMENT')  --Added by Jaina 27-12-2017        
             
     IF @Process_id > 0        
      BEGIN        
       SELECT @payment_process_id = payment_process_id        
       FROM MONTHLY_EMP_BANK_PAYMENT WITH (NOLOCK)        
       WHERE Emp_ID =@Emp_ID and For_Date = @For_Date and isnull(process_type,'') = @Process_Type         
       and isnull(Ad_id,0) = @ad_id         
       and ISNULL(process_type_id,0) = @process_id        
               
       UPDATE T0302_Process_Detail        
       SET  payment_process_id = @payment_process_id        
       WHERE Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(for_date) = YEAR(@For_Date) and isnull(process_type_id ,'') = @process_id and ISNULL(process_type_id,0) = @process_id        
      END        
              
     IF @PROCESS_TYPE ='Bond' and @Net_Amount > 0        
      BEGIN        
       UPDATE T0120_BOND_APPROVAL        
       SET  Bond_Return_Status = 'Yes' , Bond_Return_Date = @Payment_Date , Payment_Process_ID = @Payment_Process_Id        
       WHERE Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID         
       and Bond_Apr_Id = @Bond_Apr_ID        
      END          
            
     IF @PROCESS_TYPE ='Claim' and @Net_Amount > 0        
      BEGIN        
              
       UPDATE T0130_CLAIM_APPROVAL_DETAIL        
       SET  Payment_Process_ID = @process_type_id        
       WHERE Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID         
       and Claim_Apr_ID = @Claim_Apr_ID         
       and Claim_Status='A' -- Added By Sajid 03032023        
       and Claim_Apr_Dtl_ID = @Claim_Apr_Detail_Id        
      END        
            
                
  End        
 Else if @Tran_Type = 'U'         
  BEGIN          
            
   UPDATE    MONTHLY_EMP_BANK_PAYMENT        
   SET       Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, For_Date = @For_Date, Payment_Date = @Payment_Date, Emp_Bank_ID = @Emp_Bank_ID,         
       Payment_Mode = @Payment_Mode, Net_Amount = @Net_Amount, Emp_Bank_AC_No = @Emp_Bank_AC_No, Cmp_Bank_ID = @Cmp_Bank_ID,         
       Emp_Cheque_No = @Emp_Cheque_No, Cmp_Bank_Cheque_No = @Cmp_Bank_Cheque_No, Cmp_Bank_AC_No = @Cmp_Bank_AC_No,         
       Emp_Left = @Emp_Left, Status = @Status         
                          
  END        
 Else if @Tran_Type = 'D'         
  begin        
        
    SET @process_id = @process_type_id --Added by ronakk 13122022        
           
   DELETE  from MONTHLY_EMP_BANK_PAYMENT where Emp_ID = @Emp_ID and For_Date = @For_Date and isnull(process_type,'')=@Process_Type         
   and isnull(Ad_id,0) = @ad_id         
   and ISNULL(process_type_id,0) = @process_id        
           
   IF @PROCESS_TYPE ='Travel Advance Amount' or @PROCESS_TYPE = 'Travel Amount'        
    BEGIN       
   --set  @Payment_Process_Id= @Payment_Process_Id-1 --Added by Yogesh on 20-11-2023 to rollback Payment process    
  delete FROM T0302_Payment_Process_Travel_Details where Emp_Id=@Emp_id and Payment_Process_Id = @Payment_Process_Id    
    END        
   ELSE IF @PROCESS_TYPE = 'Bond'        
    BEGIN        
     IF @Payment_Process_Id > 0         
      BEGIN        
       DELETE  from MONTHLY_EMP_BANK_PAYMENT         
       WHERE Emp_ID = @Emp_ID and For_Date = @For_Date and Payment_Process_Id = @Payment_Process_Id        
      END        
             
             
     UPDATE T0120_BOND_APPROVAL        
     SET  Bond_Return_Status = 'No' , Bond_Return_Date = NULL , Payment_Process_ID = NULL        
     WHERE Payment_Process_ID = @Payment_Process_Id        
    END        
   ELSE IF @Process_Type = 'Claim'        
   Begin        
    IF @Payment_Process_Id > 0         
      BEGIN        
       DELETE  from MONTHLY_EMP_BANK_PAYMENT         
       WHERE Emp_ID = @Emp_ID and For_Date = @For_Date and Payment_Process_Id = @Payment_Process_Id        
      END        
    UPDATE T0130_CLAIM_APPROVAL_DETAIL        
    SET  Payment_Process_ID = NULL        
    WHERE Payment_Process_ID = @process_type_id        
   end        
   if @process_id > 0        
   begin        
    delete from T0302_Process_Detail where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(for_date) = YEAR(@For_Date) and ISNULL(process_type_id ,0) = @process_id        
   end        
  end        
        
        
 RETURN        
        