--exec SP_Mobile_HRMS_WebService_Email_Notification 413,'Change Request Application',0        
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Email_Notification]        
 @Tran_ID varchar(50),        
 @Tran_Type varchar(50),        
 @Emp_ID NUMERIC(18,0) = 0        
AS        
        
--DECLARE @Emp_ID Numeric(18,0)        
DECLARE @SEmp_ID Numeric(18,0)        
DECLARE @Cmp_ID int        
DECLARE @Leave_ID Numeric(18,0)        
DECLARE @FinalApprove INT        
DECLARE @Flag int        
DECLARE @Rpt_Level INT        
DECLARE @Application_ID INT        
        
        
IF @Tran_Type = 'Leave Application'        
 BEGIN        
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Leave_ID = Leave_ID        
  FROM V0110_LEAVE_APPLICATION_DETAIL        
  WHERE Leave_Application_ID = CAST(@Tran_ID AS NUMERIC)        
         
  SELECT LA.Emp_ID,LA.Leave_ID,LA.Cmp_ID ,LA.Desig_Name,LA.Dept_Name,LA.Emp_Full_Name,LA.Alpha_Emp_Code,CONVERT(varchar(11), LA.Application_Date,103) AS 'Application_Date',        
   (LA.Alpha_Emp_Code + ' - ' + LA.Emp_Full_Name) AS 'Emp_Name',        
   LA.Leave_Name,(CONVERT(varchar(11),LA.From_Date,103) + ' ' + DATENAME(W,LA.From_Date)) AS 'From_Date',        
   (CONVERT(varchar(11),LA.To_Date,103) + ' ' + DATENAME(W,LA.To_Date)) AS 'To_Date',        
   LA.Leave_Period,LA.Leave_Assign_As,LA.Application_Status,LA.Leave_Reason,LA.Emp_Superior,        
   (CASE WHEN LA.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LA.Half_Leave_Date,103) END) AS 'Half_Leave_Date',        
   (CASE WHEN LA.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LA.leave_In_time,108) END) AS 'Leave_In_Time',        
   (CASE WHEN LA.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LA.leave_Out_time,108) END) AS 'Leave_Out_Time',        
   (CASE WHEN ISNULL(EM.Image_Name,'') = '0.jpg' OR ISNULL(EM.Image_Name,'') = '' THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'EmpImage_Name',        
   CONVERT(varchar(11),EM.Date_Of_Join,103) AS 'Date_Of_Join',        
   CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM V0110_LEAVE_APPLICATION_DETAIL LA        
   INNER JOIN T0080_EMP_MASTER EM ON LA.Emp_ID = EM.Emp_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON LA.Cmp_ID = CM.Cmp_Id        
  WHERE Leave_Application_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = @Tran_Type        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 2,        
  @Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 0        
         
 END        
ELSE IF @Tran_Type = 'Leave Approval'        
 BEGIN        
  SELECT @SEmp_ID = S_Emp_ID ,@Cmp_ID = Cmp_ID,@Leave_ID = Leave_ID,@Rpt_Level = Rpt_Level,        
  @Emp_ID = Emp_ID,@Application_ID =Leave_Application_ID        
  FROM T0115_Leave_Level_Approval         
  WHERE Tran_ID = CAST(@Tran_ID AS NUMERIC)        
          
  IF EXISTS (SELECT 1 FROM T0120_LEAVE_APPROVAL WHERE Leave_Application_ID = @Application_ID)        
   BEGIN        
    SET @FinalApprove = 1        
    SET @Flag = 1        
   END        
  ELSE        
   BEGIN        
    SET @FinalApprove = 0        
    SET @Flag = 2        
   END        
  SELECT TOP 1 LA.Emp_ID,LA.Leave_ID,LA.Cmp_ID ,LA.Desig_Name,LA.Dept_Name,LA.Emp_Full_Name,LA.Alpha_Emp_Code,CONVERT(varchar(11), LA.Application_Date,103) AS 'Application_Date',        
   (LA.Alpha_Emp_Code + ' - ' + LA.Emp_Full_Name) AS 'Emp_Name',(TEM.Alpha_Emp_Code + ' - ' + TEM.Emp_Full_Name) AS 'SEmp_Name',        
   LA.Leave_Name,(CONVERT(varchar(11),LA.From_Date,103) + ' ' + DATENAME(W,LA.From_Date)) AS 'From_Date',        
   (CONVERT(varchar(11),LA.To_Date,103) + ' ' + DATENAME(W,LA.To_Date))AS 'To_Date',        
   LA.Leave_Period,LA.Leave_Assign_As,LA.Leave_Reason,LA.Emp_Superior, LLA.Leave_Application_ID,        
   (CASE WHEN LA.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LA.Half_Leave_Date,103) END) AS 'Half_Leave_Date',        
   (CASE WHEN LA.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LA.leave_In_time,108) END) AS 'Leave_In_Time',        
   (CASE WHEN LA.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LA.leave_Out_time,108) END) AS 'Leave_Out_Time',        
   (CASE WHEN ISNULL(EM.Image_Name,'') = '0.jpg' OR ISNULL(EM.Image_Name,'') = '' THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'EmpImage_Name',        
   CONVERT(varchar(11),EM.Date_Of_Join,103) AS 'Date_Of_Join',        
   CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name ,        
   LLA.Approval_Status,CONVERT(varchar(11),LLA.Approval_Date,103) AS 'Approval_Date',LLA.Approval_Comments,        
   LLA.Rpt_Level,@FinalApprove AS 'FinalApprove'        
  FROM V0110_LEAVE_APPLICATION_DETAIL LA        
   INNER JOIN T0080_EMP_MASTER EM ON LA.Emp_ID = EM.Emp_ID        
   INNER JOIN T0080_EMP_MASTER TEM ON LA.S_Emp_ID = TEM.Emp_ID        
   INNER JOIN T0115_Leave_Level_Approval LLA ON LA.Leave_Application_ID = LLA.Leave_Application_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON LLA.Cmp_ID = CM.Cmp_Id        
  WHERE LLA.Leave_Application_ID = @Application_ID        
  ORDER BY LLA.Rpt_Level DESC        
        
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Leave Application'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = @Flag,        
  @Leave_ID = @Leave_ID,@Rpt_Level = @Rpt_Level,@Final_Approval = @FinalApprove        
 END        
ELSE IF @Tran_Type = 'Attendance Regularization'        
 BEGIN        
         
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID         
  FROM T0150_EMP_INOUT_RECORD         
  WHERE IO_Tran_Id = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT TE.Emp_ID,TE.Cmp_ID, TE.IO_Tran_Id,In_Date_Time,Out_Date_Time,Chk_By_Superior,Is_Cancel_Late_In,Is_Cancel_Early_Out,         
   (CASE WHEN Is_Cancel_Late_In = 1 THEN 'Cancel' ELSE '' END) AS 'Cancel_Late_In',        
   (CASE WHEN Is_Cancel_Early_Out = 1 THEN 'Cancel' ELSE '' END) AS 'Cancel_Early_Out',        
   EM.Emp_Full_Name_new AS 'Emp_Name',EM.Dept_Name,EM.Desig_Name,EM.Emp_Full_Name_Superior,TE.Half_Full_day,        
   REPLACE(CONVERT(varchar(11), TE.For_Date,106),' ','-') AS 'For_Date',TE.App_Date,        
   (SM.Shift_St_Time + ' - ' + SM.Shift_End_Time) AS 'Shift_Time',TE.Reason,TE.Other_Reason,        
   CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.Image_file_Path,Cmp_Signature,EM.Image_Name AS 'EmpImage_Name'        
   ,Convert(char(5),In_Date_Time,108)+'-'+Convert(char(5),Out_Date_Time,108) as [In_Out] -- Changed by Deepal(30122021)        
  FROM T0150_EMP_INOUT_RECORD TE        
   INNER JOIN V0080_Employee_Master EM ON TE.Emp_ID = EM.Emp_ID        
   INNER JOIN T0040_SHIFT_MASTER SM ON EM.Shift_ID = SM.Shift_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON TE.Cmp_ID = CM.Cmp_Id        
  WHERE TE.IO_Tran_Id = CAST(@Tran_ID AS NUMERIC)         
          
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Attendance Regularization'        
         
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 2,        
  @Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0        
 END        
ELSE IF @Tran_Type = 'Attendance Regularization Approve'        
 BEGIN        
         
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID         
  FROM T0150_EMP_INOUT_RECORD         
  WHERE IO_Tran_Id = CAST(@Tran_ID AS NUMERIC)        
          
  SET @Rpt_Level = (SELECT top 1 Rpt_Level FROM T0115_AttendanceRegu_Level_Approval WHERE IO_Tran_ID = CAST(@Tran_ID AS NUMERIC) ORDER BY Rpt_Level DESC)        
    
  IF EXISTS (SELECT 1 FROM T0150_EMP_INOUT_RECORD WHERE IO_Tran_Id = CAST(@Tran_ID AS NUMERIC) AND Chk_By_Superior <> 0)        
   BEGIN        
    SET @FinalApprove = 1        
    SET @Flag = 1        
   END        
  ELSE        
   BEGIN        
    SET @FinalApprove = 0        
    SET @Flag = 2        
   END        
           
  SELECT top 1 TE.Emp_ID,TE.Cmp_ID, TE.IO_Tran_Id,In_Date_Time,Out_Date_Time,TA.Chk_By_Superior,TA.Is_Cancel_Late_In,TA.Is_Cancel_Early_Out,         
   (CASE WHEN ISNULL(TA.Is_Cancel_Late_In,TE.Is_Cancel_Late_In) = 1 THEN 'Cancel' ELSE '' END) AS 'Cancel_Late_In',        
   (CASE WHEN ISNULL(TA.Is_Cancel_Early_Out,TE.Is_Cancel_Early_Out) = 1 THEN 'Cancel' ELSE '' END) AS 'Cancel_Early_Out',        
   EM.Emp_Full_Name_new AS 'Emp_Name',EM.Dept_Name,EM.Desig_Name,EM.Emp_Full_Name_Superior,TE.Half_Full_day,        
   REPLACE(CONVERT(varchar(11), TE.For_Date,106),' ','-') AS 'For_Date',TE.App_Date,        
   (SM.Shift_St_Time + ' - ' + SM.Shift_End_Time) AS 'Shift_Time',TE.Reason,TE.Other_Reason,        
   CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.Image_file_Path,Cmp_Signature,EM.Image_Name AS 'EmpImage_Name',        
   @Rpt_Level AS 'Rpt_Level',@FinalApprove  AS 'FinalApprove',        
   (CASE WHEN ISNULL(TA.Chk_By_Superior,0) = 0 THEN 'P' ELSE CASE WHEN TA.Chk_By_Superior = 1 THEN 'A' ELSE 'R' END END) AS 'Approval_Status'        
   ,(SEM.Alpha_Emp_Code + '-' + SEM.Emp_Full_Name) as Scheme_Manager -- Added by Niraj (11012022)        
  FROM T0150_EMP_INOUT_RECORD TE        
   INNER JOIN V0080_Employee_Master EM ON TE.Emp_ID = EM.Emp_ID        
   INNER JOIN T0040_SHIFT_MASTER SM ON EM.Shift_ID = SM.Shift_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON TE.Cmp_ID = CM.Cmp_Id        
   INNER JOIN T0115_AttendanceRegu_Level_Approval TA ON TE.IO_Tran_Id = TA.IO_Tran_ID        
   LEFT OUTER JOIN T0080_EMP_MASTER SEM ON TA.S_Emp_Id = SEM.Emp_ID -- Added by Niraj (11012022)        
  WHERE TE.IO_Tran_Id = CAST(@Tran_ID AS NUMERIC)        
  order by TA.System_Date desc -- Added by Niraj (13012022)        
          
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  WHERE Cmp_ID = @Cmp_ID AND Email_Type = 'Attendance Regularization'        
         
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = @Flag,        
  @Leave_ID = 0,@Rpt_Level = @Rpt_Level,@Final_Approval = @FinalApprove        
 END        
ELSE IF @Tran_Type = 'Cancel Leave Application'        
 BEGIN        
  SELECT LC.Leave_Approval_ID,LC.Emp_ID,LC.Leave_ID,LC.Cmp_ID ,LC.Emp_Full_Name,LC.Alpha_Emp_Code,(LC.Alpha_Emp_Code + ' - ' + LC.Emp_Full_Name) AS 'Emp_Name',        
    LC.Leave_Name,CONVERT(varchar(11),LAD.From_Date,103) AS 'From_Date',CONVERT(varchar(11),LAD.To_Date,103) AS 'To_Date',        
    LAD.Leave_Period as 'No_of_Days',CONVERT(varchar(11),LC.For_date,103) AS 'For_date', CAST(LC.LEAVE_PERIOD AS VARCHAR(5)) + ' - ' + LC.Day_type AS 'Cancel_Leave_Period',        
    (CASE WHEN LAD.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LAD.Half_Leave_Date,103) END) AS 'Half_Leave_Date',        
    (CASE WHEN LAD.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_In_time,108) END) AS 'Leave_In_Time',        
    (CASE WHEN LAD.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_Out_time,108) END) AS 'Leave_Out_Time',        
    LC.Comment AS 'Cancel_Reason',LAD.Leave_Assign_As,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM V0150_LEAVE_CANCELLATION LC        
   INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LAD.Leave_Approval_ID = LC.Leave_Approval_id        
   INNER JOIN T0080_EMP_MASTER EM ON LC.Emp_ID = EM.Emp_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON LC.Cmp_ID = CM.Cmp_Id        
  --WHERE LC.Is_Approve = 0 AND LC.Leave_Approval_id in (select data from dbo.split(@Tran_ID,','))         
  WHERE LC.Is_Approve = 0 AND LC.Tran_ID in (select data from dbo.split(@Tran_ID,','))         
          
  SELECT TOP 1 @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Leave_ID = Leave_ID        
  FROM V0150_LEAVE_CANCELLATION        
  --WHERE Leave_Approval_id in (select data from dbo.split(@Tran_ID,','))         
  WHERE Is_Approve = 0 AND Tran_ID in (select data from dbo.split(@Tran_ID,','))         
        
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  WHERE Cmp_ID = @Cmp_ID AND Email_Type = 'Leave Cancellation'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 2,        
  @Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 0        
 END        
