CREATE PROCEDURE [dbo].[SP_CALCULATE_CLAIM_TRANSACTION]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC ,
	@FOR_DATE		DATETIME ,
	@SALARY_TRAN_ID	NUMERIC ,
	--@MANUAL_CLAIM	NUMERIC,
	@Month_St_Date datetime,
	@Month_End_Date datetime,		
	--@IS_CLAIMDEDU	NUMERIC, -- (0 ,1)
	@Rounding Numeric= 1,
	@Tran_Type varchar(20),
	@Exceed_Flag tinyint = 0  --Added by Jaina 13-10-2020
	
AS
	SET NOCOUNT ON 
	
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
	
	
	declare @for_Date_New datetime
	
	declare @CLAIM_Tran_ID numeric(18,0)
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

	
	--SELECT @Return_Amount=Claim_Closing from T0140_CLAIM_transaction where Emp_ID=@EMP_ID and cmp_id=@CMP_ID 
	
	--select @TotCLAIM_Closing = isnull(sum(CLAIM_Closing),0) from T0140_CLAIM_transaction where emp_Id = @emp_id 
	--and Cmp_ID = @Cmp_ID and for_date in (select max(for_date) from T0140_CLAIM_transaction
	--			where emp_Id = @emp_Id  and  Cmp_ID = @Cmp_ID 
	--	and for_date <= @FOR_DATE group by CLAIM_id )
	if @Tran_Type='I'
	begin
	
		declare CurClaim cursor for 
		
		--select CT.Claim_ID,CT.for_Date,CT.Claim_Closing from T0140_Claim_Transaction CT inner join T0130_CLAIM_APPROVAL_DETAIL CAD on CAD.Claim_Apr_Date=CT.For_Date left join T0120_CLAIM_APPROVAL CA on CA.Emp_ID=CT.Emp_ID  where CT.emp_id=@emp_id and CT.cmp_id=@cmp_id and CA.Claim_Apr_Date<=@Month_End_Date and CA.Claim_Apr_Date>=@Month_St_Date
		--select CT.Claim_ID,CT.for_Date,CT.Claim_Closing from T0140_Claim_Transaction CT inner join T0130_CLAIM_APPROVAL_DETAIL CAD on CAD.Claim_Apr_Date=CT.For_Date inner join T0120_CLAIM_APPROVAL CA on CA.Claim_Apr_ID=CAD.Claim_Apr_ID where CT.emp_id=@emp_id and CT.cmp_id=@cmp_id and CA.Claim_Apr_Date<=@Month_End_Date and CA.Claim_Apr_Date>=@Month_St_Date
		SELECT DISTINCT CT.CLAIM_ID, CT.FOR_DATE,CT.CLAIM_CLOSING 
		FROM  T0140_CLAIM_TRANSACTION AS CT WITH(NOLOCK) INNER JOIN 
			  T0130_CLAIM_APPROVAL_DETAIL AS CAD WITH(NOLOCK) ON CAD.CLAIM_APR_DATE = CT.FOR_DATE  INNER JOIN 
			  T0120_CLAIM_APPROVAL AS CA  WITH(NOLOCK) ON CA.CLAIM_APR_ID = CAD.CLAIM_APR_ID  AND CT.EMP_ID=CA.EMP_ID AND CT.CLAIM_ID=CAD.CLAIM_ID INNER JOIN
			  T0040_CLAIM_MASTER CLM WITH(NOLOCK) ON CLM.CLAIM_ID = CAD.CLAIM_ID
	    WHERE CT.EMP_ID=@EMP_ID AND CT.CMP_ID=@CMP_ID AND CA.CLAIM_APR_DATE<=@MONTH_END_DATE AND CA.CLAIM_APR_DATE>=@MONTH_ST_DATE
			 AND CLM.CLAIM_APR_DEDUCT_FROM_SAL=1
			 AND CLM.BEYOND_MAX_LIMIT_DEDUCT_IN_SALARY = @Exceed_Flag


		open CurClaim
		fetch next from CurClaim into @Claim_Id,@for_Date_New,@TotCLAIM_Closing
		while @@FETCH_STATUS=0
		begin
			select @CLAIM_Tran_ID = Isnull(Max(CLAIM_Tran_ID),0)  +1 From T0140_CLAIM_TRANSACTION
			
			--if exists(select Claim_ID from T0040_CLAIM_MASTER where Claim_Apr_Deduct_From_Sal=1 and Cmp_ID=@Cmp_ID and Claim_ID=@Claim_Id)
			--begin
				--if not exists(select * from T0140_CLAIM_TRANSACTION where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and For_Date=@for_Date_New and Claim_Return<>@TotCLAIM_Closing)
				--begin
				
				IF @TOTCLAIM_CLOSING >0
				BEGIN					
					INSERT T0140_CLAIM_TRANSACTION(CLAIM_TRAN_ID,EMP_ID,CLAIM_ID,CMP_ID,FOR_DATE,CLAIM_OPENING,CLAIM_ISSUE,CLAIM_CLOSING,CLAIM_RETURN)
					VALUES(@CLAIM_TRAN_ID,@EMP_ID,@CLAIM_ID,@CMP_ID,@MONTH_END_DATE,0,0,0,@TOTCLAIM_CLOSING) 					
				END
				--End			
			Fetch Next From curCLAIM into @Claim_Id,@for_Date_New,@TotCLAIM_Closing
		end
			close curCLAIM
			deallocate curCLAIM
			

	--if @Is_CLAIMDedu = 1 and @TotCLAIM_Closing > 0 
	--	begin
	--		set @CLAIM_Payment_Id = 0
	--		declare curCLAIM cursor for
	--			--select CLAIM_id,CLAIM_Apr_ID,CLAIM_Apr_Amount,CLAIM_apr_Deduct_From_sal
	--			-- from T0120_CLAIM_approval la  where emp_id = @emp_id and Cmp_ID = @Cmp_ID
	--			-- 	and CLAIM_Apr_pending_amount >0 	and CLAIM_apr_Date <= @FOR_DATE
	--			-- 	and Claim_Apr_Status='A'
	--			--	order by CLAIM_apr_ID
	--			select Claim_ID,Claim_Apr_Dtl_ID,Claim_Apr_Amount from T0130_CLAIM_APPROVAL_DETAIL
	--			la where emp_ID=@emp_Id and cmp_ID=@Cmp_ID and CLAIM_apr_Date <= @FOR_DATE
	--			and Claim_Status='A' order by Claim_Apr_Dtl_ID
				
	--		open curCLAIM		
	--		fetch next from curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount--,@CLAIM_apr_Deduct_From_sal 
	--		while @@fetch_status = 0
	--				begin
					
					
	--					Set		@Return_Amount = 0
	--					set @CLAIM_Inst_Amount = @CLAIM_Apr_Amount
	--					Select  @Return_Amount = Isnull(sum(CLAIM_Apr_Amnt),0) From T0230_MONTHLY_CLAIM_PAYMENT_DETAIL WHERE CLAIM_Apr_ID = @CLAIM_Apr_ID
						
	--					Set @Pending_CLAIM  = @CLAIM_Apr_Amount - @Return_Amount 
						
	--					if @CLAIM_Inst_Amount > @Pending_CLAIM and @Pending_CLAIM >0 
	--						set @CLAIM_Inst_Amount = @Pending_CLAIM
	--					else IF @Pending_CLAIM =0 
	--						set @CLAIM_Inst_Amount = 0
						
						
	--					If @ROUNDING = 1
	--					Begin
	--						set @CLAIM_Inst_Amount =  round(@CLAIM_Inst_Amount,0)
	--					End --Added by sumit 06112014
						
	--					if @CLAIM_Inst_Amount > 0 --and @CLAIM_apr_Deduct_From_sal = 1
	--						begin
							
	--							exec P0210_MONTHLY_CLAIM_PAYMENT_INSERT 0,@CLAIM_Apr_ID,@Cmp_Id,@Salary_Tran_ID,@CLAIM_Inst_Amount,'',@For_Date,'','','',''
	--						End

						
	--					Fetch Next From curCLAIM into @CLAIM_Id,@CLAIM_Apr_ID,@CLAIM_Apr_Amount--,@CLAIM_apr_Deduct_From_sal 
	--				end 			
						
	--		close curCLAIM
	--		deallocate curCLAIM
						
	--	end		
		
	--	If @ROUNDING = 1
	--	Begin
	--		set @CLAIM_Apr_Amount =  round(@CLAIM_Apr_Amount,0)
	--	End
		
		end
		else if @Tran_Type='D'
		begin
		
		delete from T0140_CLAIM_TRANSACTION where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and Claim_Return<>0 and For_Date=@Month_End_Date --and 
		
		End
		--select @CLAIM_Apr_Amount
	
	RETURN




