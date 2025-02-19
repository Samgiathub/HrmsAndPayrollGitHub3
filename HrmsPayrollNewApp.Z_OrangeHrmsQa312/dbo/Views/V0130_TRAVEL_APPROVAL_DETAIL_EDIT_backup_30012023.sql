








create VIEW [dbo].[V0130_TRAVEL_APPROVAL_DETAIL_EDIT_backup_30012023]
AS
SELECT  distinct   TA.Travel_Application_ID, TA.Application_Date, TA.Application_Code, TA.Emp_ID, EM.Emp_Full_Name, isnull(TA.S_Emp_ID,0) as S_Emp_ID , SEMP.Emp_Full_Name AS Supervisor, 
                      TAD.Travel_Approval_Detail_ID as Travel_App_Detail_ID, TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID, 
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, TM.Travel_Mode_Name, TAD.From_Date, TAD.Period, 
                      TAD.To_Date, TAD.Remarks, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name
                      ,TAD.Leave_ID as Leave_id,'' as Leave_name,TA.Cmp_ID
                      ,TA.chk_Adv,TA.chk_Agenda,ta.Tour_Agenda,TA.IMP_Business_Appoint,ta.KRA_Tour,TA.Attached_Doc_File
                      ,isnull(TAD.State_ID,0)as State_ID,isnull(TAD.City_ID,0) as City_ID,Sm.State_Name as State,cm.City_Name as City
                      ,lM.Loc_name,isnull(tad.loc_ID,0) as Loc_ID,isnull(tad.loc_ID,0) as chk_International
                      ,isnull(TAD.Project_ID,0) as Project_ID,ISNULL(pmp.Project_Name,'') as Project_Name,isnull(pmp.Site_ID,'') as Site_ID
                      ,ISNULL(TAP.Approval_Comments,'') as Comments,
                      TAD.Half_Leave_Date,TAD.LeaveType,TAD.Night_Day,C.GST_No
					   ,isnull(TT.Travel_Type_Name , '') as Travel_Type_Name,isnull(tt.Travel_Type_Id,0) as Travel_Type_Id
FROM				
					dbo.T0130_TRAVEL_APPROVAL_DETAIL AS TAD WITH (NOLOCK) INNER JOIN
					  dbo.T0120_TRAVEL_APPROVAL TAP WITH (NOLOCK)  on TAP.Travel_Approval_ID=TAD.Travel_Approval_ID and TAP.Cmp_ID=TAD.Cmp_ID
					  LEFT join
                      dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK)  ON TAP.Travel_Application_ID = TA.Travel_Application_ID left JOIN
					  dbo.T0110_TRAVEL_APPLICATION_DETAIL AS TADD WITH (NOLOCK)  on TADD.Travel_App_ID = TA.Travel_Application_ID left JOIN
					    T0040_Travel_Type TT With (Nolock) on  Tt.Travel_Type_Id = TADD.TravelTypeId  left JOIN
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS IEMP WITH (NOLOCK)  ON TAD.Instruct_Emp_ID = IEMP.Emp_ID left outer join
                      dbo.T0020_STATE_MASTER sm WITH (NOLOCK)  on sm.State_ID=TAD.state_ID left outer join
                      dbo.T0030_CITY_MASTER cm WITH (NOLOCK)  on cm.City_ID=TAD.City_ID left join
                      dbo.T0001_LOCATION_MASTER Lm  WITH (NOLOCK) on Lm.Loc_ID=tad.loC_id left join
                      dbo.T0050_Project_Master_Payroll pmp WITH (NOLOCK)  on pmp.Tran_Id=tad.project_ID INNER JOIN
                      T0010_COMPANY_MASTER C WITH (NOLOCK)  ON C.Cmp_Id = TAD.Cmp_ID 





