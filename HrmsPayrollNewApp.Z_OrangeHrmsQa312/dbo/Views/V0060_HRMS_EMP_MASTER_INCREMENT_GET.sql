

CREATE VIEW [dbo].[V0060_HRMS_EMP_MASTER_INCREMENT_GET]
AS
SELECT     e.Emp_code, e.Initial, e.Emp_First_Name, e.Emp_Second_Name, e.Emp_Last_Name, e.Date_Of_Join, e.SSN_No, e.SIN_No, e.Dr_Lic_No, e.Pan_No, e.Date_Of_Birth, 
                      e.Marital_Status, e.Gender, e.Dr_Lic_Ex_Date, e.Nationality, e.Loc_ID, e.Street_1, e.City, e.State, e.Zip_code, e.Home_Tel_no, e.Mobile_No, e.Work_Tel_No, 
                      e.Work_Email, e.Other_Email, e.Image_Name, e.Emp_Full_Name, e.Emp_Left, e.Emp_Left_Date, I.Increment_ID, e.Present_Street, e.Present_City, e.Present_State, 
                      e.Present_Post_Box, R.Emp_Superior, e.Enroll_No, e.Blood_Group, e.Tally_Led_Name, e.Religion, e.Height, e.Emp_Mark_Of_Identification, e.Despencery, 
                      e.Doctor_Name, e.DespenceryAddress, e.Insurance_No, e.Is_Gr_App, e.Is_Yearly_Bonus, e.Yearly_Leave_Days, e.Yearly_Leave_Amount, e.Yearly_Bonus_Per, 
                      e.Yearly_Bonus_Amount, e.Emp_Confirm_Date, e.Is_On_Probation, e.Tally_Led_ID, e.Emp_ID, e.Cmp_ID, isnull(ESD.Shift_ID,e.Shift_ID)as Shift_ID, i.Branch_ID, i.Cat_ID, i.Grd_ID, i.Dept_ID, 
                      i.Desig_Id, i.Type_ID, i.Bank_ID, i.Curr_ID, i.Wages_Type, i.Salary_Basis_On, i.Basic_Salary, i.Gross_Salary, i.Increment_Effective_Date, i.Payment_Mode, 
                      i.Inc_Bank_AC_No, i.Emp_OT, i.Emp_OT_Min_Limit, i.Emp_OT_Max_Limit, i.Emp_Late_mark, i.Emp_Full_PF, i.Emp_PT, i.Emp_Fix_Salary, i.Emp_Part_Time, 
                      i.Late_Dedu_Type, i.Emp_Late_Limit, i.Emp_PT_Amount, i.Emp_Childran, i.Is_Master_Rec, e.IS_Emp_FNF, e.Probation, i.Is_Deputation_Reminder, 
                      ISNULL(LEFT(i.Deputation_End_Date, 12), '') AS Deputation_End_Date, i.Increment_Type, e.Worker_Adult_No, e.Father_name, e.Bank_BSR, e.Old_Ref_No, 
                      e.Alpha_Emp_Code, (CASE WHEN ISNULL(e.Alpha_Code, '') = '' THEN NULL ELSE e.Alpha_Code END) AS Alpha_Code, e.Leave_In_Probation, e.Is_LWF, ISNULL(i.CTC,
                       0) AS CTC, ISNULL(i.Center_ID, 0) AS Center_ID, ISNULL(e.DBRD_Code, '') AS DBRD_Code, ISNULL(e.Dealer_Code, '') AS Dealer_Code, ISNULL(e.CCenter_Remark, '') 
                      AS CCenter_Remark, i.Emp_Early_mark, i.Early_Dedu_Type, i.Emp_Early_Limit, e.Ifsc_Code, i.Center_ID AS Expr1, i.Emp_WeekDay_OT_Rate, 
                      i.Emp_WeekOff_OT_Rate, i.Emp_Holiday_OT_Rate, e.Emp_PF_Opening, e.Emp_Category, e.Emp_UIDNo, e.Emp_Cast, e.Emp_Annivarsary_Date, e.Login_ID, 
                      e.Extra_AB_Deduction, e.CompOff_Min_hrs, e.mother_name, i.Is_Metro_City, ISNULL(i.is_physical, 0) AS is_physical, i.is_physical AS Expr2, e.Emp_Offer_Date, 
                      ESC.SalDate_id, i.Emp_Auto_Vpf, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID, e.GroupJoiningDate, i.Monthly_Deficit_Adjust_OT_Hrs, 
                      i.Fix_OT_Hour_Rate_WD, i.Fix_OT_Hour_Rate_WO_HO, e.Ifsc_Code_Two, i.Bank_ID_Two, i.Payment_Mode_Two, i.Inc_Bank_AC_No_Two, i.Bank_Branch_Name, 
                      i.Bank_Branch_Name_Two, e.Code_Date, e.Code_Date_Format, e.EmpName_Alias_PrimaryBank, e.EmpName_Alias_PF, e.EmpName_Alias_PT, 
                      e.EmpName_Alias_SecondaryBank, e.EmpName_Alias_Tax, e.EmpName_Alias_ESIC, e.EmpName_Alias_Salary, e.Emp_Notice_Period, e.Emp_Shoe_Size, 
                      e.Emp_Pent_Size, e.Emp_Shirt_Size, e.Emp_Dress_Code, e.Emp_Canteen_Code, e.Thana_Id, e.Tehsil, e.District, e.Thana_Id_Wok, e.Tehsil_Wok, e.District_Wok, 
                      e.SkillType_ID, e.About_Me, e.UAN_No, e.CompOff_WO_App_Days, e.CompOff_WO_Avail_Days, e.CompOff_WD_App_Days, e.CompOff_WD_Avail_Days, 
                      e.CompOff_HO_App_Days, e.CompOff_HO_Avail_Days, e.Date_of_Retirement, e.Salary_Depends_on_Production, e.Ration_Card_Type, e.Ration_Card_No, 
                      e.Vehicle_NO, e.Is_On_Training, e.Training_Month, e.Aadhar_Card_No, e.Actual_Date_Of_Birth, ISNULL(e.is_PF_Trust, 0) AS is_PF_Trust, ISNULL(e.PF_Trust_No, '') 
                      AS PF_Trust_No, REPLACE(CONVERT(VARCHAR(20), e.System_Date, 106), ' ', '-') + ' ' + dbo.F_GET_AMPM(e.System_Date) AS System_Date, e.Extension_No,e.LinkedIn_ID,e.Twitter_ID
                      ,i.Customer_Audit ,E.Manager_Probation ,e.PF_Start_Date  -- Jaina 22-08-2016 (Customer_Audit); Rohit 26082016 (Manager_Probation);Jaina 02-09-2016(PF_Start_Date)
                      ,dm.Dept_Name,dg.Desig_Name, bm.Branch_Name,gm.Grd_Name  -- Jimit (Dept_Name & Desig_Name on 07112016) and ( Branch_Name & Grd_Name on 12112016 )
                      ,ISNULL(I.Sales_Code , '') AS Sales_Code --Ramiz 07122016 (Sales_Code)
                      ,e.Signature_Image_Name  --Added by Jaina 04-01-2017
                      ,E.Leave_Encash_working_days --Added By Jimit 03022018
                      ,I.Physical_Percent			--added by Krushna 05-07-2018
                      ,e.Is_Probation_Month_Days,e.Is_Trainee_Month_Days
					 ,Isnull(e.WeekOffCompOffAvail_After_Days,0)WeekOffCompOffAvail_After_Days ,
					  Isnull(e.HolidayCompOffAvail_After_Days,0) HolidayCompOffAvail_After_Days ,
					  Isnull(e.WeekdayCompOffAvail_After_Days,0) WeekdayCompOffAvail_After_Days,
					  SV.SubVertical_Name,VI.Vertical_Name,BS.Segment_Name,Cat_Name
