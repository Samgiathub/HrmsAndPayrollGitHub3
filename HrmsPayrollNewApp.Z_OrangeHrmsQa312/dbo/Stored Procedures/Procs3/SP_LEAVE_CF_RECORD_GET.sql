



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CF_RECORD_GET]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric   
	,@Grd_ID		numeric 
	,@Emp_ID 		numeric 		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null 
	if @Emp_ID = 0
		set @Emp_ID = null
		
		Declare @Leave_CF Table
		(
			leave_id			numeric
			,Leave_Name			varchar(100)
		)
		
		Declare @Emp_Cons Table
			(
				Emp_ID	numeric
			)
	
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 

	
			Insert Into @Leave_CF(leave_id,Leave_Name)

			select LEave_ID,Leave_Name from T0040_leave_master WITH (NOLOCK) where Leave_CF_Type='Monthly' and cmp_ID=@Cmp_ID
			and leave_ID not in 
			(select distinct leave_ID  from T0100_leavE_CF_Detail lcf WITH (NOLOCK) Inner join @Emp_Cons ec on lcf.emp_ID= ec.emp_ID where lcf.cmp_ID=@Cmp_ID and 
			month(cf_For_Date) = month(@From_Date))
			
			
			Insert Into @Leave_CF(leave_id,Leave_Name)

			select LEave_ID,Leave_Name from T0040_leave_master WITH (NOLOCK) where Leave_CF_Type='Yearly' and cmp_ID=@Cmp_ID and Leave_cf_month = month(@from_date)
			and leave_ID not in 
			(select distinct leave_ID  from T0100_leavE_CF_Detail lcf WITH (NOLOCK) Inner join @Emp_Cons ec on lcf.emp_ID= ec.emp_ID where lcf.cmp_ID=@Cmp_ID and 
			 Year(cf_For_Date) = Year(@From_Date)) 
			
			--Nikunj 15-Dec-2010
			--For yearlt carry forward you have to chek year rather then month
			--before this change here is month only so once u done then after it's not done.
			--if u want to check then u check with below condtion 			
			--month(cf_For_Date) = month(@From_Date)
			
			
			select LEave_ID,Leave_Name from @Leave_CF




