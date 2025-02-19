


-- =============================================
-- Author:		<JIMTT>
-- Create date: <23112015>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER_SALARYDETAIL_HISTORY]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric  = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric  = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @Branch_ID = 0
		Set @Branch_ID = null
	If @Cat_ID = 0
		Set @Cat_ID = null
	If @Type_ID = 0
		Set @Type_ID = null
	If @Dept_ID = 0
		Set @Dept_ID = null
	If @Grd_ID = 0
		Set @Grd_ID = null
	If @Emp_ID = 0
		Set @Emp_ID = null
	If @Desig_ID = 0
		Set @Desig_ID = null
		
	
	Create Table #Emp_Cons 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )      
 
	
	Create Table #Emp_Cons_temp
	 (      
	   Old_Cmp_Id  NUMERIC,
	   New_Cmp_Id NUMERIC,
	   Old_Emp_Id NUMERIC,
	   New_Emp_Id NUMERIC	   
	 ) 
	
	If @Constraint <> ''
		Begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		End
	
	Else 
		Begin
			Insert Into #Emp_Cons      
		      select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      cmp_id=@Cmp_ID 
		        and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
			    and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
			    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
			    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
			    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
			    and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
				and Increment_Effective_Date <= @To_Date 
		        and 
				  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
					or (Left_date is null and @To_Date >= Join_Date)      
					or (@To_Date >= left_date  and  @From_Date <= left_date )) 
					order by Emp_ID
							
			Delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)
		End
		
		;with cte as
						(  
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner JOIN
						  #Emp_Cons EC On Ec.Emp_ID = T.Old_Emp_Id
						  where T.Old_Emp_Id = Ec.Emp_ID
						  union all
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK)
							inner join cte as C
							  on T.Old_Emp_Id = C.New_Emp_Id
						)
						select * 
						into #Temp
						from cte
	 					
	 		;with cte as
						(  
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner JOIN
						  #Emp_Cons EC On Ec.Emp_ID = T.Old_Emp_Id
						  where T.New_Emp_Id = Ec.Emp_ID
						  union all
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK)
							inner join cte as C
							  on T.New_Emp_Id = C.Old_Emp_Id
						)
						select * 
						into #Temp1
						from cte
	 					
	 						
	 			insert into #Emp_Cons_temp
	 			SELECT * from #temp
	 			union ALL 
	 			select * from #temp1
	 			order By Old_emp_id
	 			
			--select * from #Emp_Cons_temp
		
		
		SELECT ED.EMP_ID AS Old_Emp_Id,
			   ED.AD_ID AS Old_Ad_Id,ED.AD_NAME AS OLD_AD_NAME,
			   ED.E_AD_MODE AS OLD_MODE,ED.E_AD_PERCENTAGE AS OLD_PERCE,ED.E_AD_AMOUNT AS OLD_AMT
			   
		FROM   V0100_EMP_EARN_DEDUCTION ED INNER JOIN
			   #Emp_Cons_temp EC on ED.Emp_Id = EC.Old_Emp_ID
		where ED.Hide_In_Reports=0   --Added by Jaina 19-05-2017
		--WHERE ED.Cmp_Id = @Cmp_Id	
		ORDER BY RIGHT(REPLICATE(N' ', 500) + convert(varchar(50),ED.EMP_ID), 500) 
			 
		SELECT ED.Old_Emp_Id,
			   ED.Old_Ad_Id,--AM.AD_NAME AS OLD_AD_NAME,
			   --ED.Old_Mode AS OLD_MODE,ED.Old_Percentage AS OLD_PERCE,ED.Old_Amount AS OLD_AMT,
			   ED.New_Emp_Id,ED.New_Ad_Id,NAM.AD_NAME AS NEW_AD_NAME,ED.New_Mode,ED.New_Percentage,ED.New_Amount
		FROM   T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION ED WITH (NOLOCK) LEFT OUTER JOIN
			   --T0050_AD_MASTER AM ON ED.Old_Ad_Id = AM.AD_ID LEFT OUTER JOIN
			   T0050_AD_MASTER NAM WITH (NOLOCK) ON ED.New_Ad_Id = NAM.AD_ID INNER JOIN
			   #Emp_Cons_temp EC on ED.Old_Emp_Id = EC.Old_Emp_ID
		where NAM.Hide_In_Reports = 0 --Added by Jaina 19-05-2017
		--WHERE ED.Old_Cmp_Id = @Cmp_Id	
		ORDER BY RIGHT(REPLICATE(N' ', 500) + convert(varchar(50),ED.OLd_EMP_ID), 500) 
		
		--SELECT CT.Old_Emp_Id,CT.Old_Cmp_Id, Basic_Salary AS Old_Basic_Salary ,Gross_Salary as Old_Gross_Salary , CTC as Old_CTC
		--FROM T0095_INCREMENT I INNER JOIN 
		--	( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
		--	where Increment_Effective_date <= @To_Date
		--	and Cmp_ID = @Cmp_ID
		--	group by emp_ID  ) Qry on
		--	I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date INNER JOIN
		--	T0095_EMP_COMPANY_TRANSFER CT ON I.Emp_ID = CT.Old_Emp_Id INNER JOIN
		--	#Emp_Cons EC ON I.Emp_ID = EC.Emp_ID
		--WHERE I.Cmp_ID = @Cmp_Id	
		
		--SELECT CT.Old_Emp_Id,CT.Old_Cmp_Id, Basic_Salary AS Old_Basic_Salary ,Gross_Salary as Old_Gross_Salary , CTC as Old_CTC
		--FROM T0095_INCREMENT I INNER JOIN 
		--	( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
		--	where Increment_Effective_date <= @To_Date
		--	and Cmp_ID = @Cmp_ID
		--	group by emp_ID  ) Qry on
		--	I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date INNER JOIN
		--	T0095_EMP_COMPANY_TRANSFER CT ON I.Emp_ID = CT.New_Emp_Id INNER JOIN
		--	#Emp_Cons EC ON I.Emp_ID = EC.Emp_ID
		--WHERE I.Cmp_ID = @Cmp_Id	
		
		drop TABLE #temp
		
	RETURN


