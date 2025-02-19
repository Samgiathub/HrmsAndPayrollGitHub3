CREATE PROCEDURE [dbo].[P0140_Travel_Sattlement_Expense]         
   @Int_Id numeric(18, 0) OUTPUT      
  ,@Travel_Approval_ID numeric(18, 0)     
  ,@cmp_id numeric(18, 0)      
  ,@Emp_ID numeric(18, 0)  =0    
  ,@for_Date datetime      
  ,@Amount Numeric(18,2)       
  ,@Comments varchar(max)      
  ,@expense_type_id varchar(100)    
  ,@Missing varchar(1)      
  ,@From_Time varchar(25) = '' --Added by Gadriwala 01122014    
  ,@To_Time varchar(25) = '' --Added by Gadriwala 01122014    
  ,@Duration float = 0 --Added by Gadriwala 01122014    
  ,@Travel_Allowance numeric(18,3)    
  ,@Limit_Amnt numeric(18,2)=0    
  ,@Grp_Emp varchar(max)=''    
  ,@Grp_Emp_ID varchar(max)=''    
  ,@Ovrlmt_Expense numeric(18,2)=0 --Added by Sumit Overlimit Amount 13082015    
  ,@Curr_ID numeric(18,0)=0    
  ,@Exchange_Rate numeric(18,2)=0    
  ,@Diff_Amount numeric(18,2)=0    
  ,@Is_Petrol tinyint=0    
  ,@Expe_KM numeric(18,2)=0    
  ,@Rate_KM numeric(18,2)=0    
  ,@File_Name varchar(500)=''    
  ,@City_ID numeric(18,0)=0    
  ,@Travel_Mode_ID numeric(18,0)=0    
  ,@Travel_Settlement_App_ID numeric(18,0)=null    
  ,@tran_type  Varchar(1)      
  ,@SGST  numeric(18,2) = 0 --Added by Jaina 22-09-2017    
  ,@CGST numeric(18,2) = 0  --Added by Jaina 22-09-2017    
  ,@IGST numeric(18,2) = 0  --Added by Jaina 22-09-2017      
  ,@GST_No nvarchar(15) = '' --Added by Jaina 5-12-2017    
  ,@GST_Company_Name nvarchar(250) = '' --Added by Jaina 5-12-2017    
  ,@Travel_Detail    xml = ''    
  ,@SelfPay tinyint
  ,@No_of_days numeric(18,2)
  ,@GuestName varchar(Max)
