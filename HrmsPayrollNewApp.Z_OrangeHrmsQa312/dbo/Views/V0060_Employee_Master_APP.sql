



CREATE VIEW [dbo].[V0060_Employee_Master_APP]
AS
SELECT     TOP (100) PERCENT E.Emp_Tran_ID, E.Emp_Application_ID, E.Approved_Emp_ID, E.Approved_Date, E.Rpt_Level, E.Emp_ID, E.Cmp_ID, E.Emp_First_Name, E.Emp_Second_Name, 
                      E.Emp_Last_Name, E.Date_Of_Join, dbo.F_Show_Decimal(I_1.Basic_Salary, I_1.Cmp_ID) AS Basic_Salary, SM.Shift_Name, DM.Dept_Name, 
                      CASE WHEN E.Gender = 'M' THEN 'Male' WHEN E.Gender = 'F' THEN 'Female' ELSE '' END AS Gender, TM.Type_Name, E.Marital_Status, GM.Grd_Name, CAST(E.Alpha_Emp_Code AS varchar(30)) 
                      + '-' + E.Emp_Full_Name AS Emp_Full_Name_new, E.Emp_Full_Name, E.Emp_Left, E.Work_Tel_No, E.Mobile_No, E.Date_Of_Birth, ISNULL(Qry_Reporting.Emp_Full_Name, '') 
                      AS Emp_Full_Name_Superior, ISNULL(Qry_Reporting.R_Emp_ID, 0) AS Emp_Superior, E.Present_City, E.Present_State, E.Present_Post_Box, E.Present_Street, E.Emp_Left_Date, 
                      ISNULL(E.Other_Email, '') AS Other_Email, ISNULL(E.Work_Email, '') AS Work_Email, E.Home_Tel_no, E.Zip_code, E.State, E.City, E.Street_1, E.Nationality, E.Dr_Lic_Ex_Date, E.Pan_No, 
                      E.Dr_Lic_No, E.SIN_No, E.SSN_No, I_1.Desig_ID, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0040_DESIGNATION_MASTER.Def_ID, dbo.T0010_COMPANY_MASTER.Cmp_Name, 
                      ISNULL(I_1.Dept_ID, DM.Dept_Id) AS DEPT_Id, BM.Branch_Name, ISNULL(Qry_Reporting.Other_Email, '') AS P_Other_Mail, ISNULL(Qry_Reporting.Work_Email, '') AS P_Work_Mail, I_1.Grd_ID, 
                      E.Image_Name, ISNULL(I_1.Branch_ID, BM.Branch_ID) AS Branch_ID, ISNULL(E.Enroll_No, 0) AS Enroll_No, E.Initial, I_1.Gross_Salary, I_1.Emp_OT, I_1.Emp_OT_Min_Limit, 
                      I_1.Emp_OT_Max_Limit, I_1.Emp_Late_mark, I_1.Emp_PT, I_1.Emp_Full_PF, I_1.Emp_Fix_Salary, I_1.Emp_Part_Time, I_1.Late_Dedu_Type, I_1.Emp_Late_Limit, I_1.Emp_PT_Amount, 
                      I_1.Yearly_Bonus_Amount, I_1.Inc_Bank_AC_No, I_1.Payment_Mode, I_1.Salary_Basis_On, I_1.Wages_Type, I_1.Bank_ID, I_1.Type_ID, E.Blood_Group, E.Religion, E.Height, 
                      E.Emp_Mark_Of_Identification, E.Despencery, E.Doctor_Name, E.DespenceryAddress, E.Insurance_No, E.Is_Gr_App, E.Is_Yearly_Bonus, E.Yearly_Leave_Days, E.Yearly_Leave_Amount, 
                      E.Emp_Confirm_Date, E.Is_On_Probation, E.Probation, E.Yearly_Bonus_Per, E.Shift_ID, E.Increment_ID, dbo.T0040_DESIGNATION_MASTER.Parent_ID, dbo.T0040_DESIGNATION_MASTER.Is_Main,
                       E.System_Date, dbo.T0001_LOCATION_MASTER.Loc_name, E.Loc_ID, Qry_Reporting.Mobile_No AS Sup_Mobile_No, E.Alpha_Emp_Code, E.Alpha_Code, E.Old_Ref_No, E.Emp_code, E.Ifsc_Code, 
                      E.Bank_BSR, E.Leave_In_Probation, E.Father_name, E.Emp_Annivarsary_Date, dbo.F_Show_Decimal(I_1.CTC, I_1.Cmp_ID) AS CTC, CM.Cat_Name, E.Worker_Adult_No, E.Tally_Led_Name, 
                      E.Emp_UIDNo, E.Emp_Cast, E.Tally_Led_ID, I_1.Curr_ID, I_1.Emp_Early_Limit, I_1.Early_Dedu_Type, I_1.Emp_WeekDay_OT_Rate, I_1.Emp_WeekOff_OT_Rate, I_1.Emp_Holiday_OT_Rate, 
                      E.Emp_PF_Opening, I_1.Increment_Type, ISNULL(LEFT(I_1.Deputation_End_Date, 12), '') AS Deputation_End_Date, I_1.Is_Deputation_Reminder, ISNULL(I_1.Center_ID, 0) AS Center_ID, 
                      ISNULL(E.DBRD_Code, '') AS DBRD_Code, ISNULL(E.Dealer_Code, '') AS Dealer_Code, ISNULL(E.CCenter_Remark, '') AS CCenter_Remark, I_1.Emp_Early_mark, E.Is_LWF, E.Extra_AB_Deduction, 
                      E.CompOff_Min_hrs, E.mother_name, I_1.Emp_Childran, I_1.Is_Metro_City, I_1.is_physical, ISNULL(I_1.Segment_ID, 0) AS Segment_ID, ISNULL(I_1.Vertical_ID, 0) AS Vertical_ID, 
                      ISNULL(I_1.SubVertical_ID, 0) AS SubVertical_ID, E.GroupJoiningDate, I_1.subBranch_ID, I_1.SalDate_ID, BS.Segment_Name, VS.Vertical_Name, SV.SubVertical_Name, E.Emp_Category, 
                      SB.SubBranch_Name, E.Emp_Shoe_Size, E.Emp_Pent_Size, E.Emp_Shirt_Size, E.Emp_Dress_Code, E.Emp_Canteen_Code, E.Thana_ID, E.Tehsil, E.District, E.Thana_Id_Wok, E.Tehsil_Wok, 
                      E.District_Wok, E.SkillType_ID, E.About_Me, E.CompOff_WO_App_Days, E.CompOff_WO_Avail_Days, E.CompOff_WD_App_Days, E.CompOff_WD_Avail_Days, E.CompOff_HO_App_Days, 
                      E.CompOff_HO_Avail_Days, E.Date_of_Retirement, E.Ration_Card_Type, E.Ration_Card_No, E.Vehicle_NO, dbo.T0010_COMPANY_MASTER.is_GroupOFCmp, I_1.Bank_Branch_Name, 
                      I_1.Bank_Branch_Name_Two, I_1.Inc_Bank_AC_No_Two, E.Ifsc_Code_Two, I_1.Payment_Mode_Two, I_1.Bank_ID_Two, E.UAN_No, E.Aadhar_Card_No, ISNULL(CM.NewJoin_Employee, 1) 
                      AS Show_New_Join_Employee, E.Actual_Date_Of_Birth, ISNULL(E.PF_Trust_No, '') AS pf_trust_no, E.Extension_No, E.LinkedIn_ID, E.Twitter_ID, I_1.Customer_Audit, E.PF_Start_Date, 
                      ISNULL(I_1.Sales_Code, '') AS Sales_Code, ISNULL(E.is_for_mobile_Access, 0) AS is_for_mobile_Access, dbo.T0010_COMPANY_MASTER.GST_No, E.Signature_Image_Name, I_1.Cat_ID, 
                      ISNULL(E.Is_Geofence_enable, 0) AS Is_Geofence_enable, ISNULL(E.Is_Camera_enable, 0) AS Is_Camera_enable, I_1.Physical_Percent
