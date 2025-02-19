



 
CREATE VIEW [dbo].[V0200_PAYMENT_PROCESS]  
AS  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Month_St_Date, MS.Month_End_Date, BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Net_Amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      MS.IT_M_ED_Cess_Amount, MS.Salary_Status  
                       ,'Salary' as process_Type  
                      ,0 as Ad_Id
FROM         dbo.T0200_MONTHLY_SALARY AS MS  WITH (NOLOCK)
			INNER JOIN	dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID
			INNER JOIN  dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID
			INNER JOIN   
                      (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
					  (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					  Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
					  on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
					  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
            LEFT OUTER JOIN  dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID   
ORDER BY EM.Emp_code  
  
  
union all  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_St_Date, dbo.GET_MONTH_END_DATE(ms.Bonus_effect_month,ms.bonus_effect_year) as Month_End_Date, BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode, INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Bonus_Amount as net_amount, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, 'Done' as 'Status'  
                      ,'Bonus' as process_Type  
                      ,0 as Ad_id
FROM         dbo.T0180_BONUS AS MS WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                        --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                          (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment  WITH (NOLOCK) 
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
      Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
                            LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID  
                      where isnull(ms.Bonus_Effect_on_Sal,0) <> 1  
ORDER BY EM.Emp_code  
union all  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.Month_St_Date, MS.Month_End_Date, BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode, INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Leave_Salary_Amount as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, MS.Salary_Status  
                      ,'Leave Encashment' as process_Type  
                      ,0 as Ad_Id
FROM         dbo.T0200_MONTHLY_SALARY AS MS WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                          --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                          (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
      Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
                              
     LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM ON EM.Bank_ID = BM.Bank_ID  
ORDER BY EM.Emp_code  
  
union all  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_Date as  Month_St_Date, MS.For_Date as  Month_End_Date, BM.Bank_Name,   
                  INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, MS.Adv_Amount as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
                      ,'Advance' as process_Type  
                      ,0 as Ad_Id
FROM         dbo.T0100_ADVANCE_PAYMENT AS MS WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                          --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                            (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
      Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
        
                            LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID  
ORDER BY EM.Emp_code  
  
  
  
union all  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.To_date as Month_End_Date,   
 BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.M_AD_Amount,0) + isnull(ms.M_AREAR_AMOUNT,0) + isnull(MS.M_AREAR_AMOUNT_Cutoff,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
                      ,AM.ad_name as process_Type  
                      ,Am.AD_ID  
FROM         dbo.T0210_MONTHLY_AD_DETAIL AS MS  WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                          --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                            (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
      Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
        
                            LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID  
                      inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and isnull(Ad_Effect_on_Esic,0) <> 1  
ORDER BY EM.Emp_code  
  
union all  
  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date  as Month_End_Date, BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Net_Amount ,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
                      ,AM.ad_name as process_Type  
                      ,Am.AD_ID  
FROM         T0210_ESIC_On_Not_Effect_on_Salary AS MS WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                          --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                              
                        (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
  Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
        
      LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID  
                      inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1 and isnull(Ad_Effect_on_Esic,0) = 1  
                        
ORDER BY EM.Emp_code  
  
union all  
  
SELECT     TOP (100) PERCENT MS.Cmp_ID, MS.Emp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, MS.For_date as Month_St_Date, MS.For_Date  as Month_End_Date, BM.Bank_Name,   
                      INC.Inc_Bank_AC_No, INC.Payment_Mode,INC.Bank_ID_Two,INC.Payment_Mode_Two,INC.Inc_Bank_AC_No_Two,  
                          (SELECT     Bank_Ac_No  
                            FROM          dbo.T0040_BANK_MASTER  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS cmp_bank_ac_no,  
                          (SELECT     Bank_Name  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1  WITH (NOLOCK) 
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_name,  
                          (SELECT     Bank_ID  
                            FROM          dbo.T0040_BANK_MASTER AS T0040_BANK_MASTER_1 WITH (NOLOCK)  
                            WHERE      (Is_Default = 'Y') AND (Cmp_Id = MS.Cmp_ID)) AS Cmp_bank_id, ( isnull(ms.Net_Amount ,0)) as net_Salary, INC.Branch_ID, ISNULL(INC.Dept_ID, 0) AS Dept_ID,   
                      ISNULL(INC.Cat_ID, 0) AS Cat_ID, ISNULL(INC.Type_ID, 0) AS Type_ID, ISNULL(INC.Desig_Id, 0) AS Desig_Id, EM.Emp_Left, INC.Bank_ID,   
                      0 as IT_M_ED_Cess_Amount, 'Done' as Salary_Status  
                      ,AM.ad_name as process_Type  
                      ,Am.AD_ID  
FROM         dbo.T0210_Emp_Seniority_Detail AS MS WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER AS EM  WITH (NOLOCK) ON MS.Emp_ID = EM.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT AS INC WITH (NOLOCK) ON MS.Emp_ID = INC.Emp_ID INNER JOIN  
                          --(SELECT     MAX(Increment_Effective_Date) AS For_Date, Emp_ID  
                          --  FROM          dbo.T0095_INCREMENT  
                          --  WHERE      (Increment_Effective_Date <= GETDATE())  
                          --  GROUP BY Emp_ID) AS Qry ON INC.Emp_ID = Qry.Emp_ID AND INC.Increment_Effective_Date = Qry.For_Date   
                            (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
      (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
      Where Increment_effective_Date <= GETDATE() Group by emp_ID) new_inc  
      on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
      Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id) Qry on INC.Increment_Id = Qry.Increment_Id  
                              
                            LEFT OUTER JOIN  
                      dbo.T0040_BANK_MASTER AS BM  WITH (NOLOCK) ON EM.Bank_ID = BM.Bank_ID  
                      inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ms.AD_ID = AM.AD_ID and am.AD_ACTIVE=1 and am.AD_NOT_EFFECT_SALARY = 1  
                        
ORDER BY EM.Emp_code  
  
  
  


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_PAYMENT_PROCESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_PAYMENT_PROCESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[17] 3) )"
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
         Begin Table = "MS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 73
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 293
               Bottom = 121
               Right = 510
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "INC"
            Begin Extent = 
               Top = 6
               Left = 548
               Bottom = 121
               Right = 756
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 794
               Bottom = 121
               Right = 970
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry"
            Begin Extent = 
               Top = 6
               Left = 1008
               Bottom = 91
               Right = 1160
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 23
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
         Width = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_PAYMENT_PROCESS';

