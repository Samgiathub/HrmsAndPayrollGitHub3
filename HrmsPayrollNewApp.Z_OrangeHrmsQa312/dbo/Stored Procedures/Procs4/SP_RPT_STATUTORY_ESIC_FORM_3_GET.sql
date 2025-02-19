

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_FORM_3_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	--,@Branch_ID 	numeric -- Comment by nilesh patel on 24092014
	--,@Cat_ID 		numeric 
	--,@Grd_ID 		numeric
	--,@Type_ID 		numeric
	--,@Dept_ID 		numeric
	--,@Desig_ID 		numeric
	,@Branch_ID 	varchar(Max)=''
	,@Cat_ID 		varchar(Max)=''
	,@Grd_ID 		varchar(Max)=''
	,@Type_ID 		varchar(Max)=''
	,@Dept_ID 		varchar(Max)=''
	,@Desig_ID 		varchar(Max)=''
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Vertical_ID varchar(max)=''  --Added By Jaina 5-10-2015
	,@SubVertical_ID varchar(max)='' --Added By Jaina 5-10-2015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	-- Added by nilesh patel on 24092014 --Start
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_ID,@SubVertical_ID,'',0,0,0,'0',0,0  --Change By Jaina 5-10-2015

	-- Added by nilesh patel on 24092014 --End
	/* -- Comment by nilesh patel on 24092014 --Start
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
	
	CREATE TABLE #Emp_Cons -- Ankit 09092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 
	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join T0080_Emp_master e on i.emp_Id = e.emp_ID inner join
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where I.Cmp_ID = @Cmp_ID 
	--		and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
	--		and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
	--		and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
	--		and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
	--		and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
	--		and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end -- Comment by nilesh patel on 24092014 --End
   */

		-- Changed By Ali 25112013 EmpName_Alias
		SELECT E.Emp_ID ,ISNULL(E.EmpName_Alias_ESIC,E.Emp_Full_Name) as Emp_full_Name,E.Alpha_Emp_Code,E.Emp_First_Name ,CM.Cmp_Name,CM.Cmp_Address, E.Emp_Code ,Date_Of_Birth,Gender,Marital_Status,Inc_Bank_Ac_no
				,Present_Street,Present_City,Present_State,Present_Post_box,Marital_Status,
				Street_1,City,State,Zip_Code,SIN_No as ESIC_No
				,@From_Date P_From_Date ,@To_Date P_To_Date 
				,q.For_date ESIC_App_Date,Emp_Second_Name  ,ESIC_No as Employer_ESIC_No ,Cmp_City
				,Insurance_No,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress
				,DBO.F_GET_AGE (Date_of_Birth,getdate(),'N','N')as Emp_Age
				,DM.Dept_name,E.Father_name,DGM.Desig_name	
				,E.Alpha_Emp_Code,e.Emp_First_Name,Gm.Grd_Name,ETM.Type_Name		--added jimit 15062015	
		FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
		 ( SELECT EED.EMP_ID , MIN(EED.FOR_dATE) FOR_DATE FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON 
			EED.AD_ID = AM.AD_ID  INNER JOIN #Emp_Cons EC ON EED.EMP_ID = EC.EMP_iD
			WHERE AD_DEF_ID = 3 and ad_not_effect_salary <> 1 AND EED.CMP_ID = @CMP_ID
		GROUP BY EED.EMP_ID ) Q  ON E.EMP_iD = Q.EMP_iD  inner join t0010_company_master CM WITH (NOLOCK) on E.Cmp_ID =CM.Cmp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID ,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q	-- Ankit 09092014 for Same Date Increment
					on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		WHERE E.CMP_ID =@cMP_ID AND Q.FOR_DATE >=@fROM_DATE AND Q.FOR_DATE <=@TO_DATE
				
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 		



	RETURN




