

-- =============================================
-- Author:		<JIMTT>
-- Create date: <23112015>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER_ADVANCEDETAIL_HISTORY]
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
	 
		Select AT.Tran_Id,CT.Old_Emp_Id,CT.New_Emp_Id,AT.Old_Balance as Old_Advance_Balance,AT.New_Balance as New_Advance_Balance
		From T0100_EMP_COMPANY_ADVANCE_TRANSFER AT WITH (NOLOCK) INNER JOIN
			 T0095_EMP_COMPANY_TRANSFER CT WITH (NOLOCK) ON AT.Tran_Id = CT.Tran_Id INNER JOIN
			 #Emp_Cons_temp EC on ct.Old_Emp_Id = EC.Old_Emp_ID 
		--WHERE ct.Old_Cmp_Id = @Cmp_Id	
		--ORDER BY RIGHT(REPLICATE(N' ', 500) , 500) 
		
		drop TABLE #temp
		
	RETURN

