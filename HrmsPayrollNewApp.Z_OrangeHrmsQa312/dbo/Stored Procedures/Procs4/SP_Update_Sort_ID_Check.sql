

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Update_Sort_ID_Check]
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

DECLARE @Sort_ID_Check INT;
DECLARE @Sort_ID INT;
 
 --Admin Module---
/****Yearly Holiday****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_22' AND UNDER_FORM_ID=9021;
 
/****Company Consolidate Info****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_27' AND UNDER_FORM_ID=9021;
 
/****Active/InActive Users****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_23' AND UNDER_FORM_ID=9021;
 
/****Allowance/Reimbursement Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_26' AND UNDER_FORM_ID=9021;
 
/****Exit Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_24' AND UNDER_FORM_ID=9021;
 
/****Training Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Admin_25' AND UNDER_FORM_ID=9021;
 

/****Leave Master****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Master' AND UNDER_FORM_ID=6057;
 
/****Leave Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Detail' AND UNDER_FORM_ID=6057;
 
/****Leave Opening****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Opening' AND UNDER_FORM_ID=6057;
 
/****Leave Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Application' AND UNDER_FORM_ID=6057;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Approval' AND UNDER_FORM_ID=6057;
 
/****Leave Carry Forward****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Carry Forward' AND UNDER_FORM_ID=6057;
 
/****Leave Encash****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Encash' AND UNDER_FORM_ID=6057;
  
/****Comp Off****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Comp Off' AND UNDER_FORM_ID=6057;

/****Leave Cancellation****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Cancellation' AND UNDER_FORM_ID=6057;
 
/****Night Halt****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Night Halt' AND UNDER_FORM_ID=6057;
 
/****Gate Pass****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Gate Pass' AND UNDER_FORM_ID=6057;
 
/****Optional Holiday Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Optional Holiday Approval' AND UNDER_FORM_ID=6057;
 
/****Employee Transfer****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Transfer' AND UNDER_FORM_ID=6219;
 
/****Employee Company Transfer****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Company Transfer' AND UNDER_FORM_ID=6219;
 
/****Employee Bulk Company Transfer****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Company Transfer Multi' AND UNDER_FORM_ID=6219;
 
 /****Travel Application****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Applications' AND UNDER_FORM_ID=6151;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Approval' AND UNDER_FORM_ID=6151;

/****Travel Account - Desk****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Account - Desk' AND UNDER_FORM_ID=6151;
 
  
/****Travel Approval - Help Desk****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Approval - Help Desk' AND UNDER_FORM_ID=6151;
 

/****Travel Settlement Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Settlement Application' AND UNDER_FORM_ID=6151;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel Settlement Approval' AND UNDER_FORM_ID=6151;
 
 
 --Loan/Claim---
/****Loan Details****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Loan LIC Details' AND UNDER_FORM_ID=6070;
 
/****Claim Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Claim Details' AND UNDER_FORM_ID=6070;
 
/****Travel****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Travel' AND UNDER_FORM_ID=6070;
 
/****LTA Medical Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='LTA Medical Details' AND UNDER_FORM_ID=6070;
 
/****Reimbursement****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Reim/Claim' AND UNDER_FORM_ID=6070;

/****Asset****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Asset' AND UNDER_FORM_ID=6070;
 
/****Admin Change Request Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Admin Change Request Approval' AND UNDER_FORM_ID=6070;
 
/****Optional Allowance Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Allowance/Reimbursement Approval' AND UNDER_FORM_ID=6070;
 

 
 --ESS Module--

/****Attendance Regularization****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;
  
 

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;

 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 
 /****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;
 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;
 

 
/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;
 
/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;
 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;
 
 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;
 

  
/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;
 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 


/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;

 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;

 

/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;

 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;
 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;

 

/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;
 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;

 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;

 

/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;

 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;

 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;

 

/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261;
 
/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;
 
 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;
 
 

/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
/****Attendance Regularization****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_262' AND UNDER_FORM_ID=9261;
 
/****My Team Member Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_263' AND UNDER_FORM_ID=9261;
 
/****Timesheet Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_290' AND UNDER_FORM_ID=9261;
 
/****Leave Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_265' AND UNDER_FORM_ID=9261;
 
/****Leave Cancellation Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_266' AND UNDER_FORM_ID=9261;
 
/****In Time :****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_267' AND UNDER_FORM_ID=9261;
 
/****Attendance Summary****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_268' AND UNDER_FORM_ID=9261;
 
/****Employee History****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_269' AND UNDER_FORM_ID=9261;
 
/****Current Year Salary Detail****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_270' AND UNDER_FORM_ID=9261;
 
/****Holiday Calendar****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_271' AND UNDER_FORM_ID=9261;
 
/****Leave Balance****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_272' AND UNDER_FORM_ID=9261;
 
/****Probation Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_273' AND UNDER_FORM_ID=9261;

/****Trainee Over****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_300' AND UNDER_FORM_ID=9261;
 
/****Comp Off Application****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_274' AND UNDER_FORM_ID=9261;

/** PreComp Off Application   **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_343' AND UNDER_FORM_ID=9261; 

/****exit interview scheduled****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_275' AND UNDER_FORM_ID=9261;
 
/****Exit Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_276' AND UNDER_FORM_ID=9261;
 
/****Reimbursement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_277' AND UNDER_FORM_ID=9261;
 
/****Pending Document's List****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_278' AND UNDER_FORM_ID=9261;
 
/****View Graphical Report****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_279' AND UNDER_FORM_ID=9261;
 

 
/****Loan Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_280' AND UNDER_FORM_ID=9261;

/****About Me****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_285' AND UNDER_FORM_ID=9261;
 
/****Travel Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_286' AND UNDER_FORM_ID=9261;
 
/****Travel Settlement Approval****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_287' AND UNDER_FORM_ID=9261;
 
/****Claim Approvals****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_315' AND UNDER_FORM_ID=9261;
 
/****Warning Details****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_264' AND UNDER_FORM_ID=9261;
 
/****Whosoff****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_Ess_289' AND UNDER_FORM_ID=9261;

/** Change Request Approval **/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_342' AND UNDER_FORM_ID=9261;
 
 
/****Training Feedback****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_288' AND UNDER_FORM_ID=9261;
 
/****Fill Up The Survey Form****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_345' AND UNDER_FORM_ID=9261;
 
/****Employee Rewards Initiated****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_341' AND UNDER_FORM_ID=9261;
 
/****Training Questionnairre****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_297' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since For Month Joinees****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_298' AND UNDER_FORM_ID=9261;
 
/****OJT Pending since Last Year****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_299' AND UNDER_FORM_ID=9261;
 
 
/****Graph****/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='TD_Home_ESS_281' AND UNDER_FORM_ID=9261;
 
 
 /*My Report*/  --Added By Jaina 20-09-2016 Start
 /**Salary Slip My#*/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Salary Slip My#' AND UNDER_FORM_ID=7532;