FROM         dbo.T0060_EMP_MASTER_APP AS E WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON E.Loc_ID = dbo.T0001_LOCATION_MASTER.Loc_ID LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON E.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                          (SELECT     i.Increment_ID, i.Emp_Tran_ID, i.Cmp_ID, i.Branch_ID, i.Cat_ID, i.Grd_ID, i.Dept_ID, i.Desig_ID, i.Type_ID, i.Bank_ID, i.Curr_ID, i.Wages_Type, i.Salary_Basis_On, i.Basic_Salary, 
                                                   i.Gross_Salary, i.Increment_Type, i.Increment_Date, i.Increment_Effective_Date, i.Payment_Mode, i.Inc_Bank_AC_No, i.Emp_OT, i.Emp_OT_Min_Limit, i.Emp_OT_Max_Limit, 
                                                   i.Increment_Per, i.Increment_Amount, i.Pre_Basic_Salary, i.Pre_Gross_Salary, i.Increment_Comments, i.Emp_Late_mark, i.Emp_Full_PF, i.Emp_PT, i.Emp_Fix_Salary, 
                                                   i.Emp_Part_Time, i.Late_Dedu_Type, i.Emp_Late_Limit, i.Emp_PT_Amount, i.Emp_Childran, i.Is_Master_Rec, i.Login_ID, i.System_Date, i.Yearly_Bonus_Amount, 
                                                   i.Deputation_End_Date, i.Is_Deputation_Reminder, i.Appr_Int_ID, i.CTC, i.Emp_Early_mark, i.Early_Dedu_Type, i.Emp_Early_Limit, i.Emp_Deficit_mark, i.Deficit_Dedu_Type, 
                                                   i.Emp_Deficit_Limit, i.Center_ID, i.Emp_WeekDay_OT_Rate, i.Emp_WeekOff_OT_Rate, i.Emp_Holiday_OT_Rate, i.Is_Metro_City, i.Pre_CTC_Salary, i.Incerment_Amount_gross, 
                                                   i.Incerment_Amount_CTC, i.Increment_Mode, i.is_physical, i.SalDate_ID, i.Emp_Auto_Vpf, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID, 
                                                   i.Monthly_Deficit_Adjust_OT_Hrs, i.Fix_OT_Hour_Rate_WD, i.Fix_OT_Hour_Rate_WO_HO, i.Bank_ID_Two, i.Payment_Mode_Two, i.Inc_Bank_AC_No_Two, i.Bank_Branch_Name, 
                                                   i.Bank_Branch_Name_Two, i.Reason_ID, i.Reason_Name, i.Increment_App_ID, i.Customer_Audit, i.Sales_Code, i.Physical_Percent
                            FROM          dbo.T0070_EMP_INCREMENT_APP AS i WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_Tran_ID
                                                         FROM          dbo.T0070_EMP_INCREMENT_APP AS I2 WITH (NOLOCK)  INNER JOIN
                                                                                    (SELECT     MAX(Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, Emp_Tran_ID
                                                                                      FROM          dbo.T0070_EMP_INCREMENT_APP AS I3 WITH (NOLOCK) 
                                                                             WHERE      (Increment_Effective_Date <= GETDATE())
                                                                                      GROUP BY Emp_Tran_ID) AS I3_1 ON I2.Increment_Effective_Date = I3_1.INCREMENT_EFFECTIVE_DATE AND I2.Emp_Tran_ID = I3_1.Emp_Tran_ID
                                                         GROUP BY I2.Emp_Tran_ID) AS I2_1 ON i.Emp_Tran_ID = I2_1.Emp_Tran_ID AND i.Increment_ID = I2_1.Increment_ID) AS I_1 ON 
                      E.Emp_Tran_ID = I_1.Emp_Tran_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK)  ON GM.Grd_ID = ISNULL(I_1.Grd_ID, E.Grd_ID) LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER AS SM WITH (NOLOCK)  ON E.Shift_ID = SM.Shift_ID LEFT OUTER JOIN
                      dbo.T0030_CATEGORY_MASTER AS CM WITH (NOLOCK)  ON CM.Cat_ID = ISNULL(I_1.Cat_ID, E.Cat_ID) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0040_DESIGNATION_MASTER.Desig_ID = ISNULL(I_1.Desig_ID, E.Desig_ID) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK)  ON DM.Dept_Id = ISNULL(I_1.Dept_ID, E.Dept_ID) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON BM.Branch_ID = ISNULL(I_1.Branch_ID, E.Branch_ID) LEFT OUTER JOIN
                      dbo.T0040_Business_Segment AS BS WITH (NOLOCK)  ON BS.Segment_ID = ISNULL(I_1.Segment_ID, E.Segment_ID) LEFT OUTER JOIN
                      dbo.T0040_Vertical_Segment AS VS WITH (NOLOCK)  ON VS.Vertical_ID = ISNULL(I_1.Vertical_ID, E.Vertical_ID) LEFT OUTER JOIN
                      dbo.T0050_SubVertical AS SV WITH (NOLOCK)  ON SV.SubVertical_ID = ISNULL(I_1.SubVertical_ID, E.SubVertical_ID) LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER AS TM WITH (NOLOCK)  ON TM.Type_ID = ISNULL(I_1.Type_ID, E.Type_ID) LEFT OUTER JOIN
                      dbo.T0050_SubBranch AS SB WITH (NOLOCK)  ON SB.SubBranch_ID = ISNULL(I_1.subBranch_ID, E.subBranch_ID) LEFT OUTER JOIN
                          (SELECT     R1.Emp_Tran_ID, R1.Approved_Date, R1.R_Emp_ID, Em.Alpha_Emp_Code + '-' + Em.Emp_Full_Name AS Emp_Full_Name, Em.Work_Email, Em.Other_Email, Em.Mobile_No
                            FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R1 WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(R2.Row_ID) AS ROW_ID, R2.Emp_Tran_ID
                                                         FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R2 WITH (NOLOCK)  INNER JOIN
                                                                                    (SELECT     MAX(Approved_Date) AS Approved_Date, Emp_Tran_ID
                                                                                      FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R3 WITH (NOLOCK) 
                                                                                      WHERE      (Approved_Date < GETDATE())
                                                                                      GROUP BY Emp_Tran_ID) AS R3_1 ON R2.Emp_Tran_ID = R3_1.Emp_Tran_ID AND R2.Approved_Date = R3_1.Approved_Date
                                                         GROUP BY R2.Emp_Tran_ID) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_Tran_ID = R2_1.Emp_Tran_ID INNER JOIN
                                                   dbo.T0060_EMP_MASTER_APP AS Em WITH (NOLOCK)  ON R1.Emp_Tran_ID = Em.Emp_Tran_ID) AS Qry_Reporting ON E.Emp_Tran_ID = Qry_Reporting.Emp_Tran_ID
ORDER BY RIGHT(REPLICATE(N' ', 500) + E.Alpha_Emp_Code, 500)


