





CREATE VIEW [dbo].[V0060_EMP_MASTER_INCREMENT_GET]
AS
SELECT     e.Emp_Tran_ID, e.Emp_Application_ID, e.Approved_Emp_ID, e.Approved_Date, e.Rpt_Level, e.Emp_code, e.Initial, e.Emp_First_Name, e.Emp_Second_Name, e.Emp_Last_Name, e.Date_Of_Join, 
                      e.SSN_No, e.SIN_No, e.Dr_Lic_No, e.Pan_No, e.Date_Of_Birth, e.Marital_Status, e.Gender, e.Dr_Lic_Ex_Date, e.Nationality, e.Loc_ID, e.Street_1, e.City, e.State, e.Zip_code, e.Home_Tel_no, 
                      e.Mobile_No, e.Work_Tel_No, e.Work_Email, e.Other_Email, e.Image_Name, e.Emp_Full_Name, e.Emp_Left, e.Emp_Left_Date, I.Increment_ID, e.Present_Street, e.Present_City, e.Present_State, 
                      e.Present_Post_Box, R_1.Emp_Superior, e.Enroll_No, e.Blood_Group, e.Tally_Led_Name, e.Religion, e.Height, e.Emp_Mark_Of_Identification, e.Despencery, e.Doctor_Name, e.DespenceryAddress,
                       e.Insurance_No, e.Is_Gr_App, e.Is_Yearly_Bonus, e.Yearly_Leave_Days, e.Yearly_Leave_Amount, e.Yearly_Bonus_Per, e.Yearly_Bonus_Amount, e.Emp_Confirm_Date, e.Is_On_Probation, 
                      e.Tally_Led_ID, e.Emp_ID, e.Cmp_ID, ISNULL(ESD.Shift_ID, e.Shift_ID) AS Shift_ID, I.Branch_ID, I.Cat_ID, I.Grd_ID, I.Dept_ID, I.Desig_ID, I.Type_ID, I.Bank_ID, I.Curr_ID, I.Wages_Type, 
                      I.Salary_Basis_On, I_Q.Basic_Salary, I_Q.Gross_Salary, I.Increment_Effective_Date, I.Payment_Mode, I.Inc_Bank_AC_No, I.Emp_OT, I.Emp_OT_Min_Limit, I.Emp_OT_Max_Limit, I.Emp_Late_mark, 
                      I.Emp_Full_PF, I.Emp_PT, I.Emp_Fix_Salary, I.Emp_Part_Time, I.Late_Dedu_Type, I.Emp_Late_Limit, I.Emp_PT_Amount, I.Emp_Childran, I.Is_Master_Rec, e.IS_Emp_FNF, e.Probation, 
                      I.Is_Deputation_Reminder, ISNULL(LEFT(I.Deputation_End_Date, 12), '') AS Deputation_End_Date, I.Increment_Type, e.Worker_Adult_No, e.Father_name, e.Bank_BSR, e.Old_Ref_No, 
                      e.Alpha_Emp_Code, (CASE WHEN ISNULL(e.Alpha_Code, '') = '' THEN NULL ELSE e.Alpha_Code END) AS Alpha_Code, e.Leave_In_Probation, e.Is_LWF, ISNULL(I_Q.CTC, 0) AS CTC, 
                      ISNULL(I.Center_ID, 0) AS Center_ID, ISNULL(e.DBRD_Code, '') AS DBRD_Code, ISNULL(e.Dealer_Code, '') AS Dealer_Code, ISNULL(e.CCenter_Remark, '') AS CCenter_Remark, I.Emp_Early_mark, 
                      I.Early_Dedu_Type, I.Emp_Early_Limit, e.Ifsc_Code, I.Center_ID AS Expr1, I.Emp_WeekDay_OT_Rate, I.Emp_WeekOff_OT_Rate, I.Emp_Holiday_OT_Rate, e.Emp_PF_Opening, e.Emp_Category, 
                      e.Emp_UIDNo, e.Emp_Cast, e.Emp_Annivarsary_Date, e.Login_ID, e.Extra_AB_Deduction, e.CompOff_Min_hrs, e.mother_name, I.Is_Metro_City, ISNULL(I.is_physical, 0) AS is_physical, 
                      I.is_physical AS Expr2, e.Emp_Offer_Date, I.Emp_Auto_Vpf, I.Segment_ID, I.Vertical_ID, I.SubVertical_ID, I.subBranch_ID, e.GroupJoiningDate, I.Monthly_Deficit_Adjust_OT_Hrs, 
                      I.Fix_OT_Hour_Rate_WD, I.Fix_OT_Hour_Rate_WO_HO, e.Ifsc_Code_Two, I.Bank_ID_Two, I.Payment_Mode_Two, I.Inc_Bank_AC_No_Two, I.Bank_Branch_Name, I.Bank_Branch_Name_Two, 
                      e.Code_Date, e.Code_Date_Format, e.EmpName_Alias_PrimaryBank, e.EmpName_Alias_PF, e.EmpName_Alias_PT, e.EmpName_Alias_SecondaryBank, e.EmpName_Alias_Tax, 
                      e.EmpName_Alias_ESIC, e.EmpName_Alias_Salary, e.Emp_Notice_Period, e.Emp_Shoe_Size, e.Emp_Pent_Size, e.Emp_Shirt_Size, e.Emp_Dress_Code, e.Emp_Canteen_Code, e.Thana_ID, 
                      e.Tehsil, e.District, e.Thana_Id_Wok, e.Tehsil_Wok, e.District_Wok, e.SkillType_ID, e.About_Me, e.UAN_No, e.CompOff_WO_App_Days, e.CompOff_WO_Avail_Days, e.CompOff_WD_App_Days, 
                      e.CompOff_WD_Avail_Days, e.CompOff_HO_App_Days, e.CompOff_HO_Avail_Days, e.Date_of_Retirement, e.Salary_Depends_on_Production, e.Ration_Card_Type, e.Ration_Card_No, 
                      e.Vehicle_NO, e.Is_On_Training, e.Training_Month, e.Aadhar_Card_No, e.Actual_Date_Of_Birth, ISNULL(e.is_PF_Trust, 0) AS is_PF_Trust, ISNULL(e.PF_Trust_No, '') AS PF_Trust_No, 
                      REPLACE(CONVERT(VARCHAR(20), e.System_Date, 106), ' ', '-') + ' ' + dbo.F_GET_AMPM(e.System_Date) AS System_Date, e.Extension_No, e.LinkedIn_ID, e.Twitter_ID, I.Customer_Audit, 
                      e.Manager_Probation, e.PF_Start_Date, Dm.Dept_Name, Dg.Desig_Name, Bm.Branch_Name, Gm.Grd_Name, ISNULL(I.Sales_Code, '') AS Sales_Code, e.Signature_Image_Name, 
                      e.Leave_Encash_Working_Days, I.Physical_Percent, e.Is_Probation_Month_Days, e.Is_Trainee_Month_Days, I_Q.SalDate_ID
					  ,e.WeekOffCompOffAvail_After_Days,e.HolidayCompOffAvail_After_Days,e.WeekdayCompOffAvail_After_Days,e.Band_Id,e.Is_Pradhan_Mantri,e.Is_1time_PF_Member,E.Emp_Cast_Join
