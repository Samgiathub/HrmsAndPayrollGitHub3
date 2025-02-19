

-- =============================================
-- Author:		<Author,,ANKIT>
-- Create date: <Create Date,,26032016>
-- Description:	<Description,,Employee Probation Extend List Get>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_RPT_EMP_PROBATION_DETAILS_PERFORMANCE_EVALUATION]
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
	,@Format_Type   VARCHAR(50)  = 'Performance Evaluation Form Training'
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
	
	CREATE TABLE #Emp_Manager
	(
		Emp_ID		NUMERIC,
		R_Emp_ID	NUMERIC,
		Manager_Emp_Code VARCHAR(50),
		Manager_Full_Name	VARCHAR(100)
	)
	
	INSERT INTO #Emp_Manager
	SELECT TOP 1 EP.Emp_ID,R_Qry.R_Emp_ID,E1.Alpha_Emp_Code,E1.Emp_Full_Name
	FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID INNER JOIN
		 (
		  SELECT  ER.Emp_ID,ER.R_Emp_ID FROM T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) INNER JOIN
			( SELECT Max(Effect_Date) AS ForDate,ER1.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ER1 WITH (NOLOCK) INNER JOIN #Emp_Cons EC1 ON ER1.Emp_ID = EC1.Emp_ID
			  WHERE ER1.Cmp_ID = @Cmp_Id AND ER1.Effect_Date <= @To_Date GROUP BY ER1.Emp_ID
			) Qr ON Qr.ForDate = ER.Effect_Date AND ER.Emp_ID = Qr.Emp_ID
		 ) R_Qry ON R_Qry.Emp_ID = EP.Emp_ID INNER JOIN
		 T0080_EMP_MASTER AS E1 WITH (NOLOCK) ON E1.Emp_ID = R_Qry.R_Emp_ID
	WHERE EP.Cmp_ID = @Cmp_Id
		 AND Probation_Status = 0 AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
	
	
	IF @Report_Type <> ''-- 'Probation'
		BEGIN
			SELECT 
				 Emp_Confirm_Date,E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,E.street_1,E.city,E.EMP_FIRST_NAME
				,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,E.Date_of_Join,Branch_Address,Comp_Name
				,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
				,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
				,EP.*
				,EMG.Manager_Emp_Code AS Manager_Emp_Code,EMG.Manager_Full_Name,ELR.Reference_No,ELR.Issue_Date
			FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
				 #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
				 dbo.T0010_Company_master CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
				 dbo.T0095_INCREMENT I_Q WITH (NOLOCK)  ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
				 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
				 T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) ON E.Emp_ID = EP.Emp_ID AND EP.Probation_Status = 0 AND EP.Flag = ISNULL(@Report_Type,EP.Flag) 
				 LEFT OUTER JOIN #Emp_Manager EMG ON EMG.Emp_ID = E.Emp_ID
				 left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Confirmation Letter-'+ @Format_Type--Mukti(06012017) 	 							 
			    WHERE E.Cmp_ID = @Cmp_Id
				--AND E.Emp_Confirm_Date <= @TO_DATE AND E.Emp_Confirm_Date >= @FROM_DATE  --Comment by ronakk 13122022
				--AND EP.Evaluation_Date <= @TO_DATE AND EP.Evaluation_Date >= @FROM_DATE  --Added  by ronakk 13122022
			    AND Probation_Status = 0 AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
			    
			
			----Skill
			
			SELECT ROW_NUMBER() OVER (order by ES.Skill_ID ASC) AS Sr_No,EP.Emp_ID, SM.Skill_Name,SW.Weightage,ES.Skill_Rating
			FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
				T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Emp_ID INNER JOIN
				#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID AND EP.Probation_Status = 0 INNER JOIN
				T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = i.Increment_ID AND ec.Emp_ID = I.Emp_ID INNER JOIN
				T0100_EMP_PROBATION_SKILL_DETAIL ES WITH (NOLOCK) ON EP.Probation_Evaluation_ID = ES.Emp_Prob_ID INNER JOIN
				T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = ES.Skill_ID 
				INNER JOIN
				 ( SELECT ESA.Tran_ID,ESA.Desig_Id FROM T0100_EMP_SKILL_ATTR_ASSIGN ESA WITH (NOLOCK) INNER JOIN
					( SELECT MAX(Effect_Date) AS Effect_Date,Desig_Id FROM T0100_EMP_SKILL_ATTR_ASSIGN  WITH (NOLOCK)
					  WHERE Effect_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY Desig_Id
					) Qry ON Qry.Effect_Date = ESA.Effect_Date AND Qry.Desig_Id = ESA.Desig_Id
					where ESA.Type=0 --added by ronakk 15122022
				  ) Qry_A ON Qry_A.Desig_Id = I.Desig_Id INNER JOIN
				T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON SW.Tran_Id = Qry_A.Tran_ID AND ES.Skill_ID = SW.Skill_ID
			WHERE EP.Cmp_ID = @Cmp_ID and Probation_Status = 0 
				--AND EM.Emp_Confirm_Date BETWEEN @From_Date and @To_Date --Comment by ronakk 13122022
				--AND EP.Evaluation_Date <= @TO_DATE AND EP.Evaluation_Date >= @FROM_DATE  --Added  by ronakk 13122022
				AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
				
			----Attribute
			
			SELECT ROW_NUMBER() OVER (order by EA.Attribute_ID ASC) AS Sr_No,EP.Emp_ID, AM.Attribute_Name,AW.Weightage,EA.Attr_Rating
			FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
				T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EP.Emp_ID INNER JOIN
				#Emp_Cons EC ON EP.Emp_ID = EC.Emp_ID AND EP.Probation_Status = 0 INNER JOIN
				T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID AND EC.Emp_ID = I.Emp_ID INNER JOIN
				T0100_EMP_PROBATION_ATTRIBUTE_DETAIL EA WITH (NOLOCK) ON EP.Probation_Evaluation_ID = EA.Emp_Prob_ID INNER JOIN
				T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) ON AM.Attribute_ID = EA.Attribute_ID
				
				INNER JOIN
				 ( SELECT ESA.Tran_ID,ESA.Desig_Id FROM T0100_EMP_SKILL_ATTR_ASSIGN ESA WITH (NOLOCK) INNER JOIN
					( SELECT MAX(Effect_Date) AS Effect_Date,Desig_Id FROM T0100_EMP_SKILL_ATTR_ASSIGN  WITH (NOLOCK)
					  WHERE Effect_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY Desig_Id
					) Qry ON Qry.Effect_Date = ESA.Effect_Date AND Qry.Desig_Id = ESA.Desig_Id
						where ESA.Type=0 --added by ronakk 15122022
				  ) Qry_A ON Qry_A.Desig_Id = I.Desig_Id INNER JOIN
				T0110_ATTRIBUTE_WEIGHTAGE AW WITH (NOLOCK) ON AW.Tran_Id = Qry_A.Tran_ID AND EA.Attribute_ID = AW.Attr_Id
			WHERE EP.Cmp_ID = @Cmp_ID and Probation_Status = 0 
				--AND EM.Emp_Confirm_Date BETWEEN @From_Date and @To_Date --Comment by ronakk 13122022
				--AND EP.Evaluation_Date <= @TO_DATE AND EP.Evaluation_Date >= @FROM_DATE  --Added  by ronakk 13122022
			    AND EP.Flag = ISNULL(@Report_Type,EP.Flag)
			
			----Rating Master
			SELECT Cast(From_Rate AS VARCHAR(8)) + ' To ' + Cast(To_Rate AS VARCHAR(8)) AS Score , Title
			FROM T0040_RATING_MASTER  WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID
			ORDER by To_Rate DESC    
			
		END
	--ELSE IF @Report_Type = 'Trainee'
	--	BEGIN
	--		SELECT 
	--			 E.Alpha_Emp_Code,E.Emp_Full_Name AS Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
	--			,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
	--			,E.Emp_Confirm_Date,E.Probation,Cm.Cmp_City
	--			--,Qry_E.New_Probation_EndDate AS Extend_Date,Qry_E.Extend_Period,Qry_E.Flag,Qry_E.Evaluation_Date
	--			,I_Q.Branch_ID,I_Q.Dept_ID,I_Q.Desig_Id,I_Q.Grd_ID,I_Q.Cat_ID
	--			,Qry_E.*
	--		FROM dbo.T0080_EMP_MASTER E INNER JOIN 
	--			 #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
	--			 dbo.T0010_Company_master CM ON E.Cmp_ID =Cm.Cmp_ID INNER JOIN
	--			 dbo.T0095_INCREMENT I_Q ON I_Q.Increment_ID = EC.Increment_ID	INNER JOIN
	--			 T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--			 T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--			 T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--			 T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
	--			 T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN
	--			 ( SELECT EP.*
	--				FROM T0095_EMP_PROBATION_MASTER EP INNER JOIN
	--				( SELECT MAX(New_Probation_EndDate) AS New_Date,Emp_ID FROM T0095_EMP_PROBATION_MASTER --Probation_Status = 0 For Confirm
	--				  WHERE New_Probation_EndDate <= @To_Date AND Cmp_ID = @Cmp_ID AND Probation_Status = 0 AND Flag = @Report_Type GROUP BY Emp_ID
	--				) Qry ON Qry.Emp_ID = EP.Emp_ID AND Qry.New_Date = Ep.New_Probation_EndDate
	--			  ) Qry_E ON Qry_E.Emp_ID = EC.Emp_ID
	--		WHERE E.Cmp_ID = @Cmp_Id 
	--			--AND Qry_E.New_Probation_EndDate <= @TO_DATE AND Qry_E.New_Probation_EndDate >= @FROM_DATE 
	--		    AND Probation_Status = 0 AND Qry_E.Flag = @Report_Type
	--	END	
	
    
END

