


--Created by Mukti(18012016)
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_FORMQ_APPOINTMENT_LETTER]
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
	,@Constraint	varchar(5000) = ''
	
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
				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
		end
	
		select Emp_ID,Sum((EmpExp - (EmpExp % 1))) As Years,Sum((EmpExp % 1)*10) As Months
		INTO #TMP_EXP
		from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) where Cmp_ID=@cmp_id
		Group By Emp_ID		
				  
		select E.Emp_Full_Name,E.Emp_ID,
		case when E.Gender='M' then 'Male' else 'Female' END as Gender,
		case when E.Marital_Status=0 then 'Single' when E.Marital_Status=1 then 'Married' when E.Marital_Status=2 then 'Divorced' when E.Marital_Status=3 then 'Seperated' END as Marital_Status,
		CONVERT(VARCHAR(10),isnull(E.Date_Of_Join,'01/01/1900'),103)as Date_Of_Join,E.Alpha_Emp_Code,BM.Comp_Name,BM.Branch_Address,
		CONVERT(VARCHAR(10),isnull(e.Date_Of_Birth,'01/01/1900'),103) as Date_Of_Birth,e.Father_name,
		isnull(e.Present_Street,'') + + ISNULL(e.Present_City,'') + + ISNULL(e.Present_State,'') + + isnull(e.Present_Post_Box,'') as Emp_Present_Address,
		ISNULL(e.Street_1,'') + + ISNULL(e.City,'') + + ISNULL(e.State,'') + + ISNULL(e.Zip_code,'') as Emp_Permanent_Address,
		C.Cmp_Name,C.Cmp_Address,C.Cmp_City,C.Cmp_Pincode,
		CD.Director_Name,CD.Director_Address,CD.Director_Designation,CD.Director_Branch,
		isnull(EG.Home_Mobile_No,'') as Emergency_no,ISNULL(EG.Name,'') AS Emergency_Name,dgm.Desig_Name,
		ISNULL(te.Months,0) as Tot_Exp,ELR.Reference_No,ELR.Issue_Date
		from T0080_EMP_MASTER E  WITH (NOLOCK)
        inner join ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID, Emp_ID from T0095_Increment WITH (NOLOCK)
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID= Qry.Increment_ID) I_Q  
							on E.Emp_ID = I_Q.Emp_ID  
							inner join @Emp_Cons EC on E.Emp_Id=EC.Emp_ID
							left join T0040_GRADE_MASTER GM WITH (NOLOCK) ON E.Grd_ID = GM.Grd_ID 
							left outer Join	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
							left outer Join	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							left outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							left outer Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
							left Join T0010_COMPANY_MASTER C WITH (NOLOCK) ON E.CMP_ID = C.CMP_ID
							left JOIN T0010_COMPANY_DIRECTOR_DETAIL CD WITH (NOLOCK) ON CD.Cmp_Id=C.Cmp_Id
							left join T0090_EMP_EMERGENCY_CONTACT_DETAIL EG WITH (NOLOCK) on e.Emp_ID=eg.Emp_ID
							left join (
										Select	Emp_ID, Cast(Years As VARCHAR(3)) + '.' +Cast(Months As VARCHAR(3))As Months
										FROM	(
													Select	Emp_ID, Cast(Years + (Case When Months > 11 Then 1 Else 0 End)  As int) As Years,  
															Cast((Months % 12) As Int) As Months
													FROM	#TMP_EXP
												) T
										) te on e.Emp_ID=te.emp_id 
							left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Appoint Letter'--Mukti(05012017)
				
			
	RETURN
