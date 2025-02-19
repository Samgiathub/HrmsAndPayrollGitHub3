

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE Procedure [dbo].[SP_Import_Allowance_Data_New_Old]
	@Cmp_ID						numeric, 
	@Emp_Id						numeric,
	@Str_Xml					xml, 
	@GUID						Varchar(2000) = '',
	@Log_Status					numeric output ,
	@Increment_Id				numeric output
AS
	Declare @Basic_Salary				numeric(18,2)
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Set @Log_Status = 0
	If @Basic_Salary is null
		set @Basic_Salary = 0
		
	Set @Str_Xml = REPLACE(cast(@Str_Xml as nvarchar(max)),'Table1','Sheet1OLE')
	
	IF OBJECT_ID('tempdb..#Temptable') IS NOT NULL 
			DROP TABLE #Temptable
		
    select 
    Sheet1OLE.value('(Emp_Code/text())[1]','Varchar(20)') as Emp_Code,
    Sheet1OLE.value('(Emp_Name/text())[1]','Varchar(100)') as Emp_Name,
    Sheet1OLE.value('(Branch_Name/text())[1]','Varchar(50)') as Branch_Name,
    Sheet1OLE.value('substring((Joining_Date/text())[1], 1, 19)','datetime') as Increment_Effective_Date,
    Sheet1OLE.value('(Increment_Type/text())[1]','Varchar(50)') as Increment_Type,
    Sheet1OLE.value('(Entry_Type/text())[1]','Varchar(30)') as Entry_Type,
    Sheet1OLE.value('(Grade/text())[1]','Varchar(50)') as Grade,
    Sheet1OLE.value('(Designation/text())[1]','Varchar(50)') as Designation,
    Sheet1OLE.value('(Department/text())[1]','Varchar(50)') as Dept,
    isnull(Sheet1OLE.value('(Basic_Salary/text())[1]','Numeric(18,2)'),0) as Basic_Salary,
    isnull(Sheet1OLE.value('(Gross_Salary/text())[1]','Numeric(18,2)'),0) as Gross,
    Sheet1OLE.value('(Reason_Name/text())[1]','Varchar(500)') as Reason_Name,
    Sheet1OLE.value('(FNF_x0020_Recovery/text())[1]','Numeric(18,2)') as [FNF Recovery],
	Sheet1OLE.value('(Other_Bonus/text())[1]','Numeric(18,2)') as Other_Bonus,
	Sheet1OLE.value('(Salary_CTC/text())[1]','Numeric(18,2)') as Salary_CTC,
	Sheet1OLE.value('(FNF_x0020_Test/text())[1]','Numeric(18,2)') as [FNF Test],
	Sheet1OLE.value('(Employee_x0020_Retention/text())[1]','Numeric(18,2)') as [Employee Retention],
	Sheet1OLE.value('(Ecogreen_x0020_Allowance/text())[1]','Numeric(18,2)') as [Ecogreen Allowance],
	Sheet1OLE.value('(Transport_Allowance_BG/text())[1]','Numeric(18,2)') as Transport_Allowance_BG,
	Sheet1OLE.value('(Conveyance_AIA/text())[1]','Numeric(18,2)') as Conveyance_AIA,
	Sheet1OLE.value('(Quarterly_Reim/text())[1]','Numeric(18,2)') as Quarterly_Reim,
	Sheet1OLE.value('(Allowance_x0020_Test/text())[1]','Numeric(18,2)') as [Allowance Test],
	Sheet1OLE.value('(Deputation_x0020_Allowance/text())[1]','Numeric(18,2)') as [Deputation Allowance],
	Sheet1OLE.value('(R_x0020_TEST/text())[1]','Numeric(18,2)') as [R TEST],
	Sheet1OLE.value('(MED_x0020_REIM/text())[1]','Numeric(18,2)') as [MED REIM],
	Sheet1OLE.value('(vfvfdvfdvd/text())[1]','Numeric(18,2)') as vfvfdvfdvd,
	Sheet1OLE.value('(On_x0020_Time_x0020_Arrival_x0020_Perormance/text())[1]','Numeric(18,2)') as [On Time Arrival Perormance],
	Sheet1OLE.value('(Housing_x0020_Rent_x0020_Allowance/text())[1]','Numeric(18,2)') as [Housing Rent Allowance],
	Sheet1OLE.value('(Dearness_x0020_Allowance/text())[1]','Numeric(18,2)') as [Dearness Allowance],
	Sheet1OLE.value('(Overtime_x0020_Allowance/text())[1]','Numeric(18,2)') as [Overtime Allowance],
	Sheet1OLE.value('(City_x0020_Compensatory_x0020_Allowance/text())[1]','Numeric(18,2)') as [City Compensatory Allowance],
	Sheet1OLE.value('(Children_x0020_Education_x0020_Allowance/text())[1]','Numeric(18,2)') as [Children Education Allowance],
	Sheet1OLE.value('(Transportation_x0020_Allowance/text())[1]','Numeric(18,2)') as [Transportation Allowance],
	Sheet1OLE.value('(Conveyance_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Conveyance Reimbursement],
	Sheet1OLE.value('(Arrears_x0020_Basic/text())[1]','Numeric(18,2)') as [Arrears Basic],
	Sheet1OLE.value('(Leave_x0020_Travell_x0020_Allowance/text())[1]','Numeric(18,2)') as [Leave Travell Allowance],
	Sheet1OLE.value('(Medical_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Medical Reimbursement],
	Sheet1OLE.value('(Telephone_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Telephone Reimbursement],
	Sheet1OLE.value('(Business_x0020_Attire_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Business Attire Reimbursement],
	Sheet1OLE.value('(Car_x0020_Expenses_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Car Expenses Reimbursement],
	Sheet1OLE.value('(AIAAttendanceAllow/text())[1]','Numeric(18,2)') as AIAAttendanceAllow,
	Sheet1OLE.value('(Training_x0020_Expense_x0020_Reim/text())[1]','Numeric(18,2)') as [Training Expense Reim],
	Sheet1OLE.value('(Gratuity/text())[1]','Numeric(18,2)') as Gratuity,
	Sheet1OLE.value('(Ex_x0020_Gratia_x0020_Bonus/text())[1]','Numeric(18,2)') as [Ex Gratia Bonus],
	Sheet1OLE.value('(AUTOPAID_x0020_BONUS/text())[1]','Numeric(18,2)') as [AUTOPAID BONUS],
	Sheet1OLE.value('(Conveyance/text())[1]','Numeric(18,2)') as Conveyance,
	Sheet1OLE.value('(Bonus/text())[1]','Numeric(18,2)') as Bonus,
	Sheet1OLE.value('(Employee_x0020_Award/text())[1]','Numeric(18,2)') as [Employee Award],
	Sheet1OLE.value('(Attendance_x0020_Allowance/text())[1]','Numeric(18,2)') as [Attendance Allowance],
	Sheet1OLE.value('(Production_x0020_Bonus/text())[1]','Numeric(18,2)') as [Production Bonus],
	Sheet1OLE.value('(Production_x0020_Variable/text())[1]','Numeric(18,2)') as [Production Variable],
	Sheet1OLE.value('(Insurance_x0020_Payment/text())[1]','Numeric(18,2)') as [Insurance Payment],
	Sheet1OLE.value('(Production_x0020_Bonus2/text())[1]','Numeric(18,2)') as [Production Bonus2],
	Sheet1OLE.value('(Telephon_bill/text())[1]','Numeric(18,2)') as Telephon_bill,
	Sheet1OLE.value('(Production_x0020_Variable2/text())[1]','Numeric(18,2)') as [Production Variable2],
	Sheet1OLE.value('(Incentive_Import/text())[1]','Numeric(18,2)') as Incentive_Import,
	Sheet1OLE.value('(Benefit_Fix/text())[1]','Numeric(18,2)') as Benefit_Fix,
	Sheet1OLE.value('(Transport_x0020_Assist/text())[1]','Numeric(18,2)') as [Transport Assist],
	Sheet1OLE.value('(Extra_x0020_Pay/text())[1]','Numeric(18,2)') as [Extra Pay],
	Sheet1OLE.value('(Leave_x0020_Allowance/text())[1]','Numeric(18,2)') as [Leave Allowance],
	Sheet1OLE.value('(Fix_x0020_Allowance/text())[1]','Numeric(18,2)') as [Fix Allowance],
	Sheet1OLE.value('(Canteen_x0020_Amount1/text())[1]','Numeric(18,2)') as [Canteen Amount1],
	Sheet1OLE.value('(Overtime_x0020_Payment/text())[1]','Numeric(18,2)') as [Overtime Payment],
	Sheet1OLE.value('(Special_x0020_Arrear/text())[1]','Numeric(18,2)') as [Special Arrear],
	Sheet1OLE.value('(Company_x0020_ESIC_x0020_Contirbution/text())[1]','Numeric(18,2)') as [Company ESIC Contirbution],
	Sheet1OLE.value('(Company_x0020_PF_x0020_Contribution/text())[1]','Numeric(18,2)') as [Company PF Contribution],    
	Sheet1OLE.value('(Special_x0020_Allowance/text())[1]','Numeric(18,2)') as [Special Allowance],
	Sheet1OLE.value('(Special_x0020_Gross/text())[1]','Numeric(18,2)') as [Special Gross],
	Sheet1OLE.value('(Employee_x0020_PF/text())[1]','Numeric(18,2)') as [Employee PF],
	Sheet1OLE.value('(Employee_x0020_ESIC_x0020_Contirbution/text())[1]','Numeric(18,2)') as [Employee ESIC Contirbution],
	Sheet1OLE.value('(TDS/text())[1]','Numeric(18,2)') as TDS,
	Sheet1OLE.value('(General_x0020_Providence_x0020_Fund/text())[1]','Numeric(18,2)') as [General Providence Fund],
	Sheet1OLE.value('(Advance/text())[1]','Numeric(18,2)') as Advance,
	Sheet1OLE.value('(Tour_x0020_Deduction/text())[1]','Numeric(18,2)') as [Tour Deduction],
	Sheet1OLE.value('(Other_x0020_Deduction/text())[1]','Numeric(18,2)') as [Other Deduction],
	Sheet1OLE.value('(Other_TDS_CHECK/text())[1]','Numeric(18,2)') as Other_TDS_CHECK,
	Sheet1OLE.value('(Canteen_x0020_Payment/text())[1]','Numeric(18,2)') as [Canteen Payment],
	Sheet1OLE.value('(NPF1/text())[1]','Numeric(18,2)') as NPF1,
	Sheet1OLE.value('(NPF2/text())[1]','Numeric(18,2)') as NPF2,
	Sheet1OLE.value('(NPF3/text())[1]','Numeric(18,2)') as NPF3,
	Sheet1OLE.value('(Transport_x0020_Allowance_Slab/text())[1]','Numeric(18,2)') as Transport_Allowance_Slab,
	Sheet1OLE.value('(Business_Attire_Reimbursement__/text())[1]','Numeric(18,2)') as Business_Attire_Reimbursement__,
	Sheet1OLE.value('(Vehicle_x0020_Maintenance_x0020_Reimbursement/text())[1]','Numeric(18,2)') as [Vehicle Maintenance Reimbursement],
	Sheet1OLE.value('(Vehicle_Maintenance_Reimbursement__/text())[1]','Numeric(18,2)') as Vehicle_Maintenance_Reimbursement__,    
	Sheet1OLE.value('(Books_x0020_And_x0020_Periodical/text())[1]','Numeric(18,2)') as [Books And Periodical],
	Sheet1OLE.value('(Books_x0020_N_x0020_Periodical/text())[1]','Numeric(18,2)') as [Books N Periodical],
	Sheet1OLE.value('(C_Telephone_x0020_Reimbursement/text())[1]','Numeric(18,2)') as C_Telephone_Reimbursement,
	Sheet1OLE.value('(C_Telephone_x0020_Reimbursement__/text())[1]','Numeric(18,2)') as C_Telephone_Reimbursement__,
	Sheet1OLE.value('(Special_x0020_Allowance_Corona/text())[1]','Numeric(18,2)') as [Special Allowance_Corona],
	Sheet1OLE.value('(Extra_x0020_OT_x0020_Payment/text())[1]','Numeric(18,2)') as [Extra OT Payment],
	Sheet1OLE.value('(Car_x0020_Retention/text())[1]','Numeric(18,2)') as [Car Retention],
	Sheet1OLE.value('(Variable_x0020_Payment/text())[1]','Numeric(18,2)') as [Variable Payment],
	Sheet1OLE.value('(Incentive_Worker/text())[1]','Numeric(18,2)') as Incentive_Worker,
	Sheet1OLE.value('(Incentive_x0020_Staff/text())[1]','Numeric(18,2)') as [Incentive Staff],
	Sheet1OLE.value('(Seniority_x0020_Awards/text())[1]','Numeric(18,2)') as [Seniority Awards],
	Sheet1OLE.value('(Bond_x0020_Return/text())[1]','Numeric(18,2)') as [Bond Return],
	Sheet1OLE.value('(Night_x0020_Halt/text())[1]','Numeric(18,2)') as [Night Halt],
	Sheet1OLE.value('(Interest_x0020_Subsidy_x0020_Amount/text())[1]','Numeric(18,2)') as [Interest Subsidy Amount],
	Sheet1OLE.value('(arrear/text())[1]','Numeric(18,2)') as arrear,
	Sheet1OLE.value('(Reference_x0020_Allowance/text())[1]','Numeric(18,2)') as [Reference Allowance],
	Sheet1OLE.value('(Other_x0020_Amount/text())[1]','Numeric(18,2)') as [Other Amount],
	Sheet1OLE.value('(Penalty/text())[1]','Numeric(18,2)') as Penalty,
	Sheet1OLE.value('(Attendance_x0020_AllowanceArkay/text())[1]','Numeric(18,2)') as [Attendance AllowanceArkay],
	Sheet1OLE.value('(Shift_x0020_Allowance_Arkay/text())[1]','Numeric(18,2)') as [Shift Allowance_Arkay],
	Sheet1OLE.value('(Extra_x0020_TDS/text())[1]','Numeric(18,2)') as [Extra TDS],
	Sheet1OLE.value('(Subsidy_x0020_interest/text())[1]','Numeric(18,2)') as [Subsidy interest],
	Sheet1OLE.value('(Arrears_x0020_Deduction/text())[1]','Numeric(18,2)') as [Arrears Deduction],
	Sheet1OLE.value('(Optional_x0020_Allowance1/text())[1]','Numeric(18,2)') as [Optional Allowance1],
	Sheet1OLE.value('(Hold_x0020_Salary_x0020_import/text())[1]','Numeric(18,2)') as [Hold Salary import],
	Sheet1OLE.value('(Performace_x0020_Incetive/text())[1]','Numeric(18,2)') as [Performace Incetive],
	Sheet1OLE.value('(Client_x0020_Tour_x0020_Claim/text())[1]','Numeric(18,2)') as [Client Tour Claim],
	Sheet1OLE.value('(Food_x0020_Allowance/text())[1]','Numeric(18,2)') as [Food Allowance],
	Sheet1OLE.value('(Travelling_x0020_Allowance/text())[1]','Numeric(18,2)') as [Travelling Allowance],
	Sheet1OLE.value('(Adhoc_x0020_Allowance/text())[1]','Numeric(18,2)') as [Adhoc Allowance],
	Sheet1OLE.value('(Night_Shift_Allowance/text())[1]','Numeric(18,2)') as Night_Shift_Allowance,
	Sheet1OLE.value('(IT_Tax/text())[1]','Numeric(18,2)') as IT_Tax,
	Sheet1OLE.value('(Employer_x0020_ESIC_x0020_Contribution/text())[1]','Numeric(18,2)') as [Employer ESIC Contribution],
	Sheet1OLE.value('(Quarterly_Amount/text())[1]','Numeric(18,2)') as Quarterly_Amount,
	Sheet1OLE.value('(Quarterly_Percentage/text())[1]','Numeric(18,2)') as Quarterly_Percentage,
    ROW_NUMBER() OVER (PARTITION BY @Emp_Id ORDER BY @Cmp_ID) AS Row_No,
    isnull(Sheet1OLE.value('(CTC/text())[1]','Numeric(18,2)'),0) as CTC,
    @GUID as [GUID]
    into #Temptable from @Str_Xml.nodes('/NewDataSet/Sheet1OLE') as Temp(Sheet1OLE)
			
BEGIN TRY
	
	Declare @Emp_code							varchar(10) 
	Declare @Emp_Name							varchar(100)
	Declare @Branch_Name						varchar(50)
	Declare @Increment_Effective_Date			DATETIME
	Declare @Increment_Type						varchar(50)
	Declare @Entry_Type							varchar(50)
	Declare @Grade								varchar(50)
	Declare @Designation						varchar(50)
	DECLARE @Dept								varchar(50)
	Declare @Gross								NUMERIC(18,2)
	Declare @CTC								NUMERIC(18,2)
	Declare @Reason_name						varchar(50)
	Declare @Increment_Id1						numeric 
	DECLARE @Row_No								numeric
	Declare @Log_Status_CurXML					numeric 
	
	set @Increment_Id = 0
	set @Log_Status = 0
	
	DECLARE CURXML CURSOR FOR  
		SELECT Emp_Code,Emp_Name,Branch_Name,Increment_Effective_Date,Increment_Type,Entry_Type,Grade
			  ,Designation,Dept,Basic_Salary,Gross, Reason_Name ,CTC,[GUID],Row_no 
		FROM #TEMPTABLE
	OPEN CURXML
		
		FETCH NEXT FROM CURXML INTO @Emp_Code, 
									@Emp_Name, @Branch_Name, @Increment_Effective_Date, @Increment_Type, @Entry_Type, 
									@Grade, @Designation, @Dept, @Basic_Salary, @Gross, @Reason_Name ,@CTC,@GUID,@Row_No
		WHILE @@FETCH_STATUS >= 0 
		BEGIN 
		
							--DECLARE @EMPID AS NUMERIC(18,0)
							DECLARE @EMPID AS varchar(20)
							SELECT @EMPID = EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE ALPHA_EMP_CODE = @Emp_Code
							
							IF OBJECT_ID('tempdb..#tmpCols') IS NOT NULL 
									DROP TABLE #tmpCols
							
							CREATE table #tmpCols(
								Emp_ID varchar(20),
								Allowance Varchar(100),
								Amount numeric(18,2)
							)
							
							DECLARE @table  NVARCHAR(257) = N'dbo.Test1129' 
							DECLARE @sql  NVARCHAR(MAX) = N'', @colNames  NVARCHAR(MAX) = N''		
							SELECT @colNames += ',' + QUOTENAME(name) 
							FROM sys.columns
							WHERE [object_id] = OBJECT_ID(@table) and column_id >= 14
							SET @sql = N'INSERT INTO #tmpCols
										 SELECT '''+ @EMPID +''' as Emp_Id ,Allowance, Amount 
										 FROM ' + @table + '
										 UNPIVOT
										(
											Amount FOR Allowance IN (' + STUFF(@colNames, 1, 1, '') + ')
										 ) AS up'
							exec(@sql)			 
							
							EXEC SP_IMPORT_ALLOWANCE_DATA 
								 @Cmp_ID ,@empId ,@Emp_Name ,@Branch_Name ,@Increment_Effective_Date ,@Increment_Type
								,@Entry_Type ,@Grade ,@Designation ,@Dept ,@Basic_Salary ,@Gross ,@Reason_Name
								,@Increment_Id1  output ,@Row_No ,@Log_Status_CurXML output ,@CTC ,@GUID
							
							IF @Increment_Id1 = 0 
							BEGIN
									set @Increment_Id = 0
							END
							IF @Log_Status_CurXML  = 1
							BEGIN
									set @Increment_Id = 0
									set @Log_Status = 1
							END
							IF @Increment_Id1 <> 0 
							BEGIN
								set @Increment_Id = @Increment_Id1
								DECLARE @EMP_ID1		NUMERIC
								DECLARE @ALLOWANCE		VARCHAR(100)
								DECLARE @AMOUNT			NUMERIC
								DECLARE @LOG_STATUS1	NUMERIC 
								
								Set @Log_Status1 = 0
								
								DECLARE ALLOWCURSOR CURSOR FOR 
													SELECT Emp_Id1 ,Allowance,Amount FROM #tmpAllowDeductData where Amount is not NULL              
								OPEN ALLOWCURSOR
									FETCH NEXT FROM ALLOWCURSOR INTO @Emp_Id1,@Allowance ,@Amount
									 
									 	EXEC SP_Import_Allow_Deduct_Data 
									 	@Cmp_ID ,@Emp_Id1 ,@Increment_Id ,@Increment_Effective_Date
									 	,@Allowance ,@Amount ,@Row_No ,@Log_Status1 output ,@GUID
									
										IF @Log_Status1 = 1 
										BEGIN
												set @Increment_Id = 0
												set @Log_Status = 1
										END
										
										FETCH NEXT FROM ALLOWCURSOR INTO @Emp_Id1,@Allowance,@Amount
										
								CLOSE ALLOWCURSOR    
								DEALLOCATE ALLOWCURSOR	
							END -- End IF @Increment_Id <> 0 													
		FETCH NEXT FROM CURXML INTO @Emp_Code, @Emp_Name, @Branch_Name, @Increment_Effective_Date, @Increment_Type, @Entry_Type, 
									@Grade, @Designation, @Dept, @Basic_Salary, @Gross, @Reason_Name, @CTC,@GUID,@Row_No
		END --END WHILE LOOP @@FETCH_STATUS >= 0 
	CLOSE CURXML 
	DEALLOCATE CURXML
	END TRY
BEGIN CATCH
	Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Id,ERROR_MESSAGE()
	,CONVERT(varchar(11),@Increment_Effective_date,103),'Please check Company Id ,String XML'
	,GetDate(),'SP_Import_Allowance_Data_New',@GUID)
	set @Log_Status = 1
END CATCH;
RETURN
	

	


