CREATE PROCEDURE [dbo].[Emp_Details_Export_Joining_Left]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Bank_ID		varchar(max) = ''
AS
	SET NOCOUNT ON 
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',@New_Join_emp,@Left_Emp,0,'0',0,0,@Bank_ID

	   
	 IF @New_Join_emp = 1	--Old Code For New Joining List ( MODIFIED BY RAMIZ ON 09/10/2018 )
		BEGIN
			SELECT E.Alpha_Emp_Code as Emp_code--,E.Emp_Code
			,E.Alpha_Emp_Code
			,I_Q.Emp_ID ,Grd_Name,E.Emp_Full_Name ,E.Father_Name,E.Street_1 as [Address],E.City,E.State,BM.Comp_Name,Cmp_Address,Branch_Name,BM.Branch_Address
				,CONVERT(VARCHAR(11),Date_of_Join,103) AS Date_of_Join ,CONVERT(VARCHAR(11),Date_Of_Birth,103) as Date_Of_Birth ,CA.Cat_Name
				,SSN_No as PF_No,SIN_No AS ESIC_No,Dr_Lic_No,E.Worker_Adult_No,Left_Date,Left_Reason,Pan_No
				,Case E.Marital_Status When 0 Then 'Single' When 1 Then 'Married' When 2 Then 'Divorced' When 3 Then 'Separted' End As Marital_Status
				,Nationality,Zip_code,Home_Tel_no,Mobile_No,Work_Tel_No,Work_Email,Dept_Name,Desig_Name,Type_Name,Emp_Mark_Of_Identification,Gender
				,BN.Bank_Name,Emp_Left,convert(varchar,Emp_Left_Date,103) as Emp_Left_Date,convert(varchar(11),@From_Date,103) as From_Date ,convert(varchar(11),@To_Date,103) as To_Date,Present_Street,Present_State,Present_City,Present_Post_Box
				,DATEDIFF(YY,ISNULL(DATE_OF_BIRTH,GETDATE()),GETDATE()) AS AGE,Present_Street [Working_Address],Enroll_No,Blood_Group,Religion,Height,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,convert(varchar,Emp_Confirm_Date,103) as Emp_Confirm_Date
				,(Select Sup.Alpha_Emp_Code + ' - ' + SUP.Emp_Full_Name from dbo.T0080_EMP_MASTER SUP where SUP.Emp_ID = E.Emp_Superior) as manager,e.Old_Ref_No,isnull(ccm.Center_Name,'-') As Cost_Center_Name-- I_Q.BRANCH_ID as BRANCH_ID		   
				--,I_Q.Vertical_ID,I_Q.SubVertical_ID	--Commented By jimit
				--,I_Q.Dept_ID  --Added By Jaina 14-10-2015	--Commented By Ramiz , now the Way of Handling Privilege is Changed (08/10/2018)
			   ,Vs.Vertical_Name,Sv.SubVertical_Name				--Added By Jimit 10072018
			   ,I_Q.CTC, E.Other_Email AS Personal_Email,SCM.Name AS Salary_Cycle --Added By Jimit 10072018
			   ,I_Q.Branch_ID
			FROM T0080_EMP_MASTER E  WITH (NOLOCK) 
				LEFT OUTER JOIN		T0100_LEFT_EMP l  WITH (NOLOCK) ON E.Emp_ID = l.Emp_ID 
				INNER JOIN		#Emp_Cons EC ON EC.EMP_ID = E.EMP_ID
				INNER JOIN		T0095_INCREMENT I_Q  WITH (NOLOCK) ON EC.Increment_ID = I_Q.Increment_ID AND EC.EMP_ID = I_Q.Emp_ID
				INNER JOIN		T0040_GRADE_MASTER GM  WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM  WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN	T0030_CATEGORY_MASTER CA  WITH (NOLOCK) On I_Q.Cat_id = CA.Cat_Id
				LEFT OUTER JOIN	T0040_BANK_MASTER BN  WITH (NOLOCK) On I_Q.Bank_id = BN.Bank_Id
				LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
				INNER JOIN		T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
				INNER JOIN 		T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
				LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM  WITH (NOLOCK) on CCM.Center_ID = I_Q.Center_ID
				LEFT OUTER JOIN	T0040_Vertical_Segment Vs  WITH (NOLOCK) On Vs.Vertical_ID = I_Q.Vertical_ID
				LEFT OUTER JOIN	T0050_SubVertical Sv  WITH (NOLOCK) On Sv.SubVertical_ID = I_Q.SubVertical_ID
				LEFT OUTER JOIN	T0040_SALARY_CYCLE_MASTER SCM  WITH (NOLOCK) On Scm.Tran_Id = I_Q.SalDate_id
			WHERE E.Cmp_ID = @Cmp_Id	
			ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then RIGHT(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0 then LEFT(e.Alpha_Emp_Code + Replicate('',21), 20)
				ELSE e.Alpha_Emp_Code
			END
			
			--Commented Old Code By Ramiz on 09/10/2018
			
			--inner join
			--( select I.Emp_Id ,Grd_ID,Bank_id,Inc_Bank_Ac_No,Branch_ID,Center_ID,Desig_ID,Dept_ID,Emp_OT,Emp_Late_Mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_time,Late_Dedu_Type,Emp_Childran,Basic_salary,
			--		I.Vertical_ID,I.SubVertical_ID,I.Dept_ID   --Added By Jaina 14-10-2015
			--         Gross_salary,Wages_Type,Type_ID,Cat_ID,I.CTC,I.SalDate_id from T0095_Increment I inner join 
			--		( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q 
			--	on E.Emp_ID = I_Q.Emp_ID 
			--	WHERE E.Cmp_ID = @Cmp_Id	
			--		And E.Emp_ID in (select Emp_ID From #Emp_Cons)	
			--Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			--	When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
			--		Else e.Alpha_Emp_Code
			--	End
		
		END
	 ELSE IF @Left_Emp = 1	--New Code Added By Ramiz on 08/10/2018
		BEGIN
			
--SELECT SHORT_FALL_DAYS		FROM T0040_GRADE_MASTER WHERE Cmp_ID = 41
--SELECT SHORT_FALL_DAYS		FROM T0040_GENERAL_SETTING WHERE Cmp_ID = 41

--SELECT CASE WHEN EM.Emp_Notice_Period = 0 
--			THEN GM.Short_Fall_Days
--			ELSE EM.Emp_Notice_Period
--	   END AS NOTICE_PERIOD	
--FROM T0080_EMP_MASTER EM
--	INNER JOIN #Emp_Cons EC ON EM.EMP_ID = EC.EMP_ID
--	INNER JOIN T0095_INCREMENT I ON I.Increment_ID = EC.Increment_ID
--	INNER JOIN T0040_GRADE_MASTER GM ON GM.Grd_ID = I.Grd_ID
--	INNER JOIN T0040_GENERAL_SETTING GS ON GS.Cmp_ID = EM.Cmp_ID AND GS.Branch_ID = I.Branch_ID
--WHERE EM.Cmp_ID = @Cmp_ID
--AND GS.For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= @To_Date and Branch_ID = I.Branch_ID and Cmp_ID = @Cmp_ID)    

--RETURN

			SELECT '="' + ALPHA_EMP_CODE + '"' AS EMP_CODE,E.EMP_FULL_NAME ,REPLACE(CONVERT(VARCHAR(20),DATE_OF_JOIN,106) , ' ' , '-') AS DATE_OF_JOIN
				,CASE  WHEN DATEDIFF(YY,DATE_OF_JOIN , EMP_LEFT_DATE) > 0 
							THEN CAST(DATEDIFF(YY,DATE_OF_JOIN , EMP_LEFT_DATE) AS VARCHAR(4)) + ' Years'	--YEARS
					   WHEN DATEDIFF(MM,DATE_OF_JOIN , EMP_LEFT_DATE) > 0 
							THEN CAST(DATEDIFF(MM,DATE_OF_JOIN , EMP_LEFT_DATE) AS VARCHAR(4)) + ' Months'	--MONTHS 
					   ELSE	CAST(DATEDIFF(DD,DATE_OF_JOIN , EMP_LEFT_DATE) AS VARCHAR(8)) + ' Days'		--DAYS
				END AS WORKED
				,REPLACE(CONVERT(VARCHAR(20),Reg_Date,106) , ' ' , '-') AS RESIGNATION_DATE 
				,REPLACE(CONVERT(VARCHAR(20),E.System_Date_Join_left,106) , ' ' , '-') AS LEFT_ENTRY_DATE -- Added By Sajid 18-04-2024 for West Rock Client Requirement Support #28513
				, REPLACE(CONVERT(VARCHAR(20),Reg_Accept_Date,106) , ' ' , '-') AS RESIGNATION_ACCEPTED_DATE
				,REPLACE(CONVERT(VARCHAR(20),EMP_LEFT_DATE,106) , ' ' , '-') AS LAST_WORKING_DATE
				,CASE WHEN GETDATE() < EMP_LEFT_DATE THEN CAST (DATEDIFF(DD,GETDATE() , EMP_LEFT_DATE) AS VARCHAR(10)) + ' Days' ELSE '' END AS REMAINING_DAYS,LEFT_REASON,BM.BRANCH_NAME AS BRANCH, DEPT_NAME AS DEPARTMENT,DESIG_NAME AS DESIGNATION,TYPE_NAME AS EMPLOYEE_TYPE,CAT_NAME AS CATEGORY 
				,CASE WHEN E.GENDER = 'M' THEN 'Male' ELSE 'Female' END AS GENDER,MOBILE_NO
				,CASE WHEN	DATE_OF_BIRTH IS NOT NULL THEN CAST(DATEDIFF(YY,ISNULL(DATE_OF_BIRTH,GETDATE()),GETDATE()) AS VARCHAR(4)) ELSE '' END AS AGE
				,VS.VERTICAL_NAME AS VERTICAL,SV.SUBVERTICAL_NAME AS SUBVERTICAL , BS.SEGMENT_NAME AS BUSINESS_SEGMENT
				,E.WORK_EMAIL AS OFFICIAL_EMAIL,E.OTHER_EMAIL AS PERSONAL_EMAIL 
				,CASE WHEN Is_Terminate = 1 THEN 'Terminated' 
					  WHEN Is_Death = 1 THEN 'Death' 
					  WHEN Is_Retire = 1 THEN 'Retirement' 
					  WHEN Is_Absconded = 1 THEN 'Absconded'
					 ELSE 'Resignation'  End as REASON_TYPE
			    ,CASE WHEN L.NOTICE_PERIOD = 1 THEN 'Yes' ELSE 'No' END AS NOTICE_PERIOD
				,CASE WHEN ISNULL(E.Emp_Notice_Period,0) = 0			--First Priority from Emp Master
						THEN CASE WHEN ISNULL(GM.Short_Fall_Days,0) = 0 --Secondly Grade Master
									THEN  ISNULL(GS.Short_Fall_Days,0)	--Third General Setting
								  ELSE GM.Short_Fall_Days 
							 END
					  ELSE E.Emp_Notice_Period END AS NOTICE_PERIOD_DAYS
			    ,CASE WHEN L.EXIT_INTERVIEW = 1 THEN 'Yes' ELSE 'No' END AS EXIT_INTERVIEW
			    ,CASE WHEN L.Uniform_Return = 1 THEN 'Yes' ELSE 'No' END AS UNIFORM_RETURN
			    ,L.LEFTREASONTEXT AS PF_LEFT_REASON 
			    ,I_Q.BRANCH_ID , I_Q.Vertical_ID , I_Q.SubVertical_ID , I_Q.Dept_ID
			    ,E.Emp_ID , E.Alpha_Emp_Code	--This 6 Fields will be Removed from Page Level , as it is not Required in Reports. 
												--If you want to Add any New Column , add it before this 2 Fields , so that Code will Remain Readable. (Ramiz 09/10/2018)
			FROM T0080_EMP_MASTER E  WITH (NOLOCK) 
				INNER JOIN		T0100_LEFT_EMP L  WITH (NOLOCK) ON E.Emp_ID = L.Emp_ID 
				INNER JOIN		#Emp_Cons EC ON EC.EMP_ID = E.EMP_ID
				INNER JOIN		T0095_INCREMENT I_Q  WITH (NOLOCK) ON EC.Increment_ID = I_Q.Increment_ID AND EC.EMP_ID = I_Q.Emp_ID
				INNER JOIN		T0040_GRADE_MASTER GM  WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
				INNER JOIN		T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
				INNER JOIN		T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
				LEFT OUTER JOIN	T0040_TYPE_MASTER ETM  WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN	T0030_CATEGORY_MASTER CA  WITH (NOLOCK) On I_Q.Cat_id = CA.Cat_Id 
				LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				LEFT OUTER JOIN	T0040_Vertical_Segment Vs  WITH (NOLOCK) On Vs.Vertical_ID = I_Q.Vertical_ID 
				LEFT OUTER JOIN	T0050_SubVertical Sv  WITH (NOLOCK) On Sv.SubVertical_ID = I_Q.SubVertical_ID 
				LEFT OUTER JOIN	T0040_Business_Segment bs  WITH (NOLOCK) On bS.Segment_ID = I_Q.Segment_ID
				INNER JOIN (
									Select	Distinct Short_Fall_Days,GS.Branch_ID 
									from	T0040_GENERAL_SETTING GS WITH (NOLOCK) 
											inner join (
															select	MAX(for_Date) as for_Date , Branch_ID
															from	T0040_GENERAL_SETTING WITH (NOLOCK) 
															where	For_Date <= @To_Date and Cmp_ID  = @Cmp_ID
															group by Branch_ID
														)G_Q on gs.For_Date = G_Q.for_Date and gs.Branch_ID = G_Q.Branch_ID
								)GS on GS.branch_id = i_q.branch_id
				---INNER JOIN		T0040_GENERAL_SETTING GS ON GS.Branch_ID = I_Q.Branch_ID
		WHERE E.Cmp_ID = @Cmp_Id
			AND Left_Reason <> 'Default Company Transfer'
			--AND GS.For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= @To_Date and Branch_ID = I_Q.Branch_ID and Cmp_ID = @Cmp_ID)
		ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				ELSE e.Alpha_Emp_Code
			END
		END	
	RETURN














