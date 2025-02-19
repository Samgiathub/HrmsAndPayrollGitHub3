  
Create PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Leave_18012024]  
 @Leave_Application_ID numeric(18,0),   
 @Emp_ID numeric(18,0),  
 @Cmp_ID numeric(18,0),  
 @Leave_ID numeric(18,0),  
 @From_Date datetime,  
 @To_Date datetime,  
 @Period numeric(18,2),   
 @Leave_Assign_As varchar(15),  
 @Comment varchar(50),  
 @Half_Leave_Date DATETIME='',  
 @InTime DATETIME = '',  
 @OutTime DATETIME = '',  
 @Login_ID numeric(18,0),  
 @strLeaveCompOff_Dates varchar(MAX) = '',  
 @Attachment varchar(MAX) = '',  
 @Type char(1),  
 @Result VARCHAR(MAX) OUTPUT  
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
DECLARE @GradeID numeric(18,0)  
DECLARE @Gender varchar(50)  
DECLARE @MaritalStatus int = 0  
  
  
DECLARE @Date datetime  
  
  
DECLARE @Leave_Min numeric(18,2)  
DECLARE @Leave_Max numeric(18,2)  
DECLARE @Leave_Closing numeric(18,2)  
DECLARE @Actual_Leave_Opening numeric(18,2)  
DECLARE @Leave_Code varchar(50)  
DECLARE @Leave_Negative_Allow int  
DECLARE @Can_Apply_Fraction int  
DECLARE @Leave_Negative_Max_Limit numeric(18,0)  
DECLARE @Days int  
DECLARE @SettingValue int  
DECLARE @msg varchar(255)  
  
DECLARE @RowID numeric(18,0)  
DECLARE @DOJ DATETIME  
DECLARE @JoiningDays int  
DECLARE @LeaveApplicable int  
DECLARE @PunchRequire int  
DECLARE @SettingValue1 int = 0  
  
DECLARE @Branch_ID int = 0  
DECLARE @Multi_Branch_Setting int = 0  
  
