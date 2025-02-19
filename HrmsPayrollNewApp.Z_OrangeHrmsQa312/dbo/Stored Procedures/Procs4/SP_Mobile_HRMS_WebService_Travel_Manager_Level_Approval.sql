
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel_Manager_Level_Approval]
	
	@Travel_Application_ID NUMERIC(18,0)
	
AS
BEGIN
			
	Select Convert(varchar(10), Application_Date,103) as Application_Date, Application_Status, 0 As Rpt_Level,
	Convert(varchar(10), TA.Application_Date,103) as Application_Date, (EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) as name From
	V0100_TRAVEL_APPLICATION TA Inner JOIN T0080_EMP_MASTER EM ON TA.Emp_ID = EM.Emp_ID Where Travel_Application_ID = 204
	Union Select Convert(varchar(10), Approval_Date,103) as Approval_Date, Approval_Status, Rpt_Level, Convert(varchar(10), TLA.System_Date,103) 
	as System_Date ,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) as name From T0115_TRAVEL_LEVEL_APPROVAL TLA Inner JOIN T0080_EMP_MASTER EM
	ON TLA.S_Emp_ID = EM.Emp_ID Where Travel_Application_ID = @Travel_Application_ID

			
END
