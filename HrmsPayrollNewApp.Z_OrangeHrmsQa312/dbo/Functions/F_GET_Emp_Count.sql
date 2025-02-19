




CREATE FUNCTION [DBO].[F_GET_Emp_Count] 
	(
		@Cmp_Id as numeric,
		@From_date as datetime,
		@To_date as datetime
	)
RETURNS Varchar(10)
AS
		begin
			Declare @emp_count numeric
			
			 select @emp_count = count(emp_id) from V_Emp_Cons where 
		     cmp_id=@Cmp_ID 
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_date  >= join_Date  and @To_date <= left_date )      
						or (Left_date is null and @To_date >= Join_Date)      
						or (@To_date >= left_date  and  @From_Date <= left_date )) 
			
			RETURN @emp_count 
		end




