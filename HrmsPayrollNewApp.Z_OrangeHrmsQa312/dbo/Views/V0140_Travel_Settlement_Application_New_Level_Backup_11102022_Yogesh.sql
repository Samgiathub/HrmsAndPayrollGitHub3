





Create VIEW [dbo].[V0140_Travel_Settlement_Application_New_Level_Backup_11102022_Yogesh]
AS
SELECT     distinct   TSA.Travel_Set_Application_id, TSA.Travel_Approval_ID, 
                      TSA.cmp_id, TSA.emp_id, TSA.Advance_Amount, 
                      --dbo.T0140_Travel_Settlement_Application.Expence, 
                      TLA.Approved_Expance as Expence,
                      --dbo.T0140_Travel_Settlement_Application.credit, 
                      TLA.Adjust_Amount as credit,
                      TSA.Debit,
                      TLA.pending_amount as Pending_Amount,
                      TSA.Comment, TSA.[Document],TSA.For_date, 
                      TSA.Visited_Flag, TSA.Status as Status_old, dbo.T0080_EMP_MASTER.Emp_Full_Name,BM.Branch_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code , isnull(T0150_Travel_Settlement_Approval.Tran_id,0) as Tran_id,TLA.status,TLA.Rpt_Level
                      ,case when TSA.Status = 'P' then 'Pending' when TSA.Status='A' then 'Approved' else 'Rejected' end as Status_Name
                      ,TSA.Status as Status_New
                      ,T0080_EMP_MASTER.Emp_First_Name,SEMP.Emp_Full_Name AS Supervisor,SEMP.Emp_ID as Emp_Superior
                      ,T0080_EMP_MASTER.Branch_ID,DM.Desig_Name,TA.Travel_Application_ID
                      ,isnull(TLA.Travel_Amt_In_Salary,0) as EffectSalary,TRA.Application_Code as Travel_App_Code
                      ,convert(varchar(11),isnull(TLA.Effect_Salary_date,GETDATE()),103) as Sal_Effect_date
                      ,ISNULL(TLA.Approved_Expance,0) as Approved_Expence
                      ,isnull(TSA.DirectEntry,0) as DirectEntry
                      ,c.GST_No,TAD.TravelTypeId
FROM         dbo.T0140_Travel_Settlement_Application TSA WITH (NOLOCK) INNER JOIN
	dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON TSA.emp_id = dbo.T0080_EMP_MASTER.Emp_ID Left Join 
	T0150_Travel_Settlement_Approval WITH (NOLOCK)  on TSA.Travel_Set_Application_id = T0150_Travel_Settlement_Approval.Travel_Set_Application_id
	left join T0030_BRANCH_MASTER BM WITH (NOLOCK)  on BM.Branch_ID=dbo.T0080_EMP_MASTER.Branch_ID
	left join T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  on DM.Desig_ID=dbo.T0080_EMP_MASTER.Desig_Id 
	left join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)  on TA.Travel_Approval_ID=TSA.Travel_Approval_ID
	left join dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID
	left join T0115_Travel_Settlement_Level_Approval TLA WITH (NOLOCK)  on TLA.Travel_Approval_ID=TSA.Travel_Approval_ID
	left Join T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
	inner join T0110_TRAVEL_APPLICATION_DETAIL TAD with (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID
	inner join T0040_Travel_Type TT With (Nolock) on TT.Travel_type_Id = TAD.TravelTypeId
	INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = TSA.Cmp_ID	




