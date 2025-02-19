











CREATE VIEW [dbo].[V0100_TRAVEL_APPLICATION_Backup_Yogesh_25072022]
AS
SELECT  distinct   TA.Cmp_ID, TA.Emp_ID, TA.Travel_Application_ID, TA.Application_Code,isnull(TAPR.Approval_date,TA.Application_Date) as Application_Date, EM.Emp_Full_Name, 
                      SEMP.Emp_Full_Name AS Supervisor, TA.Application_Status, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0030_BRANCH_MASTER.Branch_ID, EM.Alpha_Emp_Code
                      ,ISNULL(TAPR.Travel_Approval_ID,0) as travel_approval_id
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id
                     ,EM.Emp_First_Name
                     ,convert(varchar(10),TA.Application_Date,103) as Application_Date_Show
                     ,isnull(Help_Desk.Cnt,0) as Cnt,Vs.Vertical_ID,sv.SubVertical_ID,em.Dept_ID                     
                     --,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,1) as Emp_Visit
                      ,case when Application_Status='A' then dbo.F_GET_Emp_Visit(TA.Cmp_ID,TAPR.Travel_Application_ID,0)
						Else dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,1) End
                      as Emp_Visit , ta.S_Emp_ID ,DV.DynHierColValue
	FROM         dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT JOIN
                      T0040_Vertical_Segment Vs WITH (NOLOCK)  on Em.Vertical_Id=Vs.vertical_id left join
                      T0050_SubVertical sv  WITH (NOLOCK) on em.SubVertical_ID =sv.SubVertical_ID left join
                      dbo.T0080_EMP_MASTER AS SEMP  WITH (NOLOCK) ON TA.S_Emp_ID = SEMP.Emp_ID 
					  Left join T0080_DynHierarchy_Value DV on  DV.DynHierColValue = SEMP.Emp_ID and ta.Emp_ID = DV.Emp_ID
					  left join T0040_DEPARTMENT_MASTER Dp WITH (NOLOCK)  on Dp.Dept_Id=Em.Dept_ID left join
                      T0120_TRAVEL_APPROVAL as TAPR WITH (NOLOCK)  ON TA.Travel_Application_ID = TAPR.Travel_Application_ID left join
                      T0140_Travel_Settlement_Application as TSA WITH (NOLOCK)  ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID
                      left Join (Select COUNT(*) as Cnt,Travel_Approval_id,Emp_Id from T0130_TRAVEL_Help_Desk WITH (NOLOCK)  group by Travel_Approval_ID,Emp_Id ) Help_Desk on TAPR.Travel_Approval_ID = Help_Desk.Travel_Approval_ID
                      
                      