ELSE IF @Tran_Type = 'Cancel Leave Approval'        
 BEGIN        
  SELECT LC.Leave_Approval_ID,LC.Emp_ID,LC.Leave_ID,LC.Cmp_ID ,LC.Emp_Full_Name,LC.Alpha_Emp_Code,(LC.Alpha_Emp_Code + ' - ' + LC.Emp_Full_Name) AS 'Emp_Name',        
    LC.Leave_Name,CONVERT(varchar(11),LAD.From_Date,103) AS 'From_Date',CONVERT(varchar(11),LAD.To_Date,103) AS 'To_Date',        
    LAD.Leave_Period as 'No_of_Days',CONVERT(varchar(11),LC.For_date,103) AS 'For_date', CAST(LC.LEAVE_PERIOD AS VARCHAR(5)) + ' - ' + LC.Day_type AS 'Cancel_Leave_Period',        
    (CASE WHEN LAD.Half_Leave_Date = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(11),LAD.Half_Leave_Date,103) END) AS 'Half_Leave_Date',        
    (CASE WHEN LAD.leave_In_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_In_time,108) END) AS 'Leave_In_Time',        
    (CASE WHEN LAD.leave_Out_time = '1900-01-01 00:00:00.000' THEN '' ELSE CONVERT(varchar(5),LAD.leave_Out_time,108) END) AS 'Leave_Out_Time',        
    LC.Comment + ';<br /> ( Managers Comments:- ' +  LC.MComment + ' )' AS 'Cancel_Reason',LAD.Leave_Assign_As,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM V0150_LEAVE_CANCELLATION LC        
   INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LAD.Leave_Approval_ID = LC.Leave_Approval_id        
   INNER JOIN T0080_EMP_MASTER EM ON LC.Emp_ID = EM.Emp_ID        
   INNER JOIN T0010_COMPANY_MASTER CM ON LC.Cmp_ID = CM.Cmp_Id        
  --WHERE LC.Is_Approve = 1 AND LC.Leave_Approval_id in (select data from dbo.split(@Tran_ID,','))         
  WHERE LC.Is_Approve = 1 AND LC.Tran_ID in (select data from dbo.split(@Tran_ID,','))         
          
  SELECT TOP 1 @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Leave_ID = Leave_ID        
  FROM V0150_LEAVE_CANCELLATION        
  --WHERE Leave_Approval_id in (select data from dbo.split(@Tran_ID,','))         
  WHERE Is_Approve = 1 AND Tran_ID in (select data from dbo.split(@Tran_ID,','))         
        
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  WHERE Cmp_ID = @Cmp_ID AND Email_Type = 'Leave Cancellation'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 2,        
  @Leave_ID = @Leave_ID,@Rpt_Level = 0,@Final_Approval = 1        
 END        
