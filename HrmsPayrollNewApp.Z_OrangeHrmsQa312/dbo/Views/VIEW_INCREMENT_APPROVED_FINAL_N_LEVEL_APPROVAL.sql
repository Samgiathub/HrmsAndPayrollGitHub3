








CREATE VIEW [dbo].[VIEW_INCREMENT_APPROVED_FINAL_N_LEVEL_APPROVAL]
AS
SELECT		IA.Cmp_ID, IA.App_ID, IA.Emp_ID, IA.Increment_Date, IA.Increment_Effective_Date,
			qry.Approval_Status AS Approval_Status, 
			IA.Alpha_Emp_Code, IA.Emp_Full_Name,IA.Emp_First_Name, qry.S_emp_ID AS S_Emp_ID_A, 
			qry.Rpt_Level AS Rpt_Level,IA.Emp_Left, qry.Branch_ID, qry.Cat_ID, qry.Grd_ID, qry.Dept_ID, qry.Desig_Id, qry.Type_ID, qry.Bank_ID, qry.Curr_ID, qry.Wages_Type, qry.Salary_Basis_On, 
			dbo.F_Show_Decimal(ISNULL(qry.Basic_Salary,0), IA.Cmp_ID) AS Basic_Salary, dbo.F_Show_Decimal(ISNULL(qry.Gross_Salary,0), IA.Cmp_ID) AS Gross_Salary, qry.Increment_Type, 
			qry.Payment_Mode, qry.Inc_Bank_AC_No, qry.Emp_OT, qry.Emp_OT_Min_Limit, qry.Emp_OT_Max_Limit, qry.Increment_Per, dbo.F_Show_Decimal(qry.Increment_Amount, IA.Cmp_ID) AS Increment_Amount, 
			dbo.F_Show_Decimal(ISNULL(qry.Pre_Basic_Salary,0), IA.Cmp_ID) AS Pre_Basic_Salary, dbo.F_Show_Decimal(ISNULL(qry.Pre_Gross_Salary,0), IA.Cmp_ID) AS Pre_Gross_Salary, qry.Increment_Comments, qry.Emp_Late_mark, 
			qry.Emp_Full_PF, qry.Emp_PT, qry.Emp_Fix_Salary, IA.Branch_Name, 
			--dbo.T0040_GRADE_MASTER.Grd_Name, 
			qry.Yearly_Bonus_Amount, qry.Deputation_End_Date, /*dbo.T0040_DESIGNATION_MASTER.Desig_Name,*/ dbo.F_Show_Decimal(ISNULL(qry.CTC, 0), IA.Cmp_ID) AS CTC, ISNULL(qry.Center_ID, 0) AS Center_ID, 
			dbo.F_Show_Decimal(ISNULL(qry.Pre_CTC_Salary,0), IA.Cmp_ID) AS Pre_CTC_Salary, dbo.F_Show_Decimal(ISNULL(qry.Incerment_Amount_gross,0), IA.Cmp_ID) AS Incerment_Amount_gross, 
			dbo.F_Show_Decimal(ISNULL(qry.Incerment_Amount_CTC,0), IA.Cmp_ID) AS Incerment_Amount_CTC, qry.Increment_Mode, qry.is_physical, qry.Segment_ID, qry.Vertical_ID, qry.SubVertical_ID, qry.subBranch_ID, 
			qry.Emp_Auto_Vpf, IA.GroupJoiningDate, qry.SalDate_id, qry.Reason_ID, qry.Reason_Name,qry.Approval_Status as App_Status
			,qry.Customer_Audit , ISNULL(qry.Sales_Code,'') AS Sales_Code,Ia.Remarks,IA.Is_Piece_Trans_Salary --Added By Jaina 04-10-2016 --RAMIZ (SALES_CODE ON 08122016)
FROM		dbo.V0100_INCREMENT_APPLICATION AS IA WITH (NOLOCK) INNER JOIN
              ( 
				SELECT  IAL.APP_ID AS App_ID,IAL.S_Emp_ID, IAL.Rpt_Level ,
						IAL.Increment_Amount,IAL.Pre_Basic_Salary,IAL.Reason_Name,
						/*Tran_ID,*/IAL.Branch_ID,IAL.Cat_ID,IAL.Grd_ID,IAL.Dept_ID,IAL.Desig_Id,IAL.TYPE_ID,IAL.Bank_ID,IAL.Curr_ID,IAL.Wages_Type,IAL.Salary_Basis_On,IAL.Basic_Salary,IAL.Gross_Salary,IAL.Increment_Type,Appr_Date,IAL.Increment_Effective_Date,IAL.Payment_Mode,IAL.Inc_Bank_AC_No,
						IAL.Emp_OT,IAL.Emp_OT_Min_Limit,IAL.Emp_OT_Max_Limit,IAL.Increment_Per,IAL.Pre_Gross_Salary,IAL.Increment_Comments,IAL.Emp_Late_mark,IAL.Emp_Full_PF,IAL.Emp_PT,IAL.Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,Emp_Late_Limit,Emp_PT_Amount,Is_Master_Rec,Login_ID,--System_Date,
						IAL.Yearly_Bonus_Amount,IAL.Deputation_End_Date,IAL.CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,Deficit_Dedu_Type,Emp_Deficit_Limit,IAL.Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, IAL.Pre_CTC_Salary ,IAL.Incerment_Amount_gross,
						IAL.Incerment_Amount_CTC,IAL.Increment_Mode,IAL.Emp_Childran,IAL.Is_Metro_City,IAL.is_physical,IAL.salDate_id,IAL.Emp_Auto_Vpf,IAL.Segment_ID,IAL.Vertical_ID,IAL.SubVertical_ID,IAL.SubBranch_ID,IAL.Monthly_Deficit_Adjust_OT_Hrs,IAL.Fix_OT_Hour_Rate_WD,IAL.Fix_OT_Hour_Rate_WO_HO,
						IAL.Bank_ID_Two,IAL.Payment_Mode_Two,IAL.Bank_Branch_Name,IAL.Bank_Branch_Name_Two,IAL.Inc_Bank_AC_No_Two,IAL.Reason_ID,IAL.Approval_Status,IAL.Customer_Audit , IAL.Sales_Code
                FROM   dbo.T0115_INCREMENT_APPROVAL_LEVEL AS IAL  WITH (NOLOCK) 
					INNER JOIN
						( 
							SELECT MAX(Rpt_Level) AS Rpt_Level, App_ID 
							FROM dbo.T0115_INCREMENT_APPROVAL_LEVEL  WITH (NOLOCK) 
							GROUP BY App_ID
						) AS Qry ON Qry.Rpt_Level = IAL.Rpt_Level AND Qry.App_ID = IAL.App_ID 
					INNER JOIN dbo.V0100_INCREMENT_APPLICATION AS LA  WITH (NOLOCK) ON LA.App_ID = IAL.App_ID
				WHERE     (IAL.Approval_Status = 'A') OR (IAL.Approval_Status = 'R')
			  ) AS qry ON IA.App_ID = qry.App_ID --LEFT OUTER JOIN T0120_GATE_PASS_APPROVAL GPR ON IA.App_ID =GPR.App_ID




