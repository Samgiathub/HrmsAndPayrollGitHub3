

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_Training_INOUT_RECORDS]
	 @cmp_ID numeric(18,0)
	,@emp_ID numeric(18,0)
	,@From_Date	 datetime
	,@To_Date	 datetime
	,@Branch_ID numeric(18,0) 
	,@Constraint varchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	Declare @Out_Time datetime
	Declare @In_Time datetime
	declare @For_date datetime
	
	 If @Branch_ID = 0 
		set @Branch_ID = null
	 If @emp_ID = 0
		set @emp_ID = null	

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else if @Emp_ID > 0
		begin
			Insert Into @Emp_Cons values (@Emp_ID)
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
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @To_date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date) 	
		end
		
		
	select distinct  Tran_ID,EI.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,EI.For_Date,isnull(dbo.F_Return_HHMM(EI.Out_Time),'') as Out_Time	
			,isnull(dbo.F_Return_HHMM(EI.In_Time),'') as In_Time
	 from T0150_EMP_Training_INOUT_RECORD EI  WITH (NOLOCK) Inner join
		  T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = EI.Emp_ID
	 where  EI.For_date >= @From_Date and  EI.For_Date <= @To_date
				and EI.Cmp_ID = @cmp_ID
	order by EM.Alpha_Emp_Code,EI.For_date
END

