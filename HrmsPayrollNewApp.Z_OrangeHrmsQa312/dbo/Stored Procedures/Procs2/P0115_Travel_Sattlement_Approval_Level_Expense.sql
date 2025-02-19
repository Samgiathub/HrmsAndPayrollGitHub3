CREATE PROCEDURE [dbo].[P0115_Travel_Sattlement_Approval_Level_Expense]        
   @int_Exp_Id numeric(18,0) output      
   ,@Int_Id numeric(18, 0)       
   ,@Travel_Settlement_Id numeric(18, 0)       
   ,@Travel_Approval_ID numeric(18, 0)       
   ,@cmp_id numeric(18, 0)        
  ,@Emp_ID numeric(18, 0)        
  ,@for_Date datetime        
  ,@Amount Numeric(18,2)        
  ,@Approved_Amount numeric(18,2)      
  ,@Comments varchar(max)        
  ,@expense_type_id varchar(100)      
  ,@Missing varchar(1)        
  ,@From_Time varchar(25) = ''       
  ,@To_Time varchar(25) = ''       
  ,@Duration float = 0       
  ,@Appr_From_Time varchar(25) = ''       
  ,@Appr_To_Time varchar(25) = ''      
  ,@Appr_Duration float = 0       
  ,@tran_type  Varchar(1)         
  ,@Rpt_Level numeric(18,0)=0      
  ,@Status varchar(10)='P'      
  ,@Manager_Emp_ID numeric(18,0)=null      
  ,@Limit_Amount numeric(18,2)=0      
  ,@Curr_ID numeric(18,0)=0      
  ,@Curr_Amount numeric(18,2)=0      
  ,@Exchange_Rate numeric(18,2)=0      
  ,@Exp_Km numeric(18,2)=0      
  ,@Travel_Detail    xml = ''     
  ,@No_of_days numeric(18,0)=0   
  ,@GuestName varchar(10)=''  
  ,@SelfPay numeric(18,0)=0 
