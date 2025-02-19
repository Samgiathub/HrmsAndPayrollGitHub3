
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[CALCULATE_SHIFT_ALLOWANCE]
	@Cmp_id numeric,
	@Emp_id numeric,
	@from_date datetime,
	@to_date datetime,
	@Allow_Amount numeric(18,2) output,
	@Ad_Id  numeric(18,0) = 0  --Added by Jaina 20-04-2018
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	set @Allow_Amount = 0
	declare @temp_curr_date datetime
	declare @shift_id numeric
    set @temp_curr_date	= @from_date
    set @shift_id = 0 
    
    
    IF  OBJECT_ID('tempdb..#data') Is Null
		begin 
			return
		end
    
    
   Declare @Shift_Count as numeric 
   Declare @Rate as Numeric(18,2)
   Declare @Minimum_Count as Numeric(18,2)
   declare @StrHoliday_Date as varchar(500) -- Added by rohit for holiday present in shift calculation on 31082016
   declare @Holiday_Days as numeric(18,2)
   declare @StrWeekoff_Date as varchar(500)
   declare @Weekoff_Days as numeric(18,2)
   
   	Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_date,Null,Null,0,@StrHoliday_Date output,@Holiday_Days output,Null,0,0,''
	Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_date,null,null,9,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,Null
	
	Declare curShift cursor for
		--SELECT  Shift_Id, Count(SHIFT_ID) As Shift_count FROM #DATA WHERE P_DAYS = 1 and Emp_Id = @Emp_Id group by Shift_id
		-- Deepal Add the HF day in below where condition Ticket ID 16573
		SELECT  Shift_Id, Count(SHIFT_ID) As Shift_count 
		FROM	#DATA 
		WHERE	(P_DAYS in (1,0.5) or For_Date in (select  cast(data  as varchar(max)) from dbo.Split (@StrHoliday_Date,';')) or For_Date in (select cast(data as varchar(max))from dbo.Split(@StrWeekoff_Date,';'))) and Emp_Id = @Emp_Id 
		group by Shift_id -- changed by rohit for holiday shift calculate on 30082016
	open curShift
	fetch next from curShift into @shift_id,@Shift_Count
	while @@fetch_status = 0
		begin			
		
			if exists (SELECT 1 from T0100_SHIFT_ALLOWANCE_RATE WITH (NOLOCK) where Ad_Id=@Ad_Id and Cmp_id =@Cmp_Id and Shift_id=@shift_id)
				BEGIN

					SELECT @Rate  = isnull(Rate,0), @Minimum_Count = ISNULL(Minimum_Count,0) 
					FROM T0100_SHIFT_ALLOWANCE_RATE WITH (NOLOCK) WHERE Shift_id  = @shift_id AND Ad_Id = @ad_id and   --Ad_id condition added by Jaina 28-05-2018
						Effective_Date = (SELECT MAX(Effective_Date) 
										  FROM T0100_SHIFT_ALLOWANCE_RATE SA WITH (NOLOCK)
												left OUTER JOIN T0050_AD_MASTER A WITH (NOLOCK) ON SA.Ad_Id = A.AD_ID   --Added by Jaina 20-04-2018
										  WHERE Shift_id = @shift_id AND Effective_Date <= @to_date
												AND A.AD_CALCULATE_ON = 'Shift Wise' AND SA.AD_ID = @Ad_Id)
																					
				
				END		
			else
				begin
					--select @Allow_Amount,@Shift_Count,@Rate
					SELECT @Rate  = isnull(Rate,0), @Minimum_Count = ISNULL(Minimum_Count,0) 
					FROM T0100_SHIFT_ALLOWANCE_RATE WITH (NOLOCK) WHERE Shift_id  = @shift_id AND 
						Effective_Date = (SELECT MAX(Effective_Date) 
										  FROM T0100_SHIFT_ALLOWANCE_RATE SA WITH (NOLOCK)																							
										  WHERE Shift_id = @shift_id AND Effective_Date <= @to_date and SA.Ad_Id = 0)
												
				end	  
					 	 				 
			
			
			If @Minimum_Count > 0 
			-- Deepal Add the = to below condition Ticket ID 16573
				If @Shift_Count >= @Minimum_Count
					Begin
						Set @Allow_Amount = @Allow_Amount + (@Shift_Count * @Rate)
					End
				Else
					Begin
						Set @Allow_Amount = @Allow_Amount + 0
					End
			Else
				Begin
					print @Shift_Count
					Set @Allow_Amount = @Allow_Amount + (@Shift_Count * @Rate)
				End
		
			---Commented by Hardik 27/02/2015 to check Eligible Count
			
			--if exists (SELECT isnull(Rate,0) FROM T0100_SHIFT_ALLOWANCE_RATE WHERE Shift_id  = @shift_id AND 
			--Effective_Date = (SELECT MAX(Effective_Date) FROM T0100_SHIFT_ALLOWANCE_RATE WHERE Shift_id = @shift_id AND Effective_Date <= @FROM_DATE ) AND Is_Emp_Rate = 0)
			--	begin
			--		SELECT @Allow_Amount = @Allow_Amount + isnull(Rate,0) FROM T0100_SHIFT_ALLOWANCE_RATE WHERE Shift_id  = @shift_id AND 
			--		Effective_Date = (SELECT MAX(Effective_Date) FROM T0100_SHIFT_ALLOWANCE_RATE WHERE Shift_id = @shift_id AND Effective_Date <= @FROM_DATE ) 
			--	end
			--else
			--	begin
			--		set @Allow_Amount = @Allow_Amount + 0
			--	end	
			
			Set @Rate = 0
			Set @Minimum_Count = 0
			
			fetch next from curShift into @shift_id,@Shift_Count
		end
	close curShift
	deallocate curShift

END


