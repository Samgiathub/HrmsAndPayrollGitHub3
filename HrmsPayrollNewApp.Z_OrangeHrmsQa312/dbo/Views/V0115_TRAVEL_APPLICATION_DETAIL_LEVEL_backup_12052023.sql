



Create VIEW [dbo].[V0115_TRAVEL_APPLICATION_DETAIL_LEVEL_backup_12052023]
AS
SELECT distinct    TA.Travel_Application_ID, TA.Application_Date, TA.Application_Code, TA.Emp_ID, EM.Emp_Full_Name, isnull(TA.S_Emp_ID,0) as S_Emp_ID , SEMP.Emp_Full_Name AS Supervisor, 
                       TAD.Tran_ID  as Travel_App_Detail_ID,
					  
					  TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID, 
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, TM.Travel_Mode_Name, TAD.From_Date, TAD.Period, 
                      TAD.To_Date, TAD.Remarks, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name
                      ,TAD.Leave_ID as Leave_id,'' as Leave_name,TA.Cmp_ID
       --               ,TA.chk_Adv
					  --,TA.chk_Agenda
					  --,ta.Tour_Agenda
					  --,TA.IMP_Business_Appoint
					  --,ta.KRA_Tour
					  --,TA.Attached_Doc_File
					  --Changes made by Yogseh to resolvel Ticket #24059 on 30012023
					  ,isnull(TLAA.chk_Adv,TA.chk_Adv)as chk_Adv
					  ,isnull(TLAA.chk_Agenda,TA.chk_Agenda)as chk_Agenda
					  ,isnull(TLAA.Tour_Agenda,TA.Tour_Agenda)as Tour_Agenda
					  ,isnull(TLAA.IMP_Business_Appoint,TA.IMP_Business_Appoint) as IMP_Business_Appoint
					  ,isnull(TLAA.KRA_Tour,TA.KRA_Tour)as KRA_Tour
					  ,isnull(TLAA.Attached_Doc_File,TA.Attached_Doc_File )as Attached_Doc_File
					  --Changes made by Yogseh to resolvel Ticket #24059 on 30012023
                      ,isnull(TAD.State_ID,0)as State_ID,isnull(TAD.City_ID,0) as City_ID,Sm.State_Name as State,
                      cm.City_Name as City
                      ,ISNULL(TAD.Loc_ID,0) as Loc_ID,isnull(Lm.Loc_name,0) as Loc_Name,
                      CASE WHEN TAD.State_ID =0 AND TAD.Loc_ID IS NOT NULL THEN 1 ELSE 0 END as chk_International
                      ,isnull(TAD.Project_ID,0) as Project_ID,isnull(PMP.Project_Name,'') as Project_Name,isnull(pmp.Site_ID,'') as Site_ID
                      --,ISNULL(TAS.Approval_Comments,'') as Comments
                      ,TAD.Half_Leave_Date,TAD.LeaveType,TAD.Night_Day,c.GST_No,
                      EM.Work_tel_no,EM.Mobile_no,EM.Work_email,TTAD.TravelTypeId,TTT.Travel_Type_Name,
					  (Select max(Rpt_Level) AS Rpt_level FROM T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID = tad.Travel_Application_Id Group by Travel_Application_ID) as Rpt_level--,
					 -- TL.Rpt_Level
FROM					dbo.T0115_TRAVEL_APPROVAL_DETAIL_LEVEL AS TAD WITH (NOLOCK)-- inner JOIN	
						-- T0115_TRAVEL_LEVEL_APPROVAL TL on TAD.Instruct_Emp_ID=TL.Emp_ID and TAD.Travel_Application_Id=TL.Travel_Application_ID and tad.Tran_ID=tl.Tran_Id
						inner join	

                      dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK)  ON TAD.Travel_Application_Id = TA.Travel_Application_ID inner join 
					  T0110_TRAVEL_APPLICATION_DETAIL as TTAD WITH (NOLOCK)  ON Ta.Travel_Application_ID = TTAD.Travel_App_ID
					  left JOIN T0040_Travel_Type TTT WITH (NOLOCK)  ON TTAD.TravelTypeId = TTT.Travel_Type_Id
					 
					   left JOIN
						
						
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
					  --Changes made by Yogseh to resolvel Ticket #24059 on 30012023
					  inner join T0115_TRAVEL_LEVEL_APPROVAL TLAA on Rpt_Level=(Select max(Rpt_Level) AS Rpt_level FROM T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID = tad.Travel_Application_Id Group by Travel_Application_ID)
					  and Ta.Travel_Application_ID=tlaa.Travel_Application_ID








