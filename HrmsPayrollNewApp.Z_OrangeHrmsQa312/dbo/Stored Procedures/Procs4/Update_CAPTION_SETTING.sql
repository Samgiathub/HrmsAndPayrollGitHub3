

CREATE PROCEDURE [dbo].[Update_CAPTION_SETTING]        
@cmp_id numeric(18,0) = 0
AS        
        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON 
BEGIN
/*
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Category'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='DBRD Code'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Dealer Code'
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Branch'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Insurance'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='InsuranceMenu'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Policy Type'
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Company Name'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Policy No'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Registration Date'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Due Date'
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Exp Date'	
	Update T0040_CAPTION_SETTING set Module_Name='PAYROLL' where Cmp_ID=@Cmp_ID and Caption='Insurance Amount'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Annual Amount'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Business Segment'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Vertical'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='SubVertical'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='subBranch'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Exit'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Direct Reporters'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Indirect Reporters'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='No Of Accidents'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='No Of Person Involved'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Canteen Code'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Title'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Reporting Manager'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Grade'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Tehsil'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Thana'	
	Update T0040_CAPTION_SETTING set Module_Name='HRMS' where Cmp_ID=@Cmp_ID and Caption='Main KPI'	
	Update T0040_CAPTION_SETTING set Module_Name='HRMS' where Cmp_ID=@Cmp_ID and Caption='Sub KPI'	
	Update T0040_CAPTION_SETTING set Module_Name='HRMS' where Cmp_ID=@Cmp_ID and Caption='KPI Attributes'	
	Update T0040_CAPTION_SETTING set Module_Name='HRMS' where Cmp_ID=@Cmp_ID and Caption='Objectives'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Employee Type'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Tally Ledger Name'	
	Update T0040_CAPTION_SETTING set Module_Name=NULL where Cmp_ID=@Cmp_ID and Caption='Gate Pass'
*/

 -- ABOVE PORTION IS COMMENTED AND NEW CODE IS ADDED BY RAMIZ ON 30/03/2017; AS IT WAS UPDATING MODULE AS NULL.
 
Update T0040_CAPTION_SETTING Set Caption = 'Performance Attribute' where Caption = 'Perfomance Attribute'	--CORRECTING WRONG SPELLING

/* MODULE:- PAYROLL*/
--Group By:- MASTER
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Category Master', Module_Name = 'PAYROLL' , Group_By = 'Master'	where Caption = 'Category' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Skill Master', Module_Name = 'PAYROLL' , Group_By = 'Master'	where Caption = 'Skill' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Branch Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Branch' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master =>  Insurance Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Insurance' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master =>  Insurance Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'InsuranceMenu' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Business Segment Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Business Segment' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Vertical Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Vertical' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => SubVertical Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'SubVertical' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Sub Branch Master', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'subBranch' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Grade', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Grade' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Employee Type', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Employee Type' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Master => Optional Holiday', Module_Name = 'PAYROLL' , Group_By = 'Master' where Caption = 'Optional Holiday' AND Cmp_ID=@Cmp_ID


--Group By:- EMPLOYEE MASTER
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Salary Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'DBRD Code' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Salary Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Dealer Code' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Policy Type' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Company Name' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Policy No' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Registration Date' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Due Date' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Exp Date' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Insurance Amount' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Insurance Details', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Annual Amount' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Direct Reporters', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Direct Reporters' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Indirect Reporters', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Indirect Reporters' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Canteen Code', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Canteen Code' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master =>  Reporting Manager', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Reporting Manager' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Tehsil', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Tehsil' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Thana', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Thana' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Tally Ledger Name', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Tally Ledger Name' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Fix Salary', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Fix Salary' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Sales Code', Module_Name = 'SALES' , Group_By = 'Employee Master' where Caption = 'Sales Code' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Work Phone No', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Work Phone No' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Personal Phone No', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Personal Phone No' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Employee Master => Extension No', Module_Name = 'PAYROLL' , Group_By = 'Employee Master' where Caption = 'Extension No' AND Cmp_ID=@Cmp_ID

--Group By:- EXIT
Update T0040_CAPTION_SETTING Set Remarks = 'Employee => Exit', Module_Name = 'PAYROLL' , Group_By = 'Exit' where Caption = 'Exit' AND Cmp_ID=@Cmp_ID

