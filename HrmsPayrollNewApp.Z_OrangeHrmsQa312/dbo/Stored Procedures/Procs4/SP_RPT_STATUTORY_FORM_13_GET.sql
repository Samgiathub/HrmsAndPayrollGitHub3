


-- =============================================
-- Author:		<Falak,Orange Technolab>
-- ALTER date: <23-SEP-2010>
-- Description:	<Statutory Form 13>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_13_GET]
	
	@Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	--,@Branch_ID 	numeric
	--,@Cat_ID 		numeric 
	--,@Grd_ID 		numeric
	--,@Type_ID 	numeric
	--,@Dept_ID 	numeric
	--,@Desig_ID 	numeric
	,@Branch_ID 	varchar(max) = ''
	,@Cat_ID 		varchar(max) = '' 
	,@Grd_ID 		varchar(max) = ''
	,@Type_ID 	    varchar(max) = ''
	,@Dept_ID 	    varchar(max) = ''
	,@Desig_ID 	    varchar(max) = ''
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Vertical_ID varchar(max)=''  --Added By Jaina 5-10-2015
	,@SubVertical_ID varchar(max)='' --Added By Jaina 5-10-2015
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	 CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_ID,@SubVertical_ID,'',0,0,0,'0',0,0  --Change By Jaina 5-10-2015
	

	/*
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

			select I.Emp_Id from T0095_Increment I inner join T0080_Emp_master e on i.emp_Id = e.emp_ID inner join
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
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
			and Date_of_Join >=@From_Date and Date_of_Join <=@To_Date 
		end */

		
		
		Select E.Emp_ID ,E.Emp_Full_Name ,CM.Cmp_Name,CM.Cmp_Address,CM.Cmp_City ,CM.Cmp_State_Name ,CM.Cmp_PinCode , 
		E.Emp_Code ,Date_Of_Birth,Gender,Marital_Status,Inc_Bank_Ac_no
				,Present_Street,Present_City,Present_State,Present_Post_box,
				Street_1,City,State,Zip_Code,SSN_No as PF_No,E.Date_Of_Join 
				,@From_Date P_From_Date ,@To_Date P_To_Date,e.Father_name
				,Alpha_Emp_Code as alpha_emp_code -- Add By Paras 06-03-2013 
				,E.Emp_First_Name     --added jimit 17062015
		From T0080_EMP_MASTER E WITH (NOLOCK) inner join t0010_company_master CM WITH (NOLOCK) on E.Cmp_ID =CM.Cmp_ID inner join
		
		#Emp_cons ec on e.Emp_ID = Ec.emp_ID   inner join

		 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID ,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 

		WHERE E.Cmp_ID = @Cmp_Id	and Date_of_Join >=@From_Date and Date_of_Join <=@To_Date     
RETURN
	



