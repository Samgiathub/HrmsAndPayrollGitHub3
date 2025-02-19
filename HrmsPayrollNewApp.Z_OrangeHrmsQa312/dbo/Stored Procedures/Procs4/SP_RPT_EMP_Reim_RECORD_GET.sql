
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_Reim_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	--,@Branch_ID		numeric   = 0
	--,@Cat_ID		numeric  = 0
	--,@Grd_ID		numeric = 0
	--,@Type_ID		numeric  = 0
	--,@Dept_ID		numeric  = 0
	--,@Desig_ID		numeric = 0
	,@Branch_ID		varchar(Max)=''
	,@Cat_ID		varchar(Max)=''
	,@Grd_ID		varchar(Max)=''
	,@Type_ID		varchar(Max)=''
	,@Dept_ID		varchar(Max)=''
	,@Desig_ID		varchar(Max)=''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''	
	,@Emp_Reim      varchar(10)=''
	,@Vertical_Id	varchar(max)=''   ---Added By Jaina 3-10-2015
	,@SubVertical_Id varchar(max)=''  ---Added By Jaina 3-10-2015
	,@SubBranch_Id varchar(max)='' -- added ronakb070824
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0  --Change By Jaina 3-10-2015
	
	-- Comment by nilesh patel on 22092014 --Start
    /*
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
		
	
	-- Ankit 08092014 for Same Date Increment


	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	
	
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
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date and  @From_Date <= left_date ) 
			
	--	end */
	--declare @rc_app_id numeric(18,0)
	--select @rc_app_id= rc_app_id from T0100_RC_Application where not exists (select rc_app_id from T0120_RC_Approval where cmp_id=@cmp_id)
	--						begin
	--						select @rc_app_id
	--						end
	
	if @Emp_Reim='ALL'
		BEgin
		
		--select T0100_RC_Application.*,T0050_AD_MASTER.AD_NAME,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
		--						Left_Date,BM.Comp_Name,BM.Branch_Address--,Left_Reason
		--						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
		--						 Gender,@From_Date as From_Date ,@To_Date as To_Date
		--						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
		--						isnull(T0120_RC_Approval.APR_Status,0) APR_Status,T0120_RC_Approval.Apr_Amount,
		--						T0120_RC_Approval.Taxable_Exemption_Amount,T0120_RC_Approval.Apr_Date 
		--						into temp_new
		--			from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
		--				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
		--						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
		--						where Increment_Effective_date <= @To_Date
		--						and Cmp_ID = @Cmp_ID
		--						group by emp_ID  ) Qry on
		--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--					on E.Emp_ID = I_Q.Emp_ID  
		--					 INNER JOIN T0100_RC_Application ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
		--						T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--						T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
		--						T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--						T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		--						T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
		--						T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
		--						inner join T0050_AD_master on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
		--						T0120_RC_Approval ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
								
								
		--					WHERE E.Cmp_ID = @Cmp_Id 	
		--					And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							
							
							
		--					and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
		--					--or App_Date >= @From_Date and App_Date <= @To_Date
		

		--DECLARE @Count AS INT
		--Select @Count = count (*) from temp_new
		
		
		--if @Count =0
		--begin
		--select T0100_RC_Application.*,T0050_AD_MASTER.AD_NAME,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
		--Left_Date,BM.Comp_Name,BM.Branch_Address--,Left_Reason
		--Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
		--						 Gender,@From_Date as From_Date ,@To_Date as To_Date
		--						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
		--						isnull(T0120_RC_Approval.APR_Status,0) APR_Status,T0120_RC_Approval.Apr_Amount,
		--						T0120_RC_Approval.Taxable_Exemption_Amount,T0120_RC_Approval.Apr_Date
		--						into temp_two
		--			from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
		--				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
		--						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
		--						where Increment_Effective_date <= @To_Date
		--						and Cmp_ID = @Cmp_ID
		--						group by emp_ID  ) Qry on
		--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--					on E.Emp_ID = I_Q.Emp_ID  
		--					 INNER JOIN T0100_RC_Application ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
		--						T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--						T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
		--						T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--						T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		--						T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
		--						T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
		--						inner join T0050_AD_master on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
		--						T0120_RC_Approval ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
								
		--					WHERE E.Cmp_ID = @Cmp_Id 	
		--					And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							
							
							
		--	--				and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
		--					and App_Date >= @From_Date and App_Date <= @To_Date
		--					and Apr_Date>=@From_Date and Apr_Date <= @To_Date
		--end
		
		--select * from temp_new
		
		--select * from temp_two
		
		
		--drop table temp_new
		--drop table temp_two
		--return
		
				select I_Q.* ,T0100_RC_Application.*,T0050_AD_MASTER.AD_NAME,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
								Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
								 Gender,@From_Date as From_Date ,@To_Date as To_Date
								,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
								case when T0120_RC_Approval.Apr_Date > @to_date then 0 else  isnull(T0120_RC_Approval.APR_Status,0) end as APR_Status,
								case when T0120_RC_Approval.Apr_Amount is null then T0100_RC_Application.App_Amount else T0120_RC_Approval.Apr_Amount end as Apr_Amount,
								case when T0120_RC_Approval.Taxable_Exemption_Amount is null then T0100_RC_Application.taxable_amount else T0120_RC_Approval.Taxable_Exemption_Amount end as Taxable_Exemption_Amount,
								
								case when T0120_RC_Approval.Apr_Date > @to_date then T0100_RC_Application.APP_Date when T0120_RC_Approval.Apr_Date is null then T0100_RC_Application.APP_Date else T0120_RC_Approval.Apr_Date end as Apr_Date
					from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  
							 INNER JOIN T0100_RC_Application WITH (NOLOCK) ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
								inner join T0050_AD_master WITH (NOLOCK) on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
								T0120_RC_Approval WITH (NOLOCK) ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
								
							WHERE E.Cmp_ID = @Cmp_Id 	
							And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END >= @From_Date and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END <= @To_Date 
							or App_Date >= @From_Date and App_Date <= @To_Date
							
							--and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
							--or App_Date >= @From_Date and App_Date <= @To_Date
							
							
					--Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			---When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				--Else e.Alpha_Emp_Code
			--End
					----ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
				--union
				--select I_Q.* ,T0100_RC_Application.*,T0050_AD_MASTER.AD_NAME,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
				--				Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
				--				,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
				--				 Gender,@From_Date as From_Date ,@To_Date as To_Date
				--				,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
				--				--case when
				--				 T0100_RC_Application.App_Date as Apr_Date,
				--				-- > @to_date then 0 else  isnull(T0120_RC_Approval.APR_Status,0) end as APR_Status,
				--				T0100_RC_Application.App_Amount as Apr_Amount,
				--				T0100_RC_Application.Tax_Exception as Taxable_Exemption_Amount,
								
				--				--case when T0120_RC_Approval.Apr_Date > @to_date then null else T0120_RC_Approval.Apr_Date end as Apr_Date
				--				T0100_RC_Application.APP_Date as Apr_date
				--	from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
				--		( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
				--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
				--				where Increment_Effective_date <= @To_Date
				--				and Cmp_ID = @Cmp_ID
				--				group by emp_ID  ) Qry on
				--				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--			on E.Emp_ID = I_Q.Emp_ID  
				--			 INNER JOIN T0100_RC_Application ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
				--				T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				--				T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
				--				T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				--				T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				--				T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				--				T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
				--				left join T0050_AD_master on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
				--				T0120_RC_Approval ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
								
				--			WHERE E.Cmp_ID = @Cmp_Id 	
				--			And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
							
							
							
				--			and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
				--			or App_Date >= @From_Date and App_Date <= @To_Date
				
				--select row_number() OVER ( PARTITION BY T0120_RC_Approval.RC_ID,T0120_RC_Approval.Emp_ID ORDER BY T0100_RC_Application.Emp_ID DESC )rank,
				-- I_Q.* ,T0100_RC_Application.*,
				---- T0050_AD_MASTER.AD_NAME,
				-- --E.Emp_Full_Name,
				
				----E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
				----Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
				--				--,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
				--				-- Gender,@From_Date as From_Date ,@To_Date as To_Date
				--				--,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
				--				isnull(T0120_RC_Approval.APR_Status,0) APR_Status,T0120_RC_Approval.Apr_Amount,
				--				T0120_RC_Approval.Taxable_Exemption_Amount,T0120_RC_Approval.Apr_Date
				--				from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
				--		( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
				--			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
				--				where Increment_Effective_date <= @To_Date
				--				and Cmp_ID = @Cmp_ID
				--				group by emp_ID  ) Qry on
				--				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--			on E.Emp_ID = I_Q.Emp_ID  
				--			 INNER JOIN T0100_RC_Application ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
				--				--T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				--				--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
				--				--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				--				--T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				--				--T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				--				--T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
				--				--inner join T0050_AD_master on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
				--				T0120_RC_Approval ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
						
				--			WHERE E.Cmp_ID = @Cmp_Id 	
				--			And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
				--			and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
							
				--			--or App_Date >= @From_Date and App_Date <= @To_Date
				--			union 
				--			select row_number() OVER (PARTITION BY T0100_RC_Application.RC_ID,T0100_RC_Application.Emp_ID ORDER BY T0100_RC_Application.Emp_ID DESC )rank,
				--			--select
				--			 I_Q.* ,T0100_RC_Application.*,
				--			 --T0050_AD_MASTER.AD_NAME,E.Emp_Full_Name,
				----E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,
				----Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
				--				--,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
				--				-- Gender,@From_Date as From_Date ,@To_Date as To_Date
				--				--,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,
				--				isnull(T0100_RC_Application.APP_Status,0) as APR_Status,T0100_RC_Application.App_amount as Apr_Amount,
				--				T0100_RC_Application.Taxable_Amount as Taxable_Exemption_Amount,T0100_RC_Application.App_date as Apr_date
				--				from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
				--		( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
				--			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
				--				where Increment_Effective_date <= @To_Date
				--				and Cmp_ID = @Cmp_ID
				--				group by emp_ID  ) Qry on
				--				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				--			on E.Emp_ID = I_Q.Emp_ID  
				--			 INNER JOIN T0100_RC_Application ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID INNER JOIN
				--			--	T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				--				--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN 
				--			--	T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				--			--	T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
				--			---	T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
				--			--	T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
				--				--inner join 
				--				T0050_AD_master on T0100_RC_Application.RC_ID = T0050_AD_master.AD_ID Left Join
				--				T0120_RC_Approval ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID And T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID
						
				--			WHERE E.Cmp_ID = @Cmp_Id 	
				--			And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
				--			and App_Date >= @From_Date and App_Date <= @To_Date 
							--and RANK=1 
							
		End
		if @Emp_Reim='APPROVE'	
		BEgin
				select I_Q.* ,T0120_RC_Approval.*,T0050_AD_MASTER.AD_NAME,T0100_RC_Application.FY,E.Emp_Full_Name , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,
								BM.Comp_Name,BM.Branch_Address,Left_Reason
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
								 Gender,@From_Date as From_Date ,@To_Date as To_Date
								,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
					from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  
							 INNER JOIN T0120_RC_Approval WITH (NOLOCK) ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID left outer JOIN
							  T0100_RC_Application WITH (NOLOCK) ON T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID INNER JOIN
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
								inner join T0050_AD_master WITH (NOLOCK) on T0120_RC_Approval.RC_ID = T0050_AD_master.AD_ID

					WHERE E.Cmp_ID = @Cmp_Id	 
					and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END >= @From_Date and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END <= @To_Date 
					--and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
					and APR_Status=1
					--And E.emp_ID in 
							--(select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=1) 
							And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		End
		
		if @Emp_Reim='REJECT'	
		BEgin
				select I_Q.* ,T0120_RC_Approval.*,T0050_AD_MASTER.AD_NAME,T0100_RC_Application.FY,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date
								,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
					from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  
							 INNER JOIN T0120_RC_Approval WITH (NOLOCK) ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID INNER JOIN
							   T0100_RC_Application WITH (NOLOCK) ON T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID left outer JOIN
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID inner join 
								T0050_AD_master WITH (NOLOCK) on T0120_RC_Approval.RC_ID = T0050_AD_master.AD_ID

					WHERE E.Cmp_ID = @Cmp_Id	
					and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END >= @From_Date and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN Apr_Date ELSE Payment_date END <= @To_Date 
					and APR_Status=2
					--and Apr_Date >= @From_Date and Apr_Date <= @To_Date and APR_Status=2
					-- And E.emp_ID in 
							--(select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=2) 
							And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		End
		
		if @Emp_Reim=''	
		BEGIN
		--select * from #Emp_Cons where emp_id=2033
		--return
		
		--SELECT * FROM (select dISTINCT T0120_RC_Approval.Emp_ID, E.Emp_Full_Name , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,
		--						BM.Comp_Name,BM.Branch_Address,Left_Reason
		--						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,
		--						 Gender,@From_Date as From_Date ,@To_Date as To_Date
		--						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box
		--			from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
		--				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
		--						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
		--						where Increment_Effective_date <= @To_Date
		--						and Cmp_ID = @Cmp_ID
		--						group by emp_ID  ) Qry on
		--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--					on E.Emp_ID = I_Q.Emp_ID  
		--					 INNER JOIN T0120_RC_Approval  ON I_Q.Emp_ID = T0120_RC_Approval.Emp_ID left outer JOIN
							  
		--					T0100_RC_Application ON T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID left JOIN
							  
		--						T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--						T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		--						T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--						T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		--						T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
		--						T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
		--						inner join T0050_AD_master on T0120_RC_Approval.RC_ID = T0050_AD_master.AD_ID

		--			WHERE E.Cmp_ID = @Cmp_Id	
		--			and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
		--			or App_Date >= @From_Date and App_Date <= @To_Date
		--			-- And E.emp_ID in 
		--					--(select Emp_ID from T0120_RC_Approval where Apr_Date >= @From_Date and Apr_Date <= @To_Date And APR_Status=1) 
		--					And E.Emp_ID in (select Emp_ID From #Emp_Cons)) AS qa
							
							
		--			Order by Case When IsNumeric(qa.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + qa.Alpha_Emp_Code, 20)
		--	When IsNumeric(qa.Alpha_Emp_Code) = 0 then Left(qa.Alpha_Emp_Code + Replicate('',21), 20)
		--		Else qa.Alpha_Emp_Code
		--	End
		--SELECT * FROM(select distinct T0100_RC_Application.Emp_ID, E.Emp_Full_Name , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date
		--from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
		--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
		--						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 08092014 for Same Date Increment
		--						where Increment_Effective_date <= @To_Date
		--						and Cmp_ID = @Cmp_ID
		--						group by emp_ID  ) Qry on
		--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
		--					on E.Emp_ID = I_Q.Emp_ID  
		--					INNER JOIN T0100_RC_Application  ON I_Q.Emp_ID = T0100_RC_Application.Emp_ID left outer JOIN
		--					T0100_RC_Application ON T0120_RC_Approval.RC_App_ID = T0100_RC_Application.RC_App_ID --left JOIN
		--			WHERE E.Cmp_ID = @Cmp_Id	
		--			and Apr_Date >= @From_Date and Apr_Date <= @To_Date 
		--			or App_Date >= @From_Date and App_Date <= @To_Date		
		--		And E.Emp_ID in (select Emp_ID From #Emp_Cons)) AS qa	
		
		
		select distinct E.Emp_ID, E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name
				Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date
								,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
								,I_Q.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
					from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  inner join
							T0100_RC_Application RC WITH (NOLOCK) on RC.Emp_ID=E.Emp_ID left join
							T0120_RC_Approval Tr WITH (NOLOCK) on Tr.RC_APP_ID=RC.RC_APP_ID LEFT join
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
								Inner Join (select Emp_ID From #Emp_Cons) e_qry
								ON e_qry.Emp_ID = E.Emp_ID
					WHERE E.Cmp_ID = @Cmp_Id
					-- And E.emp_ID in 
					--		(select Emp_ID from T0100_RC_Application where T0100_RC_Application.APP_Date >= @From_Date and T0100_RC_Application.APP_Date <= @To_Date )--and App_Status=0 or App_Status=1 or App_Status=2)
							--or (select Emp_ID from T0100_AR_Application where For_Date >= @From_Date and For_Date <= @To_Date) 
					
					and RC.APP_Date >= @From_Date and RC.APP_Date <= @To_Date
					OR	CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN tr.Apr_Date ELSE Payment_date END >=@FROm_Date and CASE WHEN RC_Apr_Effect_In_Salary = 0 THEN tr.Apr_Date ELSE Payment_date END <= @To_Date
					--or	tr.Apr_Date >=@FROm_Date and tr.Apr_date <= @To_Date
							
		
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + qa.ALPHA_EMP_CODE, 500)
		END
		
	RETURN




