

 
-----//** This Is New Webservices ,Old one is [SP_Get_Emp_Detail_Service] **//--
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Employee_Data_Services] 
	@Date	Datetime,
	@Cmp_ID numeric = 1,
	@is_timestamp tinyint = 1,
	@Type numeric(18) = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @TYPE = 0	
		BEGIN				
			IF @IS_TIMESTAMP = 1 
				BEGIN
				
				--New Code of Customized Column Added By Ramiz on 05/04/2017--
						DECLARE @sql       NVARCHAR(MAX)
						DECLARE @colNames as varchar (MAX)
						SET @sql  = N''
						SET @colNames = N''

						SELECT
							@colNames = @colNames + ',' + QUOTENAME(REPLACE(CAST(column_name AS VARCHAR(MAX)),' ','_' ))
							FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
							WHERE [cmp_Id] = @Cmp_ID and Active =1


							CREATE TABLE #Cust_Column
							(
								emp_id Numeric(18,0)
							);

							DECLARE @ALTERCOLS NVARCHAR(MAX);
							SELECT @ALTERCOLS = ISNULL(@ALTERCOLS  + '', ';') + 'ALTER  TABLE #Cust_Column ADD ' + DATA + ' Varchar(max)' FROM dbo.Split(@colNames, ',') Where Data <> '';
							
							EXEC sp_executesql @ALTERCOLS;

							SET @sql = N'
							insert into #Cust_Column
							SELECT emp_id ' + isnull(@colNames,'') + ' 
							FROM (
							SELECT emp_id, REPLACE(CAST(column_name AS VARCHAR(MAX)),'' '',''_'' ) as Column_Name   , value
							FROM T0082_Emp_Column WITH (NOLOCK) inner join T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) on T0082_Emp_Column.cmp_Id =T0081_CUSTOMIZED_COLUMN.Cmp_Id and T0082_Emp_Column.mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id) up
							PIVOT (max(value) FOR Column_Name IN ( ' + isnull(STUFF(@colNames, 1, 1, ''),'[0]') + ')) AS pvt
							ORDER BY emp_id'					
							
							EXEC sp_executesql @sql;

					--Customized Column Code Ends Here--
				
						SELECT isnull(EM.Alpha_Emp_Code,'') as Alpha_Emp_Code,EM.Initial,
						EM.Emp_Full_Name,
						 isnull(DM.Desig_Name,'') as Desig_Name,Qry_Reporting.Emp_Full_Name AS Reporting_Manager,
						 Qry_Reporting.Alpha_Emp_Code as Reporting_Manager_Code ,
						isnull(stuff((SELECT SM.Skill_Name + ',' from T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH ('')),len((SELECT SM.Skill_Name + ',' from T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH (''))),1,''),'') as skills
						,ISNULL(EM.Work_Email,'')  as Work_Email,ISNULL(EM.Other_Email,'') as Personal_Email,Ln.Login_Name,
						CONVERT(VARCHAR(10),EM.Date_of_Birth,105) as Date_of_Birth,
						CONVERT(VARCHAR(10),EM.Date_OF_Join,105) as Date_OF_Join,
						CONVERT(VARCHAR(10),EM.Emp_Confirm_Date,105) as Emp_Confirm_Date,
						BM.Branch_Name,BM.Branch_Code,isnull(DeptM.Dept_Name,'') as Dept_Name,isnull(GM.grd_Name,'')as Grade_Name ,isnull(EM.Mobile_No,'') as Mobile_No,
						case when EM.Gender='M' then 'Male' else 'Female' end as Gender,
						Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,
						ISNULL(SBM.SubBranch_Name,'-') as Sub_Branch,
						SBM.SubBranch_Code,TM.Type_Name,EM.Pan_No,CONVERT(VARCHAR(10),LEM.Reg_Date,105) as Resign_Date,
						CTM.Cat_Name as Category,EM.SSN_No as PF_No,EM.SIN_No as ESIC_No,EM.Dr_Lic_No,EM.Nationality,EM.Street_1 as Permanent_Address,EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,EM.Image_Name,BN.Bank_Name,Qry.Inc_Bank_AC_No,EM.Emp_Left,CONVERT(VARCHAR(10),EM.Emp_Left_Date,105) as Emp_Left_Date ,
						EM.Present_Street [Working_Address],EM.Present_City,EM.Present_State,EM.Present_Post_Box,EM.Enroll_No,Qry.Emp_Full_PF,Qry.Emp_PT,Qry.Emp_Fix_Salary,Qry.Emp_Part_Time,Qry.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,EM.Insurance_No,CONVERT(VARCHAR(10),EM.Emp_Confirm_Date,105) as Emp_Confirm_Date,DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,
						Qry.wages_type,Qry.Basic_Salary,Qry.Gross_Salary, IsNull(Qry.CTC,0) As CTC
						,EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,Qry.Branch_ID,    --EM.Branch_ID,
						CASE WHEN EM.Marital_Status = '0' THEN 'Single' WHEN EM.Marital_Status = '1' THEN 'Married' WHEN EM.Marital_Status = '2' THEN 'Divorced' WHEN EM.Marital_Status = '3' THEN 'Saperated' END AS Marital_Status,
						(Case ISNULL(EM.Date_Of_Birth,'') when '' then '' else dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) as Age,
						EM.Emp_Superior as Manager_Code,SCM.Name as Salary_Cycle,Bs.Segment_Name,
						CONVERT(VARCHAR(10),EM.GroupJoiningDate,105) as GroupJoiningDate,
						CASE WHEN  Qry.Increment_Type = 'Transfer' THEN 1 ELSE 0 END AS Employee_Transfer,
						CASE WHEN  Qry.Increment_Type = 'Transfer' THEN Qry.Increment_Effective_Date ELSE Null END AS Transfer_Date,
						CASE WHEN Qry.Increment_Type = 'Increment' THEN Qry.Increment_Effective_Date ELSE null END AS Increment_Date
						,CC.* --Adding All Customized Fields in API
						From T0080_EMP_MASTER EM WITH (NOLOCK)
						LEFT JOIN (
									SELECT	I.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,CONVERT(VARCHAR(10),i.Increment_Effective_Date,105) as Increment_Effective_Date,
											I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,
											I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID , i.Basic_Salary ,
											I.Branch_ID , I.Dept_ID , I.Type_ID , I.Grd_ID , I.Cat_ID , i.Bank_ID , i.Vertical_ID , 
											I.SubVertical_ID 
									FROM T0095_Increment I WITH (NOLOCK)
									INNER JOIN 
										(	SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
											FROM T0095_INCREMENT I WITH (NOLOCK)
											INNER JOIN 
											(
													SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
													FROM T0095_INCREMENT I3 WITH (NOLOCK)
													WHERE I3.Increment_effective_Date <= @DATE
													GROUP BY I3.EMP_ID  
												) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
										   where I.INCREMENT_EFFECTIVE_DATE <= @DATE
										   group by I.emp_ID  
										) Qry1 on	I.Emp_ID = Qry1.Emp_ID	and I.Increment_ID = Qry1.Increment_ID 
									--INNER JOIN (
									--			SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, EMP_ID 
									--			FROM T0095_INCREMENT    
									--			WHERE INCREMENT_EFFECTIVE_DATE <= @DATE GROUP BY EMP_ID
									--			) AS INC ON INC.EMP_ID = I.EMP_ID AND INC.INCREMENT_ID = I.INCREMENT_ID
								 ) QRY ON EM.EMP_ID = QRY.EMP_ID
						LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Qry.Desig_Id = DM.Desig_Id
						LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) On Qry.Grd_ID = GM.Grd_ID	 ---EM.Grd_ID = GM.Grd_ID	
						LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) On Qry.Dept_ID = DeptM.Dept_Id --EM.Dept_ID = DeptM.Dept_Id  \\Commented By Ramiz as Dept was not Updating in case of Increment or Transfer
						LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) On Qry.Type_ID = TM.Type_ID	  --EM.Type_ID = TM.Type_ID	\\Commented By Ramiz as Type was not Updating in case of Increment or Transfer
						INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID				 -- Added By Gadriwala Muslim 18042014
						LEFT JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Qry.Branch_ID = BM.Branch_ID -- Added By Gadriwala Muslim 18042014 --\\Commented By Ramiz as Branch was not Updating in case of Increment or Transfer
						LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) on Qry.Cat_ID=CTM.Cat_ID			--EM.Cat_ID=CTM.Cat_ID
						LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) on VTS.Vertical_ID=Qry.Vertical_ID   --VTS.Vertical_ID=EM.Vertical_ID
						LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) on SubVT.SubVertical_ID=Qry.SubVertical_ID   --SubVT.SubVertical_ID=EM.SubVertical_ID
						LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) on Bn.Bank_ID=Qry.Bank_ID  --Bn.Bank_ID=EM.Bank_ID
						LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID=Qry.Center_ID
						LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) on SCm.Tran_Id=Qry.SalDate_id
						LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=Qry.Segment_ID
						LEFT JOIN T0050_SubBranch SBM WITH (NOLOCK) on  Qry.SubBranch_ID = SBM.subBranch_ID
						LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) on LEM.Emp_ID=EM.Emp_ID
						LEFT OUTER JOIN #CUST_COLUMN CC ON EM.EMP_ID = CC.EMP_ID 
						LEFT OUTER JOIN
									  (SELECT     R1.Emp_ID, R1.Effect_Date, R1.R_Emp_ID,Em.Alpha_Emp_Code , em.Emp_Full_Name
										FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK) INNER JOIN
																   (SELECT     MAX(R2.Row_ID) AS ROW_ID, R2.Emp_ID
																	 FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK) INNER JOIN
																								(SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
																								  FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
																								  WHERE      (Effect_Date < @Date)
																								  GROUP BY Emp_ID) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
																	 GROUP BY R2.Emp_ID) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID LEFT OUTER JOIN
															   dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID) AS Qry_Reporting ON EM.Emp_ID = Qry_Reporting.Emp_ID
						WHERE EM.DATE_OF_JOIN <= @DATE --AND EM.CMP_ID = @Cmp_ID
						ORDER BY 
						CASE WHEN IsNumeric(EM.Alpha_Emp_Code) = 1 THEN RIGHT(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
							 WHEN IsNumeric(EM.Alpha_Emp_Code) = 0 THEN LEFT(EM.Alpha_Emp_Code + Replicate('',21), 20)
							 ELSE EM.Alpha_Emp_Code
							 END , EM.Date_of_Join
							 
					END
				
						
			--SELECT EM.Alpha_Emp_Code , EM.Emp_Full_Name ,  IM.INS_NAME AS CERTIFICATION_TYPE , EID.INS_CMP_NAME AS NISM , EID.INS_POLICY_NO AS CERTIFICATION_NO, 
			--EID.INS_TAKEN_DATE AS EXAMINATION_DATE , EID.INS_EXP_DATE AS [EXPIRY_DATE] , CM.Cmp_Name
			--FROM T0090_EMP_INSURANCE_DETAIL EID
			--	INNER JOIN T0040_INSURANCE_MASTER IM ON EID.INS_TRAN_ID = IM.INS_TRAN_ID
			--	LEFT JOIN T0080_EMP_MASTER EM on EM.Emp_id = EID.Emp_Id
			--	INNER JOIN T0010_COMPANY_MASTER CM on CM.Cmp_Id = Em.Cmp_ID
			
			
				
		END
	ELSE IF @IS_TIMESTAMP = 2
			BEGIN
				SELECT EM.EMP_ID,ISNULL(EM.Alpha_Emp_Code,'') AS 'Alpha_Emp_Code',EM.Initial,EM.Emp_Full_Name,ISNULL(DM.Desig_Name,'') AS 'Desig_Name',
				Qry_Reporting.Emp_Full_Name AS 'Reporting_Manager',Qry_Reporting.Alpha_Emp_Code AS 'Reporting_Manager_Code',
				ISNULL(STUFF((SELECT SM.Skill_Name + ',' FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID and Emp_ID = EM.Emp_ID FOR XML PATH ('')),LEN((SELECT SM.Skill_Name + ',' FROM T0090_EMP_SKILL_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON ESD.Skill_ID = SM.Skill_ID AND Emp_ID = EM.Emp_ID FOR XML PATH (''))),1,''),'') AS 'skills',
				ISNULL(EM.Work_Email,'') AS 'Work_Email',Ln.Login_Name,CONVERT(VARCHAR(10),EM.Date_of_Birth,105) AS 'Date_of_Birth',
				CONVERT(VARCHAR(10),EM.Date_OF_Join,105) AS 'Date_OF_Join',CONVERT(VARCHAR(10),EM.Emp_Confirm_Date,105) AS 'Emp_Confirm_Date',
				BM.Branch_Name,BM.Branch_Code,ISNULL(DeptM.Dept_Name,'') AS 'Dept_Name',ISNULL(GM.grd_Name,'') AS 'Grade_Name',ISNULL(EM.Mobile_No,'') AS 'Mobile_No',
				CASE WHEN EM.Gender='M' THEN 'Male' ELSE 'Female' END AS 'Gender',Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,
				ISNULL(SBM.SubBranch_Name,'-') AS 'Sub_Branch',SBM.SubBranch_Code,TM.Type_Name,EM.Pan_No,CONVERT(VARCHAR(10),LEM.Reg_Date,105) AS 'Resign_Date',
				CTM.Cat_Name AS 'place_of_posting',EM.SSN_No AS 'PF_No',EM.SIN_No AS 'ESIC_No',EM.Dr_Lic_No,EM.Nationality,EM.Street_1 AS 'Permanent_Address',
				EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,BN.Bank_Name,Qry.Inc_Bank_AC_No,EM.Emp_Left,
				CONVERT(VARCHAR(10),EM.Emp_Left_Date,105) AS 'Emp_Left_Date',EM.Present_Street AS 'Working_Address',EM.Present_City,EM.Present_State,EM.Present_Post_Box,
				EM.Enroll_No,Qry.Emp_Full_PF,Qry.Emp_PT,Qry.Emp_Fix_Salary,Qry.Emp_Part_Time,Qry.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,
				EM.Insurance_No,CONVERT(VARCHAR(10),EM.Emp_Confirm_Date,105) AS 'Emp_Confirm_Date',DATEDIFF(MM,EM.Date_Of_Join,GETDATE()) AS 'Work_Exp_Month',Qry.wages_type,
				Qry.Basic_Salary,Qry.Gross_Salary, ISNULL(Qry.CTC,0) AS 'CTC',EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,Qry.Branch_ID,--EM.Branch_ID,
				CASE WHEN EM.Marital_Status = '0' THEN 'Single' WHEN EM.Marital_Status = '1' THEN 'Married' WHEN EM.Marital_Status = '2' THEN 'Divorced' WHEN EM.Marital_Status = '3' THEN 'Saperated' END AS 'Marital_Status',
				(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,GETDATE(),'Y','N') END ) AS 'Age',
				EM.Emp_Superior AS 'Manager_Code',SCM.Name AS 'Salary_Cycle',Bs.Segment_Name,CONVERT(VARCHAR(10),EM.GroupJoiningDate,105) AS 'GroupJoiningDate',
				CASE WHEN Qry.Increment_Type = 'Transfer' THEN 1 ELSE 0 END AS 'Employee_Transfer',
				CASE WHEN Qry.Increment_Type = 'Transfer' THEN Qry.Increment_Effective_Date ELSE NULL END AS 'Transfer_Date',
				CASE WHEN Qry.Increment_Type = 'Increment' THEN Qry.Increment_Effective_Date ELSE NULL END AS 'Increment_Date'
				From T0080_EMP_MASTER EM WITH (NOLOCK)
				LEFT JOIN V0080_Employee_Master EM1 ON EM.Emp_Superior =EM1.Emp_ID			
				LEFT JOIN 
				(
					SELECT I.CTC,I.Emp_ID,I.Desig_Id,I.subBranch_ID,I.Increment_Type,CONVERT(VARCHAR(10),I.Increment_Effective_Date,105) AS 'Increment_Effective_Date',
					I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,
					I.SalDate_id,I.Segment_ID,I.Basic_Salary,I.Branch_ID,I.Dept_ID,I.Type_ID,I.Grd_ID,I.Cat_ID,I.Bank_ID,I.Vertical_ID,I.SubVertical_ID 
					FROM T0095_Increment I WITH (NOLOCK)
					INNER JOIN 
					(
						SELECT MAX(INCREMENT_ID) AS 'INCREMENT_ID', EMP_ID 
						FROM T0095_INCREMENT WITH (NOLOCK)
						WHERE INCREMENT_EFFECTIVE_DATE <= @DATE 
						GROUP BY EMP_ID
					) AS INC ON INC.EMP_ID = I.EMP_ID AND INC.INCREMENT_ID = I.INCREMENT_ID
				) QRY ON EM.EMP_ID = QRY.EMP_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Qry.Desig_Id = DM.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Qry.Grd_ID = GM.Grd_ID	 ---EM.Grd_ID = GM.Grd_ID	
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) ON Qry.Dept_ID = DeptM.Dept_Id --EM.Dept_ID = DeptM.Dept_Id  \\Commented By Ramiz as Dept was not Updating in case of Increment or Transfer
				LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON Qry.Type_ID = TM.Type_ID	  --EM.Type_ID = TM.Type_ID	\\Commented By Ramiz as Type was not Updating in case of Increment or Transfer
				INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID				 -- Added By Gadriwala Muslim 18042014
				LEFT JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Qry.Branch_ID = BM.Branch_ID -- Added By Gadriwala Muslim 18042014 --\\Commented By Ramiz as Branch was not Updating in case of Increment or Transfer
				LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON Qry.Cat_ID=CTM.Cat_ID			--EM.Cat_ID=CTM.Cat_ID
				LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) ON VTS.Vertical_ID=Qry.Vertical_ID   --VTS.Vertical_ID=EM.Vertical_ID
				LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) ON SubVT.SubVertical_ID=Qry.SubVertical_ID   --SubVT.SubVertical_ID=EM.SubVertical_ID
				LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Bn.Bank_ID=Qry.Bank_ID  --Bn.Bank_ID=EM.Bank_ID
				LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID=Qry.Center_ID
				LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCm.Tran_Id=Qry.SalDate_id
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID=Qry.Segment_ID
				LEFT JOIN T0050_SubBranch SBM WITH (NOLOCK) ON Qry.SubBranch_ID = SBM.subBranch_ID
				LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) ON LEM.Emp_ID=EM.Emp_ID
				LEFT OUTER JOIN
				(
					SELECT R1.Emp_ID,R1.Effect_Date,R1.R_Emp_ID,Em.Alpha_Emp_Code,em.Emp_Full_Name
					FROM T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
					INNER JOIN
					(
						SELECT MAX(R2.Row_ID) AS 'ROW_ID', R2.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
						INNER JOIN
						(
							SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
							WHERE (Effect_Date < @Date)
							GROUP BY Emp_ID
						) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
						GROUP BY R2.Emp_ID
					) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID 
					LEFT OUTER JOIN T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID
				) AS Qry_Reporting ON EM.Emp_ID = Qry_Reporting.Emp_ID
				
				WHERE EM.DATE_OF_JOIN <= @DATE AND EM.CMP_Id = @CMP_ID
				ORDER BY CASE WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 1 THEN RIGHT(REPLICATE('0',21) + EM.Alpha_Emp_Code, 20)
						 WHEN ISNUMERIC(EM.Alpha_Emp_Code) = 0 THEN LEFT(EM.Alpha_Emp_Code + REPLICATE('',21), 20)
						 ELSE EM.Alpha_Emp_Code END , EM.Date_of_Join
			END
	
	
END

