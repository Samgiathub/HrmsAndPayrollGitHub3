

CREATE PROCEDURE [dbo].[SP_Family_Detail]
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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_master e WITH (NOLOCK) on i.emp_Id = e.emp_ID inner join
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
			and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
			and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
			and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
			and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
			and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
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
		
		Declare @Emp_Detail table
		(
			Emp_ID numeric(18,0),
			Name varchar(100),
			Gender varchar(10),
			Date_Of_Birth DateTime,
			C_Age  numeric(18,2),
			Relation varchar(50),
			IS_REsi numeric(18,2)
		)
		
		insert into @Emp_Detail 
		
		--change by Falak on 16-SEP-2010 added new field emp_id,Relation,IS_resi
		--Change by Falak on 24-NOV-2010 changed condition added AD_DEF_ID = 2 or 3
		
		SELECT ecd.Emp_Id,ecd.Name,ecd.Gender,ecd.Date_Of_Birth,ecd.C_Age,isnull(ecd.Relationship,'') as Relationship,isnull(ecd.IS_REsi,0) as IS_REsi
		FROM T0090_EMP_CHILDRAN_DETAIL ecd WITH (NOLOCK) inner join  T0080_EMP_MASTER E WITH (NOLOCK) on ecd.Emp_ID = e.Emp_ID INNER JOIN
		 ( SELECT EED.EMP_ID , MIN(EED.FOR_dATE) FOR_DATE FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON 
			EED.AD_ID = AM.AD_ID  INNER JOIN @EMP_cONS EC ON EED.EMP_ID = EC.EMP_iD
			WHERE ad_not_effect_salary <> 1 AND (AD_DEF_ID = 3 or AD_DEF_ID = 2) AND EED.CMP_ID = @CMP_ID
		GROUP BY EED.EMP_ID ) Q  ON E.EMP_iD = Q.EMP_iD  inner join t0010_company_master CM WITH (NOLOCK) on E.Cmp_ID =CM.Cmp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID ,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		WHERE E.CMP_ID =@cMP_ID AND Q.FOR_DATE >=@fROM_DATE AND Q.FOR_DATE <=@TO_DATE
			
			
		insert into @Emp_Detail 
		
			SELECT ecd.Emp_ID,ecd.Name,'M',ecd.BirthDate,ecd.D_Age,isnull(ecd.Relationship,'') as Relationship,isnull(ecd.IS_REsi,0) as IS_REsi
		FROM T0090_EMP_Dependant_DETAIL ecd WITH (NOLOCK) inner join  T0080_EMP_MASTER E WITH (NOLOCK) on ecd.Emp_ID = e.Emp_ID INNER JOIN
		 ( SELECT EED.EMP_ID , MIN(EED.FOR_dATE) FOR_DATE FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON 
			EED.AD_ID = AM.AD_ID  INNER JOIN @EMP_cONS EC ON EED.EMP_ID = EC.EMP_iD
			WHERE ad_not_effect_salary <> 1 AND (AD_DEF_ID = 3 or AD_DEF_ID = 2) AND EED.CMP_ID = @CMP_ID
		GROUP BY EED.EMP_ID ) Q  ON E.EMP_iD = Q.EMP_iD  inner join t0010_company_master CM WITH (NOLOCK) on E.Cmp_ID =CM.Cmp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID ,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		--WHERE E.CMP_ID =@cMP_ID AND Q.FOR_DATE >=@fROM_DATE AND Q.FOR_DATE <=@TO_DATE    \\** Commented By Ramiz on 26/06/2015
		
		Select * from @Emp_Detail
				
RETURN




