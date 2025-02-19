


CREATE PROCEDURE [dbo].[SP_GET_LATE_EARLY_SLABWISE]
	@CMP_ID					NUMERIC ,
	@GEN_ID					NUMERIC ,
	@VALUE					VARCHAR(10),
	@SLAB_VALUE				NUMERIC(3,1) OUTPUT ,
	@Branch_ID				numeric = 0
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	DECLARE @From_Limit	NUMERIC(9,1)
	DECLARE @To_Limit	NUMERIC(9,1)
	DECLARE @Deduction_Day AS NUMERIC(9,1)
	DECLARE @Temp_Val	NUMERIC(9,2)
	
	SET @Temp_Val = CAST(REPLACE(@VALUE,':','.') AS NUMERIC(18,2))
		
	SET @SLAB_VALUE = 0
	SET @From_Limit = 0
	SET @To_Limit = 0
	SET @deduction_day = 0 
	
	IF @Branch_ID = 0
		SET @Branch_ID = null
		
	--Added Query in place of following cursor to get value from record faster.
	--Nimesh on 27-Jan-2016
	SELECT	TOP 1 @SLAB_VALUE = Deduction_Days 
	FROM	T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK)
	WHERE	GEN_Id = @GEN_ID and Slab_Type = 'P'	
			AND (CASE WHEN To_hours = 0 AND @temp_Val >= From_hours 
					THEN 1 
				 WHEN To_hours > 0 AND @temp_val >= From_hours and @temp_val < (To_hours + 1)
					THEN 1
				ELSE 
					0
				END)  = 1
	
	/*Commented By Nimesh ON 27-Jan-2016	
	declare curLE cursor for
		select from_hours,to_hours,deduction_days from T0050_GENERAL_DETAIL_SLAB where GEN_Id = @GEN_ID and Slab_Type = 'P'	
	open curLE
	fetch next from curLE into @From_Limit,@To_Limit,@deduction_day
		while @@fetch_status = 0
			begin					
				if @To_Limit = 0 
					begin					
						if @temp_val >= @from_limit 
							BEGIN																
								set @SLAB_VALUE = @deduction_day								
							END
					end 
				else	
					begin
						if @temp_val >= @from_limit  and @temp_val < (@To_Limit + 1)
							BEGIN												
								set @SLAB_VALUE = @deduction_day								
							END 
					end
			
				fetch next from curLE into @From_Limit,@To_Limit,@deduction_day					
			end
	close curLE
	deallocate curLE
	*/
	RETURN




