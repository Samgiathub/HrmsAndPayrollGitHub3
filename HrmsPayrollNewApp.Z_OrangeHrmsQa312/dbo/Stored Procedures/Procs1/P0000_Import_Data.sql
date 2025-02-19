



-- Created By rohit For Import Data on 09012016
CREATE PROCEDURE [dbo].[P0000_Import_Data]  
AS  
SET NOCOUNT ON
Begin

	TRUNCATE TABLE T0000_IMPORT_DATA  -- This Will delete all data with auto increment key
	
						/*-- This Number will Show you the Max Index --
						  *******************************************
						  ***************** 106  *********************
						  *******************************************
						 -- Please Update this Index if you Add New form -- */
	
	--Master Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Branch Import','Branch','6','Master',NULL,6014,'Branch Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Grade Import','Grade','7','Master',NULL,6015,'Grade Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Department Import','Department','8','Master',NULL,6016,'Department Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Designation Import','Designation','10','Master',NULL,6017,'Designation Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Bank Import','Bank','13','Master','Payroll',6037,'Bank Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('City Master Import','City Master','64','Master',NULL,6013,'State Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('City Category Expense Import','City Category Expense','65','Master','Payroll',NULL,'City Category Expense Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Business Segment Import','Business Segment','71','Master',NULL,NULL,'Business Segment Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Cost Center Import','Cost Center','72','Master','Payroll',NULL,'Cost Center Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Asset Master Import','Asset Master Import','76','Master','Payroll',NULL,'Asset Master') 
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('ASSET IMPORT','Asset Details','49','Master','Payroll',null,'Asset Details')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Vendor Master Import','Vendor Master Import','77','Master','Payroll',NULL,'Vendor Master')  --Mukti 18012016
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Holiday Master Import','Holiday Master','89','Master','Payroll',NULL,'Holiday Master')  --Added by Jaina 18-01-2018
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Geo Location Master Import','Geo Location Master','102','Master','Payroll',NULL,'Geo Location Master')  --Added by Mr.Mehul 12072022

	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Skill Level Import','Skill Level','103','Master','Payroll',NULL,'Skill Level Import')  --Added by Ronakk 12092023
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Cat. Skill Import','Cat. Skill','104','Master','Payroll',NULL,'Cat. Skill Import')  --Added by Ronakk 12092023
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Sub Cat. Skill Import','Sub Cat. Skill','105','Master','Payroll',NULL,'Sub Cat. Skill Import')  --Added by Ronakk 12092023
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Certificate Skill Mapping Import','Certificate Skill Mapping','106','Master','Payroll',NULL,'Certificate Skill Mapping Import')  --Added by Ronakk 12092023

	--Employee Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Import','Employee','0','Employee',NULL,NULL,'Employee Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Update Import','Employee Update','11','Employee',NULL,NULL,'Employee Master')
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Transfer Import','Employee Transfer','53','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Nominees Import','Employee Nominees','47','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee FamilyMember Import','Employee FamilyMember','48','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Salary Cycle Import','Employee Salary Cycle','50','Employee','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Change Password Import','Change Password','66','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Scheme','Employee Scheme','61','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Weekoff Import','Employee Weekoff','56','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Reporting Manager Import','Reporting Manager','42','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Qualification Import','Qualification','44','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Experience Import','Experience','45','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Earn/Ded Data Import','Earn/Ded Data','32','Employee','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Allow/Dedu Revised Import','Allow/Dedu Revised','57','Employee','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Bulk Increment Import','Bulk Increment','54','Employee','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Insurance Detail Import','Insurance Detail','51','Employee','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Cross Company Privilege Import','Cross Company Privilege','63','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('License Detail Import','License Detail','55','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Reference Import','Reference Import','70','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Left Import','Employee Left','40','Employee',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Asset Allocation Import','Asset Allocation','58','Employee',NULL,NULL,NULL) 
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Medical Detail Import','Medical Detail','93','Employee',NULL,NULL,NULL) 
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Emergency Contact Import','Emergency Contact','98','Employee',NULL,NULL,NULL)  --Added by ronakk 24052022
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Dynamic Hierarchy Import','Dynamic Hierarchy','99','Employee',NULL,NULL,NULL)  --Added by ronakk 25052022
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Contract Details Import','Contract Details','100','Employee',NULL,NULL,NULL)  --Added by ronakk 27052022
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Employee Geo Location Import','Employee Geo Location','101','Employee',NULL,NULL,NULL)  --Added by Mr.Mehul 12072022


	--Leave Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Leave Opening Import','Leave Opening','35','Leave',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Leave Credit Import','Leave Credit','41','Leave',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Leave Allowance Detail Import','Leave Allowance Detail','46','Leave','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Leave Approval Import','Leave Approval','36','Leave',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Multiple Leave Opening Import','Multiple Leave Opening Import','96','Leave',NULL,NULL,NULL)

	-- Loan - Bond Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Loan Approval Import','Loan Approval','25','Loan','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Loan Interest Subsidy','Loan Interest Subsidy','59','Loan','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Bond Approval Import','Bond Approval','94','Loan','Payroll',NULL,NULL) -- Added by Rajput on 03112018
	--Salary Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Attendance(In/Out) Import','Attendance (In/Out)','15','Salary',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Attendance Import','Attendance Import','43','Salary',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Monthly Present Import','Monthly Present','17','Salary',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Monthly Earn/Ded Import','Monthly Earn/Ded','16','Salary','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Allowance Days Import','Allowance Days','52','Salary','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Grade Change Import','Grade Change(Daily Wages Salary)','73','Salary','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Reimbursement Approval Import','Reimbursement Approval','74','Salary','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Advance Import','Advance Import','79','Salary','Payroll',NULL,NULL)--Ramiz 04/03/2016
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Production Bonus/Variable Import','Production Bonus/Variable Import','80','Salary','Payroll',NULL,NULL)--Mukti 16/05/2016
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Monthly Shift Import','Monthly Shift Import','86','Salary','Payroll',NULL,NULL)--Mukti 14/03/2017

	--Other Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Tax Declaration Import','Tax Declaration','37','Other','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Product Details Import','Production Details','60','Other','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Estimated Amount Import','IT Estimated Amount','62','Other','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('GPF Opening Import','GPF Opening','67','Other','GPF',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('GPF Additional Amount Import','GPF Additional Amount','69','Other','GPF',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('CPS Opening Import','CPS Opening','68','Other','CPS',NULL,NULL)
	--insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Publish News Letter Import','Publish News Letter Import','75','Other',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Publish News Letter Import','News Announcement Import','75','Other',NULL,NULL,NULL) -- Name Change by nilesh patel on 29032016 
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Transport Attendance Import','Transport Attendance','78','Other',NULL,NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Bonus Deduction Import','Bonus Deduction (Form C)','81','Other','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Clearance Attribute Import','Clearance Attribute Master','82','Other','Payroll',NULL,NULL)   --Added By Jaina 08-06-2016
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Sales Target Import','Sales Target Import','83','Other','Payroll',NULL,NULL)   --Added By Ramiz 12/11/2016
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Tax on Other Components Import','Tax on Other Components','84','Other','Payroll',NULL,NULL)
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Reimbursement Opening Import','Reimbursement Opening','85','Other','Payroll',NULL,NULL)  --Added by Jaina 23-02-2017
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Uniform Opening Import','Uniform Opening','87','Other','Payroll',NULL,NULL)  --Added by Nilesh patel on 27-04-2017
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Incentive Import','Incentive Import','88','Other','Payroll',NULL,NULL)  --Added by Rajput 20072017
	Insert Into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Increment Application Import','Increment Application','95','Other','Payroll',NULL,NULL)  --Added By Jimit 01032019
	Insert Into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Claim Approval Import','Claim Approval Upload','97','Other','Payroll',NULL,NULL)  --Added By Jaina 10-06-2020
	
	--Machine Tab
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Machine Daily Efficiency Import','Machine Daily Efficiency Import','90','Machine','Machine',NULL,NULL)  --Added by Ramiz on 03/04/2018
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Machine Gradewise Overtime Import','Machine Gradewise Overtime Import','91','Machine','Machine',NULL,NULL)  --Added by Ramiz on 03/04/2018
	insert into t0000_import_data (Name,Right_Name,Value,tab_Name,Module_Name,Form_Id,Form_Name) values ('Machine Monthly Allowance Import','Machine Monthly Allowance Import','92','Machine','Machine',NULL,NULL)  --Added by Ramiz on 03/04/2018

End

