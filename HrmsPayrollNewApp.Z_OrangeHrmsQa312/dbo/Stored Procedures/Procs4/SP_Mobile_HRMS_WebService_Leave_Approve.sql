CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Leave_Approve]  
 @Leave_Approval_ID NUMERIC(18,0),  
 @Leave_Application_ID NUMERIC(18,0),  
 @Leave_ID NUMERIC(18,0),  
 @Emp_ID NUMERIC(18,0),  
 @Cmp_ID NUMERIC(18,0),  
 @Approval_Date datetime,  
 @From_Date datetime,  
 @TO_Date datetime,  
 @Leave_Period decimal(18,2),  
 @Leave_AssignAs varchar(15),  
 @Leave_Reason VARCHAR(100),  
 @Half_Leave_Date DATETIME = NULL,  
 @Approval_Status char(1),  
 @Approval_Comments varchar(250),  
 -- @Manager_Comment varchar(250),  
 @Final_Approve int,  
 @Is_Fwd_Leave_Rej int,  
 @Rpt_Level int,  
 @SEmp_ID numeric(18,0),  
 @Intime datetime,  
 @Outtime datetime,  
 @Login_ID numeric(18,0),  
 @strLeaveCompOff_Dates varchar(MAX) = '',  
 @Type Char(1),  
 @Status Char(1)='',  
 @Result varchar(255) OUTPUT  
AS      
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
DECLARE @System_Date DATETIME  
DECLARE @RowID numeric(18,0)  
DECLARE @Tran_ID numeric(18,0)  
DECLARE @Flag int  
DECLARE @DeviceID  NVARCHAR(MAX)  
SET @DeviceID = ''  
  
