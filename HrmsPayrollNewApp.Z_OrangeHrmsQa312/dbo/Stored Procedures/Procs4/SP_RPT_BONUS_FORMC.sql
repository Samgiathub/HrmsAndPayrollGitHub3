
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_BONUS_FORMC]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint		varchar(MAX) = ''
	,@Report_Type tinyint =0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	
	
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
		
				
	
		SELECT	I_Q.* ,Bonus_Effect_Month,Bonus_Effect_Year, E.Emp_Code,E.alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.branch_name,BM.branch_address,BM.Comp_name,CM.Cmp_Name,CM.Cmp_Address,Dept_Name,Desig_Name,grd_name,type_name,B.Bonus_Calculated_amount,B.Bonus_amount,
				B.From_Date as P_From_Date ,B.To_Date as P_To_Date ,B_Q.PRESENT_DAYS,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),@From_Date) AS AGE
		FROM	T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN T0180_BONUS B WITH (NOLOCK) ON E.Emp_ID =B.Emp_Id 
				INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID =Cm.Cmp_ID 
				INNER JOIN (SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
							FROM	T0095_Increment I WITH (NOLOCK)
									INNER JOIN ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID 
												FROM	T0095_Increment	WITH (NOLOCK) ----Ankit 28042015 for Same Date Increment
												WHERE	Increment_Effective_date <= @To_Date
														AND Cmp_ID = @Cmp_ID
												GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
							) I_Q ON E.Emp_ID = I_Q.Emp_ID  
				--INNER JOIN (SELECT	SUM(ISNULL(PRESENT_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
				--			FROM	T0200_MONTHLY_SALARY MS 
				--					LEFT OUTER JOIN T0180_BONUS BN ON MS.Emp_ID = BN.Emp_ID
				--			WHERE	MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date 
				--			GROUP BY MS.Emp_ID)B_Q ON I_Q.EMP_ID = B_Q.EMP_ID 
				INNER JOIN	T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
				Cross Apply (SELECT	SUM(ISNULL(PRESENT_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
							FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)									
							WHERE	MONTH_ST_DATE >= B.From_Date AND MONTH_END_DATE <= B.To_Date 
									AND B.Emp_ID=MS.Emp_ID
							GROUP BY MS.Emp_ID)B_Q 
		WHERE	E.Cmp_ID = @Cmp_Id 
				--and  b.Bonus_effect_Month = month(@From_Date)	 and b.bonus_effect_Year=  year(@From_Date)
				and  b.From_Date >= @From_Date	and b.To_Date <=  @To_Date
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
				
				
		
	RETURN
