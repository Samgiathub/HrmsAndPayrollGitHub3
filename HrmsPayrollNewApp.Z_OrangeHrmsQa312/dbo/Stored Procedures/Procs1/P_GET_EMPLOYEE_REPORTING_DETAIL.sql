
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_EMPLOYEE_REPORTING_DETAIL]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		Varchar(Max) = '0'
	,@Cat_ID		Varchar(Max) = '0'
	,@Grd_ID		Varchar(Max) = '0'
	,@Type_ID		Varchar(Max) = '0'
	,@Dept_ID		Varchar(Max) = '0'
	,@Desig_ID		Varchar(Max) = '0'
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
		CREATE TABLE #Emp_Cons 
		(      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		)  
					
		
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,
		@Emp_ID ,@constraint ,0,0 ,'','','','',0,0,0,'',0,0
		
		
		
			IF OBJECT_ID('DBO.TEMPDB..#RMTORM') IS NOT NULL
			DROP TABLE #RMTORM
	
			CREATE TABLE #RMTORM
			(
				EMP_ID				NUMERIC,
				R_EMP_ID			NUMERIC,
				RM_To_RM_EMP_Id     VARCHAR(MAX),
				Effect_DATE			DATETIME			
			)
		
			
				 			
			Insert	INTO #RMTORM
			SELECT	EC.Emp_Id,R_Emp_ID,'0',Rm.effect_date
			From	#Emp_Cons EC Inner Join 
					V0010_Get_Max_Reporting_manager RM ON EC.Emp_ID = RM.Emp_ID
			
			
			
			UPDATE  RM
			SET	    --RM.R_EMP_ID = Q.R_EMP_ID 
					RM.RM_To_RM_EMP_Id = Q.R_EMP_ID 
			FROM	#RMTORM RM INNER JOIN
					#EMP_CONS EC ON EC.EMP_ID = RM.EMP_ID INNER JOIN
					(
						SELECT	distinct STUFF((SELECT  distinct ', ' + (CAST(E1.R_EMP_ID as VARCHAR(MAX)))
								FROM	T0090_EMP_REPORTING_DETAIL E1 WITH (NOLOCK)
								WHERE   E1.EMP_ID = ERD.EMP_ID and 	
										E1.EMP_ID = RQRY.EMP_ID AND E1.EFFECT_DATE = RQRY.EFFECT_DATE					
								FOR XML PATH('')),1,1,'') AS R_EMP_ID							
								,ERD.EMP_ID
						FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN
								(
									SELECT	 MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID 
									FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									WHERE	 EFFECT_DATE <= @TO_DATE
									GROUP BY EMP_ID
								) RQRY ON  ERD.EMP_ID = RQRY.EMP_ID AND ERD.EFFECT_DATE = RQRY.EFFECT_DATE INNER JOIN 
							  T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD.R_EMP_ID 
						WHERE EXISTS 
							  (
								SELECT	DISTINCT ERD1.EMP_ID
								FROM	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN
										(
											SELECT	 MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID 
											FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											WHERE	 EFFECT_DATE <= @TO_DATE
											GROUP BY EMP_ID
										) RQRY ON  ERD1.EMP_ID = RQRY.EMP_ID AND ERD1.EFFECT_DATE = RQRY.EFFECT_DATE INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD1.R_EMP_ID AND ERD.EMP_ID = E.EMP_ID INNER JOIN 
								#EMP_CONS ECS ON ECS.EMP_ID  = ERD1.EMP_ID 				
								)
					)Q ON Q.EMP_ID = RM.R_EMP_ID			
				
			
			SELECT	E_1.Alpha_Emp_Code AS [EMPLOYEE_CODE],E_1.Emp_Full_Name AS [EMPLOYEE_NAME], 
					BM.Branch_Name AS [BRANCH_NAME],
					COnvert(varchar(15),E.Date_Of_Join ,103) AS [DATE_OF_JOIN],
					DM.Desig_Name AS [MANAGER_DESIGNATION],
					CAST(E.Alpha_Emp_Code AS varchar(15)) + ' - ' + E.Emp_Full_Name AS [MANAGER_NAME], 
					CM_R.Cmp_Name AS [MANAGER_COMPANY],QRY_REPORTING.Reporting_Method AS [REPORTING_METHOD], 
					COnvert(varchar(15),QRY_REPORTING.Effect_Date,103) AS [EFFECT_DATE],E_1.CMP_ID,E_1.EMP_ID,
					E.Branch_ID AS [BRANCH_ID]
					--,Q.RM_TO_RM AS [REPORTING_TO_REPORTING] 
					,STUFF((SELECT	', ' + (CAST(E2.Alpha_Emp_Code AS varchar(15)) + ' - ' + E2.Emp_Full_Name)
							FROM	T0080_EMP_MASTER E2 WITH (NOLOCK)
							WHERE	CHARINDEX(',' + Cast(Emp_ID AS Varchar(10)) + ',', ',' + REPLACE(QRY_REPORTING.RM_To_RM_EMP_Id,' ','') + ',') > 0
							FOR XML PATH('')),1,1,'') AS [REPORTING_TO_REPORTING] 						
			FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
					(			
						SELECT	R1.EMP_ID, R2.EFFECT_DATE AS EFFECT_DATE,ALPHA_EMP_CODE,E.EMP_FULL_NAME,R1.R_EMP_ID,
								R2.Row_ID,R2.Cmp_ID,R2.Reporting_To,Reporting_Method,R1.RM_To_RM_EMP_Id
						FROM	#RMTORM R1	INNER JOIN 
								T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) ON R1.EMP_ID = R2.EMP_Id AND R1.EFFECT_DATE = R2.EFFECT_DATE and r1.R_EMP_ID = r2.R_Emp_ID				INNER JOIN								
								T0080_EMP_MASTER E WITH (NOLOCK) ON R1.R_EMP_ID = E.EMP_ID 
					) AS QRY_REPORTING ON QRY_REPORTING.R_Emp_ID = E.Emp_ID	INNER JOIN 
					
					T0080_EMP_MASTER AS E_1 WITH (NOLOCK) ON QRY_REPORTING.Emp_ID = E_1.Emp_ID INNER JOIN
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E_1.Cmp_ID = CM.Cmp_Id		INNER JOIN 
					T0010_COMPANY_MASTER AS CM_R WITH (NOLOCK) ON E.Cmp_ID = CM_R.Cmp_Id	LEFT OUTER JOIN 
					(
						SELECT	I.Emp_id,I.Desig_Id,I.Cmp_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
								(
									SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID,I1.Emp_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN
											(
											  SELECT	MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date,I2.Emp_ID
											  FROM		T0095_INCREMENT I2 WITH (NOLOCK)
											  WHERE		I2.Increment_Effective_Date <= @To_DAte And I2.Cmp_ID=@Cmp_Id
											  GROUP BY	I2.Emp_ID, I2.Cmp_ID
											 )Inc_Q ON  I1.Emp_ID=Inc_Q.Emp_ID AND
														I1.Increment_Effective_Date = Inc_Q.Increment_Effective_Date
									GROUP BY I1.Emp_ID
								)Inc_Q1	ON  I.Emp_ID=Inc_Q1.Emp_ID AND I.INCREMENT_ID = Inc_Q1.INCREMENT_ID											
					) RPT_EMP ON E.Emp_ID = RPT_EMP.Emp_ID 
					INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON RPT_EMP.Desig_Id = DM.Desig_ID AND DM.Cmp_ID = E.Cmp_ID  
					INNER JOIN #Emp_Cons EC ON E_1.Emp_Id = EC.Emp_ID
					INNER JOIN	T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID = BM.Branch_ID	
					--Left OUTER JOIN 
					--(						
					--		SELECT	R1.EMP_ID,RM_To_RM_EMP_Id,
					--			STUFF((SELECT	', ' + (CAST(E2.Alpha_Emp_Code AS varchar(15)) + ' - ' + E2.Emp_Full_Name)
					--					FROM	T0080_EMP_MASTER E2
					--					WHERE	CHARINDEX(',' + Cast(Emp_ID AS Varchar(10)) + ',', ',' + R1.RM_To_RM_EMP_Id + ',') > -1
					--					FOR XML PATH('')),1,1,'') AS RM_TO_RM										
					--			FROM	(SELECT EMP_ID,R_EMP_ID,RM_To_RM_EMP_Id FROM #RMTORM R1 GROUP BY R_EMP_ID, RM_To_RM_EMP_Id, EMP_ID) R1
					--) Q On Q.EMP_ID = E_1.Emp_ID and Q.RM_To_RM_EMP_Id = QRY_REPORTING.RM_To_RM_EMP_Id
					--Left OUTER JOIN 
					--(						
					--		SELECT	distinct R1.EMP_ID,
					--			STUFF((SELECT  distinct ', ' + (CAST(E2.Alpha_Emp_Code AS varchar(15)) + ' - ' + E2.Emp_Full_Name)
					--					FROM	#RMTORM E1	Inner JOIN 
					--							T0080_EMP_MASTER E2 On  E2.emp_id in (select data from dbo.split(E1.RM_To_RM_EMP_Id,','))
					--					WHERE   E1.R_EMP_ID = R1.R_EMP_ID							
					--					FOR XML PATH('')),1,1,'') AS RM_TO_RM,
					--					RM_To_RM_EMP_Id
					--			FROM	(SELECT EMP_ID,R_EMP_ID,RM_To_RM_EMP_Id FROM #RMTORM R1 GROUP BY R_EMP_ID, RM_To_RM_EMP_Id, EMP_ID) R1
					--) Q On Q.EMP_ID = E_1.Emp_ID and Q.RM_To_RM_EMP_Id = QRY_REPORTING.RM_To_RM_EMP_Id
					
			WHERE	E.Cmp_ID = @CMP_Id
			ORDER BY E_1.Alpha_Emp_Code
			
			/*
		return
						
			SELECT	E_1.Alpha_Emp_Code AS [EMPLOYEE_CODE],E_1.Emp_Full_Name AS [EMPLOYEE_NAME], 
					BM.Branch_Name AS [BRANCH_NAME],
					
					--STUFF((SELECT  distinct ', ' + CAST(E1.Date_Of_Join AS varchar(11))
					--	   FROM		T0080_EMP_MASTER E1 
					--	   WHERE	E1.EMP_Id = E.EMP_Id							
					--	   FOR XML PATH('')),1,1,'') AS [DATE_OF_JOIN],
					COnvert(varchar(15),E.Date_Of_Join ,103) AS [DATE_OF_JOIN],
					
					--STUFF((SELECT  distinct ', ' + D2.Desig_Name
					--	   FROM		T0040_DESIGNATION_MASTER D2 
					--	   WHERE	D2.Desig_ID = DESIG_Q.Desig_ID							
					--	   FOR XML PATH('')),1,1,'') AS [MANAGER_DESIGNATION],					
					DM.Desig_Name AS [MANAGER_DESIGNATION],
					
					--STUFF((SELECT  distinct ', ' + CAST(E1.Alpha_Emp_Code AS varchar(15)) + ' - ' + E1.Emp_Full_Name 
					--	   FROM		T0080_EMP_MASTER E1 
					--	   WHERE	E1.EMP_Id = E.EMP_Id
					--	   FOR XML PATH('')),1,1,'') AS [MANAGER_NAME], 
					
					CAST(E.Alpha_Emp_Code AS varchar(15)) + ' - ' + E.Emp_Full_Name AS [MANAGER_NAME], 
					
					
					CM_R.Cmp_Name AS [MANAGER_COMPANY],QRY_REPORTING.Reporting_Method AS [REPORTING_METHOD], 
					COnvert(varchar(15),QRY_REPORTING.Effect_Date,103) AS [EFFECT_DATE],E_1.CMP_ID,E_1.EMP_ID,
					
					E.Branch_ID AS [BRANCH_ID],Q.RM_TO_RM AS [REPORTING_TO_REPORTING] 
		
			FROM	T0080_EMP_MASTER E INNER JOIN 
					(			
						SELECT	R1.EMP_ID, R2.EFFECT_DATE AS EFFECT_DATE,ALPHA_EMP_CODE,E.EMP_FULL_NAME,R1.R_EMP_ID,
								R2.Row_ID,R2.Cmp_ID,R2.Reporting_To,Reporting_Method,R1.RM_To_RM_EMP_Id
						FROM	#RMTORM R1	INNER JOIN 
								T0090_EMP_REPORTING_DETAIL R2 ON R1.EMP_ID = R2.EMP_Id AND R1.EFFECT_DATE = R2.EFFECT_DATE and r1.R_EMP_ID = r2.R_Emp_ID				INNER JOIN								
								T0080_EMP_MASTER E ON R1.R_EMP_ID = E.EMP_ID 
					) AS QRY_REPORTING ON QRY_REPORTING.R_Emp_ID = E.Emp_ID	INNER JOIN 
					
					T0080_EMP_MASTER AS E_1 ON QRY_REPORTING.Emp_ID = E_1.Emp_ID INNER JOIN
					T0030_BRANCH_MASTER BM ON E.Branch_ID = BM.Branch_ID	INNER JOIN 
					T0010_COMPANY_MASTER CM ON E_1.Cmp_ID = CM.Cmp_Id		INNER JOIN 
					T0010_COMPANY_MASTER AS CM_R ON E.Cmp_ID = CM_R.Cmp_Id	LEFT OUTER JOIN 
					(
						SELECT	I.Emp_id,I.Desig_Id,I.Cmp_ID 
						FROM	T0095_INCREMENT I INNER JOIN
								(
									SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID,I1.Emp_ID
									FROM	T0095_INCREMENT I1 INNER JOIN
											(
											  SELECT	MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date,I2.Emp_ID
											  FROM		T0095_INCREMENT I2
											  WHERE		I2.Increment_Effective_Date <= @To_DAte And I2.Cmp_ID=@Cmp_Id
											  GROUP BY	I2.Emp_ID, I2.Cmp_ID
											 )Inc_Q ON  I1.Emp_ID=Inc_Q.Emp_ID AND
														I1.Increment_Effective_Date = Inc_Q.Increment_Effective_Date
									GROUP BY I1.Emp_ID
								)Inc_Q1	ON  I.Emp_ID=Inc_Q1.Emp_ID AND I.INCREMENT_ID = Inc_Q1.INCREMENT_ID											
					) RPT_EMP ON E.Emp_ID = RPT_EMP.Emp_ID INNER JOIN 
					
					T0040_DESIGNATION_MASTER DM ON RPT_EMP.Desig_Id = DM.Desig_ID AND DM.Cmp_ID = E.Cmp_ID  Left OUTER JOIN 
					(						
							SELECT	distinct R1.EMP_ID,
								STUFF((SELECT  distinct ', ' + (CAST(E2.Alpha_Emp_Code AS varchar(15)) + ' - ' + E2.Emp_Full_Name)
										FROM	#RMTORM E1	Inner JOIN 
												T0080_EMP_MASTER E2 On  E2.emp_id in (select data from dbo.split(E1.RM_To_RM_EMP_Id,','))
										WHERE   E1.R_EMP_ID = R1.R_EMP_ID							
										FOR XML PATH('')),1,1,'') AS RM_TO_RM,
										RM_To_RM_EMP_Id
								--STUFF((SELECT  distinct ', ' + (CAST(E1.RM_To_RM_EMP_Id as VARCHAR(MAX)))
								--		FROM	#RMTORM E1	
								--		WHERE   E1.R_EMP_ID = R1.R_EMP_ID							
								--		FOR XML PATH('')),1,1,'') AS RM_To_RM_EMP_Id						
								FROM	#RMTORM R1															 
					) Q On Q.EMP_ID = E_1.Emp_ID and Q.RM_To_RM_EMP_Id = QRY_REPORTING.RM_To_RM_EMP_Id
					
			WHERE	E.Cmp_ID = @CMP_Id
			
			
				
				*/
				
			
			--SELECT	distinct R1.EMP_ID,(CAST(E2.Alpha_Emp_Code AS varchar(15)) + ' - ' + E2.Emp_Full_Name) as RM_To_RM
			--					,R1.RM_To_RM_EMP_Id
			--			FROM	#RMTORM R1	Inner JOIN 
			--					T0080_EMP_MASTER E2 On E2.emp_id in (select data from dbo.split(R1.RM_To_RM_EMP_Id,','))
		
		
		
		RETURN		
