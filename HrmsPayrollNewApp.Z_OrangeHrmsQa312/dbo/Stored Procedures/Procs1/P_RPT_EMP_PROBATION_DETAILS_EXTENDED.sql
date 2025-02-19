

-- =============================================
-- Author:		<Author,,ANKIT>
-- Create date: <Create Date,,26032016>
-- Description:	<Description,,Employee Probation Extend List Get>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_RPT_EMP_PROBATION_DETAILS_EXTENDED]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		numeric = 0
	,@Cat_ID		numeric = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric = 0
	,@Dept_ID		numeric = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric = 0
	,@Constraint	varchar(MAX) = ''
	,@Report_Type	VARCHAR(30)  = 'Probation'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF ISNULL(@Report_Type,'') = ''
		SET @Report_Type = 'Probation'

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	  )            
    
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,0,0,0,0,0,0,@constraint,0,0,'','','','',0,0,0,'0',0,0               
	
	IF @Report_Type = 'Training To Extended'
		BEGIN
			SELECT 
					 E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
					,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
					,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
					,Qry_E.New_Probation_EndDate AS Extend_Date,Qry_E.Extend_Period,Qry_E.Flag,Qry_E.Evaluation_Date
					,E.Emp_ID,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
			FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
					#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
					dbo.T0010_Company_master CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
					dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
					( SELECT EP.Emp_ID,EP.New_Probation_EndDate,EP.Flag,EP.Extend_Period,EP.Probation_Status,EP.Evaluation_Date FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
						( SELECT MAX(New_Probation_EndDate) AS New_Date,Emp_ID FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) --Probation_Status = 1 For Extend
						  WHERE New_Probation_EndDate <= @To_Date AND Cmp_ID = @Cmp_ID AND Probation_Status = 1 AND Flag = 'Trainee' GROUP BY Emp_ID
						) Qry ON Qry.Emp_ID = EP.Emp_ID AND Qry.New_Date = Ep.New_Probation_EndDate
					) Qry_E ON Qry_E.Emp_ID = EC.Emp_ID
			WHERE	E.Cmp_ID = @Cmp_Id 
				AND Qry_E.New_Probation_EndDate <= @TO_DATE AND Qry_E.New_Probation_EndDate >= @FROM_DATE 
			    AND Probation_Status = 1 AND Qry_E.Flag = 'Trainee'
		END
	ELSE IF @Report_Type = 'Training To Probation'
		BEGIN
			SELECT 
					 E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
					,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
					,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
					,Qry_E.New_Probation_EndDate AS Extend_Date,Qry_E.Extend_Period,Qry_E.Flag,Qry_E.Evaluation_Date
					,E.Emp_ID,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
			FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
					#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
					dbo.T0010_Company_master CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
					dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
					( SELECT EP.Emp_ID,EP.New_Probation_EndDate,EP.Flag,EP.Extend_Period,EP.Probation_Status,EP.Evaluation_Date FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
						( SELECT MAX(New_Probation_EndDate) AS New_Date,Emp_ID FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) --Probation_Status = 1 For Extend
						  WHERE New_Probation_EndDate <= @To_Date AND Cmp_ID = @Cmp_ID AND Probation_Status = 2 AND Flag = 'Trainee' GROUP BY Emp_ID
						) Qry ON Qry.Emp_ID = EP.Emp_ID AND Qry.New_Date = Ep.New_Probation_EndDate
					) Qry_E ON Qry_E.Emp_ID = EC.Emp_ID
			WHERE	E.Cmp_ID = @Cmp_Id 
				AND Qry_E.New_Probation_EndDate <= @TO_DATE AND Qry_E.New_Probation_EndDate >= @FROM_DATE 
			    AND Probation_Status = 2 AND Qry_E.Flag = 'Trainee'
		END
	ELSE IF @Report_Type = 'Probation To Extended'	
		BEGIN
			SELECT 
					 E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
					,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
					,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
					,Qry_E.New_Probation_EndDate AS Extend_Date,Qry_E.Extend_Period,Qry_E.Flag,Qry_E.Evaluation_Date
					,E.Emp_ID,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
			FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
					#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
					dbo.T0010_Company_master CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
					dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
					( SELECT EP.Emp_ID,EP.New_Probation_EndDate,EP.Flag,EP.Extend_Period,EP.Probation_Status,EP.Evaluation_Date FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
						( SELECT MAX(New_Probation_EndDate) AS New_Date,Emp_ID FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) --Probation_Status = 1 For Extend
						  WHERE New_Probation_EndDate <= @To_Date AND Cmp_ID = @Cmp_ID AND Probation_Status = 1 AND Flag = 'Probation' GROUP BY Emp_ID
						) Qry ON Qry.Emp_ID = EP.Emp_ID AND Qry.New_Date = Ep.New_Probation_EndDate
					) Qry_E ON Qry_E.Emp_ID = EC.Emp_ID
			WHERE	E.Cmp_ID = @Cmp_Id 
				AND Qry_E.New_Probation_EndDate <= @TO_DATE AND Qry_E.New_Probation_EndDate >= @FROM_DATE 
			    AND Probation_Status = 1 AND Qry_E.Flag = 'Probation'
		END
	ELSE IF @Report_Type = 'Probation'	 
		BEGIN
			SELECT 
					 E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
					,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
					,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
					,Qry_E.New_Probation_EndDate AS Extend_Date,Qry_E.Extend_Period,Qry_E.Flag,Qry_E.Evaluation_Date
					,E.Emp_ID,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
			FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
					#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
					dbo.T0010_Company_master CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
					dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
					( SELECT EP.Emp_ID,EP.New_Probation_EndDate,EP.Flag,EP.Extend_Period,EP.Probation_Status,EP.Evaluation_Date FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
						( SELECT MAX(New_Probation_EndDate) AS New_Date,Emp_ID FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK) --Probation_Status = 1 For Extend
						  WHERE New_Probation_EndDate <= @To_Date AND Cmp_ID = @Cmp_ID AND Probation_Status = 1 AND Flag = @Report_Type GROUP BY Emp_ID
						) Qry ON Qry.Emp_ID = EP.Emp_ID AND Qry.New_Date = Ep.New_Probation_EndDate
					) Qry_E ON Qry_E.Emp_ID = EC.Emp_ID
			WHERE	E.Cmp_ID = @Cmp_Id 
				AND Qry_E.New_Probation_EndDate <= @TO_DATE AND Qry_E.New_Probation_EndDate >= @FROM_DATE 
			    AND Probation_Status = 1 AND Qry_E.Flag = @Report_Type
		END
	
    
END

