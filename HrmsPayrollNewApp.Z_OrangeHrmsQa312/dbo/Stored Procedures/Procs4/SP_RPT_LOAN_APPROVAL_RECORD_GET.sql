
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LOAN_APPROVAL_RECORD_GET]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	--,@LOAN_STATUS	VARCHAR(1) --commented by Mukti 24112015
	,@LOAN_STATUS	VARCHAR(5)--Mukti 24112015
	,@CONSTRAINT 	VARCHAR(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	 --Added by Mukti(start) 24112015
	if @Loan_Status =	'ALL' 
		set @Loan_Status = null
	else
		set @Loan_Status=SUBSTRING (@Loan_Status, 1, 1)
	--Added by Mukti(end) 24112015
		  
	IF @Loan_Status = 'S' or 	@Loan_Status =''
		set @Loan_Status = null
	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
	 
			Select MLD.*,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code,E.Alpha_Emp_Code As Emp_Code,Type_Name,Dept_Name,Desig_Name,LOAN_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address
					,Loan_apr_amount,@From_Date as From_Date,@To_Date as To_Date,BM.Branch_ID,E1.Alpha_Emp_Code As Guarantor_Emp_Code , E1.Emp_Full_Name As Guarantor_Emp_Name
				 ,e.Emp_First_Name,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,Loan_Apr_Intrest_Type,Loan_Apr_Intrest_Per
				 ,Installment_Start_Date,Deduction_Type,Loan_Apr_Deduct_From_Sal,Loan_Number,   --added jimit 21052015
				 isnull(E2.Alpha_Emp_Code,'') As Guarantor_Emp_Code2 , E2.Emp_Full_Name As Guarantor_Emp_Name2  --Mukti 18112015
				 ,(Select AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) Where AD_ID = Isnull(MLD.AD_ID,0)) AS ADName
				 From T0120_LOAN_APPROVAL MLD WITH (NOLOCK) Inner join 
					  --T0100_Loan_Application LA ON MLD.LOAN_APp_ID = LA.LOAN_APp_ID INNER JOIN  -- Commented By rohit for Admin Loan Approval Record not Showing in loan Approval report - on 23072013
					  T0040_LOAN_MASTER LM WITH (NOLOCK) ON MLD.LOAN_ID = LM.LOAN_ID INNER JOIN 
					--T0080_EMP_MASTER E on MLD.emp_ID = E.emp_ID INNER  JOIN 
					T0080_EMP_MASTER E WITH (NOLOCK) on MLD.emp_ID = E.emp_ID Left Outer Join
					T0080_EMP_MASTER E2 WITH (NOLOCK) On E2.Emp_ID = MLD.Guarantor_Emp_ID2 left  JOIN --Mukti 18112015
					T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = MLD.Guarantor_Emp_ID INNER  JOIN --Ankit 02052014
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
							T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
				WHERE		E.Cmp_ID = @Cmp_Id 
						and MLD.Loan_Apr_Status= isnull(@Loan_Status,MLD.Loan_Apr_Status) 
						and  Loan_apr_Date >=@From_Date and Loan_apr_Date <=@To_Date
		
									
	RETURN 




