


--=============================================================================================================
--ALTER BY   : Nilesh Patel
--ALTER DATE : 03/02/2015
--DESCRIPTION : For Salary Certificate Report
--MODIFY BY   : Nilesh Patel
--REVIEW BY   : Nilesh Patel
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--=============================================================================================================
CREATE PROCEDURE [dbo].[SP_EMP_Salary_Certificate]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC   = 0
	,@Cat_ID		NUMERIC  = 0
	,@Grd_ID		NUMERIC = 0
	,@Type_ID		NUMERIC  = 0
	,@Dept_ID		NUMERIC  = 0
	,@Desig_ID		NUMERIC = 0
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF @Branch_ID = 0
		SET @Branch_ID = NULL
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
	If @Desig_ID = 0
		SET @Desig_ID = NULL
		
	
	
	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO @Emp_Cons
			SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			
			
			INSERT INTO @Emp_Cons

			SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
					(SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)
					WHERE Increment_Effective_date <= @To_Date
					AND Cmp_ID = @Cmp_ID
					GROUP BY emp_ID  ) Qry ON
					I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date
			WHERE Cmp_ID = @Cmp_ID 
			AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))
			AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)
			AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
			AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))
			AND ISNULL(Type_ID,0) = ISNULL(@Type_ID ,ISNULL(Type_ID,0))
			AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
			AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in 
				(SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE cmp_ID = @Cmp_ID   AND  
				(( @From_Date  >= join_Date  AND  @From_Date <= left_date ) 
				OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )
				OR Left_date IS NULL  AND @To_Date >= Join_Date)
				OR @To_Date >= left_date  AND  @From_Date <= left_date ) 
			
		END
		
		
		 
		SELECT  I_Q.* ,I_Q.Gross_Salary,Cmp_Name,Cmp_address,BM.Comp_Name,BM.Branch_Address,Emp_Code, E.Alpha_Emp_Code
					,E.Emp_First_Name,E.Mobile_No,E.Work_Email,CTM.Cat_Name
					,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,I_Q.Basic_Salary,I_Q.Increment_Effective_Date,I_Q.Pre_Gross_Salary,I_Q.Increment_Amount,I_Q.Increment_Type,
					E.Pan_No --Added by nilesh on 04022015
					,I_Q.Basic_Salary + Earn.Allowance as CTC_Amount_Monthly
					,(I_Q.Basic_Salary + Earn.Allowance)*12 as CTC_Amount_Yearly,ELR2.Reference_No,ELR2.Issue_Date	, CM.cmp_logo , CM.Cmp_Phone
					, REPLACE(REPLACE(E.Street_1, CHAR(13), ''), CHAR(10), ' ') as Street_1 , E.Tehsil , E.City , E.State , E.Zip_code
					,NET.Net_Take_Home , BNK.Bank_Name
					,@From_Date as From_date
					,@To_Date as To_Date
		FROM T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on Cm.Cmp_Id = E.Cmp_ID 
			INNER JOIN T0095_INCREMENT I_Q WITH (NOLOCK) on E.Emp_ID = I_Q.Emp_ID
			INNER JOIN 
					 ( 
						SELECT MAX(Increment_ID) as Increment_ID , Emp_ID 
						FROM T0095_INCREMENT  WITH (NOLOCK)
						WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID 
						GROUP BY EMP_ID  
					  ) QRY ON  I_Q.Emp_ID = Qry.Emp_ID and I_Q.Increment_ID = Qry.Increment_ID 
			INNER JOIN 
						(
							SELECT SUM(ED.E_AD_AMOUNT) As Allowance,ED.EMP_ID,ED.INCREMENT_ID 
							FROM T0100_EMP_EARN_DEDUCTION ED WITH (NOLOCK)
								INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON ED.AD_ID = AM.AD_ID
							WHERE ED.FOR_DATE <=  @To_Date  and ED.CMP_ID = @Cmp_ID AND ED.E_AD_FLAG = 'I' 
								AND AM.AD_PART_OF_CTC=1  AND AM.Hide_In_Reports= 0
							GROUP BY ED.EMP_ID,ED.INCREMENT_ID
						) EARN ON I_Q.Emp_ID = Earn.EMP_ID AND I_Q.Increment_ID = Earn.INCREMENT_ID 
			INNER JOIN		T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
			LEFT OUTER JOIN	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
			LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) On I_Q.Cat_ID = CTM.Cat_ID
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id		-- Added By Gadriwala 17022014
			INNER JOIN		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
			LEFT OUTER JOIN	T0040_BANK_MASTER BNK WITH (NOLOCK) ON I_Q.Bank_ID = BNK.Bank_ID
			LEFT OUTER JOIN
					(
						SELECT ELR1.EMP_ID,MAX(ELR1.Tran_Id)Tran_Id,ELR1.Reference_No,ELR1.Issue_Date  --Mukti(11012017)
						FROM		T0081_Emp_LetterRef_Details ELR1 WITH (NOLOCK) INNER JOIN
							(
							 SELECT  MAX(Issue_Date) Issue_Date,EMP_ID  
							 FROM	 T0081_Emp_LetterRef_Details WITH (NOLOCK)
							 WHERE	 Issue_Date <= @To_Date AND CMP_ID =@CMP_ID and Letter_Name='Salary Certificate'
							 GROUP BY EMP_ID
							 )ELR ON ELR.EMP_ID = ELR1.EMP_ID and Letter_Name='Salary Certificate' AND ELR.Issue_Date = ELR1.Issue_Date								 
						GROUP BY ELR1.EMP_ID,ELR1.Reference_No,ELR1.Issue_Date
					)ELR2 ON ELR2.Emp_ID = E.Emp_ID
			LEFT OUTER JOIN (
								SELECT SUM(Net_Amount + isnull(Settelement_Amount,0)) AS Net_Take_Home,EMP_ID
								FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
								WHERE Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
								GROUP BY Emp_ID
							) NET ON NET.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_Id	
				AND E.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		
		
		
		
RETURN




