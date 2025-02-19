


create VIEW [dbo].[V0100_TRAVEL_APPLICATION_backup_17082022]
AS
SELECT DISTINCT 
                         TA.Cmp_ID, TA.Emp_ID, TA.Travel_Application_ID, TA.Application_Code, ISNULL(TAPR.Approval_Date, TA.Application_Date) AS Application_Date, EM.Emp_Full_Name, SEMP.Emp_Full_Name AS Supervisor, 
                         TA.Application_Status, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0030_BRANCH_MASTER.Branch_ID, EM.Alpha_Emp_Code, ISNULL(TAPR.Travel_Approval_ID, 0) 
                         AS travel_approval_id, ISNULL(TSA.Travel_Set_Application_id, 0) AS travel_set_Application_id, EM.Emp_First_Name, CONVERT(varchar(10), TA.Application_Date, 103) AS Application_Date_Show, ISNULL(Help_Desk.Cnt, 0) 
                         AS Cnt, Vs.Vertical_ID, sv.SubVertical_ID, EM.Dept_ID, CASE WHEN Application_Status = 'A' THEN dbo.F_GET_Emp_Visit(TA.Cmp_ID, TAPR.Travel_Application_ID, 0) ELSE dbo.F_GET_Emp_Visit(TA.Cmp_ID, 
                         TA.Travel_Application_ID, 1) END AS Emp_Visit, TA.S_Emp_ID, DV.DynHierColValue
						 ,(select count(1) from T0080_Emp_Travel_Proof where TravelApp_Code=TA.Application_Code and Cmp_Id=TA.Cmp_ID) as ProofCount
FROM            dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK) INNER JOIN
                         dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID INNER JOIN
                         dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                         dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                         dbo.T0040_Vertical_Segment AS Vs WITH (NOLOCK) ON EM.Vertical_ID = Vs.Vertical_ID LEFT OUTER JOIN
                         dbo.T0050_SubVertical AS sv WITH (NOLOCK) ON EM.SubVertical_ID = sv.SubVertical_ID LEFT OUTER JOIN
                         dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK) ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN
                         dbo.T0080_DynHierarchy_Value AS DV ON DV.DynHierColValue = SEMP.Emp_ID AND TA.Emp_ID = DV.Emp_ID LEFT OUTER JOIN
                         dbo.T0040_DEPARTMENT_MASTER AS Dp WITH (NOLOCK) ON Dp.Dept_Id = EM.Dept_ID LEFT OUTER JOIN
                         dbo.T0120_TRAVEL_APPROVAL AS TAPR WITH (NOLOCK) ON TA.Travel_Application_ID = TAPR.Travel_Application_ID LEFT OUTER JOIN
                         dbo.T0140_Travel_Settlement_Application AS TSA WITH (NOLOCK) ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID LEFT OUTER JOIN
                             (SELECT        COUNT(*) AS Cnt, Travel_Approval_ID, Emp_ID
                               FROM            dbo.T0130_TRAVEL_Help_Desk WITH (NOLOCK)
                               GROUP BY Travel_Approval_ID, Emp_ID) AS Help_Desk ON TAPR.Travel_Approval_ID = Help_Desk.Travel_Approval_ID