IF @Type = 'B' --- For Leave Bind  
 BEGIN  
  SELECT @GradeID = ISNULL(Grd_ID,0),@Gender=Gender,@MaritalStatus=Marital_Status,@Branch_ID=Branch_ID FROM  V0080_Employee_Master WHERE Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  
  Select @SettingValue1 = Setting_Value from T0040_SETTING where Setting_Name like '%Employee can apply Maternity and Paternity leave in case employee status is single%' and Cmp_ID = @Cmp_ID  
  Select @Multi_Branch_Setting = Setting_Value from T0040_SETTING where Setting_Name = 'Branch wise Leave' and CMP_ID = @Cmp_ID  
  --SELECT Leave_ID,Leave_Name  
  --FROM V0040_LEAVE_DETAILS   
  --WHERE (1=(CASE ISNULL(Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END)) AND Grd_ID = @GradeID AND Cmp_ID = @Cmp_ID  
  --AND Leave_Name <> 'Comp-Off Leave'  
    
  --SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly  
  --FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
  --INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
  --WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END)) AND LD.Grd_ID = @GradeID AND LM.Cmp_ID = @Cmp_ID  
    
  if @SettingValue1 = 1  
  Begin  
   if @Gender = 'Male'   
   Begin   
    SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly  
    FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
    INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
    WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END))   
    AND LD.Grd_ID = @GradeID AND LM.Cmp_ID = @Cmp_ID and leave_name <> 'Maternity Leave' --order by Leave_Sorting_No -- Added by Niraj(08122021)  
    -- End Added by Niraj(02072022)  
     AND  
      (  
       ((@Multi_Branch_Setting = 1)  
       AND  
       (@Branch_ID in (Select data FROM Split(Multi_Branch_ID, '#')) OR Multi_Branch_ID = ''))  
       OR   
       @Multi_Branch_Setting = 0  
      )  
     order by Leave_Sorting_No  
     -- End Added by Niraj(02072022)  
   END  
   Else  
   Begin   
    SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly  
    FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
    INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
    WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END))   
    AND LM.Cmp_ID = @Cmp_ID AND LD.Grd_ID = @GradeID  and leave_name <> 'Paternity Leave' --order by Leave_Sorting_No -- Added by Niraj(08122021)  
    -- End Added by Niraj(02072022)  
     AND  
      (  
       ((@Multi_Branch_Setting = 1)  
       AND  
       (@Branch_ID in (Select data FROM Split(Multi_Branch_ID, '#')) OR Multi_Branch_ID = ''))  
       OR   
       @Multi_Branch_Setting = 0  
      )  
     order by Leave_Sorting_No  
     -- End Added by Niraj(02072022)  
   END  
  END  
  ELSe  
  Begin  
   if @MaritalStatus = 0  
   Begin  
    if @Gender = 'Male' or @Gender = 'Female'  
    Begin   
     SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly  
     FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
     INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
     WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END))   
     AND LD.Grd_ID = @GradeID AND LM.Cmp_ID = @Cmp_ID and leave_name not in ('Maternity Leave','Paternity Leave') --order by Leave_Sorting_No -- Added by Niraj(08122021)  
     -- End Added by Niraj(02072022)  
     AND  
      (  
       ((@Multi_Branch_Setting = 1)  
       AND  
       (@Branch_ID in (Select data FROM Split(Multi_Branch_ID, '#')) OR Multi_Branch_ID = ''))  
       OR   
       @Multi_Branch_Setting = 0  
      )  
     order by Leave_Sorting_No  
     -- End Added by Niraj(02072022)  
    END  
   END  
   ELSE  
   BEGIN  
    if @Gender = 'Male'   
    Begin   
     SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly,Multi_Branch_ID  
     FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
     INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
     WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END))   
     AND LD.Grd_ID = @GradeID AND LM.Cmp_ID = @Cmp_ID and leave_name <> 'Maternity Leave'  
     -- End Added by Niraj(02072022)  
     AND  
      (  
       ((@Multi_Branch_Setting = 1)  
       AND  
       (@Branch_ID in (Select data FROM Split(Multi_Branch_ID, '#')) OR Multi_Branch_ID = ''))  
       OR   
       @Multi_Branch_Setting = 0  
      )  
     order by Leave_Sorting_No  
     -- End Added by Niraj(02072022)  
    END  
    Else  
    Begin   
     --select @Cmp_ID,@GradeID,@Multi_Branch_Setting,@Branch_ID  
     SELECT LM.Leave_ID,LM.Leave_Name,LM.Leave_Code,LM.Attachment_Days,LM.is_Document_Required,LM.Leave_Type,LM.Apply_Hourly  
     FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)  
     INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
     WHERE (1=(CASE ISNULL(LM.Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(LM.InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END))   
     AND LM.Cmp_ID = @Cmp_ID AND LD.Grd_ID = @GradeID  and leave_name <> 'Paternity Leave' -- order by Leave_Sorting_No -- Added by Niraj(08122021)  
     -- End Added by Niraj(02072022)  
     AND  
      (  
       ((@Multi_Branch_Setting = 1)  
       AND  
       (@Branch_ID in (Select data FROM Split(Multi_Branch_ID, '#')) OR Multi_Branch_ID = ''))  
       OR   
       @Multi_Branch_Setting = 0  
      )  
     order by Leave_Sorting_No  
     -- End Added by Niraj(02072022)  
       
    END  
   END  
  ENd  
    
  --AND LM.Leave_Name <> 'Comp-Off Leave'  
 END  
ELSE IF @Type = 'S' --- For Leave Application Records  
 BEGIN  
  SELECT * FROM  
  (  
   SELECT  0 AS 'Leave_Approval_ID',VL.Leave_Application_ID, VL.Application_Status,(CASE WHEN VL.Application_Status = 'A' THEN 'Approved' ELSE (CASE WHEN VL.Application_Status = 'P' THEN 'Pending' ELSE 'Rejected' END )END) AS 'AppStatus',  
   VL.Cmp_ID,VL.Leave_ID,CONVERT(varchar(11),VL.From_Date,103) AS 'From_Date',CONVERT(varchar(11),VL.To_Date,103) AS 'To_Date',  
   CONVERT(varchar(11),VL.Application_Date,103) AS 'Application_Date',VL.Leave_Period AS 'LeaveAppDays',  
   (CASE WHEN ISNULL(LLA.Leave_Period,0) = 0 THEN VL.Leave_Period ELSE LLA.Leave_Period END) AS 'LeaveApprDays',  
   LM.Leave_Code,VL.Leave_Assign_As,VL.Leave_Reason,VL.Leave_Name,VL.Senior_Employee,VL.Emp_Full_Name,  
   ISNULL(VL.Emp_Superior,0) AS 'Emp_Superior',CONVERT(varchar(11),VL.Half_Leave_Date,103) AS 'Half_Leave_Date',  
   VL.Application_Comments  
   ,LLA.Approval_Comments  
   ,VL.Leave_CompOff_Dates,0 as LeaveCancelCount  
   FROM V0110_LEAVE_APPLICATION_DETAIL VL   
   LEFT JOIN   
   (   
    SELECT MAX(Tran_ID) AS 'Tran_ID' ,Emp_ID,Leave_Application_ID   
    FROM T0115_Leave_Level_Approval WITH (NOLOCK)  
    GROUP BY Emp_ID,Leave_Application_ID   
   ) AS LL ON VL.Leave_Application_ID = LL.Leave_Application_ID   
   INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON VL.Leave_ID = LM.Leave_ID  
   LEFT JOIN T0115_Leave_Level_Approval LLA WITH (NOLOCK) ON VL.Leave_Application_ID = LLA.Leave_Application_ID  
   WHERE VL.Cmp_ID = @Cmp_ID AND VL.Emp_ID = @Emp_ID AND VL.From_Date >= CONVERT(DATETIME, @From_Date,103) AND VL.To_Date <= CONVERT(DATETIME, @To_Date,103)    
   AND VL.Application_Status = 'P'  
     
   UNION ALL  
     
   SELECT  LA.Leave_Approval_ID, ISNULL(LA.Leave_Application_ID,0) AS 'Leave_Application_ID',LA.Approval_Status AS 'Application_Status',  
   (CASE WHEN LA.Approval_Status = 'A' THEN 'Approved' ELSE (CASE WHEN LA.Approval_Status = 'P' THEN 'Pending' ELSE 'Rejected' END )END) AS 'AppStatus',  
   LA.Cmp_ID,LA.Leave_ID,CONVERT(VARCHAR(11),LA.From_Date,103) AS 'From_Date',  
   CONVERT(VARCHAR(11),LA.To_Date,103) AS 'To_Date',  
   CONVERT(VARCHAR(11),LA.Approval_date,103) AS 'Approval_date',ISNULL(LD.Leave_Period,0.00) AS 'LeaveAppDays',  
   LA.Leave_Period AS 'LeaveApprDays',LM.Leave_Code,LA.Leave_Assign_As,  
   LA.Leave_Reason,LA.Leave_Name,LA.Senior_Employee,LA.Emp_Full_Name,LA.S_Emp_ID as 'Emp_Superior',  
    Convert(varchar(11),LA.Half_Leave_Date,103) AS 'Half_Leave_Date','' AS 'Application_Comments',  
    LA.Approval_Comments,  
   LD.Leave_CompOff_Dates,isnull(VC.LeaveCancelCount,0)  
   FROM V0120_LEAVE_APPROVAL LA  
   INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LA.Leave_ID = LM.Leave_ID  
   left outer JOIN (   
       select Leave_Approval_id, count(1) as LeaveCancelCount   
       from V0150_LEAVE_CANCELLATION where Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID  
       group by Leave_Approval_id  
    )  VC on VC.Leave_Approval_id =LA.Leave_Approval_ID  
   LEFT JOIN T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK) ON LA.Leave_Application_ID = LD.Leave_Application_ID  
   WHERE LA.Cmp_ID= @Cmp_ID AND LA.Emp_ID=@Emp_ID AND (Approval_Status = 'A' or Approval_Status  = 'R' or Approval_Status='F')   
   AND LA.From_Date >= CONVERT(DATETIME, @From_Date,103) AND LA.To_Date <= CONVERT(DATETIME, @To_Date,103)    
   --Order By From_Date desc  
  ) AS QRY  
  ORDER BY  Leave_Application_ID desc ,CONVERT(DATETIME,From_Date,103) DESC  
    
  SELECT * FROM  
  (  
   SELECT distinct 0 AS Tran_ID,VL.Leave_Application_ID, CONVERT(VARCHAR(20),vl.From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),To_Date,103) AS 'To_Date',Leave_Period,  
   Leave_Reason AS 'Comment', Application_Status,CONVERT(VARCHAR(20),VL.System_Date,103) AS 'System_Date' , 'Application' As 'Rpt_Level',  
   VL.Emp_Full_Name,  
   (CASE WHEN EM.Image_Name = '0.jpg' OR ISNULL(EM.Image_Name,'') = '' THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name',  
   '' AS 'Image_Path'   
   --,0 as LeaveCancelCount  
   FROM V0110_LEAVE_APPLICATION_DETAIL VL  
   INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON VL.Emp_ID = EM.Emp_ID  
   --left JOIN V0150_LEAVE_CANCELLATION_APPROVAL as TLC on TLC.Leave_Application_ID =VL.Leave_Application_ID  
   WHERE VL.Cmp_ID = @Cmp_ID AND VL.Emp_ID = @Emp_ID AND VL.From_Date >= CONVERT(DATETIME, @From_Date,103) AND VL.To_Date <= CONVERT(DATETIME, @To_Date,103)    
   --WHERE Leave_Application_ID = @Leave_Application_ID   
     
   UNION   
  
   SELECT distinct TL.Tran_ID ,TL.Leave_Application_ID,CONVERT(VARCHAR(20),TL.From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),TL.To_Date,103) AS 'To_Date',TL.Leave_Period,  
   TL.Approval_Comments AS 'Comment',TL.Approval_Status, CONVERT(VARCHAR(20),TL.System_Date,103) AS 'System_Date',  
   (CASE WHEN Rpt_Level = 1 THEN 'First' ELSE (CASE WHEN Rpt_Level = 2 THEN 'Second' ELSE ( CASE WHEN Rpt_Level = 3 THEN 'Third' ELSE (CASE WHEN Rpt_Level = 4 THEN 'Fourth' ELSE 'Fifth' END) END ) END) END ) AS 'Rpt_Level',  
   (EM.Initial + ' '+ EM.Emp_First_Name + ' '+ ISNULL(EM.Emp_Second_Name,'') + ' ' + ISNULL(EM.Emp_Last_Name,'')) AS 'S_Emp_Full_Name',  
   (CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name',  
   '' AS 'Image_Path'   
   --,VC.LeaveCancelCount   
   FROM T0115_Leave_Level_Approval TL WITH (NOLOCK)  
   Left join T0120_LEAVE_APPROVAL TA WITH (NOLOCK) on TL.Leave_Application_ID = TA.Leave_Application_ID  
   INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.S_Emp_ID = EM.Emp_ID  
   --left outer JOIN (   
    --   select Leave_Approval_id, count(1) as LeaveCancelCount   
    --   from V0150_LEAVE_CANCELLATION where Emp_Id = @Emp_ID and Cmp_Id = @Cmp_ID  
    --   group by Leave_Approval_id  
   -- )  VC on VC.Leave_Approval_id =TA.Leave_Approval_ID  
   --WHERE Leave_Application_ID = @Leave_Application_ID  
   WHERE TL.Cmp_ID = @Cmp_ID AND TL.Emp_ID = @Emp_ID AND TL.From_Date >= CONVERT(DATETIME, @From_Date,103) AND TL.To_Date <= CONVERT(DATETIME, @To_Date,103)    
  ) AS QryLVL  
  Order by QryLVL.Leave_Application_ID,QryLVL.Tran_ID  
  
 END  
ELSE IF @Type = 'V' --- For Leave Validation  
 BEGIN  
  SET @Date = (SELECT Convert(varchar(20),getdate(),111))  
    
  CREATE TABLE #LeaveBalanceData  
  (  
   Leave_Opening numeric(18,2),  
   Leave_Used numeric(18,2),  
   Leave_Credit numeric(18,2),  
   Leave_Closing numeric(18,2),  
   Leave_Code varchar(50),  
   Leave_Name varchar(50),  
   Leave_ID numeric(18,0),  
   Display_LeaveBalance int,  
   Actual_Leave_Closing numeric(18,2),  
   Leave_Type varchar(50)  
  )  
  CREATE TABLE #LeaveDetails  
  (  
   Leave_Min numeric(18,2),  
   Leave_Max numeric(18,2),  
   Leave_Notice_Period int,  
   Leave_Applicable int,  
   Leave_Nagative_Allow int,  
   Leave_Paid_Unpaid varchar(20),  
   Is_Document_required int,  
   Apply_Hourly int,  
   Can_Apply_Fraction int,  
   Default_Short_Name varchar(50),  
   Leave_Name varchar(50),  
   AllowNightHalt int,  
   Half_Paid int,  
   Leave_Negative_Max_Limit numeric(18,2),  
   Min_Leave_Not_Mandatory int,  
   Attachment_Days numeric(18,0)  
  )  
    
  CREATE TABLE #Todate  
  (  
   From_Date datetime,  
   To_Date datetime,  
   Period numeric(18,2),  
   LeaveDate varchar(MAX),  
   WeekoffDate varchar(MAX),  
   HolidayDate varchar(MAX)  
  )      
  --INSERT INTO #LeaveBalanceData EXEC SP_LEAVE_CLOSING_AS_ON_DATE @Cmp_ID,@Emp_ID,@Date   
  --SELECt @Date  
  INSERT INTO #LeaveBalanceData EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @From_Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID  
  
  --INSERT INTO #LeaveDetails EXEC P0050_Leave_Details_Get @Cmp_ID,@Emp_ID,@Leave_ID  
  INSERT INTO #LeaveDetails EXEC P0050_Leave_Details_Get @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID  
  --INSERT INTO #LeaveClubbDetails EXEC Check_Leave_Clubbing @Emp_ID,@Cmp_Id,@From_DateFE,@To_DateFE,@From_DateLE,@To_DateLE,'LA',@Leave_ID  
    
    
  SELECT @Leave_Closing = Leave_Closing  FROM #LeaveBalanceData WHERE Leave_ID = @Leave_ID  
    
    
  SELECT @DOJ = Date_Of_Join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID  
    
  SET @JoiningDays = DATEDIFF(d,@DOJ,@From_Date)  
    
     
    
  SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow,  
  @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit,  
  @LeaveApplicable = Leave_Applicable   
  FROM #LeaveDetails  
    
  SELECT @PunchRequire = Punch_Required FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @Leave_ID  
    
  IF @PunchRequire = 1  
   BEGIN  
    IF NOT EXISTS (SELECT 1 FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE For_date = @From_Date AND Emp_ID= @Emp_ID)  
     BEGIN  
      SET @Result = 'Atleast one punch is required to apply leave#False#'  
      SELECT @Result  as Result  
      RETURN  
     END  
   END  
    
  IF @LeaveApplicable > 0  
   BEGIN  
    IF @LeaveApplicable > @JoiningDays  
     BEGIN  
      SET @Result = 'You can not apply this Leave during Probation Period#False#'  
      SELECT @Result  as Result  
      RETURN  
     END  
   END  
     
    
  SET @Days = @Period  
    
    
    
  IF (@Period - @Days) > 0  
   BEGIN  
    IF @Can_Apply_Fraction <> 1  
     BEGIN  
      SET @Result = 'You Cannot Enter Fraction Value#False#'  
      SELECT @Result  as Result  
      RETURN   
     END  
   END  
  IF  @Period < @Leave_Min AND @Leave_Min <> 0.0  
   BEGIN   
    SET @Result = 'You have to take Min ' + CAST(@Leave_Min AS varchar) + ' leave for selected leave Type#False#'  
    SELECT @Result  as Result  
    RETURN   
   END  
  IF  @Period > @Leave_Max AND @Leave_Max <> 0.0  
   BEGIN   
    SET @Result ='You have to take Max ' +  CAST(@Leave_Max AS varchar) + ' leave for selected leave Type#False#'  
    SELECT @Result  as Result  
    RETURN   
   END  
   --SELECT @Leave_Closing,@Period  
     
  SELECT @SettingValue = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Auto LWP Leave'  
  
  SET @msg = ''  
  
  IF @Period > @Leave_Closing  
   BEGIN   
     
    IF @Leave_Negative_Allow = 0 AND @SettingValue = 1  
     BEGIN  
      --SET @msg =  'Your Balance is ' + CAST(@Leave_Closing AS VARCHAR) +  '. So Your ' + CAST(@Period - @Leave_Closing AS VARCHAR) +  ' excess leave will be marked as LWP or correct your leave period or correct your leave type LWP'  
      SET @msg = 'No Enough Leave Balance.#False#' -- Added by Niraj for Bug #17625 29/06/2021  
      SELECT @msg as Result  
      RETURN  
     END  
    --Start by Niraj 30092021  
    ELSE IF @Leave_Negative_Allow = 1 AND @SettingValue = 1 AND @Leave_Negative_Max_Limit <> 0  
     BEGIN  
      --SET @msg =  'Your Balance is ' + CAST(@Leave_Closing AS VARCHAR) +  '. So Your ' + CAST(@Period AS VARCHAR) +  ' excess leave will be marked as LWP or correct your leave period or correct your leave type LWP'  
      SET @msg = 'No Enough Leave Balance.#False#' -- Added by Niraj for Bug #17625 29/06/2021  
      SELECT @msg as Result  
      RETURN  
     END  
    --End by Niraj 30092021  
    ELSE IF @Leave_Negative_Allow = 1 AND @SettingValue = 0 AND @Leave_Negative_Max_Limit <> 0  
     BEGIN  
      IF @Period > (@Leave_Closing + @Leave_Negative_Max_Limit)  
       BEGIN  
        --SET @Result =  'You have not take more leave for selected leave Type#False#'  
        SET @Result =  'Negative Leave is not allow.#False#' -- Added By Niraj(30092021)  
        SELECT @Result as Result  
        RETURN  
       END  
     END  
    ELSE IF @Leave_Negative_Allow = 0 AND @SettingValue = 0  
     BEGIN  
      --SET @Result =  'You have not take more leave for selected leave Type#False#'  
      SET @Result = 'No Enough Leave Balance#False#'   
      SELECT @Result as Result  
      RETURN   
     END  
      
    --ELSE IF @Leave_Negative_Allow = 1 AND @SettingValue = 1  
    -- BEGIN  
    --  SET @Result =  'You have not take more leave for selected leave Type#False#'  
    --  SELECT @Result  
    --  RETURN   
    -- END  
    --ELSE  
    -- BEGIN  
    --  SET @Result =  'You have not take more leave for selected leave Type#False#'  
    --  RETURN  
    -- END  
   END  
      
  IF @From_Date <> '1900-01-01 00:00:00' AND @Leave_ID <> 0 AND (@Period <> 0.0  OR @Period <> 0)  
   BEGIN  
    INSERT INTO #Todate EXEC Calculate_Leave_End_Date @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID,@From_Date = @From_Date,@Period = @Period,@Type = 'E'  
    ,@M_Cancel_weekoff_holiday =0,@Leave_Assign_As = 'Full Day'  
    --SET @Result =  DATEADD(d, @Period, @From_Date)  
    SELECT @Result = To_Date FROM #Todate  
      
    --SET @Result = isnull(@msg,'')+'#False#' + CONVERT(varchar(11),CONVERT(datetime, @Result,103),103)   
    SET @Result = '#True#' + CONVERT(varchar(11),CONVERT(datetime, @Result,103),103) -- Changed By Niraj(07102021)  
    SELECT @Result as Result  
    RETURN  
   END  
  ELSE  
   BEGIN  
    SET @Result = 'OK#True#'  
    SELECT @Result as Result  
   END  
  --IF @IS_Leave_Clubbed = 1  
  -- BEGIN  
  --  SET @Result = 'Selected Leave Cannot Club with Previous Leave Approved'  
  --  RETURN   
  -- END  
    
  --DROP TABLE #LeaveDetails  
  --DROP TABLE #LeaveBalanceData  
  --DROP TABLE #Todate  
   
 END  
ELSE IF @Type = 'H' --- For Get Half Leave Dates  
 BEGIN  
  EXEC Calculate_Leave_End_Date @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID,@From_Date = @From_Date,@Period = @Period,@Type = 'A',@M_Cancel_weekoff_holiday =0,@Leave_Assign_As = 'Full Day'  
 END  
ELSE IF @Type = 'I'  --- For Leave Application  
 BEGIN  
  DECLARE @From_DateFE datetime  
  DECLARE @To_DateFE datetime  
  DECLARE @From_DateLE datetime  
  DECLARE @To_DateLE datetime  
  DECLARE @IS_Leave_Clubbed int  
  DECLARE @IsBackdate numeric  
  DECLARE @Leave_Shutdown_Status int  
  DECLARE @ApplicatioDate datetime     
  DECLARE @S_Emp_ID  numeric  
  DECLARE @Fromdate_month int = 0  
  DECLARE @Current_month int = 0  
  
  SET @From_DateFE = DATEADD(d, -1, @From_Date)  
  SET @To_DateFE = DATEADD(d, 1, @From_Date)  
  SET @From_DateLE = DATEADD(d, -1, @From_Date)  
  SET @To_DateLE = DATEADD(d, 1, @From_Date)  
  SET @Leave_Application_ID = 0  
  SET  @IsBackdate = 0  
    
  -------------------------------------------------Start By Prapti 24/08/2022------------------------------------------------------  
   
  SET @Fromdate_month = month(@From_Date)  
  SET @Current_month = month(getdate())  
  
  Declare @year int = 0  
  SET @year = Year(@From_Date)  
  --select @year, YEAR(GETDATE()),87  
  
  ------------------------------------------For Leave Validation-------------------------------------------------------------  
  
  
  DECLARE @dt_punchboth_leave int,@dt_punchboth int  
  DECLARE @in_time VARCHAR(200),@out_time VARCHAR(200)  
    
  IF ((Select isnull(PunchBoth_Required,0) from T0040_Leave_MASTER  WHERE PUNCHBOTH_REQUIRED = 1 and Leave_id = @Leave_ID) > 0)  
  BEGIN  
    select @IN_TIME = In_Time,@OUT_TIME = Out_Time   
       from T0150_EMP_INOUT_RECORD   
       where convert(varchar(15),For_date,103) = convert(varchar(15),@From_Date,103)    
       and Emp_ID= @Emp_ID  
  
   IF @InTime='' OR @OUT_TIME = ''  
   BEGIN  
     IF @InTime=''   
     BEGIN  
      SET @RESULT = 'IN Punch is required to apply leave#FALSE#'  
      SELECT @RESULT AS RESULT  
      RETURN   
     END   
     ELSe If  @OUT_TIME = ''  
     BEGIN  
      SET @RESULT = 'Out Punch is required to apply leave#FALSE#'  
      SELECT @RESULT AS RESULT  
      RETURN   
     ENd  
   End  
   Else IF @InTime='' AND @OUT_TIME = ''  
    Begin  
     SET @Result = 'You can not apply more than 1 day as this leave required atleast two punch#False#'  
     SELECt @Result as Result  
     RETURN   
   END  
  END  
    
  
  
------------------------------------------For Notice period Leave Validation-------------------------------------------------------------  
  
  
  
  If(@Fromdate_month = @Current_month)  
   Begin  
  
   --select @Cmp_ID,@Leave_ID,@Period,@From_Date,  
   -- 'Day(s)',@Emp_ID, @To_Date  
    
  
   exec Mobile_HRMS_P_Check_Leave_Notice_Period @CMP_ID=@Cmp_ID,@LEAVE_ID=@Leave_ID,@LEAVE_PERIOD=@Period,@FROM_DATE=@From_Date,  
   @LEAVE_TYPE = 'Day(s)',@Emp_Id=@Emp_ID,@To_Date = @To_Date  
  
  
   --select Object_ID('tempdb..##NOTICE_MSG')  
   IF Object_ID('tempdb..##NOTICE_MSG') Is Not null  
    Begin  
      
     if ((Select count(1) from ##NOTICE_MSG) > 0)  
     BEGIN  
     DECLARE @Notice_result varchar(500)  = ''  
     SELECT @Notice_result =  NOTICE_MSG from ##NOTICE_MSG  
       
     If(@Notice_result != '')   
     Begin  
      set @Result = @Notice_result+'#False#'   
      SELECt @Result as Result  
	  
      RETURN   
     End  
    ENd  
   end  
  End  
  
 ------------------------------------------For Privious Month Leave Validation-------------------------------------------------------------  
   
 Declare @Fromdate_1 date=''  
 Declare @ToDate_1 date=''  
 Declare @curr_year int = YEAR(GETDATE())  
  
 select @Fromdate_1 = CAST(CAST(YEAR(@From_Date) AS VARCHAR(4)) + '/' + CAST(MONTH(@From_Date) AS VARCHAR(2)) + '/01' AS DATETIME)   
  
 select  @ToDate_1 =  eomonth(@Fromdate_1)   
  
 --select @year, @curr_year,87  
 --select @Fromdate_month, @Current_month,@year,@curr_year  
 IF(@Fromdate_month < @Current_month AND @year<= @curr_year)  
  Begin  
  
  --select 'aay gyu'  
    Declare @setting int  
    
    select @setting = Setting_Value from T0040_SETTING where Cmp_ID = @Cmp_ID  
     and Setting_Name ='Check Absent History of Previous Month in Leave'   
  
  If(@setting = 1)  
  Begin  
  
   IF Object_ID('tempdb..#Privious_month_Record') Is NOT null  
   Begin  
    Drop Table #Privious_month_Record  
   End  
   
   exec Mobile_HRMS_SP_EMP_Absent_History_RECORD_GET @Cmp_ID=@Cmp_ID,@Emp_Id=@Emp_ID,@From_Date=@Fromdate_1,@To_Date= @ToDate_1,  
   @Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=@GradeID,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Constraint=''   
  
   Select For_Date into #Privious_month_Record from ##Privious_month_Record  
  
   Declare @countPer int = 0  
   Declare @thisdate varchar(100) = @From_Date  
  
   set @countPer = @Period   
  
   while(@countPer >= 0)  
   Begin  
    IF exists(select for_date from #Privious_month_Record where for_date = convert(varchar(100),cast(@From_Date as date),103))  
     Begin  
      SELECT @thisdate = (@From_Date + @countPer ) - 1   
      set @countPer = @countPer - 1  
     End  
    Else  
     Begin  
      SET @Result = 'Selected Date not Exists in Absent History#False#'  
      SELECT @Result as Result  
      RETURN   
     End  
    End  
   End  
 End  
 --set @From_Date = convert(varchar(50),@From_Date,103)  
-------------------------------------------------End By Prapti 24/08/2022--------------------------------------------------------------------------  
  
  CREATE table #LeaveClubbDetails  
  (  
   Leave_ID numeric(18,0),  
   For_Date datetime,  
   App_ID numeric(18,0),  
   Apr_ID numeric(18,0),  
   Assign_AS varchar(50)  
  )       
  
  CREATE TABLE #Check_Leave_Shutdown_Period  
  (  
   Leave_Shutdown_Status varchar(100)  
  )  
  
  IF @Half_Leave_Date = ''  
   BEGIN  
    SET @Half_Leave_Date = '1900-01-01 00:00:00'  
   END  
  IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date<= @From_Date And Month_End_Date>= @To_Date and Emp_ID = @Emp_ID and Cmp_ID=@Cmp_ID)  
   BEGIN  
    SET @IsBackdate = 1  
   END  
  INSERT INTO #Check_Leave_Shutdown_Period  
  EXEC SP_Check_Leave_Shutdown_Period @Cmp_Id = @Cmp_Id,@Emp_Id = @Emp_ID,  
  @Leave_Id = @Leave_ID,@From_Date = @From_Date,@To_Date = @To_Date  
    
  SELECT @Leave_Shutdown_Status = COUNT(*) FROM #Check_Leave_Shutdown_Period  
  IF @Leave_Shutdown_Status = 1  
   BEGIN  
    SET @Result = 'Can''t take leave on this dates#False#'  
    SELECt @Result as Result  
    RETURN   
   END  
     
     
   --SELECT @Emp_ID,@Cmp_Id,@From_DateFE,@To_DateFE,@From_DateLE,@To_DateLE,'LA',@Leave_ID,0,@Period,@Leave_Assign_As,@Half_Leave_Date  
     
   INSERT INTO #LeaveClubbDetails   
   EXEC Check_Leave_Clubbing @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_Id,@From_DateFE = @From_DateFE,@To_DateFE = @To_DateFE,@From_DateLE = @From_DateLE,@To_DateLE = @To_DateLE,@Tag = 'LP',@Leave_Id = @Leave_ID,@Leave_App_Id = 0,@Leave_Period = @Period,@Leave_Day
 = @Leave_Assign_As,@Leave_Half_Date = @Half_Leave_Date  
       
   --exec Check_Leave_Clubbing @Emp_Id=17581,@Cmp_Id=149,@From_DateFE='2017-08-27 00:00:00',@To_DateFE='2017-08-29 00:00:00',@From_DateLE='2017-08-27 00:00:00',@To_DateLE='2017-08-29 00:00:00',@Tag='LA',@Leave_Id=551,@Leave_App_Id=0,@Leave_Period=1,@Leave_Day='Full Day',@Leave_Half_Date='2017-08-28 00:00:00'  
   --exec Check_Leave_Clubbing @Emp_Id=17581,@Cmp_Id=149,@From_DateFE='2017-08-29 00:00:00',@To_DateFE='2017-08-31 00:00:00',@From_DateLE='2017-08-29 00:00:00',@To_DateLE='2017-08-31 00:00:00',@Tag='LA',@Leave_Id=551,@Leave_App_Id=0,@Leave_Period=1,@Leave_Day='Full Day',@Leave_Half_Date='2017-08-30 00:00:00'  
     
   --exec Check_Leave_Clubbing @Emp_Id=17581,@Cmp_Id=149,@From_DateFE='2017-08-29 00:00:00',@To_DateFE='2017-08-31 00:00:00',@From_DateLE='2017-08-29 00:00:00',@To_DateLE='2017-08-31 00:00:00',@Tag='LA',@Leave_Id=551,@Leave_App_Id=2412,@Leave_Period=1,@Leave_Day='Full Day',@Leave_Half_Date='2017-08-30 00:00:00'  
     
   SELECT @IS_Leave_Clubbed = COUNT(*) FROM #LeaveClubbDetails  
   --SELECT @IS_Leave_Clubbed = IS_Leave_Clubbed  FROM #LeaveClubbDetails  
     
   --SELECT * FROM #LeaveClubbDetails  
       
   IF @IS_Leave_Clubbed = 1  
    BEGIN  
     --SET @Result = 'Selected Leave Cannot Club with Previous Leave Approved#False#'  
     SET @Result = 'Selected Leave Cannot Club With Previous Applied Leave#False#'  
     SELECt @Result as Result  
     RETURN   
    END  
   CREATE TABLE #LeaveBalance  
   (  
    Leave_Opening numeric(18,2),  
    Leave_Used numeric(18,2),  
    Leave_Credit numeric(18,2),  
    Leave_Closing numeric(18,2),  
    Leave_Code varchar(50),  
    Leave_Name varchar(50),  
    Leave_ID numeric(18,0),  
    Display_LeaveBalance int,  
    Actual_Leave_Closing numeric(18,2),  
    Leave_Type varchar(50)  
   )  
   SET @Date = (SELECT Convert(varchar(20),getdate(),111))  
   INSERT INTO #LeaveBalance EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID  
   --EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @CMP_ID = @Cmp_ID,@EMP_ID = @Emp_ID,@FOR_DATE = @Date,@Leave_Application = 0,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID  
   --SELECT * from #LeaveBalance  
     
   SELECT @Leave_Closing = Leave_Closing  FROM #LeaveBalance WHERE Leave_ID = @Leave_ID  
   select @Actual_Leave_Opening = Leave_Opening  FROM #LeaveBalance WHERE Leave_ID = @Leave_ID  
   select @Leave_Code = Leave_Code  FROM #LeaveBalance WHERE Leave_ID = @Leave_ID  
   --set @Leave_Closing=@Leave_Closing-@Actual_Leave_Closing  
     
   --SELECT @Leave_Closing,@Actual_Leave_Opening  
    
   CREATE TABLE #LeaveDetail  
   (  
    Leave_Min numeric(18,2),  
    Leave_Max numeric(18,2),  
    Leave_Notice_Period int,  
    Leave_Applicable int,  
    Leave_Nagative_Allow int,  
    Leave_Paid_Unpaid varchar(20),  
    Is_Document_required int,  
    Apply_Hourly int,  
    Can_Apply_Fraction int,  
    Default_Short_Name varchar(50),  
    Leave_Name varchar(50),  
    AllowNightHalt int,  
    Half_Paid int,  
    Leave_Negative_Max_Limit numeric(18,2),  
    Min_Leave_Not_Mandatory int,  
    Attachment_Days numeric(18,0)  
   )  
    
   INSERT INTO #LeaveDetail EXEC P0050_Leave_Details_Get @Cmp_Id = @Cmp_ID,@Emp_Id = @Emp_ID,@Leave_Id = @Leave_ID  
     
   -- Added  by deepal 26072021 Ticket id 18604  
   Declare @LeaveNoticePeriod as numeric = 0  
   Declare @LeaveCount as numeric = 0  
   select @LeaveNoticePeriod = Leave_Notice_Period  from #LeaveDetail  
   SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow, @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit  FROM #LeaveDetail  
   SELECT @LeaveCount = DATEDIFF(DAY,GETDATE(), @From_Date )  
   SELECT @SettingValue = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Auto LWP Leave'  
     
     
   --if (@LeaveNoticePeriod >= @LeaveCount and @LeaveNoticePeriod <> 0)  
   --Begin   
   -- SET @Result = 'Leave Notice Period is ' + cast(@LeaveNoticePeriod as varchar(10)) + ' Days#False#'  
   -- SELECT @Result as Result  
   -- RETURN  
   --end  
   -- END  by deepal 26072021 Ticket id 18604  
  
   SELECT @DOJ = Date_Of_Join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID  
    
   SET @JoiningDays = DATEDIFF(d,@DOJ,GETDATE())  
     
   SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow,  
   @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit,  
   @LeaveApplicable = Leave_Applicable   
   FROM #LeaveDetail  
     
   IF @LeaveApplicable > 0  
    BEGIN  
     IF @LeaveApplicable > @JoiningDays  
      BEGIN  
       SET @Result = 'You can not apply this Leave during Probation Period#False#'  
       SELECT @Result as Result  
       RETURN  
      END  
    END  
     
     
  BEGIN TRANSACTION LAA    
  BEGIN TRY  
     
    
   EXEC P_Check_Leave_Availability @Cmp_Id = @Cmp_Id,@Emp_Id = @Emp_ID,@From_Date = @From_Date,@To_Date = @To_Date,  
   @Half_Date = @Half_Leave_Date,@Leave_type = @Leave_Assign_As,@Leave_Application_Id = 0,@Raise_Error = 1,   
   @From_time = @InTime,@To_time = @OutTime,@Leave_Period = @Period  
     
   SELECT @SettingValue = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name = 'Auto LWP Leave'  
     
   --SELECT * from #LeaveDetail  
     
   DECLARE @LWPPeriod numeric(18,2)  
   DECLARE @LWPFromdate datetime  
   DECLARE @LWPTodate datetime  
   DECLARE @LWPAssignAs varchar(50) = 'Full Day'  
     
   DECLARE @LWPDays int   
   DECLARE @LWPHalf_Leave_Date datetime   
   SET @LWPHalf_Leave_Date =  @Half_Leave_Date  
   SET @LWPPeriod = 0.0  
     
   DECLARE @LWPHalfPeriod numeric(18,2)  
   DECLARE @LWPHalfFromdate datetime  
   DECLARE @LWPHalfTodate datetime  
   DECLARE @LWPHalfAssignAs varchar(50) = 'Full Day'  
     
   DECLARE @ID varchar(50)  
     
   SET @LWPHalfPeriod = 0.0  
     
   ----SELECt @Period,@Leave_Closing,@SettingValue,@Leave_Negative_Allow  
   --yogesh  
     -- FOR COMPOFF Leave  
    Declare @Compoff_Balance as numeric (18,2)  
    set @Compoff_Balance=@Actual_Leave_Opening-@Leave_Closing   
    --select @Actual_Leave_Opening,@Leave_Closing   
      
   -- if (@Period <= @Compoff_Balance and @Leave_Code='COMP') or (@Leave_Code != 'COMP')  
    --begin  
      
    
   IF @Period > @Leave_Closing  
    BEGIN  
  
      
      
      
     IF @Leave_Negative_Allow = 0 AND @SettingValue = 1  
      BEGIN  
        
       IF @Leave_Negative_Max_Limit - @Period - @Leave_Closing < 0  
        BEGIN  
         SET @LWPPeriod = @Period - @Leave_Closing  
          
         
         
         SET @Period = @Period - @LWPPeriod  
           
         SET @Days = @Period  
           
         --SELECT @Period,(@Period - @Days) ,@Leave_Assign_As  
           
         IF (@Period - @Days) = 0.5  
          BEGIN  
           SET @Leave_Assign_As = 'First Half'  
           SET @Half_Leave_Date = @From_Date  
           --SET @LWPAssignAs  = 'Second Half'  
          END  
         ELSE  
          BEGIN  
           SET @Leave_Assign_As = 'Full Day'  
           SET @Half_Leave_Date = '1900-01-01'  
          END  
         --SELECT @Period,(@Period - @Days) ,@Leave_Assign_As  
           
         IF @Period > 1  
          BEGIN  
           SET @To_Date =  DATEADD(d, @Period, @From_Date)  
          END  
         ELSE  
          BEGIN  
           SET @To_Date = @From_Date  
          END  
          --@Leave_Assign_As  
            
         SET @LWPDays = @LWPPeriod  
           
         SET @LWPFromdate = DATEADD(d, 1, @To_Date)  
           
         --SET @LWPPeriod = @LWPPeriod + (@LWPPeriod - @Days)  
           
         --SELECT (@LWPPeriod - @LWPDays)  
           
           
         SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPPeriod - @LWPDays)), @To_Date)  
           
         IF (@LWPPeriod - @LWPDays) = 0.50 AND @Leave_Assign_As = 'First Half'  
          BEGIN  
           SET @LWPAssignAs = 'Second Half'  
           SET @LWPFromdate = @To_Date   
           SET @LWPHalf_Leave_Date = @To_Date  
          END  
         ELSE IF (@LWPPeriod - @LWPDays) = 0 AND @Leave_Assign_As = 'First Half'  
          BEGIN  
           SET @LWPAssignAs = 'First Half'  
           SET @LWPFromdate = DATEADD(d, 1, @To_Date)  
           SET @LWPPeriod = @LWPPeriod - 0.50  
           SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPDays - @LWPPeriod)), @To_Date)  
           SET @LWPHalf_Leave_Date = @LWPTodate  
             
           SET @LWPHalfPeriod = 0.50  
           SET @LWPHalfFromdate = @To_Date  
           SET @LWPHalfTodate = @To_Date  
           SET @LWPHalfAssignAs = 'Second Half'  
          END  
         ELSE IF (@LWPPeriod - @LWPDays) = 0.50  
          BEGIN  
           SET @LWPAssignAs = 'First Half'  
          END  
         ELSE  
          BEGIN  
           SET @LWPAssignAs = 'Full Day'  
           SET @LWPHalf_Leave_Date = '1900-01-01'  
          END  
       --SELECT @LWPTodate   
        END  
      END  
     ELSE IF @Leave_Negative_Allow = 1 AND @SettingValue = 1 AND @Leave_Negative_Max_Limit <> 0  
      BEGIN  
        
       --SET @LWPPeriod = @Leave_Negative_Max_Limit - (@Period - @Leave_Closing)   
       IF @Leave_Negative_Max_Limit - @Period - @Leave_Closing < 0  
        BEGIN  
         SET @LWPPeriod = @Period - @Leave_Negative_Max_Limit - @Leave_Closing  
          
         
         SET @Period = @Period - @LWPPeriod  
           
         SET @Days = @Period  
           
         --SELECT @Period,(@Period - @Days) ,@Leave_Assign_As  
         --SELECT @Period,(@Period - @Days)  
         IF (@Period - @Days) = 0.5  
          BEGIN  
           SET @Leave_Assign_As = 'First Half'  
           SET @Half_Leave_Date = DATEADD(d,(@Period - (@Period - @Days)), @From_Date)  
           --SET @LWPAssignAs  = 'Second Half'  
          END  
         ELSE  
          BEGIN  
           SET @Leave_Assign_As = 'Full Day'  
           SET @Half_Leave_Date = '1900-01-01'  
          END  
         --SELECT @Period,(@Period - @Days) ,@Leave_Assign_As  
           
         IF @Period > 1  
          BEGIN  
           SET @To_Date =  DATEADD(d, @Period, @From_Date)  
          END  
         ELSE  
          BEGIN  
           SET @To_Date = @From_Date  
          END  
          --@Leave_Assign_As  
            
         SET @LWPDays = @LWPPeriod  
           
         SET @LWPFromdate = DATEADD(d, 1, @To_Date)  
           
         --SET @LWPPeriod = @LWPPeriod + (@LWPPeriod - @Days)  
           
         --SELECT (@LWPPeriod - @LWPDays)  
           
           
         SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPPeriod - @LWPDays)), @To_Date)  
           
         IF (@LWPPeriod - @LWPDays) = 0.50 AND @Leave_Assign_As = 'First Half'  
          BEGIN  
           SET @LWPAssignAs = 'Second Half'  
           SET @LWPFromdate = @To_Date   
           SET @LWPHalf_Leave_Date = @To_Date  
          END  
         ELSE IF (@LWPPeriod - @LWPDays) = 0 AND @Leave_Assign_As = 'First Half'  
          BEGIN  
           SET @LWPAssignAs = 'First Half'  
           SET @LWPFromdate = DATEADD(d, 1, @To_Date)  
           SET @LWPPeriod = @LWPPeriod - 0.50  
           SET @LWPTodate = DATEADD(d,(@LWPPeriod + (@LWPDays - @LWPPeriod)), @To_Date)  
           SET @LWPHalf_Leave_Date = @LWPTodate  
             
           SET @LWPHalfPeriod = 0.50  
           SET @LWPHalfFromdate = @To_Date  
           SET @LWPHalfTodate = @To_Date  
           SET @LWPHalfAssignAs = 'Second Half'  
          END  
         ELSE IF (@LWPPeriod - @LWPDays) = 0.50  
          BEGIN  
           SET @LWPAssignAs = 'First Half'  
          END  
         ELSE  
          BEGIN  
           SET @LWPAssignAs = 'Full Day'  
           SET @LWPHalf_Leave_Date = '1900-01-01'  
          END  
        END  
       --SELECT @LWPTodate   
         
      END  
    END  
    
   SET @ApplicatioDate = (select cast(getdate()as varchar(11)))         
      
   SET @S_Emp_ID = (select Emp_Superior from T0080_Emp_master WITH (NOLOCK) where Emp_ID = @Emp_ID)     
    
    
  
   EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,  
   @S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Comment,  
   @Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,  
   @is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0     
     
   SET @ID = @Leave_Application_ID  
  
   EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,  
   @Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @To_Date,@Leave_Period = @Period,@Leave_Assign_As = @Leave_Assign_As,  
   @Leave_Reason = @Comment,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @Half_Leave_Date,  
   @Leave_App_Docs = @Attachment,@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,  
   @strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0           
    
     
   SELECT @GradeID = ISNULL(Grd_ID,0) FROM  V0080_Employee_Master WHERE Emp_ID = @Emp_ID  
    
   SELECT @Leave_ID = Leave_ID   
   FROM V0040_LEAVE_DETAILS   
   WHERE (1=(CASE ISNULL(Leave_Status,0) WHEN 0 THEN (CASE WHEN ISNULL(InActive_Effective_Date,GETDATE())> GETDATE() THEN 1 ELSE 0 END) ELSE 1 END)) AND Grd_ID = @GradeID AND Cmp_ID = @Cmp_ID AND Leave_Name = 'LWP'  
     
   IF @LWPHalfPeriod <> 0.0  
    BEGIN  
     EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,  
     @S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Comment,  
     @Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,  
     @is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0  
       
     EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,  
     @Leave_ID = @Leave_ID,@From_Date = @LWPHalfFromdate,@To_Date = @LWPHalfTodate,@Leave_Period = @LWPHalfPeriod,@Leave_Assign_As = @LWPHalfAssignAs,  
     @Leave_Reason = @Comment,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @LWPHalfFromdate,  
     @Leave_App_Docs = @Attachment,@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,  
     @strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0       
       
     SET @ID = @ID +','+ CAST(@Leave_Application_ID AS varchar(10))  
    END  
     
   IF @LWPPeriod <> 0.0  
    BEGIN  
     EXEC P0100_LEAVE_APPLICATION @Leave_Application_ID = @Leave_Application_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,  
     @S_Emp_ID = @S_Emp_ID,@Application_Date = @ApplicatioDate,@Application_Code = 0,@Application_Status = 'P',@Application_Comments = @Comment,  
     @Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@is_backdated_application = @IsBackdate,  
     @is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0  
       
     EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,  
     @Leave_ID = @Leave_ID,@From_Date = @LWPFromdate,@To_Date = @LWPTodate,@Leave_Period = @LWPPeriod,@Leave_Assign_As = @LWPAssignAs,  
     @Leave_Reason = @Comment,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @LWPHalf_Leave_Date,  
     @Leave_App_Docs = @Attachment,@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,  
     @strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0       
       
     SET @ID = @ID +','+ CAST(@Leave_Application_ID AS varchar(10))   
    END  
     
    
  
  
  
   SET @Result = 'Leave Applied Successfully#True#'+ @ID  
   --end  
   -- ELSE  
    --begin  
  
    --SET @Result = 'Compoff balance is less than entered Leave period.#False#'  
      
   -- END  
  -- FOR COMPOFF Leave  
  
     
   DECLARE @DeviceID AS nvarchar(MAX)  
   SET @DeviceID = ''  
     
   SELECT @Result  
     
      
   SELECT CONVERT(varchar(11),Application_Date,103) AS 'Application_Date',Application_Code,Emp_Full_Name,  
   Desig_Name,Dept_Name,Leave_Name,  
   (CONVERT(varchar(11),From_Date ,103) + ' ' + DATENAME(weekday,From_Date))AS 'FromDate',  
   (CONVERT(varchar(11),To_Date,103) + ' ' + DATENAME(weekday,To_Date)) AS 'ToDate',  
   Leave_Period,Leave_Assign_As,  
   Leave_Reason,Leave_Status,Mobile_No,Leave_Application_ID  
   FROM V0110_LEAVE_APPLICATION_DETAIL WHERE Leave_Application_ID IN (@ID) AND Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID  
     
   EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @EMP_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Leave Application',@Flag = 2,  
   @Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 0--,@DeviceID = @DeviceID OUTPUT  
     
   --IF @DeviceID <> ''  
   -- BEGIN  
   --  SELECT LEFT(@DeviceID, LEN(@DeviceID) - 1) AS 'DeviceID'  
   -- END  
      
  COMMIT TRANSACTION LAA  
  END TRY  
  BEGIN CATCH  
   SET @Result = ERROR_MESSAGE()+'#False#'  
   SELECT @Result as Result 
   
   ROLLBACK TRANSACTION LAA  
   --ROLLBACK  
  END CATCH  
  
 END  
