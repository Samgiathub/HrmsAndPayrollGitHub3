

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_DEFAULT_FORM_IMPORT_DATA]
AS
	BEGIN		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @Form_ID INT
		DECLARE @Page_Flag CHAR(2)
		SET @Page_Flag = 'IP'

		DECLARE @Under_Form_ID INT
		SELECT @Under_Form_ID = Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) Where Form_Name LIKE  'Imports Data'

		DECLARE @Sort_ID INT 
		SET @Sort_ID = 7		

		DECLARE @Sort_ID_Check INT 
		SET @Sort_ID_Check = 1		

		/*OLD UPDATE*/		
		UPDATE	T
		SET		Page_Flag = 'IP'
		FROM	T0000_DEFAULT_FORM T
		WHERE	Form_Name IN ('Holiday Master Import','Tax on Other Components Import')
				AND Page_Flag = 'AR'
		/*END OF UPDATE*/

		/*********************************************
		Menu Index : 1
		Menu Name: Increment Application Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Increment Application Import',
			@Alias='Increment Application Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 2
		Menu Name: Multiple Leave Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Multiple Leave Opening Import',
			@Alias='Multiple Leave Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 3
		Menu Name: Sales Target Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Sales Target Import',
			@Alias='Sales Target Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Sales',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 4
		Menu Name: Tax on Other Components Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Tax on Other Components Import',
			@Alias='Tax on Other Components Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='PAYROLL',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 5
		Menu Name: Monthly Shift Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Monthly Shift Import',
			@Alias='Monthly Shift Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 6
		Menu Name: Incentive Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Incentive Import',
			@Alias='Incentive Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 7
		Menu Name: Machine Daily Efficiency Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Machine Daily Efficiency Import',
			@Alias='Machine Daily Efficiency Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Machine',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 8
		Menu Name: Machine Gradewise Overtime Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Machine Gradewise Overtime Import',
			@Alias='Machine Gradewise Overtime Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Machine',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 9
		Menu Name: Machine Monthly Allowance Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Machine Monthly Allowance Import',
			@Alias='Machine Monthly Allowance Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Machine',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 10
		Menu Name: Medical Detail Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Medical Detail Import',
			@Alias='Medical Detail Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 11
		Menu Name: Bond Approval Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Bond Approval Import',
			@Alias='Bond Approval Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Loan',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 12
		Menu Name: Branch Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Branch Import',
			@Alias='Branch Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 13
		Menu Name: Grade Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Grade Import',
			@Alias='Grade Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 14
		Menu Name: Department Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Department Import',
			@Alias='Department Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 15
		Menu Name: Designation Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Designation Import',
			@Alias='Designation Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 16
		Menu Name: Bank Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Bank Import',
			@Alias='Bank Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 17
		Menu Name: City Master Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='City Master Import',
			@Alias='City Master Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 18
		Menu Name: City Category Expense Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='City Category Expense Import',
			@Alias='City Category Expense Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 19
		Menu Name: Business Segment Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Business Segment Import',
			@Alias='Business Segment Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 20
		Menu Name: Cost Center Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Cost Center Import',
			@Alias='Cost Center Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 21
		Menu Name: Asset Master Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Asset Master Import',
			@Alias='Asset Master Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 22
		Menu Name: Asset Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Asset Import',
			@Alias='Asset Details',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 23
		Menu Name: Vendor Master Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Vendor Master Import',
			@Alias='Vendor Master Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 24
		Menu Name: Employee Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Import',
			@Alias='Employee Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 25
		Menu Name: Employee Update Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Update Import',
			@Alias='Employee Update Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 26
		Menu Name: Employee Transfer Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Transfer Import',
			@Alias='Employee Transfer Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 27
		Menu Name: Employee Nominees Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Nominees Import',
			@Alias='Employee Nominees Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 28
		Menu Name: Employee FamilyMember Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee FamilyMember Import',
			@Alias='Employee FamilyMember Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 29
		Menu Name: Employee Salary Cycle Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Salary Cycle Import',
			@Alias='Employee Salary Cycle Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 30
		Menu Name: Change Password Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Change Password Import',
			@Alias='Change Password Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 31
		Menu Name: Employee Scheme
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Scheme',
			@Alias='Employee Scheme',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 32
		Menu Name: Employee Weekoff Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Weekoff Import',
			@Alias='Employee Weekoff Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 33
		Menu Name: Reporting Manager Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Reporting Manager Import',
			@Alias='Reporting Manager Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 34
		Menu Name: Qualification Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Qualification Import',
			@Alias='Qualification Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 35
		Menu Name: Experience Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Experience Import',
			@Alias='Experience Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 36
		Menu Name: Earn/Ded Data Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Earn/Ded Data Import',
			@Alias='Earn/Ded Data Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 37
		Menu Name: Allow/Dedu Revised Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Allow/Dedu Revised Import',
			@Alias='Allow/Dedu Revised Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 38
		Menu Name: Bulk Increment Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Bulk Increment Import',
			@Alias='Bulk Increment Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 39
		Menu Name: Insurance Detail Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Insurance Detail Import',
			@Alias='Insurance Detail Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 40
		Menu Name: Cross Company Privilege Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Cross Company Privilege Import',
			@Alias='Cross Company Privilege Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 41
		Menu Name: License Detail Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='License Detail Import',
			@Alias='License Detail Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 42
		Menu Name: Reference Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Reference Import',
			@Alias='Reference Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 43
		Menu Name: Employee Left Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Left Import',
			@Alias='Employee Left Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 44
		Menu Name: Asset Allocation Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Asset Allocation Import',
			@Alias='Asset Allocation Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 45
		Menu Name: Leave Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Leave Opening Import',
			@Alias='Leave Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 46
		Menu Name: Leave Credit Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Leave Credit Import',
			@Alias='Leave Credit Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 47
		Menu Name: Leave Allowance Detail Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Leave Allowance Detail Import',
			@Alias='Leave Allowance Detail Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 48
		Menu Name: Leave Approval Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Leave Approval Import',
			@Alias='Leave Approval Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 49
		Menu Name: Loan Approval Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Loan Approval Import',
			@Alias='Loan Approval Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 50
		Menu Name: Loan Interest Subsidy
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Loan Interest Subsidy',
			@Alias='Loan Interest Subsidy',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 51
		Menu Name: Attendance(In/Out) Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Attendance(In/Out) Import',
			@Alias='Attendance(In/Out) Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 52
		Menu Name: Attendance Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Attendance Import',
			@Alias='Attendance Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 53
		Menu Name: Monthly Present Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Monthly Present Import',
			@Alias='Monthly Present Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 54
		Menu Name: Monthly Earn/Ded Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Monthly Earn/Ded Import',
			@Alias='Monthly Earn/Ded Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 55
		Menu Name: Allowance Days Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Allowance Days Import',
			@Alias='Allowance Days Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 56
		Menu Name: Grade Change Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Grade Change Import',
			@Alias='Grade Change Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 57
		Menu Name: Reimbursement Approval Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Reimbursement Approval Import',
			@Alias='Reimbursement Approval Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 58
		Menu Name: Advance Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Advance Import',
			@Alias='Advance Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 59
		Menu Name: Production Bonus/Variable Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Production Bonus/Variable Import',
			@Alias='Production Bonus/Variable Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 60
		Menu Name: Tax Declaration Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Tax Declaration Import',
			@Alias='Tax Declaration Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 61
		Menu Name: Product Details Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Product Details Import',
			@Alias='Product Details Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 62
		Menu Name: Estimated Amount Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Estimated Amount Import',
			@Alias='IT Estimated Amount Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 63
		Menu Name: GPF Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='GPF Opening Import',
			@Alias='GPF Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='GPF',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 64
		Menu Name: GPF Additional Amount Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='GPF Additional Amount Import',
			@Alias='GPF Additional Amount Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='GPF',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 65
		Menu Name: CPS Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='CPS Opening Import',
			@Alias='CPS Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='CPS',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 66
		Menu Name: Publish News Letter Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Publish News Letter Import',
			@Alias='News Announcement Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 67
		Menu Name: Transport Attendance Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Transport Attendance Import',
			@Alias='Transport Attendance Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 68
		Menu Name: Bonus Deduction Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Bonus Deduction Import',
			@Alias='Bonus Deduction Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 69
		Menu Name: Clearance Attribute Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Clearance Attribute Import',
			@Alias='Clearance Attribute Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 70
		Menu Name: Reimbursement Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Reimbursement Opening Import',
			@Alias='Reimbursement Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 71
		Menu Name: Uniform Opening Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Uniform Opening Import',
			@Alias='Uniform Opening Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1

		/*********************************************
		Menu Index : 72
		Menu Name: Holiday Master Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Holiday Master Import',
			@Alias='Holiday Master Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


		/*********************************************
		Menu Index : 73
		Menu Name: Claim Approval Import
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Claim Approval Import',
			@Alias='Claim Approval Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


	    /*********************************************
		Menu Index : 74
		Menu Name: Emergency Contact Import
		Added by ronakk 24052022
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Emergency Contact Import',
			@Alias='Emergency Contact Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


		/*********************************************
		Menu Index : 75
		Menu Name: Dynamic Hierarchy Import
		Added by ronakk 25052022
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Dynamic Hierarchy Import',
			@Alias='Dynamic Hierarchy Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1



		/*********************************************
		Menu Index : 76
		Menu Name: Contract Details Import
		Added by ronakk 27052022
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Contract Details Import',
			@Alias='Contract Details Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


		
			/*********************************************
		Menu Index : 77
		Menu Name: Geo Location Master Import
		Added by Mr.Mehul 12072022
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Geo Location Master Import',
			@Alias='Geo Location Master Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


			/*********************************************
		Menu Index : 78
		Menu Name: Employee Geo Location Import
		Added by Mr.Mehul 12072022
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Employee Geo Location Import',
			@Alias='Employee Geo Location Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1



			
		/*********************************************
		Menu Index : 79
		Menu Name: Skill Level Import
		Added by ronakk 12092023
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Skill Level Import',
			@Alias='Skill Level Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


			/*********************************************
		Menu Index : 80
		Menu Name: Cat. Skill Import
		Added by ronakk 12092023
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Cat. Skill Import',
			@Alias='Cat. Skill Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


				/*********************************************
		Menu Index : 81
		Menu Name: Sub Cat. Skill Import
		Added by ronakk 12092023
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Sub Cat. Skill Import',
			@Alias='Sub Cat. Skill Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


				/*********************************************
		Menu Index : 82
		Menu Name: Certificate Skill Mapping Import
		Added by ronakk 12092023
		*********************************************/
		SET @Form_ID = 0
		EXEC P0000_DEFAULT_FORM 
			@Form_ID = @Form_ID OUTPUT,
			@Form_Name='Certificate Skill Mapping Import',
			@Alias='Certificate Skill Mapping Import',	
			@Under_Form_ID=@Under_Form_ID,
			@Page_Flag=@Page_Flag,
			@Module_Name='Payroll',
			@Form_Type=1,
			@Sort_ID=@Sort_ID, 
			@Sort_ID_Check=@Sort_ID_Check OUTPUT,
			@Is_Active_For_Menu = 1


	END