IF @Type = 'I'  -- For Leave Approval Insert  
 BEGIN  
   
  IF @Half_Leave_Date = '' OR @Half_Leave_Date is null  
   BEGIN  
    SET @Half_Leave_Date = '1900-01-01 00:00:00'  
   END  
     
  SET @System_Date = (SELECT CAST(GETDATE()AS VARCHAR(11)))    
  SELECT @Cmp_ID = Cmp_ID FROM T0100_LEAVE_APPLICATION WITH (NOLOCK) WHERE Leave_Application_ID = @Leave_Application_ID  
    
 BEGIN TRY  
  BEGIN TRANSACTION LA  
    IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej=0 AND @Approval_Status = 'R')   
     BEGIN  
       
      EXEC P0120_LEAVE_APPROVAL @Leave_Approval_ID OUTPUT,@Leave_Application_ID = @Leave_Application_ID,  
      @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @SEmp_ID,@Approval_Date = @Approval_Date,  
      @Approval_Status = @Approval_Status,@Approval_Comments = @Approval_Comments,@Login_ID = @Login_ID,  
      @System_Date = @System_Date,@tran_type = 'I',@User_Id = @Login_ID,@IP_Address = 'Mobile',@Is_Backdated_App = 0  
      --SET @Leave_Approval_ID = (SELECT max(Leave_Approval_ID) FROM  T0120_LEAVE_APPROVAL)   
      --SELECT @Leave_Approval_ID  
      --return  
       
      EXEC P0130_LEAVE_APPROVAL_DETAIL @RowID OUTPUT,@Leave_Approval_ID = @Leave_Approval_ID,  
      @Cmp_ID = @Cmp_ID,@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @TO_Date,  
      @Leave_Period = @Leave_Period,@Leave_Assign_As = @Leave_AssignAs,@Leave_Reason = @Leave_Reason,  
      @Login_ID = @Login_ID,@System_Date = @Approval_Date,@Is_import = 0,@tran_type = 'I',  
      @M_Cancel_WO_HO = 0,@Half_Leave_Date = @Half_Leave_Date,@User_Id = @Login_ID,  
      @IP_Address = 'Mobile',@Leave_Out_Time = @Outtime,@Leave_In_Time = @Intime,@NightHalt = 0,  
      @strLeaveCompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0,@Warning_flag= 0,@Rules_Violate =0     
         
     END  
    -- Declare @leave_Appr_Id as integer= @Leave_Approval_ID  
  
      
    --   select  @Cmp_ID, @Leave_Application_ID,  
    -- @Emp_ID, @Leave_ID, @From_Date, @TO_Date, @Leave_Period,  
    -- @Leave_AssignAs, @Leave_Reason, 0, @Half_Leave_Date,  
    -- @SEmp_ID, @Approval_Date, @Approval_Status,  
    --@Approval_Comments, @Rpt_Level, 'I', 0, 0,  
    -- 0, 0, 0, @Outtime,  
    -- @Intime, @strLeaveCompOff_Dates, 0  



    EXEC P0115_Leave_Level_Approval @Leave_Approval_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Leave_Application_ID = @Leave_Application_ID,  
    @Emp_ID = @Emp_ID,@Leave_ID = @Leave_ID,@From_Date = @From_Date,@To_Date = @TO_Date,@Leave_Period = @Leave_Period,  
    @Leave_Assign_As = @Leave_AssignAs,@Leave_Reason = @Leave_Reason,@M_Cancel_WO_HO = 0,@Half_Leave_Date = @Half_Leave_Date,  
    @S_Emp_ID = @SEmp_ID,@Approval_Date = @Approval_Date,@Approval_Status = @Approval_Status,  
    @Approval_Comments = @Approval_Comments,@Rpt_Level = @Rpt_Level,@Tran_Type = 'I',@is_arrear = 0,@arrear_month = 0,  
    @arrear_year = 0,@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@Leave_Out_Time = @Outtime,  
    @Leave_In_Time = @Intime,@Leave_CompOff_Dates = @strLeaveCompOff_Dates,@Half_Payment = 0  
    
    Declare @leave_Appr_Id as integer= @Leave_Approval_ID  
  
  
    IF  @leave_Appr_Id <> 0  
     BEGIN  
      IF @Approval_Status = 'R'  
       BEGIN  
         
        SET @Result = 'Leave Application Rejected Successfully#True#'+CAST(@Leave_Approval_ID AS varchar(10))   
        --SELECT 'Leave Reject Done#True#'  
       END  
      ELSE  
       BEGIN  
         
        SET @Result = 'Leave Application Approved Successfully#True#'+CAST(@Leave_Approval_ID AS varchar(10))   
        --SELECT 'Leave Approval Done#True#'  
       END  
     END  
       
     SELECT @Result as Result -- commented by Yogseh on 27062023  
       
     IF @Final_Approve = 1 OR (@Is_Fwd_Leave_Rej = 0 AND @Approval_Status = 'R')   
      BEGIN  
  
       SELECT LA.Leave_Application_ID,MAX(LA.Rpt_Level) AS 'Rpt_Level',LA.Emp_ID,LA.Leave_ID,LM.Leave_Name,EM.Emp_Full_Name  
       FROM T0115_Leave_Level_Approval LA WITH (NOLOCK)  
       INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID  
       INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LA.Leave_ID = LM.Leave_ID  
       WHERE LA.Leave_Application_ID = @Leave_Application_ID   
       GROUP BY LA.Leave_Application_ID,LA.Emp_ID,LA.Leave_ID,LM.Leave_Name,EM.Emp_Full_Name  
         
       --SELECT * FROM V0120_LEAVE_APPROVAL WHERE Leave_Approval_ID = @Leave_Approval_ID  
       SET @Flag = 1  
      END  
     ELSE  
      BEGIN  
        
       SET @Flag = 2  
       --SELECT * FROM T0115_Leave_Level_Approval WHERE Leave_Application_ID = @Leave_Application_ID   
       SELECT LA.Leave_Application_ID,MAX(LA.Rpt_Level) AS 'Rpt_Level',LA.Emp_ID,LA.Leave_ID,LM.Leave_Name,EM.Emp_Full_Name  
       FROM T0115_Leave_Level_Approval LA WITH (NOLOCK)  
       INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID  
       INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LA.Leave_ID = LM.Leave_ID  
       WHERE LA.Leave_Application_ID = @Leave_Application_ID   
       GROUP BY LA.Leave_Application_ID,LA.Emp_ID,LA.Leave_ID,LM.Leave_Name,EM.Emp_Full_Name  
      END  
       
      
	   
     --    select Emp_Full_Name as Sup_Emp from T0080_EMP_MASTER   
     --where Emp_ID = @Emp_ID

     EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @EMP_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Leave Approval',@Flag = @Flag,  
     @Leave_ID = @Leave_ID,@Rpt_Level = @Rpt_Level,@Final_Approval = @Final_Approve--,@DeviceID = @DeviceID OUTPUT  
	 
     --    select Emp_Full_Name as Sup_Emp from T0080_EMP_MASTER   
     --where Emp_ID = @Emp_ID
     IF @DeviceID <> ''  
      BEGIN  
       SELECT LEFT(@DeviceID, LEN(@DeviceID) - 1) AS 'DeviceID'  
      END  
  
      
       
       
  COMMIT TRANSACTION LA  
      
 END TRY  
  BEGIN CATCH  
   SET @Result = ERROR_MESSAGE()+'#False#'  
   SELECT @Result   
   ROLLBACK TRANSACTION LA  
   --ROLLBACK   
  END CATCH  
  
    
 END  
