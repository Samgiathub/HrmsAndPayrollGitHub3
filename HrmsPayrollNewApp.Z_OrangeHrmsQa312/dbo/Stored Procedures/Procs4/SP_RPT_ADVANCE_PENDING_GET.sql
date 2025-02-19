---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_ADVANCE_PENDING_GET]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT 	VARCHAR(MAX)
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 19082013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 19082013
	,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 19082013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 19082013	
	,@Reason_Id  numeric = 0   --Added By Jaina 31-10-2015
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
	
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 19082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 19082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 19082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 19082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 19082013
	set @SubBranch_Id = null	

	
	CREATE TABLE #Emp_Cons 	-- Ankit 06092014 for Same Date Increment
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )   
		 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 


	--Declare #Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons

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
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 19082013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 19082013
		
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date)
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date) 
	--	end
	
	--IF @Reason_ID = 0
	--	SET @Reason_ID = NULL
			
			IF @Reason_ID = 0
			Begin
			Select distinct MLD.Adv_Tran_ID,MLD.Cmp_ID,MLD.Emp_ID,MLD.For_Date,MLD.Adv_Opening,MLD.Adv_Return,MLD.Adv_Closing,AP.Adv_Amount As Adv_Issue,   --Added By Jaina 16-11-2015
					ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Cmp_Name,Cmp_Address ,Comp_name ,@From_date P_From_Date ,
					@To_Date P_To_Date,Branch_Name,Branch_Address, BM.Branch_ID
					,E.alpha_emp_code,E.Emp_first_name   --added jimit 01062015
					,R.Res_Id,R.Reason_Name   --Added By Jaina 26-10-2015
					From T0140_ADVANCE_TRANSACTION MLD WITH (NOLOCK) Inner join      
						 T0080_Emp_master E WITH (NOLOCK) on MLD.Emp_ID =E.Emp_ID left OUTER join
						 --Added By Jaina 26-10-2015 Start
						 T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) ON AP.For_Date = MLD.For_Date and AP.Emp_ID=MLD.Emp_ID left OUTER JOIN
						 T0090_ADVANCE_PAYMENT_APPROVAL APA WITH (NOLOCK) ON APA.Application_Date = MLD.For_Date and MLD.Emp_ID=APA.Emp_ID left OUTER JOIN
						 T0040_Reason_Master R WITH (NOLOCK) ON R.Res_Id=IsNull(AP.Res_Id, APA.Res_Id)	--For Admin Advance Payment
						 
						 INNER JOIN
						 --Added By Jaina 26-10-2015 End
  							(select I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
								on E.Emp_ID = I_Q.Emp_ID  inner join
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
									T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
						WHERE		E.Cmp_ID = @Cmp_Id and  MLD.For_Date >=@From_Date and MLD.For_Date <=@To_Date 
									And E.Emp_Id In (Select Emp_Id From #Emp_Cons) 
									And ( Adv_Issue>0 Or Adv_return >0)

			End
		Else
			Begin
					-- Changed By Ali 22112013 EmpName_Alias
					Select distinct MLD.Adv_Tran_ID,MLD.Cmp_ID,MLD.Emp_ID,MLD.For_Date,MLD.Adv_Opening,MLD.Adv_Return,MLD.Adv_Closing,AP.Adv_Amount As Adv_Issue,   --Added By Jaina 16-11-2015
					ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Cmp_Name,Cmp_Address ,Comp_name ,@From_date P_From_Date ,
					@To_Date P_To_Date,Branch_Name,Branch_Address, BM.Branch_ID
					,E.alpha_emp_code,E.Emp_first_name   --added jimit 01062015
					,R.Res_Id,R.Reason_Name   --Added By Jaina 26-10-2015
					From T0140_ADVANCE_TRANSACTION MLD WITH (NOLOCK) Inner join      
						 T0080_Emp_master E WITH (NOLOCK) on MLD.Emp_ID =E.Emp_ID left OUTER join
						 --Added By Jaina 26-10-2015 Start
						 T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) ON AP.For_Date = MLD.For_Date and AP.Emp_ID=MLD.Emp_ID left OUTER JOIN
						 T0090_ADVANCE_PAYMENT_APPROVAL APA WITH (NOLOCK) ON APA.Application_Date = MLD.For_Date and MLD.Emp_ID=APA.Emp_ID
						 LEFT OUTER JOIN T0040_Reason_Master R WITH (NOLOCK) ON R.Res_Id=IsNull(AP.Res_Id,APA.Res_Id) inner JOIN
						 --Added By Jaina 26-10-2015 End
  							(select I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
								on E.Emp_ID = I_Q.Emp_ID  inner join
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
									T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
						WHERE		E.Cmp_ID = @Cmp_Id and  MLD.For_Date >=@From_Date and MLD.For_Date <=@To_Date 
									And E.Emp_Id In (Select Emp_Id From #Emp_Cons) 
									And ( Adv_Issue>0 Or Adv_return >0)
									And R.Res_Id = @Reason_ID --Added By Jaina 31-10-2015
								
			End
		
	RETURN
