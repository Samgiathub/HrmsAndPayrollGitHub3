




--zalak for lta setting
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_LM_SETTING]
			 @Row_ID	numeric(18,0) output
			,@Cmp_ID	numeric(18,0)
			,@Branch_id	numeric(18,0)
			,@for_date datetime
			,@start_date	datetime
			,@end_date	datetime
			,@Max_limit	numeric(18,2)
			,@Type_ID	int
			,@Effective_month	varchar(20)
			,@Effect_on_CTC	int
			,@Cal_amount_Type	int
			,@Show_Yearly	int
			,@tran_type char
			,@Is_All_Branch_Setting int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	declare @cursor_Branch_ID numeric
	
	
	--'Alpesh 18-Oct-2011 To give Default Setting to All branch
	If @Is_All_Branch_Setting = 1
	begin
		
		declare cur1 cursor for Select Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID
		open cur1
		
		fetch next from cur1 into @cursor_Branch_ID
		while @@fetch_status = 0
		begin
			Delete from T0040_LM_SETTING  Where Cmp_ID = @Cmp_ID and Branch_id=@cursor_Branch_ID and Type_ID=@Type_ID and
											((@start_date >= start_date and @start_date <= end_date) or 
											(@end_date >= start_date and 	@end_date <= end_date) or 
											(start_date >= @start_date and start_date <= @end_date) or
											(end_date >= @start_date and end_date <= @end_date))
			
			select @Row_ID = isnull(max(Row_ID),0) + 1 from T0040_LM_SETTING WITH (NOLOCK)
											
			insert into T0040_LM_SETTING
						(Row_ID
						 ,Cmp_ID
						,Branch_id
						,for_Date
						,start_date
						,end_date
						,Max_limit
						,Type_ID
						,Effective_month
						,Effect_on_CTC
						,Cal_amount_Type
						,Show_Yearly
						) 
					values
					(@Row_ID
						 ,@Cmp_ID
						,@cursor_Branch_ID
						,@for_Date
						,@start_date
						,@end_date
						,@Max_limit
						,@Type_ID
						,@Effective_month
						,@Effect_on_CTC
						,@Cal_amount_Type
						,@Show_Yearly
					) 
		
			fetch next from cur1 into @cursor_Branch_ID
		end
		
		close cur1
		deallocate cur1
	end
else
	begin
	
	if Upper(@tran_type) ='I' 
		begin
		
			if exists (Select Row_ID  from T0040_LM_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Branch_id=@Branch_id and Type_ID=@Type_ID and
											((@start_date >= start_date and @start_date <= end_date) or 
											(@end_date >= start_date and 	@end_date <= end_date) or 
											(start_date >= @start_date and start_date <= @end_date) or
											(end_date >= @start_date and end_date <= @end_date)))
			
				begin
						RAISERROR ('Record already exists for given period' , 16, 2) 
						Return
						--select @Row_ID = Row_ID from T0040_LM_SETTING Where Cmp_ID = @Cmp_ID and Branch_id=@Branch_id and for_date=@for_date and Type_ID=@Type_ID
						--Update T0040_LM_SETTING 
						-- Set	Max_limit=@Max_limit
						--	,start_date=@start_date
						--	,end_date=@end_date
						--	,Type_ID=@Type_ID
						--	,Effective_month=@Effective_month
						--	,Effect_on_CTC=@Effect_on_CTC
						--	,Cal_amount_Type=@Cal_amount_Type
						--	,Show_Yearly=@Show_Yearly
						--Where Row_ID=@Row_ID
						--RETURN 
				end
				
					select @Row_ID = isnull(max(Row_ID),0) + 1 from T0040_LM_SETTING WITH (NOLOCK)
						
					insert into T0040_LM_SETTING
						(Row_ID
						 ,Cmp_ID
						,Branch_id
						,for_Date
						,start_date
						,end_date
						,Max_limit
						,Type_ID
						,Effective_month
						,Effect_on_CTC
						,Cal_amount_Type
						,Show_Yearly
						) 
					values
					(@Row_ID
						 ,@Cmp_ID
						,@Branch_id
						,@for_Date
						,@start_date
						,@end_date
						,@Max_limit
						,@Type_ID
						,@Effective_month
						,@Effect_on_CTC
						,@Cal_amount_Type
						,@Show_Yearly
					) 

		end 
	else if upper(@tran_type) ='U' 
		begin
				
				Update T0040_LM_SETTING 
				Set		Max_limit=@Max_limit
						,start_date=@start_date
						,end_date=@end_date
						,Type_ID=@Type_ID
						,Effective_month=@Effective_month
						,Effect_on_CTC=@Effect_on_CTC
						,Cal_amount_Type=@Cal_amount_Type
						,Show_Yearly=@Show_Yearly
						
				where Row_ID = @Row_ID
		end	
	else if upper(@tran_type) ='D'
		Begin
			delete  from T0040_LM_SETTING where Row_ID=@Row_ID 
		end
			
	end
	RETURN




