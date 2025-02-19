





Create VIEW [dbo].[V0090_Emp_Reporting_manager_Get_Backupby_Ronakk10022022]
AS
Select DISTINCT * , 
		Case When t.Cmp_ID = t.R_Cmp_Id THEN t.R_Emp_Full_Name1 ELSE t.R_Emp_Full_Name1 + ' - ' + t.Company_name END as R_Emp_Full_Name 
from (
		Select *,
				(Select Cmp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = temp.R_Emp_ID ) as R_Cmp_Id,
				(Select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK)  where Cmp_ID = (Select Cmp_ID from T0080_EMP_MASTER WITH (NOLOCK)  where Emp_ID = temp.R_Emp_ID ) ) as Company_name
		from (
					SELECT     dbo.T0090_EMP_REPORTING_DETAIL.Row_ID, dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID, dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID, 
										  dbo.T0090_EMP_REPORTING_DETAIL.Cmp_ID, dbo.T0090_EMP_REPORTING_DETAIL.Reporting_To, 
										  dbo.T0090_EMP_REPORTING_DETAIL.Reporting_Method
										  , CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(15)) 
										  + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS R_Emp_Full_Name1                      
										  , T0080_EMP_MASTER_1.Alpha_Emp_Code, 
										  T0080_EMP_MASTER_1.Emp_Full_Name, Qry.Branch_ID, Qry.Dept_ID, Qry.Desig_Id, ISNULL(Qry.Grd_ID, 0) AS Grd_ID, ISNULL(Qry.Cat_ID, 0) 
										  AS Cat_ID, BM.Branch_Name,qry.Vertical_ID,qry.SubVertical_ID,dbo.T0090_EMP_REPORTING_DETAIL.Effect_Date
					FROM         dbo.T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) 
								INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID  
								INNER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID = T0080_EMP_MASTER_1.Emp_ID and T0080_EMP_MASTER_1.Emp_Left <> 'Y' 
								INNER JOIN  (
												SELECT     Increment_ID, SInc.Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Bank_ID, Curr_ID, Wages_Type, 
														   Salary_Basis_On, Basic_Salary, Gross_Salary, Increment_Type, Increment_Date, Increment_Effective_Date, Payment_Mode, 
														   Inc_Bank_AC_No, Emp_OT, Emp_OT_Min_Limit, Emp_OT_Max_Limit, Increment_Per, Increment_Amount, Pre_Basic_Salary, 
														   Pre_Gross_Salary, Increment_Comments, Emp_Late_mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary, Emp_Part_Time, Late_Dedu_Type, 
														   Emp_Late_Limit, Emp_PT_Amount, Emp_Childran, Is_Master_Rec, Login_ID, System_Date, Yearly_Bonus_Amount, 
														   Deputation_End_Date, Is_Deputation_Reminder, Appr_Int_ID, CTC, Emp_Early_mark, Early_Dedu_Type, Emp_Early_Limit, 
														   Emp_Deficit_mark, Deficit_Dedu_Type, Emp_Deficit_Limit, Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, 
														   Emp_Holiday_OT_Rate,Vertical_ID,SubVertical_ID
											  FROM  dbo.T0095_INCREMENT AS SInc WITH (NOLOCK) 
													INNER JOIN (
																	SELECT MAX(I.Increment_ID) as IncID,I.Emp_ID 
																		FROM T0095_INCREMENT I WITH (NOLOCK) 
																	INNER JOIN(
																				SELECT MAX(Increment_Effective_Date) AS For_Date,ssInc.Emp_ID
																					FROM dbo.T0095_INCREMENT AS ssInc WITH (NOLOCK) 
																				Where ssInc.Increment_Effective_Date <= GETDATE()
																				GROUP BY ssInc.Emp_ID 
																			  ) as Qry
																	ON I.Increment_Effective_Date = Qry.For_Date and I.Emp_ID = Qry.Emp_ID
																	GROUP BY I.Emp_ID
																) As Qry_1 
													ON SInc.Increment_ID = Qry_1.IncID AND Sinc.Emp_ID = Qry_1.Emp_ID
											 ) AS Qry ON T0080_EMP_MASTER_1.Emp_ID = Qry.Emp_ID 
								INNER JOIN dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON BM.Branch_ID = Qry.Branch_ID
				) as  temp
) as t




