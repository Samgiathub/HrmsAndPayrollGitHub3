








CREATE VIEW [dbo].[V0115_TRAVEL_APPLICATION_DETAIL_LEVEL_Backup_Yogesh_22112022]
AS
SELECT     TA.Travel_Application_ID, TA.Application_Date, TA.Application_Code, TA.Emp_ID, EM.Emp_Full_Name, isnull(TA.S_Emp_ID,0) as S_Emp_ID , SEMP.Emp_Full_Name AS Supervisor, 
                      TAD.Tran_ID as Travel_App_Detail_ID, TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID, 
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, TM.Travel_Mode_Name, TAD.From_Date, TAD.Period, 
                      TAD.To_Date, TAD.Remarks, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name
                      ,TAD.Leave_ID as Leave_id,'' as Leave_name,TA.Cmp_ID
                      ,TA.chk_Adv,TA.chk_Agenda,ta.Tour_Agenda,TA.IMP_Business_Appoint,ta.KRA_Tour,TA.Attached_Doc_File
                      ,isnull(TAD.State_ID,0)as State_ID,isnull(TAD.City_ID,0) as City_ID,Sm.State_Name as State,
                      cm.City_Name as City
                      ,ISNULL(TAD.Loc_ID,0) as Loc_ID,isnull(Lm.Loc_name,0) as Loc_Name,
                      CASE WHEN TAD.State_ID =0 AND TAD.Loc_ID IS NOT NULL THEN 1 ELSE 0 END as chk_International
                      ,isnull(TAD.Project_ID,0) as Project_ID,isnull(PMP.Project_Name,'') as Project_Name,isnull(pmp.Site_ID,'') as Site_ID
                      --,ISNULL(TAS.Approval_Comments,'') as Comments
                      ,TAD.Half_Leave_Date,TAD.LeaveType,TAD.Night_Day,c.GST_No,
                      EM.Work_tel_no,EM.Mobile_no,EM.Work_email,TTAD.TravelTypeId,TTT.Travel_Type_Name
FROM					dbo.T0115_TRAVEL_APPROVAL_DETAIL_LEVEL AS TAD WITH (NOLOCK) INNER JOIN					  
                      dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK)  ON TAD.Travel_Application_Id = TA.Travel_Application_ID inner join 
					  T0110_TRAVEL_APPLICATION_DETAIL as TTAD WITH (NOLOCK)  ON Ta.Travel_Application_ID = TTAD.Travel_App_ID
					  left JOIN T0040_Travel_Type TTT WITH (NOLOCK)  ON TTAD.TravelTypeId = TTT.Travel_Type_Id
					  left JOIN
						--T0115_TRAVEL_LEVEL_APPROVAL TAL on TAL.Travel_Application_ID=TAD.Travel_Application_ID
						--T0115_TRAVEL_LEVEL_APPROVAL TAL on TAL.Travel_Application_ID=TAD.Travel_Application_ID LEFT Join
						--inner join 
						--	(	
						--		select MAX(Rpt_Level)as RptLvl,Emp_ID,Travel_Application_ID
						--		from T0115_TRAVEL_LEVEL_APPROVAL TAL 
						--		where Rpt_Level<>0 group by Emp_ID,Travel_Application_ID 
						--	) TL on TAL.Rpt_Level=TL.RptLvl and TL.Emp_ID=TAL.Emp_ID and TL.Travel_Application_ID=TAL.Travel_Application_ID
                        --T0115_TRAVEL_LEVEL_APPROVAL TAL on TAL.Travel_Application_ID=TAD.Travel_Application_ID LEFT Join
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS IEMP WITH (NOLOCK)  ON TAD.Instruct_Emp_ID = IEMP.Emp_ID left outer join
                      dbo.T0020_STATE_MASTER sm WITH (NOLOCK)  on sm.State_ID=TAD.state_ID left outer join
                      dbo.T0030_CITY_MASTER cm WITH (NOLOCK)  on cm.City_ID=TAD.City_ID LEFT JOIN 
                      dbo.T0001_LOCATION_MASTER Lm WITH (NOLOCK)  ON Lm.Loc_ID=TAD.Loc_ID left join
                      T0050_Project_Master_Payroll PMP WITH (NOLOCK)  on PMP.Tran_Id=TAD.Project_ID and PMP.Cmp_ID=TAD.Cmp_ID
                      INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = TAD.Cmp_ID