--Group By:- CONTROL PANEL
Update T0040_CAPTION_SETTING Set Remarks = 'Control Panel => AX Mapping', Module_Name = 'PAYROLL' , Group_By = 'Control Panel' where Caption = 'AX Mapping' AND Cmp_ID=@Cmp_ID

--GROUP BY :- GATE PASS
Update T0040_CAPTION_SETTING Set Remarks = 'Leave => Gate Pass', Module_Name = 'PAYROLL' , Group_By = 'Gate Pass' where Caption = 'Gate Pass' AND Cmp_ID=@Cmp_ID

/* MODULE:- HRMS*/
--Group By:- Appraisal
Update T0040_CAPTION_SETTING Set Remarks = 'Other Assessment Master => No Of Accidents', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'No Of Accidents' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Other Assessment Master =>  No Of Person Involved', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'No Of Person Involved' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Other Assessment Master =>  Title', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Title' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Main KPI', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Main KPI' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Sub KPI', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Sub KPI' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => KPI Attributes', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'KPI Attributes' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Objectives', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Objectives' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => KPA', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'KPA' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Target', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Target' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Performance Attribute', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Performance Attribute' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Potential Attribute', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Potential Attribute' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Justification for High Score', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Justification for High Score' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Criteria', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Criteria' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Appraiser Comments', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Appraiser Comments' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => Group Head/GH', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'Group Head/GH' AND Cmp_ID=@Cmp_ID --added on 28/08/2017 sneha
Update T0040_CAPTION_SETTING Set Remarks = 'Appraisal => HOD', Module_Name = 'HRMS' , Group_By = 'Appraisal' where Caption = 'HOD' AND Cmp_ID=@Cmp_ID --added on 28/08/2017 sneha

/* MODULE:- SALES*/
--Group By:- Sales
Update T0040_CAPTION_SETTING Set Remarks = 'Sales => Sales Target', Module_Name = 'SALES' , Group_By = 'Sales' where Caption = 'Sales Target' AND Cmp_ID=@cmp_id
Update T0040_CAPTION_SETTING Set Remarks = 'Sales => Sales Route Master', Module_Name = 'SALES' , Group_By = 'Sales' where Caption = 'Sales Route Master' AND Cmp_ID=@cmp_id
Update T0040_CAPTION_SETTING Set Remarks = 'Sales => Sales Week Master', Module_Name = 'SALES' , Group_By = 'Sales' where Caption = 'Sales Week Master' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Sales => Sales Assigned Target', Module_Name = 'SALES' , Group_By = 'Sales' where Caption = 'Sales Assigned Target' AND Cmp_ID=@Cmp_ID


/* MODULE:- TRAVEL*/
--Group By:- TRAVEL
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Tour Agenda Planned', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Tour Agenda Planned' AND Cmp_ID=@cmp_id
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Business Appointment Planned', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Business Appointment Planned' AND Cmp_ID=@cmp_id
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Tour Appointment Planned', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Tour Appointment Planned' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Tour Agenda Actual', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Tour Agenda Actual' AND Cmp_ID=@Cmp_ID
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Business Appointment Actual', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Business Appointment Actual' AND Cmp_ID=@cmp_id
Update T0040_CAPTION_SETTING Set Remarks = 'Travel => Tour Appointment Actual', Module_Name = 'Travel' , Group_By = 'Travel' where Caption = 'Tour Appointment Actual' AND Cmp_ID=@cmp_id



UPDATE	C
SET		CAPTIONCODE=T.CAPTIONCODE
FROM	T0040_CAPTION_SETTING C INNER JOIN (SELECT DISTINCT CAPTIONCODE, CAPTION FROM T0040_CAPTION_SETTING T WITH (NOLOCK)) T ON T.Caption=C.Caption
WHERE	C.CaptionCode IS NULL


--- Change condition for Direct / Indirect by Hardik on 28/01/2021 for Vandana Global
UPDATE C
SET		CAPTIONCODE= Case C.Caption When 'Direct Reporters' Then 'Direct' When 'Indirect Reporters' Then 'Indirect' Else C.Caption End
FROM	T0040_CAPTION_SETTING C 
WHERE	C.CaptionCode IS NULL


END



