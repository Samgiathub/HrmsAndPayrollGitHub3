
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EXPERIANCE_LETTER_NEW]
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
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
		
	
	
		select I_Q.* , E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,street_1,city
					,Dept_Name,left_Date,DGM.Desig_Name,Type_Name,DATEDIFF(M,Date_of_Join,Getdate() )AS DURATION,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name
					,cm.cmp_logo
					,E.Alpha_Emp_code,E.Emp_First_Name          --added jimit 28052015
					,E.Gender,(E.Initial + ' ' +  E.Emp_Last_Name) as Emp_Last_Name,ELR2.Reference_No,ELR2.Issue_Date  --added By jimit 11082015
					,E.Tehsil,E.District,E.State as [State]
					,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig,E.Father_name   --Added By Jimit 02052018
					,E.Zip_code
					,le.Is_Retire --added By Rudra 23042018
					,E.Father_name, E.Tehsil, E.District,E.State 	--added By Rudra 01052018
					,E.Date_Of_Birth, le.Left_Reason		--added By Rudra 31052018
					,TDM.Desig_Name	as Join_Desig_Name		--added by Krushna 31-05-2018	
					,E.Initial
					,E.Emp_Second_Name
					,E.Emp_Last_Name as Last_Name
					,E.Old_Ref_No
					,E.GroupJoiningDate
		from T0080_EMP_MASTER E WITH (NOLOCK) left outer join			
		  t0100_lEFT_eMP le WITH (NOLOCK) on e.Emp_ID =le.Emp_ID inner join
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID left join
		     
		     ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID left join
					(SELECT ELR1.EMP_ID,MAX(ELR1.Tran_Id)Tran_Id,ELR1.Reference_No,ELR1.Issue_Date  --Mukti(30012017)
					 FROM		T0081_Emp_LetterRef_Details ELR1 WITH (NOLOCK) INNER JOIN
					(SELECT  MAX(Issue_Date) Issue_Date,EMP_ID  
						 FROM	 T0081_Emp_LetterRef_Details WITH (NOLOCK)
						 WHERE	 Issue_Date <= @To_Date AND CMP_ID =@CMP_ID and Letter_Name='Experience Letter'
						 GROUP BY EMP_ID)ELR ON ELR.EMP_ID = ELR1.EMP_ID and Letter_Name='Experience Letter' AND ELR.Issue_Date = ELR1.Issue_Date								 
					GROUP BY ELR1.EMP_ID,ELR1.Reference_No,ELR1.Issue_Date)ELR2 ON ELR2.Emp_ID = E.Emp_ID					
					--added by Krushna for desig while joining 31-05-2018
					left OUTER join (
										select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
											from T0095_Increment I WITH (NOLOCK)
												inner join (
																select min(Increment_ID) as Increment_ID , Emp_ID 
																	from T0095_Increment WITH (NOLOCK)
																where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
																group by emp_ID  
															) 
															Qry_Min on I.Emp_ID = Qry_Min.Emp_ID and I.Increment_ID = Qry_Min.Increment_ID	
									) I_Q_Min on E.Emp_ID = I_Q_Min.Emp_ID
					left OUTER join T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) on	I_Q_Min.Desig_Id = TDM.Desig_Id
					--end Krushna
		WHERE E.Cmp_ID = @Cmp_Id	AND
		E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
		

	RETURN




