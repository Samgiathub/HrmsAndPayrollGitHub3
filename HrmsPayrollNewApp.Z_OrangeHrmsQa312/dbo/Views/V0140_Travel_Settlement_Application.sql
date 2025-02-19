
  
  
  
  
  
  
CREATE VIEW [dbo].[V0140_Travel_Settlement_Application]  
AS  
SELECT     TSA.Travel_Set_Application_id, TSA.Travel_Approval_ID,   
                      TSA.cmp_id, TSA.emp_id, TSA.Advance_Amount
					  ,TSA.Expence
					  --,(select isnull(sum(Amount),0)  from T0140_Travel_Settlement_Expense where  SelfPay=1) as Expense
					  , TSA.credit,TSA.Debit,   
                      TSA.Comment, TSA.[Document],  
                      --dbo.T0140_Travel_Settlement_Application.For_date,   
                      isnull(T0150_Travel_Settlement_Approval.Approval_date,TSA.For_date) as For_date,  -- Added by rohit for Approval Date if Application approved on 13012016  
                      TSA.Visited_Flag, TSA.Status, EM.Emp_Full_Name,   
                      EM.Alpha_Emp_Code , isnull(T0150_Travel_Settlement_Approval.Tran_id,0) as Tran_id  
                      ,case when TSA.Status = 'P' then 'Pending' when TSA.Status='A' then 'Approved' else 'Rejected' end as Status_Name  
                      ,EM.Emp_First_Name  
                      ,EM.Branch_ID  
                      ,isnull(dbo.T0150_Travel_Settlement_Approval.Travel_Amt_In_Salary,0) as EffectSalary,TRA.Application_Code as Travel_App_Code  
                      ,EM.Vertical_ID,EM.SubVertical_ID,EM.Dept_ID  
                      ,isnull(T0150_Travel_Settlement_Approval.Approved_Expance,0) as Approved_Expance  
                      ,ISNULL(TSA.DirectEntry,0) as DirectEntry  
                      ,c.GST_No  
					  ,(select count(1) from T0080_Emp_Travel_Proof where TravelApp_Code=TRA.Application_Code and Cmp_Id=TSA.Cmp_ID and Emp_ID=tra.Emp_id ) as ProofCount    
       ,isnull(tra.Application_Date,'1/1/1900')as Application_Date  
FROM         dbo.T0140_Travel_Settlement_Application TSA WITH (NOLOCK) INNER JOIN  
 dbo.T0080_EMP_MASTER EM WITH (NOLOCK)  ON TSA.emp_id = EM.Emp_ID Left Join   
 T0150_Travel_Settlement_Approval WITH (NOLOCK)  on TSA.Travel_Set_Application_id = T0150_Travel_Settlement_Approval.Travel_Set_Application_id  
 left join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)  on TA.Travel_Approval_ID=TSA.Travel_Approval_ID and TA.Emp_ID=TSA.emp_id  
 left Join T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID  
 --left join T0140_Travel_Settlement_Expense TSE With (NOLOCK) on   TSE.Travel_Approval_Id=TSA.Travel_Approval_ID
 INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = TSA.cmp_id  
 --	where TSE.SelfPay=1
   
  
  
  

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0140_Travel_Settlement_Application"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 9
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 289
               Bottom = 125
               Right = 514
            End
            DisplayFlags = 280
            TopColumn = 76
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_Travel_Settlement_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_Travel_Settlement_Application';

