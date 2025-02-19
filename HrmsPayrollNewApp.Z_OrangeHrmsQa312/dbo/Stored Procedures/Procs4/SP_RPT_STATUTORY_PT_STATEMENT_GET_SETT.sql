



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PT_STATEMENT_GET_SETT]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_call	varchar(20) ='PT Statement'
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

	if @Report_Call ='PT Statement'
		begin
			-- Changed By Ali 23112013 EmpName_Alias
			Select ms.Emp_Id,MS.S_Pt_Calculated_Amount,Ms.S_PT_Amount,ISNULL(EmpName_Alias_PT,Emp_Full_Name) as Emp_full_Name,Grd_Name,Month(S_Month_St_Date)as Month,YEar(S_Month_St_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,CMP_NAME,CMP_ADDRESS,S_PT_F_T_Limit,Comp_Name,Branch_Address,Branch_name, BM.Branch_ID		
				 From t0201_monthly_salary_sett MS WITH (NOLOCK) Inner join 
				T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID 
					inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  INNER JOIN 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID
				WHERE E.Cmp_ID = @Cmp_Id	
					and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date 
					and S_PT_Amount > 0
		End
	else
		Begin
		
				 Declare @PT_Challan Table
							  ( 
  								Cmp_ID		numeric ,
								Branch_ID 		numeric ,
								PT_L_T_Limit  	varchar(50),
								A_PT_Amount		numeric default 0,
								PT_Amount		numeric default 0,
								P_month		numeric ,
								P_Year		numeric,
								PT_calculated_Amount  numeric	default 0,
								Emp_Count	numeric default 0
							  )	
							
							  
				insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
				select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  cast(To_Limit as varchar(20))  ,Month(@To_Date) ,year(@To_Date)

				from T0040_professional_setting p WITH (NOLOCK) inner join 
				( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting WITH (NOLOCK)
					where Cmp_ID =@cmp_ID 
				group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
				Where p.Cmp_Id =@Cmp_ID and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)


				update @PT_Challan 
				set PT_Amount = q.Sum_PT_Amount ,
					PT_calculated_Amount = q.sum_PT_calculated_Amount,
					Emp_Count = q.Emp_Count
				From @PT_Challan  P inner join 
					( Select Branch_Id,count(ms.emp_Id)Emp_Count,S_PT_Amount,sum(S_PT_Amount) Sum_PT_Amount,Sum(S_PT_calculated_Amount ) sum_PT_calculated_Amount 
						From	t0201_monthly_salary_sett ms WITH (NOLOCK) inner join T0095_Increment I WITH (NOLOCK) on ms.Increment_ID =i.Increment_ID 
						inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						Where S_Month_St_date >=@From_Date and S_Month_St_Date <=@To_Date
						group by Branch_ID ,S_PT_Amount) q on p.Branch_ID =q.Branch_ID and p.A_PT_Amount = q.S_PT_Amount
				Where  isnull(p.Branch_ID,0) >0 			

			 	update @PT_Challan 
				set PT_Amount = q.Sum_PT_Amount ,
					PT_calculated_Amount = q.sum_PT_calculated_Amount,
					Emp_Count = q.Emp_Count
				From @PT_Challan  P inner join 
					( Select S_PT_Amount,count(ms.emp_Id)Emp_Count,sum(S_PT_Amount) Sum_PT_Amount,Sum(S_PT_calculated_Amount ) sum_PT_calculated_Amount 
						From	t0201_monthly_salary_sett ms WITH (NOLOCK) inner join T0095_Increment I WITH (NOLOCK) on ms.Increment_ID =i.Increment_ID 
						inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
						Where S_Month_St_date >=@From_Date and S_Month_St_Date <=@To_Date
						group by S_PT_Amount) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = q.S_PT_Amount
				Where  isnull(p.Branch_ID,0) =0
			 
					
			select p.* ,Branch_NAme,Cmp_Address,Cmp_Name,BM.Branch_ID from @PT_Challan	p left outer Join T0030_Branch_MAster bm  WITH (NOLOCK) on p.Branch_ID = bm.Branch_ID
			Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) on p.Cmp_Id = cm.Cmp_ID 
				
			  
		/*
			Select Ms.Cmp_ID,Cmp_Name,Cmp_Address,Emp_full_Name,Grd_Name,Month(Month_St_Date)as Month,YEar(Month_St_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,PT_Amount,PT_F_T_Limit			
				 From T0200_MONTHLY_SALARY MS Inner join 
				T0080_EMP_MASTER E on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					T0095_Increment I_Q on Ms.Increment_ID = I_Q.Increment_ID 
					inner join
							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  Inner join 
							T0010_COMPANY_MASTER CM ON MS.CMP_ID = CM.CMP_ID
				WHERE E.Cmp_ID = @Cmp_Id	
					and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date
					and PT_Amount > 0 
					*/
		End			

		
RETURN