ELSE IF @Tran_Type = 'Ticket Application'        
 BEGIN        
  Declare @Email_type varchar(300)        
        
  Declare @send_to int        
        
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Flag = Ticket_Dept_ID        
  FROM V0090_Ticket_Application         
  WHERE Ticket_App_ID = @Tran_ID        
          
  SELECT  Ticket_App_ID, (Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'EmpFullName',Ticket_Type,Ticket_Dept_Name,Ticket_Status,        
  (CASE WHEN Ticket_Priority = 'High' THEN '<B><span style=color:#e41a1a;>High</spam></B>' ELSE CASE WHEN Ticket_Priority = 'Medium' THEN '<B><span style=color:#efea37;>Medium</spam></B>' ELSE '<B><span style=color:#2fa013;>Low</spam></B>' END END ) AS 'T
  
    
      
icket_Priority',        
  Ticket_Gen_Date,Ticket_Status,Ticket_Description,VT.Emp_ID,VT.Cmp_ID,        
  CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.Image_file_Path,Cmp_Signature        
  FROM V0090_Ticket_Application VT        
  INNER JOIN T0010_COMPANY_MASTER CM ON VT.Cmp_ID = CM.Cmp_Id        
  WHERE Ticket_App_ID = @Tran_ID        
        
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  WHERE Cmp_ID = @Cmp_ID AND Email_Type = 'Ticket Open'        
        
  select @send_to = SendTo from T0090_Ticket_Application where Ticket_App_ID = @Tran_ID         
          
  EXEC SP_Get_Email_ToCC_Ticket @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Ticket Open',@Flag = @Flag,@send_to=@send_to        
        
    --select @Emp_ID,@Cmp_ID,@Flag,@Tran_ID        
 END        
ELSE IF @Tran_Type = 'Ticket Approval'        
 BEGIN        
 -- commented by prapti 23082022 -- wrong parameter 'Ticket_Apr_ID'        
  --SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Flag = Ticket_Dept_ID         
  --FROM V0090_Ticket_Application         
  --WHERE Ticket_Apr_ID = @Tran_ID         
        
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Flag = Ticket_Dept_ID         
  FROM V0090_Ticket_Application         
  WHERE Ticket_App_ID = @Tran_ID        
          
        
  SELECT  VT.Ticket_App_ID,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'EmpFullName',Ticket_Type,Ticket_Dept_Name,        
  (CASE WHEN Ticket_Priority = 'High' THEN '<B><span style=color:#e41a1a;>High</spam></B>' ELSE CASE WHEN Ticket_Priority = 'Medium' THEN '<B><span style=color:#efea37;>Medium</spam></B>' ELSE '<B><span style=color:#2fa013;>Low</spam></B>' END END ) AS 'T
  
    
      
icket_Priority',        
  Ticket_Gen_Date,Ticket_Description,VT.Emp_ID,VT.Cmp_ID,        
  (CASE WHEN Ticket_Status = 'On Hold' THEN '<B><span style=color:#efea37;>On Hold</spam></B>' ELSE '<B><span style=color:#2fa013;>Closed</spam></B>' END) AS 'Ticket_Status',        
  CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City,CM.Image_file_Path,Cmp_Signature,VT.appliedByEmail,ISNULL(TE.Email_ID,'') AS 'Email_ID',        
  (CASE WHEN Ticket_Status = 'On Hold' THEN 'Ticket On Hold' ELSE 'Ticket Closed' END) AS 'MailSubject',VT.On_Hold_Reason        
  FROM V0090_Ticket_Application VT        
  INNER JOIN T0010_COMPANY_MASTER CM ON VT.Cmp_ID = CM.Cmp_Id        
  LEFT JOIN T0095_Ticket_Escalation TE ON VT.Ticket_App_ID = TE.Ticket_App_ID        
  WHERE VT.Ticket_App_ID  = @Tran_ID        
          
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  WHERE Cmp_ID = @Cmp_ID AND Email_Type = 'Ticket Close'        
          
        
  EXEC SP_Get_Email_ToCC_Ticket @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Ticket Close',@Flag = @Flag        
        
   --select @Emp_ID as emp,@Cmp_ID as cmp,@Flag as flag        
         
 END        
ELSE IF @Tran_Type = 'Travel Application'        
 BEGIN        
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID        
  FROM T0100_TRAVEL_APPLICATION        
  WHERE Travel_Application_ID = CAST(@Tran_ID AS NUMERIC)        
         
  SELECT VTA.Travel_Application_ID,CONVERT(VARCHAR(11),VTA.Application_Date,103) AS 'Application_Date',        
  VTA.Application_Code,VTA.Emp_ID,VTA.Cmp_ID,(EM.Alpha_Emp_Code + ' - '+VTA.Emp_Full_Name) AS 'EmpName',         
  VTA.S_Emp_ID,VTA.Supervisor,VTA.Instruct_Emp_ID,VTA.Instruct_Emp_Name,VTA.Place_Of_Visit,        
  CONVERT(VARCHAR(11), VTA.From_Date,103) AS 'From_Date',VTA.Period,CONVERT(VARCHAR(11),VTA.To_Date,103) AS 'To_Date',        
  VTA.Remarks,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM V0110_TRAVEL_APPLICATION_DETAIL VTA        
  INNER JOIN T0080_EMP_MASTER EM ON VTA.Emp_ID = EM.Emp_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON VTA.Cmp_ID = CM.Cmp_Id        
  WHERE VTA.Travel_Application_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT Email_Signature FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = @Tran_Type        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 0,        
  @Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0        
         
 END        
ELSE IF @Tran_Type = 'Travel Approval'        
 BEGIN        
  SELECT @SEmp_ID = S_Emp_ID ,@Cmp_ID = Cmp_ID,@Rpt_Level = Rpt_Level,        
  @Emp_ID = Emp_ID,@Application_ID = Travel_Application_ID        
  FROM T0115_TRAVEL_LEVEL_APPROVAL         
  WHERE Tran_ID = CAST(@Tran_ID AS NUMERIC)        
          
  IF EXISTS (SELECT 1 FROM T0120_TRAVEL_APPROVAL WHERE Travel_Application_ID = @Application_ID)        
   BEGIN        
    SET @FinalApprove = 1        
    SET @Flag = 1        
   END        
  ELSE        
   BEGIN        
    SET @FinalApprove = 0        
    SET @Flag = 2        
   END        
          
  SELECT TLA.Travel_Application_ID,CONVERT(varchar(11),TA.Application_Date,103) AS 'Application_Date' ,(EM.Alpha_Emp_Code + ' - '+ EM.Emp_Full_Name) AS 'EmpName',CONVERT(varchar(11),TLA.Approval_Date,103) AS 'Approval_Date',        
  TLA.Rpt_Level,(CASE WHEN TLA.Approval_Status = 'A' THEN 'Approved' ELSE 'Rejected' END) AS 'Approval_Status',        
  TAD.Place_Of_Visit,CONVERT(varchar(11), TAD.From_Date,103) AS 'From_Date',TAD.Period ,CONVERT(varchar(11),TAD.To_Date,103) AS 'To_Date',        
  ISNULL(TAD.Leave_ID,0) AS 'Leave_ID',LM.Leave_Name,@FinalApprove AS 'FinalApproval',ISNULL(TAD.Loc_ID,0) AS 'Loc_ID',        
  TLM.Loc_name,TLA.Cmp_ID,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM T0115_TRAVEL_LEVEL_APPROVAL TLA        
  INNER JOIN T0100_TRAVEL_APPLICATION TA ON TLA.Travel_Application_ID = TA.Travel_Application_ID        
  INNER JOIN T0115_TRAVEL_APPROVAL_DETAIL_LEVEL TAD ON TLA.Tran_Id = TAD.Tran_ID        
  INNER JOIN T0080_EMP_MASTER EM ON TLA.Emp_ID = EM.Emp_ID        
  LEFT JOIN T0040_LEAVE_MASTER LM ON TAD.Leave_ID = LM.Leave_ID        
  LEFT JOIN T0001_LOCATION_MASTER TLM ON TAD.Loc_ID = TLM.Loc_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON TLA.Cmp_ID = CM.Cmp_Id        
  WHERE TAD.Tran_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT TLA.Tran_ID,TAO.Travel_Mode_ID,TM.Travel_Mode_Name,TAO.For_date,TAO.Amount,ISNULL(TA.Chk_International,0) AS 'Chk_International',        
  (CASE WHEN TAO.Self_Pay = 1 THEN 'Yes' ELSE 'No' END) AS 'Self_Pay',ISNULL(TAO.Curr_ID,0) AS 'Curr_ID',CM.Curr_Name,CM.Curr_Symbol        
  FROM T0115_TRAVEL_LEVEL_APPROVAL TLA        
  INNER JOIN T0100_TRAVEL_APPLICATION TA ON TLA.Travel_Application_ID = TA.Travel_Application_ID        
  LEFT JOIN T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL TAO ON TLA.Tran_Id = TAO.Tran_ID        
  LEFT JOIN T0030_TRAVEL_MODE_MASTER TM ON TAO.Travel_Mode_ID = TM.Travel_Mode_ID        
  LEFT JOIN T0040_CURRENCY_MASTER CM ON TAO.Curr_ID = CM.Curr_ID        
  WHERE TLA.Tran_ID = CAST(@Tran_ID AS NUMERIC)        
        
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Travel Application'        
          
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Travel Application',@Flag = @Flag,        
  @Leave_ID = 0,@Rpt_Level = @Rpt_Level,@Final_Approval = @FinalApprove        
 END        
ELSE IF @Tran_Type = 'Compoff Application'        
 BEGIN        
         
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID         
  FROM V0110_COMPOFF_APPLICATION_DETAIL        
  WHERE Compoff_App_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT VC.Emp_ID,VC.Cmp_ID,CONVERT(VARCHAR(11),VC.Extra_Work_Date,103) AS 'Extra_Work_Date',        
  VC.Extra_Work_Hours,VC.Extra_Work_Reason,(VC.Alpha_Emp_Code + ' - ' + VC.Emp_Full_Name) AS 'EmpName',        
  'Pending' AS 'Application_Status',CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM V0110_COMPOFF_APPLICATION_DETAIL VC        
  INNER JOIN T0010_COMPANY_MASTER CM ON VC.Cmp_ID = CM.Cmp_Id        
  WHERE Compoff_App_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'CompOff Application'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Comp-Off Application',@Flag = 0,        
  @Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0        
 END        
ELSE IF @Tran_Type = 'Compoff Approval'        
 BEGIN        
         
  SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID         
  FROM T0120_CompOff_Approval        
  WHERE  CompOff_Appr_ID = CAST(@Tran_ID AS NUMERIC)        
          
  SELECT VC.Emp_ID,VC.Cmp_ID,CONVERT(VARCHAR(11),VC.Extra_Work_Date,103) AS 'Extra_Work_Date',        
  VC.Extra_Work_Hours,VC.Sanctioned_Hours,VC.Extra_Work_Reason,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) AS 'EmpName',        
  (CASE WHEN VC.Approve_Status= 'A' THEN 'Approved' ELSE 'Rejected' END) AS 'Approve_Status',        
  CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM T0120_CompOff_Approval VC        
  INNER JOIN V0080_Employee_Master EM ON VC.Emp_ID = EM.Emp_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON VC.Cmp_ID = CM.Cmp_Id        
  WHERE VC.CompOff_Appr_ID = CAST(@Tran_ID AS NUMERIC)        
          
          
  --SELECT Approve_Status,Sanctioned_Hours, * FROM T0120_CompOff_Approval        
          
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'CompOff Approval'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Comp-Off Approval',@Flag = 1,        
  @Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0        
 END        
