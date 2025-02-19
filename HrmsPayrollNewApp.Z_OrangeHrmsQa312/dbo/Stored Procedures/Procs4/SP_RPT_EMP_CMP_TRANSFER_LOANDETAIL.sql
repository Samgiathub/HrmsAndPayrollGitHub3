

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER_LOANDETAIL]
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
		
		Select lt.Emp_ID as Old_Emp_Id,lt.Cmp_ID as Old_Cmp_ID, lt.Loan_ID AS Old_Loan_Id,lm.Loan_Name as Loan_Name,Case When Loan_Closing > 0 Then Loan_Closing Else Old_Balance end AS Old_Balance,lt.For_Date 
		From T0140_LOAN_TRANSACTION lt WITH (NOLOCK) inner join 
			(Select max(For_Date) For_Date,Emp_ID,Loan_ID From T0140_LOAN_TRANSACTION WITH (NOLOCK)
				where Emp_ID In (select Emp_ID From #Emp_Cons)
				group by Emp_ID,Loan_ID) q on lt.Emp_ID=q.Emp_ID and lt.Loan_ID=q.Loan_ID and lt.For_Date=q.For_Date inner join 
			T0040_LOAN_MASTER lm WITH (NOLOCK) on lt.Loan_ID=lm.Loan_ID Inner Join 
			T0100_EMP_COMPANY_LOAN_TRANSFER CLT WITH (NOLOCK) ON lt.Emp_ID = CLT.Emp_Id INNER JOIN
			#Emp_Cons EC on CLT.Emp_Id = EC.Emp_ID 
		where Case When Loan_Closing > 0 Then Loan_Closing Else Old_Balance end > 0 and
			  CLT.Cmp_Id = @Cmp_Id	
			  ORDER BY RIGHT(REPLICATE(N' ', 500) + lm.Loan_Name, 500) 
	 
		SELECT  CLT.Emp_Id as Old_Emp_Id,CLT.Cmp_Id as Old_Cmp_ID, --CLT.Loan_Id AS Old_Loan_Id,OLM.Loan_Name as Old_Loan_Name,CLT.Old_Balance,
				CLT.New_Emp_Id as New_Emp_Id,CLT.New_Cmp_Id as New_Cmp_ID,CLT.New_Loan_Id,NLM.Loan_Name as New_Loan_Name,CLT.New_Balance	
		FROM	T0100_EMP_COMPANY_LOAN_TRANSFER CLT WITH (NOLOCK) INNER JOIN
				--T0040_Loan_Master OLM ON CLT.Loan_Id = OLM.Loan_ID INNER JOIN
				T0040_Loan_Master NLM WITH (NOLOCK) ON CLT.New_Loan_Id = NLM.Loan_ID INNER JOIN
			    #Emp_Cons EC on CLT.Emp_Id = EC.Emp_ID 
		WHERE CLT.Cmp_Id = @Cmp_Id	
		ORDER BY RIGHT(REPLICATE(N' ', 500) + NLM.Loan_Name, 500) 
		
	RETURN
	

