



---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_RETURN_PT_AMOUNT]
(
	@Calculated_Amount	numeric ,
	@Cmp_ID				numeric,
	@Emp_ID				numeric,
	@Branch_ID			numeric,
	@For_Date			Datetime
)  
RETURNS @RtnValue table 
(
	Emp_ID		numeric,
	PT_Amount	numeric
) 
AS  
BEGIN 
	Declare @Cnt int
	Declare @PT_Amount int
	declare @PT_F_T_LIMIT varchar(30)
	Set @Cnt = 1

	declare @From_Limit as numeric(27,0)
	declare @To_Limit as numeric(27,0)
	declare @PT_Amt as numeric(27,0)
	
	set @PT_Amount = 0
	set @From_Limit = 0
	set @To_Limit = 0
	set @PT_Amt = 0 
	
	if @Branch_ID = 0
		set @Branch_ID = null
	
 
	
		if exists(select Cmp_ID from T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)))
			begin
							
				declare curPT cursor for
				select from_limit,to_limit,Amount from T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0))
				and For_date = (
				select max(For_Date) from T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)))
				order by row_id
			end
		else
			begin
							
				declare curPT cursor for
				select from_limit,to_limit,Amount from T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
				and For_date = (
				select max(For_Date) from T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date )
				order by row_id
			end
			
	open curPT
	fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt
		while @@fetch_status = 0
			begin
				
				if @To_Limit = 0 
					begin
						if @Calculated_Amount >= @from_limit 
							BEGIN
								set @PT_Amount = @Pt_Amt
								SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
							END
					end 
				else	
					begin
						if @Calculated_Amount >= @from_limit  and @Calculated_Amount < (@To_Limit + 1)
							BEGIN
								set @PT_Amount = @Pt_Amt
								SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
							END 
					end
			
				fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt					
			end
	close curPT
	deallocate curPT

	
	
	Insert Into @RtnValue (Emp_ID,PT_Amount)
	select @Emp_ID,@PT_Amount

	Return
END