ELSE IF @Type = 'D'  --- For Leave Application Delete  
 BEGIN  
  BEGIN TRY  
   EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,  
   @Cmp_ID = @Cmp_ID,@Leave_ID = 0,@From_Date = @From_Date,@To_Date = @To_Date,@Leave_Period = 0,@Leave_Assign_As = '',  
   @Leave_Reason = '',@Row_ID = 0,@Login_ID = 0,@System_Date = @From_Date,@tran_type = 'D',@Half_Leave_Date = @Half_Leave_Date,  
   @Leave_App_Docs = '',@User_Id = 0,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,  
   @NightHalt = 0,@strLeaveCompOff_Dates = '',@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0   
     
   --EXEC P0110_Leave_Application_Detail @Leave_Application_ID = @Leave_Application_ID,@Emp_Id = @EMP_ID,@Cmp_ID = @Cmp_ID,  
   --@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @To_Date,@Leave_Period = @Period,@Leave_Assign_As = @Leave_Assign_As,  
   --@Leave_Reason = @Comment,@Row_ID = @RowID OUTPUT,@Login_ID = @Login_ID,@System_Date = @ApplicatioDate,@tran_type = 'I',@Half_Leave_Date = @Half_Leave_Date,  
   --@Leave_App_Docs = '',@User_Id = @Login_ID,@IP_Address = 'Mobile',@Leave_Out_Time = @InTime,@Leave_In_Time = @OutTime,@NightHalt = 0,  
   --@strLeaveCompOff_Dates = '',@Half_Payment = 0,@Warning_flag = 0,@Rules_Violate = 0          
           
     
   --exec P0110_Leave_Application_Detail @Leave_Application_ID=44,@EMP_ID=0,@Cmp_ID=1,@Leave_ID=0,  
   --@From_Date='2018-03-14 19:13:01.803',@To_Date='2018-03-14 19:13:01.803',@Leave_Period=0,@Leave_Assign_As='',@Leave_Reason='',@Row_ID=@p10 output,@Login_ID=6,@System_Date='2018-03-14 19:13:01.803',@tran_type='Delete',@Half_Leave_Date='1900-01-01 00:00:00',@Leave_App_Docs='',@User_Id='6',@IP_Address='::1',@Leave_Out_Time='',@Leave_In_Time='',@NightHalt=0,@strLeaveCompOff_Dates='',@Half_Payment=0,@Warning_Flag=0,@Rules_violate=0  
     
   SET @Result = 'Leave Application Deleted successfully#True#'+CAST(@Leave_Application_ID AS varchar(50))  
   SELECT @Result as Result   
  END TRY  
  BEGIN CATCH  
   SET @Result = ERROR_MESSAGE()+'#False#'  
   SELECT @Result as Result  
  END CATCH  
   
 END  
   
