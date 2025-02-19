

--Created By rohit on 09012015 for Update payroll Form.
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Payroll_Form_Update]  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
begin

	update t0000_default_form set module_name='Payroll' where Form_Name='Professional Tax Setting' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Cost Center Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance Deduction Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Present Late Scenario' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='AD Slab Settings' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Performance Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Increment' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Gradewise Allowance' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Details' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Bonus Detail' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Performance Detail' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Advance' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Monthly Salary' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Manually Salary' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Daily' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Settlement' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='F F Settlement' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Gratuity Detail' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='TDS' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Declaration' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Limit' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Form Design' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Employee Perquisites' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Tax Planning' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Challan' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Challan' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Challan' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Challan Sett' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Payment Process' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='TDS Challan' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Cycle Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Cycle Transfer' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reverse Salary' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Approval' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Opening' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Opening Import' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='AX Mapping' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Minimum Wages Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Pay Scale Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Abstract Report Master' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Bulk Increment' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance/Reimbursement Approval' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee-Increment' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Reimbursement Sub Expense Detail' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Night Halt' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Night Halt Approve' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Night Halt Application Admin' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Interest Subsidy Approval' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Other Payment Process' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Seniority Calculation Process' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Payment Slip' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee PayScale Detail' and form_id>=6000 and form_id<6500
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Reports' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Reports' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Reports' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Reports' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='TAX Reports' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Gratuity Bonus HRIS' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Gratuity Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Salary Structure' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Slip Weekly Basis' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Register Daily Basis' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Register(Allo/Ded)' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Register With Settlement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance/Deduction Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Yearly Salary' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Bank Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance Export' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Statement Sett' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Challan' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Challan Sett' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Employer Contribution' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Statement for Inspection' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Pension Scheme-10C ' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Pension Scheme-10D' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF FORM 11' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF FORM 19 ' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF FORM 20 ' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Challan' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Challan Sett' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Statement Sett' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Employer' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Challan' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Statement Sett' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Form5' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='PT Form5A' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='LWF Statement FORM A' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Form 9-A' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='F & F Letter' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Increment Letter' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Income Tax Declaration' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Computation' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Form -16(IT)' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Tax Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='TDS Challan' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Bonus Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Bonus(Form C)' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Variance Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Gratuity' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Consolidated Annual Return' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Gratuity Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Approval' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Balance' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Slip' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reimbursement Slip' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Leave Balance with Amount' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Customize' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Customize' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Earn/Ded Data Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Bank Import' and form_id>=6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Monthly Earn/Ded Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Daily Earn/Ded Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Declaration Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Salary Cycle Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Insurance Detail Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Bulk Increment Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Allow/Dedu Revised Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='It Estimated Amount Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Cost Center Import' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Labour Hours Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Payment Process Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Interest Subsidy Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='LWF Statement' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance Status' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Night Halt Slip' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Certificate' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Claim Detail Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Incerment Summary' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Allowance/Deduction Revised Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Esic Component' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Leave Encash Amount' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Summary Bankwise' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Costing Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Project Cost' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Project Overhead Cost' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Collection Detail' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Payment Slip' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Calculation Report' and form_id>6700 and form_id<7000
	update t0000_default_form set module_name='Payroll' where Form_Name='Half Yearly Return Report' and form_id>6700 and form_id<7000
	
	
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Detail' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Performance Detail' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='IT Declaration Form' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Slip' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Advance' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Advance Application' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Advance Approval' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Advance Status' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Application' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reim/Claim Approval' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Warning Card' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Night Halt Application' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Rewards & Recognition' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee Reward' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Slip Member#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Yearly Salary Member#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Statement Member#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Preparation Member#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Form-16(IT) Member#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Salary Slip My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Yearly Salary My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='PF Statement My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Tax Preparation My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Form-16(IT) My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='CTC letter (Annexure) My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Income Tax Declaration My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='FORM 11 (PF) My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Reimbursement Slip My#' and form_id>7000 and form_id<8000
	update t0000_default_form set module_name='Payroll' where Form_Name='Employee CTC Report Member#' and form_id>7000 and form_id<8000
	
	