FROM         dbo.T0060_EMP_MASTER_APP AS e WITH (NOLOCK) INNER JOIN
                      dbo.T0070_EMP_INCREMENT_APP AS I WITH (NOLOCK)  ON e.Emp_Tran_ID = I.Emp_Tran_ID INNER JOIN
                          (SELECT     MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_Tran_ID
                            FROM          dbo.T0070_EMP_INCREMENT_APP AS I2 WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(I3.Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, I3.Emp_Tran_ID
                                                         FROM          dbo.T0070_EMP_INCREMENT_APP AS I3 WITH (NOLOCK)  INNER JOIN
                                                                                dbo.T0060_EMP_MASTER_APP AS EM WITH (NOLOCK)  ON EM.Emp_Tran_ID = I3.Emp_Tran_ID
                                                         WHERE      (I3.Increment_Effective_Date <= (CASE WHEN EM.Date_Of_Join >= GETDATE() THEN EM.Date_Of_Join ELSE GETDATE() END))
                                                         GROUP BY I3.Emp_Tran_ID) AS I3_2 ON I2.Increment_Effective_Date = I3_2.INCREMENT_EFFECTIVE_DATE AND I2.Emp_Tran_ID = I3_2.Emp_Tran_ID
                            GROUP BY I2.Emp_Tran_ID) AS I2_1 ON I.Emp_Tran_ID = I2_1.Emp_Tran_ID AND I.Increment_ID = I2_1.Increment_ID INNER JOIN
                      dbo.T0070_EMP_INCREMENT_APP AS I_Q WITH (NOLOCK)  ON e.Emp_Tran_ID = I_Q.Emp_Tran_ID INNER JOIN
                          (SELECT     MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_Tran_ID
                            FROM          dbo.T0070_EMP_INCREMENT_APP AS I2 WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(I3.Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, I3.Emp_Tran_ID
                                                         FROM          dbo.T0070_EMP_INCREMENT_APP AS I3 WITH (NOLOCK)  INNER JOIN
                                                                                dbo.T0060_EMP_MASTER_APP AS EM WITH (NOLOCK)  ON EM.Emp_Tran_ID = I3.Emp_Tran_ID
                                                         WHERE      (I3.Increment_Effective_Date <= (CASE WHEN EM.Date_Of_Join >= GETDATE() THEN EM.Date_Of_Join ELSE GETDATE() END)) AND (I3.Increment_Type NOT IN ('Transfer', 
                                                                                'Deputation'))
                                                         GROUP BY I3.Emp_Tran_ID) AS I3_1 ON I2.Increment_Effective_Date = I3_1.INCREMENT_EFFECTIVE_DATE AND I2.Emp_Tran_ID = I3_1.Emp_Tran_ID
                            GROUP BY I2.Emp_Tran_ID) AS I2_Q ON I_Q.Emp_Tran_ID = I2_Q.Emp_Tran_ID AND I_Q.Increment_ID = I2_Q.Increment_ID LEFT OUTER JOIN
                          (SELECT     ES.Shift_ID, ES.Emp_Tran_ID
                            FROM          dbo.T0065_EMP_SHIFT_DETAIL_APP AS ES WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(Approved_Date) AS Approved_Date, Emp_Tran_ID
                                                         FROM          dbo.T0065_EMP_SHIFT_DETAIL_APP AS ES1 WITH (NOLOCK) 
                                                         WHERE      (Approved_Date < GETDATE()) AND (Shift_Type <> 1)
                                                         GROUP BY Emp_Tran_ID) AS ES1_1 ON ES.Emp_Tran_ID = ES1_1.Emp_Tran_ID AND ES.Approved_Date = ES1_1.Approved_Date) AS ESD ON 
    ESD.Emp_Tran_ID = e.Emp_Tran_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS Dm WITH (NOLOCK)  ON Dm.Dept_Id = I.Dept_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS Dg WITH (NOLOCK)  ON Dg.Desig_ID = I.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER AS Gm WITH (NOLOCK)  ON Gm.Grd_ID = I.Grd_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS Bm WITH (NOLOCK)  ON Bm.Branch_ID = I.Branch_ID LEFT OUTER JOIN
                          (SELECT     R.Emp_Tran_ID, R.R_Emp_ID AS Emp_Superior
                            FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(R1.Row_ID) AS ROW_ID, R1.Emp_Tran_ID
                                                         FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R1 WITH (NOLOCK)  INNER JOIN
                                                                                    (SELECT     MAX(Approved_Date) AS Approved_Date, Emp_Tran_ID
                                                                                      FROM          dbo.T0065_EMP_REPORTING_DETAIL_APP AS R2 WITH (NOLOCK) 
                                                                                      GROUP BY Emp_Tran_ID) AS R2_1 ON R1.Emp_Tran_ID = R2_1.Emp_Tran_ID AND R1.Approved_Date = R2_1.Approved_Date
                                                         GROUP BY R1.Emp_Tran_ID) AS R1_1 ON R.Emp_Tran_ID = R1_1.Emp_Tran_ID AND R.Row_ID = R1_1.ROW_ID) AS R_1 ON e.Emp_Tran_ID = R_1.Emp_Tran_ID


