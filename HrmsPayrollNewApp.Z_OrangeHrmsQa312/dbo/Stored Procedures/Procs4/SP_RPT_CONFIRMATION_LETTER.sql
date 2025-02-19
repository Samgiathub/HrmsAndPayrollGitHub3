

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CONFIRMATION_LETTER]
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
		
	
	
		select I_Q.* , E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city,EMP_FIRST_NAME
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,emp_confirm_date
		,e.Alpha_Emp_Code   --added jimit 27052015
		,E.Emp_Confirm_Date,E.Probation,E.Initial,
		(Select TOP 1 E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)  --added jimit 15032016
							INNER JOIN  T0011_LOGIN DM WITH (NOLOCK) ON E.Emp_ID=DM.Emp_id
					  WHERE  DM.Cmp_ID=I_Q.Cmp_ID and DM.Is_HR =1 
			) As HR
			,Cm.Cmp_City  --added jimit 18032016
			,E.Enroll_No --add by chetan 030417
			,E.Mobile_No --added by chetan 29112017
			,ELR.Reference_No	--added by Krushna 04-12-2018
			,ELR.Issue_Date		--added by Krushna 04-12-2018
			,CM.Cmp_HR_Manager	--added by Krushna 04-12-2018
			,cm.Cmp_HR_Manager_Desig	--added by Krushna 04-12-2018
			,EP_Q.Old_Probation_EndDate
			,EP_Q.New_Probation_EndDate
			,EP_Q.Confirmation_date
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		     ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Cmp_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT JOIN
					T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Confirmation Letter-Probation To Confirmation' 					
					INNER JOIN
						( SELECT EP.Emp_Id ,Probation_Status,Evaluation_Date,Extend_Period,EP.New_Probation_EndDate AS New_Probation_EndDate,Flag ,
						EP.Old_Probation_Period,EP.Old_Probation_EndDate,ep.Confirmation_date
						  FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
							@Emp_Cons EC1 ON EP.Emp_ID = EC1.Emp_ID INNER JOIN 
							( SELECT MAX(New_Probation_EndDate) AS New_Probation_EndDate , EP2.Emp_ID FROM T0095_EMP_PROBATION_MASTER EP2 WITH (NOLOCK)
							  INNER JOIN @Emp_Cons EC2 ON EP2.Emp_ID = EC2.Emp_ID 
							  WHERE (New_Probation_EndDate <= @To_Date OR EP2.Evaluation_Date <= @To_Date) AND Cmp_ID = @Cmp_ID 
							  AND Probation_Status = 0 AND Flag = 'Probation' GROUP BY EP2.emp_ID  
							) Qry1 ON EP.Emp_ID = Qry1.Emp_ID AND EP.New_Probation_EndDate = Qry1.New_Probation_EndDate	 
						 ) EP_Q  ON E.Emp_ID = EP_Q.Emp_ID 
		WHERE E.Cmp_ID = @Cmp_Id	AND
		   E.EMP_CONFIRM_DATE <= @TO_DATE AND E.EMP_CONFIRM_DATE >= @FROM_DATE AND
		   E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
				
 		
		
		
	RETURN









