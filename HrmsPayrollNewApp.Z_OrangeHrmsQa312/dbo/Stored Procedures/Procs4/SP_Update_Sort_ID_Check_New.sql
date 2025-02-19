


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Update_Sort_ID_Check_New]
	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON



DECLARE @Sort_ID_Check INT;
DECLARE @Sort_ID INT;
 
 --Admin Module---
/****Yearly Holiday****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_22',@UNDER_FORM_ID=9021,@RESET_ID=1,@Module_Name='Admin'

/****Company Consolidate Info****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_27',@UNDER_FORM_ID=9021,@Module_Name='Admin'
 
/****Active/InActive Users****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_23',@UNDER_FORM_ID=9021,@Module_Name='Admin'
 
/****Allowance/Reimbursement Application****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_26',@UNDER_FORM_ID=9021,@Module_Name='Admin'

/****Exit Application****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_24',@UNDER_FORM_ID=9021,@Module_Name='Admin'
 
/****Training Application****/
exec SP_SET_MENU_ORDER @FORM_NAME='TD_Home_Admin_25',@UNDER_FORM_ID=9021,@Module_Name='Admin'

/****Leave Master****/
SET @Sort_ID_Check = 0;
SET @Sort_ID = 0;
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Master',@UNDER_FORM_ID=6057,@RESET_ID=1,@Module_Name='Leave'

/****Leave Detail****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Detail',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Opening****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Opening',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Application****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Application',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Approval****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Approval',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Carry Forward****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Carry Forward',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Encash****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Encash',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Comp Off****/
exec SP_SET_MENU_ORDER @FORM_NAME='Comp Off',@UNDER_FORM_ID=6057,@Module_Name='Leave'

/****Leave Cancellation****/
exec SP_SET_MENU_ORDER @FORM_NAME='Leave Cancellation',@UNDER_FORM_ID=6057,@Module_Name='Leave'
 
/****Night Halt****/
exec SP_SET_MENU_ORDER @FORM_NAME='Night Halt',@UNDER_FORM_ID=6057,@Module_Name='Leave'
 
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
 

END


