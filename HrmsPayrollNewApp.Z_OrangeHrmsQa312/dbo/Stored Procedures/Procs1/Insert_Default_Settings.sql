


CREATE PROCEDURE [dbo].[Insert_Default_Settings]
	@Cmp_ID		numeric
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		DECLARE @Login_ID as INT
		/*	
			DIFFERENT PORTIONS ARE ADDED ON THE BASIS OF GROUPS BY RAMIZ ON 30/03/2017.
			WE HAVE ALSO INCLUDED "BEGIN" & "END" FOR EVERY GROUP JUST TO CREATE A REGION
			
			KINDLY ADD YOUR RELATED SETTING IN THAT GROUP SO THAT IT CAN EASILY BE MANAGED
		*/

		/*************************************** ADMIN SETTINGS STARTS HERE *********************************/
		/*INVALID ADMIN SETTINGS TO BE DELETED*/
		--add by chetan/nimeshbhai 140417
		DELETE FROM T0040_SETTING WHERE Setting_Name = 'Present Compulsory Extra Days Deduction (Holiday Master)' AND Cmp_ID=@CMP_ID --It has space between "Deduction (Holiday Master)" words which does not exist.
		DELETE FROM T0040_SETTING WHERE Setting_Name = 'Add initial in emploe full name' AND  Cmp_ID=@CMP_ID
		DELETE FROM T0040_SETTING WHERE setting_name = 'Enable Project in Travel' AND cmp_id = @cmp_ID
		DELETE FROM T0040_SETTING WHERE setting_name = 'Display Leave Detail by Calendar Year' AND cmp_id = @cmp_ID
		/*END OF INVALID ADMIN SETTINGS TO BE DELETED*/

		BEGIN	--THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION
				
			DECLARE @SETTING_ID_MAX INT;
			DECLARE @SETTING_NAME VARCHAR(512)
			DECLARE @ALIAS VARCHAR(512)
			DECLARE @TOOLTIP VARCHAR(MAX)
			DECLARE @GROUP_NAME VARCHAR(128)
			DECLARE @VTYPE VARCHAR(8)
			DECLARE @VREF VARCHAR(MAX)


		    --Added by ronakk with direction of Chintan and sandip 03052023
				/******* Loan Decution as per cut off  date  *******/
			SET @SETTING_NAME = 'Allow Cutoff Date as Loan Installment/Paid Date '
			SET @ALIAS = 'Allow Cutoff Date as Loan Installment/Paid Date '
			SET @TOOLTIP = 'Allow Cutoff Date as Loan Installment/Paid Date '
			SET @GROUP_NAME = 'Loan Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Loan Decution as per cut off  date   *******/

			--ronakb loan application issue Bug #32598 16-01-25
			/******* Not Allow multiple loan Apply *******/
			SET @SETTING_NAME = 'Allow Multiple Loan'
			SET @ALIAS = 'Avoid to Apply Loan untill not close Previous Loan'
			SET @TOOLTIP = 'User can not apply second Loan Application untill not close/paid previous Loan'
			SET @GROUP_NAME = 'Loan Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
				/******* Not Allow multiple loan Apply *******/

           --ronakb Advance application issue Bug #32598 16-01-25
			/******* Not Allow multiple Advance Apply *******/
			SET @SETTING_NAME = 'Avoid to Apply Advance untill not close Previous Advance'
			SET @ALIAS = 'Avoid to Apply Advance untill not close Previous Advance'
			SET @TOOLTIP = 'User can not apply second Advance Application untill not close/paid previous Advance'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/******* Not Allow multiple Advance Apply *******/

			/*******  Add initial in employee full name  *******/
			SET @SETTING_NAME = 'Add initial in employee full name'
			SET @ALIAS = 'Add initial in employee full name'
			SET @TOOLTIP = 'To view employee`s full name with initial. Example: Mr. Rahul R Sharma.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Add initial in employee full name  *******/
	 
	 
			/*******  Add Other Employees In Travel Settlement  *******/
			SET @SETTING_NAME = 'Add Other Employees In Travel Settlement'
			SET @ALIAS = 'Add Other Employees In Travel Settlement'
			SET @TOOLTIP = 'To avail option to add other employee expense details while travel settlement.'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Add Other Employees In Travel Settlement  *******/
	 
	 
			/*******  Admin Side Default Salary Slip Format  *******/
			SET @SETTING_NAME = 'Admin Side Default Salary Slip Format'
			SET @ALIAS = 'Admin Side Default Salary Slip Format'
			SET @TOOLTIP = 'Enter the Format Number which you want to Generate as default'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"14"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Admin Side Default Salary Slip Format  *******/
			

			/*******  Leave Application Count as Used Balance  *******/
			SET @SETTING_NAME = 'Leave Application Count as Used Balance'
			SET @ALIAS = 'Leave Application Count as Used Balance'
			SET @TOOLTIP = 'Ex. Restrict to Apply Full Day Leave Second time in case of Available Balance only 1'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Leave Application Count as Used Balance  *******/
	 
			/*******  Advance Leave balance assign from Employee Master  *******/
			SET @SETTING_NAME = 'Advance Leave balance assign from Employee Master'
			SET @ALIAS = 'Advance Leave balance assign from Employee Master'
			SET @TOOLTIP = 'Activate the option if you would like to give Advance Leave from Employee Master.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Advance Leave balance assign from Employee Master  *******/
	 

			/*******  Employee can apply Maternity and Paternity leave in case employee status is single  *******/
			SET @SETTING_NAME = 'Employee can apply Maternity and Paternity leave in case employee status is single'
			SET @ALIAS = 'Employee can apply Maternity and Paternity leave in case employee status is single'
			SET @TOOLTIP = 'Activate the option then employee can apply Maternity and Paternity leave in any employee status.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Employee can apply Maternity and Paternity leave in case employee status is single  *******/
	 

	 
			/*******  Allow Attendance Regularization Editable  *******/
			SET @SETTING_NAME = 'Allow Attendance Regularization Editable'
			SET @ALIAS = 'Allow Attendance Regularization Editable'
			SET @TOOLTIP = 'To give privilege to edit in-out time while attendance regularization'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Allow Attendance Regularization Editable  *******/
	 
	 
			/*******  Allow Comments in Salary Slip  *******/
			SET @SETTING_NAME = 'Allow Comments in Salary Slip'
			SET @ALIAS = 'Allow Comments in Salary Slip'
			SET @TOOLTIP = 'To provide comment option to write while publishing salary slip to admin user which employee can view in salary slip'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Allow Comments in Salary Slip  *******/
	 
	 
			--/*******  Allow Part Day Leave  *******/
			--SET @SETTING_NAME = 'Allow Part Day Leave'
			--SET @ALIAS = 'Allow Part Day Leave'
			--SET @TOOLTIP = 'To add option in leave master for hourly base leave which allow employee to avail for Part day leave.'
			--SET @GROUP_NAME = 'Leave Settings'
			--SET @VTYPE = '1'
			--SET @VREF = '{"min":"0","max":"1000"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			--/*******  Allow Part Day Leave  *******/
	 
			
			/*******  Allow Part Day for Day and Hourly base Leave  *******/
			SET @SETTING_NAME = 'Allow Part Day for Day and Hourly base Leave'
			SET @ALIAS = 'Allow Part Day for Day and Hourly base Leave'
			SET @TOOLTIP = 'To show Option "Apply Hourly" in Leave Master, If Tick then Allow Part Day Leave only using Enter Time and hour period, If not tick then Allow Day base period and hour period using Leave Type Option'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Allow Part Day for Day and Hourly base Leave  *******/


			/*******  Allow Part Day for Hourly base Leave Only  *******/
			SET @SETTING_NAME = 'Allow Part Day for Hourly base Leave Only'
			SET @ALIAS = 'Allow Part Day for Hourly base Leave Only'
			SET @TOOLTIP = 'To show Option "Apply Hourly" in Leave Master, If Tick then Allow Part Day Leave only using Enter Time and hour period, If not tick then Allow Day base period Only, will not show Part Day Option for Day Base Leave.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Allow Part Day for Hourly base Leave Only  *******/






	 
			/*******  Allow Same Date Increment  *******/
			SET @SETTING_NAME = 'Allow Same Date Increment'
			SET @ALIAS = 'Allow Same Date Increment'
			SET @TOOLTIP = 'To add multiple entry of employee increment on same date.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Allow Same Date Increment  *******/
	 
	 
			/*******  Allowance detail show in Allowance/Reimbursement  *******/
			SET @SETTING_NAME = 'Allowance detail show in Allowance/Reimbursement'
			SET @ALIAS = 'Allowance detail show in Allowance/Reimbursement'
			SET @TOOLTIP = 'Turn on this feature to display Allowance detail in Allowance/Reimbursement'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Allowance detail show in Allowance/Reimbursement  *******/
	 
	 
			/*******  Auto Calculate CTC Amount during Salary Structure Assigning or Changing  *******/
			SET @SETTING_NAME = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing'
			SET @ALIAS = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing'
			SET @TOOLTIP = 'To calculate CTC amount automatically as per allowance allocation (Note: Option of Part of CTC of allowance has to be selected in allowance master)'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Auto Calculate CTC Amount during Salary Structure Assigning or Changing  *******/
	 
	 
			/*******  Auto Comp Off Approval  *******/
			SET @SETTING_NAME = 'Auto CompOff Approval'
			SET @ALIAS = 'Auto Comp Off Approval'
			SET @TOOLTIP = 'Turn on feature for Auto Comp Off Approval when Pre Comp Off Approval with job daily schedule'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Auto CompOff Approval  *******/
	 
	 
			/*******  Auto comp-Off leave dates adjust  *******/
			SET @SETTING_NAME = 'Auto comp-Off leave dates adjust'
			SET @ALIAS = 'Auto comp-Off leave dates adjust'
			SET @TOOLTIP = 'To consider default earliest comp date while leave application of comp-off leave type'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Auto comp-Off leave dates adjust  *******/
			--Added by Sumit on 29092016 for COPH and COND Leave----------------------------------------------------------
			/*******  Auto COPH & COND leave dates adjust  *******/
			SET @SETTING_NAME = 'Auto COPH leave dates adjust'
			SET @ALIAS = 'Auto COPH leave dates adjust'
			SET @TOOLTIP = 'To consider default earliest coph date while leave application of coph leave type'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******for COPH Leave Ended ******************/
			/*********** for COND Added ********************/
			SET @SETTING_NAME = 'Auto COND leave dates adjust'
			SET @ALIAS = 'Auto COND leave dates adjust'
			SET @TOOLTIP = 'To consider default earliest cond date while leave application of cond leave type'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******for COND Leave Ended ******************/
	 
			/*******  Auto credit one medical leave when first time ESIC leave have approved in year  *******/
			SET @SETTING_NAME = 'Auto credit one medical leave when first time ESIC leave have approved in year'
			SET @ALIAS = 'Auto credit one medical leave when first time ESIC leave have approved in year'
			SET @TOOLTIP = 'To credit on medical leave to employee once his first ESIC leave approved. (Note: Medical leave type should be created with Medical leave setting and allocated to employee)'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Auto credit one medical leave when first time ESIC leave have approved in year  *******/
	 
	 
			/*******  Auto Generate Employee PF Number  *******/
			SET @SETTING_NAME = 'Auto Generate Employee PF Number'
			SET @ALIAS = 'Auto Generate Employee PF Number'
			SET @TOOLTIP = 'To auto generate PF number while manual entry of employee in employee master. (Note: During import of employee , PF needs to mention manually in import sheet ).'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Auto Generate Employee PF Number  *******/
	 
	 
			/*******  Auto LWP Leave  *******/
			SET @SETTING_NAME = 'Auto LWP Leave'
			SET @ALIAS = 'Auto LWP Leave'
			SET @TOOLTIP = 'To consider LWP leave if selected leave type not having sufficient balance while leave application. In case of inactive, only "Negative leave is not allow"'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Auto LWP Leave  *******/
	 
	 
			/*******  AX  *******/
			SET @SETTING_NAME = 'AX'
			SET @ALIAS = 'AX'
			SET @TOOLTIP = 'Export salary data in excel file for Dynamic Microsoft ERP'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  AX  *******/
	 
	 
			/*******  Bonus Detail - Salary Arrears Amount Calculated In Arrear Month  *******/
			SET @SETTING_NAME = 'Bonus Detail - Salary Arear Amount Calculated In Arear Month'
			SET @ALIAS = 'Bonus Detail - Salary Arrears Amount Calculated In Arrear Month'
			SET @TOOLTIP = 'Bonus Detail - Salary Arrears Amount Calculated In Arrear Month'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Bonus Detail - Salary Arrears Amount Calculated In Arrear Month  *******/
	 
	 
	 	/******* Binal 24042020  Auto PL Leave Enable Detail - Salary Process *******/
			SET @SETTING_NAME = 'Auto Leave Approve against Absent Days during Salary Process'
            SET @ALIAS = 'Auto Leave Approve against Absent Days during Salary Process'
            SET @TOOLTIP = 'If this Setting is On then During Salary Process, System will Auto Approve Leave against Absent days, If this setting OFF then Normal Salary Process'
            SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/******* Binal 24042020  Auto PL Leave Enable Detail - Salary Process *******/
		
	 
			/*******  Branch wise Leave  *******/
			SET @SETTING_NAME = 'Branch wise Leave'
			SET @ALIAS = 'Branch wise Leave'
			SET @TOOLTIP = 'To get branch wise selection during leave type creation in leave master'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Branch wise Leave  *******/
	 
	 
			/*******  Bulk Increment Basic Salary Upper Rounding *******/
			SET @SETTING_NAME = 'Bulk Increment Basic Salary Upper Rouning'
			SET @ALIAS = 'Bulk Increment Basic Salary Upper Rounding'
			SET @TOOLTIP = 'To set rounding value for basic amount as define value at upper side.'
			SET @GROUP_NAME = 'Bulk Increment'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"100","step":"5"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Bulk Increment Basic Salary Upper Rounding  *******/
	 
	 
			/*******  Calculate Salary Base on Production Details  *******/
			SET @SETTING_NAME = 'Calculate Salary Base on Production Details'
			SET @ALIAS = 'Calculate Salary Base on Production Details'
			SET @TOOLTIP = 'Activate the option to calculate the salary based on production details.'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Calculate Salary Base on Production Details  *******/
	 
	 
			/*******  Check Absent History of Previous Month in Leave  *******/
			SET @SETTING_NAME = 'Check Absent History of Previous Month in Leave'
			SET @ALIAS = 'Check Absent History of Previous Month in Leave'
			SET @TOOLTIP = 'To view absent history while raising previous month leave application'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Check Absent History of Previous Month in Leave  *******/
	 
	 
			/*******  Comment field Mandatory in Leave Cancellation form  *******/
			SET @SETTING_NAME = 'Comment field Mandatory in Leave Cancellation form'
			SET @ALIAS = 'Comment field Mandatory in Leave Cancellation form'
			SET @TOOLTIP = 'To fill comment while leave cancellation application'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Comment field Mandatory in Leave Cancellation form  *******/
	 
	 
			/*******  Comp-off Balance show as on date wise  *******/
			SET @SETTING_NAME = 'Comp-off Balance show as on date wise'
			SET @ALIAS = 'Comp Off Balance show as on date wise'
			SET @TOOLTIP = 'To view date wise received Comp Off balance as on date.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Comp-off Balance show as on date wise  *******/
	 
	 
			/*******  Conveyance Tax Exemption based on prorate  *******/
			SET @SETTING_NAME = 'Conveyance Tax Exemption based on prorate'
			SET @ALIAS = 'Conveyance Tax Exemption based on prorates'
			SET @TOOLTIP = 'To get exemption of conveyance according to paid conveyance in salary.'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Conveyance Tax Exemption based on prorate  *******/
	 
	 
			/*******  Default Checked Arrear Day Checkbox in Leave Approval  *******/
			SET @SETTING_NAME = 'Default Checked Arrear Day Checkbox in Leave Approval'
			SET @ALIAS = 'Default Checked Arrear Day Checkbox in Leave Approval'
			SET @TOOLTIP = 'To get default tick mark on "Arrear day" selection for last month leave payment.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Default Checked Arrear Day Checkbox in Leave Approval  *******/
	 
	 
			/*******  Direct Login to ESS Portal  *******/
			SET @SETTING_NAME = 'Direct Login to ESS Portal'
			SET @ALIAS = 'Direct Login to ESS Portal'
			SET @TOOLTIP = 'Set 1 If Admin/ESS Employee Privileges User Directly Login to ESS Portal else Set 0 User Directly Login to Admin Portal'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Direct Login to ESS Portal  *******/
	 
	 
			/*******  Disable Employee Code, Date of Joining & PF No when Employee Creation from Employee Master  *******/
			SET @SETTING_NAME = 'Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master'
			SET @ALIAS = 'Disable Employee Code, Date Of Joining & PF No when Employee Creation from Employee Master'
			SET @TOOLTIP = 'Turn on feature to Disable Employee Code, Date Of Joining and PF No in Employee Master'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Disable Employee Code, Date of Joining & PF No when Employee Creation from Employee Master  *******/
	 
			
			--		/*******   Camera Option For Mobile In/Out  *******/
			--SET @SETTING_NAME = 'Enable Web Cam for ESS user during Manual clock-in clock-out from Web-application '
			--SET @ALIAS = 'Enable Web Cam for ESS user during Manual clock-in clock-out from Web-application '
			--SET @TOOLTIP = 'Turn on to Enable Camera for Manual In/Out'
			--SET @GROUP_NAME = 'Attendance Settings'
			--SET @VTYPE = '1'
			--SET @VREF = '{"min":"0","max":"1000"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			--/*******   Camera Option For Mobile In/Out  *******/
	 
			-- Added By Sajid 05-09-2023
			/*******  Mobile In Out Camera & Geofence Enable  *******/
			SET @SETTING_NAME = 'Mobile In Out Camera & Geofence Enable While Mobile Activation'
			SET @ALIAS = 'Mobile In Out Camera & Geofence Enable While Mobile Activation'
			SET @TOOLTIP = 'Set 1 for Camera Enable Else Set 2 for Geofence Enable Else Set 3 Camera + Geofence Enable Else 0 for Regular'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"3"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL

	 
			/*******  Disable Guarantor Validation in Loan Application/Approval  *******/
			SET @SETTING_NAME = 'Disable Guarantor Validation in Loan Application/Approval'
			SET @ALIAS = 'Disable Guarantor Validation in Loan Application/Approval'
			SET @TOOLTIP = 'To disable guarantor name while loan application or guarantor name would be mandatory'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Disable Guarantor Validation in Loan Application/Approval  *******/
	 
	 
			/*******  Disable Tax Free Checkbox  *******/
			SET @SETTING_NAME = 'Disable Tax Free Checkbox'
			SET @ALIAS = 'Disable Tax Free Checkbox'
			SET @TOOLTIP = 'To disable Tax free check box while reimbursement application or else Tax free check box would be mandatory'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Disable Tax Free Checkbox  *******/
	 
	 
			/*******  Display Actual Birth Date  *******/
			SET @SETTING_NAME = 'Display Actual Birth Date'
			SET @ALIAS = 'Display Actual Birth Date'
			SET @TOOLTIP = 'Display Employee Actual Birth Date'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Display Actual Birth Date  *******/
	 
	 
			/*******  Display Leave Detail by Selected Period  *******/
			SET @SETTING_NAME = 'Display Leave Detail by Selected Period'
			SET @ALIAS = 'Display Leave Detail by Selected Period'
			SET @TOOLTIP = 'Insert 1 to display leave detail by Calendar year (i.e. the leave transactions will be taken from 1st Jan to 31st Dec), Insert 2 for financial year wise or leave 0 to display leave as on date in Leave Application/Approval.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"2"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Display Leave Detail by Selected Period  *******/
			
			/*******  Eanable Advance in Travel  *******/
			SET @SETTING_NAME = 'Enable Travel Type in Travel Module / Travel Expense'
			SET @ALIAS = 'Enable Travel Type in Travel Module / Travel Expense'
			SET @TOOLTIP = 'Active Option for Enable Travel Type in Travel Module / Travel Expense.'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Eanable Advance in Travel  *******/

				/*******  Eanable SONo in Travel  *******/  --Added By Yogesh on 07092023
			SET @SETTING_NAME = 'Hide/Show SONo TextBox Prefix'
			SET @ALIAS = 'Hide/Show SONo TextBox Prefix'
			SET @TOOLTIP = 'Active Option for Enable So.No. Prefix'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Eanable SONo in Travel  *******/ --Added By Yogesh on 07092023

			/*******  Eanable Reason in Travel  *******/  --Added By Yogesh on 07092023
			SET @SETTING_NAME = 'Hide/Show Reason List'
			SET @ALIAS = 'Hide/Show Reason List'
			SET @TOOLTIP = 'Active Option for Enable Reason'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Eanable Reason in Travel  *******/ --Added By Yogesh on 07092023





				/*******  Eanable Advance in Travel  *******/
			SET @SETTING_NAME = 'Enable Advance in Travel'
			SET @ALIAS = 'Enable Advance in Travel'
			SET @TOOLTIP = 'Active Option for Enable Advance in Travel.'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Eanable Advance in Travel  *******/

			/*******  Eanable Travel Tracking in Travel  *******/
			SET @SETTING_NAME = 'Enable Travel Tracking in Travel Module'
			SET @ALIAS = 'Enable Travel Tracking in Travel Module'
			SET @TOOLTIP = 'Active Option for Enable Travel Tracking in Travel Module'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Eanable Travel Tracking in Travel   *******/

				/*******  Eanable Travel Tracking in Travel  *******/
			SET @SETTING_NAME = 'Enable Dynamic hierarchy in Scheme'
			SET @ALIAS = 'Enable Dynamic hierarchy in Scheme'
			SET @TOOLTIP = 'Active Option for Enable Dynamic hierarchy in Scheme'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Eanable Travel Tracking in Travel   *******/
		
			--/*******  Eanable Advance in Travel  *******/
			--SET @SETTING_NAME = 'Enable Travel Type in Expense Master'
			--SET @ALIAS = 'Enable Travel Type in Expense Master'
			--SET @TOOLTIP = 'Active Option for Enable Travel Type in Expense Master.'
			--SET @GROUP_NAME = 'Travel Settings'
			--SET @VTYPE = '1'
			--SET @VREF = '{"min":"0","max":"1000"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			--/*******  Eanable Advance in Travel  *******/
	 
			/*******  Employee Lock After First Salary  *******/
			SET @SETTING_NAME = 'Employee Lock After First Salary'
			SET @ALIAS = 'Employee Lock After First Salary'
			SET @TOOLTIP = 'To lock Employee`s basic and salary structure once first month salary process. '
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Employee Lock After First Salary  *******/
	 
	 
			/*******  Employee Retirement Age  *******/
			SET @SETTING_NAME = 'Employee Retirement Age'
			SET @ALIAS = 'Employee Retirement Age'
			SET @TOOLTIP = 'Select Age for employee retirement, Retirement date consider accordingly. User needs to select prior to any entry in employee master.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=58,@MODULE_NAME=NULL
			/*******  Employee Retirement Age  *******/
	 
	 
			/*******  Enable Age Restriction in Medical for Dependent (Enter Age)  *******/
			SET @SETTING_NAME = 'Enable Age Restriction in Medical for Dependent (Enter Age)'
			SET @ALIAS = 'Enable Age Restriction in Medical for Dependent (Enter Age)'
			SET @TOOLTIP = 'Enable Age Restriction in Medical for Dependent (Enter Age)'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=18,@MODULE_NAME='PAYROLL'
			/*******  Enable Age Restriction in Medical for Dependent (Enter Age)  *******/
	 
	 
			/*******  Enable Asset Installment  *******/
			SET @SETTING_NAME = 'Enable Asset Installment'
			SET @ALIAS = 'Enable Asset Installment'
			SET @TOOLTIP = 'To add installment details of approved asset'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Asset Installment  *******/
	 
			/*******  Enable Multi Language  *******/ -- Added by rohit on 20102016
			SET @SETTING_NAME = 'Enable Multi Language'
			SET @ALIAS = 'Enable Multi Language Settings'
			SET @TOOLTIP = 'To Enable Multi language Option'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Multi Language  *******/
	 
	 
			/*******  Enable Check out Date Option in Travel Application  *******/
			SET @SETTING_NAME = 'Enable Check out Date Option in Travel Application'
			SET @ALIAS = 'Enable Check out Date Option in Travel Application'
			SET @TOOLTIP = 'Enable Check out Date Option in Travel Application'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Check out Date Option in Travel Application  *******/
	 
	 
			/*******  Enable document upload in grade master  *******/
			SET @SETTING_NAME = 'Enable document upload in grade master'
			SET @ALIAS = 'Enable document upload in Grade Master'
			SET @TOOLTIP = 'To avail option for Document upload'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable document upload in grade master  *******/
	 
	 
			/*******  Enable Import Option for Estimated Amount  *******/
			SET @SETTING_NAME = 'Enable Import Option for Estimated Amount'
			SET @ALIAS = 'Enable Import Option for Estimated Amount'
			SET @TOOLTIP = 'Enable Import Option for Estimated Amount in It Preparation report on Listed Type Allowance.(Late,Present Scenario,Absent Scenario,Leave Scenario,Performance,Transfer OT,Import,Bonus,Present Days,Slab Wise,Reference,Shift Wise,Leave Allowance,Split Shift,Formula,Security Deposit,Present + Paid Leave Days,Night Halt)'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Enable Import Option for Estimated Amount  *******/
	 
	 
			/*******  Enable Instruct By Employee Column in Travel Application  *******/
			SET @SETTING_NAME = 'Enable Instruct By Employee Column in Travel Application'
			SET @ALIAS = 'Enable Instruct By Employee Column in Travel Application'
			SET @TOOLTIP = 'To enable "Employee Name" under Instruct By field while Travel application'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Instruct By Employee Column in Travel Application  *******/
	 
	 
			/*******  Enable International Travel  *******/
			SET @SETTING_NAME = 'Enable International Travel'
			SET @ALIAS = 'Enable International Travel'
			SET @TOOLTIP = 'To get option to add Internal Travel details'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable International Travel  *******/
	 
	 
			/*******  Enable IT Declaration for mid join employee upto days  *******/
			SET @SETTING_NAME = 'Enable IT Declaration for mid join employee upto days'
			SET @ALIAS = 'Enable IT Declaration for mid join employee up to days'
			SET @TOOLTIP = 'For Mid join employee enable IT Declaration for the days period even if periodically lock is enabled.'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=30,@MODULE_NAME='PAYROLL'
			/*******  Enable IT Declaration for mid join employee upto days  *******/
	 
	 
			/*******  Enable Miss punch SMS  *******/
			SET @SETTING_NAME = 'Enable Miss punch SMS'
			SET @ALIAS = 'Enable Miss punch SMS'
			SET @TOOLTIP = 'Turn feature On or Off for Miss Punch SMS'
			SET @GROUP_NAME = 'SMS Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Miss punch SMS  *******/
	 
	 
			/*******  Enable Project in Travel  *******/
			--Commented by Sumit on 14022017
			--SET @SETTING_NAME = 'Enable Project in Travel'
			--SET @ALIAS = 'Enable Project in Travel'
			--SET @TOOLTIP = 'To enable project details option while Travel application'
			--SET @GROUP_NAME = 'Travel Settings'
			--SET @VTYPE = '1'
			--SET @VREF = '{"min":"0","max":"1000"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Project in Travel  *******/
	 
	 
			/*******  Exit Clearance Require  *******/
			SET @SETTING_NAME = 'Exit Clearance Require'
			SET @ALIAS = 'Exit Clearance Require'
			SET @TOOLTIP = 'Turn this feature on to force user to give reason of Exit Clearance.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Exit Clearance Require  *******/
	 
	 
			/*******  Gratuity Amount Hide In FNF Letter  *******/
			SET @SETTING_NAME = 'Gratuity Amount Hide In FNF Letter'
			SET @ALIAS = 'Gratuity Amount Hide In FNF Letter'
			SET @TOOLTIP = 'To skip gratuity amount calculation during F & F'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Gratuity Amount Hide In FNF Letter  *******/
	 
	 
			/*******  Hide Age Column  *******/
			SET @SETTING_NAME = 'Hide Age Column'
			SET @ALIAS = 'Hide Age Column'
			SET @TOOLTIP = 'To hide employee age in Employee Profile'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Hide Age Column  *******/
	 
	 
			/*******  Hide Allowance Rate in Salary Slip  *******/
			SET @SETTING_NAME = 'Hide Allowance Rate in Salary Slip'
			SET @ALIAS = 'Hide Allowance Rate in Salary Slip'
			SET @TOOLTIP = 'To hide Allowance rate as per employee salary structure from all format of salary slip'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Hide Allowance Rate in Salary Slip  *******/
	 
	 
			/*******  Hide Browse file in IT declaration  *******/
			SET @SETTING_NAME = 'Hide Browse file in IT declaration'
			SET @ALIAS = 'Hide Browse file in IT declaration'
			SET @TOOLTIP = 'To hide option of upload documents'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Hide Browse file in IT declaration  *******/
	 
	 
			/*******  Hide Cancel Week off and Holiday in Leave Application  *******/
			SET @SETTING_NAME = 'Hide Cancel Weekoff and Holiday in Leave Application'
			SET @ALIAS = 'Hide Cancel Week off and Holiday in Leave Application'
			SET @TOOLTIP = 'Hide Cancel Week off and Holiday in Leave Application'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Cancel Week off and Holiday in Leave Application  *******/
	 
	 
			/*******  Hide Cancel Week off and Holiday in Leave Approval  *******/
			SET @SETTING_NAME = 'Hide Cancel Weekoff and Holiday in Leave Approval'
			SET @ALIAS = 'Hide Cancel Week off and Holiday in Leave Approval'
			SET @TOOLTIP = 'To hid check box option for Week off and Holiday consider for leave period approval'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Cancel Week off and Holiday in Leave Approval  *******/
	 
	 
			/*******  Hide Currency in Claim Application  *******/
			SET @SETTING_NAME = 'Hide Currency in Claim Application'
			SET @ALIAS = 'Hide Currency in Claim Application'
			SET @TOOLTIP = 'To view Currency exchange rate in claim application'
			SET @GROUP_NAME = 'Claim Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Hide Currency in Claim Application  *******/
	 
	 
			/*******  Hide Downline Employee Salary  *******/
			SET @SETTING_NAME = 'Hide Downline Employee Salary'
			SET @ALIAS = 'Hide Downline Employee Salary'
			SET @TOOLTIP = 'To disable salary details of sub-ordinates'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Hide Downline Employee Salary  *******/
	 
			
				/*******  Calculate Full PF, evenif Basic is above PF Limit  Added By Jimit 20052019 *******/ 
			SET @SETTING_NAME = 'Calculate Full PF, evenif Basic is above PF Limit'
			SET @ALIAS = 'Calculate Full PF, evenif Basic is above PF Limit'
			SET @TOOLTIP = 'When Full PF Applicable to Employee and Basic Salary is above the PF Limit and this setting is on then PF is calculating on Basic + Other Allowance Amount, if it is not on then PF is calculating only on the Basic salary.'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Calculate Full PF, evenif Basic is above PF Limit  *******/
	 


			/*******  Hide Employee Details Caption on Dashboard(ESS)  *******/
			SET @SETTING_NAME = 'Hide Employee Details Caption on Dashboard(ESS)'
			SET @ALIAS = 'Hide Employee Details Caption on Dashboard (ESS)'
			SET @TOOLTIP = 'To hide employee details on dashboard in ESS access'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Hide Employee Details Caption on Dashboard(ESS)  *******/
	 
	 
			/*******  Hide Leave Balance in Leave Application/Approval  *******/
			SET @SETTING_NAME = 'Hide Leave Balance in Leave Application/Approval'
			SET @ALIAS = 'Hide Leave Balance in Leave Application/Approval'
			SET @TOOLTIP = 'To hide leave balance while leave application and approval.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Leave Balance in Leave Application/Approval  *******/
	 
	 
			/*******  Hide Monthly OT Approval  *******/
			SET @SETTING_NAME = 'Hide Monthly OT Approval'
			SET @ALIAS = 'Hide Monthly OT Approval'
			SET @TOOLTIP = 'To hide option of "Monthly" Over Time option in Overtime approval. User only get daily OT approval'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Monthly OT Approval  *******/
	 
	 
			/*******  How Many Decimal In Allowance  *******/
			SET @SETTING_NAME = 'How Many Decimal In Allowance'
			SET @ALIAS = 'No of Decimal In Salary Allowance'
			SET @TOOLTIP = 'option for How many decimal Value Shows in the Allowance.like 2 decimal means 18.00 and 3 decimal means 18.000 and Max Is 4 Decimal only'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"4"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=2,@MODULE_NAME='PAYROLL'
			/*******  How Many Decimal In Allowance  *******/
	 
	 
			/*******  In and Out Punch depends on Device In-Out Flag  *******/
			SET @SETTING_NAME = 'In and Out Punch depends on Device In-Out Flag'
			SET @ALIAS = 'In and Out Punch depends on Device In-Out Flag'
			SET @TOOLTIP = 'Set 1 if In Out Punch depends on Device In-Out Flag Else Set 2 if Shift Start from 12 AM Else 0 for Regular Synchronize'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"2"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  In and Out Punch depends on Device In-Out Flag  *******/


			
			/*******  "04"  More than Alloted daily Overtime hours convert to Compoff  *******/ --Added by deepal on 13102022
			SET @SETTING_NAME = 'More than alloted daily overtime hours convert to compoff'
			SET @ALIAS = 'More than alloted daily overtime hours convert to compoff'
			SET @TOOLTIP = 'If its Defined More than "0" then Hide Those Overtime Date which is more than Defined OT Hours in Overtime Approval'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"2"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  "04"  More than Alloted daily Overtime hours convert to Compoff  *******/
	 
			/*******    Reminder Days of Payroll Application Renewal  *******/ --Added by deepal on 13102022
			SET @SETTING_NAME = 'Reminder Days of Payroll Application Renewal'
			SET @ALIAS = 'Reminder Days of Payroll Application Renewal'
			SET @TOOLTIP = 'Reminder Days of Payroll Application Renewal'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"30","max":"99"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******    Reminder Days of Payroll Application Renewal  *******/
	 
			/*******  In F&F, Disable Leave Encash Days Validation  *******/
			SET @SETTING_NAME = 'In F&F, Disable Leave Encash Days Validation'
			SET @ALIAS = 'In F&F, Disable Leave Encash Days Validation'
			SET @TOOLTIP = 'To allow Encash No. of leave more than employee`s actual leave balance while F&F.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  In F&F, Disable Leave Encash Days Validation  *******/
	 
	 
			/*******  In OT Approval Remark Column Show  *******/
			SET @SETTING_NAME = 'In OT Approval Remark Column Show'
			SET @ALIAS = 'In OT Approval Remark Column Show'
			SET @TOOLTIP = 'To view column option to add remark while OT approval'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  In OT Approval Remark Column Show  *******/
			
			/*******  In OT Approval Restrict Approval Should not Exceed from Actual OT -- By Sumit on 17022017 *******/
			SET @SETTING_NAME = 'Approved OT Hours should not exceed from Actual OT Hours'
			SET @ALIAS = 'Approved OT Hours should not exceed from Actual OT Hours'
			SET @TOOLTIP = 'To Restrict Approved OT Should not Exceed from Actual OT'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  In OT Approval Restrict Approval Should not Exceed from Actual OT  -- By Sumit on 17022017 *******/
			
			
			/*******  Comment Mandatory For OT Approval  *******/
			SET @SETTING_NAME = 'Comment Mandatory For OverTime Approval'
			SET @ALIAS = 'Comment Mandatory For OverTime Approval'
			SET @TOOLTIP = 'Comment Mandatory For OverTime Approval'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,
					@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Comment Mandatory For OT Approval  *******/
	 
			
			
	 
			/*******  In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount  *******/
			SET @SETTING_NAME = 'In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount'
			SET @ALIAS = 'In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount'
			SET @TOOLTIP = 'To allow approve amount more than claim amount in Travel settlement'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount  *******/
	 
	 
			/*******  InActive User After Days  *******/
			SET @SETTING_NAME = 'InActive User After Days'
			SET @ALIAS = 'Inactive User After Days'
			SET @TOOLTIP = 'Add no. of days where in no activity found from Employee, Employee would be inactive.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  InActive User After Days  *******/
	 
	 
			/*******  Include Leave Details in Salary Slip  *******/
			SET @SETTING_NAME = 'Include Leave Details in Salary Slip'
			SET @ALIAS = 'Include Leave Details in Salary Slip'
			SET @TOOLTIP = 'To view leave details in salary slip'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Include Leave Details in Salary Slip  *******/
	 
	 
			/*******  Insurance Reminder Days  *******/
			SET @SETTING_NAME = 'Insurance Reminder Days'
			SET @ALIAS = 'Insurance Reminder Days'
			SET @TOOLTIP = 'To get reminder prior to mention days for insurance'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Insurance Reminder Days  *******/
	 
	 
			/*******  Intimate day for Allowance/Reimbursement application  *******/
			SET @SETTING_NAME = 'Intimate day for Allowance/Reimbursement application'
			SET @ALIAS = 'Intimate day for Allowance/Reimbursement application'
			SET @TOOLTIP = 'To set of days which reminder before define no. of days to employees for optional allowance selection'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=365,@MODULE_NAME='PAYROLL'
			/*******  Intimate day for Allowance/Reimbursement application  *******/
	 
	 
			/*******  IS_YEARLY_CTC  *******/
			SET @SETTING_NAME = 'IS_YEARLY_CTC'
			SET @ALIAS = 'IS_YEARLY_CTC'
			SET @TOOLTIP = 'To implement Yearly base CTC formula wise salary structure'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  IS_YEARLY_CTC  *******/
	 
	 
			/*******  Leave not Approval Popup in Salary  *******/
			SET @SETTING_NAME = 'Leave not Approval Popup in Salary'
			SET @ALIAS = 'Leave not Approval Popup in Salary'
			SET @TOOLTIP = 'To receive pop-up for pending leave application'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Leave not Approval Popup in Salary  *******/
	 
	 
			/*******  Leave Selection [On Duty] Mandatory for Travel  *******/
			SET @SETTING_NAME = 'Leave Selection [On Duty] Mandatory for Travel'
			SET @ALIAS = 'Leave Selection [On Duty] Mandatory for Travel'
			SET @TOOLTIP = 'Leave Selection [On Duty] Mandatory for Travel'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Leave Selection [On Duty] Mandatory for Travel  *******/
	 
	 
			/*******  Lower Round in leave Balance  *******/
			SET @SETTING_NAME = 'Lower Round in leave Balance'
			SET @ALIAS = 'Lower Round in leave Balance'
			SET @TOOLTIP = 'To set leave balance in lower rounding in case of decimal leave balance. Example: leave balance is 1.22 then 1 leave balance to be used'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Lower Round in leave Balance  *******/
	 
	 
			/*******  Maximum gap between two canteen punch (In minutes)  *******/
			SET @SETTING_NAME = 'Maximum gap between two canteen punch (In minutes)'
			SET @ALIAS = 'Maximum gap between two canteen punch (In minutes)'
			SET @TOOLTIP = 'Not to consider multiple punch entries for canteen in-out as per define punch entry.'
			SET @GROUP_NAME = 'Canteen Deduction'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"30"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Maximum gap between two canteen punch (In minutes)  *******/
	 
	 
			/*******  Min. basic rules applicable  *******/
			SET @SETTING_NAME = 'Min. basic rules applicable'
			SET @ALIAS = 'Min. basic rules applicable'
			SET @TOOLTIP = 'To consider as per movement minimum wages for employee`s basic amount'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Min. basic rules applicable  *******/
	 
	 
			/*******  Minimum Character for Leave Reason  *******/
			if  exists(Select 1 from T0040_SETTING where Setting_Name='Minimum Character Require for Leave Application Reason')
				BEGIN
					delete from T0040_SETTING
					where Setting_Name='Minimum Character Require for Leave Application Reason'				

				END
			
			SET @SETTING_NAME = 'Minimum Character for Leave Reason'
			SET @ALIAS = 'Minimum Character for Leave Reason'
			SET @TOOLTIP = 'To set minimum characters requirement for leave reason'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"1024"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Minimum Character for Leave Reason  *******/
	 
	 
			/*******  Monthly base get reimbursement claim amount  *******/
			SET @SETTING_NAME = 'Monthly base get reimbursement claim amount'
			SET @ALIAS = 'Monthly base get reimbursement claim amount'
			SET @TOOLTIP = 'To allow payment of reimbursement as monthly eligibility only even if claim is higher than avail balance'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Monthly base get reimbursement claim amount  *******/
	 
	 
			/*******  OD and CompOff Leave Consider As Present  *******/
			SET @SETTING_NAME = 'OD and CompOff Leave Consider As Present'
			SET @ALIAS = 'OD and Comp Off Leave Consider As Present'
			SET @TOOLTIP = 'To consider as present if attendance status shows OD or Comp-off leave taken'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  OD and CompOff Leave Consider As Present  *******/
	 
	 
			/*******  Pre Comp Off Request Mandatory  *******/
			SET @SETTING_NAME = 'Pre Comp-off Request Mandatory'
			SET @ALIAS = 'Pre Comp Off Request Mandatory'
			SET @TOOLTIP = 'To make Pre Comp Off request mandatory before do extra work to gain Comp Off balance or raise as application for Comp Off'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Pre Comp Off Request Mandatory  *******/
	 
	 
			/*******  Present Compulsory Extra Days Deduction(Holiday Master)  *******/
			--SET @SETTING_NAME = 'Present Compulsory Extra Days Deduction (Holiday Master) chetan/nimeshbhai 150417'
			SET @SETTING_NAME = 'Present Compulsory Extra Days Deduction(Holiday Master)'
			SET @ALIAS = 'Present Compulsory Extra Days Deduction (Holiday Master)'
			SET @TOOLTIP = 'To deduct define extra days deduction when holiday mark as present compulsory'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Present Compulsory Extra Days Deduction(Holiday Master)  *******/
	 
	 
			/*******  Process salary in background  *******/
			SET @SETTING_NAME = 'Process salary in background'
			SET @ALIAS = 'Process salary in background'
			SET @TOOLTIP = 'To process salary in background and user can access other application while process salary'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Process salary in background  *******/

			/*******  Process salary in background  *******/
			SET @SETTING_NAME = 'Count of actual day salary in current month'
			SET @ALIAS = 'Count of actual day salary in current month'
			SET @TOOLTIP = 'For monthly salary will not calculate week of and holiday of future day'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Process salary in background  *******/

		
	 
	 
	 
			/*******  Purpose Column Mandatory in Travel Application  *******/
			SET @SETTING_NAME = 'Purpose Column Mandatory in Travel Application'
			SET @ALIAS = 'Purpose Column Mandatory in Travel Application'
			SET @TOOLTIP = 'Purpose Column Mandatory in Travel Application'
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Purpose Column Mandatory in Travel Application  *******/
	 
	 
			/*******  Reimbershment Not Effect in Salary Default  *******/
			SET @SETTING_NAME = 'Reimbershment Not Effect in Salary Default'
			SET @ALIAS = 'Reimbursement Not Effect in Salary Default'
			SET @TOOLTIP = 'Enable option for Reimbursement Not Effect in Salary by Default'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Reimbershment Not Effect in Salary Default  *******/
	 
	 
			/*******  Reimbershment Shows in IT Computation  *******/
			SET @SETTING_NAME = 'Reimbershment Shows in IT Computation'
			SET @ALIAS = 'Reimbursement Shows in IT Computation'
			SET @TOOLTIP = 'Enable Reimbursement Shows in IT Computation'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Reimbershment Shows in IT Computation  *******/


			/******* Show Compare Tax Pannel Every financial Year Added by ronakk with Sandip bhai 17042023  *******/
			SET @SETTING_NAME = 'Show Compare Tax Panel in IT Declaration Every financial Year'
			SET @ALIAS = 'Show Compare Tax Panel in IT Declaration Every financial Year'
			SET @TOOLTIP = 'Enable Show Compare Tax Panel in IT Declaration Every financial Year'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/******* Show Compare Tax Pannel Every financial Year Added by ronakk with Sandip bhai 17042023  *******/

			
			-- Start Added by Niraj (22062022)
			/*******  Enable Re-Process Salary with Tax Planning  *******/
			SET @SETTING_NAME = 'Enable Auto Re-Process Salary with Tax Planning'
			SET @ALIAS = 'Enable Auto Re-Process Salary with Tax Planning'
			SET @TOOLTIP = 'If Setting is ON then Monthly TDS Amount will be Revised or Add automatically in Salary(re-processed) after Saving Tax Planning'
			SET @GROUP_NAME = 'Income-Tax Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Re-Process Salary with Tax Planning  *******/
			-- End Added by Niraj (22062022)
	 
			/*******  Reimbusement application after date of join days  *******/
			SET @SETTING_NAME = 'Reimbusement application after date of join days'
			SET @ALIAS = 'Reimbursement application after date of join days'
			SET @TOOLTIP = 'Add no. of day which allow employee raise a reimbursement application after his Date of Joining.'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Reimbusement application after date of join days  *******/
	 
	 
			/*******  Report Preview Options  *******/
			SET @SETTING_NAME = 'Report Preview Options'
			SET @ALIAS = 'Report Preview Options'
			SET @TOOLTIP = 'To enable preview option for all reports'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Report Preview Options  *******/
	 
	 
			/*******  Required Specialty and Type of Services  *******/
			SET @SETTING_NAME = 'Required Specility and Type of Services'
			SET @ALIAS = 'Required Specialty and Type of Services'
			SET @TOOLTIP = 'Turn this feature on for Common Timesheet or Off it for Client Changes in Timesheet'
			SET @GROUP_NAME = 'Timesheet Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='TIMESHEET'
			/*******  Required Specialty and Type of Services  *******/
	 
			/*******  Show additional fields in project master  *******/ 
			--Added by Mr.Mehul on 28122022
			SET @SETTING_NAME = 'Show additional fields in project master'
			SET @ALIAS = 'Show additional fields in project master'
			SET @TOOLTIP = 'Turn on to get additional fields inside project master'
			SET @GROUP_NAME = 'Timesheet Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='TIMESHEET'
			/*******  Show additional fields in project master   *******/

	 
			/*******  Restrict other master creation when Employee Master Import  *******/
			SET @SETTING_NAME = 'Restrict other master creation when Emplyee Master Import'
			SET @ALIAS = 'Allow other master creation when Employee Master Import'
			SET @TOOLTIP = 'Turn the feature on to allow application creating other master data automatically.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Restrict other master creation when Employee Master Import  *******/
	 
	 
			/*******  Restrict Reim. Application Amount on Yearly Prorata Limit  *******/
			SET @SETTING_NAME = 'Restrict Reim. Application Amount on Yearly Prorata Limit'
			SET @ALIAS = 'Restrict Reim. Application Amount on Yearly Prorata Limit'
			SET @TOOLTIP = 'To consider reimbursement amount on yearly prorata limit and not according to max limit from allowance master'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Restrict Reim. Application Amount on Yearly Prorata Limit  *******/
	 
	 
			/*******  Restrict Self Leave Approval if Admin rights assigned   *******/
			SET @SETTING_NAME = 'Restrict Self Leave Approval if Admin rights assigned'
			SET @ALIAS = 'Restrict Self Leave Approval if Admin rights assigned'
			SET @TOOLTIP = 'To restrict leave approval of own if user is having admin rights. '
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Restrict Self Leave Approval if Admin rights assigned   *******/
	 
	 
			/*******  Reverse Current WO/HO Cancel Policy  *******/
			SET @SETTING_NAME = 'Reverse Current WO/HO Cancel Policy'
			SET @ALIAS = 'Reverse Current WO/HO Cancel Policy'
			SET @TOOLTIP = 'Week Off Will not be canceled between the leave period if you turned the feature OFF.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Reverse Current WO/HO Cancel Policy  *******/
	 
	 
			/*******  Round Loan Interest Amount  *******/
			SET @SETTING_NAME = 'Round Loan Interest Amount'
			SET @ALIAS = 'Round Loan Interest Amount'
			SET @TOOLTIP = 'To count rounded amount for loan interest'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Round Loan Interest Amount  *******/

			/*******  '1 st installment Start date from EMI start Date insted of prorate intrest deduction same like bank rule'  *******/
			SET @SETTING_NAME = '1 st installment start date from EMI start date deduct like bank rule'
			SET @ALIAS = '1 st installment start date from EMI start date deduct like bank rule'
			SET @TOOLTIP = '1 st installment Start date from EMI start Date insted of prorate intrest deduction same like bank rule'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  '1 st installment Start date from EMI start Date insted of prorate intrest deduction same like bank rule'  *******/
	 
			/*******  Salary Cycle Employee Wise  *******/
			SET @SETTING_NAME = 'Salary Cycle Employee Wise'
			SET @ALIAS = 'Salary Cycle Employee Wise'
			SET @TOOLTIP = 'To enable employee wise salary cycle option'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Salary Cycle Employee Wise  *******/
	 
	 
			/*******  Salary Records Highlight if no PAN Card Number  *******/
			SET @SETTING_NAME = 'Salary Records Highlight if no PAN Card Number'
			SET @ALIAS = 'Salary Records Highlight if no PAN Card Number'
			SET @TOOLTIP = 'To highlight employee`s row wherein employee`s PAN Card no. is not updated.'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Salary Records Highlight if no PAN Card Number  *******/
	 
	 
			/*******  Salary Records Highlight if Previous Salary on Hold  *******/
			SET @SETTING_NAME = 'Salary Records Highlight if Previous Salary on Hold'
			SET @ALIAS = 'Salary Records Highlight if Previous Salary on Hold'
			SET @TOOLTIP = 'To enable option to highlight employee`s row where previous month salary on hold'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Salary Records Highlight if Previous Salary on Hold  *******/
	 
	 
			/*******  Salary Slip with Password Protected  *******/
			SET @SETTING_NAME = 'Salary Slip with Password Protected'
			SET @ALIAS = 'Salary Slip with Password Protected'
			SET @TOOLTIP = 'To active password protected option to view salary slip'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Salary Slip with Password Protected  *******/
	 
			/*******  Multi Salary Processed  *******/
			SET @SETTING_NAME = 'Multi Salary Processed'
			SET @ALIAS = 'Multi Salary Processed'
			SET @TOOLTIP = 'To active multi salary processed'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Multi Salary Processed  *******/
	 
			/*******  Send Email in Bulk Leave Approval  *******/
			SET @SETTING_NAME = 'Send Email in Bulk Leave Approval'
			SET @ALIAS = 'Send Email in Bulk Leave Approval'
			SET @TOOLTIP = 'To send email notification to employees in case bulk approval for all employee`s leave applications'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Send Email in Bulk Leave Approval  *******/
	 
	 
			/*******  Send Email through SQL Job  *******/
			SET @SETTING_NAME = 'Send Email through SQL Job'
			SET @ALIAS = 'Send Email through SQL Job'
			SET @TOOLTIP = 'To enable option to send email through SQL job'
			SET @GROUP_NAME = 'Email Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Send Email through SQL Job  *******/
	 
	 
			/*******  Send Remainder mail of Increment  *******/
			SET @SETTING_NAME = 'Send Remainder mail of Increment'
			SET @ALIAS = 'Send Remainder mail of Increment'
			SET @TOOLTIP = 'Set days for send remainder mail of increment'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Send Remainder mail of Increment  *******/
	 
			/*******  Employee Referral Days  *******/
			SET @SETTING_NAME = 'Employee Referral bonus paid after days'
			SET @ALIAS = 'Employee Referral bonus paid after days'
			SET @TOOLTIP = 'Set days for employee referral bonus paid after days'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Employee Referral Days  *******/
			
			/*******  Show absent days in salary slip when calculate salary on fix day  *******/
			SET @SETTING_NAME = 'Show absent days in salary slip when calaculate salary on fix day'
			SET @ALIAS = 'Show absent days in salary slip when calculate salary on fix day'
			SET @TOOLTIP = 'To view absent days in salary slip when salary calculate on fix days'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Show absent days in salary slip when calculate salary on fix day  *******/
	 
	 
			/*******  Show Birthday Reminder Group Company wise  *******/
			SET @SETTING_NAME = 'Show Birthday Reminder Group Company wise'
			SET @ALIAS = 'Show Birthday Reminder Group Company wise'
			SET @TOOLTIP = 'To view birthday reminder on dashboard for all group of companies'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Show Birthday Reminder Group Company wise  *******/
	 
	 
			/*******  Show Current Month Attendance Regularization Count On Home Page  *******/
			SET @SETTING_NAME = 'Show Current Month Attendance Regularization Count On Home Page'
			SET @ALIAS = 'Show Current Month Attendance Regularization Count On Home Page'
			SET @TOOLTIP = 'To view only current month attendance regularization pending application count on Dashboard'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Show Current Month Attendance Regularization Count On Home Page  *******/
	 
	 
			/*******  Show Emp Detail at top view (ESS)  *******/
			SET @SETTING_NAME = 'Show Emp Detail at top view(Ess)'
			SET @ALIAS = 'Show Employee Detail at top view (ESS)'
			SET @TOOLTIP = 'To view Employee`s details at top in ESS side'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Show Emp Detail at top view (ESS)  *******/
	 
	 
			/*******  Show Grade wise Salary Textbox in Grade Master  *******/
			SET @SETTING_NAME = 'Show Gradewise Salary Textbox in Grade Master'
			SET @ALIAS = 'Show Grade wise Salary Textbox in Grade Master'
			SET @TOOLTIP = 'To active grade wise salary option in Grade master'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Show Grade wise Salary Textbox in Grade Master  *******/
	 
	 
			/*******  Show Left Employee for Salary  *******/
			SET @SETTING_NAME = 'Show Left Employee for Salary'
			SET @ALIAS = 'Show Left Employee for Salary'
			SET @TOOLTIP = 'To process left employee`s salary while salary generation'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Show Left Employee for Salary  *******/
	 
	 
			/*******  Show list of employees whose PT settings are pending during Salary Process  *******/
			SET @SETTING_NAME = 'Show list of employees whose PT settings are pending during Salary Process'
			SET @ALIAS = 'Show list of employees whose PT settings are pending during Salary Process'
			SET @TOOLTIP = 'To highlight those employee`s list where PT deduction setting has not done in employee master'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Show list of employees whose PT settings are pending during Salary Process  *******/
	 
	 
			/*******  Show Loan Details Grade wise  *******/
			SET @SETTING_NAME = 'Show Loan Details Grade wise'
			SET @ALIAS = 'Show Loan Details Grade wise'
			SET @TOOLTIP = 'To avail grade selection for allocation loan master'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Show Loan Details Grade wise  *******/
	 
	 
			/*******  Show New Joining Details for All Group Company wise on Dashboard  *******/
			SET @SETTING_NAME = 'Show New Joining Details for All Group Company wise on Dashboard'
			SET @ALIAS = 'Show New Joining Details for All Group Company wise on Dashboard'
			SET @TOOLTIP = 'To view all new joinees from group of companies on Dashboard. All employees can view company wise new joinee details'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Show New Joining Details for All Group Company wise on Dashboard  *******/
	 
	 
			/*******  show other Employee leave in leave Approval  *******/
			SET @SETTING_NAME = 'show other Employee leave in leave Approval'
			SET @ALIAS = 'show other Employee leave in leave Approval'
			SET @TOOLTIP = 'To view other employee`s leave details while leave approval.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  show other Employee leave in leave Approval  *******/
	 
	 
			/*******  Show Pass Responsibility in Leave  *******/
			SET @SETTING_NAME = 'Show Pass Responsibility in Leave'
			SET @ALIAS = 'Show Pass Responsibility in Leave'
			SET @TOOLTIP = 'To avail option to pass responsibility option while leave application and approval.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Show Pass Responsibility in Leave  *******/
	 
	 
			/*******  Show Reimbursement Amount in Salary Slip  *******/
			SET @SETTING_NAME = 'Show Reimbursement Amount in Salary Slip'
			SET @ALIAS = 'Show Reimbursement Amount in Salary Slip'
			SET @TOOLTIP = 'To view reimbursement amount in salary slip'
			SET @GROUP_NAME = 'Reports'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Show Reimbursement Amount in Salary Slip  *******/
	 
	 
			/*******  Show Work Anniversary Reminder on Dashboard  *******/
			SET @SETTING_NAME = 'Show Work Anniversary Reminder on Dashboard'
			SET @ALIAS = 'Show Work Anniversary Reminder on Dashboard'
			SET @TOOLTIP = 'To view Employee`s work anniversary details on dashboard.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Show Work Anniversary Reminder on Dashboard  *******/
	 
	 
			/*******  Special Allowance Calculate From Employee Allowance/Deduction Revise  *******/
			SET @SETTING_NAME = 'Special Allowance Calculate From Employee Allowance/Deduction Revise'
			SET @ALIAS = 'Special Allowance Calculate From Employee Allowance/Deduction Revise'
			SET @TOOLTIP = 'To calculate Special allowance from Allowance/Deduction revise form.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Special Allowance Calculate From Employee Allowance/Deduction Revise  *******/
	 
	 
			/*******  State wise minimum wages Calculation  *******/
			SET @SETTING_NAME = 'State wise minimum wages Calculation'
			SET @ALIAS = 'State wise minimum wages Calculation'
			SET @TOOLTIP = 'To avail option for minimum wages in State master'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  State wise minimum wages Calculation  *******/
	 
	 
			/*******  Timesheet Type (Daily or Weekly)  *******/
			SET @SETTING_NAME = 'Timesheet Type (Daily or Weekly)'
			SET @ALIAS = 'Timesheet Type (Daily or Weekly)'
			SET @TOOLTIP = 'To avail weekly base timesheet .Default time sheet would get on daily base'
			SET @GROUP_NAME = 'Timesheet Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='TIMESHEET'
			/*******  Timesheet Type (Daily or Weekly)  *******/
	 
	 
			/*******  Travel Claim Submit Limit  *******/
			SET @SETTING_NAME = 'Travel Claim Submit Limit'
			SET @ALIAS = 'Travel Claim Submit Limit (days)'
			SET @TOOLTIP = 'Travel Claim Submit Limit with Travel Approval Date Ex. 0 means Unlimited Days and 15 means Settlement application apply within 15 days after travel approval date. '
			SET @GROUP_NAME = 'Travel Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Travel Claim Submit Limit  *******/
	 
	 
			/*******  Upper Round for Employer ESIC  *******/
			SET @SETTING_NAME = 'Upper Round for Employer ESIC'
			SET @ALIAS = 'Upper Round for Employer ESIC'
			SET @TOOLTIP = 'To consider upper rounding for employer ESIC'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Upper Round for Employer ESIC  *******/

			/*******  Restrict Self Leave Approval if Admin rights assigned   *******/
			SET @SETTING_NAME = 'Add number of days to apply leave in advance'
			SET @ALIAS = 'Add number of days to apply leave in advance'
			SET @TOOLTIP = 'Employee can apply leave in advance as defined number of days.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"1024"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=180,@MODULE_NAME=NULL
			/*******  Restrict Self Leave Approval if Admin rights assigned   *******/
			
			/*******  Show Comp-off Lapse Notification Ess Side  *******/
			SET @SETTING_NAME = 'Show Comp-off Lapse Notification(ESS)'
			SET @ALIAS = 'Show Comp-off Lapse Notification(ESS)'
			SET @TOOLTIP = 'To view Comp-off Lapse Details in Ess Side.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Show Comp-off Lapse Notification Ess Side  *******/

			--Added By Jaina 07-09-2016
			/*******  Hide Attendance For Fix Salary Employee   *******/
			SET @SETTING_NAME = 'Hide Attendance For Fix Salary Employee'
			SET @ALIAS = 'Hide Attendance For Fix Salary Employee'
			SET @TOOLTIP = 'Hide Attendance For Fix Salary Employee'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Attendance For Fix Salary Employee  *******/
			
			
			--Added By Nimesh 08-11-2016
			/*******  Enable Night Shift Scenario for In Out   *******/
			SET @SETTING_NAME = 'Enable Night Shift Scenario for In Out'
			SET @ALIAS = 'Enable Night Shift Scenario for In Out'
			SET @TOOLTIP = ''
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Night Shift Scenario for In Out  *******/
			--Added by Gadriwala Muslim 13122016
			/*******  AutoGoogleTax IN Travel Module Active/InActive *******/
			SET @SETTING_NAME = 'Auto Google Tax & Map For Training Module'
			SET @ALIAS = 'Auto Google Text & Map For Training Module'
			SET @TOOLTIP = 'To active Auto Google Text & Map For Training Module'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='HRMS'
			/*******  AutoGoogleTax IN Travel Module Active/InActive *******/
			
			--Added By Mukti 08032017
			/*******  Show Designation in Grade Master  *******/
			SET @SETTING_NAME = 'Map Designation with Grade Master'
			SET @ALIAS = 'Map Designation with Grade Master'
			SET @TOOLTIP = 'To add Designation in Grade Master and this setting is applicable for HRMS Appraisal Module'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Show Designation in Grade Master  *******/
			
			
			
			--Added by Jaina 16-03-2017
			/***** Remove the Gap Between Two In-Out Punch from Working Hours ****/
			SET @SETTING_NAME = 'Remove the Gap Between Two In-Out Punch from Working Hours'
			SET @ALIAS = 'Remove the Gap Between Two In-Out Punch from Working Hours'
			SET @TOOLTIP = 'Enter the maximum number of hours to be allowed between two In-Out punches. If the difference between Out and In punch is more than a defined hours then it will be deducted.'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=5,@MODULE_NAME=NULL
			/***** Remove the Gap Between Two In-Out Punch from Working Hours ****/
			
			/*******  InActive User After no of Wrong Login -- Rohit on 27032017 *******/
			SET @SETTING_NAME = 'InActive User After No of wrong Login'
			SET @ALIAS = 'InActive User After No of wrong Login'
			SET @TOOLTIP = 'Add no. of wrong Login limit, Employee would be inactive after that Limit. Ex. 0 means Unlimited login.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  InActive User After no of Wrong Login  *******/
			
			--Added by Jaina 17-04-2017
			/***** Maximum days allowed for leave clubbing ****/
			SET @SETTING_NAME = 'Maximum days allowed for leave clubbing'
			SET @ALIAS = 'Maximum days allowed for leave clubbing'
			SET @TOOLTIP = 'Enter number of days to be allowed for leave clubbing. Enter "0" for no limit.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"50"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/***** Maximum days allowed for leave clubbing ****/
			
			--Added by Rajput 01-05-2017
			/*******  Show Company Name and Address by Effective Datewise  *******/
			SET @SETTING_NAME = 'Enable Effective Date Wise Company Name'
			SET @ALIAS = 'Enable Effective Date Wise Company Name'
			SET @TOOLTIP = 'Allow user to change Company Name and Address Effective Date Wise.It will be affected in all reports and all page headers.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Show Company Name and Address by Effective Datewise End  *******/
			
			--Added by Rajput 06-05-2017	
			/******* Setting For Email Send to Personal EmailID/Official EmailID   *******/
			SET @SETTING_NAME = 'Payslip Send On Personal Email ID'
			SET @ALIAS = 'Payslip Send On Personal Email ID'
			SET @TOOLTIP = 'Set ON for send Payslip on Personal ID and OFF for Official Email ID'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******   Setting For Email Send to Personal EmailID/Official EmailID End *******/
			
			--Added by Jaina 08-08-2017
			/*******  After Salary Overtime Payment Process  *******/
			SET @SETTING_NAME = 'After Salary Overtime Payment Process'
			SET @ALIAS = 'After Salary Overtime Payment Process'
			SET @TOOLTIP = 'After Salary Overtime Payment Process'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  After Salary Overtime Payment Process  *******/
			
			---- Added by Rajput on 20042018 ----
			/*******  Employee Pendings Leave of Last One Month  *******/
			SET @SETTING_NAME = 'Display Pending Leave Application List in Leave Approval'
			SET @ALIAS = 'Display Pending Leave Application List in Leave Approval'
			SET @TOOLTIP = 'Display Employee Pending Leave Application List of Last One Month'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Employee Pendings Leave of Last One Month  *******/
		

			IF EXISTS(SELECT 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Ticket Request Application Escalation hours')
				BEGIN
					DELETE FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Ticket Request Application Escalation hours' 
				END
			
			--SET @SETTING_NAME = 'Ticket Request Application Escalation hours'
			--SET @ALIAS = 'Ticket Request Application Escalation hours'
			--SET @TOOLTIP = 'Ticket Request Application Escalation hours'
			--SET @GROUP_NAME = 'Other Settings'
			--SET @VTYPE = '0'
			--SET @VREF = '{"min":"0","max":"1000"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			
			--Added by Mukti(01092017)
			/******* Setting For Mobile In Out Approval by Manager(start)   *******/
			SET @SETTING_NAME = 'Required Mobile In Out Approval'
			SET @ALIAS = 'Required Mobile In Out Approval'
			SET @TOOLTIP = 'To Synchronize only approved records of Mobile In Out'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/******* Setting For Mobile In Out Approval by Manager(end)   *******/
			
			--Added by Mukti(08092017)start
			SET @SETTING_NAME = 'Advance Leave balance assign from Import Employee'
			SET @ALIAS = 'Advance Leave balance assign from Import Employee'
			SET @TOOLTIP = 'While Importing New Employee with Excel then Auto Leave Credit Days (Prorata) will be assign to Employee (This Setting will apply for only Advance Credit Leaves)'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			--Added by Mukti(08092017)start
			
			-------------added by jimit 09032017---------------------
			/*******  Show From Date And To Date in Leave Carry Forward  *******/
			SET @SETTING_NAME = 'Show Current Year Left Employee in Leave Carry Forward'
			SET @ALIAS = 'Show Current Year Left Employee in Leave Carry Forward'
			SET @TOOLTIP = 'If you On this setting then Current Calendar Year Left Employee will show in Leave Carry Forward else it will show Active Employees'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1024"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL		
			
			/*******  Show From And To Date in Leave Carry Forward  *******/
			
			/*******  Added by Mukti(start)04112017  *******/
			SET @SETTING_NAME = 'Old Reference Code consider as SAP Code'
			SET @ALIAS = 'Old Reference Code consider as SAP Code'
			SET @TOOLTIP = 'Old Reference Code consider as SAP Code'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Added by Mukti(end)04112017  *******/
			
			/*******  Added by Mukti(start)14112017  *******/
			SET @SETTING_NAME = 'Restrict User to Apply Leave if Month is Locked'
			SET @ALIAS = 'Restrict User to Apply Leave if Month is Locked'
			SET @TOOLTIP = 'To Restrict User to Apply Leave if Month is Locked'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Added by Mukti(end)14112017  *******/
			
			/*******   Added by Mukti(start)09012018  *******/
			SET @SETTING_NAME = 'Show Member details Reporting Manager Hierarchy wise'
			SET @ALIAS = 'Show Member details Reporting Manager Hierarchy wise'
			SET @TOOLTIP = 'To Show Member details Reporting Manager Hierarchy wise (N-level)'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******   Added by Mukti(end)09012018  *******/
			
			/*******  Added by Mukti(start)17012018 *******/
			SET @SETTING_NAME = 'Reminder Days for Document Expiry'
			SET @ALIAS = 'Reminder Days for Document Expiry'
			SET @TOOLTIP = 'To Show Reminder for Passport/Visa/Licence Expiry'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Added by Mukti(end)17012018 *******/

			/*******  Restricted Back Date of Joning  *******/
			SET @SETTING_NAME = 'Allowed Backdated Joining upto Days'
			SET @ALIAS = 'Allowed Backdated Joining upto Days'
			SET @TOOLTIP = 'Allowed Backdated Joining upto Days, if values is 0(Zero) than no limit'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			
			/*******  Restricted Back Date of Joning  *******/

			/*******  Restricted on Upload Attachment File   *******/
				SET @SETTING_NAME = 'Attachment Maximum Limit (In MB)'
				SET @ALIAS = 'Attachment Maximum Limit (In MB)'
				SET @TOOLTIP = 'Allowed Maximum Limit, if values is 4 MB than file upload Limit is upto 4MB'
				SET @GROUP_NAME = 'Employee Settings'
				SET @VTYPE = '0'
				SET @VREF = '{"min":"0","max":"100"}'
		 
				EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=4,@MODULE_NAME=NULL
				
			/*******  Restricted on Upload Attachment File  *******/
			
			/*******  Allow Attendance Regularization Editable  *******/
			SET @SETTING_NAME = 'Set Default Shift Timing when Edit In-Out in Attendance Regularize'
			SET @ALIAS = 'Set Default Shift Timing when Edit In-Out in Attendance Regularize'
			SET @TOOLTIP = 'To give privilege to edit in-out time while attendance regularization and set default shift time'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
		 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Allow Attendance Regularization Editable  *******/
			
			/*******  Allow Employee to Regularize the Attendance even In & Out is missing   *******/
			SET @SETTING_NAME = 'Allow Employee to Regularize the Attendance even In & Out is missing'
			SET @ALIAS = 'Employee can regularize the Attendance even In/Out is missing and Attendance is showing Absent Day.'
			SET @TOOLTIP = 'Employee can regularize the Attendance even In/Out is missing and Attendance is showing Absent Day.'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME=NULL
			/*******  Allow Employee to Regularize the Attendance even In & Out is missing   *******/
			
			/*******  Enable Attendance Approval feature in Attendance Regularise Form   *******/
			SET @SETTING_NAME = 'Enable Attendance Approval feature in Attendance Regularise Form'
			SET @ALIAS = 'Employee Request for Attendance Approval from Attendance Regularize.'
			SET @TOOLTIP = 'Enable Attendance Approval feature in Attendance Regularize Form'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
		 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Attendance Approval feature in Attendance Regularise Form   *******/

			--Added By Nimesh On 16-Jul-2018 (This requirement is for Genchi Client)
			/*******  Enter No of Days for Employee Probation Over Reminder Email Scheduler   *******/
			SET @SETTING_NAME = 'Enter No of Days for Employee Probation Over Reminder Email Scheduler'
			SET @ALIAS = 'Enter No of Days for Employee Probation Over Reminder Email Scheduler'
			SET @TOOLTIP = 'Enter No of Days (like 10/15/30) to get Reminder before Employee''s Probation getting over through the Scheduled Email Job. Enter 0 to get default Reminder for 1 month.'
			SET @GROUP_NAME = 'Probation Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"60"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enter No of Days for Employee Probation Over Reminder Email Scheduler   *******/
			
			/*******  Enable Attendance Approval feature in Attendance Regularise Form   *******/
			SET @SETTING_NAME = 'Enable Back Dated Leave As Leave Arrear Days in Next Month Salary'
			SET @ALIAS = 'Enable Back Dated Leave As Leave Arrear Days in Next Month Salary'
			SET @TOOLTIP = 'Enable Back Dated Leave As Leave Arrear Days in Next Month Salary'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
		 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Enable Attendance Approval feature in Attendance Regularise Form   *******/
			
			/*******  Enable Quarterly Reimburstment Process  *******/
			SET @SETTING_NAME = 'Enable Quarterly Reimburstment Process.'
			SET @ALIAS = 'Enable Quarterly Reimbursement Process.'
			SET @TOOLTIP = 'Enable Quarterly Reimbursement Process.'
			SET @GROUP_NAME = 'Reimbursement Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
		 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Quarterly Reimburstment Process   *******/
			
			/*******  Exit Clearance CostCenterWise  *******/
			SET @SETTING_NAME = 'Enable Exit Clearance Process Cost Center Wise'
			SET @ALIAS = 'Enable Exit Clearance Process Cost Center Wise'
			SET @TOOLTIP = 'To enable this feature for Cost Center Wise of Exit Clearance.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Exit Clearance Require  *******/			
			
			/******* Reminder Days for Exit Clearance CostCenterWise  *******/
			SET @SETTING_NAME = 'Reminder Days for Exit Clearance Cost Center Wise'
			SET @ALIAS = 'Reminder Days for Exit Clearance Cost Center Wise'
			SET @TOOLTIP = 'To Show Reminder for Exit Clearance Cost Center Wise'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/******* Reminder Days for Exit Clearance CostCenterWise  *******/
			
			/*******  Reminder days to fill Self Assessment Probation  *******/
			SET @SETTING_NAME = 'Set days to fill Self Assessment Probation Details'
			SET @ALIAS = 'Set days to fill Self Assessment Probation Details'
			SET @TOOLTIP = 'Set days to fill Self Assessment Probation Details'
			SET @GROUP_NAME = 'Probation Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=30,@MODULE_NAME='PAYROLL'
			/*******  Reminder days to fill Self Assessment Probation  *******/
			
			
			/*******  Enable Induction Training Department  *******/
			SET @SETTING_NAME = 'Enable Induction Training Department in Training Type Master'
			SET @ALIAS = 'Enable Induction Training Department in Training Type Master'
			SET @TOOLTIP = 'Enable Induction Training Department in Training Type Master'
			SET @GROUP_NAME = 'Training Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Induction Training Department  *******/


			--Added By Jimit 25102018 -- For Shoft Shipyard Client
			SET @SETTING_NAME = 'Enable Shift Wise Over Time Rate'
			SET @ALIAS = 'Enable Shift Wise Over Time Rate'
			SET @TOOLTIP = 'If you On this setting then Enable WeekDay,WeekOff and Holiday OT Rate option in Shift Master'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL		
			--Ended

			/*By Nimesh on 14-Feb-2019 (Corona and other clients)*/
			SET @SETTING_NAME = 'Sandwich Policy not Applicable if Employee Present on before or after Holiday/WeekOff (QD/HF/3QD)'
			SET @ALIAS = 'Sandwich Policy not Applicable if Employee Present on before or after Holiday/WeekOff (QD/HF/3QD)'
			SET @TOOLTIP = 'If employee takes leave for Half Day before or after Holiday/WeekOff and also has present for atleast 0.25 day then Cancel Holiday/WeekOff Policy (Sandwich Policy) will not be applicable.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'

			/*By Nimesh on 14-Feb-2019 (Shoft Shipyard)*/
			SET @SETTING_NAME = 'Cancel Holiday/WeekOff if Leave applied for given Number of Days (Before Holiday/WeekOff)'
			SET @ALIAS = 'Cancel Holiday/WeekOff if Leave applied for given Number of Days (Before Holiday/WeekOff)'
			SET @TOOLTIP = 'If employee takes leave before Holiday/WeekOff for given number of days or more then Holiday/WeekOff will be cancelled.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"5"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'


			/*By Hardik on 21-Feb-2019 (Havmor)*/
			SET @SETTING_NAME = 'Consider LWP in Same Month for Cutoff Salary'
			SET @ALIAS = 'Consider LWP in Same Month for Cutoff Salary'
			SET @TOOLTIP = 'If Salary Process on Cutoff Base and Consider LWP Leave which are after Cutoff Date in Same Month Salary'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'

			--Added By Nilesh Patel on 29-03-2019
			SET @SETTING_NAME = 'Restrict Entry based on Employee Strength Master'
			SET @ALIAS = 'Restrict Entry based on Employee Strength Master'
			SET @TOOLTIP = 'Restrict New Employee and Recruitment Application based on Employee Strength entered.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'

			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'


			/*******  Enable Probation/Trainee Assessment With Score(Mukti 14062019)  *******/
			SET @SETTING_NAME = 'Enable Probation/Trainee Assessment With Score'
			SET @ALIAS = 'Enable Probation/Trainee Assessment With Score'
			SET @TOOLTIP = 'Enable Probation/Trainee Assessment With Score'
			SET @GROUP_NAME = 'Probation Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Enable Probation/Trainee Assessment With Score  *******/
			
			/*******  Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master (Nilesh On 26-06-2019)  *******/
			SET @SETTING_NAME = 'Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master'
			SET @ALIAS = 'Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master'
			SET @TOOLTIP = 'Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Break Hours not consider in OT Hourly Rate Calculation, if Deduct Break Hour Ticked in Shift Master (Nilesh On 26-06-2019)  *******/
	 
			--Added By Jimit 15102019
			/*******  Hide Previous Month Option in Leave Application and Approval   *******/
			SET @SETTING_NAME = 'Hide Previous Month Option in Leave Application and Approval'
			SET @ALIAS = 'Hide Previous Month Option in Leave Application and Approval'
			SET @TOOLTIP = 'Set 0 - For Normal Condition, 1 - For Hide in Leave Application & Approval (ESS Side), 2 - For Hide in Leave Application & Approval (Admin Side & ESS Side)'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"2"}'
		 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Attendance Approval feature in Attendance Regularise Form   *******/
			---Ended

			--Added By Hardik 03/12/2019 for Cera,  for ODD Shift showing Present
			SET @SETTING_NAME = 'Make Absent if Employee came in Different Shift'
			SET @ALIAS = 'Make Absent if Employee came in Different Shift'
			SET @TOOLTIP = 'If you On this setting then it will give absent if employee came in different shift Else it will give Present evenif employee came in different shift'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'		
			
			/*******  Enable Probation/Trainee Assessment With Score(Mukti 14062019)  *******/
			SET @SETTING_NAME = 'Once Exit Scheme Final Level Approved then consider Employee as Left'
			SET @ALIAS = 'Once Exit Scheme Final Level Approved then consider Employee as Left'
			SET @TOOLTIP = 'Once Exit Scheme Final Level Approved then consider Employee as Left'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Enable Probation/Trainee Assessment With Score  *******/


			--/*******  My team web cam(Prapti 15042021)  *******/
			--SET @SETTING_NAME = 'My team web cam'
			--SET @ALIAS = 'My team web cam'
			--SET @TOOLTIP = 'My team web cam'
			--SET @GROUP_NAME = 'Other Settings'
			--SET @VTYPE = '1'
			--SET @VREF = '{"min":"0","max":"1"}'
	 
			--EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			--/*******  Enable Probation/Trainee Assessment With Score  *******/

			/*Added by Jaina 08-05-2020*/
			/*******  Restrict Weekoff in Monthly Roster, if more than Limit  *******/
			SET @SETTING_NAME = 'Restrict Weekoff in Monthly Roster, if more than Limit'
			SET @ALIAS = 'Restrict Weekoff in Monthly Roster, if more than Limit'
			SET @TOOLTIP = 'If this setting is ON then System will not allow Weekoff more than Limit, If this setting is OFF then it will give alert only'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  Restrict Weekoff in Monthly Roster, if more than Limit  *******/

			/*Added by Hardik 13-05-2020*/
			/*******  PF Calculation on Earning Basic or Actual Basic for Adding Other Allowances, New PF Rule  *******/
			SET @SETTING_NAME = 'PF Limit Check with Earning Basic'
			SET @ALIAS = 'PF Limit Check with Earning Basic'
			SET @TOOLTIP = 'If this setting is ON then System will Check PF Limit with Earning Basic e.g. If Earning Basic is below PF Limit then Add Other Allowances to calculate PF, If this setting is OFF then PF Limit check with Actual Basic'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			/*******  PF Calculation on Earning Basic or Actual Basic for Adding Other Allowances, New PF Rule  *******/

			--Added by Mukti(26062020)start
			SET @SETTING_NAME = 'Send Notification to Mobile, If Policy document added'
			SET @ALIAS = 'Send Notification to Mobile, If Policy document added'
			SET @TOOLTIP = 'To Send Notification to Mobile, If Policy document added through HR portal'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			--Added by Mukti(26062020)end

			/*******  Employee Maximum Age Limit Added by Mukti(09072020)start*******/
			SET @SETTING_NAME = 'Maximum Age Limit for Employee Joining'
			SET @ALIAS = 'Maximum Age Limit for Employee Joining'
			SET @TOOLTIP = 'Enter Maximum Age to restrict Employee during Joining.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=58,@MODULE_NAME=NULL
			/*******   Employee Maximum Age Limit Added by Mukti(09072020)end*******/

			/*******  Calculate Full PF, Evenif Basic is Less than PF Limit,  Added by Hardik 27/07/2020 for GIFT City start*******/
			SET @SETTING_NAME = 'Calculate Full PF, Evenif Basic is Less than PF Limit'
			SET @ALIAS = 'Calculate Full PF, Evenif Basic is Less than PF Limit'
			SET @TOOLTIP = 'When Full PF Applicable to Employee and Basic Salary is Less than the PF Limit and this setting is ON then PF is calculating on Basic + Other Allowance Amount, if it is not on then PF is calculating only on the Basic salary.'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Calculate Full PF, Evenif Basic is Less than PF Limit,  Added by Hardik 27/07/2020 end*******/

			/*******  Restrict OT Approval Hours on Quarterly basis   *******/
			SET @SETTING_NAME = 'Add number of Hours to restrict OT Approval'
			SET @ALIAS = 'Restrict OT Approval Hours on Quarterly basis'
			SET @TOOLTIP = 'Restrict OT Approval Hours on Quarterly basis'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Restrict Self Leave Approval if Admin rights assigned   *******/

			/*******  To Restrict to apply only one type of Expense in Claim Application  *******/
			SET @SETTING_NAME = 'Single Claim Type allow in single Claim Application'
			SET @ALIAS = 'Single Claim Type allow in single Claim Application'
			SET @TOOLTIP = 'Turn on feature to Restrict to apply only one type of Expense in Claim Application'
			SET @GROUP_NAME = 'Claim Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  To Restrict to apply only one type of Expense in Claim Application  *******/

			/*******  Auto Active Mobile User during Employee Creation  *******/
			SET @SETTING_NAME = 'Auto Active Mobile User during Employee Creation'
			SET @ALIAS = 'Auto Active Mobile User during Employee Creation'
			SET @TOOLTIP = 'Turn on feature to Auto Active Mobile User during Employee Creation'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Auto Active Mobile User during Employee Creation  *******/

			/*******  Working Hour should not exceed from Shift Hour in Time sheet  *******/
			SET @SETTING_NAME = 'Working Hour should not exceed from Shift Hour in Time sheet'
			SET @ALIAS = 'Working Hour should not exceed from Shift Hour in Time sheet'
			SET @TOOLTIP = 'Turn on feature to Working Hour should not exceed from Shift Hour in Time sheet'
			SET @GROUP_NAME = 'Timesheet Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Working Hour should not exceed from Shift Hour in Time sheet  *******/

			/*******  Restrict to enter Working Hours on Holiday, Weekoff and Full Day in Time sheet  *******/
			SET @SETTING_NAME = 'Restrict to enter Working Hours on Holiday, Weekoff and Full Day in Time sheet'
			SET @ALIAS = 'Restrict to enter Working Hours on Holiday, Weekoff and Full Day in Time sheet'
			SET @TOOLTIP = 'Turn on feature to Restrict to enter Working Hours on Holiday, Weekoff and Full Day in Time sheet'
			SET @GROUP_NAME = 'Timesheet Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Restrict to enter Working Hours on Holiday, Weekoff and Full Day in Time sheet  *******/
			
			/*******  Added by Mukti(start)24082020 *******/
			SET @SETTING_NAME = 'Reminder Days for Auto Email Recruitment Application Approval'
			SET @ALIAS = 'Reminder Days for Auto Email Recruitment Application Approval'
			SET @TOOLTIP = 'To Send Auto Email(As per scheduler) Recruitment Application Approval'
			SET @GROUP_NAME = 'Recruitment Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"365"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			

			SET @SETTING_NAME = 'Scheme Levelwise attached documents will be shown to Recruitment Requester'
			SET @ALIAS = 'Scheme Levelwise attached documents will be shown to Recruitment Requester'
			SET @TOOLTIP = 'If this setting is ON then documents attached by levelwise manager will be shown to Requester else will not be shown.'
			SET @GROUP_NAME = 'Recruitment Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'
			/*******  Added by Mukti(end)24082020 *******/


			/*******  Enable Backdated Leave If Month is Lock or Salary Exists. (Approved leave no effect on Salary)  *******/
			SET @SETTING_NAME = 'Enable Backdated Leave If Month is Lock or Salary Exists. (Approved leave no effect on Salary)'
			SET @ALIAS = 'Enable Backdated Leave If Month is Lock or Salary Exists. (Approved leave no effect on Salary)'
			SET @TOOLTIP = 'Turn on feature to for backdated leave entry'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Backdated Leave If Month is Lock or Salary Exists. (Approved leave no effect on Salary)  *******/

			/*******  Half Paid Leave Tick in Leave Master / Full Payment Leave Approved then Double Leave Balance Deducted.  *******/
			SET @SETTING_NAME = 'Half Paid Leave Tick in Leave Master / Full Payment Leave Approved then Double Leave Balance Deducted.'
			SET @ALIAS = 'Half Paid Leave Tick in Leave Master / Full Payment Leave Approved then Double Leave Balance Deducted.'
			SET @TOOLTIP = 'Turn on feature to for Half Paid Leave Tick in Leave Master / Full Payment Leave Approved then Double Leave Balance Deducted.'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL

			/*Added by Mr.Mehul on 01062022 */
			SET @SETTING_NAME = 'Comments Mandatory in Leave Approval'
			SET @ALIAS = 'Comments Mandatory in Leave Approval'
			SET @TOOLTIP = 'Restrict User to Approve Leave Without Adding Comments .'
			SET @GROUP_NAME = 'Leave Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME='PAYROLL'
			
			/*******  Added by Niraj for Ticekt Module  Setting (start)20122021 *******/
			SET @SETTING_NAME = 'Hide Escalation Time'
			SET @ALIAS = 'Hide Escaltion Time'
			SET @TOOLTIP = 'Turn on to dispaly esacaltion time in ticket form'
			SET @GROUP_NAME = 'Ticket Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'

			SET @SETTING_NAME = 'Hide Suggestion Box'
			SET @ALIAS = 'Hide Suggestion Box'
			SET @TOOLTIP = 'Set 0 - Hide Suggestion box and 1 - Show Suggestion box and 2 - Show and reuired Suggestion box in feedback form'
			SET @GROUP_NAME = 'Ticket Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"2"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'

			SET @SETTING_NAME = 'Ticket Request Application Escalation hours'
			SET @ALIAS = 'Ticket Request Application Escalation hours'
			SET @TOOLTIP = 'Also you need to create the SQL Job for Ticket Escalation'
			SET @GROUP_NAME = 'Ticket Settings'
			SET @VTYPE = '0'
			SET @VREF = '{"min":"0","max":"24"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=1,@MODULE_NAME='PAYROLL'

			/*******  Added by Niraj for Ticekt Module  Setting (end)20122021 *******/

			/*******  This Months Salary Exists Validation If Salary Geneated..  *******/
			SET @SETTING_NAME = 'This Months Salary Exists Validation If Salary Geneated.'
			SET @ALIAS = 'This Months Salary Exists Validation If Salary Geneated.'
			SET @TOOLTIP = 'Turn on feature to this validation Off.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			
			/*******  This Months Salary Exists Validation If Salary Geneated.****/

			/*******  Hide Employee Name Display in ESS Portal..  *******/
			SET @SETTING_NAME = 'Hide Employee Name Display in ESS Portal.'
			SET @ALIAS = 'Hide Employee Name Display in ESS Portal.'
			SET @TOOLTIP = 'If it is on then it will display only Alpha Emp Code instead of Employee Full Name.'
			SET @GROUP_NAME = 'Employee Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			
			/*******  Hide Employee Name Display in ESS Portal.****/

			/*******   Camera Option For Mobile In/Out  *******/  -- Added By Sajid 05042022
			SET @SETTING_NAME = 'Enable Camera for Mobile user during clock-in clock-out for Mobile Application'
			SET @ALIAS = 'Enable Camera for Mobile user during clock-in clock-out for Mobile Application'
			SET @TOOLTIP = 'Turn on to Enable Camera for Mobile In-Out after Active Mobile User'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******   Camera Option For Mobile In/Out  *******/ -- Added By Sajid 05042022


			/*******   Agrawal OT setting  *******/  -- Added By Ronakk 07022023
			SET @SETTING_NAME = 'Overtime approval based on slab'
			SET @ALIAS = 'Overtime approval based on slab'
			SET @TOOLTIP = 'Overtime approval based on slab'
			SET @GROUP_NAME = 'OT Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Agrawal OT setting  *******/ -- Added By Ronakk 07022023


			/*******  Present on holiday and weekoff calculate on shift master slab wise (added by Mr.Mehul for Sajid bhai's Client CRM on 09052023) *******/
			SET @SETTING_NAME = 'Present On Holiday And Weekoff Calculate On Shift Master Slab Wise.'
			SET @ALIAS = 'Present On Holiday And Weekoff Calculate On Shift Master Slab Wise.'
			SET @TOOLTIP = 'Turn on this setting to calculate weekoff and holiday on shift slab wise.'
			SET @GROUP_NAME = 'Salary Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"100"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Calculate Full PF, Evenif Basic is Less than PF Limit,  Added by Hardik 27/07/2020 end*******/

			
			/*******  Enable Month End Date Selection in Claim  *******/
			SET @SETTING_NAME = 'Enable Month End Date Selection in Claim'
			SET @ALIAS = 'Enable Month End Date Selection in Claim'
			SET @TOOLTIP = 'Turn on this setting to select by default month end date of a month in claim'
			SET @GROUP_NAME = 'Claim Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Month End Date Selection in Claim  *******/
			
			/*******  Enable CItywise Claim Application Selection in Claim  *******/
			SET @SETTING_NAME = 'Enable CItywise Claim Application Selection in Claim'
			SET @ALIAS = 'Enable CItywise Claim Application Selection in Claim'
			SET @TOOLTIP = 'Turn on this setting to select by default CItywise Claim Application in claim'
			SET @GROUP_NAME = 'Claim Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Enable Month End Date Selection in Claim  *******/


			/*******  Hide Home Quick Link in Ess  *******/
			SET @SETTING_NAME = 'Hide Home Quick Link in Ess'
			SET @ALIAS = 'Hide Home Quick Link in Ess'
			SET @TOOLTIP = 'Turn on this setting to hide the quick link in the home page in ess side'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Hide Home Quick Link in Ess  *******/


			--Added by Deepal for Weekoff Odd Even Case 08102023
			/******* Weekoff Odd Even.  *******/
			SET @SETTING_NAME = 'Weekoff Odd Even.'
			SET @ALIAS = 'Weekoff Odd Even.'
			SET @TOOLTIP = 'Turn on to get weekoff odd even.'
			SET @GROUP_NAME = 'Other Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
			
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL

			/*******  Personal Gate Pass Duration Minus in Working Hours  *******/
			SET @SETTING_NAME = 'Personal Gate Pass Duration Minus in Working Hours'
			SET @ALIAS = 'Personal Gate Pass Duration Minus in Working Hours'
			SET @TOOLTIP = 'Personal Gate Pass Duration Minus in Working Hours'
			SET @GROUP_NAME = 'Attendance Settings'
			SET @VTYPE = '1'
			SET @VREF = '{"min":"0","max":"1000"}'
	 
			EXEC P0040_SETTING @CMP_ID=@CMP_ID,@SETTING_NAME=@SETTING_NAME,@ALIAS=@ALIAS,@GROUP_NAME=@GROUP_NAME,@TOOLTIP=@TOOLTIP,@VTYPE=@VTYPE,@VREF=@VREF,@SETTING_VALUE=0,@MODULE_NAME=NULL
			/*******  Personal Gate Pass Duration Minus in Working Hours  *******/

		END
	
		/*************************************** ADMIN SETTINGS ENDS HERE *********************************/
		
		
				
		/**************************  LEAVE SETTINGS STARTS FROM HERE **************************/
		
		BEGIN	--THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION

			IF NOT EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND DEFAULT_SHORT_NAME='LWP')
				BEGIN
					EXEC [P0040_LEAVE_MASTER] 0,@Cmp_ID,'LWP','LWP','--',0,'U',0,0,0,0,0,0,0,0,'None',0,0,'M',0,'Ins',0,1,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'LWP'
				END
			
			IF NOT EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND DEFAULT_SHORT_NAME='COMP')
				BEGIN
					EXEC [P0040_LEAVE_MASTER] 0,@Cmp_ID,'COMP','Comp-Off Leave','--',0,'P',0,0,0,0,0,0,0,0,'None',0,0,'M',0,'Ins',0,0,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'COMP'
				END
			---ADDED BY SUMIT 29092016 FOR DEFAULT LEAVE--------------------------------------------------------------	
			IF NOT EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND DEFAULT_SHORT_NAME='COPH')
				BEGIN
				
					EXEC [P0040_LEAVE_MASTER] 0,@CMP_ID,'COPH','Coph Leave','--',0,'P',0,0,0,0,0,0,0,0,0,0,0,'M',0,'INS',0,0,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'COPH'
				END
				
			IF NOT EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND DEFAULT_SHORT_NAME='COND')
				BEGIN
					EXEC [P0040_LEAVE_MASTER] 0,@CMP_ID,'COND','Cond Leave','--',0,'P',0,0,0,0,0,0,0,0,0,0,0,'M',0,'INS',0,0,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'COND'
				END	
			---ENDED BY SUMIT 29092016 FOR DEFAULT LEAVE--------------------		

			--Alpesh 21-May-2012 -> T0050_Leave_Detail
			DECLARE @Chk_Leave_ID NUMERIC(18,0)
			SET  @Chk_Leave_ID = 0
			SELECT @Chk_Leave_ID = Leave_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Default_Short_Name='COMP'
			IF NOT EXISTS(SELECT 1 FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Leave_ID=@Chk_Leave_ID)
				BEGIN
			
					DECLARE @Leave_ID	NUMERIC(18,0)
					DECLARE @Grd_ID		NUMERIC(18,0)
			    
					DECLARE cur CURSOR FOR SELECT Grd_ID FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID 
					OPEN cur
					FETCH NEXT FROM cur INTO @Grd_ID
			    
					WHILE @@FETCH_STATUS = 0
						BEGIN
							IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name='LWP')
								Begin					
									SELECT @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name='LWP'
									EXEC [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'			
								End 						
							IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP')
								BEGIN	
									SELECT @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP'
									EXEC [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'	
								END 
					
							FETCH NEXT FROM cur INTO @Grd_ID
						END
					CLOSE cur
					DEALLOCATE cur
				END
		END

		/************************** LEAVE SETTINGS ENDS HERE ***********************/	
			


		/*************************************** CAPTIONS SETTINGS STARTS FROM HERE ***************************************/
			
		BEGIN --THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION
			
			DECLARE @Max_Cap_Tranid NUMERIC		--Declared By Ramiz on 12/02/2019, so that we can use single variable and reduce the local variable declaration again and again
			SET @Max_Cap_Tranid = 0
			
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Category')
				BEGIN
					DECLARE @capTran_id numeric
		 			SELECT @capTran_id = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id + 1, @Cmp_ID, N'Category', N'Category', 1,N'Category Master' 
				END	
			ELSE
				BEGIN
					update T0040_CAPTION_SETTING set Remarks = N'Category Master' where Cmp_Id = @Cmp_ID and Caption='Category'
				END
				
				--ADDED BY MR.MEHUL ON 12012023

				if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Skill')
				BEGIN
					DECLARE @capTran_ids numeric
		 			SELECT @capTran_ids = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_ids + 1, @Cmp_ID, N'Skill', N'Skill', 1,N'Skill Master' 
				END	
				ELSE
				BEGIN
					update T0040_CAPTION_SETTING set Remarks = N'Skill Master' where Cmp_Id = @Cmp_ID and Caption='Skill'
				END

				--ADDED BY MR.MEHUL ON 12012023


			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='DBRD Code')
				begin
					declare @capTran_id_DB numeric
		 			select @capTran_id_DB = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capTran_id_DB + 2, @Cmp_ID, N'DBRD Code', N'DBRD Code', 2,N'Employee Master => Salary Details'
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Salary Details' where Cmp_Id = @Cmp_ID and Caption='DBRD Code'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Dealer Code')
				begin
					declare @capTran_id_DE numeric
		 			select @capTran_id_DE = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id_DE + 3, @Cmp_ID, N'Dealer Code', N'Dealer Code', 3,N'Employee Master => Salary Details'
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Salary Details' where Cmp_Id = @Cmp_ID and Caption='Dealer Code'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Branch')
				begin
					declare @capTran_id1 numeric
					select @capTran_id1 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id1 + 1, @Cmp_ID, N'Branch', N'Branch',4 ,N'Branch Master'
							 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Branch Master' where Cmp_Id = @Cmp_ID and Caption='Branch'
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Insurance')
				begin
					declare @capTran_id2 numeric
					select @capTran_id2 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id2 + 1, @Cmp_ID, N'Insurance', N'Insurance',5,N'Insurance Master' 
							 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Insurance Master' where Cmp_Id = @Cmp_ID and Caption='Insurance'
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='InsuranceMenu')
				begin
					declare @capTran_id3 numeric
					select @capTran_id3 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo])
						SELECT @capTran_id3 + 1, @Cmp_ID, N'InsuranceMenu', N'InsuranceMenu',6 
							 
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Policy Type')
				begin
					declare @capTran_id4 numeric
					select @capTran_id4 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id4 + 1, @Cmp_ID, N'Policy Type', N'Policy Type',7,N'Employee Master => Insurance Details' 
				end
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Policy Type'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Company Name')
				begin
					declare @capTran_id5 numeric
					select @capTran_id5 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id5 + 1, @Cmp_ID, N'Company Name', N'Company Name',8,N'Empployee Master => Insurance Details'  
						 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Company Name'
				end		  
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Policy No')
				begin
					declare @capTran_id6 numeric
					select @capTran_id6 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id6 + 1, @Cmp_ID, N'Policy No', N'Policy No',9,N'Empployee Master => Insurance Details'  
							 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Policy No'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Registration Date')
				begin
					declare @capTran_id7 numeric
					select @capTran_id7 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id7 + 1, @Cmp_ID, N'Registration Date', N'Registration Date',10 ,N'Empployee Master => Insurance Details' 
							 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Registration Date'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Due Date')
				begin
					declare @capTran_id8 numeric
					select @capTran_id8 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id8 + 1, @Cmp_ID, N'Due Date', N'Due Date',11,N'Employee Master => Insurance Details'  						 
				End
			else	
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Due Date'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Exp Date')
				begin
						declare @capTran_id9 numeric
						select @capTran_id9 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id9 + 1, @Cmp_ID, N'Exp Date', N'Exp Date',12,N'Empployee Master => Insurance Details'  
				end	
			else	
				begin
						update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Exp Date'
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Insurance Amount')
				begin
					declare @capTran_id10 numeric
					select @capTran_id10 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id10 + 1, @Cmp_ID, N'Insurance Amount', N'Insurance Amount',13,N'Empployee Master => Insurance Details'  						 
				end
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Insurance Amount'
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Annual Amount')
				begin
					declare @capTran_id11 numeric
					select @capTran_id11 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id11 + 1, @Cmp_ID, N'Annual Amount', N'Annual Amount',14,N'Empployee Master => Insurance Details'  
							 
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Annual Amount'
				end
					-------------------------------Gadriwala Muslim on 19-7-2013--------------------------
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Business Segment')
				begin
					declare @capTran_id12 numeric
					select @capTran_id12 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id12 + 1, @Cmp_ID, N'Business Segment', N'Business Segment',15,N'Business Segment Master'						 
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Vertical')
				begin
					declare @capTran_id13 numeric
					select @capTran_id13 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id13 + 1, @Cmp_ID, N'Vertical', N'Vertical',16,N'Vertical Master'
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='SubVertical')
				begin
					declare @capTran_id14 numeric
					select @capTran_id14 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id14 + 1, @Cmp_ID, N'SubVertical', N'SubVertical',17,N'SubVertical Master'						 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='subBranch')
				begin
					declare @capTran_id15 numeric
					select @capTran_id15 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id15 + 1, @Cmp_ID, N'subBranch', N'Sub Branch',18,N'Sub Branch Master'
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Exit')
				begin
					declare @capTran_id16 numeric
					select @capTran_id16 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id16 + 1, @Cmp_ID, N'Exit', N'Exit',18,N'Exit'
							 
				end
			--Added by Gadriwala 10012014 - Start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Direct Reporters')
				begin
					declare @capTran_id17 numeric
					select @capTran_id17 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id17 + 1, @Cmp_ID, N'Direct Reporters', N'Direct Reporters',19,N'Employee => Direct Reporters'  
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Indirect Reporters')
				begin
					declare @capTran_id18 numeric
					select @capTran_id18 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id18 + 1, @Cmp_ID, N'Indirect Reporters', N'Indirect Reporters',19,N'Employee => Indirect Reporters'  
							 
				end
			--Added by Gadriwala 10012014 - End
			--sneha on 1 apr 2014
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='No Of Accidents')
				begin
					declare @capTran_id19 numeric
					select @capTran_id19 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id19 + 1, @Cmp_ID, N'No Of Accidents', N'No Of Accidents',19,N'No Of Accidents'  
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='No Of Person Involved')
				begin
					declare @capTran_id20 numeric
					select @capTran_id20 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id20 + 1, @Cmp_ID, N'No Of Person Involved', N'No Of Person Involved',19,N'No Of Person Involved'  
							 
				end
			--sneha on 1 apr 2014
				
			-- Added By Ali 01042014 -- Start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Canteen Code')
				begin
					declare @capTran_id21 numeric
					select @capTran_id21 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id21 + 1, @Cmp_ID, N'Canteen Code', N'Canteen Code',21,N'Employee => Canteen Code'  
							 
				end
			-- Added By Ali 01042014 -- End
			--sneha on 3 apr 2014
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Title')
				begin
					declare @capTran_id22 numeric
					select @capTran_id22 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id22 + 1, @Cmp_ID, N'Title', N'Title',22,N'Title'  
							 
				end
			--sneha end on 3 apr 2014
				
			--Added By Gadriwala Muslim 15072014 - Start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Reporting Manager')
				begin
					declare @capTran_id23 numeric
					select @capTran_id23 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id23 + 1, @Cmp_ID, N'Reporting Manager', N'Reporting Manager',23,N'Reporting Manager'  
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Grade')
				begin
					declare @capTran_id24 numeric
					select @capTran_id24 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id24 + 1, @Cmp_ID, N'Grade', N'Grade',24,N'Grade'  
							 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tehsil')
				begin
					declare @capTran_id25 numeric
					select @capTran_id25 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id25 + 1, @Cmp_ID, N'Tehsil', N'Tehsil',25,N'Tehsil'  
							 
				end
			Else
				begin
					update T0040_CAPTION_SETTING --Added by Sumit 29062015
					set Alias='Taluka'				
					where caption='Tehsil' and Cmp_Id=@Cmp_ID
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Thana')
				begin
					declare @capTran_id26 numeric
					select @capTran_id26 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id26 + 1, @Cmp_ID, N'Thana', N'Thana',26,N'Thana'  
							 
				end
			Else
				begin
					update T0040_CAPTION_SETTING --Added by Sumit 29062015
					set Alias='Police Station'						
					where caption='Thana' and Cmp_Id=@Cmp_ID
				end
			--Added By Gadriwala Muslim 15072014 - End
			--added by sneha on 27 Feb 2015 - start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Main KPI')
				begin
					declare @capTran_id27 numeric
					select @capTran_id27 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id27 + 1, @Cmp_ID, N'Main KPI', N'Main KPI',27,N'Main KPI'  
								 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Sub KPI')
				begin
					declare @capTran_id28 numeric
					select @capTran_id28 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id28 + 1, @Cmp_ID, N'Sub KPI', N'Sub KPI',28,N'Sub KPI'  
								 
				end
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='KPI Attributes')
				begin
					declare @capTran_id29 numeric
					select @capTran_id29 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id29 + 1, @Cmp_ID, N'KPI Attributes', N'KPI Attributes',29,N'KPI Attributes'  
								 
				end
			--added by sneha on 27 Feb 2015 - end
			--added by sneha on 23 Apr 2015 - start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Objectives')
				begin
					declare @capTran_id30 numeric
					select @capTran_id30 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id30 + 1, @Cmp_ID, N'Objectives', N'Objectives',30,N'Objectives'  
								 
				end
			--added by sneha on 23 Apr 2015 - end
				
			--added by jaina on 10-08-2015 start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Employee Type')
				begin
					declare @capTran_id31 numeric
					select @capTran_id31 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id31 + 1, @Cmp_ID, N'Employee Type', N'Employee Type',31 ,N'Employee Type'
						
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Employee Type' where Cmp_Id = @Cmp_ID and Caption='Employee Type'
				end	
			--added by jaina on 10-08-2015 end
			--Added By Ramiz on 27/11/2015
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tally Ledger Name')
				begin
					declare @capTran_id32 numeric
					select @capTran_id32 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id32 + 1, @Cmp_ID, N'Tally Ledger Name', N'Tally Ledger Name',32 ,N'Tally Ledger Name'
						
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Tally Ledger Name' where Cmp_Id = @Cmp_ID and Caption='Tally Ledger Name'
				end	
			--Added By Ramiz on 27/11/2015	
			--added By jimit 03082016
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Gate Pass')
				begin
					declare @capTran_id33 numeric
					select @capTran_id33 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id33 + 1, @Cmp_ID, N'Gate Pass', N'Gate Pass',33 ,N'Gate Pass'
							
				end	
			else
				begin
					update T0040_CAPTION_SETTING set Remarks = N'Gate Pass' where Cmp_Id = @Cmp_ID and Caption='Gate Pass'
				end
			--ended
			--Added By Mukti(21072016)start
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='KPA')
				begin
						declare @capTranEmail_id86 numeric
						select @capTranEmail_id86 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTranEmail_id86 + 1, @Cmp_ID, N'KPA', N'KPA',86,N'KPA'						 
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Target')
				begin
						declare @capTranEmail_id87 numeric
						select @capTranEmail_id87 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTranEmail_id87 + 1, @Cmp_ID, N'Target', N'Target',87,N'Target'						 
				end
				
			--This Query of Spelling Correction is Added By Ramiz on 31/03/2017. 
			--As It was Inserting Duplicate Entry one with Correct Spelling and Other with Incorrect Spelling.	
			IF EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION ='Perfomance Attribute')
				BEGIN
					IF EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION ='Performance Attribute')
						BEGIN
							DELETE from T0040_CAPTION_SETTING WHERE Caption='Perfomance Attribute'
						END
					ELSE
						BEGIN
							UPDATE T0040_CAPTION_SETTING Set Caption = 'Performance Attribute' where Caption = 'Perfomance Attribute'	
						END
				END
			--Query Ends Here. . .
				
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Performance Attribute')
				begin
						declare @capTranEmail_id88 numeric
						select @capTranEmail_id88 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTranEmail_id88 + 1, @Cmp_ID, N'Performance Attribute', N'Performance Attribute',88,N'Performance Attribute'
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Potential Attribute')
				begin
						declare @capTranEmail_id89 numeric 
						select @capTranEmail_id89 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTranEmail_id89 + 1, @Cmp_ID, N'Potential Attribute', N'Potential Attribute',89,N'Potential Attribute'
				end	
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Justification for High Score')
				begin
					declare @capTranEmail_id90 numeric
					select @capTranEmail_id90 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id90 + 1, @Cmp_ID, N'Justification for High Score', N'Justification for High Score',90,N'Justification for High Score'
				end		
			--Added By Mukti(21072016)end
			--Added By Ramiz on 11/08/2016
			if not exists (select Tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='AX Mapping')
				BEGIN
					Declare @Cap_AX91 numeric
					Select @Cap_AX91 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @Cap_AX91, @Cmp_ID, N'AX Mapping', N'AX Mapping',91,N'AX Mapping'
				END		
			--Ended By Ramiz on 11/08/2016
			--Added By Mukti on 30/08/2016 for Appraisal caption
			if not exists (select Tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Criteria')
				BEGIN
					Declare @capTranEmail_id92 numeric
					Select @capTranEmail_id92 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capTranEmail_id92, @Cmp_ID, N'Criteria', N'Criteria',92,N'Criteria'
				END		
			--Ended By Mukti on 30/08/2016
			--Added By Jaina 03-09-2016 Start
			if not exists (select Tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Optional Holiday')
				BEGIN
					Declare @Cap_AX93 numeric
					Select @Cap_AX93 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @Cap_AX93, @Cmp_ID, N'Optional Holiday', N'Optional Holiday',93,N'Optional Holiday'
				END		
			--Added By Jaina 03-09-2016 End
			--Added By Jaina 06-09-2016 Start
			if not exists (select Tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Fix Salary')
				BEGIN
					Declare @Cap_AX94 numeric
					Select @Cap_AX94 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @Cap_AX94, @Cmp_ID, N'Fix Salary', N'Fix Salary',94,N'Fix Salary'
				END	
			--Added By Jaina 06-09-2016 End
			--Added By Mukti on 29/09/2016 for Appraisal caption(start)
			if not exists (select Tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Appraiser Comments')
				BEGIN
					Declare @capAppraisal_id95 numeric
					Select @capAppraisal_id95 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capAppraisal_id95, @Cmp_ID, N'Appraiser Comments', N'Appraiser Comments',95,N'Appraiser Comments'
				END		
			--Ended By Mukti on 29/09/2016 for Appraisal caption(end)
			
			--ADDED BY RAMIZ ON 30/03/2017 --(SALES CAPTION WORK)--START
			DECLARE @capSales NUMERIC		--NO NEED TO DECLARE MULTIPLE VARIABLES , WHEN YOU CAN REUSE THE SAME
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='Sales Code')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capSales, @Cmp_ID, N'Sales Code', N'Sales Code',96,N'Sales Code'
				END
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='Sales Target')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capSales, @Cmp_ID, N'Sales Target', N'Sales Target',97,N'Sales Target'
				END	
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='Sales Route Master')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capSales, @Cmp_ID, N'Sales Route Master', N'Sales Route Master',98,N'Sales Route Master'
				END	
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='Sales Week Master')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capSales, @Cmp_ID, N'Sales Week Master', N'Sales Week Master',99,N'Sales Week Master'
				END	
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='Sales Assigned Target')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
					SELECT @capSales, @Cmp_ID, N'Sales Assigned Target', N'Sales Assigned Target',100,N'Sales Assigned Target'
				END		
			--(SALES CAPTION WORK)--END
			---added on 28/08/2017--sneha--start
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK)  WHERE CMP_ID = @CMP_ID AND CAPTION='Group Head/GH')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],[Module_Name],[Group_By])
					SELECT @capSales, @Cmp_ID, N'Group Head/GH', N'Group Head',101,N'Appraisal => Group Head/GH','HRMS','Appraisal'
				END
			IF NOT EXISTS (SELECT TRAN_ID FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND CAPTION='HOD')
				BEGIN
					SELECT @capSales = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],[Module_Name],[Group_By])
					SELECT @capSales, @Cmp_ID, N'HOD', N'HOD',102,N'Appraisal => HOD','HRMS','Appraisal'
				END		
			---added on 28/08/2017--sneha--end
			
			--Added by Mukti(start)06112017
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Old Reference Code')
				begin
					declare @capTran_id_refcode numeric
		 			select @capTran_id_refcode = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],[Module_Name],[Group_By])
					SELECT @capTran_id_refcode + 1, @Cmp_ID, N'Old Reference Code', N'Old Reference Code1', 103,N'Employee Master => Salary Details','PAYROLL','Employee Master'
				end			
			--Added by Mukti(end)06112017
			
			--Added by Mukti(start)02012018
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Bank Branch Name')
				begin
					declare @capTran_id_bankbranch numeric
		 			select @capTran_id_bankbranch = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],[Module_Name],[Group_By],Is_Hidden)
					SELECT @capTran_id_bankbranch + 1, @Cmp_ID, N'Bank Branch Name', N'Bank Branch Name', 103,N'Employee Master => Report Details','PAYROLL','Employee Master',1
				end			
			--Added by Mukti(end)02012018
			
			--Added by Mukti(start)16032018
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Performance Feedback')
				begin
					declare @capTranEmail_id91 numeric
					select @capTranEmail_id91 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capTranEmail_id91 + 1, @Cmp_ID, N'Performance Feedback', N'Performance Feedback',104,N'Performance Feedback','HRMS','Appraisal',N'Performance Feedback',0
				end		
			--Added by Mukti(start)16032018
			
			--Added by Mukti(start)30072018
				if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Cost Center')
				begin
					declare @Cap_Cost_Center numeric
					select @Cap_Cost_Center = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
				INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
				SELECT @Cap_Cost_Center + 1, @Cmp_ID, N'Cost Center', N'Cost Center',105,N'Master => Cost Center','Payroll','Master','Cost Center',0
						 
				end
			--Added by Mukti(end)30072018	
			
			
			---- ADDED BY RAJPUT ON 14112018 ----
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Bond')
				begin
	
					DECLARE @BOND_ID NUMERIC
					SELECT @BOND_ID = ISNULL(MAX(TRAN_ID),0) FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @BOND_ID + 1, @Cmp_ID, N'Bond', N'Bond',106,N'Bond => Bond','Payroll','Bond','Bond'
				end
				
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Bond Master')
				begin
	
					DECLARE @BOND_MID NUMERIC
					SELECT @BOND_MID = ISNULL(MAX(TRAN_ID),0) FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @BOND_MID + 1, @Cmp_ID, N'Bond Master', N'Bond Master',106,N'Bond Master => Bond Master','Payroll','Bond','Bond Master'
				end
				
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Admin Bond Approval')
				begin
	
					DECLARE @BOND_AID NUMERIC
					SELECT @BOND_AID = ISNULL(MAX(TRAN_ID),0) FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @BOND_AID + 1, @Cmp_ID, N'Admin Bond Approval', N'Admin Bond Approval',106,N'Admin Bond Approval => Admin Bond Approval','Payroll','Bond','Admin Bond Approval'
				end
			----- END -----
			
			---- ADDED BY RAJPUT ON 28112018 ----
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Assign Vertical & Sub-Vertical')
				begin
					
					DECLARE @AtranID NUMERIC
					SELECT @AtranID = ISNULL(MAX(TRAN_ID),0) FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @AtranID + 1, @Cmp_ID, N'Assign Vertical & Sub-Vertical', N'Assign Vertical & Sub-Vertical',107,N'Employee Master => Assign Vertical & Sub-Vertical','Payroll','Employee Master','Assign Vertical & Sub-Vertical'
				end
			----- END -----
			
						---- ADDED BY RAMIZ ON 12/02/2019 ----
			IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Work Phone No')
				BEGIN
					SET @Max_Cap_Tranid = 0
					SELECT @Max_Cap_Tranid = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @Max_Cap_Tranid , @Cmp_ID, N'Work Phone No', N'Work Phone No',107,N'Employee Master => Work Phone No','Payroll','Employee Master','Work Phone No'
				END
			
			IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Personal Phone No')
				BEGIN
					SET @Max_Cap_Tranid = 0
					SELECT @Max_Cap_Tranid = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @Max_Cap_Tranid , @Cmp_ID, N'Personal Phone No', N'Personal Phone No',107,N'Employee Master => Personal Phone No','Payroll','Employee Master','Personal Phone No'
				END
				
			IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Extension No')
				BEGIN
					SET @Max_Cap_Tranid = 0
					SELECT @Max_Cap_Tranid = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode)
					SELECT @Max_Cap_Tranid , @Cmp_ID, N'Extension No', N'Extension No',107,N'Employee Master => Extension No','Payroll','Employee Master','Extension No'
				END
			----- END -----
			
			--Added by Mukti(start)10052019
			if not exists (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='KPA Type')
				begin
					declare @capKPAType numeric
					select @capKPAType = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capKPAType + 1, @Cmp_ID, N'KPA Type', N'KPA Type',104,N'KPA Type','HRMS','Appraisal',N'KPA Type',0
				end		
			--Added by Mukti(start)10052019

			
			--Added by Mehul 16022022
				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tour Agenda Planned')
				BEGIN
					declare @capTourPlanned numeric
					select @capTourPlanned = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capTourPlanned , @Cmp_ID, N'Tour Agenda Planned', N'Tour Agenda Planned',111,N'Travel  => Tour Agenda Planned','Payroll','Travel','Tour Agenda Planned',0
				END

				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Business Appointment Planned')
				BEGIN
					declare @capBusinessPlanned numeric
					select @capBusinessPlanned = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capBusinessPlanned , @Cmp_ID, N'Business Appointment Planned', N'Business Appointment Planned',112,N'Travel  => Business Appointment Planned','Payroll','Travel','Business Appointment Planned',0
				END

				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tour Appointment Planned')
				BEGIN
					declare @capTourAppPlanned numeric
					select @capTourAppPlanned = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capTourAppPlanned , @Cmp_ID, N'Tour Appointment Planned', N'Tour Appointment Planned',113,N'Travel  => Tour Appointment Planned','Payroll','Travel','Tour Appointment Planned',0
				END

				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tour Agenda Actual')
				BEGIN
					declare @capTourActual numeric
					select @capTourActual = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capTourActual , @Cmp_ID, N'Tour Agenda Actual', N'Tour Agenda Actual',114,N'Travel  => Tour Agenda Actual','Payroll','Travel','Tour Agenda Actual',0
				END

				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Business Appointment Actual')
				BEGIN
					declare @capBusinessActual numeric
					select @capBusinessActual = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capBusinessActual , @Cmp_ID, N'Business Appointment Actual', N'Business Appointment Actual',115,N'Travel  => Business Appointment Actual','Payroll','Travel','Business Appointment Actual',0
				END

				IF NOT EXISTS (select tran_id from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Caption='Tour Appointment Actual')
				BEGIN
					declare @capTourAppActual numeric
					select @capTourAppActual = isnull(MAX(tran_id),0) + 1 from T0040_CAPTION_SETTING WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]
						([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks],Module_Name,Group_BY,CaptionCode,Is_Hidden)
					SELECT @capTourAppActual , @Cmp_ID, N'Tour Appointment Actual', N'Tour Appointment Actual',116,N'Travel  => Tour Appointment Actual','Payroll','Travel','Tour Appointment Actual',0
				END

				--Added by Mehul 16022022

			/******************* PLEASE READ THIS IF YOU ARE ADDING ANY CAPTION ***( ADDED BY RAMIZ) ***********************
				
				AFTER ADDING ANY NEW CAPTION IN THIS SP, YOU NEED TO ADD THE SAME IN "Update_CAPTION_SETTING (SP)"; 
				IN THAT WE ARE ADDING "MODULE_NAME" AND "GROUP_BY"
				
				NEXT MAX SORTING NUMBER 
				FOR CAPTION SETTING WILL BE : 101 
				[AS WE HAD SOME GAP IN SORTING NUMBER AFTER 33, NOW WE WILL CONTINUE WITH THIS ONLY.
				
			*******************************************/
		
		END
			
		/**************************************************** CAPTIONS SETTINGS ENDS HERE ********************************/



		/*************************************** EMAIL NOTIFICATION SETTINGS STARTS HERE *********************************/

		BEGIN	--THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION

			If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization')
				Begin
					If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz')
						Begin
							Delete From T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz'
						End
				End
						
			If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz')
				Begin
					Update T0040_Email_Notification_Config Set EMAIL_TYPE_NAME = 'Attendance Regularization' where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz'
				End
			
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Settlement Approval')
				begin
					declare @capTranEmail2_id1 numeric
					select @capTranEmail2_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail2_id1+1, @Cmp_ID, N'Travel Settlement Approval', 0, 25, 0, 0, 0, N'' 
								
				end
			else
				begin
					UPDATE T0040_Email_Notification_Config SET  EMAIL_NTF_DEF_ID = 25 where EMAIL_TYPE_NAME = 'Travel Settlement Approval' and cmp_id = @cmp_id						
					delete T0040_Email_Notification_Config  where EMAIL_TYPE_NAME = 'Travel Settelment Approval' and cmp_id = @cmp_id						
				end
							
			--ALTER By Paras 20-09-2012
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Leave Application')
				begin
					declare @capTranEmail_id1 numeric
					select @capTranEmail_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail_id1+1, @Cmp_ID, N'Leave Application', 0, 2, 0, 0, 0, N'' 
								
				end
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Leave Approval')
				begin
					declare @capTranEmail_id2 numeric
					select @capTranEmail_id2 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id2 + 1, @Cmp_ID, N'Leave Approval', 0, 3, 0, 0, 0, N''
								
				end	
						
			-- Added By Gadriwala 17042014
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Cancel Leave Application')
				begin
					declare @capTranEmail_id23 numeric
					select @capTranEmail_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail_id1+1, @Cmp_ID, N'Cancel Leave Application', 0, 39, 0, 0, 0, N'' 
								
				end
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Cancel Leave Approval')
				begin
					declare @capTranEmail_id24 numeric
					select @capTranEmail_id2 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id2 + 1, @Cmp_ID, N'Cancel Leave Approval', 0, 40, 0, 0, 0, N''
								
				end	
				-- Added By Gadriwala 17042014
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Application')
				begin
					declare @capTranEmail_id3 numeric
					select @capTranEmail_id3 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id3 + 1, @Cmp_ID, N'Loan Application', 0, 4, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Approval')
				begin
					declare @capTranEmail_id4 numeric
					select @capTranEmail_id4 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id4 + 1, @Cmp_ID, N'Loan Approval', 0, 5, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Payment')
				begin
					declare @capTranEmail_id5 numeric
					select @capTranEmail_id5 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id5 + 1, @Cmp_ID, N'Loan Payment', 0, 6, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Appraisal Initiation')
				begin
					declare @capTranEmail_id6 numeric
					select @capTranEmail_id6 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id6 + 1, @Cmp_ID, N'Appraisal Initiation', 0, 7, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Approval')
				begin
					declare @capTranEmail_id7 numeric
					select @capTranEmail_id7 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id7 + 1, @Cmp_ID,N'Claim Approval', 0, 8, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Payment')
				begin
					declare @capTranEmail_id8 numeric
					select @capTranEmail_id8 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id8 + 1, @Cmp_ID,N'Claim Payment', 0, 9, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Application')
				begin
					declare @capTranEmail_id9 numeric
					select @capTranEmail_id9 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id9 + 1, @Cmp_ID,N'Claim Application', 0, 10, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Appraisal Approval')
				begin
					declare @capTranEmail_id10 numeric
					select @capTranEmail_id10 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id10 + 1, @Cmp_ID,N'Appraisal Approval', 0, 11, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Approval')
				begin
					declare @capTranEmail_id11 numeric
					select @capTranEmail_id11 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id11 + 1, @Cmp_ID, N'Recruitment Approval', 0, 12, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Interview Schedule')
				begin
					declare @capTranEmail_id12 numeric
					select @capTranEmail_id12 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id12 + 1, @Cmp_ID,N'Interview Schedule', 0, 13, 0, 0, 0, N''
								
				end	
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Forget Password')
				begin
					declare @capTranEmail_id13 numeric
					select @capTranEmail_id13 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id13 + 1, @Cmp_ID,N'Forget Password', 0, 15, 0, 0, 0, N''
								
				end	
				
			-- Added By Hiral Start 10102012
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Application')
				begin
					declare @capTranEmail_id14 numeric
					select @capTranEmail_id14 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id14 + 1, @Cmp_ID,N'Travel Application', 0, 16, 0, 0, 0, N''
								
				end
			-- Added By Hiral End 10102012			
			-- Added By Hiral Start 15102012
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Comp-Off Application')
				begin
					declare @capTranEmail_id15 numeric
					select @capTranEmail_id15 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id15 + 1, @Cmp_ID,N'Comp-Off Application', 0, 17, 0, 0, 0, N''
				end
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Comp-Off Approval')
				begin
					declare @capTranEmail_id16 numeric
					select @capTranEmail_id16 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id16 + 1, @Cmp_ID,N'Comp-Off Approval', 0, 18, 0, 0, 0, N''
				end
			-- Added By Hiral End 15102012		
			-- Added By Hiral Start 16102012
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization')
				begin
					declare @capTranEmail_id17 numeric
					select @capTranEmail_id17 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id17 + 1, @Cmp_ID,N'Attendance Regularization', 0, 19, 0, 0, 0, N''
				end
						
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Employee Probation')
				begin
					declare @capTranEmail_id18 numeric
					select @capTranEmail_id18 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id18 + 1, @Cmp_ID,N'Employee Probation', 0, 20, 0, 0, 0, N''
				end
			-- Added By Hiral End 16102012
			----Training -- Ankit 06042016
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Employee Training')
				BEGIN
					set @capTranEmail_id18 = 0
					SELECT @capTranEmail_id18 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id18 + 1, @Cmp_ID,N'Employee Training', 0, 20, 0, 0, 0, N''
				END
						
			-- Added By Hiral Start 08112012
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Exit Application')
				begin
					declare @capTranEmail_id19 numeric
					select @capTranEmail_id19 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id19 + 1, @Cmp_ID,N'Exit Application', 0, 21, 0, 0, 0, N''
				end
			-- Added By Hiral End 08112012
			-- Added by rohit for Attendance regularization approve on 25022013.
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization Approve')
				begin
					declare @capTranEmail_id20 numeric
					select @capTranEmail_id20 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id20 + 1, @Cmp_ID,N'Attendance Regularization Approve', 0, 22, 0, 0, 0, N''
				end

			-- ended by rohit on 25022013
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Birth Day')
				begin
					declare @capTranEmail_id21 numeric
					select @capTranEmail_id21 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id21 + 1, @Cmp_ID,N'Birth Day', 0, 23, 0, 0, 0, N''
				end
			
			-- ended by rohit on 25022013
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Settlement Application')
				begin
					declare @capTranEmail_id22 numeric
					select @capTranEmail_id22 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail_id22+1, @Cmp_ID, N'Travel Settlement Application', 0, 24, 0, 0, 0, N'' 
								
				end
			
			-- Added By Nilesh Start 0501215
			Delete from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Application' AND EMAIL_NTF_DEF_ID = 20
			Delete from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Approval' AND EMAIL_NTF_DEF_ID = 20
			
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Application')
				begin
					declare @capTranEmail_id30 numeric
					select @capTranEmail_id30 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id30 + 1, @Cmp_ID,N'Change Request Application', 0, 77, 0, 0, 0, N''
				end
				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Approval')
				begin
					declare @capTranEmail_id31 numeric
					select @capTranEmail_id31 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id31 + 1, @Cmp_ID,N'Change Request Approval', 0, 78, 0, 0, 0, N''
				end
			-- Added By Nilesh End 0501215
			---------------------------------------------------------- Prakash Patel 27012015 -----------------------------------------------------------------------------------
			declare @EmailNotification_ID numeric
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Timesheet Application')
				begin
					select @EmailNotification_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID],[Cmp_Id],[EMAIL_TYPE_NAME],[EMAIL_NTF_SENT],[EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @EmailNotification_ID + 1, @Cmp_ID, N'Timesheet Application', 0, 62, 0, 0, 0, N'' 
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Timesheet Approval')
				begin
					select @EmailNotification_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @EmailNotification_ID + 1, @Cmp_ID, N'Timesheet Approval', 0, 63, 0, 0, 0, N'' 
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Work Anniversary')
				begin
					declare @capTranEmail_id25 numeric
					select @capTranEmail_id25 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id25 + 1, @Cmp_ID,N'Work Anniversary', 0, 64, 0, 0, 0, N''
				end

		  ---added by jimit  14112016 for Employee Increment Application mail
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Employee Increment Application')
				begin
					declare @capTranEmail_id96 numeric
					select @capTranEmail_id96 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id96 + 1, @Cmp_ID,N'Employee Increment Application', 0, 89, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Employee Increment Approval')
				begin
					declare @capTranEmail_id97 numeric
					select @capTranEmail_id97 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id97 + 1, @Cmp_ID,N'Employee Increment Approval', 0, 90, 0, 0, 0, N''
				end
			---- Added by rohit For Claim Reimbersment Application on 24102013
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Reimbursement\Claim Application')
			begin
					declare @capTranEmail_id26 numeric
					select @capTranEmail_id26 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail_id26+1, @Cmp_ID, N'Reimbursement\Claim Application', 0, 26, 0, 0, 0, N'' 
					
			end
			----Ended by rohit on 24102013
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Reimbursement\Claim Approval')
			begin
					declare @capTranEmail_id27 numeric
					select @capTranEmail_id27 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT  @capTranEmail_id27+1, @Cmp_ID, N'Reimbursement\Claim Approval', 0, 27, 0, 0, 0, N'' 
					
			end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Auto Mail of Probation Over')
				begin
					declare @capTranEmail_id28 numeric
					select @capTranEmail_id28 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id28 + 1, @Cmp_ID,N'Auto Mail of Probation Over', 0, 28, 0, 0, 0, N''
				end			
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Auto Carry forward Intimation')
				begin
					declare @capTranEmail_id29 numeric
					select @capTranEmail_id29 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id29 + 1, @Cmp_ID,N'Auto Carry forward Intimation', 0, 29, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Self Assessment')
				begin
					declare @capTranEmail_id510 numeric
					select @capTranEmail_id510 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id510 + 1, @Cmp_ID,N'Self Assessment', 0, 30, 0, 0, 0, N''
				end				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Approval')
				begin
					declare @capTranEmail_id520 numeric
					select @capTranEmail_id520 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id520 + 1, @Cmp_ID,N'SelfAssessment Approval', 0, 31, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Review')
				begin
					declare @capTranEmail_id32 numeric
					select @capTranEmail_id32 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id32 + 1, @Cmp_ID,N'SelfAssessment Review', 0, 32, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Approved')
				begin
					declare @capTranEmail_id33 numeric
					select @capTranEmail_id33 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id33 + 1, @Cmp_ID,N'SelfAssessment Approved', 0, 33, 0, 0, 0, N''
				end		
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Allocation')
				begin
					declare @capTranEmail_id34 numeric
					select @capTranEmail_id34 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id34 + 1, @Cmp_ID,N'PerformanceAssessment Allocation', 0, 34, 0, 0, 0, N''
				end		
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Review')
				begin
					declare @capTranEmail_id35 numeric
					select @capTranEmail_id35 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id35 + 1, @Cmp_ID,N'PerformanceAssessment Review', 0, 35, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Final')
				begin
					declare @capTranEmail_id36 numeric
					select @capTranEmail_id36 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id36 + 1, @Cmp_ID,N'PerformanceAssessment Final', 0, 36, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Final Stage Review')
				Begin
					declare @capTranEmail_id37 numeric
					select @capTranEmail_id37 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id37 + 1, @Cmp_ID,N'Final Stage Review', 0, 37, 0, 0, 0, N''
				End	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Direct Assessment Approved')
				Begin
					declare @capTranEmail_id38 numeric
					select @capTranEmail_id38 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id38 + 1, @Cmp_ID,N'Direct Assessment Approved', 0, 38, 0, 0, 0, N''
				End		
			--added 16 apr 2014
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Extended Self Assessment')
				Begin
					declare @capTranEmail_id39 numeric
					select @capTranEmail_id39 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id39 + 1, @Cmp_ID,N'Extended Self Assessment', 0, 79, 0, 0, 0, N''
				End	
			Else --modified on 23 oct 2015
				begin				
					update 	[T0040_Email_Notification_Config]
					set 	[EMAIL_NTF_DEF_ID] =79
					where [EMAIL_TYPE_NAME]='Extended Self Assessment' and cmp_id = @Cmp_ID 
				end										
			--Added By Mukti(Start)
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Asset Application')
				begin
					declare @capTranEmail_id40 numeric
					select @capTranEmail_id40 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id40 + 1, @Cmp_ID,N'Asset Application', 0, 57, 0, 0, 0, N''
				end		
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Asset Approval')
				begin
					declare @capTranEmail_id41 numeric
					select @capTranEmail_id41 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id41 + 1, @Cmp_ID,N'Asset Approval', 0, 58, 0, 0, 0, N''
				end			
			--Added By Mukti(End)	
			---Added By Ripal 25Jun2014 Start
			declare @capTranEmail_id42 numeric
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Request')
				begin
					select @capTranEmail_id42 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]
								([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id42 + 1, @Cmp_ID,N'Recruitment Request', 0, 41, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Request Approval')
				begin
					select @capTranEmail_id42 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]
								([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id42 + 1, @Cmp_ID,N'Recruitment Request Approval', 0, 42, 0, 0, 0, N''
				end
			---Added By Ripal 25Jun2014 End
			--added by sneha on 19dec2014
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Resume Screening')
				begin
					declare @capTranEmail_id60 numeric
					select @capTranEmail_id60 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id60 + 1, @Cmp_ID,N'Resume Screening', 0, 60, 0, 0, 0, N''
				end	
				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Resume Screened')
				begin
					declare @capTranEmail_id61 numeric
					select @capTranEmail_id61 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id61 + 1, @Cmp_ID,N'Resume Screened', 0, 61, 0, 0, 0, N''
				end	
			--added by sneha on 19dec2014 end
			--added by sneha on 25Dec2014
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Employee Review')
				begin
					declare @capTranEmail_id43 numeric
					select @capTranEmail_id43 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id43 + 1, @Cmp_ID,N'KPI Employee Review', 0, 43, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Employee Approved')
				begin
					declare @capTranEmail_id44 numeric
					select @capTranEmail_id44 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id44 + 1, @Cmp_ID,N'KPI Employee Approved', 0, 44, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Reviewed')
				begin
					declare @capTranEmail_id45 numeric
					select @capTranEmail_id45 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id45 + 1, @Cmp_ID,N'KPI Reviewed', 0, 45, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Manager Approved')
				begin
					declare @capTranEmail_id46 numeric
					select @capTranEmail_id46 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id46 + 1, @Cmp_ID,N'KPI Manager Approved', 0, 46, 0, 0, 0, N''
				end				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Employee Review')
				begin
					declare @capTranEmail_id47 numeric
					select @capTranEmail_id47 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id47 + 1, @Cmp_ID,N'KPIRating Employee Review', 0, 47, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Reviewed')
				begin
					declare @capTranEmail_id48 numeric
					select @capTranEmail_id48 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id48 + 1, @Cmp_ID,N'KPIRating Reviewed', 0, 48, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Employee Approved')
				begin
					declare @capTranEmail_id49 numeric
					select @capTranEmail_id49 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id49 + 1, @Cmp_ID,N'KPIRating Employee Approved', 0, 49, 0, 0, 0, N''
				end					
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Manager Approved')
				begin
					declare @capTranEmail_id50 numeric
					select @capTranEmail_id50 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id50 + 1, @Cmp_ID,N'KPIRating Manager Approved', 0, 50, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Manager Review')
				begin
					declare @capTranEmail_id51 numeric
					select @capTranEmail_id51 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id51 + 1, @Cmp_ID,N'KPIRating Manager Review', 0, 51, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Reject')
				begin
					declare @capTranEmail_id52 numeric
					select @capTranEmail_id52 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id52 + 1, @Cmp_ID,N'KPIRating Reject', 0, 52, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Approve')
				begin
					declare @capTranEmail_id53 numeric
					select @capTranEmail_id53 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id53 + 1, @Cmp_ID,N'KPIRating Approve', 0, 53, 0, 0, 0, N''
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Closed')
				begin
					declare @capTranEmail_id54 numeric
					select @capTranEmail_id54 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id54 + 1, @Cmp_ID,N'KPI Closed', 0, 54, 0, 0, 0, N''
				end		
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Objective Manager Review')
				begin
					declare @capTranEmail_id55 numeric
					select @capTranEmail_id55 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id55 + 1, @Cmp_ID,N'KPI Objective Manager Review', 0, 55, 0, 0, 0, N''
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Objective Final Approval')
				begin
					declare @capTranEmail_id56 numeric
					select @capTranEmail_id56 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id56 + 1, @Cmp_ID,N'KPI Objective Final Approval', 0, 56, 0, 0, 0, N''
				end			
			--by sneha on 25 Dec 2014 end
			
			--added by Mukti on 28012015 start
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Approval Level')
				begin
						declare @capTranEmail_id64 numeric
						select @capTranEmail_id64 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id64 + 1, @Cmp_ID,N'Recruitment Approval Level', 0, 64, 0, 0, 0, N''
				end	
				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Approval')
				begin
					declare @capTranEmail_id66 numeric
					select @capTranEmail_id66 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id66 + 1, @Cmp_ID,N'Candidate Approval', 0, 66, 0, 0, 0, N''
				end	
					
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Approval Level')
				begin
					declare @capTranEmail_id65 numeric
					select @capTranEmail_id65 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id65 + 1, @Cmp_ID,N'Candidate Approval Level', 0, 65, 0, 0, 0, N''
				end	
			--added by Mukti on 28012015 end
			--added by Mukti on 11022015 start
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Rejection')
				begin
					declare @capTranEmail_id67 numeric
					select @capTranEmail_id67 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id67 + 1, @Cmp_ID,N'Candidate Rejection', 0, 67, 0, 0, 0, N''
				end	
				
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Post Detail')
				begin
					declare @capTranEmail_id68 numeric
					select @capTranEmail_id68 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id68 + 1, @Cmp_ID,N'Recruitment Post Detail', 0, 68, 0, 0, 0, N''
				end		
			--added by Mukti on 11022015 end
			--added by Mukti on 02032015 start
			if exists (select 1 from T0040_Email_Notification_Config WITH (NOLOCK) where email_type_name ='Training Remainder')	
				begin
					delete from T0040_Email_Notification_Config where email_type_name ='Training Remainder'
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training Reminder')
				begin
					declare @capTranEmail_id69 numeric
					select @capTranEmail_id69 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id69 + 1, @Cmp_ID,N'Training Reminder', 0, 69, 0, 0, 0, N''
				end	
			--added by Mukti on 02032015 end		

			--added by Mukti 03032015(start)
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Survey Form Filled By Employee')
				begin
					declare @capTranEmail_id70 numeric
					select @capTranEmail_id70 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])	
					SELECT @capTranEmail_id70 + 1, @Cmp_ID,N'Survey Form Filled By Employee', 0, 70, 0, 0, 0, N''
				End
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Fill The Survey Form')
				begin
					declare @capTranEmail_id71 numeric
					select @capTranEmail_id71 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])	
					SELECT @capTranEmail_id71 + 1, @Cmp_ID,N'Fill The Survey Form', 0, 71, 0, 0, 0, N''
			End
			--added by Mukti 03032015(end)
			--Added by Gadriwala Muslim -03072015
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Pre-CompOff Application')
				begin
					declare @capTranEmail_id73 numeric
					select @capTranEmail_id73 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id73 + 1, @Cmp_ID, N'Pre-CompOff Application', 0, 73, 0, 0, 0, N''
								
				end	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Pre-CompOff Approval')
				begin
					declare @capTranEmail_id74 numeric
					select @capTranEmail_id74 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id74 + 1, @Cmp_ID, N'Pre-CompOff Approval', 0, 74, 0, 0, 0, N''
								
				end	
			--Added by Gadriwala Muslim -03072015

			--added by sneha on 07 Aug 2015 start	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Send final list of trainees')
				begin
					declare @capTranEmail_id75 numeric
					select @capTranEmail_id75 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id75 + 1, @Cmp_ID,N'Send final list of trainees', 0, 75, 0, 0, 0, N''
				end	
			--added by sneha on 07 Aug 2015 end

			--added by sneha on 07 Aug 2015 start	
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training Answers/Feedback Submitted')
				begin
					declare @capTranEmail_id76 numeric
					select @capTranEmail_id76 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id76 + 1, @Cmp_ID,N'Training Answers/Feedback Submitted', 0, 76, 0, 0, 0, N''
				end	
			--added by sneha on 07 Aug 2015 end
						
			--added by sneha on 21 Jun 2016 start
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Register For Training')
				begin
					declare @capTranEmail_id85 numeric
					select @capTranEmail_id85 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
							
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[Module_Name])
					SELECT @capTranEmail_id85 + 1, @Cmp_ID,N'Register For Training', 0, 85, 0, 0, 0, N'',N'HRMS'
				end	
			--added by sneha on 21 Jun 2016 end		
			--added by 01/08/2016 sneha start--
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Balance Score Card')
				BEGIN
					declare @TranEmail_id86 numeric
					SET  @TranEmail_id86  = 0
					SELECT @TranEmail_id86 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[module_name])
					SELECT @TranEmail_id86 + 1, @Cmp_ID,N'Balance Score Card', 0, 86, 0, 0, 0,N'','Appraisal3'
				END		 

			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Balance Score Card Assessment')
				BEGIN
					declare @TranEmail_id87 numeric
					SET  @TranEmail_id87  = 0
					SELECT @TranEmail_id87 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[module_name])
					SELECT @TranEmail_id87 + 1, @Cmp_ID,N'Balance Score Card Assessment', 0, 87, 0, 0, 0,N'','Appraisal3'
				END			 	 
			--added by 01/08/2016 sneha end--	
			--Added by Pathak on 05122016---------------------------------------------
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Optional Holiday Application')
				BEGIN	
						declare @TranEmail_id91 numeric
						SELECT @TranEmail_id91 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @TranEmail_id91 + 1, @CMP_ID,N'Optional Holiday Application', 0, 91, 0, 0, 0, N''
				END
			--Ended by Pathak on 05122016------------------------------------------------------------------------
			--Added by Pathak on 15122016---------------------------------------------
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Optional Holiday Approval')
				BEGIN	
						declare @TranEmail_id92 numeric
						SELECT @TranEmail_id92 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @TranEmail_id92 + 1, @CMP_ID,N'Optional Holiday Approval', 0, 92, 0, 0, 0, N''
				END
			--Ended by Pathak on 15122016------------------------------------------------------------------------
			--added by Mukti on 17062015 start
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Offer/Appointment Letter Status')
				begin
					declare @capTranEmail_id72 numeric
					select @capTranEmail_id72 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id72 + 1, @Cmp_ID,N'Offer/Appointment Letter Status', 0, 72, 0, 0, 0, N''
				end		
			--added by Mukti on 17062015 end	
			--added by Mukti on 04022016(start)
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training In-Out')
				begin
					declare @capTranEmail_id80 numeric
					select @capTranEmail_id80 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id80 + 1, @Cmp_ID,N'Training In-Out', 0, 80, 0, 0, 0,N''
				end	
			--added by Mukti on 04022016(end)
			--Ankit 26052016
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'GatePass')
				BEGIN
					SET  @capTranEmail_id80  = 0
					SELECT @capTranEmail_id80 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id80 + 1, @Cmp_ID,N'GatePass', 0, 81, 0, 0, 0,N''
				END	
			--Added By Jaina 06-06-2016 Start
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Exit Approval')
				BEGIN
						DECLARE @CAPTRANEMAIL_ID82 NUMERIC
						SELECT @CAPTRANEMAIL_ID82 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @CAPTRANEMAIL_ID82 + 1, @CMP_ID,N'Exit Approval', 0, 82, 0, 0, 0, N''
				END

			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Clearance Approval')
				BEGIN
						DECLARE @CAPTRANEMAIL_ID83 NUMERIC
						SELECT @CAPTRANEMAIL_ID83 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @CAPTRANEMAIL_ID83 + 1, @CMP_ID,N'Clearance Approval', 0, 83, 0, 0, 0, N''
				END

			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Final Clearance Approval')
				BEGIN
						DECLARE @CAPTRANEMAIL_ID84 NUMERIC
						SELECT @CAPTRANEMAIL_ID84 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @CAPTRANEMAIL_ID84 + 1, @CMP_ID,N'Final Clearance Approval', 0, 84, 0, 0, 0, N''
				END
			--Added By Jaina 06-06-2016 End
			--Added By Jaina 12-09-2016 Start
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Weekoff Request Application')
				BEGIN
						DECLARE @CAPTRANEMAIL_ID94 NUMERIC
						SELECT @CAPTRANEMAIL_ID94 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
								
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @CAPTRANEMAIL_ID94 + 1, @CMP_ID,N'Weekoff Request Application', 0, 88, 0, 0, 0, N''
				END
			--Added By Jaina 12-09-2016 ENd
			--Added By Ramiz on 06/03/2017
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Assign Reporting Manager')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	WITH (NOLOCK)	 
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Assign Reporting Manager', 0, 91, 0, 0, 0, N''
				END
			--Ended By Ramiz on 06/03/2017
			--Added by Jaina 10-04-2017 Start
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Pass Responsibility')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	 WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Pass Responsibility', 0, 93, 0, 0, 0, N''
				END
			--Added by Jaina 10-04-2017 End
			
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Marriage Anniversary')
				begin
					declare @capTranEmail_id95 numeric
					select @capTranEmail_id95 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id95 + 1, @Cmp_ID,N'Marriage Anniversary', 0, 94, 0, 0, 0, N''
				end
			
			--Added by Jaina 17-06-2017 Start	
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Employee Retirement')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	 WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Employee Retirement', 0, 95, 0, 0, 0, N''
				END
				
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Ticket Open')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Ticket Open', 0, 96, 0, 0, 0, N''
				END
				
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Ticket Close')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	WITH (NOLOCK)	 
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Ticket Close', 0, 97, 0, 0, 0, N''
				END
			--Added by Jaina 17-06-2017 End
			---added by sneha 19-08/2017 start
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Resume From Consultant')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	 WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Resume From Consultant', 0, 98, 0, 0, 0, N''
				END			
			---added by sneha 19-08/2017 end
			
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Different Location Login Alert')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Different Location Login Alert', 0, 99, 0, 0, 0, N''
				END		
			
			--Added by Jaina 05-07-2018 Start	
			IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Employee Warning')
				BEGIN
						SELECT @EMAILNOTIFICATION_ID = ISNULL(MAX(EMAIL_NTF_ID),0) + 1 FROM T0040_EMAIL_NOTIFICATION_CONFIG	WITH (NOLOCK)	
						
						INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
						SELECT @EMAILNOTIFICATION_ID, @CMP_ID,N'Employee Warning', 0, 100, 0, 0, 0, N''
				END
			--Added by Jaina 05-07-2018 End
			
			--Added By Mukti(07092018)start
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Self Assessment Probation Form Submitted')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Self Assessment Probation Form Submitted', 0, 101, 0, 0, 0, N'' 								
				end
			--Added By Mukti(07092018)end

			--Added By Nilesh Patel on 26-12-2018 --Start
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Induction Training Answers Submitted')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Induction Training Answers Submitted', 0, 102, 0, 0, 0, N'' 								
				end
			--Added By Nilesh Patel on 26-12-2018 --End

			--Added By Nilesh Patel on 26-12-2018 --Start
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Fill Up Induction Checklist')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Fill Up Induction Checklist', 0, 103, 0, 0, 0, N'' 								
				end
			--Added By Nilesh Patel on 26-12-2018 --End
			
			--Added By Mukti(06122018)start
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Job Description Submitted')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Job Description Submitted', 0, 104, 0, 0, 0, N'' 								
				end
			--Added By Mukti(06122018)end
			
			--Added By Mukti(22012018)start
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Transferred')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Candidate Transferred', 0, 105, 0, 0, 0, N'' 								
				end
			--Added By Mukti(22012018)end
			
			IF not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Induction Schedule')
				begin
					SELECT @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @EMAILNOTIFICATION_ID+1, @Cmp_ID, N'Recruitment Induction Schedule', 0, 106, 0, 0, 0, N'' 								
				end

			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Auto Reminder for New Joinee')
				begin					
					select @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @EMAILNOTIFICATION_ID + 1, @Cmp_ID, N'Auto Reminder for New Joinee', 0, 107, 0, 0, 0, N''
								
				end
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config WITH (NOLOCK) where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Vehicle Application')
				begin					
					select @EMAILNOTIFICATION_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config WITH (NOLOCK)
								
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @EMAILNOTIFICATION_ID + 1, @Cmp_ID,N'Vehicle Application', 0, 108, 0, 0, 0, N''
				end		
		END

		/*************************************** EMAIL NOTIFICATION SETTINGS ENDS HERE *********************************/
			
		

		/*************************************** CHANGE REQUEST SETTINGS STARTS HERE *********************************/

		BEGIN --THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION

			--Added by nilesh Patel on 21122017 --Start

			--Added by nilesh Patel on 21122017 --End
			declare @Priority_ID numeric
			if not exists(select 1 from T0040_Ticket_Priority WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Priority_Name = 'High')
			begin
				select  @Priority_ID = isnull(MAX(Tran_id),0) + 1 from T0040_Ticket_Priority WITH (NOLOCK)
				INSERT INTO T0040_Ticket_Priority(Tran_id,Cmp_ID,Priority_Name,Hours_Limit,UserID,Modify_Date)VALUES(@Priority_ID,@Cmp_ID,'High',4,0,GETDATE())
			end
			if not exists(select 1 from T0040_Ticket_Priority WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Priority_Name = 'Medium')
			begin
				select  @Priority_ID = isnull(MAX(Tran_id),0) + 1 from T0040_Ticket_Priority WITH (NOLOCK)
				INSERT INTO T0040_Ticket_Priority(Tran_id,Cmp_ID,Priority_Name,Hours_Limit,UserID,Modify_Date)VALUES(@Priority_ID,@Cmp_ID,'Medium',8,0,GETDATE())
			end
			if not exists(select 1 from T0040_Ticket_Priority WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Priority_Name = 'Low')
			begin
				select  @Priority_ID = isnull(MAX(Tran_id),0) + 1 from T0040_Ticket_Priority WITH (NOLOCK)
				INSERT INTO T0040_Ticket_Priority(Tran_id,Cmp_ID,Priority_Name,Hours_Limit,UserID,Modify_Date)VALUES(@Priority_ID,@Cmp_ID,'Low',12,0,GETDATE())
			end
			--Added by nilesh patel on 12012015 -start
			Delete FROM T0040_Change_Request_Master WHERE Cmp_Id = @Cmp_ID
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Birthdate Change')
			begin
					declare @Request_id1 numeric
					select  @Request_id1 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK) 
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id1,1,'Birthdate Change',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Branch Change')
			begin
					declare @Request_id2 numeric
					select  @Request_id2 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id2,2,'Branch Change',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK)  where Cmp_Id = @Cmp_ID and Request_type = 'Shift Change')
			begin
					declare @Request_id3 numeric
					select  @Request_id3 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id3,3,'Shift Change',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Marital Status Change')
			begin
					declare @Request_id4 numeric
					select  @Request_id4 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id4,4,'Marital Status Change',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Permanent Address Change')
			begin
					declare @Request_id5 numeric
					select  @Request_id5 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id5,5,'Permanent Address Change',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Present Address Change')
			begin
					declare @Request_id6 numeric
					select  @Request_id6 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id6,6,'Present Address Change',@Cmp_ID,0)
			end
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Qualification')
			begin
					declare @Request_id7 numeric
					select  @Request_id7 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id7,7,'Qualification',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK)  where Cmp_Id = @Cmp_ID and Request_type = 'Dependent')
			begin
					declare @Request_id8 numeric
					select  @Request_id8 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id8,8,'Dependent',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Passport')
			begin
					declare @Request_id9 numeric
					select  @Request_id9 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id9,9,'Passport',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Visa')
			begin
					declare @Request_id10 numeric
					select  @Request_id10 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id10,10,'Visa',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'License')
			begin
					declare @Request_id11 numeric
					select  @Request_id11 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id11,11,'License',@Cmp_ID,0)
			end
				
			--Added By Jaina 28-10-2015 		
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Others')
			begin
					declare @Request_id12 numeric
					select  @Request_id12 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id12,12,'Others',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Bank Details')
			begin
					declare @Request_id13 numeric
					select  @Request_id13 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id13,13,'Bank Details',@Cmp_ID,0)
			end		
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Nominees')
			begin
					declare @Request_id14 numeric
					select  @Request_id14 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id14,14,'Nominees',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Mediclaim')
			begin
					declare @Request_id15 numeric
					select  @Request_id15 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id15,15,'Mediclaim',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Pan Card & Aadhaar Card')
			begin
					declare @Request_id16 numeric
					select  @Request_id16 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id16,16,'Pan Card & Aadhaar Card',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Skip Monthly Loan Installment')
			begin
					declare @Request_id17 numeric
					select  @Request_id17 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id17,17,'Skip Monthly Loan Installment',@Cmp_ID,0)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Absconding')
			begin
					declare @Request_id18 numeric
					select  @Request_id18 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id18,18,'Absconding',@Cmp_ID,1)
			end
			
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Salary On Hold')
			begin
					declare @Request_id19 numeric
					select  @Request_id19 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id19,19,'Salary On Hold',@Cmp_ID,1)
			end
			
			--Added by Jaina 27-04-2018
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Child Birth Detail')
			begin
					declare @Request_id20 numeric
					select  @Request_id20 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag)VALUES(@Request_id20,20,'Child Birth Detail',@Cmp_ID,0)
			end
			
			--Added by Jaina 27-04-2018
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK)  where Cmp_Id = @Cmp_ID and Request_type = 'Child Birth Limit (For Paternity Leave)')
				begin
						declare @Request_id21 numeric
						select  @Request_id21 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
						INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag,Max_Limit)VALUES(@Request_id21,21,'Child Birth Limit (For Paternity Leave)',@Cmp_ID,1,2)
				end

			--Added by Jaina 06-10-2020
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Sim Card')
				begin
						declare @Request_id22 numeric
						select  @Request_id22 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
						INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag,Max_Limit)VALUES(@Request_id22,22,'Sim Card',@Cmp_ID,0,0)
				end
			-- Added by Niraj(24062022)
			if not exists (select Request_id from T0040_Change_Request_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Request_type = 'Favourite')
			begin 
					declare @Request_id23 numeric
					select  @Request_id23 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master WITH (NOLOCK)
					INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID,Flag,Max_Limit)VALUES(@Request_id23,23,'Favourite',@Cmp_ID,0,0)
			end
		END

		/*************************************** CHANGE REQUEST SETTINGS STARTS HERE *********************************/		


		/*************************************** OTHER COMMON SETTINGS STARTS HERE *********************************/		
		BEGIN	--THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION

			IF NOT EXISTS(SELECT 1 FROM T0030_Hrms_Training_Type WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Training_TypeName='External')
				BEGIN
					EXEC P0030_Hrms_Training_Type 0,@Cmp_ID,'External','I'
				END
			IF NOT EXISTS(SELECT 1 FROM T0030_Hrms_Training_Type WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Training_TypeName='Internal')
				BEGIN
					EXEC P0030_Hrms_Training_Type 0,@Cmp_ID,'Internal','I'
				END
			--ended on  07 Aug 2015 sneha
			IF not exists (select Perquisites_Id from T0240_Perquisites_Master WITH (NOLOCK) where Cmp_Id = @Cmp_ID)
				begin
					Declare @per_tran_id as numeric
					set @per_tran_id = 0
				
					select @per_tran_id = isnull(max(Perquisites_Id),0) from T0240_Perquisites_Master WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0240_Perquisites_Master]([Perquisites_Id], [Cmp_id], [Name], [Sort_Name], [Sorting_no], [Def_id], [Remarks])
					SELECT @per_tran_id + 1, @Cmp_Id, N'Accommodation', N'RFA', 1, 0, NULL UNION ALL
					SELECT @per_tran_id + 2, @Cmp_Id, N'Cars / Other automotive', N'Car', 2, 0, NULL --UNION ALL
					--SELECT @per_tran_id + 3, @Cmp_Id, N'Sweeper, gardener, watchman or personal attendant', N'Clerk', 3, 0, NULL UNION ALL
					--SELECT @per_tran_id + 4, @Cmp_Id, N'Gas, electricity, water', N'Facilities', 4, 0, NULL UNION ALL
					--SELECT @per_tran_id + 5, @Cmp_Id, N'Interest free or concessional Loans', N'Interest', 5, 0, NULL UNION ALL
					--SELECT @per_tran_id + 6, @Cmp_Id, N'Holiday expenses', N'Holiday', 6, 0, NULL UNION ALL
					--SELECT @per_tran_id + 7, @Cmp_Id, N'Free or concessional travel', N'Travel', 7, 0, NULL UNION ALL
					--SELECT @per_tran_id + 8, @Cmp_Id, N'Free meals', N'Meals', 8, 0, NULL UNION ALL
					--SELECT @per_tran_id + 9, @Cmp_Id, N'Free Education', N'Education', 9, 0, NULL UNION ALL
					--SELECT @per_tran_id + 10, @Cmp_Id, N'Gifts, vouchers etc', N'Gift', 10, 0, NULL UNION ALL
					--SELECT @per_tran_id + 11, @Cmp_Id, N'Credit card expenses', N'Credit', 11, 0, NULL UNION ALL
					--SELECT @per_tran_id + 12, @Cmp_Id, N'Club expenses', N'Club', 12, 0, NULL UNION ALL
					--SELECT @per_tran_id + 13, @Cmp_Id, N'Use of movable assets by employees', N'Assets', 13, 0, NULL UNION ALL
					--SELECT @per_tran_id + 14, @Cmp_Id, N'Transfer of assets to employees', N'TAssets ', 14, 0, NULL UNION ALL
					--SELECT @per_tran_id + 15, @Cmp_Id, N'Value of any other benefit / amenity / service / privilege', N'Benefits', 15, 0, NULL UNION ALL
					--SELECT @per_tran_id + 16, @Cmp_Id, N'Stock options (non-qualified options)', N'Stock', 16, 0, NULL UNION ALL
					--SELECT @per_tran_id + 17, @Cmp_Id, N'Other benefits or amenities', N'Other', 17, 0, NULL
				end		
			
			
			-- Travel Mode Start (Hiral 28092012) --
			IF not exists (select Travel_Mode_ID from T0030_TRAVEL_MODE_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID)
				begin
					declare @Travel_Mode_ID numeric
					select @Travel_Mode_ID = isnull(MAX(Travel_Mode_ID),0) from T0030_TRAVEL_MODE_MASTER WITH (NOLOCK)
						
					INSERT INTO [dbo].[T0030_TRAVEL_MODE_MASTER]([Travel_Mode_ID], [Cmp_Id], [Travel_Mode_Name],[Login_ID], [Create_Date],[Mode_Type])
						SELECT @Travel_Mode_ID + 1, @Cmp_ID, N'Car', 0, GETDATE(),3 UNION ALL
						SELECT @Travel_Mode_ID + 2, @Cmp_ID, N'Bus', 0 , GETDATE(),4 UNION ALL
						SELECT @Travel_Mode_ID + 3, @Cmp_ID, N'Train', 0, GETDATE(),2 UNION ALL
						SELECT @Travel_Mode_ID + 4, @Cmp_ID, N'Flight', 0, GETDATE(),1 UNION ALL
						SELECT @Travel_Mode_ID + 5, @Cmp_ID, N'Other', 0, GETDATE(),7 
				end
			-- Travel Mode End (Hiral 28092012) --
			
			---Start Committee Member Allocation : Should be put on member type in dropdown list(Ronakb050225)---

            IF NOT EXISTS (SELECT GCM_ID FROM T0040_Griev_Committee_Member_Type WHERE GCM_ID IN (1, 2, 3))
             BEGIN

					DECLARE @MaxGCM_ID INT;
					SELECT @MaxGCM_ID = ISNULL(MAX(GCM_ID), 0) FROM T0040_Griev_Committee_Member_Type;

					-- Insert new records for GCM_ID 1, 2, and 3
					INSERT INTO T0040_Griev_Committee_Member_Type (GCM_ID, GCM_Type)
					SELECT @MaxGCM_ID + 1, 'Chairperson'
					UNION ALL
					SELECT @MaxGCM_ID + 2, 'Nodel HR'
					UNION ALL
					SELECT @MaxGCM_ID + 3, 'Committee Member';
            END
			---End Committee Member Allocation : Should be put on member type in dropdown list(Ronakb050225)---
			---Start Grievance Application(Admin) : Should be put on Receive From dropdown list(Ronakb050225)---
			IF NOT EXISTS (SELECT Id FROM T0030_Griev_Recieve_From_List WHERE Id IN (1, 2, 3, 4, 5, 6))
			BEGIN
				-- Get the current maximum Id
				DECLARE @MaxId INT;
				SELECT @MaxId = ISNULL(MAX(Id), 0) FROM T0030_Griev_Recieve_From_List;

				-- Insert new records for the given Ids
				INSERT INTO T0030_Griev_Recieve_From_List (Id, R_From)
				SELECT @MaxId + 1, 'Email'
				UNION ALL
				SELECT @MaxId + 2, 'Registry'
				UNION ALL
				SELECT @MaxId + 3, 'Currier'
				UNION ALL
				SELECT @MaxId + 4, 'Other'
				UNION ALL
				SELECT @MaxId + 5, 'System'
				UNION ALL
				SELECT @MaxId + 6, 'Mobile';
			END
			---End Grievance Application(Admin) : Should be put on Receive From dropdown list(Ronakb050225)---
			
			-- Email General Setting Start (Hiral 08102012)
				exec Insert_Default_Mail_Settings_New @Cmp_ID
			-- Email General Setting End (Hiral 08102012)
			-- Digital Signature start
			if not exists (select Tran_id from T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Module = 'Form16')
				begin					
					INSERT INTO T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS
							(Cmp_id, Module, Param1, Param2, Param3, Param4, PageNo)
					VALUES     (@Cmp_ID,'Form16',300,635,400,675, 2)
				end
			
			if not exists (select Tran_id from T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Module = 'Form12B')
				begin					
					INSERT INTO T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS
							(Cmp_id, Module, Param1, Param2, Param3, Param4, PageNo)
					VALUES     (@Cmp_ID,'Form12B',400,90,450,120,4)
				end
				
			--- Digital Signature end
		
			-- Added By Hiral For Password Expiry Setting 04 June,2013 (Start)
			If not exists(Select 1 from T0011_Password_Settings WITH (NOLOCK) where Cmp_ID = @Cmp_ID)
				begin
					Declare @Password_ID As Numeric(18,0)
					Select @Password_ID = ISNULL(MAX(Password_ID),0) + 1 from T0011_Password_Settings WITH (NOLOCK)
				
					Insert into T0011_Password_Settings
						(Password_ID, Cmp_ID, Enable_Validation, Min_Chars, Upper_Char, Lower_Char, 
						 Is_Digit, Special_Char, Password_Format, Pass_Exp_Days, Reminder_Days)
						values(@Password_ID, @Cmp_ID, 1, 0, 0, 0, 0, 0, '', 180, 30)	
				end	
			-- Added By Hiral For Password Expiry Setting 04 June,2013 (End)
			-- Added By Gadriwala Muslim 23/05/2014 -start
			if not Exists(select 1 from T0250_Password_Format_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID)
				begin
					Insert into T0250_Password_Format_Setting (Pwd_ID,Cmp_ID,Name,Format_ID)
					select 1,@Cmp_ID,'Form-16',0 union all
					select 2,@Cmp_ID,'Salary Slip',0	
				end
			-- Added By Gadriwala Muslim 23/05/2014 -End			
			-- Ankit For Update Sample Code IS Null -- 26122014
			IF Exists( SELECT 1 FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE (Sample_Emp_Code Is Null OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID )
				BEGIN
					Declare @IS_Auto_Alpha_Numeric_Code Numeric(18,0)
					Declare @No_OF_Digit_Emp_Code	 Numeric(18,0)
					Declare @Is_CompanyWise Numeric(18,0)
					Declare @IS_Alpha_Numeric_Branchwise Numeric(18,0)
					Declare @Sample_Emp_Code Varchar(100)
					Declare @Dig Varchar(15)
					Declare @Is_DateWise Numeric(18,0)
					Declare @Is_JoiningDateWise Numeric(18,0)
					Declare @DateFormat Varchar(15)
					
					Set @IS_Auto_Alpha_Numeric_Code = 0
					Set @No_OF_Digit_Emp_Code		= 0
					Set @Is_CompanyWise				= 0
					Set @IS_Alpha_Numeric_Branchwise = 0
					Set @Sample_Emp_Code			= ''
					Set @Dig = ''
					Set @Is_DateWise	= 0
					Set @Is_JoiningDateWise	= 0
					Set @DateFormat = ''
					
					SELECT @IS_Auto_Alpha_Numeric_Code = IS_Auto_Alpha_Numeric_Code ,@No_OF_Digit_Emp_Code = No_OF_Digit_Emp_Code ,
							@Is_CompanyWise = Is_CompanyWise , @IS_Alpha_Numeric_Branchwise = IS_Alpha_Numeric_Branchwise,
							@Is_DateWise = Is_DateWise ,@Is_JoiningDateWise = Is_JoiningDateWise , @DateFormat = DateFormat
					FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE (Sample_Emp_Code Is Null OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID
				
					IF @IS_Auto_Alpha_Numeric_Code = 1
						BEGIN
								IF @No_OF_Digit_Emp_Code > 0
								SET @Dig = RIGHT(REPLICATE('0', @No_OF_Digit_Emp_Code)  ,@No_OF_Digit_Emp_Code - 1)   +  '1'
							 
								IF @Is_CompanyWise = 1
								SET @Sample_Emp_Code = 'CM+'
							 
								IF @IS_Alpha_Numeric_Branchwise = 1
								SET @Sample_Emp_Code = @Sample_Emp_Code + 'BR+'
							 
								IF @Is_DateWise = 1 AND @Is_JoiningDateWise = 1
								SET @Sample_Emp_Code = @Sample_Emp_Code + 'JD('+ @DateFormat + ')+'
								Else IF @Is_DateWise = 1 AND @Is_JoiningDateWise = 0
								SET @Sample_Emp_Code = @Sample_Emp_Code + 'CD('+ @DateFormat + ')+'
								
								
								SET @Sample_Emp_Code = ISNULL(@Sample_Emp_Code,'') + @Dig
						END
					ELSE
						BEGIN
							IF @No_OF_Digit_Emp_Code > 0
								SET @Sample_Emp_Code = RIGHT(REPLICATE('0', @No_OF_Digit_Emp_Code)  ,@No_OF_Digit_Emp_Code - 1)   +  '1'
						END
					
					UPDATE T0010_COMPANY_MASTER 
					SET Sample_Emp_Code = @Sample_Emp_Code
					WHERE (Sample_Emp_Code IS NULL OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID
						
				END
			
			UPDATE T0090_EMP_REPORTING_DETAIL		--UPDATE EFFECT DATE OF REPORTING MANAGER AS EMPLOYEE DOJ
			SET EFFECT_DATE = A.DATE_OF_JOIN
			FROM T0080_EMP_MASTER A INNER JOIN 
				T0090_EMP_REPORTING_DETAIL B ON  A.EMP_ID = B.EMP_ID
			WHERE B.EFFECT_DATE IS  NULL
				
			-- Ankit For Update Sample Code Is Null -- 26122014
			
			--IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Allow Same Date Increment')
			--	BEGIN
			--		SELECT @setting_id_max=isnull(max(setting_id),0) + 1 FROM T0040_SETTING
			--		Insert into T0040_SETTING(Setting_ID,Cmp_ID,Setting_Name,Setting_Value,Comment,Group_By,Alias,Module_Name,Value_Type,Value_Ref) 
			--		VALUES(@setting_id_max,@Cmp_ID,'Allow Same Date Increment',0,'Allow Employee Same Date Increment Entry','Employee Settings')
			--	END		
			
			--Added By Gadriwala Muslim 25022015 - Start
						declare @pwd_Frmt_ID as integer 
						declare @Format as varchar(max)
	 
						declare curPassFormat cursor for select pwd_Frmt_ID,Format from T0040_Password_Format WITH (NOLOCK) where cmp_ID = @cmp_ID
	 
							open curPassFormat
							fetch next from curPassFormat into @pwd_Frmt_ID,@Format
								while @@fetch_Status = 0
									begin
										set @Format = REPLACE(@Format,'Employee First Name','EFN + ')
										set @Format = REPLACE(@Format,'Employee Last Name','ELN + ')
										set @Format = REPLACE(@Format,'Employee Code','EC + ')
										set @Format = REPLACE(@Format,'PAN Card','PAN + ')
										set @Format = REPLACE(@Format,'Date of Birth','DOB + ')
										set @Format = REPLACE(@Format,'Date of Join','DOJ + ')
										if  right(@format,2) = '+'
											set @format =	Substring(isnull(@format,''),1,len(@format) - 2)
										
										update T0040_Password_Format set Format = @Format 
										where pwd_Frmt_ID =  @pwd_Frmt_ID
										
									fetch next from curPassFormat into @pwd_Frmt_ID,@Format
									end
							close curPassFormat
							deallocate curPassFormat
			--Added By Gadriwala Muslim 25022015 - End
			
			--Added by nilesh patel on 07032015 -Start
			DECLARE @Char_index as Numeric(18,0)
			SELECT @Char_index = (Select charindex('{',data) From dbo.Split(Actual_AD_Formula,'#') where id=1) from (Select  Actual_AD_Formula ,ROW_NUMBER() OVER(ORDER BY Tran_Id) as Row_id  from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_ID ) t WHERE t.Row_id = 1 
			
			if @Char_index = 0
			begin
				DECLARE @Ad_ID Numeric(18,0)
				DECLARE @Ad_Actual_Name Varchar(2000)
				DECLARE @Cmp_ID_temp Numeric(18,0)
				DECLARE @Cmp_ID_1 Numeric(18,0)
				DECLARE @ID Numeric(18,0)
				DECLARE @Data Varchar(500)
				DECLARE @In_Formula Varchar(500)
				declare @StrSQl as nvarchar(max)
				
				CREATE Table #Temp
				(
					ID Numeric(18,0),
					Name Varchar(1000),
					Cmp_ID Numeric(18,0)
				)
				Declare  Cur_Spit cursor for Select AD_Id,Actual_AD_Formula,Cmp_Id From T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_ID
				open Cur_Spit
				FETCH next from Cur_Spit into @Ad_ID,@Ad_Actual_Name,@Cmp_ID_temp
				while @@fetch_status = 0 
					BEGIN
					
						Insert INTO #Temp(ID,Name,Cmp_ID)
						Select @Ad_ID,data,@Cmp_ID_temp From dbo.Split(@Ad_Actual_Name,'#')
										
						Declare Cur_Spit1 cursor for Select ID,Name,Cmp_ID From #Temp
						open Cur_Spit1  
						fetch next from Cur_Spit1 into @ID,@Data,@Cmp_ID_1
						while @@fetch_status = 0
							Begin
															
								Set @In_Formula = ''
								if @Data = 'Basic Salary'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End 
								if @Data = 'Gross Salary'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'CTC'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Absent Days'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Present Days'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Actual Gross'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Actual Basic'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'XDays'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Night Halt Count'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End
								if @Data = 'Month Days'
									Begin 
										Set @In_Formula = '{' + @Data + '}'
										Update #Temp Set Name =  @In_Formula where Name = @Data
									End	
								fetch next from Cur_Spit1 into @ID,@Data,@Cmp_ID_1
							End
							set @StrSQl=''
							SELECT @StrSQl = COALESCE(@StrSQl+'#',' ') + Name from #Temp	 where ID = @Ad_ID and Cmp_Id = @Cmp_ID_temp
							set @StrSQl = right(@StrSQl,LEN(@StrSQl)-1)
							close Cur_Spit1                    
							deallocate Cur_Spit1 
							Update T0040_AD_Formula_Setting SET Actual_AD_Formula = @StrSQl where AD_Id = @Ad_ID   and Cmp_Id = @Cmp_ID_temp
						FETCH next from Cur_Spit into @Ad_ID,@Ad_Actual_Name,@Cmp_ID_temp
					End
				close Cur_Spit                    
				deallocate Cur_Spit
				DROP TABLE #Temp
			End
			--Added by nilesh patel on 07032015 -End
			
			--Added by nilesh patel on 07032015 -Start
			DECLARE @Fromula_Ad Numeric(18,0)
			SELECT @Fromula_Ad = AD_Formula from (Select Charindex('{',AD_Formula) as AD_Formula ,ROW_NUMBER() OVER(ORDER BY Tran_Id) as Row_id  from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_Id ) t WHERE t.Row_id = 1
			
			if @Fromula_Ad = 0
			begin
				DECLARE @StrSQl_12 Varchar(max)
				Declare @AD_ID_12  nvarchar(max)
				Declare @AD_NAME_12  nvarchar(max) 
				Declare @Ad_ID_123 Numeric(18,0)
				DECLARE @Ad_Actual_Name_12 nvarchar(max)
				DECLARE @Cmp_ID_12 Numeric(18,0)

					Declare  Cur_Spit cursor for Select AD_Id,Actual_AD_Formula,Cmp_Id From T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					open Cur_Spit
					FETCH next from Cur_Spit into @Ad_ID_123,@Ad_Actual_Name_12,@Cmp_ID_12
					while @@fetch_status = 0 
						Begin 
							set @StrSQl_12=''
							SELECT @StrSQl_12 = COALESCE(@StrSQl_12+' ',' ') + Data FROM dbo.Split(@Ad_Actual_Name_12,'#')
							DECLARE Cur_Get_AD_Formula CURSOR FOR  
									select AD_ID,AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID_12  
									OPEN Cur_Get_AD_Formula  
										fetch next from Cur_Get_AD_Formula into @AD_ID_12,@AD_NAME_12  
										while @@fetch_status = 0  
										Begin  
												If CHARINDEX('{'+ @AD_ID_12 +'}',@StrSQl_12)>0 
													Begin 	
														set @StrSQl_12=REPLACE(@StrSQl_12,@AD_ID_12,@AD_NAME_12) 
													End
										fetch next from Cur_Get_AD_Formula into @AD_ID_12,@AD_NAME_12  
										End 
								Set @StrSQl_12 = REPLACE(REPLACE(@StrSQl_12,'} }','}'),'{ {','{')
								update T0040_AD_Formula_Setting SET AD_Formula = @StrSQl_12 where AD_Id = @Ad_ID_123
							close Cur_Get_AD_Formula   
							deallocate Cur_Get_AD_Formula  
						FETCH next from Cur_Spit into @Ad_ID_123,@Ad_Actual_Name_12,@Cmp_ID_12
					End 
					close Cur_Spit                    
					deallocate Cur_Spit
				End
				--Added by nilesh patel on 07032015 -End
		END

		/*************************************** OTHER COMMON SETTINGS ENDS HERE *********************************/		


		/*************************************** OTHER EXECUTION STARTS HERE *********************************/		
		BEGIN	--THIS BEGIN & END IS KEPT JUST TO CREATE A REGION , SO THAT WE CAN EXPAND AND COLLAPSE THIS PORTION
				
				exec InsertCity										-- Added by rohit on 21082015 for Default City Entry.
				exec insertsubdist									-- Added By tejas 21052024 for insert subdistrict
				exec P0030_City_Master_Default @cmp_id				-- Added By tejas 21052024 for insert District_master
				exec P0030_Dist_Master_Default @cmp_id				-- Added By tejas 21052024 for insert subdistrict_master
				exec P0030_TEHSIL_MASTER_Default @cmp_id
				exec Update_CAPTION_SETTING @cmp_id					--Mukti 07012016
				exec Update_Menu_setting @cmp_id					--Mukti 16012016
				exec Update_Email_Notification_Config @cmp_id		--Mukti 16012016
				exec P0011_module_detail 0,'HRMS',@cmp_id,0			--Added by rohit For Default Module Entry on 16012016	
				exec P0011_module_detail 0,'Appraisal1',@cmp_id,0
				exec P0011_module_detail 0,'Appraisal2',@cmp_id,0
				exec P0011_module_detail 0,'Appraisal3',@cmp_id,0	--THIS APPRAISAL FOR SCHEME
				exec P0011_module_detail 0,'MOBILE',@cmp_id,0		--THIS MOBILE Module added by rohit on 22072015
				exec P0011_module_detail 0,'GPF',@cmp_id,0			--Added by nilesh patel on 17082015
				exec P0011_module_detail 0,'CPS',@cmp_id,0			--Added by nilesh patel on 17082015
				exec P0011_module_detail 0,'Payroll',@cmp_id,1		--Added by rohit for Payroll Module on 16012016
				exec P0011_module_detail 0,'Timesheet',@cmp_id,0	--Added by Prakash Patel on 01032016
				exec P0011_module_detail 0,'Transport',@cmp_id,0	--Added by Prakash Patel on 01032016
				exec P0011_module_detail 0,'SALES',@cmp_id,0		--ADDED BY RAMIZ ON 16/11/2016 [BY DEFAULT IT WILL BE DISABLED]
				exec P0011_module_detail 0,'Machine',@cmp_id,0		--ADDED BY RAMIZ ON 23/02/2018 [BY DEFAULT IT WILL BE DISABLED]

				exec P0011_module_detail 0,'Retaining',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Incentive',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Uniform',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Piece_Transaction',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Bond',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Canteen',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Grievance',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'File_Management',@cmp_id,0		--Added by ronakk 27122023
				exec P0011_module_detail 0,'Medical',@cmp_id,0		--Added by ronakk 27122023
				

				EXEC P0350_EXIT_CLEARANCE_STATUS @CMP_ID			--ADDED BY JAINA FOR EXIT CLEARANCE STATUS 05-07-2016
				exec InsertDefault_AppraisalDetails @CMP_ID --Added by Mukti(16032018)for appraisal
				
				
			--Added By Nilesh Patel on 20032019
			IF NOT EXISTS(Select 1 From T0011_Company_Other_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID)
				Begin
					DECLARE @Exit_Terms_Condition As Varchar(Max)
					Set @Exit_Terms_Condition = 'Employees should compulsory serve notice period, in case employee fails to serve the notice period will not be issued the Relieving Letter and Full n Final Settlement shall be processed after recovering Pay equivalent to Notice Pay. In case employee is in possession of any assets or product or process related material, the same needed to be handed over to immediate HOD before Last working date.'
					Exec P0011_Company_Other_Setting @CMP_ID,@Exit_Terms_Condition
				End

			/* For Mandatory Fields In Employee Master */

			Declare @Tran_ID Numeric
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Department')
				Begin
					Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields   WITH (NOLOCK)
					Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Department',0,'Department Name','Dept_ID'
				End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Date-of-Birth')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields   WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Date-of-Birth',0,'Date of Birth','Date_Of_Birth'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Login-Alias')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Login-Alias',0,'Login Alias','Login_Alias'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Gross-Salary')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK) 
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Gross-Salary',0,'Gross Salary','Gross_Salary'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Basic-Salary')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields   WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Basic-Salary',0,'Basic Salary','Basic_Salary'
					End

		
			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Adhar-No.')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Adhar-No.',0,'Aadhar No.','Aadhar_Card_No'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Work-Email-ID')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Work-Email-ID',0,'Working EMail ID','Work_Email'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'No-of-Child')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','No-of-Child',0,'No. of Children','Emp_Childran'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'CTC')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','CTC',0,'CTC','CTC'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Category')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Category',0,'Category','Cat_ID'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Category')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) 
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Middle-Name',0,'Middle Name','Emp_Second_Name'
					End

			IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Fields_Name= 'Category')
					Begin
						Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields  WITH (NOLOCK)
						Exec P0040_Setting_Mandatory_Fields @Tran_ID,@Cmp_ID,'Employee','Middle-Name',0,'Middle Name','Emp_Second_Name'
					End
