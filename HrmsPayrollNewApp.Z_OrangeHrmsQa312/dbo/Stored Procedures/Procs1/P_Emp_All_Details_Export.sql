
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Emp_All_Details_Export]  
	 @Company_Id	NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		NUMERIC	
	,@Grade_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        NUMERIC = 0
	,@is_Column		tinyint = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
   
 	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Grade_ID = 0  
		 SET @Grade_ID = NULL  
		 
	IF @Emp_ID = 0  
		SET @Emp_ID = NULL  
		
	IF @Desig_ID = 0  
		SET @Desig_ID = NULL  
		
    IF @Dept_ID = 0  
		SET @Dept_ID = NULL 
		
	IF @Type_ID = 0  
		SET @Type_ID = NULL 	
		
    IF @Cat_ID = 0
        SET @Cat_ID = NULL
     
	CREATE TABLE #Emp_Cons
	(
		Emp_ID	NUMERIC
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons(Emp_ID)
			SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN		
			INSERT INTO #Emp_Cons
				SELECT I.Emp_Id 
					FROM dbo.T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   
										FROM dbo.T0095_INCREMENT WITH (NOLOCK)
										WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Company_ID
										GROUP BY emp_ID
									) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id
						INNER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON i.emp_ID = E.Emp_ID
					WHERE E.CMP_ID = @Company_ID 
						AND i.BRANCH_ID = ISNULL(@BRANCH_ID ,i.BRANCH_ID)
						AND ISNULL(i.Type_ID,0) = ISNULL(@Type_ID ,ISNULL(i.Type_ID,0))
						AND ISNULL(i.Grd_ID,0) = ISNULL(@Grade_ID ,ISNULL(i.Grd_ID,0))
						AND ISNULL(i.Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(i.Dept_ID,0))			
						AND ISNULL(i.Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(i.Desig_ID,0))			
						AND ISNULL(I.Emp_ID,0) = ISNULL(@Emp_ID ,ISNULL(I.Emp_ID,0))
						AND ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))
						AND Date_Of_Join <= @To_Date 
						AND I.emp_id IN(SELECT e.Emp_Id 
											FROM (SELECT e.emp_id, e.cmp_id, Date_Of_Join, ISNULL(Emp_left_Date, @To_Date) AS left_Date 
														FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)
												 ) qry
											WHERE cmp_id = @Company_id 
						AND ((@From_Date >= Date_Of_Join AND @From_Date <= Emp_left_date) 
							 OR(@to_Date >= Date_Of_Join AND @To_Date <= Emp_left_date)
							 OR Emp_left_date IS NULL AND @To_Date >= Date_Of_Join)
							 OR @To_Date >= Emp_left_date AND @From_Date <= Emp_left_date )  
			
		END

	declare @sql       NVARCHAR(MAX)
	declare @colNames as varchar (max)
	
	
	SET @sql  = N''
	SET @colNames = N''

	SELECT @colNames = @colNames + ',' + QUOTENAME(REPLACE(CAST(column_name AS VARCHAR(MAX)),' ','_' )) 
		FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
		WHERE [cmp_Id] = @Company_Id and Active =1
	
	
	create table #Cust_Column(emp_id Numeric(18,0));
	
	
	
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
	
  
	DECLARE @Status VARCHAR(10) 
    SET @Status =  ''
    SELECT  '="' + Alpha_Emp_Code + '"' AS Emp_code, Initial, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, BM.Branch_Name, GM.Grd_Name, DM.Desig_Name
			, TM.Type_Name, CM.Cat_Name, DT.Dept_Name, REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join, SSN_No AS PF_NO
			, SIN_No AS ESIC_No, Dr_Lic_No, Pan_No, REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth
			, CASE WHEN Marital_Status = 0 THEN 'Single' WHEN Marital_Status = 1 THEN 'Married' WHEN Marital_Status = 2 THEN 'Divorced' WHEN Marital_Status = 3 THEN 'Saperated' END AS Marital_Status 
			, Gender,Nationality, Street_1 AS [Address], City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email
			, E.Emp_Full_Name,Inc_Qry.Payment_Mode, BN.Bank_Name,( '="' + Inc_Qry.Inc_Bank_Ac_No + '"') as Inc_Bank_Ac_No , e.Ifsc_Code, Emp_Left, REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date
			, Present_Street [Working_Address], Present_City, Present_State, Present_Post_Box, Enroll_No, Inc_Qry.Emp_OT, Inc_Qry.Emp_Late_Mark
			, Inc_Qry.Emp_Full_PF, Inc_Qry.Emp_PT, Inc_Qry.Emp_Fix_Salary, Inc_Qry.Emp_Part_time, Inc_Qry.Late_Dedu_Type, Inc_Qry.Emp_Childran
			, Blood_Group, Religion, Height, Emp_Mark_Of_Identification, Despencery, Doctor_Name, DespenceryAddress, Insurance_No
			, REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date, Father_name, DATEDIFF(MM,Date_Of_Join,@To_date) AS Work_Exp_Month
			, Inc_Qry.Wages_Type, Inc_Qry.Basic_salary, Inc_Qry.Gross_salary , Inc_Qry.CTC
			,Qry_Reporting.emp_full_name as manager
			--(SELECT SUP.Emp_Full_Name FROM dbo.T0080_EMP_MASTER SUP WHERE SUP.Emp_ID = E.Emp_Superior) AS manager
			, e.Old_Ref_No,e.dealer_code, ISNULL(ccm.Center_Name,'-') AS Cost_Center_Name, @Status AS Status, Inc_Qry.Branch_ID AS Branch_ID
			,(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
			,(SELECT SUP.Alpha_Emp_Code FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) Manager_Code
			, SCM.Name As Salary_Cycle, BS.Segment_Name, VS.Vertical_Name		
			, SV.SubVertical_Name, SB.SubBranch_Name							
			, REPLACE(CONVERT(VARCHAR,E.GroupJoiningDate,106),' ','-') AS Group_Join_Date , E.Aadhar_Card_No  
			,CC.*		
			,emp_ot_min_limit,emp_ot_max_limit,Emp_Late_Limit,emp_early_limit  
			,E.compoff_min_hrs,Case When E.Image_Name like '0.jpg' then '' else e.Image_Name End as Image_Name
			,case when isnull(E.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF
			,E.Tally_Led_Name ,Case When ISNULL(E.Salary_Depends_on_Production,0) = 1 then 'Yes' Else 'No' END as Salary_Depends_on_Production  
			,E.UAN_No,E.Training_Month,Inc_Qry.Emp_Childran,E.Emp_UIDNo,E.Emp_Cast,E.Emp_Annivarsary_Date,E.Emp_Dress_Code,E.Emp_Shirt_Size			
			,E.Emp_Pent_Size,E.Emp_Shoe_Size,E.Emp_Canteen_Code,Sm.Skill_Name,E.Vehicle_NO,E.Ration_Card_Type,E.Aadhar_Card_No,E.Ration_Card_No,E.Ration_Card_Type   
			,Thm.ThanaName as Present_Police_Station,THM1.ThanaName as Permanent_Police_Station,Tlm.Tally_Led_Name,Lm.Loc_name,E.Extension_No						
			,(Select STUFF((SELECT ',' + Name from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)
							INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID 							
				WHERE EEC.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Name
			,(Select STUFF((SELECT ',' + EEC.RelationShip from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)
							INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID 							
				WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Relationship
			,(Select STUFF((SELECT ',' + EEC.Home_Tel_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)
							INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID 							
				WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID and EEC.Home_Tel_No <> '' FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Home_Tel_No
			,(Select STUFF((SELECT ',' + EEC.Home_Mobile_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)
							INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID 							
				WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Mobile
			,(Select STUFF((SELECT ',' + EEC.Work_Tel_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)
							INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID 							
				WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID and EEc.Work_Tel_No <> '' FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Work_Tel_No			
		FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID	, CTC	
								,emp_ot_min_limit,emp_ot_max_limit,Emp_Late_Limit,emp_early_limit,Payment_Mode  
							FROM T0095_INCREMENT WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   
												FROM T0095_INCREMENT WITH (NOLOCK) 
												WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Company_ID 
												GROUP BY emp_ID
											) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_Id   
							WHERE cmp_id = @Company_ID
						) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id
			LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_id = BN.Bank_Id 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON Inc_Qry.Type_Id = TM.Type_Id
			LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON Inc_Qry.Cat_id = CM.Cat_Id
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id
			 
			LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = Inc_Qry.Center_ID
			LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCM.Tran_ID = Inc_Qry.SalDate_ID		
			LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) On BS.Segment_ID = Inc_Qry.Segment_ID			
			LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK)On VS.Vertical_ID = Inc_Qry.Vertical_ID		
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK)On SV.SubVertical_ID =  Inc_Qry.SubVertical_ID		
			LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) On SB.SubBranch_ID = Inc_Qry.SubBranch_ID			
			left join #Cust_Column CC on ec.Emp_ID = CC.emp_id  
			 LEFT OUTER JOIN	
                          (SELECT   R1.Emp_ID, Effect_Date AS Effect_Date, R_Emp_ID,Em.emp_full_name
                            FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
									INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
													INNER JOIN (SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) WHERE R3.Effect_Date < GETDATE() GROUP BY R3.Emp_ID) R3
													ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date
												GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID
												inner join t0080_emp_master Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
							) AS Qry_Reporting ON E.Emp_ID = Qry_Reporting.Emp_ID  
		left outer JOIN 	T0040_SKILL_MASTER SM WITH (NOLOCK) On Sm.Skill_ID = E.SkillType_ID and Sm.Cmp_ID = E.Cmp_ID	
		Left Outer join		T0030_Thana_Master THM WITH (NOLOCK) On THM.Thana_Id = E.Thana_Id and thm.Cmp_Id = e.Cmp_ID
		Left Outer join		T0030_Thana_Master THM1  WITH (NOLOCK) ON  Thm1.Thana_Id = E.Thana_Id_Wok and thm1.Cmp_Id = E.Cmp_ID	
		Left Outer JOIN		T0040_Tally_Led_Master TLM WITH (NOLOCK) On TLM.Tally_Led_ID = E.Tally_Led_Id and TLM.Cmp_Id = E.Cmp_ID
		Left outer JOIN     T0001_LOCATION_MASTER LM WITH (NOLOCK) on Lm.Loc_Id = E.Loc_ID
		WHERE e.Cmp_ID = @Company_ID  
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End 		  
 RETURN

