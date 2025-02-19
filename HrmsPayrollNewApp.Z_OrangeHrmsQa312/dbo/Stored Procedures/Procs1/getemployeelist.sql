CREATE proc getemployeelist
as
begin
select distinct T0.Emp_First_Name as 'FirstName',T0.Emp_Last_Name as 'LastName',T0.Work_Email as 'EmailAddress',
T0.desig_name as 'Designation',T0.branch_name as 'Branch_name', T0.Emp_code as 'Employee_Code', '' AS 'Busineess', T0.Mobile_No AS 'AssociatedPhoneNumbers',T2.Work_Email as 'ManagerUserId', 
(CASE WHEN T0.Emp_Left = 'Y' THEN 'Yes' ELSE 'No' END) AS 'Deactivation',T0.Emp_Left_Date as 'Date of left' from V0080_EMP_MASTER_INCREMENT_GET T0
LEFT JOIN(select TOP 1 Emp_ID, R_Emp_ID from T0090_EMP_REPORTING_DETAIL order by Effect_Date, Row_ID desc) T1 ON T1.Emp_ID = T0.emp_id 
LEFT JOIN T0080_EMP_MASTER T2 ON T2.Emp_ID = T1.R_Emp_ID

--select distinct T0.Emp_First_Name as 'FirstName',T0.Emp_Last_Name as 'LastName',T0.Work_Email as 'EmailAddress',T2.desig_name as 'Designation',T3.branch_name as 'Branch_name',T0.Emp_code as 'Employee_Code',
--'' AS 'Busineess',T0.Mobile_No AS 'AssociatedPhoneNumbers',T5.Work_Email as 'ManagerUserId',(CASE WHEN T0.Emp_Left='Y' THEN 'Yes' ELSE 'No' END) AS 'Deactivation',T0.Emp_Left_Date as 'Date of left' 
--from T0080_EMP_MASTER T0
--LEFT JOIN T0095_INCREMENT T1 ON T1.Emp_ID = T0.Emp_ID
--LEFT JOIN T0040_DESIGNATION_MASTER T2 ON T2.Desig_ID = T1.Desig_Id
--LEFT JOIN T0030_BRANCH_MASTER T3 ON T3.Branch_ID = T1.Branch_ID
--LEFT JOIN(select TOP 1 Emp_ID, R_Emp_ID from T0090_EMP_REPORTING_DETAIL order by Effect_Date, Row_ID desc) T4 ON T4.Emp_ID = T0.emp_id 
--LEFT JOIN T0080_EMP_MASTER T5 ON T5.Emp_ID = T4.R_Emp_ID
--for json AUTO
end