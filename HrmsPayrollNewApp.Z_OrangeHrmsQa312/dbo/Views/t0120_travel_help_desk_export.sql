



CREATE VIEW [dbo].[t0120_travel_help_desk_export]
as
SELECT     EM.Alpha_Emp_Code, TAPR.Travel_Approval_ID, TAPR.Cmp_ID, TAPR.Emp_ID, dbo.T0100_TRAVEL_APPLICATION.Application_Code, 
                      dbo.T0100_TRAVEL_APPLICATION.Application_Date,t_app_dtls.Place_Of_Visit,t_app_dtls.Travel_Purpose,t_app_dtls.Instruct_Emp_ID,t_app_dtls.To_Date,t_app_dtls.From_Date,t_app_dtls.Period,t_app_dtls.Remarks, SEMP.Emp_Full_Name AS Supervisor, EM.Emp_Full_Name, TAPR.Approval_Date, TAPR.Approval_Status, 
                      TAPR.Approval_Comments,
						T0100_TRAVEL_APPLICATION.Travel_Application_ID, 
                      isnull(TAPR.Approved_Status_Help_Desk,'P') as Application_Status,  
                      BM.Branch_Name, BM.Branch_ID
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id
                      
                      
FROM         dbo.T0120_TRAVEL_APPROVAL AS TAPR WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TAPR.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0100_TRAVEL_APPLICATION WITH (NOLOCK)  ON TAPR.Travel_Application_ID = dbo.T0100_TRAVEL_APPLICATION.Travel_Application_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TAPR.S_Emp_ID = SEMP.Emp_ID inner join 
                      T0030_BRANCH_MASTER BM WITH (NOLOCK)  on EM.Branch_ID = BM.Branch_ID
						left join
                      T0140_Travel_Settlement_Application as TSA WITH (NOLOCK)  ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID left join 
                      T0130_TRAVEL_APPROVAL_DETAIL as t_app_dtls WITH (NOLOCK)  on t_app_dtls.Travel_Approval_ID=TAPR.Travel_Approval_ID 
                      