/*Yearly Salary My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Yearly Salary My#' AND UNDER_FORM_ID=7532;

/*PF Statement My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='PF Statement My#' AND UNDER_FORM_ID=7532;

/*Tax Preparation My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Tax Preparation My#' AND UNDER_FORM_ID=7532;

/*Form-16(IT) My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Form-16(IT) My#' AND UNDER_FORM_ID=7532;

/*CTC letter (Annexure) My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='CTC letter (Annexure) My#' AND UNDER_FORM_ID=7532;

/*Income Tax Declaration My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Income Tax Declaration My#' AND UNDER_FORM_ID=7532;

/*Tax Consolidate Report My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Tax Consolidate Report My#' AND UNDER_FORM_ID=7532;

/*FORM 11 (PF) My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='FORM 11 (PF) My#' AND UNDER_FORM_ID=7532;

/*Employee Warning My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Warning My#' AND UNDER_FORM_ID=7532;

/*Register With Settlement My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Register With Settlement My#' AND UNDER_FORM_ID=7532;

/*Scheme Details My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Scheme Details My#' AND UNDER_FORM_ID=7532;

/*Asset Installment Statement My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Asset Installment Statement My#' AND UNDER_FORM_ID=7532;

/*Reimbursement Slip My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Reimbursement Slip My#' AND UNDER_FORM_ID=7532;

/*Shift Report My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Shift Report My#' AND UNDER_FORM_ID=7532;

/*Reimbursement Statement My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Reimbursement Statement My#' AND UNDER_FORM_ID=7532;

/*Payment Slip My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Payment Slip My#' AND UNDER_FORM_ID=7532;

/*Employee Daily Overtime My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Daily Overtime My' AND UNDER_FORM_ID=7532;

 --Added By Jaina 20-09-2016 End

--Added By Jaina 06-10-2016 Start
 /**Other Reports Member#*/
 /*Salary Slip Member#*/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Salary Slip Member#' AND UNDER_FORM_ID=7514;

/*Yearly Salary Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Yearly Salary Member#' AND UNDER_FORM_ID=7514;
 
/*PF Statement Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='PF Statement Member#' AND UNDER_FORM_ID=7514;

/*Tax Preparation Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Tax Preparation Member#' AND UNDER_FORM_ID=7514;

/*Form-16(IT) Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Form-16(IT) Member#' AND UNDER_FORM_ID=7514;

/*Income Tax Declaration Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Income Tax Declaration Member#' AND UNDER_FORM_ID=7514;

/*Employee Warning Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Warning Member#' AND UNDER_FORM_ID=7514;

/*Shift Report Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Shift Report Member#' AND UNDER_FORM_ID=7514;

/*Employee CTC Report Member#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Employee CTC Report Member#' AND UNDER_FORM_ID=7514;
--Added By Jaina 06-10-2016 End

--Added by Jaina 03-12-2016 Start (My Report)
--Leave Report--
/*Leave Approval My#*/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Approval My#' AND UNDER_FORM_ID=7525;

/*Leave Balance My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Balance My#' AND UNDER_FORM_ID=7525;

/*Yearly Leave Transaction My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Yearly Leave Transaction My#' AND UNDER_FORM_ID=7525;

/*GatePass InOut My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='GatePass InOut My#' AND UNDER_FORM_ID=7525;

/*Comp-Off Leave Adjustment Details My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Comp-Off Leave Adjustment Details My#' AND UNDER_FORM_ID=7525;

/*Comp-Off Avail Balance My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Comp-Off Avail Balance My#' AND UNDER_FORM_ID=7525;

/*Leave Card My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Card My#' AND UNDER_FORM_ID=7525;

/*Leave Encash Slip My#*/
SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Encash Slip My#' AND UNDER_FORM_ID=7525;

--Added by Jaina 03-12-2016 End (My Report)

--added By Jimit 24112017


SET @Sort_ID_Check = @Sort_ID_Check + 1;
SET @Sort_ID = @Sort_ID + 1;
UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=@Sort_ID_Check,Sort_Id=@Sort_ID WHERE FORM_NAME='Leave Application Report My#'
 AND UNDER_FORM_ID=7525;
--ended


END