update t0000_default_form set module_name='Payroll' where Form_Name='Project Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Insurance/Medical Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Bank Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Claim' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Details' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Application' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Admin Loan LIC Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Payment' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Details' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Application' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Payment' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical Details' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical Setting Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Employee LTA Medical Detail' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical Application  Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical Payment' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical History' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='IT Acknowledgement' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Salary Advance Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Admin Advance Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement Approval' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Expense Type Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement Application' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Applications' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='PT Challan' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Approval - Help Desk' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Mode Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Employee AllowDedu Revised' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Canteen Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='ESIC Calculation Process' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Process Type Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Account - Desk' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Currency Master' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Currency Conversion' and form_id>=6000 and form_id<6500
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Reports' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee CTC' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee Insurance2' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Monthly Loan Payment' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Approval' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Number' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Statement Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Yearly Advance' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Yearly Attendance ' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Pending Advance' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee Overtime' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee Daily Overtime ' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form2' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form05' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form10' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form12A' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form3A-Yearly' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form6A-Yearly' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form13 (Revised)' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form 1(Declaration)' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form 3' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form 5' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form 6' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Form 7' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee Variance Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Leave Encashment paid' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Clearance Form' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Employee Insurance' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Leave Allowance Detail' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Approval Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Leave Allowance Detail Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Allowance Days Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='License Detail Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Product Details Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Attendance Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Attendance(In/Out) Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Monthly Present Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Interest Subsidy' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='City Category Expense Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Grade Change Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Reimbursement Approval Import' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Insurance Deduction' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Application Form' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Deviation Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Pending Loan Detail' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Statement' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Detail' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement Status' and form_id>6700 and form_id<7000

update t0000_default_form set module_name='Payroll' where Form_Name='Employee Insurance1' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Canteen Deduction' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Cash Voucher' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Consolidation Statement' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Monthly Abstract Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Journal Voucher Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Pay Bill Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='CPS' where Form_Name='CPS Balance Report' and form_id>6700 and form_id<7000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan LIC Status' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Claim' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Claim Status' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='LTA Medical History' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Details' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Approvals ' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement Approvals' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Approval' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Allowance/Reimbursement Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Allowance/Reimbursement Approval' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Claim_Approval_Superior' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Claims' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Optional Allowance' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Reports Member#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Approval Member#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Statement Report Member#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Reports My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Approval My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Statement Report My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Report My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Detail My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Statement My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Travel Settlement Status My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Register With Settlement My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Application Report Member#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Loan Application Report My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Asset Installment Statement My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Reimbursement Statement My#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='Payroll' where Form_Name='Payment Slip My#' and form_id>7000 and form_id<8000

--- hrms Forms

update t0000_default_form set module_name='HRMS' where Form_Name='HRMS' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Organization Organogram' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Employee Organogram' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Training Application' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Training History' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Training Chart' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Recruitment Request' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Interview Process' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Performance Appraisal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Define Goal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Employee Goal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Goal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Employee Goal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Performance Summary' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Employee PerformanceSummary' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Competency' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Review Employee Competency' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Recruitment Request Approval' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Candidate Approval' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Resume For Screening' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='KPI/PMS' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Organogram' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Recruitment' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Training' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Appraisal' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Employee Self Assessment Member#' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='HRMS' where Form_Name='Self Assessment Form My#' and form_id>7000 and form_id<8000


-- TimeSheet Form
update t0000_default_form set module_name='TIMESHEET' where Form_Name='ESS TimeSheet Entry' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='TIMESHEET' where Form_Name='ESS TimeSheet Detail' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='TIMESHEET' where Form_Name='ESS Timesheet Details' and form_id>7000 and form_id<8000
update t0000_default_form set module_name='TIMESHEET' where Form_Name='Time sheets' and form_id>7000 and form_id<8000

--Retaining Added by ronakk 27122023
update t0000_default_form set module_name='Retaining' where Form_Name='Employee Retaining'
update t0000_default_form set module_name='Retaining' where Form_Name='Assign Retaining Status'
update t0000_default_form set module_name='Retaining' where Form_Name='Retaining Rate Master'
update t0000_default_form set module_name='Retaining' where Form_Name='Retaining Payment Process'
update t0000_default_form set module_name='Retaining' where Form_Name='Final Retaining Payment'

--Incentive Added by ronakk 27122023
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive'
update t0000_default_form set module_name='Incentive' where Form_Name='Parameter Template'
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive Scheme'
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive Template'
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive Process'
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive Scheme Export'
update t0000_default_form set module_name='Incentive' where Form_Name='Incentive Import'