ELSE IF @Type = 'E'   -- For Leave Application Details   
 BEGIN    
  Declare @LPeriod float  
  select distinct @LPeriod = LLA.Leave_Period from T0115_Leave_Level_Approval LLA WHERE LLA.Leave_Application_ID = @Leave_Application_ID  
  
  SELECT distinct(EM.Alpha_Emp_Code + ' ' + EM.Initial + ' ' + EM.Emp_First_Name + ' ' + ISNULL(EM.Emp_Last_Name,'')) AS 'EmployeeFullName',  
  (EM.Emp_First_Name+' '+ EM.Emp_Last_Name)as 'EmployeeName',LA.Emp_ID,LA.Cmp_ID,LA.S_Emp_ID,LA.Leave_Application_ID,  
  CONVERT(VARCHAR(20),LA.Application_Date,103) AS 'Application_Date',LA.Application_Code,LA.Application_Status,LA.Application_Comments,LAD.Leave_ID,LM.Leave_Name,LM.Leave_Code,  
  --CONVERT(VARCHAR(20),LAD.From_Date,103) AS 'FromDate',CONVERT(VARCHAR(20),LAD.To_Date,103) AS 'ToDate',  
  CASE WHEN CONVERT(VARCHAR(20),LLA.From_Date,103) != '' then CONVERT(VARCHAR(20),LLA.From_Date,103)  else CONVERT(VARCHAR(20),LAD.From_Date,103) END as 'FromDate',  
  CASE WHEN CONVERT(VARCHAR(20),LLA.To_Date ,103) != '' then CONVERT(VARCHAR(20),LLA.To_Date ,103) else CONVERT(VARCHAR(20),LAD.To_Date,103) END as 'ToDate',  
  Case when cast(@LPeriod as nvarchar(5)) != '' Then @LPeriod else LAD.Leave_Period END as Leave_Period,    
  --LAD.Leave_Period,  
  LAD.Leave_Assign_As,CONVERT(VARCHAR(20),LAD.Half_Leave_Date,103) AS 'Half_Leave_Date' ,LAD.Leave_Reason,LAD.NightHalt,  
  CONVERT(VARCHAR(5),LAD.leave_Out_time,108) AS 'leave_Out_time',CONVERT(VARCHAR(5),LAD.leave_In_time,108) AS 'leave_In_time',  
  (CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name',  
  '' AS 'Image_Path',LAD.Leave_CompOff_Dates  
  ,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type  
  FROM T0100_LEAVE_APPLICATION LA  WITH (NOLOCK)   
  INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID = LAD.Leave_Application_ID   
  left join T0115_Leave_Level_Approval LLA on LLA.Leave_Application_ID = la.Leave_Application_ID  
  INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_ID = EM.Emp_ID   
  INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID = LM.Leave_ID  
  WHERE LA.Leave_Application_ID = @Leave_Application_ID  
    
  SELECT CONVERT(VARCHAR(20),From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),To_Date,103) AS 'To_Date',Leave_Period,  
  Leave_Reason AS 'Comment', Application_Status,CONVERT(VARCHAR(20),System_Date,103) AS 'System_Date' , 'Application' As 'Rpt_Level'  
  FROM V0110_LEAVE_APPLICATION_DETAIL   
  WHERE Leave_Application_ID = @Leave_Application_ID   
    
  UNION   
    
  SELECT CONVERT(VARCHAR(20),From_Date,103) AS 'From_Date',CONVERT(VARCHAR(20),To_Date,103) AS 'To_Date',Leave_Period,  
  Approval_Comments AS 'Comment',Approval_Status, CONVERT(VARCHAR(20),System_Date,103) AS 'System_Date',  
  (CASE WHEN Rpt_Level = 1  THEN 'First' ELSE (CASE WHEN Rpt_Level = 2 THEN 'Second' ELSE ( CASE WHEN Rpt_Level = 3 THEN 'Third' ELSE (CASE WHEN Rpt_Level = 4 THEN 'Fourth' ELSE 'Fifth' END) END ) END) END ) AS 'Rpt_Level'  
    
  FROM T0115_Leave_Level_Approval WITH (NOLOCK)  
  WHERE Leave_Application_ID = @Leave_Application_ID   
  ORDER BY Rpt_Level  
  
  
  --EXEC SP_Get_Leave_Application_Records @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level = 0,@Constrains = '(Application_Status = ''P'' or Application_Status = ''F'')',@Type =0  
    
  SELECT @Emp_ID = LA.Emp_ID,@Cmp_ID = LA.Cmp_ID,@From_Date = LD.From_Date,@Leave_ID = LD.Leave_ID   
  FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  
  INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK) ON LA.Leave_Application_ID = LD.Leave_Application_ID  
  WHERE LA.Leave_Application_ID = @Leave_Application_ID  
  
  EXEC SP_LEAVE_CLOSING_AS_ON_DATE_ALL @Cmp_ID = @Cmp_ID,@For_Date = @From_Date,@Emp_Id = @Emp_ID,  
  @Leave_Application = @Leave_Application_ID,@Leave_Encash_App_ID = 0,@Leave_ID = @Leave_ID  
 END  
ELSE IF @Type = 'S'   -- For Leave Application Records  
 BEGIN  
 if @status=''  
 begin  
  
 EXEC SP_Get_Leave_Application_Records @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level = 0,@Constrains = '(Application_Status = ''P'' or Application_Status = ''F'')',@Type =0  
  
 end  
 END  
 else if @Type='D'  
 begin  
   
     declare curLeave cursor Fast_forward for                      
     select leave_approval_id from T0120_LEAVE_APPROVAL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID   
     open curLeave  
     fetch next from curLeave into @leave_approval_id  
     while @@fetch_status = 0        
     begin  
       
     exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@leave_approval_id output,@Leave_Application_ID=0,@Cmp_ID=0,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date = '',@Approval_Status='',@Approval_Comments='',@Login_ID=0,@System_Date = '',@tran_type='Delete'  
        
      fetch next from curLeave into @leave_approval_id  
     end                      
     close curLeave                      
     deallocate curLeave  
  
     Select 'Deleted '  
 end
