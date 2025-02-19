



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LST_AMOUNT]
	@CMP_ID					NUMERIC ,
	@EMP_ID					NUMERIC ,
	@FOR_DATE				DATETIME ,
	@LST_CALCULATED_AMOUNT	NUMERIC,
	@LST_AMOUNT				NUMERIC OUTPUT ,
	@LST_F_T_LIMIT			VARCHAR(20) OUTPUT,
	@Branch_ID				numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @From_Limit as numeric(27,0)
	declare @To_Limit as numeric(27,0)
	declare @LST_Amt as numeric(27,0)
	
	set @LST_Amount = 0
	set @From_Limit = 0
	set @To_Limit = 0
	set @LST_Amt = 0 
	
	if @Branch_ID = 0
		set @Branch_ID = null
	
	if exists(select Cmp_ID from t0040_local_service_tax_master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)))
		begin
			declare curLST cursor for
				select from_limit,to_limit,Amount from t0040_local_service_tax_master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0))
				and For_date = (
				select max(For_Date) from t0040_local_service_tax_master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)))
				order by row_id
		end
	else
		begin
			declare curLST cursor for
				select from_limit,to_limit,Amount from t0040_local_service_tax_master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_date = (
				select max(For_Date) from t0040_local_service_tax_master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date )
				order by row_id
		end
	open curLST
	fetch next from curLST into @From_Limit,@To_Limit,@LST_Amt
		while @@fetch_status = 0
			begin
				
				if @To_Limit = 0 
					begin
						if @LST_CALCULATED_AMOUNT >= @from_limit 
							BEGIN
								set @LST_Amount = @LST_Amt
								SET @LST_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
							END
					end 
				else	
					begin
						if @LST_CALCULATED_AMOUNT >= @from_limit  and @LST_CALCULATED_AMOUNT < (@To_Limit + 1)
							BEGIN
								set @LST_Amount = @LST_Amt
								SET @LST_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
							END 
					end
			
				fetch next from curLST into @From_Limit,@To_Limit,@LST_Amt					
			end
	close curLST
	deallocate curLST
		
	RETURN




