CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_GETCOUNT]  
 @Emp_ID numeric(18,0),  
 @Cmp_ID numeric(18,0)  
AS  
SET ANSI_WARNINGS ON;  
SET ARITHABORT ON;  
DECLARE @ShowCurrMonth_Count NUMERIC  
SET @ShowCurrMonth_Count = 0  
  
   
SELECT @ShowCurrMonth_Count = ISNULL(Setting_Value,0) FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Show Current Month Attendance Regularization Count On Home Page'  
  
  
--GETTING LEAVE APPROVAL COUNT  
EXEC SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1  
  
  
--INSERTING ATTENDANCE REGULARIZATION COUNT  
IF @ShowCurrMonth_Count = 1  
 BEGIN  
  EXEC SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0) and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) ',  1  
 END  
ELSE  
 BEGIN  
  EXEC SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0)',  1  
 END  
  
   
---- GET LEAVE CANCELLATION COUNT     
  
--Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')  
--    and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id )   
--    and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where is_approve = 0))  
  
--==========start comment on 23-nov-2020--by satish======     
--SELECT COUNT(VLA.ROW_ID) AS 'LeaveCancel'   
--FROM V0120_LEAVE_APPROVAL VLA WITH (NOLOCK)   
--INNER JOIN T0150_LEAVE_CANCELLATION TLC WITH (NOLOCK)  ON VLA.Leave_Approval_ID = TLC.Leave_Approval_ID  
--INNER JOIN T0090_EMP_REPORTING_DETAIL TER  WITH (NOLOCK) ON VLA.Emp_ID = TER.Emp_ID AND TER.R_Emp_ID = @Emp_ID  
--WHERE (APPROVAL_STATUS = 'A' OR APPROVAL_STATUS='R') AND TLC.Is_Approve = 0 --AND VLA.EMP_ID = @Emp_ID  
--and VLA.Cmp_ID=@Cmp_ID  
---======================end=================  
  
DECLARE @Request_Date datetime  
DECLARE @EmpIDS as varchar(MAX)  
  
SET @Request_Date = CAST(GETDATE() AS varchar(11))  
SELECT @EmpIDS = dbo.F_GET_DOWNLINE_EMPLOYEES_XML(@Emp_ID,@Request_Date)  
  
 IF @EmpIDS = ''  
  BEGIN  
   SET @EmpIDS = @Emp_ID  
  END  
  
SELECT  COUNT(VL.Tran_Id) AS 'LeaveCancel'  
FROM V0150_LEAVE_CANCELLATION_APPROVAL_MAIN VL  
INNER JOIN  
(  
 SELECT Data FROM dbo.Split(@EmpIDS,',')  
) E ON VL.Emp_ID = E.Data  
WHERE  IS_APPROVE = 0 AND S_Emp_ID = @Emp_ID  
  
  
--WHERE (APPROVAL_STATUS = 'A' OR APPROVAL_STATUS='R') AND VLA.EMP_ID IN (SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL WHERE R_EMP_ID = @EMP_ID )   
-- AND (LEAVE_APPROVAL_ID IN (SELECT DISTINCT LEAVE_APPROVAL_ID FROM T0150_LEAVE_CANCELLATION WHERE IS_APPROVE = 0))  
  
  
----Added for the Comp-Off Approval Records by satish on 03-Oct-2020  
--==========start comment on 23-nov-2020--by satish======  
--SELECT ISNULL(COUNT(Compoff_App_ID),0) AS 'CompOffApprovals'   
--From V0110_COMPOFF_APPLICATION_DETAIL COMP  
--  INNER JOIN (SELECT R1.EMP_ID, R_Emp_ID, R1.Effect_Date   
--     FROM T0090_EMP_REPORTING_DETAIL R1   
--      INNER JOIN (SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID  
--         FROM T0090_EMP_REPORTING_DETAIL R2  
--         GROUP BY Emp_ID  
--         ) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date  
--     ) R1 ON COMP.Emp_ID=R1.Emp_ID  
--Where Application_Status='P' AND R1.R_Emp_ID=@Emp_ID and COMP.Cmp_ID=@Cmp_ID  
---======================end=================  
  
SELECT ISNULL(COUNT(VC.Compoff_App_ID),0) AS 'CompOffApprovals'  
FROM  V0110_COMPOFF_APPLICATION_DETAIL VC  
 INNER JOIN  
  (  
  SELECT ERD.EMP_ID  
   FROM T0090_EMP_REPORTING_DETAIL ERD   
   INNER JOIN   
   (  
    SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID   
    FROM T0090_EMP_REPORTING_DETAIL ERD1   
    WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN   
    (  
     SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL   
     WHERE R_EMP_ID = @Emp_ID  
    ) GROUP BY EMP_ID   
   ) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE   
   WHERE ERD.R_EMP_ID = @Emp_ID   
  ) QRY ON VC.EMP_ID = QRY.EMP_ID  
  WHERE VC.APPLICATION_STATUS = 'P'  
  
  
--SELECT ISNULL(COUNT(VC.exit_id),0) AS 'ExitApproval'  
--FROM  V0200_EXIT_APPLICATION VC  
-- INNER JOIN  
--  ( SELECT ERD.EMP_ID FROM T0090_EMP_REPORTING_DETAIL ERD   
--   INNER JOIN  (  
--    SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID   
--    FROM T0090_EMP_REPORTING_DETAIL ERD1   
--    WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN   
--    (  
--     SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL   
--     WHERE R_EMP_ID = @Emp_ID  
--    )   GROUP BY EMP_ID   
--   ) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE WHERE ERD.R_EMP_ID = @Emp_ID ) QRY   
--   ON VC.EMP_ID = QRY.EMP_ID  
--  WHERE VC.status = 'P'  
  