ELSE IF @Tran_Type = 'Survey Form Filled By Employee'        
 BEGIN        
  SELECT @Cmp_ID = Cmp_ID         
  FROM T0080_EMP_MASTER        
  WHERE EMP_ID = @EMP_ID AND EMP_LEFT = 'N'        
          
  SELECT SM.Cmp_ID,SM.Survey_Title,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) AS 'EmpName',        
  CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM T0050_SurveyMaster SM        
  INNER JOIN V0080_Employee_Master EM ON EM.Emp_ID = @EMP_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON SM.Cmp_ID = CM.Cmp_Id        
  WHERE SM.survey_id = CAST(@Tran_ID AS NUMERIC)        
         
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Survey Form Filled By Employee'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Survey Form Filled By Employee',@Flag = 1        
 END        
ELSE IF @Tran_Type = 'Claim Application'         
 BEGIN         
         
  SELECT @CMP_ID = CMP_ID ,@EMP_ID = EMP_ID         
  FROM T0100_CLAIM_APPLICATION WHERE CLAIM_APP_ID = @TRAN_ID         
        
  --SELECT EM.Emp_Full_Name,ca.Transaction_Date, CA.Cmp_ID, Rtrim(Ltrim(CM.Claim_Name)) as [Claim Type],cast(Claim_App_Date as date) as [From Date]        
  --,Claim_App_Amount as Amount,CD.Claim_Description as [Purpose]        
  --,case when CA.Claim_App_Status = 'A' then 'Approve' else 'Pending' End As [Status]         
  --FROM T0100_CLAIM_APPLICATION CA inner join         
  --T0110_CLAIM_APPLICATION_DETAIL CD on CA.Claim_App_ID = CD.Claim_App_ID        
  --Left join T0040_CLAIM_MASTER CM on CM.Claim_ID = CA.Claim_ID        
  --Left  join T0080_EMP_MASTER EM on CA.Emp_ID = Em.Emp_ID        
  --Where isnull(Transaction_Date,'')  <> '' and Ca.Claim_App_Status = 'P' and cd.Claim_App_ID = CAST(@Tran_ID AS NUMERIC)        
          
        
  SELECT EM.Emp_Full_Name,ca.Claim_App_Date as Transaction_Date, CA.Cmp_ID, Rtrim(Ltrim(CM.Claim_Name)) as [Claim Type],cast(CD.For_Date as date) as [From Date]        
  ,cd.Claim_Amount as Amount,CD.Claim_Description as [Purpose]        
  ,case when CA.Claim_App_Status = 'A' then 'Approve' else 'Pending' End As [Status]        
  --,CA.Claim_App_Status As [Status]        
  FROM T0100_CLAIM_APPLICATION CA inner join         
  T0110_CLAIM_APPLICATION_DETAIL CD on CA.Claim_App_ID = CD.Claim_App_ID        
  Left join T0040_CLAIM_MASTER CM on CM.Claim_ID = CD.Claim_ID        
  Left  join T0080_EMP_MASTER EM on CA.Emp_ID = Em.Emp_ID        
  Where isnull(Transaction_Date,'')  <> '' and Ca.Claim_App_Status = 'P' and cd.Claim_App_ID = CAST(@Tran_ID AS NUMERIC)        
  --Where cd.Claim_App_ID = CAST(@Tran_ID AS NUMERIC)        
             
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting WITH(NOLOCK)        
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Claim Application'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Claim Application',@Flag = 1,        
  @Leave_ID = 0 ,@Rpt_Level = 0 ,@Final_Approval = 0        
          
          
 END        