---------------------Add Submitted status for Timesheet Project(Added by Mukti(23122019)start)----------------------
						SELECT @Login_ID=Login_ID FROM T0011_LOGIN WITH (NOLOCK) where  Cmp_ID=@Cmp_ID and Is_Default=1

			IF Not Exists(Select 1 From T0040_Project_Status WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Project_Status='Submitted')
					Begin
						Select @Tran_ID = Isnull(Max(Project_Status_ID),0) + 1 From T0040_Project_Status  WITH (NOLOCK)
						Exec P0040_Project_Status @Tran_ID,'Submitted','','#33CC66',@Cmp_ID,@Login_ID,'I'
					End
---------------------Add Submitted status for Timesheet Project(Added by Mukti(23122019)end)----------------------					

			/* INSERTING DEFAULT DATA IN COMPANY DETAIL TABLE, FOR EFFECTIVE DATE WISE COMPANY NAME CHANGE FEATURE - ADDED BY RAMIZ ON 03/04/2019 */
			
			IF EXISTS(SELECT CM.CMP_ID FROM T0010_COMPANY_MASTER CM WITH (NOLOCK)
							LEFT OUTER JOIN T0011_COMPANY_DETAIL CD WITH (NOLOCK) ON CM.CMP_ID = CD.CMP_ID WHERE CD.CMP_ID IS NULL)
					 BEGIN
						INSERT INTO T0011_COMPANY_DETAIL
							(Cmp_Id, Cmp_Name, Cmp_Address, Old_Cmp_Name, Old_Cmp_Address, LoginId, Effect_Date, System_Date , Cmp_Header , Cmp_Footer)
						SELECT CM.Cmp_Id , CM.Cmp_Name , CM.Cmp_Address , '' , '' , 0 , CM.FROM_DATE,GETDATE() , CM.Cmp_Header , CM.Cmp_Footer
						FROM T0010_COMPANY_MASTER CM WITH (NOLOCK)
								LEFT OUTER JOIN T0011_COMPANY_DETAIL CD WITH (NOLOCK) ON CM.CMP_ID = CD.CMP_ID
						WHERE CD.CMP_ID IS NULL
					 END
					
						
				END	

	/*************************************** OTHER EXECUTION ENDS HERE *********************************/
	
	EXEC Default_Column_insert --- Added by Hardik 08/04/2019 for Default Column name in Schedule Email Form (SQL Job) where Customize InOut Sechedule
	EXEC P_Insert_Employee_Directory_Columns @CMP_Id --ADDED By Jimit 01052019 for default Employee Directory Columns Insert
	
	EXEC P_Insert_Relationship_Master @Cmp_ID -- Added by Nilesh Patel on 20/07/2019 -- Entry if Relationship is not exists
END


