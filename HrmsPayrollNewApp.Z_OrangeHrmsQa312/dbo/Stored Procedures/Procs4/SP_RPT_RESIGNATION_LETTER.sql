



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_RESIGNATION_LETTER]
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
	,@Constraint	varchar(MAX) = ''
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
		
	
	
		select I_Q.* , E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,LE.REG_ACCEPT_DATE,E.street_1,E.city,E.emp_first_name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,E.Date_of_Join,Branch_Address,Comp_Name
		,E.Alpha_Emp_code,ELR.Reference_No,ELR.Issue_Date    --added jimit 27052015
		,LE.Left_Date--add by chetan 120417
		,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig,LE.Reg_Date
		,ERM.Emp_Full_Name as reporting_name
		from T0080_EMP_MASTER E WITH (NOLOCK)
			inner join T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID 
			inner join T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID 
			INNER JOIN ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
						from T0095_Increment I WITH (NOLOCK)
							inner join ( select max(Increment_ID) as Increment_ID , Emp_ID 
											from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
										group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
			inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
			left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Resignation Letter'--Mukti(05012017) 	 	
--add by Krushna 30-04-2018
			Left OUTER Join
					(SELECT		Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
					 FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) INNER JOIN
								(SELECT  MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
								 FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
								 WHERE	 EFFECT_DATE <= getdate() AND CMP_ID = @CMP_ID 
								 GROUP BY EMP_ID)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
					 GROUP BY Q.EMP_ID)MAIN	ON Main.Emp_ID = I_Q.Emp_ID 
			LEFT JOIN T0080_EMP_MASTER ERM WITH (NOLOCK) ON MAIN.R_EMP_ID = ERM.EMP_ID
--end Krushna
		WHERE E.Cmp_ID = @Cmp_Id	AND
		LE.REG_ACCEPT_DATE <=@TO_DATE AND LE.REG_ACCEPT_DATE >= @FROM_DATE AND  isnull(Is_Terminate,0)= 0  
		AND
		   E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
		
 		
		
	RETURN