ELSE IF @Tran_Type = 'Claim Approval'        
 BEGIN         
  --select * from T0115_CLAIM_LEVEL_APPROVAL order by 1 desc        
  --select * from T0115_CLAIM_LEVEL_APPROVAL_DETAIL order by 1 desc        
  If exists(SELECT 1 FROM T0115_CLAIM_LEVEL_APPROVAL WHERE Tran_ID = @TRAN_ID)        
  BEGIN        
   print 'Level Approval'        
   SELECT @EMP_ID = Emp_ID         
   FROM T0115_CLAIM_LEVEL_APPROVAL WHERE Tran_ID = @TRAN_ID         
        
   SELECT @CMP_ID = CMP_ID         
   FROM T0080_EMP_MASTER WHERE Emp_ID = @EMP_ID        
        
   DECLARE @rpt INT        
   SELECT DISTINCT TOP 1 @rpt = Rpt_Level          
   FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL         
   WHERE Claim_Apr_ID = CAST(@Tran_ID AS NUMERIC) ORDER BY Rpt_Level DESC        
        
        
   SELECT distinct   EM.Emp_Full_Name,CLA.Claim_App_Date as Approval_Date--,ca.Approval_Date        
   , Rtrim(Ltrim(CM.Claim_Name)) as [Claim Type],cast(Claim_Apr_Date as date) as [From Date]        
   ,Claim_Apr_Amnt AS Amount,CD.Purpose as [Purpose]        
   --,CASE WHEN CA.Claim_Apr_Status = 'A' then 'Approved' else 'Rejected' End As [Status] --,*        
   ,CASE WHEN CD.Claim_Status = 'A' then 'Approved' else 'Rejected' End As [Status] --,*        
   ,case when cd.Rpt_Level = 1 then 'First Level Completed'        
      when cd.Rpt_Level = 2 then 'Second Level Completed'         
      when cd.Rpt_Level = 3 then 'Third Level Completed'         
      when cd.Rpt_Level = 4 then 'Fourth Level Completed'         
      when cd.Rpt_Level = 5 then 'Five Level Completed'         
      Else 'Completed' END as Rpt_Level         
   FROM         
   T0115_CLAIM_LEVEL_APPROVAL CA inner join         
   T0115_CLAIM_LEVEL_APPROVAL_DETAIL CD on CA.Claim_App_ID = CD.Claim_App_ID        
   Left join T0040_CLAIM_MASTER CM on CM.Claim_ID = CD.Claim_ID        
   Left  join T0080_EMP_MASTER EM on CA.Emp_ID = Em.Emp_ID        
   Left Join T0100_CLAIM_APPLICATION CLA on CA.Claim_App_ID = CLA.Claim_App_ID        
   WHERE cd.Claim_Apr_ID = CAST(@Tran_ID AS NUMERIC) AND CD.Rpt_Level = @rpt        
   order by  1 desc        
        
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Claim Application'        
        
   --print @Emp_ID        
   --print @Cmp_ID        
   --print @rpt        
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Claim Approval',@Flag = 1         
   ,@Leave_ID = 0 ,@Rpt_Level = @rpt ,@Final_Approval = 0        
  END        
  ELSE        
  BEGIN        
   print 'Final Approval'        
   --DECLARE @rpt1 INT        
   --SELECT DISTINCT TOP 1 @rpt = Rpt_Level          
   --FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL         
   --WHERE Claim_Apr_ID = CAST(@Tran_ID AS NUMERIC) ORDER BY Rpt_Level DESC        
           
   SELECT @CMP_ID = CMP_ID ,@EMP_ID = Emp_ID         
   FROM T0120_CLAIM_APPROVAL WHERE Claim_Apr_ID = @TRAN_ID         
        
   SELECT distinct EM.Emp_Full_Name, CLA.Claim_App_Date as Approval_Date --ca.Claim_Apr_Date as Approval_Date        
   ,  Rtrim(Ltrim(CM.Claim_Name)) as [Claim Type],cast(CD.Claim_Apr_Date as date) as [From Date]        
   ,CD.Claim_Apr_Amount AS Amount,CD.Purpose as [Purpose]        
   ,CASE WHEN CD.Claim_Status = 'A' then 'Approved' else 'Rejected' End As [Status] --,*        
   ,'Completed' as Rpt_Level        
   FROM T0120_CLAIM_APPROVAL CA inner join         
   T0130_CLAIM_APPROVAL_DETAIL CD on CA.Claim_App_ID = CD.Claim_App_ID        
   Left join T0040_CLAIM_MASTER CM on CM.Claim_ID = CD.Claim_ID        
   Left  join T0080_EMP_MASTER EM on CA.Emp_ID = Em.Emp_ID        
   Left Join T0100_CLAIM_APPLICATION CLA on CA.Claim_App_ID = CLA.Claim_App_ID        
   WHERE cd.Claim_Apr_ID = CAST(@Tran_ID AS NUMERIC) --AND cd.rpt = @rpt        
           
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Claim Application'        
           
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Claim Approval',@Flag = 1        
   --,@Leave_ID = 0 ,@Rpt_Level = @rpt ,@Final_Approval = 0        
         
  END        
         
 END        
