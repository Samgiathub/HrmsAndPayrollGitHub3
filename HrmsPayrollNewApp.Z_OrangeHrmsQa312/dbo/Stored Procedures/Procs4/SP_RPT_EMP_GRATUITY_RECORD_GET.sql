

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_GRATUITY_RECORD_GET]
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
		
	----COMMENTED BY RAMIZ ON 17/05/2018 , AND ADDED COMMON CODE FOR #EMP_CONS
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		Insert Into @Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date and  @From_Date <= left_date ) 
			
	--	end
	--	select I_Q.* ,E.Emp_Full_Name , cast(isnull(Marital_status,0) as numeric) as Marital_status,
					--			Religion,street_1,city,state, E.Emp_Code,BM.Comp_Name,BM.Branch_Address
					--			,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date
					--			,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,
					--			EDD.*
					--from T0080_EMP_MASTER E  
					--LEFT OUTER JOIN t0090_emp_dependant_detail EDD on E.Emp_ID=EDD.Emp_ID 
					--INNER JOIN
					--	( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
					--			( select max(Increment_ID) as Increment_ID, Emp_ID from T0095_Increment --Changed by Hardik 09/09/2014 for Same Date Increment
					--			where Increment_Effective_date <= @To_Date
					--			and Cmp_ID = @Cmp_ID
					--			group by emp_ID  ) Qry on
					--			I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q   --Changed by Hardik 09/09/2014 for Same Date Increment
					--		on E.Emp_ID = I_Q.Emp_ID  
					--INNER JOIN
					--			T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					--			T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					--			T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					--			T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					--			T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
					--			T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
					--WHERE E.Cmp_ID = @Cmp_Id And E.emp_ID in 
					--		(select Emp_ID from T0080_EMP_MASTER where Date_Of_Join >= @From_Date and Date_Of_Join <= @To_Date and Cmp_ID=@Cmp_ID) 
					--		And E.Emp_ID in (select Emp_ID From @Emp_Cons)
		
		--NEW CODE ADDED BY RAMIZ ON 17/05/2018 --
		CREATE TABLE #EMP_CONS 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )    
	   
		EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,NULL ,NULL ,NULL ,NULL ,NULL ,NULL 

		SELECT  E.Emp_Id , I_Q.Grd_ID,I_Q.Branch_ID,I_Q.Cat_ID,I_Q.Desig_ID,I_Q.Dept_ID,I_Q.TYPE_ID ,E.Emp_Full_Name 
				,Case When Marital_status = '' then 0 else isnull(cast(Marital_status as numeric),0) end as Marital_status
				,E.Religion,E.Street_1,E.City,State, E.Emp_Code,BM.Comp_Name,BM.Branch_Address,DM.Dept_Name,DGM.Desig_Name,ETM.Type_Name,GM.Grd_Name,
				Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date,Cmp_Name,Cmp_Address,Present_Street,
				Present_State,Present_City,Present_Post_Box,TM.ThanaName , District , Tehsil , Zip_code ,
				EDD.Name , EDD.RelationShip ,EDD.BirthDate , EDD.D_Age , EDD.Address , EDD.Share , EDD.Is_Resi , EDD.NomineeFor
		FROM T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN		#EMP_CONS EC ON   EC.Emp_ID = E.Emp_ID
			INNER JOIN		dbo.T0095_INCREMENT I_Q WITH (NOLOCK) ON EC.Emp_ID = I_Q.Emp_ID AND EC.Increment_ID = I_Q.Increment_ID
			INNER JOIN		dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
			INNER JOIN		dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
			INNER JOIN		dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			INNER JOIN		dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
			LEFT OUTER JOIN dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			LEFT OUTER JOIN dbo.T0090_EMP_DEPENDANT_DETAIL EDD WITH (NOLOCK) on E.Emp_ID=EDD.Emp_ID
			LEFT OUTER JOIN dbo.T0030_THANA_MASTER TM WITH (NOLOCK) ON E.Thana_Id = TM.Thana_Id and e.Cmp_ID = tm.Cmp_Id 
		WHERE E.Cmp_ID = @Cmp_Id
				
		

	RETURN