--SELECT ISNULL(COUNT(VC.exit_id),0) AS 'ExitApproval'  
--FROM  V0200_EXIT_APPLICATION VC  
-- INNER JOIN  
--  ( SELECT ERD.EMP_ID FROM T0090_EMP_REPORTING_DETAIL ERD   
--   INNER JOIN  (  
--    SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID   
--    FROM T0090_EMP_REPORTING_DETAIL ERD1   
--    WHERE ERD1.EFFECT_DATE <= GETDATE() AND EMP_ID IN   
--    (  
--     SELECT EMP_ID FROM T0090_EMP_REPORTING_DETAIL   
--     WHERE Emp_ID = @Emp_ID  
--    )   GROUP BY EMP_ID   
--   ) TBL1 ON TBL1.EMP_ID = ERD.EMP_ID AND TBL1.EFFECT_DATE = ERD.EFFECT_DATE WHERE ERD.Emp_ID = @Emp_ID ) QRY   
--   ON VC.EMP_ID = QRY.EMP_ID  
--  WHERE VC.status = 'P'  
  
  
--exec SP_Mobile_HRMS_Exit_Approval @cmp_Id=@Cmp_ID,@emp_id=@Emp_ID,@status='H',@Type = 1  
  
 --select 0 as 'ExitApproval'  
  
     
----Added for the Ticket Approval Records by satish on 03-Oct-2020  
  
 Declare @IT_Manager Numeric(5,0)  
 Declare @IT_Manager_Email Varchar(50)  
   
 Declare @Acc_Manager Numeric(5,0)  
 Declare @Acc_Manager_Email Varchar(50)  
   
 Declare @HR_Manager Numeric(5,0)  
 Declare @HR_Manager_Email Varchar(50)  
   
 Declare @Travel_Manager Numeric(5,0)  
 Declare @Travel_Manager_Email Varchar(50)  
   
 Set @IT_Manager = 0  
 Set @IT_Manager_Email = ''  
   
 Set @Acc_Manager =0  
 Set @Acc_Manager_Email = ''  
   
 Set @HR_Manager = 0  
 Set @HR_Manager_Email = ''  
   
 Set @Travel_Manager = 0  
 Set @Travel_Manager_Email = ''  
   
 Select @IT_Manager = Isnull(TL.IS_IT,0),  
     @IT_Manager_Email = Isnull(TL.Email_ID_IT,''),  
     @Acc_Manager = Isnull(TL.Is_Accou,0),  
     @Acc_Manager_Email = Isnull(TL.Email_ID_Accou,''),  
     @HR_Manager = Isnull(TL.Is_HR,0),  
     @HR_Manager_Email = Isnull(TL.Email_ID,''),  
     @Travel_Manager = Isnull(TL.Travel_Help_Desk,0),  
     @Travel_Manager_Email = Isnull(TL.Email_ID_HelpDesk,'')  
 From T0011_LOGIN TL Where TL.Cmp_ID = @Cmp_ID and TL.Emp_ID = @Emp_ID  
  
 if @IT_Manager > 0  
  Begin  
    Select ISNULL(COUNT(1),0) as 'TicketApprovals'   
    From V0090_Ticket_Application  WITH(NOLOCK)  
     Where Cmp_ID = @Cmp_ID   
       AND Ticket_Dept_ID = 1   
       AND ISNULL(Is_Candidate,0) = 0  
       and Ticket_Status = 'Open'  
       and Sendto = @Emp_ID  
  
  End  
 Else if @HR_Manager > 0  
  Begin  
    Select ISNULL(COUNT(1),0) as 'TicketApprovals'   
    From V0090_Ticket_Application  WITH(NOLOCK)  
     Where Cmp_ID = @Cmp_ID   
       AND Ticket_Dept_ID = 2   
       AND ISNULL(Is_Candidate,0) = 0  
       and Ticket_Status = 'Open'  
          and Sendto = @Emp_ID  
  End  
 Else if @Acc_Manager > 0  
  Begin  
    Select ISNULL(COUNT(1),0) as 'TicketApprovals'   
    From V0090_Ticket_Application  WITH(NOLOCK)  
     Where Cmp_ID = @Cmp_ID   
       AND Ticket_Dept_ID = 3   
       AND ISNULL(Is_Candidate,0) = 0  
       and Ticket_Status = 'Open'  
  End  
 Else if @Travel_Manager > 0  
  Begin  
       Select ISNULL(COUNT(1),0) as 'TicketApprovals'   
    From V0090_Ticket_Application  WITH(NOLOCK)  
     Where Cmp_ID = @Cmp_ID   
       AND Ticket_Dept_ID = 4  
       AND ISNULL(Is_Candidate,0) = 0  
       and Ticket_Status = 'Open'  
          and Sendto = @Emp_ID  
  END  
 ELSE  
  BEGIN  
    Select 0 as 'TicketApprovals'   
  END  
  
-- Get The Count of the Claim Application done by Employee   
EXEC SP_Get_Claim_Application_Records  @Cmp_ID = @Cmp_ID, @Emp_ID = @Emp_ID  
   ,@Rpt_level=0,@Type=1,@Constrains=N'Claim_App_Status = ''P'' And Submit_Flag=0'  
  
--exec SP_Mobile_HRMS_WebService_Travel_Approval_List @Emp_Id=14565,@Cmp_Id=120,@StrType='P',@Rpt_level=0  
  
  
--GETTING travel APPROVAL COUNT  
  
  
exec SP_Mobile_HRMS_WebService_Travel_Approval_List @Emp_Id = @Emp_Id,@Cmp_Id = @Cmp_Id ,@StrType= 'p',@Rpt_level=0,@Type = 1  
  
--EXEC SP_Mobile_HRMS_WebService_Travel_Approval_List @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1
