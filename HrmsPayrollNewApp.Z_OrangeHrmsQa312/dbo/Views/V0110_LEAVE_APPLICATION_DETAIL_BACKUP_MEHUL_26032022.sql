

CREATE VIEW [dbo].[V0110_LEAVE_APPLICATION_DETAIL_BACKUP_MEHUL_26032022]
AS
SELECT     lad.Cmp_ID, lad.Leave_ID, lad.From_Date, lad.To_Date, lad.Leave_Period, lad.Leave_Assign_As, lad.Leave_Reason, lad.Row_ID, lad.Login_ID, 
                      lad.System_Date, lad.Leave_Application_ID, LA.Emp_ID, LA.S_Emp_ID, 
                      LA.Application_Date 
                      --convert(varchar(10),LA.Application_Date ,101) as Application_date
                      , lm.Leave_Name, lm.Leave_Paid_Unpaid, 
                      E1.Emp_Full_Name, R_Emp_ID As Emp_Superior, isnull(Qry_Reporting.Emp_Full_Name,'Admin') AS Senior_Employee, LA.Application_Code, LA.Application_Status, E1.Emp_First_Name, 
                      Qry_Reporting.Emp_First_Name AS S_Emp_First_Name, e1.Emp_Left, Qry_Reporting.Other_Email AS S_Other_Email, E1.Mobile_No, lm.Leave_Min, lm.Leave_Max, 
                      lm.Leave_Notice_Period, lm.Leave_Applicable, lm.Leave_Status, dbo.T0095_INCREMENT.Grd_ID, E1.Date_Of_Join, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, Qry_Reporting.Emp_Full_Name AS S_Emp_Full_Name, E1.Other_Email, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, Qry_Reporting.Emp_code AS S_Emp_Code, dbo.T0030_BRANCH_MASTER.Branch_Name, E1.Emp_code, 
                      E1.Work_Email, E1.Alpha_Emp_Code, lad.Half_Leave_Date, lm.Default_Short_Name, LA.is_backdated_application, LA.is_Responsibility_pass, 
                      LA.Responsible_Emp_id, ISNULL(lad.Leave_App_Doc, '') AS Leave_App_Doc, LA.Application_Comments, lm.Apply_Hourly, lm.Can_Apply_Fraction, 
                      lad.leave_Out_time, lad.leave_In_time, lm.Leave_Type, lad.NightHalt, lm.AllowNightHalt, ISNULL(lad.Leave_CompOff_Dates, '') 
                      AS Leave_CompOff_Dates, lad.Half_Payment, lm.Half_Paid, lad.Warning_flag, lad.Rules_violate
                      ,dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID ,dbo.T0040_DEPARTMENT_MASTER.Dept_Name --Added By Jaina 01-10-2015 
                      ,LA.M_Cancel_WO_HO --Ankit 05082016
                      ,E1.Gender
FROM         dbo.T0100_LEAVE_APPLICATION AS LA WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON E1.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON 
                      LA.Emp_ID = E1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      --dbo.T0080_EMP_MASTER AS e ON LA.S_Emp_ID = e.Emp_ID RIGHT OUTER JOIN
                      -- LEFT OUTER JOIN
                       	--Removed by Nimesh on 30-11-2015 (Duplicate records are displaying for emp code top2010821064)
                          (SELECT   R1.Emp_ID, Effect_Date AS Effect_Date, R_Emp_ID,Em.emp_full_name,Em.Emp_First_Name,Em.Emp_code,Em.Other_Email
                            FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) 
									INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)  
													INNER JOIN (SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)  WHERE R3.Effect_Date < GETDATE() GROUP BY R3.Emp_ID) R3
													ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date
												GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID
												inner join t0080_emp_master Em WITH (NOLOCK)  on R1.R_emp_id = Em.emp_id
							) AS Qry_Reporting ON E1.Emp_ID = Qry_Reporting.Emp_ID RIGHT OUTER JOIN --Added by sumit for showing reporting manager 05120015
                      dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL AS lad WITH (NOLOCK)  ON lm.Leave_ID = lad.Leave_ID ON LA.Leave_Application_ID = lad.Leave_Application_ID LEFT OUTER JOIN
					  dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id 




