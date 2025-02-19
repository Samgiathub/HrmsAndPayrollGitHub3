

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_INSURANCE_DEDUCTION]
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
	,@CONSTRAINT 	VARCHAR(MAX)=''
--	,@ORDER_BY		VARCHAR(50) = 'Code'
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
		
								
	 
		SELECT I_Q.* ,E.Emp_Full_Name as Emp_Full_Name,E.Emp_code,CM.Cmp_Name,CM.Cmp_Address,IM.Ins_Name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,Comp_name,Branch_Address
					,WD.Ins_Cmp_name,WD.Ins_Policy_No,WD.Ins_Taken_Date,WD.Ins_Due_Date,WD.Ins_Exp_Date,WD.Monthly_Premium As Ins_Amount,WD.Ins_Anual_Amt
					,E.Enroll_No,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 29052015
		FROM	T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN @Emp_Cons CONS ON E.Emp_ID=CONS.Emp_ID 
				INNER JOIN T0090_EMP_INSURANCE_DETAIL WD WITH (NOLOCK) on E.Emp_ID =WD.Emp_Id 
				INNER JOIN T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID 
				INNER JOIN ( 
								SELECT	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
								FROM	T0095_Increment I WITH (NOLOCK)
								WHERE	I.Increment_ID=(SELECT	TOP 1 INCREMENT_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
														WHERE	I2.Cmp_ID=I.Cmp_ID AND I2.Emp_ID=I.Emp_ID AND I2.Increment_Effective_Date <= @TO_DATE
														ORDER BY I2.Increment_Effective_Date DESC, I2.Increment_ID DESC
														)
										AND I.Cmp_ID=@Cmp_ID
														
							) I_Q ON E.Emp_ID = I_Q.Emp_ID  
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN T0040_Insurance_Master IM WITH (NOLOCK) on WD.Ins_Tran_ID=IM.Ins_Tran_ID 
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 		
				inner JOIN T0200_MONTHLY_SALARY S WITH (NOLOCK) ON S.Emp_ID = E.Emp_ID   --Added By Jaina 4-12-2015			
		WHERE	E.Cmp_ID = @Cmp_Id AND ISNULL(WD.Ins_Exp_Date,@To_Date) >= @To_Date AND WD.Sal_Effective_Date <= @To_Date 
				AND WD.Deduct_From_Salary = 1 
				and S.Month_End_Date between @FROM_DATE AND @To_Date   --Added By Jaina 4-12-2015
		ORDER BY	(	
						CASE WHEN ISNUMERIC(E.Alpha_Emp_Code)=1 THEN 
							RIGHT(REPLICATE('0', 30) + E.Alpha_Emp_Code, 30) 
						ELSE
							E.Alpha_Emp_Code
						END
					)
					--(
					--	CASE @ORDER_BY WHEN 'Enroll No' THEN
					--		RIGHT(REPLICATE('0', 30) + E.Enroll_No, 30) 
					--	WHEN 'Name' THEN
					--		E.Emp_Full_Name
					--	ELSE
					--		(	
					--			CASE WHEN ISNUMERIC(E.Alpha_Emp_Code)=1 THEN 
					--				RIGHT(REPLICATE('0', 30) + E.Alpha_Emp_Code, 30) 
					--			ELSE
					--				E.Alpha_Emp_Code
					--			END
					--		)	
					--	END
					--)
		
					
	RETURN 


