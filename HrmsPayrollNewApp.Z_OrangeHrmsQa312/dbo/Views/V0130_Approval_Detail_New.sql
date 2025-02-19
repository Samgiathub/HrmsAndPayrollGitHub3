
  
              
              
              
              
CREATE VIEW [dbo].[V0130_Approval_Detail_New]              
AS              
SELECT Distinct    TA.Travel_Approval_ID, TA.Approval_Date, TA.Emp_ID,              
 EM.Emp_Full_Name,              
  TA.S_Emp_ID,               
SEMP.Emp_Full_Name AS Supervisor,              
 TAD.Travel_Approval_Detail_ID,               
                      TAD.Place_Of_Visit, TAD.Travel_Purpose,TA.Attached_Doc_File,TA.Travel_Application_ID as Application_Code, TAD.Instruct_Emp_ID,TaD.Leave_ID,              
                      '' as Leave_Name,              
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name,EM.Branch_ID,EM.Desig_Id, TAD.Travel_Mode_ID,               
                      TM.Travel_Mode_Name,              
                       TAD.From_Date, TAD.Period, TAD.To_Date, TAD.Remarks    
        ,tad.From_State_ID,fSM.State_Name as 'From_State',              
                       FCm.City_Name as 'From_City_Name'    
        ,tad.State_ID,SM.State_Name as State,              
                       Cm.City_Name    
        ,isnull(LC.Loc_name,'') as Loc_name,isnull(tad.loc_ID,0) as chk_International              
                       ,ISNULL(TAD.Project_ID,0) as Project_ID,ISNULL(PMP.Project_Name,'') as Project_Name              
                       ,ISNULL(PMP.Site_Id,'') as Site_Id              
                       ,c.GST_No              
        ,Rm.Reason_Name 
		
FROM         dbo.T0120_TRAVEL_APPROVAL AS TA WITH (NOLOCK) left JOIN              
                      dbo.T0130_TRAVEL_APPROVAL_DETAIL AS TAD WITH (NOLOCK)  ON TA.Travel_Approval_ID = TAD.Travel_Approval_ID               
                      --left JOIN T0130_Travel_Approval_Other_Detail TRD on TRD.Travel_Approval_ID=TAD.Travel_Approval_ID              
                      left join              
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID left JOIN              
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID LEFT OUTER JOIN              
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN              
                      dbo.T0080_EMP_MASTER AS IEMP WITH (NOLOCK)  ON TAD.Instruct_Emp_ID = IEMP.Emp_ID left join              
                      dbo.T0040_LEAVE_MASTER AS LM WITH (NOLOCK)  on LM.Leave_ID=TAD.Leave_ID left join              
                      dbo.T0020_STATE_MASTER SM WITH (NOLOCK)  on SM.State_ID=TAD.State_ID and Sm.Cmp_ID=TAD.Cmp_ID left join              
                      dbo.T0030_CITY_MASTER Cm WITH (NOLOCK)  on Cm.Cmp_ID=TAD.Cmp_ID and TAD.City_ID=Cm.City_ID left join              
      dbo.T0020_STATE_MASTER FSM WITH (NOLOCK)  on FSM.State_ID=TAD.From_State_id and Sm.Cmp_ID=TAD.Cmp_ID left join              
                      dbo.T0030_CITY_MASTER FCm WITH (NOLOCK)  on Cm.Cmp_ID=TAD.Cmp_ID and TAD.From_City_id=FCm.City_ID left join              
                      dbo.T0001_LOCATION_MASTER LC WITH (NOLOCK)  on TAD.Loc_ID=LC.Loc_ID left join              
                      dbo.T0050_Project_Master_Payroll PMP WITH (NOLOCK)  on PMP.Tran_Id=TAD.Project_ID and PMP.Cmp_Id=TAD.Cmp_ID              
                      INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = TAD.Cmp_ID             
       left join T0110_TRAVEL_APPLICATION_DETAIL TADD  WITH (NOLOCK) on TadD.travel_app_Id=TA.Travel_Application_Id        
       left join T0040_Reason_Master RM WITH (NOLOCK) on Rm.Res_Id=taD.Reason_ID   