AS      
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
  --if @Claim_App_Docs =''      
    --set  @Claim_App_Docs = null      
   declare @visit tinyint     
   SET @visit = 0    
       
   if (@City_ID=0)    
 begin    
  set @City_ID=null;    
 End    
     
    
 ---- XML Records     
 DECLARE @Travel_Mode numeric(18,0)    
 DECLARE @From_Place varchar(50)    
 DECLARE @To_Place varchar(50)    
 DECLARE @Mode_Name varchar(50)    
 DECLARE @Mode_No varchar(50)    
 --DECLARE @Travel_Date varchar(15)    
 --DECLARE @Dep_Time varchar(15)    
 DECLARE @City varchar(50)    
 DECLARE @Check_Out_Date varchar(20)    
 DECLARE @No_Pessenger numeric(18,0)    
 DECLARE @Booking_Date varchar(20)    
 DECLARE @Pick_Up_Address varchar(MAX)    
 DECLARE @Pick_Up_Time varchar(15)    
 DECLARE @Drop_Address varchar(MAX)    
     
 DECLARE @Bill_No varchar(50)    
 DECLARE @TDescription varchar(MAX)    
     
 DECLARE @MODE_TRAN_ID AS NUMERIC(18,0)    
 SET @MODE_TRAN_ID = 0  
 
 select @Travel_Detail
     
 IF (@Travel_Detail.exist('/NewDataSet/Table1') = 1) -- For Web XML    
 BEGIN    
  SELECT Table1.value('(Travel_Mode/text())[1]','numeric(18,0)') AS Travel_Mode,    
  Table1.value('(From_Place/text())[1]','varchar(50)') AS From_Place,    
  Table1.value('(To_Place/text())[1]','varchar(50)') AS To_Place,    
  Table1.value('(Mode_Name/text())[1]','varchar(50)') AS Mode_Name,    
  Table1.value('(Mode_No/text())[1]','varchar(50)') AS Mode_No,    
      
  Table1.value('(City/text())[1]','varchar(50)') AS City,    
  Table1.value('(Check_Out_Date/text())[1]','varchar(20)') AS Check_Out_Date,    
  Table1.value('(No_Pessenger/text())[1]','varchar(50)') AS No_Pessenger,    
  Table1.value('(Booking_Date/text())[1]','varchar(20)') AS Booking_Date,    
  Table1.value('(Pick_Up_Address/text())[1]','varchar(255)') AS Pick_Up_Address,    
  Table1.value('(Pick_Up_Time/text())[1]','varchar(15)') AS Pick_Up_Time,    
  Table1.value('(Drop_Address/text())[1]','varchar(255)') AS Drop_Address,    
  Table1.value('(Bill_No/text())[1]','varchar(255)') AS Bill_No,    
  Table1.value('(Description/text())[1]','varchar(255)') AS [Description]    
      
  INTO #ItemTemp FROM @Travel_Detail.nodes('/NewDataSet/Table1') as Temp(Table1)    
 END     
      
     
  if @tran_type ='I'       
   begin      
         
  --declare @Emp_Code as numeric      
  --declare @str_Emp_Code as varchar(20)      
        
  SELECT @INT_ID  = ISNULL(MAX(INT_ID ),0) + 1     
  FROM T0140_TRAVEL_SETTLEMENT_EXPENSE  WITH (NOLOCK)    
       
     SELECT  @EXPENSE_TYPE_ID = EXPENSE_TYPE_ID     
     FROM T0040_EXPENSE_TYPE_MASTER WITH (NOLOCK)    
     WHERE EXPENSE_TYPE_NAME = @EXPENSE_TYPE_ID AND CMP_ID=@CMP_ID    
      
      
         
  Create table #TravelHySchemeSett    
  (    
   RptLevel numeric(18,0),    
   Scheme_id numeric(18,0),    
   DynHierId numeric(18,0),    
   TravelTypeId varchar(50),    
   AppEmp numeric(18,0),    
   AprId numeric(18,0),    
   RptEmp numeric(18,0),    
   CreateDate DateTime    
    )    
       
   --if Exists(select Travel_approval_id from T0140_Travel_Settlement_Application where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID)    
 --Begin         
  INSERT INTO T0140_Travel_Settlement_Expense      
   (      
       
    int_Id,Travel_Approval_Id,Emp_ID,Cmp_ID,For_Date,Amount,Expense_Type_id,Comments,Missing,From_Time,To_Time,Duration,TravelAllowance,Limit_Amount, Grp_Emp,Grp_Emp_ID,    
    Overlimit_Expense,Curr_ID,Exchange_Rate,Diff_Amount,is_petrol,Exp_KM,RateKM,FileName,    
    City_ID,Travel_Mode_ID,Travel_Set_Application_id,SGST,CGST,IGST,GST_No,GST_Company_Name,SelfPay,No_of_Days,GuestName    
   )      
   VALUES            
     (    
    @Int_Id      
      ,@Travel_Approval_ID      
      ,@Emp_ID     
      ,@Cmp_ID     
      ,@for_Date     
    ,@Amount      
      ,@expense_type_id      
      ,@Comments      
      ,@Missing       
      ,@from_Time    
      ,@To_Time     
      ,@Duration    
      ,@Travel_Allowance    
      ,@Limit_Amnt    
      ,@Grp_Emp    
      ,@Grp_Emp_ID    
      ,@Ovrlmt_Expense    
      ,@Curr_ID    
      ,@Exchange_Rate    
      ,@Diff_Amount    
      ,@Is_Petrol    
      ,@Expe_KM    
      ,@rate_km    
      ,@File_Name    
      ,@City_ID    
      ,@Travel_Mode_ID    
      ,@Travel_Settlement_App_ID    
      ,@SGST    
      ,@CGST    
      ,@IGST    
      ,@GST_No    
      ,@GST_Company_Name    
      ,@SelfPay
	  ,@No_of_days
	  ,@GuestName
      )      
          
       
    
      -- Deepal date:- 19022022    
      insert into #TravelHySchemeSett    
     SELECT isnull(max(Rpt_Level),0) as RPT_max_level,Scheme_Id,Dyn_Hier_Id,Leave as TravelTypeId,@Emp_ID as App_Emp, case when @Travel_Approval_ID=0 then @Travel_Settlement_App_ID else @Travel_Approval_ID end as AprId    
    ,Dy.DynHierColValue as RptEmp,GetDate() as CreatedDate     
    FROM T0050_Scheme_Detail SD    
    inner join T0080_DynHierarchy_Value Dy on sd.Dyn_Hier_Id = DY.DynHierColId and Dy.Emp_ID = @Emp_ID      
    where Scheme_Id = (    
           SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id     
           WHERE Emp_ID = @Emp_ID And Type = 'Travel Settlement'     
           AND Effective_Date = (SELECT max(Effective_Date)     
                  from T0095_EMP_SCHEME where Emp_ID = @Emp_ID And Type = 'Travel Settlement'      
                  AND Effective_Date <= getdate())     
           AND (SELECT top 1 TravelTypeId from V0140_Travel_Settlement_Application_New_Level where Travel_Approval_ID = @Travel_Approval_ID and Travel_set_Application_Id=@Travel_Settlement_App_ID and TravelTypeId!=0) IN (select data from dbo.split(leave,'#')))     
    AND (SELECT top 1 TravelTypeId from V0140_Travel_Settlement_Application_New_Level where Travel_Approval_ID = @Travel_Approval_ID and Travel_set_Application_Id=@Travel_Settlement_App_ID and TravelTypeId!=0 ) IN (select data from dbo.split(leave,'#'))  
  

    GROUP BY Scheme_Id,Dyn_Hier_Id,Leave,DynHierColValue    
    
        --select * from #TravelHySchemeSett   
          
      If ((Select Count(1) from T0080_Travel_HycScheme_Email_Sett) > 0)     
       Truncate table T0080_Travel_HycScheme_Email_Sett    
    
    insert into T0080_Travel_HycScheme_Email_Sett    
    select * from #TravelHySchemeSett    
        
    MERGE T0080_Travel_HycScheme_Sett AS Target    
    
      USING #TravelHySchemeSett AS Source    
      ON Source.RptLevel = Target.RptLevel and     
       Source.Scheme_id = Target.SchemeIId and    
       Source.DynHierId = target.DynHierId and    
       Source.TravelTypeId = target.TravelTypeId and     
       source.AppEmp = target.AppEmp and     
       source.AprId = target.AppId and    
       source.RptEmp = target.RptEmp    
      WHEN NOT MATCHED BY Target THEN    
       INSERT (RptLevel,SchemeIId, DynHierId,TravelTypeId,AppEmp,AppId,RptEmp,CreateDate)     
       VALUES (Source.RptLevel,Source.Scheme_id, Source.DynHierId,source.TravelTypeId,source.AppEmp,source.AprId,source.RptEmp,getdate())    
      WHEN MATCHED THEN     
       UPDATE SET    
       Target.RptLevel = Source.RptLevel,    
       Target.SchemeIId = Source.Scheme_id,    
       Target.DynHierId = Source.DynHierId,    
       Target.TravelTypeId = Source.TravelTypeId,    
       Target.AppEmp = Source.AppEmp,    
       Target.AppId = Source.AprId,    
       Target.RptEmp = Source.RptEmp,    
       Target.CreateDate = GetDate();    
      -- Deepal date:- 19022022    
          
    ---- CURSOR FOR TRAVEL MODE DETAILS ENTRY    
        
   DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR      
   SELECT TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,NO_PESSENGER,    
     CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,    
     PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION]     
   FROM #ITEMTEMP    
       
   OPEN ITEM_CURSOR    
   FETCH NEXT FROM ITEM_CURSOR INTO @TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,    
            @PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription     
    
   WHILE @@fetch_status = 0    
    BEGIN    
         
     SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1     
     FROM T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK)    
    
         
     INSERT INTO T0140_Travel_Settlement_Mode_Expense    
     (    
      TRAN_ID,    
      CMP_ID,    
      INT_ID,    
      TRAVEL_APPROVAL_ID,    
      TRAVEL_SET_APPLICATION_ID,    
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
     VALUES    
     (    
      @MODE_TRAN_ID,    
      @CMP_ID,    
      @INT_ID,    
      @TRAVEL_APPROVAL_ID,    
      @TRAVEL_SETTLEMENT_APP_ID,    
      @TRAVEL_MODE,    
      @FROM_PLACE,    
      @TO_PLACE,    
      @MODE_NAME,    
      @MODE_NO,    
      @CITY,    
      @CHECK_OUT_DATE,    
      @NO_PESSENGER,    
      @BOOKING_DATE,    
      @PICK_UP_ADDRESS,    
      @PICK_UP_TIME,    
      @DROP_ADDRESS,    
      @BILL_NO,    
      @TDescription    
         
     )    
         
     FETCH NEXT FROM ITEM_CURSOR INTO @TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,    
              @PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription     
    END    
   CLOSE ITEM_CURSOR    
   DEALLOCATE ITEM_CURSOR    
       
           
 End    
 --END      
     
 else if @tran_type ='U'       
    begin      
         
     update T0140_Travel_Settlement_Expense       
     set      
     for_Date = @for_Date      
     ,Amount = @Amount    
     ,expense_type_id = @expense_type_id      
     ,Comments = @Comments    
     ,Missing=@Missing    
     ,From_Time = @From_Time --Added by Gadriwala 01122014    
     ,To_Time = @To_Time --Added by Gadriwala 01122014    
     ,Duration = @Duration --Added by Gadriwala 01122014    
     ,TravelAllowance=@Travel_Allowance    
     ,Limit_Amount=@Limit_Amnt    
     ,Grp_Emp=@Grp_Emp    
     ,Grp_Emp_ID=@Grp_Emp_ID    
     ,Overlimit_Expense=@Ovrlmt_Expense    
     ,Curr_ID=@Curr_ID    
  ,Exchange_Rate=@Exchange_Rate    
  ,Diff_Amount=@Diff_Amount    
  ,is_petrol=@Is_Petrol    
  ,Exp_KM=@Expe_KM    
  ,RateKM=@Rate_KM    
  ,fileName=@File_Name    
  ,City_ID=@City_ID    
  ,Travel_Mode_ID=@Travel_Mode_ID    
  ,Travel_Set_Application_id=@Travel_Settlement_App_ID    
  ,SGST = @SGST    
  ,CGST = @CGST    
  ,IGST = @IGST    
  ,GST_No = @GST_No    
  ,GST_Company_Name  = @GST_Company_Name    
  ,SelfPay=@SelfPay  
  ,No_of_Days=No_of_days
  ,GuestName=@GuestName
     where       
     emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID and Travel_Set_Application_id=@Travel_Settlement_App_ID  and int_id=@Int_Id    
         
         
         
    ---- CURSOR FOR TRAVEL MODE DETAILS ENTRY    
   DECLARE ITEM_CURSOR CURSOR  FAST_FORWARD FOR      
   SELECT TRAVEL_MODE,FROM_PLACE,TO_PLACE,MODE_NAME,MODE_NO,CITY,CONVERT(DATETIME,CHECK_OUT_DATE,103) AS CHECK_OUT_DATE,NO_PESSENGER,    
     CONVERT(DATETIME,BOOKING_DATE,103) AS BOOKING_DATE,    
     PICK_UP_ADDRESS,PICK_UP_TIME,DROP_ADDRESS,BILL_NO,[DESCRIPTION]     
   FROM #ITEMTEMP    
       
   OPEN ITEM_CURSOR    
   FETCH NEXT FROM ITEM_CURSOR INTO @TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,    
            @PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription     
   WHILE @@fetch_status = 0    
    BEGIN    
         
     SELECT @MODE_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1     
     FROM T0140_Travel_Settlement_Mode_Expense WITH (NOLOCK)    
    
         
     INSERT INTO T0140_Travel_Settlement_Mode_Expense    
     (    
      TRAN_ID,    
      CMP_ID,    
      INT_ID,    
      TRAVEL_APPROVAL_ID,    
      TRAVEL_SET_APPLICATION_ID,    
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
     VALUES    
     (    
      @MODE_TRAN_ID,    
      @CMP_ID,    
      @INT_ID,    
      @TRAVEL_APPROVAL_ID,    
      @TRAVEL_SETTLEMENT_APP_ID,    
      @TRAVEL_MODE,    
      @FROM_PLACE,    
      @TO_PLACE,    
      @MODE_NAME,    
      @MODE_NO,    
      @CITY,    
      @CHECK_OUT_DATE,    
      @NO_PESSENGER,    
      @BOOKING_DATE,    
      @PICK_UP_ADDRESS,    
      @PICK_UP_TIME,    
      @DROP_ADDRESS,    
      @BILL_NO,    
      @TDescription    
         
     )    
         
     FETCH NEXT FROM ITEM_CURSOR INTO @TRAVEL_MODE,@FROM_PLACE,@TO_PLACE,@MODE_NAME,@MODE_NO,@CITY,@CHECK_OUT_DATE,@NO_PESSENGER,@BOOKING_DATE,    
              @PICK_UP_ADDRESS,@PICK_UP_TIME,@DROP_ADDRESS,@BILL_NO,@TDescription     
    END    
   CLOSE ITEM_CURSOR    
   DEALLOCATE ITEM_CURSOR    
         
         
    end      
  else if @tran_type ='D'      
  begin      
      
  delete from T0140_Travel_Settlement_Expense where emp_id=@Emp_ID and Travel_Approval_ID = @Travel_Approval_ID and Travel_Set_Application_id=@Travel_Settlement_App_ID  and int_id=@Int_Id    
      
  end    
      
 RETURN      
      
      
      
      
      