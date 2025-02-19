

--ALTER PROCEDURE [dbo].[SP_CALCULATE_CLAIM_PAYMENT]
--	@CMP_ID			NUMERIC ,
--	@EMP_ID			NUMERIC ,
--	@FOR_DATE		DATETIME ,
--	@SALARY_TRAN_ID	NUMERIC ,
--	@MANUAL_CLAIM	NUMERIC,
--	@IS_CLAIMDEDU	NUMERIC, -- (0 ,1)
--	@Rounding Numeric= 1
	
--AS
--	SET NOCOUNT ON 
	
--	declare @CLAIM_Id as numeric
--	declare @Pending_CLAIM as numeric(27,5)
--	declare @CLAIM_Payment_Id as numeric
--	declare @TotalInst_Amount as numeric(27,5)
--	declare @TotCLAIM_Closing as numeric(27,5)

--	declare @CLAIM_Apr_ID as numeric
--	declare @CLAIM_apr_Deduct_From_sal numeric
--	declare @Return_Amount as numeric(27,5)

--	declare @CLAIM_Apr_Amount as numeric(27,5)
--	declare @Pre_Approval_Id as numeric
--	declare @Pre_Payment_Id as numeric
--	Declare @CLAIM_Inst_Amount numeric (18,3)
--	--DECLARE @Round			Numeric      
----DECLARE @ROUNDING AS NUMERIC(18,0)

--	set @Pending_CLAIM = 0.0
--	set @TotCLAIM_Closing = 0.0
--	set @TotalInst_Amount = 0.0
--	set @CLAIM_Apr_Amount = 0.0
--	set @CLAIM_Payment_Id = 0

--	set @Return_Amount = 0.0
--	set @CLAIM_Apr_Amount =0.0
--	SET @Pre_Approval_Id = 0
--	set @Pre_Payment_Id = 0
--	SET @CLAIM_Inst_Amount = 0
----SET @ROUNDING = 1
--	declare @DelPayment_Id as numeric
--	set @DelPayment_Id = 0
--	---SET @Round		= 0 
----select @FOR_DATE

	
--	select @TotCLAIM_Closing = isnull(sum(CLAIM_Closing),0) from T0140_CLAIM_transaction where emp_Id = @emp_id 
--	and Cmp_ID = @Cmp_ID and for_date in (select max(for_date) from T0140_CLAIM_transaction
--				where emp_Id = @emp_Id  and  Cmp_ID = @Cmp_ID 
--		and for_date <= @FOR_DATE group by CLAIM_id )


--	if @Is_CLAIMDedu = 1 and @TotCLAIM_Closing > 0 
--		begin
--			set @CLAIM_Payment_Id = 0
--			declare curCLAIM cursor for
--				select CLAIM_id,CLAIM_Apr_ID,CLAIM_Apr_Amount,CLAIM_apr_Deduct_From_sal
--				 from T0120_CLAIM_approval la  where emp_id = @emp_id and Cmp_ID = @Cmp_ID
--				 	and CLAIM_Apr_pending_amount >0 	and CLAIM_apr_Date <= @FOR_DATE
--				 	and Claim_Apr_Status='A'
--					order by CLAIM_apr_ID
					
--			open curCLAIM		
--			fetch next from curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount,@CLAIM_apr_Deduct_From_sal 
--			while @@fetch_status = 0
--					begin
--						Set		@Return_Amount = 0
--						set @CLAIM_Inst_Amount = @CLAIM_Apr_Amount
--						Select  @Return_Amount = Isnull(sum(CLAIM_Pay_Amount),0) From T0210_MONTHLY_CLAIM_PAYMENT WHERE CLAIM_Apr_ID = @CLAIM_Apr_ID
						
--						Set @Pending_CLAIM  = @CLAIM_Apr_Amount - @Return_Amount 
						
--						if @CLAIM_Inst_Amount > @Pending_CLAIM and @Pending_CLAIM >0 
--							set @CLAIM_Inst_Amount = @Pending_CLAIM
--						else IF @Pending_CLAIM =0 
--							set @CLAIM_Inst_Amount = 0
						
						
--						If @ROUNDING = 1
--						Begin
--							set @CLAIM_Inst_Amount =  round(@CLAIM_Inst_Amount,0)
--						End --Added by sumit 06112014
						
--						if @CLAIM_Inst_Amount > 0 and @CLAIM_apr_Deduct_From_sal = 1
--							begin
							
--								exec P0210_MONTHLY_CLAIM_PAYMENT_INSERT 0,@CLAIM_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@CLAIM_Inst_Amount,'',@For_Date,'','','',''
--							End

						
--						Fetch Next From curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount,@CLAIM_apr_Deduct_From_sal 
--					end 			
						
--			close curCLAIM
--			deallocate curCLAIM
						
--		end		
		
--		If @ROUNDING = 1
--		Begin
--			set @CLAIM_Apr_Amount =  round(@CLAIM_Apr_Amount,0)
--		End
		
		
--		--select @CLAIM_Apr_Amount
	
