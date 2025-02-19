




----------------------------------------------------------------------------------------------
--ALTER BY:
--Modified By :
--Description:
--Notes :  Please dont put the Select @Emp_Id like that...
--Late Modified and Review Please Put Comments
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
----------------------------------------------------------------------------------------------



CREATE PROCEDURE [dbo].[SP_IT_TAX_PT_CALCULATION]
	@EMP_ID			NUMERIC,
	@COMPANY_ID		NUMERIC,
	@BASIC_SALARY	NUMERIC(18),
	@PT_AMOUNT		NUMERIC OUTPUT
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
			Declare @PT_Calculated_Amount numeric 
			Declare @From_Limit numeric 
			Declare @To_Limit	numeric
			Declare @PT_Amt		numeric 
			
			set @PT_Calculated_Amount = 0
			set @PT_Amt	 =0
			
		/*	
			select @PT_Calculated_Amount = isnull(sum(Amount),0) from #AD_DETAIL WHERE EMP_iD=@emp_ID and Is_not_Effect_PT <>'Y'
			
			
			
			declare curPT cursor for
				select from_limit,to_limit,pt_amount from pt_setting where company_id = @company_id order by row_id
			open curPT
			fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt
				while @@fetch_status = 0
					begin
						if @To_Limit = 0 
							begin
								if @PT_Calculated_Amount >= @from_limit 
									set @PT_Amount = @Pt_Amt
							end 
						else	
							begin
								if @PT_Calculated_Amount >= @from_limit  and @PT_Calculated_Amount < (@To_Limit + 1)
									set @PT_Amount = @Pt_Amt
							end
					
						fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt					
					end
			close curPT
			deallocate curPT
			*/	
	RETURN




