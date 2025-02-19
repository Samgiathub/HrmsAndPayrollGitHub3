



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER_LEAVEDETAIL]
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
	 	
		Select lt.Emp_ID as Old_Emp_Id,lt.Cmp_ID as Old_Cmp_ID, lt.Leave_ID AS Old_Leave_Id,lm.Leave_Name as Old_Leave_Name,Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End as Old_Balance  
		From T0140_LEave_Transaction lt WITH (NOLOCK) inner join 
			(select max(For_Date)For_Date,Emp_ID,LEave_ID from T0140_LEave_Transaction WITH (NOLOCK)
				where(emp_ID IN (select Emp_ID From #Emp_Cons) And For_Date <=@From_Date) 
				group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date inner join 
		T0040_leave_master lm WITH (NOLOCK) on lt.leavE_id =lm.leave_id Inner Join
		#Emp_Cons EC on lt.Emp_Id = EC.Emp_ID
		Where Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End > 0 
		order by Leave_Name asc
		
		SELECT CLT.Emp_Id as Old_Emp_Id,CLT.Cmp_Id as Old_Cmp_ID,-- CLT.Leave_Id AS Old_Leave_Id,OLM.Leave_Name as Old_Leave_Name,CLT.Old_Balance,
			   CLT.New_Emp_Id as New_Emp_Id,CLT.New_Cmp_Id as New_Cmp_ID,CLT.New_Leave_Id,NLM.Leave_Name as New_Leave_Name,CLT.New_Balance	
		FROM	T0100_EMP_COMPANY_LEAVE_TRANSFER CLT WITH (NOLOCK) INNER JOIN
				--T0040_LEAVE_MASTER OLM ON CLT.Leave_Id = OLM.Leave_ID INNER JOIN
				T0040_LEAVE_MASTER NLM WITH (NOLOCK) ON CLT.New_Leave_Id = NLM.Leave_ID INNER JOIN 
				#Emp_Cons EC on CLT.Emp_Id = EC.Emp_ID
		WHERE CLT.Cmp_Id = @Cmp_Id	
		ORDER BY RIGHT(REPLICATE(N' ', 500) + NLM.Leave_Name, 500) 
		
	RETURN
