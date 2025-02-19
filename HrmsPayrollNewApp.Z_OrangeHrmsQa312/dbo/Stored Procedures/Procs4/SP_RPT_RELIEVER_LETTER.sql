
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_RELIEVER_LETTER]
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
	,@reportPath    varchar(max)=''
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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK)  inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
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
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) ) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
	
	--dateadd(d,-1,eMP_lEFT_DATE) -- dateadd(d,-1,LE.LEFT_DATE)
		select I_Q.* , E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name, eMP_lEFT_DATE,CM.Cmp_Name,CM.Cmp_Address,LE.REG_ACCEPT_DATE, LE.LEFT_DATE,street_1,city,emp_first_name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name,ELR.Reference_No,ELR.Issue_Date
		,E.Alpha_Emp_Code,   --added jimit 28052015
		replace(CAST(@reportPath as varchar(max)),'\Reports\','') + '\App_File\Signature\' + cast (GM.[Signature] as varchar(max))as [signature]
		--added by Krushna 29-05-2018
		,LE.Reg_Date				
		,CM.Cmp_HR_Manager			
		,CM.Cmp_HR_Manager_Desig	
		,E.GroupJoiningDate	
		,CAST(@reportPath as varchar(max)) + '\report_image\header_' + cast (cm.cmp_id as varchar) + '.bmp' as rp_header
		,CAST(@reportPath as varchar(max)) + '\report_image\Footer_' + cast (cm.cmp_id as varchar) + '.bmp' as rp_Footer
		,CM.cmp_logo		
		--end Krushna
		,E.Gender
		,E.Initial
		,E.Emp_Second_Name
		,E.Emp_Last_Name
		,E.Old_Ref_No
		,E.GroupJoiningDate
		,LE.Is_Terminate
		,LE.Is_Death
		,LE.Is_Retire
		,LE.LeftReasonValue
		,LE.Left_Reason	
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		     T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID INNER JOIN
		     ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
					left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Reliever Letter'--Mukti(06012017) 	 	
		WHERE E.Cmp_ID = @Cmp_Id	AND
		LE.LEFT_DATE <=@TO_DATE AND LE.LEFT_DATE >= @FROM_DATE 
		AND
		   E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
				
 		
		
	RETURN