AS        
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
        
   declare @visit tinyint       
   SET @visit = 0      
         
         
         
   IF @TRAN_TYPE ='I'         
   BEGIN        
           
        
    SELECT  @EXPENSE_TYPE_ID = EXPENSE_TYPE_ID       
    FROM T0040_EXPENSE_TYPE_MASTER WITH (NOLOCK)      
    WHERE EXPENSE_TYPE_NAME = @EXPENSE_TYPE_ID AND CMP_ID=@CMP_ID      
          
    --IF Exists(Select 1 From T0115_Travel_Settlement_Level_Expense Where manager_emp_id=@Manager_Emp_ID and Emp_ID=@Emp_ID and Rpt_Level=@Rpt_Level)      
 -- Begin      
         
 -- Set @Int_Exp_Id = 0      
 -- Select @Int_Exp_Id      
 -- Return       
 -- End      
       
 IF  Exists( SELECT 1 FROM T0115_TRAVEL_SETTLEMENT_LEVEL_EXPENSE TSE WITH (NOLOCK)      
    WHERE CMP_ID = @CMP_ID AND EMP_ID=@EMP_ID AND FOR_DATE = @FOR_DATE AND TRAVEL_SETTLEMENT_ID = @TRAVEL_SETTLEMENT_ID AND MANAGER_EMP_ID=@MANAGER_EMP_ID  
 AND EXPENSE_TYPE_ID = @EXPENSE_TYPE_ID and Rpt_Level=@Rpt_Level  
 and int_Id=@Int_Id)      
  BEGIN      
      Print 'issue Found '  
   Set @Int_Exp_Id = 0      
   Return       
         
  End      
        
    DECLARE @MODE_TRAN_ID AS NUMERIC(18,0)      
 SET @MODE_TRAN_ID = 0      
       
  SELECT @INT_EXP_ID  = ISNULL(MAX(INT_EXP_ID ),0) + 1       
  FROM T0115_TRAVEL_SETTLEMENT_LEVEL_EXPENSE WITH (NOLOCK)      
           
     INSERT INTO T0115_Travel_Settlement_Level_Expense      
      (        
    int_Exp_Id,int_Id,Travel_Settlement_Id,Travel_Approval_Id,Emp_ID,Cmp_ID,For_Date,Amount,Approved_Amount,Expense_Type_id,      
    Comments,Missing,From_Time,To_Time,Duration,Appr_From_Time,Appr_To_Time,Appr_Duration,Rpt_Level,Status,Manager_Emp_ID,      
    Limit_Amount,Curr_ID,Curr_Amount,Exchange_Rate,ExpKM,No_of_Days,GuestName,SelfPay      
      )        
      VALUES              
   (   @int_Exp_Id      
      ,@Int_Id        
      ,@Travel_Settlement_Id      
      ,@Travel_Approval_ID        
      ,@Emp_ID       
      ,@Cmp_ID       
      ,@for_Date       
      ,@Amount        
      ,@Approved_Amount      
      ,@expense_type_id        
      ,@Comments        
      ,@Missing        
      ,@from_Time      
      ,@To_Time      
      ,@Duration      
      ,@Appr_From_Time      
      ,@Appr_To_Time      
      ,@Appr_Duration      
      ,@Rpt_Level      
      ,@Status      
      ,@Manager_Emp_ID      
      ,@Limit_Amount      
      ,@Curr_ID      
      ,@Curr_Amount      
      ,@Exchange_Rate      
      ,@Exp_Km  
   ,@No_of_days  
   ,@GuestName
   ,@SelfPay
       )        
             
            
          
    SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1       
    FROM T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE WITH (NOLOCK)      
          
    INSERT INTO T0115_TRAVEL_SETTLEMENT_LEVEL_MODE_EXPENSE      
    (      
     TRAN_ID,      
     INT_EXP_ID,      
     CMP_ID,   
     INT_ID,      
     TRAVEL_SETTLEMENT_ID,      
     TRAVEL_APPROVAL_ID,      
     TRAVEL_MODE,      
     FROM_PLACE,      
     TO_PLACE,      
     MODE_NAME,      
     MODE_NO,      
     CITY,      
     CHECK_OUT_DATE,      
     NO_PASSENGER,      
     BOOKING_DATE,      
     PICK_UP_ADDRESS,      
     PICK_UP_TIME,      
     DROP_ADDRESS,      
     BILL_NO,      
     [DESCRIPTION]      
           
    )      
    SELECT TOP 1 @MODE_TRAN_ID,@INT_EXP_ID,@CMP_ID,@INT_ID,@TRAVEL_SETTLEMENT_ID,@TRAVEL_APPROVAL_ID,TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,      
      CITY,CHECK_OUT_DATE,NO_PASSENGER,BOOKING_DATE,PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION]      
    FROM T0140_TRAVEL_SETTLEMENT_MODE_EXPENSE WITH (NOLOCK)      
    WHERE INT_ID = @INT_ID AND TRAVEL_SET_APPLICATION_ID = @TRAVEL_SETTLEMENT_ID      
          
          
         
 END        
 ELSE IF @TRAN_TYPE ='U'         
    BEGIN        
           
   update T0115_Travel_Settlement_Level_Expense         
   set  for_Date = @for_Date        
    ,Amount = @Amount      
    ,expense_type_id = @expense_type_id        
    ,Comments = @Comments      
    ,Missing=@Missing      
    ,Approved_Amount=@Approved_Amount      
    ,From_Time = @From_Time      
    ,To_Time = @To_Time      
    ,Duration = @Duration      
    ,Appr_From_Time = @Appr_From_Time      
    ,Appr_To_Time = @Appr_To_Time      
    ,Appr_Duration = @Appr_Duration      
    ,Rpt_Level=@Rpt_Level      
    ,Status=@Status      
    ,Manager_Emp_ID=@Manager_Emp_ID      
    ,Limit_Amount=@Limit_Amount       
    ,Curr_ID=@Curr_ID      
    ,Curr_Amount=@Curr_Amount      
    ,Exchange_Rate=@Exchange_Rate      
    ,ExpKM=@Exp_Km   
 ,No_of_Days=@No_of_days  
 ,GuestName=@GuestName  
 ,selfpay=@SelfPay
   where   emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and int_id=@Int_Id and int_Exp_Id=@int_Exp_Id      
    end        
  else if @tran_type ='D'        
  begin        
        
  delete from T0115_Travel_Settlement_Level_Expense where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID  and int_id=@Int_Id and int_Exp_Id=@int_Exp_Id      
        
  end      
        
 RETURN        
        
        
        