ELSE IF @Tran_Type='Exit Approval'        
BEGIN        
          
  IF EXISTS(SELECT 1 FROM T0300_Emp_Exit_Approval_Level WHERE exit_id = @TRAN_ID )        
  BEGIN        
           
   -------------------------        
   print 'level approval'        
           
   declare @Branch_ID Numeric(18,0)        
   declare @Exit_ID Numeric(18,0)        
        
   SELECT @EMP_ID = Emp_ID, @Exit_ID = Exit_id         
   FROM T0300_Emp_Exit_Approval_Level WHERE Exit_id = @TRAN_ID     
        
   SELECT @CMP_ID = CMP_ID ,@Branch_ID = Branch_Id        
   FROM T0080_EMP_MASTER WHERE Emp_ID = @EMP_ID        
        
   DECLARE @rptl INT        
        
   SELECT DISTINCT TOP 1 @rptl = Rpt_Level          
   FROM T0300_Emp_Exit_Approval_Level         
   WHERE Tran_Id = CAST(@Tran_ID AS NUMERIC)         
         AND Final_Approval = 0        
   ORDER BY Rpt_Level DESC        
        
            SELECT distinct EP.exit_id,cast(EP.resignation_date as date) as resignation_date,cast(EP.last_date as date) as last_date,        
       EM.Emp_Full_Name,EM.Dept_Name,EM.Desig_Name,          
          CM.Cmp_Address,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,        
       CM.Image_file_Path,CM.Cmp_Address,CM.Cmp_City,        
       CASE WHEN EP.[status] = 'H' then 'Hold'         
            WHEN EP.[status] = 'LR' then 'Reject*'         
      WHEN EP.[status] = 'A' then 'Approved'        
      WHEN EP.[status] = 'P' then 'Pending'        
      WHEN EP.[status] = 'F' then 'Auto Forward'        
       else 'Rejected' End As [Status],         
     CASE WHEN LA.Rpt_Level = 1 then 'First Level Completed'        
      when LA.Rpt_Level = 2 then 'Second Level Completed'         
when LA.Rpt_Level = 3 then 'Third Level Completed'         
      when LA.Rpt_Level = 4 then 'Fourth Level Completed'         
      when LA.Rpt_Level = 5 then 'Five Level Completed'         
       Else 'Completed' END as Rpt_Level          
   FROM T0300_Emp_Exit_Approval_Level LA WITH(NOLOCK)        
   INNER JOIN  T0200_Emp_ExitApplication EP WITH(NOLOCK) ON  EP.exit_id = LA.Exit_id        
   LEFT JOIN T0040_Reason_Master RM WITH(NOLOCK) ON RM.Res_Id = EP.reason        
   LEFT JOIN T0010_COMPANY_MASTER CM WITH(NOLOCK) ON EP.cmp_id = CM.Cmp_Id        
   LEFT JOIN  V0080_Employee_master EM ON  EP.emp_id = EM.Emp_ID         
   Where LA.Tran_Id = CAST(@Tran_ID AS NUMERIC) AND LA.Rpt_Level = @rptl        
   AND RM.[Type]='Exit' and RM.Isactive=1        
   AND EP.emp_id = @EMP_ID AND EP.cmp_id = @CMP_ID        
   AND EP.exit_id = @Exit_ID        
   order by  1 desc        
           
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Exit Approval'        
        
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Exit Approval',@Flag = 1         
   ,@Leave_ID = 0 ,@Rpt_Level = @rptl ,@Final_Approval = 0        
            
  END        
  ELSE        
  BEGIN        
    print 'Final Approval'        
        
   SELECT @CMP_ID = CMP_ID ,@EMP_ID = Emp_ID         
   FROM T0300_Emp_Exit_Approval_Level WHERE Tran_Id = @TRAN_ID        
           
   --add approval data for the exit applicaiton.         
        
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Exit Approval'        
        
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Exit Approval',@Flag = 1         
   ,@Leave_ID = 0 ,@Rpt_Level = @rptl ,@Final_Approval = 0        
        
  END        
