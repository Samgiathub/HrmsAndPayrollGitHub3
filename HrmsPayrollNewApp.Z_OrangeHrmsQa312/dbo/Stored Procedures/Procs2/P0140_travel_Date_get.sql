

--exec P0140_travel_Date_get 2,22
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_travel_Date_get]
	@Cmp_ID				NUMERIC(18,0)
	,@travel_Approval_id 	NUMERIC(18,0)	
	,@int_Exp_ID numeric(18,0)=0
	
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	Declare @Start_Date As Datetime
	Declare @End_Date As Datetime
	declare @isnotpreedate as tinyint --=0
	
	SET @isnotpreedate = 0 --changed jimit 18042016
	
	 declare @Temp_Date table
	 (For_Date Datetime )	
	if @int_Exp_ID<>0 --Added by Sumit 30092015
	Begin
		select @isnotpreedate= is_not_pree_post_date from T0040_Expense_Type_Master WITH (NOLOCK) where CMP_ID=@Cmp_ID and Expense_Type_ID=@int_Exp_ID	
	End
	
--	select @Start_Date = From_Date , @End_Date = To_Date from T0130_TRAVEL_APPROVAL_DETAIL where Cmp_ID=@Cmp_ID and travel_Approval_id = @travel_Approval_id order by From_Date
--Declare Cur_HO cursor Fast_forward for
--select From_Date - 1 ,To_Date + 1 from T0130_TRAVEL_APPROVAL_DETAIL where Cmp_ID=@Cmp_ID and travel_Approval_id = @travel_Approval_id order by From_Date
if (@isnotpreedate=0)
	Begin
		Declare Cur_HO cursor Fast_forward for
		select From_Date - 1 ,To_Date + 1 from T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and travel_Approval_id = @travel_Approval_id order by From_Date
	End
Else if (@isnotpreedate=1)
	Begin
		Declare Cur_HO cursor Fast_forward for
		select From_Date  ,To_Date  from T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and travel_Approval_id = @travel_Approval_id order by From_Date
	End
----Added by Sumit 30092015

open Cur_HO
fetch next from Cur_HO into @Start_Date,@End_Date

While @@Fetch_Status=0
	   begin

			WHILE (@Start_Date <=@End_Date)
			BEGIN

			if not exists( select 1 from @Temp_Date where For_Date = @Start_Date)
			BEGIN
				insert into @Temp_Date (for_date)
				values (@Start_Date)
			END	

			SET @Start_Date = @Start_Date + 1
			END
	
	 fetch next from Cur_HO into @Start_Date,@End_Date
	  end        
	close Cur_HO        
	Deallocate Cur_HO  
	
	select convert(varchar,For_Date,103) as For_Date from @Temp_Date
END


