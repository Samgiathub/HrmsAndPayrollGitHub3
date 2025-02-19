---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
    
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Claim_Approval_Update]    
  @Tran_ID    NUMERIC(18,0) OUTPUT    
 ,@Claim_App_ID   NUMERIC(18,0)    
 ,@Cmp_ID    NUMERIC(18,0)    
 ,@Emp_ID    NUMERIC(18,0)    
 ,@S_Emp_ID    NUMERIC(18,0)    
 ,@Approval_Date   Datetime    
 ,@Approval_Status  varchar(20)    
 ,@Approval_Comments  Varchar(250)    
 ,@Login_ID    NUMERIC(18,0)    
 ,@Rpt_Level    TinyInt     
 ,@Claim_Details   XML    
 ,@Tran_Type    Char(1)      
 ,@Result VARCHAR(100) OUTPUT    
AS    
BEGIN    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
 Declare @Create_Date As Datetime    
     
 Set @Create_Date = GETDATE()    
     
 If @S_Emp_ID = 0    
  Set @S_Emp_ID = NULL    
    
 If UPPER(@Tran_Type) = 'I'    
  BEGIN    
   IF Exists(Select 1 From T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK) Where Emp_ID=@Emp_ID     
   and Claim_App_ID=@Claim_App_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)    
   BEGIN    
     
    Set @Tran_ID = 0    
    --Select @Tran_ID    
    Return     
   END    
    
   SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)    
   INSERT INTO T0115_CLAIM_LEVEL_APPROVAL    
     (Tran_ID,Claim_App_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Claim_Apr_Status,Claim_Apr_Comments, Login_ID,System_date,Rpt_Level,Claim_Apr_Amount,Claim_Apr_Pending_Amnt,Claim_App_Amount,Curr_ID,Curr_Rate,Claim_App_Total_Amount,Attached_Doc_File,Claim_ID,Deduct_from_salary,for_date,Claim_App_Purpose,Approved_Petrol_Km,Is_Mobile_Entry)    
   VALUES (@Tran_ID, @Claim_App_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID,@Create_Date,@Rpt_Level,0,0,0,NULL,NULL,0,NULL,0,0,GETDATE(),NULL,0,1)    
       
   --select * from T0115_CLAIM_LEVEL_APPROVAL where Tran_ID = @Tran_ID     
    
   IF (@Claim_Details.exist('/NewDataSet/ClaimDetails') = 1)    
    BEGIN    
     SELECT     
      ROW_NUMBER() OVER(ORDER BY (SELECT NULL) ) AS Row_No,    
      Table1.value('(CLAIM_APP_ID/text())[1]','varchar(20)') AS Claim_App_ID,    
      Table1.value('(CMP_ID/text())[1]','numeric(18,0)') AS Cmp_ID,    
      @Emp_ID As Emp_ID,     
      @S_Emp_ID as S_Emp_ID,    
      Table1.value('(CLAIM_ID/text())[1]','numeric(18,0)') AS CLAIM_ID,    
      Table1.value('(FOR_DATE/text())[1]','varchar(20)') AS Claim_Apr_Date,    
      Table1.value('0','numeric(18,0)') AS Claim_Apr_code,    
      Table1.value('(APPLICATION_AMOUNT/text())[1]','numeric(18,2)') AS Claim_Apr_Amount,    
      Table1.value('(Claim_Status/text())[1]','varchar(20)') AS Claim_Status,    
      Table1.value('(TOTALAMOUNT/text())[1]','numeric(18,2)') AS Claim_App_Amnt,    
      Table1.value('0','numeric(18,0)') AS Curr_ID,    
      Table1.value('(CURR_RATE/text())[1]','numeric(18,2)') AS Curr_rate,    
      Table1.value('(DESCRIPTION/text())[1]','varchar(20)') AS Purpose,    
      Table1.value('(TOTALAMOUNT/text())[1]','numeric(18,2)') AS Claim_App_Total_Amnt,    
      Table1.value('(PETROL_KM/text())[1]','numeric(18,2)') AS PETROL_KM,    
      @Login_ID as Login_ID,    
      @Rpt_Level as Rpt_Level,    
      Table1.value('(FOR_DATE/text())[1]','varchar(20)') AS For_Date    
      INTO #ClaimDetailsTemp FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)    
    END    
        
   DECLARE @Counter INT     
   DECLARE @TableCount INT     
   Select @TableCount = Count(1) from #ClaimDetailsTemp    
   SET @Counter=1    
       
   Declare @Claim_Tran_ID numeric(18, 0) = 0    
   WHILE ( @Counter <= @TableCount)    
   BEGIN    
    SELECT @Claim_Tran_ID = Isnull(max(Claim_Tran_ID),0) + 1      
    FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)    
    
    --select Claim_Status,* from #ClaimDetailsTemp WHERE Row_No = @Counter    
    
    -- Start Added By Niraj(06102021) - Suggestions #19051    
    Insert Into T0115_CLAIM_LEVEL_APPROVAL_DETAIL(Claim_Tran_ID,Claim_Apr_ID,Claim_App_ID,Cmp_ID,Emp_ID,    
    S_Emp_ID,Claim_ID,Claim_Apr_Date,Claim_Apr_Code,Claim_Apr_Amnt,Claim_Status,Claim_App_Amnt,Curr_ID,Curr_Rate,    
    Purpose,Claim_App_Total_Amnt, PetrolKM, Login_ID, Rpt_Level,For_Date)    
    SELECT @Claim_Tran_ID,@Tran_ID,Claim_App_ID,Cmp_ID,Emp_ID,S_Emp_ID,CLAIM_ID,CONVERT(VARCHAR(20), CONVERT(DATEtime, Claim_Apr_Date, 103), 20) as Claim_Apr_Date    
    ,Claim_Apr_code,Claim_Apr_Amount,    
    case    
    when Claim_Status = 'Pending' then 'P'     
    When Claim_Status = 'Approved' Then 'A'      
    When Claim_Status = 'Rejected' Then 'R'      
    else '' end as Claim_Status    
    ,Claim_App_Amnt,Curr_ID,Curr_rate,Purpose,Claim_App_Total_Amnt,PETROL_KM,Login_ID,Rpt_Level,CONVERT(VARCHAR(20), CONVERT(DATEtime, For_Date, 103), 20) as For_Date    
    FROM #ClaimDetailsTemp WHERE Row_No = @Counter    
    -- End Added By Niraj(06102021) - Suggestions #19051    
    SET @Counter  = @Counter  + 1    
    
    --select * from T0115_CLAIM_LEVEL_APPROVAL_DETAIL where Claim_Tran_ID = @Claim_Tran_ID    
    
   END    
    SET @Result = 'Claim Approval Detail Insert Successfully#True#'+CAST(@Tran_ID AS varchar(11))    
    Select @Result as Result    
 END    
END