END        
ELSE IF @Tran_Type='Exit Application'        
BEGIN        
        
  SELECT @CMP_ID = EA.CMP_ID ,@EMP_ID = EA.EMP_ID         
  FROM T0200_Emp_ExitApplication EA WITH(NOLOCK)        
  WHERE  EA.exit_id = @Tran_ID        
        
  SELECT  EA.cmp_id,EA.exit_id,cast(EA.resignation_date as date) as resignation_date,cast(EA.last_date as date) as last_date,        
       EM.Emp_Full_Name,EM.Dept_Name,EM.Desig_Name,        
    CM.Cmp_Address,CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,        
       CM.Image_file_Path,CM.Cmp_City,RM.Reason_Name,EA.comments,        
       CASE WHEN EA.[status] = 'H' then 'Hold'         
            WHEN EA.[status] = 'LR' then 'Reject*'         
      WHEN EA.[status] = 'A' then 'Approved'        
      WHEN EA.[status] = 'P' then 'Pending'        
      WHEN EA.[status] = 'F' then 'Auto Forward'        
       else 'Rejected' End As [Status]        
  FROM T0200_Emp_ExitApplication EA WITH(NOLOCK)        
  LEFT JOIN V0080_Employee_master EM ON EA.emp_id = EM.Emp_ID         
  LEFT JOIN T0010_COMPANY_MASTER CM WITH(NOLOCK) ON EA.cmp_id = CM.Cmp_Id       
  LEFT JOIN T0040_Reason_Master RM WITH(NOLOCK) ON  EA.reason = RM.Res_Id        
  WHERE   EA.emp_id = @EMP_ID        
      AND EA.cmp_id = @CMP_ID        
   AND EA.exit_id = @Tran_ID        
        
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting WITH(NOLOCK)        
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Exit Application'        
        
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Exit Application',@Flag = 1         
      ,@Leave_ID = 0 ,@Rpt_Level = @rptl ,@Final_Approval = 0        
END        
        
