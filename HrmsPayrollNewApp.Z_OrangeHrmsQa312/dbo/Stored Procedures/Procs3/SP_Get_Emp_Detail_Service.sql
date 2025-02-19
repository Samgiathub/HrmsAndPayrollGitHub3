
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Emp_Detail_Service]  
	@Date	Datetime,	
	@is_timestamp tinyint = 1,
	@Type numeric(18) = 0,
	@searchType VARCHAR(64),
	@searchText VARCHAR(1024)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	if @type = 0	
		begin				
			if @is_timestamp = 1 
				begin						
					SELECT	ISNULL(EM.Alpha_Emp_Code,'') as Alpha_Emp_Code,
							EM.Initial +' '+ EM.Emp_Full_Name as Emp_full_Name,
							ISNULL(DM.Desig_Name,'') as Desig_Name,
						 	EM.Work_Email,
							EM.Date_OF_Join,
							DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,
							EM.Initial +' '+ EM1.Emp_Full_Name AS Reporting_Manager,
							EM.Date_of_Birth,
							CASE WHEN EM.Marital_Status = '0' THEN 
									'Single' 
								WHEN EM.Marital_Status = '1' THEN 
									'Married' 
								WHEN EM.Marital_Status = '2' THEN 
									'Divorced' 
								WHEN EM.Marital_Status = '3' THEN 
									'Saperated' 
							END AS Marital_Status,
							--(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END) AS Age,
							--Case When SUBSTRING((CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END), 
							--					 LEN((CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END)), 
							--					 LEN((CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END)) -1) = '0' THEN
							--					LEFT( CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ,LEN(CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END)-1 )
							--					ELSE
							--						CASE ISNULL(EM.Date_Of_Birth,'') WHEN '' THEN '' ELSE dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END
							--					End as Age,
							EM.Emp_Superior as Manager_Code,
							Dept_Name AS Department,
							DM.DESIG_NAME AS Designation,
							GM.Grd_Name AS Grade,
							BM.BRANCH_NAME AS Branch,
							TM.TYPE_NAME AS Emp_Type
					INTO	#EMP_DETAIL
					From	T0080_EMP_MASTER EM	WITH (NOLOCK)		-- Added By Gadriwala Muslim 18042014 (Added New Field)
							LEFT JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) On EM.Emp_Superior = EM1.Emp_ID			
							LEFT JOIN (Select	i.Cmp_ID, i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID 
										From		T0095_Increment i WITH (NOLOCK)
												INNER JOIN (SELECT	MAX(Increment_effective_Date) as Increment_effective_Date, Emp_ID 
															FROM	T0095_Increment  WITH (NOLOCK)  
															WHERE	Increment_Effective_date <= @Date 
															GROUP BY emp_ID) AS inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_effective_Date = i.Increment_Effective_Date
										) Qry ON EM.Emp_ID = Qry.Emp_ID
							LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Qry.Desig_Id = DM.Desig_Id
							LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) On EM.Grd_ID = GM.Grd_ID	
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) On EM.Dept_ID = DeptM.Dept_Id
							LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) On EM.Type_ID = TM.Type_ID	
							INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID				 -- Added By Gadriwala Muslim 18042014
							INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON em.Branch_ID = BM.Branch_ID -- Added By Gadriwala Muslim 18042014
							--Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
							LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) on EM.Cat_ID=CTM.Cat_ID
							LEFT OUTER JOIN T0040_Vertical_Segment VTS WITH (NOLOCK) on VTS.Vertical_ID=EM.Vertical_ID
							LEFT OUTER JOIN T0050_SubVertical SubVT WITH (NOLOCK) on SubVT.SubVertical_ID=EM.SubVertical_ID
							LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) on Bn.Bank_ID=EM.Bank_ID
							LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID=Qry.Center_ID
							LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) on SCm.Tran_Id=Qry.SalDate_id
							LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=Qry.Segment_ID
							LEFT OUTER JOIN T0050_SubBranch SBM WITH (NOLOCK) on  Qry.SubBranch_ID = SBM.subBranch_ID
							LEFT OUTER JOIN T0100_LEFT_EMP LEM WITH (NOLOCK) on LEM.Emp_ID=EM.Emp_ID 
							LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on Qry.Cmp_ID = CM.Cmp_Id
					Where	Em.date_of_join <=@Date 
					--Order by	Case	When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
					--					When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
					--					Else EM.Alpha_Emp_Code
					--			END
					
					SELECT	* 
					FROM	#EMP_DETAIL T
					WHERE	(CASE	WHEN @searchType = 'EMP_NAME' AND Emp_full_Name like '%' + @searchText + '%' THEN 1
									WHEN @searchType = 'EMP_CODE' AND Emp_full_Name = @searchText	THEN 1
									WHEN @searchType = 'EMAIL_ID' AND Work_Email = @searchText		THEN 1								
									ELSE  0
							END) = 1
					Order by	Case	When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
										When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
										Else Alpha_Emp_Code
								END
				
			
				end
		End
END

