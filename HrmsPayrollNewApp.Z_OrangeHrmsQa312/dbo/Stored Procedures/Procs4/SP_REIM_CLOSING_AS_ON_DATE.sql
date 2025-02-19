
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_REIM_CLOSING_AS_ON_DATE]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FOR_DATE	DATETIME = null,
	@RC_ID numeric,
	@Return_Type numeric = 0
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		if Isnull(@For_Date,'') = '' 
			begin
				select @For_Date = max(For_Date) From T0140_ReimClaim_Transacation WITH (NOLOCK)  where Emp_ID = @Emp_ID
			end
		
		--Ripal 07July2014 Strat
		Declare @SalaryMaxDate as datetime 
		Declare @TotalUnpaid as numeric(18,2) 
		Declare @LastCurruntMonth as datetime 
		 
		 SET @TotalUnpaid = 0.0
		 SET @LastCurruntMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0))
		  
		select @SalaryMaxDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(max(month_St_Date))-1),max(month_St_Date)),106)
			from T0200_Monthly_Salary WITH (NOLOCK)
			group by  cmp_ID,emp_id
			Having cmp_ID = @CMP_ID and emp_id = @Emp_ID
		
		if @SalaryMaxDate is Null
			Begin
				select	@SalaryMaxDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(Date_Of_Join)-1),Date_Of_Join),106)		
						from T0080_EMP_MASTER WITH (NOLOCK)
						where cmp_ID = @CMP_ID and emp_id = @Emp_ID
			End
		Else
			Begin
				set @SalaryMaxDate = dateadd(mm,1,@SalaryMaxDate)
			End

		
		
		Select @TotalUnpaid = sum(Apr_Amount + Taxable_Exemption_Amount) 
			FROM T0120_RC_Approval WITH (NOLOCK)
			where cmp_ID = @CMP_ID and emp_id = @EMP_ID and RC_ID = @RC_ID and APR_Status = 1 And
				Payment_date between @SalaryMaxDate and @LastCurruntMonth and RC_Apr_Effect_In_Salary =1
		--Ripal 07July2014 End


		
		Declare @Setting_Value as tinyint -- Added by Gadriwala Muslim 22062015
			set @Setting_Value = 0
			select @Setting_Value = Setting_Value from T0040_Setting WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and setting_Name = 'Monthly base get reimbursement claim amount'	
	
		if @Setting_Value = 1  --Added by Gadriwala Muslim 22062015 
			begin
				Declare @Reim_Closing numeric(18,2)
				set @Reim_Closing = 0
				
				select @Reim_Closing = isnull(Reim_Closing,0)FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
				(SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
				WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
				GROUP BY EMP_ID,RC_ID) Q 
				ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE 
				where LT.RC_ID=@RC_ID order by  lt.Reim_Tran_ID desc
				
				If @TotalUnpaid > @Reim_Closing
					set @TotalUnpaid = @Reim_Closing 
			end
		
		---Ripal 03 Jan 2014 Start
		
		--Added By Jimit 09032018
		if  @Return_Type = 1 
			 begin         
					Insert  Into #Reim_Closing
					SELECT	top 1 lt.Reim_Tran_ID,LT.Emp_ID,aD_Name,Reim_Opening,
							(
								SELECT	SUM(Reim_Credit) 
								FROM	T0140_ReimClaim_Transacation LT WITH (NOLOCK)  INNER JOIN  
										(
											SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
											WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
											GROUP BY EMP_ID,RC_ID
										 ) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
								where LT.RC_ID = @RC_ID
							 ) Reim_Credit,
							 (	
								(
									SELECT SUM(Reim_Debit) 
									FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
										(
											SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
											WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
											GROUP BY EMP_ID,RC_ID
										) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
									where LT.RC_ID=@RC_ID
								  ) + isnull(@TotalUnpaid,0.0)
							 ) Reim_Debit,										
							 (Reim_Closing - isnull(@TotalUnpaid,0.0)) Reim_Closing,lt.For_Date							
					FROM	T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
							(
								SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
								WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
								GROUP BY EMP_ID,RC_ID
							) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE INNER JOIN 
							T0050_AD_Master LM WITH (NOLOCK) ON LT.RC_ID = LM.AD_ID
					where	LT.RC_ID=@RC_ID order by  lt.Reim_Tran_ID desc
				end				
		---Ended
		else
			begin 	
					 SELECT top 1 lt.Reim_Tran_ID,LT.Emp_ID,aD_Name,Reim_Opening,
							(
								SELECT	SUM(Reim_Credit) 
								FROM	T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
										(
											SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
											WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
											GROUP BY EMP_ID,RC_ID
										 ) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
								where LT.RC_ID = @RC_ID
							 ) Reim_Credit,
							 (	
								(
									SELECT SUM(Reim_Debit) 
									FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
										(
											SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
											WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
											GROUP BY EMP_ID,RC_ID
										) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE
									where LT.RC_ID=@RC_ID
								  ) + isnull(@TotalUnpaid,0.0)
							 ) Reim_Debit,										
							 (Reim_Closing - isnull(@TotalUnpaid,0.0)) Reim_Closing,lt.For_Date							
					 FROM	T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN  
							(
								SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
								WHERE EMP_ID = @Emp_ID AND FOR_DATE <= @FOR_DATE AND RC_ID = @RC_ID
								GROUP BY EMP_ID,RC_ID
							) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND LT.FOR_DATE = Q.FOR_DATE INNER JOIN 
							T0050_AD_Master LM WITH (NOLOCK) ON LT.RC_ID = LM.AD_ID
					 where	LT.RC_ID=@RC_ID order by  lt.Reim_Tran_ID desc
				end
				
		---Ripal 03 Jan 2014 End
		
		
		--Declare @Temp table
	  --(
	  --  Emp_ID numeric(18,2),
	  --  AD_Name varchar(255),
	  --  Reim_Opening numeric(18,2),
	  --  Reim_Closing numeric(18,2),
	  --  Reim_Debit numeric(18,2),
	  --  Reim_Credit numeric(18,2)
	    
	  --)
	  --insert into @Temp
		
		--Comment By Ripal 03Jan2014 Start
		--SELECT LT.Emp_ID,aD_Name,Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing FROM T0140_ReimClaim_Transacation LT INNER JOIN  
		--(SELECT MAX(FOR_dATE) FOR_DATE , RC_ID,EMP_ID FROM T0140_ReimClaim_Transacation 
		--WHERE EMP_ID = @Emp_ID AND FOR_DATE <=@FOR_DATE AND RC_ID =@RC_ID
		--GROUP BY EMP_ID,RC_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.RC_ID = Q.RC_ID AND 
		--LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0050_AD_Master LM ON LT.RC_ID = LM.AD_ID
		--where LT.RC_ID=@RC_ID
		--Comment By Ripal 03Jan2014 End
			
	RETURN