--	RETURN
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_CLAIM_PAYMENT]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC ,
	@FOR_DATE		DATETIME ,
	@SALARY_TRAN_ID	NUMERIC ,
	@MANUAL_CLAIM	NUMERIC,
	@IS_CLAIMDEDU	NUMERIC, -- (0 ,1)
	@Rounding Numeric= 1
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @CLAIM_Id as numeric
	declare @Pending_CLAIM as numeric(27,5)
	declare @CLAIM_Payment_Id as numeric
	declare @TotalInst_Amount as numeric(27,5)
	declare @TotCLAIM_Closing as numeric(27,5)

	declare @CLAIM_Apr_ID as numeric
	declare @CLAIM_apr_Deduct_From_sal numeric
	declare @Return_Amount as numeric(27,5)

	declare @CLAIM_Apr_Amount as numeric(27,5)
	declare @Pre_Approval_Id as numeric
	declare @Pre_Payment_Id as numeric
	Declare @CLAIM_Inst_Amount numeric (18,3)
	--DECLARE @Round			Numeric      
--DECLARE @ROUNDING AS NUMERIC(18,0)

	set @Pending_CLAIM = 0.0
	set @TotCLAIM_Closing = 0.0
	set @TotalInst_Amount = 0.0
	set @CLAIM_Apr_Amount = 0.0
	set @CLAIM_Payment_Id = 0

	set @Return_Amount = 0.0
	set @CLAIM_Apr_Amount =0.0
	SET @Pre_Approval_Id = 0
	set @Pre_Payment_Id = 0
	SET @CLAIM_Inst_Amount = 0
--SET @ROUNDING = 1
	declare @DelPayment_Id as numeric
	set @DelPayment_Id = 0
	---SET @Round		= 0 
--select @FOR_DATE

	
	select @TotCLAIM_Closing = isnull(sum(CLAIM_Closing),0) from T0140_CLAIM_transaction WITH (NOLOCK) where emp_Id = @emp_id 
	and Cmp_ID = @Cmp_ID and for_date in (select max(for_date) from T0140_CLAIM_transaction WITH (NOLOCK)
				where emp_Id = @emp_Id  and  Cmp_ID = @Cmp_ID 
		and for_date <= @FOR_DATE group by CLAIM_id )

print 'cc'
	if @Is_CLAIMDedu = 1 and @TotCLAIM_Closing > 0 
		begin
			set @CLAIM_Payment_Id = 0
			declare curCLAIM cursor for
				--select CLAIM_id,CLAIM_Apr_ID,CLAIM_Apr_Amount,CLAIM_apr_Deduct_From_sal
				-- from T0120_CLAIM_approval la  where emp_id = @emp_id and Cmp_ID = @Cmp_ID
				-- 	and CLAIM_Apr_pending_amount >0 	and CLAIM_apr_Date <= @FOR_DATE
				-- 	and Claim_Apr_Status='A'
				--	order by CLAIM_apr_ID
				select Claim_ID,Claim_Apr_Dtl_ID,Claim_Apr_Amount from T0130_CLAIM_APPROVAL_DETAIL 
				la WITH (NOLOCK) where emp_ID=@emp_Id and cmp_ID=@Cmp_ID and CLAIM_apr_Date <= @FOR_DATE
				and Claim_Status='A' order by Claim_Apr_Dtl_ID
				
			open curCLAIM		
			fetch next from curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount--,@CLAIM_apr_Deduct_From_sal 
			while @@fetch_status = 0
					begin
					
					
						Set		@Return_Amount = 0
						set @CLAIM_Inst_Amount = @CLAIM_Apr_Amount
						Select  @Return_Amount = Isnull(sum(CLAIM_Apr_Amnt),0) From T0230_MONTHLY_CLAIM_PAYMENT_DETAIL WITH (NOLOCK) WHERE CLAIM_Apr_ID = @CLAIM_Apr_ID
						
						Set @Pending_CLAIM  = @CLAIM_Apr_Amount - @Return_Amount 
						
						if @CLAIM_Inst_Amount > @Pending_CLAIM and @Pending_CLAIM >0 
							set @CLAIM_Inst_Amount = @Pending_CLAIM
						else IF @Pending_CLAIM =0 
							set @CLAIM_Inst_Amount = 0
						
						
						If @ROUNDING = 1
						Begin
							set @CLAIM_Inst_Amount =  round(@CLAIM_Inst_Amount,0)
						End --Added by sumit 06112014
						
						if @CLAIM_Inst_Amount > 0 --and @CLAIM_apr_Deduct_From_sal = 1
							begin
							
								exec P0210_MONTHLY_CLAIM_PAYMENT_INSERT 0,@CLAIM_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@CLAIM_Inst_Amount,'',@For_Date,'','','',''
							End

						
						Fetch Next From curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount--,@CLAIM_apr_Deduct_From_sal 
					end 			
						
			close curCLAIM
			deallocate curCLAIM
						
		end		
		
		If @ROUNDING = 1
		Begin
			set @CLAIM_Apr_Amount =  round(@CLAIM_Apr_Amount,0)
		End
		
		
		--select @CLAIM_Apr_Amount
	
	RETURN