--Uniform Added by ronakk 27122023
update t0000_default_form set module_name='Uniform' where Form_Name='Employee Uniform'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Master'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Issue/Receive'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Requisition Application'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Requisition Approval'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Dispatch'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Stock Balance'
update t0000_default_form set module_name='Uniform' where Form_Name='Monthly Uniform Payment'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Costing Report'
update t0000_default_form set module_name='Uniform' where Form_Name='Uniform Opening Import'

-- Piece_Transaction Added by ronakk 27122023
update t0000_default_form set module_name='Piece_Transaction' where Form_Name='Piece Transaction'
update t0000_default_form set module_name='Piece_Transaction' where Form_Name='Product/SubProduct Master'
update t0000_default_form set module_name='Piece_Transaction' where Form_Name='Rate / Revised Assginment'
update t0000_default_form set module_name='Piece_Transaction' where Form_Name='Pieces Transaction'

--Bond Added by ronakk 27122023
update t0000_default_form set module_name='Bond' where Form_Name='Bond'
update t0000_default_form set module_name='Bond' where Form_Name='Bond Master'
update t0000_default_form set module_name='Bond' where Form_Name='Admin Bond Approval'
update t0000_default_form set module_name='Bond' where Form_Name='Bond Status'
update t0000_default_form set module_name='Bond' where Form_Name='Bond Approval Import'

--Canteen  Added by ronakk 27122023
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Punch'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Master'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Management'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Finger Print Details'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Application'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Deduction'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Dashboard'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Application'
update t0000_default_form set module_name='Canteen' where Form_Name='Mobile Canteen'
update t0000_default_form set module_name='Canteen' where Form_Name='Attendance with Canteen In Out Report'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Attendance Register'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Customize'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Report - Employee Wise'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Details Report'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Exemption Report'
update t0000_default_form set module_name='Canteen' where Form_Name='Canteen Application Report'

-- Grievance Added by ronakk 27122023
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Master'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Priority Master'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Cat. Master'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Committee Master'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Application'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Application Allocation'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Hearing'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Hearing Calendar'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Dashboard'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Application'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Application Allocation'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Hearing'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Application Allocation - Chairperson'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Hearing - Chairperson'
update t0000_default_form set module_name='Grievance' where Form_Name='Mobile Grievance'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Customize'
update t0000_default_form set module_name='Grievance' where Form_Name='Grievance Register'

--File_Management  Added by ronakk 27122023
update t0000_default_form set module_name='File_Management' where Form_Name='File Management'
update t0000_default_form set module_name='File_Management' where Form_Name='FM Type Master'
update t0000_default_form set module_name='File_Management' where Form_Name='File Admin Approval'
update t0000_default_form set module_name='File_Management' where Form_Name='File Application'
update t0000_default_form set module_name='File_Management' where Form_Name='File Approve'
update t0000_default_form set module_name='File_Management' where Form_Name='File History'
update t0000_default_form set module_name='File_Management' where Form_Name='File Dashboard'
update t0000_default_form set module_name='File_Management' where Form_Name='File Management'
update t0000_default_form set module_name='File_Management' where Form_Name='File Application'
update t0000_default_form set module_name='File_Management' where Form_Name='File Approve'
update t0000_default_form set module_name='File_Management' where Form_Name='File History'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Approve'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Approve_forward'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Approve_Forward_By'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Approve_Reivew'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Approve_Reivew_By'
update t0000_default_form set module_name='File_Management' where Form_Name='TD_Home_ESS_File_Application_Review_To'
update t0000_default_form set module_name='File_Management' where Form_Name='File Management Customize'
update t0000_default_form set module_name='File_Management' where Form_Name='File Management Register'


--Medical  Added by ronakk 27122023
update t0000_default_form set module_name='Medical' where Form_Name='Medical'
update t0000_default_form set module_name='Medical' where Form_Name='Medical Application'
update t0000_default_form set module_name='Medical' where Form_Name='Mobile Medical Treatment Application'
update t0000_default_form set module_name='Medical' where Form_Name='Medical Detail Import'
update t0000_default_form set module_name='Medical' where Form_Name='All Dependent Details'
update t0000_default_form set module_name='Medical' where Form_Name='Dependents Import Sample'
update t0000_default_form set module_name='Medical' where Form_Name='Medical Application Report'


end
