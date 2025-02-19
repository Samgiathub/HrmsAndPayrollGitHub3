

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_ALL_COMPANY_EmpId]     
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric,
  Emp_full_Name Varchar(100)
 )      

 
	
		Insert Into #Emp_Cons      
		select	DISTINCT  VE.Emp_ID,VE.branch_id,VE.Increment_ID ,Em.Emp_Full_Name 
		from		V_Emp_Cons  VE 
					inner join T0080_EMP_MASTER EM on VE.Emp_ID = EM.Emp_ID
					inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on VE.branch_id=g.branch_id left OUTER JOIN 
						(
							SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid 
							FROM	T0095_Emp_Salary_Cycle ESC WITH (NOLOCK) inner join 
							(
								SELECT	max(Effective_date) as Effective_date,emp_id 
								FROM	T0095_Emp_Salary_Cycle WITH (NOLOCK) 
								where	Effective_date <= @To_Date
										and cmp_id = @Cmp_ID 
								GROUP BY emp_id
							) Qry  on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
						 ) as QrySC ON QrySC.eid = VE.Emp_ID 
		       where  --Change By Jaina 14-09-2015
			  VE.cmp_id=@Cmp_ID 
		and Increment_Effective_Date <= @To_Date 
		and ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
		order by Emp_ID
			
			
		Delete	#Emp_Cons 
		From	#Emp_Cons  EC WITH (NOLOCK) 
					Left Outer Join (
										SELECT	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
										FROM	t0095_increment TI  WITH (NOLOCK)
												INNER JOIN 
												(	
													Select	Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)
													Where	Increment_effective_Date <= @to_date and cmp_id=@Cmp_Id
													Group by emp_ID
												) new_inc ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date										
										group by ti.emp_id
									) Qry on Ec.Increment_Id = Qry.Increment_Id
				
					
		Where Qry.Increment_ID is null
			
		select * from #Emp_Cons
Return		