ELSE IF @Tran_Type='Change Request Application'        
BEGIN        
  Declare @RequestTypeID as numeric(18,0) = 0        
        
  SELECT @CMP_ID = EA.CMP_ID ,@EMP_ID = EA.EMP_ID ,@RequestTypeID = Request_Type_id        
  FROM T0090_Change_Request_Application EA WITH(NOLOCK)        
  WHERE  EA.Request_id = @Tran_ID        
        
  If @RequestTypeID = 8        
  BEGIN        
   SELECT DISTINCT        
   isnull(Dependant_Name,'') as Dependant_Name,isnull(Dependant_Gender,'') as Dependant_Gender        
   ,isnull(convert(varchar,Dependant_DOB,107),'') as Dependant_DOB        
   ,isnull(Dependant_Age,0) as Dependant_Age,isnull(Dependant_Relationship,'') as Dependant_Relationship        
   ,isnull(Dependant_Is_Resident,0) as Dependant_Is_Resident,isnull(Dependant_Is_Dependant,0) as Dependant_Is_Dependant        
   ,isnull(Dep_OccupationID,0) as Dep_OccupationID,isnull(Dep_Std_Specialization,'') as Dep_Std_Specialization        
   ,isnull(Dep_HobbyID,0) as Dep_HobbyID,isnull(Dep_HobbyName,'') as Dep_HobbyName,isnull(Dep_DepCompanyName,'') as Dep_DepCompanyName        
   ,isnull(Dep_CmpCity,'') as Dep_CmpCity,isnull(Dep_Standard_ID,0) as Dep_Standard_ID,isnull(Dep_Shcool_College,'') as Dep_Shcool_College,         
   isnull(Dep_SchCity,'') as Dep_SchCity,isnull(Dep_ExtraActivity,'') as Dep_ExtraActivity,isnull(Occupation_Name,'') as Occupation_Name        
   ,Em.Emp_Full_Name,CRM.Request_type,convert(varchar, EA.Request_Date, 103) as Request_Date,Request_type_id,Ea.Cmp_id,EA.Emp_id,        
   Case When Request_status = 'P' then 'Pending' when Request_status = 'A' then 'Approve' else 'Reject' end as Request_Status        
   ,isnull(S.StandardName,'') as StandardName,isnull(Dep_Shcool_College,'') as Dep_Shcool_College,isnull(Dep_SchCity,'') as Dep_SchCity ,isnull(Dep_ExtraActivity,'') as Dep_ExtraActivity        
   --*        
   from T0090_Change_Request_Application EA         
   inner join T0080_EMP_MASTER EM on Ea.Emp_ID = EM.Emp_ID        
   inner join T0040_Change_Request_Master CRM on EA.Request_Type_id = CRM.Request_id        
   left join T0040_Dep_Standard_Master s on EA.Dep_Standard_ID = s.S_ID        
   left join T0040_Occupation_Master O on EA.Dep_OccupationID = O.O_Id        
   WHERE   EA.emp_id = @EMP_ID        
       AND EA.cmp_id = @CMP_ID        
    AND EA.Request_id = @Tran_ID        
    and EA.Request_Type_id = @RequestTypeID        
           
        
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Change Request Application'        
        
        
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Change Request Application',@Flag = 1         
       ,@Leave_ID = @Tran_ID ,@Rpt_Level = @rptl ,@Final_Approval = 0        
        
   select Cmp_Name,Cmp_Email,Cmp_Signature,Image_file_Path,Cmp_Address,Cmp_City from T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID        
  END        
  else if  @RequestTypeID = 23        
  BEGIN        
        
   SELECT DISTINCT        
   isnull(Curr_Emp_Fav_Sport_id,'') as Curr_Emp_Fav_Sport_id ,isnull(Curr_Emp_Fav_Sport_Name,'') as Curr_Emp_Fav_Sport_Name,isnull(Curr_Emp_Hobby_id,'') as Curr_Emp_Hobby_id        
   ,isnull(Curr_Emp_Hobby_Name,'') as Curr_Emp_Hobby_Name,isnull(Curr_Emp_Fav_Food,'') as Curr_Emp_Fav_Food        
   ,isnull(Curr_Emp_Fav_Restro,'') as Curr_Emp_Fav_Restro,isnull(Curr_Emp_Fav_Trv_Destination,'') as Curr_Emp_Fav_Trv_Destination,isnull(Curr_Emp_Fav_Festival,'') as Curr_Emp_Fav_Festival        
   ,isnull(Curr_Emp_Fav_SportPerson,'') as Curr_Emp_Fav_SportPerson,isnull(Curr_Emp_Fav_Singer,'') as Curr_Emp_Fav_Singer,        
   isnull(EA.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id,isnull(EA.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name,isnull(EA.Emp_Hobby_id,'') as Emp_Hobby_id,isnull(EA.Emp_Hobby_Name,'') as Emp_Hobby_Name        
   ,isnull(EA.Emp_Fav_Food,'') as Emp_Fav_Food,isnull(EA.Emp_Fav_Restro,'') as Emp_Fav_Restro,isnull(EA.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination,isnull(EA.Emp_Fav_Festival,'') as Emp_Fav_Festival        
   ,isnull(EA.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson,isnull(EA.Emp_Fav_Singer,'') as Emp_Fav_Singer        
   ,Em.Emp_Full_Name,CRM.Request_type,EA.Request_Date,Request_type_id,Ea.Cmp_id,EA.Emp_id,        
   Case When Request_status = 'P' then 'Pending' when Request_status = 'A' then 'Approve' else 'Reject' end as Request_Status        
   from T0090_Change_Request_Application EA         
   inner join T0080_EMP_MASTER EM on Ea.Emp_ID = EM.Emp_ID        
   inner join T0040_Change_Request_Master CRM on EA.Request_Type_id = CRM.Request_id        
   left join T0040_Dep_Standard_Master s on EA.Dep_Standard_ID = s.S_ID        
   left join T0040_Occupation_Master O on EA.Dep_OccupationID = O.O_Id        
   WHERE   EA.emp_id = @EMP_ID        
   AND EA.cmp_id = @CMP_ID        
   AND EA.Request_id = @Tran_ID        
   and EA.Request_Type_id = @RequestTypeID        
           
        
   SELECT Email_Signature         
   FROM T0010_Email_Format_Setting WITH(NOLOCK)        
   Where Cmp_ID = @Cmp_ID AND Email_Type = 'Change Request Application'        
        
        
   EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Change Request Application',@Flag = 1         
       ,@Leave_ID = @Tran_ID ,@Rpt_Level = @rptl ,@Final_Approval = 0        
        
   SELECT Cmp_Name,Cmp_Email,Cmp_Signature,Image_file_Path,Cmp_Address,Cmp_City from T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID        
  END        
END        
        
-- Added by Divyaraj Kiri on 27/07/2023        
ELSE IF @Tran_Type = 'Template Application'        
 BEGIN        
  SELECT @Cmp_ID = Cmp_ID         
  FROM T0080_EMP_MASTER        
  WHERE EMP_ID = @EMP_ID AND EMP_LEFT = 'N'        
          
  SELECT distinct TM.Cmp_ID,TM.Template_Title,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) AS 'EmpName',        
  CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM T0040_Template_Master TM        
  INNER JOIN T0100_Employee_Template_Response ETR on ETR.T_Id = TM.T_ID        
  INNER JOIN V0080_Employee_Master EM ON EM.Emp_ID = @EMP_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON TM.Cmp_ID = CM.Cmp_Id        
  WHERE TM.T_ID = CAST(@Tran_ID AS NUMERIC)        
         
  SELECT Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = 'Template Application'        
          
  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Template Application',@Flag = 1        
 END        
 ELSE      
 BEGIN        
  SELECT @Cmp_ID = Cmp_ID         
  FROM T0080_EMP_MASTER        
  WHERE EMP_ID = @EMP_ID AND EMP_LEFT = 'N'        
          
  SELECT distinct TM.Cmp_ID,TM.Template_Title,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) AS 'EmpName',        
  CM.Cmp_Name,CM.Cmp_Email,CM.Cmp_Signature,CM.Image_file_Path,CM.Image_name        
  FROM T0040_Template_Master TM        
  INNER JOIN T0100_Employee_Template_Response ETR on ETR.T_Id = TM.T_ID        
  INNER JOIN V0080_Employee_Master EM ON EM.Emp_ID = @EMP_ID        
  INNER JOIN T0010_COMPANY_MASTER CM ON TM.Cmp_ID = CM.Cmp_Id        
  WHERE TM.T_ID = CAST(@Tran_ID AS NUMERIC)        
      
 --Added By tejas  at 25/12/2023      
  SELECT       
  Email_Signature         
  FROM T0010_Email_Format_Setting         
  Where Cmp_ID = @Cmp_ID AND Email_Type = @Tran_Type        
      
  SELECT ETR.T_Id, ETR.F_Id,CONCAT('#',REPLACE(TF.Field_Name,' ',''),'#')Field_Name,TF.Field_Type,ETR.Answer,ETR.Response_Flag      
  FROM T0040_Template_Master TM    
  LEFT JOIN T0050_Template_Field_Master TF ON TF.T_ID = TM.T_ID  
  LEFT JOIN T0010_COMPANY_MASTER CM ON TM.Cmp_ID = CM.Cmp_Id  
  LEFT JOIN T0100_Employee_Template_Response ETR on ETR.F_Id = TF.F_ID        
  WHERE TM.T_ID =@Tran_ID  and TM.Is_Active=1 and TF.Is_Required=1 and TF.Field_Type <> 'File Upload' and Field_Type <> 'Title' 
  and ETR.Response_Flag= (  select MAX(Response_Flag) from T0100_Employee_Template_Response where Cmp_Id=TM.Cmp_ID and T_Id=@Tran_ID)  
  ORDER BY TF.Sorting_No asc
  --///////////////// End By Tejas

  EXEC SP_Get_Email_ToCC @Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID,@Module_Name = @Tran_Type,@Flag = 1       
  --///////////////////// Add BY tejas ////////////////////////  
  select TR.Answer from T0050_Template_Field_Master TM   
  LEFT JOIN T0100_Employee_Template_Response TR on TR.F_Id = TM.F_ID   
  where TM.T_ID=@Tran_ID and TM.Field_Type = 'File Upload'   
  and TR.Response_Flag=( select MAX(Response_Flag) from T0100_Employee_Template_Response where Cmp_Id=@Cmp_ID and T_Id=@Tran_ID)  
 END        
 --//////////////////// Ended BY Tejas //////////////////////////////
-- Ended by Divyaraj Kiri on 27/07/2023
