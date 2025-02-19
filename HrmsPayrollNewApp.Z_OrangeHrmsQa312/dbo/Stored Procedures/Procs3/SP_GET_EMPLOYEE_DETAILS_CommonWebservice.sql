


 
 ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_EMPLOYEE_DETAILS_CommonWebservice]
	@Date Datetime,	
	@Type varchar(10) = '',		--ALL , ACTIVE , LEFT
	@Cmp_ID numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Type = ''
		SET @Type = 'ALL'
	
	IF @Type = 'Active'
		SET  @Type = 'N'
	
	IF @Type = 'Left'
		SET  @Type = 'Y' 
	
	IF @Type = 'ALL'
		BEGIN
			SELECT	ISNULL(EM.Alpha_Emp_Code,'') AS 'Alpha_Emp_Code',EM.Initial,EM.Emp_Full_Name,ISNULL(DM.Desig_Name,'') AS 'Desig_Name',EM1.Emp_Full_Name AS 'Reporting_Manager', cm.Cmp_Name, 
					EM1.Alpha_Emp_Code AS 'Reporting_Manager_Code', ISNULL(stuff((SELECT SM.Skill_Name + ',' FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH ('')),len((SELECT SM.Skill_Name + ',' 
					FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH (''))),1,''),'') AS 'Skills'
					,ISNULL(EM.Work_Email,'') AS 'Work_Email',Ln.Login_Name,EM.Date_of_Birth,EM.Date_OF_Join,EM.Emp_Confirm_Date ,BM.Branch_Name,BM.Branch_Code,
					ISNULL(DeptM.Dept_Name,'') AS 'Dept_Name',ISNULL(GM.grd_Name,'') AS Grade_Name ,ISNULL(EM.Mobile_No,'') AS Mobile_No,CASE WHEN EM.Gender='M' THEN 'Male' ELSE 'Female' END AS 'Gender',
					EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,ISNULL(SBM.SubBranch_Name,'-') AS 'Sub_Branch',SBM.SubBranch_Code,TM.Type_Name,EM.Pan_No,LEM.Reg_Date AS 'Resign_Date',
					CTM.Cat_Name AS 'Place_of_posting',EM.SSN_No AS 'PF_No',EM.SIN_No AS 'ESIC_No',EM.Dr_Lic_No,EM.Nationality,EM.Street_1 AS 'Permanent_Address',EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,
					EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,EM.Image_Name,BN.Bank_Name,Qry.Inc_Bank_AC_No,EM.Emp_Left,EM.Emp_Left_Date,EM.Present_Street [Working_Address],EM.Present_City,EM.Present_State,
					EM.Present_Post_Box,EM.Enroll_No,Qry.Emp_Full_PF,Qry.Emp_PT,Qry.Emp_Fix_Salary,Qry.Emp_Part_Time,Qry.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,EM.Insurance_No,
					EM.Emp_Confirm_Date,DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,Qry.wages_type,EM.Basic_Salary,Qry.Gross_Salary,EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,EM.Branch_ID,
					CASE WHEN EM.Marital_Status = '0' THEN 'Single' WHEN EM.Marital_Status = '1' THEN 'Married' WHEN EM.Marital_Status = '2' THEN 'Divorced' WHEN EM.Marital_Status = '3' THEN 'Saperated' END AS Marital_Status,
					(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) AS 'Age',EM.Emp_Superior AS 'Manager_Code',SCM.Name AS 'Salary_Cycle',
					Bs.Segment_Name,EM.GroupJoiningDate,CASE WHEN Qry.Increment_Type = 'Transfer' THEN 1 ELSE 0 END AS 'Employee_Transfer',
					CASE WHEN Qry.Increment_Type = 'Transfer' THEN Qry.Increment_Effective_Date ELSE Null END AS 'Transfer_Date',CASE WHEN Qry.Increment_Type = 'Increment' THEN Qry.Increment_Effective_Date ELSE NULL END AS 'Increment_Date'
			FROM T0080_EMP_MASTER EM WITH (NOLOCK)
			LEFT JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON EM.Emp_Superior = EM1.Emp_ID			
			LEFT JOIN(
					SELECT i.Cmp_ID, i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,
					I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID 
					FROM T0095_Increment i  WITH (NOLOCK)
					INNER JOIN(
						SELECT max(Increment_effective_Date) AS 'Increment_effective_Date', Emp_ID 
						FROM T0095_Increment  WITH (NOLOCK)
						WHERE Increment_Effective_date <= @Date 
						GROUP BY emp_ID
							  ) AS inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_effective_Date = i.Increment_Effective_Date
					 ) Qry ON EM.Emp_ID = Qry.Emp_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Qry.Desig_Id = DM.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON EM.Grd_ID = GM.Grd_ID	
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) ON EM.Dept_ID = DeptM.Dept_Id
				LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON EM.Type_ID = TM.Type_ID	
				INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID
				INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON em.Branch_ID = BM.Branch_ID
				LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON EM.Cat_ID=CTM.Cat_ID
				LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) ON VTS.Vertical_ID=EM.Vertical_ID
				LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) ON SubVT.SubVertical_ID=EM.SubVertical_ID
				LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Bn.Bank_ID=EM.Bank_ID
				LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID=Qry.Center_ID
				LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCm.Tran_Id=Qry.SalDate_id
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID=Qry.Segment_ID
				LEFT JOIN T0050_SubBranch SBM WITH (NOLOCK) ON Qry.SubBranch_ID = SBM.subBranch_ID
				LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) ON LEM.Emp_ID=EM.Emp_ID 
				LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON Qry.Cmp_ID = CM.Cmp_Id
				WHERE Em.date_of_join <=@Date and EM.CMP_ID = @CMP_ID
				ORDER BY CASE WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 1 THEN Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
				WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 0 THEN Left(EM.Alpha_Emp_Code + Replicate('',21), 20) ELSE EM.Alpha_Emp_Code END
		END
	ELSE
		BEGIN
			SELECT ISNULL(EM.Alpha_Emp_Code,'') AS 'Alpha_Emp_Code',EM.Initial,EM.Emp_Full_Name,ISNULL(DM.Desig_Name,'') AS 'Desig_Name',EM1.Emp_Full_Name AS 'Reporting_Manager', cm.Cmp_Name, 
			EM1.Alpha_Emp_Code AS 'Reporting_Manager_Code', ISNULL(stuff((SELECT SM.Skill_Name + ',' FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH ('')),len((SELECT SM.Skill_Name + ',' 
			FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH (''))),1,''),'') AS 'Skills'
			,ISNULL(EM.Work_Email,'') AS 'Work_Email',Ln.Login_Name,EM.Date_of_Birth,EM.Date_OF_Join,EM.Emp_Confirm_Date ,BM.Branch_Name,BM.Branch_Code,
			ISNULL(DeptM.Dept_Name,'') AS 'Dept_Name',ISNULL(GM.grd_Name,'') AS Grade_Name ,ISNULL(EM.Mobile_No,'') AS Mobile_No,CASE WHEN EM.Gender='M' THEN 'Male' ELSE 'Female' END AS 'Gender',
			EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,ISNULL(SBM.SubBranch_Name,'-') AS 'Sub_Branch',SBM.SubBranch_Code,TM.Type_Name,EM.Pan_No,LEM.Reg_Date AS 'Resign_Date',
			CTM.Cat_Name AS 'Place_of_posting',EM.SSN_No AS 'PF_No',EM.SIN_No AS 'ESIC_No',EM.Dr_Lic_No,EM.Nationality,EM.Street_1 AS 'Permanent_Address',EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,
			EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,EM.Image_Name,BN.Bank_Name,Qry.Inc_Bank_AC_No,EM.Emp_Left,EM.Emp_Left_Date,EM.Present_Street [Working_Address],EM.Present_City,EM.Present_State,
			EM.Present_Post_Box,EM.Enroll_No,Qry.Emp_Full_PF,Qry.Emp_PT,Qry.Emp_Fix_Salary,Qry.Emp_Part_Time,Qry.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,EM.Insurance_No,
			EM.Emp_Confirm_Date,DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,Qry.wages_type,EM.Basic_Salary,Qry.Gross_Salary,EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,EM.Branch_ID,
			CASE WHEN EM.Marital_Status = '0' THEN 'Single' WHEN EM.Marital_Status = '1' THEN 'Married' WHEN EM.Marital_Status = '2' THEN 'Divorced' WHEN EM.Marital_Status = '3' THEN 'Saperated' END AS Marital_Status,
			(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) AS 'Age',EM.Emp_Superior AS 'Manager_Code',SCM.Name AS 'Salary_Cycle',
			Bs.Segment_Name,EM.GroupJoiningDate,CASE WHEN Qry.Increment_Type = 'Transfer' THEN 1 ELSE 0 END AS 'Employee_Transfer',
			CASE WHEN Qry.Increment_Type = 'Transfer' THEN Qry.Increment_Effective_Date ELSE Null END AS 'Transfer_Date',CASE WHEN Qry.Increment_Type = 'Increment' THEN Qry.Increment_Effective_Date ELSE NULL END AS 'Increment_Date'
			FROM T0080_EMP_MASTER EM WITH (NOLOCK)
			LEFT JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON EM.Emp_Superior = EM1.Emp_ID			
			LEFT JOIN(
					SELECT i.Cmp_ID, i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,
					I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID 
					FROM T0095_Increment i WITH (NOLOCK)
					INNER JOIN(
						SELECT max(Increment_effective_Date) AS 'Increment_effective_Date', Emp_ID 
						FROM T0095_Increment WITH (NOLOCK)
						WHERE Increment_Effective_date <= @Date 
						GROUP BY emp_ID
							  ) AS inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_effective_Date = i.Increment_Effective_Date
					 ) Qry ON EM.Emp_ID = Qry.Emp_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Qry.Desig_Id = DM.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON EM.Grd_ID = GM.Grd_ID	
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) ON EM.Dept_ID = DeptM.Dept_Id
				LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON EM.Type_ID = TM.Type_ID	
				INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID
				INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON em.Branch_ID = BM.Branch_ID
				LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON EM.Cat_ID=CTM.Cat_ID
				LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) ON VTS.Vertical_ID=EM.Vertical_ID
				LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) ON SubVT.SubVertical_ID=EM.SubVertical_ID
				LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Bn.Bank_ID=EM.Bank_ID
				LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID=Qry.Center_ID
				LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCm.Tran_Id=Qry.SalDate_id
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID=Qry.Segment_ID
				LEFT JOIN T0050_SubBranch SBM WITH (NOLOCK) ON Qry.SubBranch_ID = SBM.subBranch_ID
				LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) ON LEM.Emp_ID=EM.Emp_ID 
				LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON Qry.Cmp_ID = CM.Cmp_Id
				WHERE Em.date_of_join <=@Date AND Em.Emp_Left = @Type and EM.CMP_ID = @CMP_ID
				ORDER BY CASE WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 1 THEN Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
				WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 0 THEN Left(EM.Alpha_Emp_Code + Replicate('',21), 20) ELSE EM.Alpha_Emp_Code END
		END
END


