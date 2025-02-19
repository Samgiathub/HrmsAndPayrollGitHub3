-- ======= Dont remove the developer comments 
-- #554 and #556 - Deepal - Add the isnull(@MaxTranID,0) condition
-- ======= Dont remove the developer comments 
CREATE PROCEDURE [dbo].[P_CUSTOMIZE_REPORTS_ENTRY]  
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  DECLARE @CustomizeReportFormID INT  
  SELECT @CustomizeReportFormID = Form_ID   
  FROM T0000_DEFAULT_FORM  WITH (NOLOCK)  
  WHERE Form_Name='Customize Report' And Page_Flag='AR'  
  
  DECLARE @Form_ID INT  
  DECLARE @Sort_ID INT  
  DECLARE @Sort_ID_Check INT   
  DECLARE @Page_Flag CHAR(2)  
  SET @Sort_ID = 1  
  SET @Sort_ID_Check = 1  
  SET @Page_Flag = 'AR'  
  
  /*********************************************  
  Menu Index : 1  
  Menu Name: Employee Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Employee Customize',  
   @Alias='Employee Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 2  
  Menu Name: Leave Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Leave Customize',  
   @Alias='Leave Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 3  
  Menu Name: Salary Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Salary Customize',  
   @Alias='Salary Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 4  
  Menu Name: Tax Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Tax Customize',  
   @Alias='Tax Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 5  
  Menu Name: Attendance Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Attendance Customize',  
   @Alias='Attendance Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 6  
  Menu Name: Asset Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Asset Customize',  
   @Alias='Asset Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 7  
  Menu Name: Claim Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Claim Customize',  
   @Alias='Claim Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 8  
  Menu Name: Others Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='Others Customize',  
   @Alias='Others Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
  
  /*********************************************  
  Menu Index : 9  
  Menu Name: PF_ESIC Customize  
  *********************************************/  
  SET @Form_ID = 0  
  EXEC P0000_DEFAULT_FORM   
   @Form_ID = @Form_ID OUTPUT,  
   @Form_Name='PF_ESIC Customize',  
   @Alias='PF_ESIC Customize',   
   @Under_Form_ID=@CustomizeReportFormID,  
   @Page_Flag=@Page_Flag,  
   @Module_Name='Payroll',  
   @Form_Type=1,  
   @Sort_ID=@Sort_ID,   
   @Sort_ID_Check=@Sort_ID_Check OUTPUT,  
   @Form_URL='',  
   @Is_Active_For_Menu = 1  
    
  
  /*Customized Report->Employee->Employee List*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee List',@SortID=1,@ReportID=1  
  
  /*Customized Report->Employee->Employee Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Details',@SortID=2,@ReportID=31  
  
  /*Customized Report->Employee->Blood Group*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Blood Group',@SortID=3,@ReportID=3  
  
  /*Customized Report->Employee->PAN Card*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='PAN Card',@SortID=4,@ReportID=4  
  
  /*Customized Report->Employee->ESIC No*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='ESIC No',@SortID=5,@ReportID=5  
  
  /*Customized Report->Employee->Employee Joining List*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Joining List',@SortID=6,@ReportID=9  
  
  /*Customized Report->Employee->Employee Man Power*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Man Power',@SortID=7,@ReportID=10  
  
  /*Customized Report->Employee->Employee Data History*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Data History',@SortID=8,@ReportID=11  
  
  /*Customized Report->Employee->Dependent Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Dependent Detail',@SortID=9,@ReportID=13  
  
  /*Customized Report->Employee->Reporting Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Reporting Detail',@SortID=10,@ReportID=15  
  
  /*Customized Report->Employee->Qualification Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Qualification Detail',@SortID=11,@ReportID=16  
  
  /*Customized Report->Employee->Skill Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Skill Details',@SortID=12,@ReportID=17  
  
  /*Customized Report->Employee->Experience Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Experience Details',@SortID=13,@ReportID=18  
  
  /*Customized Report->Employee->Document CheckList*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Document CheckList',@SortID=14,@ReportID=19  
  
  /*Customized Report->Employee->Employee Privilege Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Privilege Detail',@SortID=15,@ReportID=22  
    
  /*Customized Report->Employee->Employee PF Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee PF Status',@SortID=16,@ReportID=36  
  
  /*Customized Report->Employee->Employee License Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee License Details',@SortID=17,@ReportID=38  
  
  /*Customized Report->Employee->Employee Immigration Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Immigration Details',@SortID=18,@ReportID=39  
  
  /*Customized Report->Employee->Employee Reference Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Reference Details',@SortID=19,@ReportID=41  
  
  /*Customized Report->Employee->Employee Strength*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Strength',@SortID=20,@ReportID=42  
  
  /*Customized Report->Employee->Employee Manager History*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Manager History',@SortID=21,@ReportID=43  
  
  /*Customized Report->Employee->Medical Checkup Diagnosis*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Medical Checkup Diagnosis',@SortID=22,@ReportID=61  
  
  /*Customized Report->Employee->Employee Nominee Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Nominee Details',@SortID=23,@ReportID=62  
  
  /*Customized Report->Employee->Employee Transfer Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Transfer Report',@SortID=24,@ReportID=72  
  
  /*Customized Report->Employee->Manpower Details(Branch Wise)*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Manpower Details(Branch Wise)',@SortID=25,@ReportID=73  
  
  /*Customized Report->Employee->Trainee/Probation Due List*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Trainee/Probation Due List',@SortID=26,@ReportID=76  
  
  /*Customized Report->Employee->Trainee/Probation Conformation List*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Trainee/Probation Conformation List',@SortID=27,@ReportID=77  
  
  /*Customized Report->Employee->Left Employee List*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Left Employee List',@SortID=28,@ReportID=117  
    
  /*Customized Report->Employee->Employee Performance*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Performance',@SortID=29,@ReportID=125  
    
  /*Customized Report->Employee->Employee Exit Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Exit Details',@SortID=30,@ReportID=129  
  
  /*Customized Report->Employee->Employee Exit Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Skill & Certificate Report',@SortID=31,@ReportID=163  
  
  /*Customized Report->Leave->Leave Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Details',@SortID=1,@ReportID=8  
   /*Customized Report->Leave-> Customize Leave*/    
 --- EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Customize Leave ',@SortID=8,@ReportID=81 
  
  /*Customized Report->Leave->Leave Used with Balance*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Used with Balance',@SortID=2,@ReportID=48  
  
  /*Customized Report->Leave->Leave Used Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Used Details',@SortID=3,@ReportID=49  
  
  /*Customized Report->Leave->Leave Wise Encash*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Wise Encash',@SortID=4,@ReportID=50  
  
  /*Customized Report->Leave->Leave Balance With Amount*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Balance With Amount',@SortID=5,@ReportID=56  
  
  /*Customized Report->Leave->Leave Summary Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Leave Summary Report',@SortID=6,@ReportID=71  
  
  /*Customized Report->Leave->Yearly Leave Transaction*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Leave',@TypeID=1,@ReportName='Yearly Leave Transactions',@SortID=7,@ReportID=104  
  
  /*Customized Report->Salary->CTC*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='CTC',@SortID=1,@ReportID=2  
  
  /*Customized Report->Salary->Salary Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Register',@SortID=2,@ReportID=6  
  
  /*Customized Report->Salary->Salary Register with Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Register with Details',@SortID=3,@ReportID=7  
  
  /*Customized Report->Salary->Arrear Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Arrear Register',@SortID=4,@ReportID=12  
  
  /*Customized Report->Salary->Increment History*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Increment History',@SortID=5,@ReportID=21  
  
  /*Customized Report->Salary->Non PF Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Non PF Report',@SortID=6,@ReportID=27  
  
  /*Customized Report->Salary->Bonus Report(Month Wise)*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Bonus Report(Month Wise)',@SortID=7,@ReportID=28  
  
  /*Customized Report->Salary->Bonus Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Bonus Register',@SortID=8,@ReportID=32  
  
  /*Customized Report->Salary->Salary Summary Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Summary Report',@SortID=9,@ReportID=34  
  
  /*Customized Report->Salary->Yearly Salary Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Yearly Salary Register',@SortID=10,@ReportID=40  
  
  /*Customized Report->Salary->FNF Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='FNF Register',@SortID=11,@ReportID=53  
  
  /*Customized Report->Salary->Employee Reimbursement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Employee Reimbursement',@SortID=12,@ReportID=54  
  
  /*Customized Report->Salary->Salary Group Wise Summary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Group Wise Summary',@SortID=13,@ReportID=55  
  
  /*Customized Report->Salary->Salary Group Wise Summary with Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Group Wise Summary with Detail',@SortID=14,@ReportID=60  
  
  /*Customized Report->Salary->Earn Deduction Export*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Earn Deduction Export',@SortID=15,@ReportID=63  
  
  /*Customized Report->Salary->Monthly Reimbursement Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Monthly Reimbursement Register',@SortID=16,@ReportID=64  
  
  /*Customized Report->Salary->Journal Entry for Salaries & Allowances*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Journal Entry for Salaries & Allowances',@SortID=17,@ReportID=66  
  
  /*Customized Report->Salary->Payment Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Payment Register',@SortID=18,@ReportID=70  
  
  /*Customized Report->Salary->Last Drawn Salary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Last Drawn Salary',@SortID=19,@ReportID=103  
  
  /*Customized Report->Salary->Salary Settelment*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Settelment',@SortID=20,@ReportID=106  
  
  /*Customized Report->Salary->Salary Variation Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Variation Report',@SortID=21,@ReportID=109  
  
  /*Customized Report->Salary->Yearly Payment Summary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Yearly Payment Summary',@SortID=22,@ReportID=113  
  
  /*Customized Report->Salary->Bank Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Bank Statement',@SortID=23,@ReportID=114  
  
  /*Customized Report->Salary->Last Paid Allowance*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Last Paid Allowance',@SortID=24,@ReportID=115  
  
  /*Customized Report->Salary->Salary Variance Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='Salary Variance Report',@SortID=25,@ReportID=122 
    
  /*Customized Report->Salary->LWF Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='LWF Eligible Employees',@SortID=26,@ReportID=126   
  
  /*Customized Report->Salary-> LWP Deduction Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Salary',@TypeID=2,@ReportName='LWP Deduction Report',@SortID=27,@ReportID=128  

  /*Customized Report->Tax->IT Preparation*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Tax',@TypeID=3,@ReportName='IT Preparation',@SortID=1,@ReportID=20  
  
  /*Customized Report->Tax->Pending IT Declaration*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Tax',@TypeID=3,@ReportName='Pending IT Declaration',@SortID=2,@ReportID=33  
  
  /*Customized Report->Tax->Perquisites Valuation*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Tax',@TypeID=3,@ReportName='Perquisites Valuation',@SortID=3,@ReportID=37  
  
  /*Customized Report->Tax->Form 24Q*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Tax',@TypeID=3,@ReportName='Form 24Q',@SortID=4,@ReportID=52  
  
  /*Customized Report->Others->Privilege Form Rights Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Privilege Form Rights Detail',@SortID=1,@ReportID=23  
  
  /*Customized Report->Others->Pending Loan Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Pending Loan Detail',@SortID=2,@ReportID=29  
  
  /*Customized Report->Others->For Send SMS IN Bulk */  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='For Send SMS IN Bulk',@SortID=3,@ReportID=30  
  
  /*Customized Report->Others->State wise Minimum Wages*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='State wise Minimum Wages',@SortID=4,@ReportID=47  
  
  /*Customized Report->Others->Uniform Costing Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Uniform Costing Report',@SortID=16,@ReportID=136  
  
  /*Customized Report->Others->Night Halt Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Night Halt Detail',@SortID=5,@ReportID=59  
  
  /*Customized Report->Others->GPF Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='GPF Statement',@SortID=6,@ReportID=65  
  
  /*Customized Report->Others->Branchwise Working */  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Branchwise Working',@SortID=7,@ReportID=74  
  
  /*Customized Report->Others->Incentive Scheme Export */  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Incentive Scheme Export',@SortID=8,@ReportID=79  
  
  /*Customized Report->Others->AX Export*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='AX Export',@SortID=9,@ReportID=99  
  
  /*Customized Report->Others->AX Export New*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='AX Export New',@SortID=10,@ReportID=100  
  
  /*Customized Report->Others->AX Consolidated*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='AX Consolidated',@SortID=11,@ReportID=101  
  
  /*Customized Report->Others->Bond Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='Bond Status',@SortID=12,@ReportID=119  
  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Others',@TypeID=4,@ReportName='AX Mapping Navision',@SortID=13,@ReportID=160  
  
  /*Customized Report->Attendance->In-Out Summary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='In-Out Summary',@SortID=1,@ReportID=24  
  
  /*Customized Report->Attendance->Late Mark  Summary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Late Mark  Summary',@SortID=2,@ReportID=25  
  
  /*Customized Report->Attendance->Daily Head Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Daily Head Report',@SortID=3,@ReportID=35  
  
  /*Customized Report->Attendance->Attendance Register(Consolidated)*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Attendance Register(Consolidated)',@SortID=4,@ReportID=51  
  
  /*Customized Report->Attendance->Daily ShiftWise Attendance Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Daily ShiftWise Attendance Report',@SortID=5,@ReportID=69  
  
  /*Customized Report->Attendance->OverTime Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='OverTime Register',@SortID=6,@ReportID=75  
  
  /*Customized Report->Attendance->Last Absentism Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Last Absentism Report',@SortID=7,@ReportID=78  
  
  /*Customized Report->Attendance->Attendance with Canteen In Out Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Attendance with Canteen In Out Report',@SortID=8,@ReportID=107  
  
  /*Customized Report->Attendance->Absent Hour Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Absent Hour Report',@SortID=9,@ReportID=116  
  
  /*Customized Report->Attendance->Canteen Attendance Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Canteen Attendance Register',@SortID=10,@ReportID=118  
  
  /*Customized Report->Attendance->Canteen Attendance Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Break Deviation Report',@SortID=11,@ReportID=120  
    
  /*Customized Report->Attendance-> Attendance Request Register*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Attendance Request Report',@SortID=11,@ReportID=123 
  
  /*Customized Report->Attendance-> Daily Man-Days Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Daily Man-Days Report',@SortID=11,@ReportID=124  
  
  /*Customized Report->Attendance-> Daily Man-Days Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Daily Attendance Report',@SortID=11,@ReportID=127  
    
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='In-Out FormD',@SortID=11,@ReportID=147  
  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Attendance',@TypeID=5,@ReportName='Corporate Office Report',@SortID=11,@ReportID=148  

  /*Customized Report->Asset->Asset Allocation Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Asset',@TypeID=7,@ReportName='Asset Allocation Details Report',@SortID=1,@ReportID=67  
  
  /*Customized Report->Asset->Pending Asset Installment Details*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Asset',@TypeID=7,@ReportName='Pending Asset Installment Details Report',@SortID=2,@ReportID=68  
  
  /*Customized Report->Asset->Asset Details Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Asset',@TypeID=7,@ReportName='Asset Details Report',@SortID=3,@ReportID=102  
  
  /*Customized Report->Claim->Claim Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Claim',@TypeID=8,@ReportName='Claim Status',@SortID=1,@ReportID=111  
  
  /*Customized Report->Claim->Claim Payment Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Claim',@TypeID=8,@ReportName='Claim Payment Status',@SortID=2,@ReportID=112  
  
  /*Customized Report->Claim->Claim Payment Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Claim',@TypeID=8,@ReportName='Claim - Travel Expense Status',@SortID=3,@ReportID=121   
    
  /*Customized Report->Claim->Claim Payment Status*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Claim',@TypeID=8,@ReportName='Claim Approval',@SortID=4,@ReportID=131   
  
  /*Customized Report->PF & ESIC->PF Report*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='PF Report',@SortID=1,@ReportID=26  
  
  /*Customized Report->PF & ESIC->Employee PF Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Employee PF Detail',@SortID=2,@ReportID=57  
  
  /*Customized Report->PF & ESIC->PF Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='PF Statement Customized',@SortID=3,@ReportID=110 
  
  /*Customized Report->PF & ESIC->Employee ESIC Detail*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Employee ESIC Detail',@SortID=4,@ReportID=58  
    
  /*Customized Report->PF & ESIC->ESIC Summary*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='ESIC Summary',@SortID=5,@ReportID=108  
  
  /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Employee ESIC Statement',@SortID=6,@ReportID=105    
  
   /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Form A',@SortID=6,@ReportID=137  
  
   /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Form B',@SortID=7,@ReportID=138  

     /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Form C',@SortID=6,@ReportID=139  

      /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Form D',@SortID=6,@ReportID=140  

      /*Customized Report->PF & ESIC->Employee ESIC Statement*/  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='PF & ESIC',@TypeID=9,@ReportName='Form V',@SortID=6,@ReportID=144 
  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Survey Details',@SortID=31,@ReportID=130  
    
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Canteen',@TypeID=10,@ReportName='Canteen Report - Employee Wise',@SortID=1,@ReportID=141  
    
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Canteen',@TypeID=10,@ReportName='Canteen Details Report',@SortID=2,@ReportID=142  
    
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Canteen',@TypeID=10,@ReportName='Canteen Exemption Report',@SortID=3,@ReportID=143  
  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Canteen',@TypeID=10,@ReportName='Canteen Application Details Report',@SortID=4,@ReportID=164  
  
  EXEC P0250_CUSTOMIZED_REPORT @ReportType ='Employee',@TypeID=0,@ReportName='Employee Template Details',@SortID=32,@ReportID=162
  

  /**********************************PRIVILEGE ENTRY*******************************/  
  BEGIN  

   DECLARE @MaxTranID INT  
   SELECT @MaxTranID = MAX(Trans_Id) FROM T0050_PRIVILEGE_DETAILS WITH (NOLOCK)  

   INSERT INTO T0050_PRIVILEGE_DETAILS   
   SELECT IsNull(T.Trans_Id, Row_ID + isnull(@MaxTranID,0)) As Trans_Id, T.Privilege_ID,T.Cmp_Id, T.Form_ID,  
     IsNull(T.Is_View,1) As Is_View, IsNull(T.Is_Edit,1) As Is_Edit, IsNull(T.Is_Save,1) As Is_Save, IsNull(T.Is_Delete,1) As Is_Delete, IsNull(T.Is_Print,1) As Is_Print  
   FROM (  
			select  PD.Trans_Id, T.Privilege_ID, T.Cmp_Id, T.Form_Id, PD.Is_View, PD.Is_Edit, PD.Is_Save, PD.Is_Delete, PD.Is_Print,  
			ROW_NUMBER() OVER(ORDER BY T.Cmp_ID, T.Privilege_ID, T.Form_ID) As Row_ID  
			from (
				SELECT * FROM (SELECT  Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK)  
				WHERE Under_Form_ID=6714) C CROSS JOIN T0020_PRIVILEGE_MASTER P WITH (NOLOCK) 
		    ) T  
       LEFT OUTER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON T.Form_ID=PD.Form_Id AND T.Privilege_ID=PD.Privilage_ID  
     ) T  
   Where T.Trans_Id IS NULL  

   SELECT @MaxTranID = MAX(Trans_Id) FROM T0050_PRIVILEGE_DETAILS WITH (NOLOCK)  
   INSERT INTO T0050_PRIVILEGE_DETAILS   
   SELECT IsNull(T.Trans_Id, Row_ID + isnull(@MaxTranID,0)) As Trans_Id, T.Privilege_ID,T.Cmp_Id, T.Form_ID,  
     IsNull(T.Is_View,1) As Is_View, IsNull(T.Is_Edit,1) As Is_Edit, IsNull(T.Is_Save,1) As Is_Save, IsNull(T.Is_Delete,1) As Is_Delete, IsNull(T.Is_Print,1) As Is_Print  
   FROM (  
     select  PD.Trans_Id, T.Privilege_ID, T.Cmp_Id, T.Form_Id, PD.Is_View, PD.Is_Edit, PD.Is_Save, PD.Is_Delete, PD.Is_Print,  
       ROW_NUMBER() OVER(ORDER BY T.Cmp_ID, T.Privilege_ID, T.Form_ID) As Row_ID  
     from (SELECT * FROM T0250_CUSTOMIZED_REPORT C WITH (NOLOCK) CROSS JOIN T0020_PRIVILEGE_MASTER P WITH (NOLOCK) ) T  
       LEFT OUTER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON T.Form_ID=PD.Form_Id AND T.Privilege_ID=PD.Privilage_ID  
     ) T  
   Where T.Trans_Id IS NULL  
  END          
 END  
  
  
  