FROM        dbo.T0080_EMP_MASTER AS e WITH (NOLOCK) INNER JOIN
			T0095_INCREMENT I WITH (NOLOCK)  ON e.Emp_ID = I.Emp_ID INNER JOIN 
				 (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
				  FROM	T0095_INCREMENT I2 WITH (NOLOCK)  
						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM	T0095_INCREMENT I3 WITH (NOLOCK)  INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON EM.Emp_ID = I3.EMp_ID
									--WHERE	I3.Increment_Effective_Date <= GETDATE() --Comment by Nilesh patel on 19042017 For future date edit
									WHERE	I3.Increment_Effective_Date <= (Case WHEN EM.Date_Of_Join >= GETDATE() then EM.Date_Of_Join Else GETDATE() END)
									GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
				 
				  GROUP BY I2.Emp_ID
				) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID				
			LEFT OUTER JOIN	
			(          
				SELECT	ES.Shift_ID,ES.Emp_ID
				FROM	T0100_EMP_SHIFT_DETAIL ES WITH (NOLOCK) 
						INNER JOIN  (SELECT max(ES1.For_Date) AS For_Date,ES1.Emp_ID 
									 FROM T0100_EMP_SHIFT_DETAIL AS ES1 WITH (NOLOCK) 
									 WHERE	ES1.For_Date < GETDATE() AND ES1.Shift_Type <> 1   --Temp Shift not dispaly 
									 GROUP BY ES1.Emp_ID) ES1 ON ES.Emp_ID=ES1.Emp_ID AND ES.For_Date=ES1.For_Date
			) as ESD ON ESD.Emp_ID = e.Emp_ID
			LEFT OUTER JOIN (SELECT	SalDate_id,ESC.Emp_ID 
							FROM	T0095_Emp_Salary_Cycle ESC WITH (NOLOCK) 
									INNER JOIN (SELECT	Max(Effective_Date) As Effective_Date, Emp_ID  
												FROM	T0095_Emp_Salary_Cycle WITH (NOLOCK) 
												WHERE	Effective_Date < GETDATE() 
												GROUP BY EMP_ID) ESC1 ON ESC.EMP_ID=ESC1.EMP_ID AND ESC.Effective_Date=ESC1.Effective_Date
							) ESC ON ESC.EMP_ID=E.EMP_ID
			Left Outer JOIN T0040_DEPARTMENT_MASTER Dm WITH (NOLOCK)  On dm.Dept_Id = i.Dept_ID
			Left Outer JOIN T0040_DESIGNATION_MASTER Dg WITH (NOLOCK)  On dg.Desig_ID = i.Desig_ID
			Left Outer JOIN T0040_GRADE_MASTER Gm WITH (NOLOCK)  On gm.Grd_ID = i.Grd_ID
			left OUTER JOIN T0030_BRANCH_MASTER Bm WITH (NOLOCK)  on Bm.Branch_ID = i.Branch_ID
			Left Outer JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK)  On CM.Cat_ID = i.Cat_ID
			LEFT OUTER JOIN T0040_Vertical_Segment VI WITH (NOLOCK)  ON VI.Vertical_ID=I.Vertical_ID
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK)  ON SV.SubVertical_ID=I.SubVertical_ID
			LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK)  ON BS.Segment_ID=I.Segment_ID
			LEFT OUTER JOIN (
							select	R.EMP_ID,R.R_EMP_ID AS Emp_Superior
							FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) 
									INNER JOIN (SELECT	MAX(R1.ROW_ID) AS ROW_ID, R1.EMP_ID
												FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) 
														INNER JOIN (SELECT	MAX(R2.EFFECT_DATE) AS EFFECT_DATE, R2.EMP_ID
																	FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) 
																	GROUP	BY EMP_ID
																	) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE
												GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
							) R ON E.EMP_ID=R.EMP_ID