ELSE IF @Type = 'R'  --- For Leave Balance   
 BEGIN  
  CREATE TABLE #LeaveMonthlyBalance  
  (  
   Cmp_ID NUMERIC(18,0),  
   Emp_ID NUMERIC(18,0),  
   For_Date datetime,  
   Leave_Opening NUMERIC(5,2),  
   Leave_Credit NUMERIC(5,2),  
   Leave_Used NUMERIC(5,2),  
   Leave_Closing NUMERIC(5,2),  
   Leave_ID NUMERIC(18,0),  
   Leave_Type varchar(50),  
   Leave_Name varchar(50),  
   Emp_Full_Name varchar(50),  
   Emp_Code NUMERIC(18,0),  
   Alpha_Emp_Code varchar(50),  
   Emp_First_Name varchar(50),  
   Grd_Name varchar(50),  
   Branch_Address varchar(255),  
   Comp_Name varchar(100),  
   Branch_Name varchar(50),  
   Dept_Name varchar(50),  
   Desig_Name varchar(50),  
   Cmp_Name varchar(100),  
   Cmp_Address varchar(255),  
   P_From_Date datetime,  
   P_To_Date datetime,  
   Branch_Id numeric(18,0),  
   Type_Name varchar(50),  
   Desig_Dis_No int,  
   Vertical_Name varchar(50),  
   SubVertical_Name varchar(50),  
   SubBranch_Name varchar(50),  
   Leave_Code varchar(50),  
   Gender varchar(50)  
  )  
    
    
   
  
  EXEC SP_RPT_MONTHLY_LEAVE_BALANCE_GET @Cmp_ID = @Cmp_ID,@From_Date = @From_Date,  
  @To_Date = @To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_Id=0,@Desig_Id=0,  
  @Emp_ID = @Emp_ID,@Leave_ID = '',@Constraint = ''  
    
  
  SELECT LB.Cmp_ID,LB.Emp_ID,LB.For_Date,LB.Leave_Opening,LB.Leave_Credit,LB.Leave_Used,LB.Leave_Closing,  
  LB.Leave_ID,LB.Leave_Type,LB.Leave_Name,LB.Emp_Full_Name,LB.Emp_Code,LB.Alpha_Emp_Code,LB.Emp_First_Name,LB.Grd_Name,  
  LB.Comp_Name ,LB.Branch_Name,LB.Dept_Name,LB.Desig_Name,LB.Cmp_Name,LB.Cmp_Address,LB.P_From_Date,  
  LB.P_To_Date,LB.Branch_Id,LB.Type_Name,isNull(LB.Desig_Dis_No,0) as 'Desig_Dis_No',LB.Vertical_Name,LB.SubVertical_Name,LB.SubBranch_Name,  
  LB.Leave_Code,LB.Gender     
  FROM #LeaveMonthlyBalance LB  
  INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LB.Leave_ID = LM.Leave_ID  
  WHERE LM.Display_leave_balance = 1 AND LB.Leave_Closing <> 0.00  
  ORDER BY LB.Leave_Name  
    
  DROP TABLE #LeaveMonthlyBalance  
 END  
ELSE IF @Type = 'T'  --- For Shift Time  
 BEGIN  
  SELECT SM.Shift_ID,SM.Shift_Name,SM.Shift_St_Time,SM.Shift_End_Time,SM.Shift_Dur  
  FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)  
  INNER JOIN  
  (  
   SELECT * FROM dbo.F_Get_Curr_Shift(@Emp_ID,@From_Date)  
  ) CSM ON SM.Shift_ID = CSM.Shift_ID  
 END  