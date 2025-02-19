
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_STATEMENT_GET_SETT]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(MAX)
,@PBranch_ID	VARCHAR(MAX) = ''
,@PVertical_ID	VARCHAR(MAX) = ''
,@PSubVertical_ID	VARCHAR(MAX) = ''
,@PDept_ID		VARCHAR(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	Declare @AD_Def_ID numeric 
	declare @EMPLOYER_CONT_PER numeric (18,2)
	Declare @Emp_Share_Cont_Amount numeric 
	Declare @Employer_Share_Cont_Amount numeric 
	Declare @Total_Share_Cont_Amount numeric 
	
	set @EMPLOYER_CONT_PER =0
	set @AD_Def_ID =3
	set @Emp_Share_Cont_Amount =0
	set @Employer_Share_Cont_Amount = 0
	set @Total_Share_Cont_Amount =0 
		 
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
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
		 
	
	select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION
		from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = ISNULL(@Branch_ID,Branch_ID)
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@tO_DATE and Branch_ID = isnull(@Branch_ID,Branch_ID) and Cmp_ID = @Cmp_ID)

		
	select @Emp_Share_Cont_Amount = sum(Emp_Cont_Amount) , 
		   @Employer_Share_Cont_Amount = sum(Employer_Cont_Amount) 
	From T0220_ESIC_Challan_Sett ec	WITH (NOLOCK) Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= @From_date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= @To_Date and 
	isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))

		 
	set @Total_Share_Cont_amount =  @Emp_Share_Cont_Amount + @Employer_Share_Cont_Amount  
	
		
	-- Changed By Ali 25112013 EmpName_Alias
	Select MAD.*,ISNULL(EmpName_Alias_ESIC,Emp_Full_Name) as Emp_full_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
			,@EMPLOYER_CONT_PER as EMPLOYER_CONT_PER ,CMP_NAME,CMP_ADDRESS,Cm.ESic_No as Cmp_ESIC_No
			,SIN_NO AS ESIC_NO ,Month(For_Date) as Month ,Year(For_Date) as Year
			,ceiling(@EMPLOYER_CONT_PER * M_AD_Calculated_Amount /100)EMPLOYER_CONT_AMOUNT
			,MS.s_SAL_CAL_DAYS,s_DAY_SALARY , @From_Date as P_From_Date , @To_Date as P_To_Date
			,@Emp_Share_Cont_Amount  Emp_Share_Cont_Amount , @Employer_Share_Cont_Amount Employer_Share_Cont_Amount
			,@Total_Share_Cont_amount Total_Share_cont_Amount , dbo.F_Number_TO_Word(@Total_Share_Cont_amount) Total_share_Cont_Amount_In_Word
			,E.Alpha_Emp_Code   --added jimit 02062015
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					t0201_monthly_salary_sett MS WITH (NOLOCK) ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN 
					T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID INNER JOIN 
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID  
					
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
				and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_not_effect_salary <>1 And sal_type=1
					
	RETURN 




