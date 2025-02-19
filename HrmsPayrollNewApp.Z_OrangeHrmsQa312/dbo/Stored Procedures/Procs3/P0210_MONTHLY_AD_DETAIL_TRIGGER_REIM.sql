
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_AD_DETAIL_TRIGGER_REIM]	
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
		DECLARE @Reim_Tran_ID	NUMERIC;
		DECLARE @M_AD_Tran_ID	NUMERIC;
		DECLARE @Cmp_ID			NUMERIC;
		DECLARE @Emp_Id			NUMERIC;
		DECLARE @RC_Id			NUMERIC;
		DECLARE @For_Date AS DATETIME;
		DECLARE @Sal_tran_id AS NUMERIC;
		DECLARE @Reim_CR_Amount AS NUMERIC (18,2);
		DECLARE @S_Sal_tran_id AS NUMERIC;
		DECLARE @Reim_Sett_CR_Amount AS NUMERIC (18,2);
		DECLARE @Last_Reim_Closing AS NUMERIC (18,2);
		DECLARE @Last_Closing AS NUMERIC (18,2);
		DECLARE @ReimShow AS NUMERIC;
		DECLARE @M_AD_Amount AS NUMERIC(18,2);
		DECLARE @M_AD_Approval_Amount AS NUMERIC(18,2);
		DECLARE @For_FNF AS NUMERIC(18,2);
		DECLARE @Setting_Value AS TINYINT; -- Added by Gadriwala Muslim 22062015
		DECLARE @Actual_Debit NUMERIC(18,2); -- Added by Gadriwala Muslim 22062015
		DECLARE @Claim_Debit NUMERIC(18,2);-- Added by Gadriwala Muslim 22062015
		DECLARE @Chg_Tran_Id NUMERIC    
		DECLARE @For_Date_Cur DATETIME
		DECLARE @Pre_Closing NUMERIC(18,2) 

		SET @Last_Reim_Closing = 0;
		SET @Reim_Sett_CR_Amount = 0;
		SET @Last_Reim_Closing = 0;
		SET @Last_Closing = 0;
		SET @M_AD_Approval_Amount =0;
		SET @For_FNF = 0;
		SET @Actual_Debit = 0; -- Added by Gadriwala Muslim 22062015
		SET @Claim_Debit = 0; -- Added by Gadriwala Muslim 22062015
		SET @Setting_Value = 0; -- Added by Gadriwala Muslim 22062015

					
		/*****************************
		******FOR REIMBURSEMENT*******
		*****************************/	
		BEGIN
			
			SELECT @Reim_Tran_ID = ISNULL(MAX(Reim_Tran_ID),0) + 1 FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
			
			SELECT @Cmp_ID = ins.Cmp_ID ,@Emp_Id = ins.Emp_Id, @RC_Id = ins.AD_ID, @For_Date = ins.For_Date,@M_AD_Tran_ID = ins.M_AD_Tran_ID,
					@Sal_tran_id = IsNull(ins.Temp_Sal_Tran_ID, ins.Sal_Tran_ID), @Reim_CR_Amount = ISNULL(ins.m_ad_amount,0) + ISNULL(ins.M_AREAR_AMOUNT,0)+ ISNULL(ins.M_AREAR_AMOUNT_Cutoff,0) ,@M_AD_Approval_Amount = ISNULL(ReimAmount,0),
					@S_Sal_tran_id = ISNULL(ins.S_Sal_Tran_ID,0),@ReimShow =ins.ReimShow, @For_FNF = ins.FOR_FNF
					FROM #INSERTED ins 
					--inner join T0050_AD_MASTER AM on ins.AD_ID = AM.AD_ID 
					--where AM.AD_NOT_EFFECT_SALARY = 1 and AM.Allowance_type='R' and ins.S_Sal_Tran_ID is null
			--Added by Gadriwala Muslim 22062015
			SELECT @Setting_Value = Setting_Value FROM dbo.T0040_Setting WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND setting_Name = 'Monthly base get reimbursement claim amount'
			SET @M_AD_Amount = @Reim_CR_Amount

			IF @Setting_Value = 1  -- Added by Gadriwala Muslim 22062015
				BEGIN
				 
					IF @M_AD_Approval_Amount > 0  AND @ReimShow = 1
						BEGIN
							IF EXISTS(SELECT 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) WHERE For_Date = @For_Date AND Claim_Id = @RC_Id AND Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID )
								BEGIN
									 UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly 
									 SET Credit = Credit + @M_AD_Approval_Amount,Balance = Balance + Isnull(@M_AD_Approval_Amount,0) 
									 WHERE For_Date = @For_Date AND Claim_Id = @RC_Id AND Cmp_id = @Cmp_ID AND Emp_ID = @Emp_ID	
									 
									 UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly 
									 SET Opening = Opening + @M_AD_Approval_Amount, Balance = Balance + Isnull(@M_AD_Approval_Amount,0)
									 WHERE Claim_Id = @RC_Id AND For_Date > @For_Date AND cmp_ID = @Cmp_ID AND Emp_ID = @Emp_Id	
									 
									SET @Reim_CR_Amount = 0
									SET @M_AD_Amount = 0
								END
							ELSE
								BEGIN
									
									DECLARE @Claim_Tran_ID NUMERIC(18,2)
									SET @Claim_Tran_ID = 0
									 
									DECLARE @Sorting_ID NUMERIC(18,2)
									SET  @Sorting_ID = 0
									
									DECLARE @Balance NUMERIC(18,2)
									SET @Balance = 0
									
									SELECT @Balance = ISNULL(Balance,0) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
									WHERE for_date = (
														SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
														WHERE for_date < @For_date AND Claim_Id = @RC_Id 
														AND cmp_ID = @cmp_ID AND emp_id = @emp_Id 
													  ) 
											AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id
					
									IF @Balance IS NULL 
										SET  @Balance = 0
										
									
									SELECT  @Claim_Tran_ID = ISNULL(MAX(trans_ID),0) + 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
									
									INSERT dbo.T0140_ReimClaim_Transacation_Payment_Monthly(Trans_ID,cmp_ID,emp_id,Claim_ID,Sal_Trans_ID,For_Date,Opening,Credit,Debit,Balance)
										VALUES(@Claim_Tran_ID,@cmp_ID,@emp_id,@Rc_Id,@Sal_tran_id,@for_Date,@Balance,@M_AD_Approval_Amount,0,Isnull(@Balance,0) + Isnull(@M_AD_Approval_Amount,0))	
								END
						END
				END

		 	IF ISNULL(@For_FNF,0) = 0
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE for_date = @For_date AND emp_id = @emp_Id  AND rc_id=@RC_Id AND Cmp_ID = @Cmp_ID)
						BEGIN
							IF @Setting_Value = 1   -- Added by Gadriwala Muslim 22062015
								BEGIN
									SELECT  @Claim_Tran_ID = ISNULL(MAX(trans_ID),0) + 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
								
									IF  EXISTS( SELECT 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) WHERE Claim_Id = @RC_Id AND Cmp_ID = @Cmp_ID AND For_Date = @For_Date AND Emp_ID = @Emp_Id)
										BEGIN
											
											SELECT @Last_Closing = ISNULL(Reim_Closing,0) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
											WHERE for_date = (
												SELECT MAX(for_date) FROM T0140_ReimClaim_Transacation WITH (NOLOCK)
												WHERE for_date < @For_date AND RC_ID = @Rc_ID 
												AND cmp_ID = @cmp_ID AND emp_id = @emp_Id
											  ) AND cmp_ID = @cmp_ID AND RC_ID = @RC_ID  AND emp_id = @emp_Id
											
											IF @Last_Closing IS NULL 
											SET  @Last_Closing = 0
										
												
											SELECT @Balance = ISNULL(Balance,0) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
											WHERE for_date = (
																 SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly  WITH (NOLOCK)
																 WHERE for_date < @For_date AND Claim_Id = @RC_Id 
																 AND cmp_ID = @cmp_ID AND emp_id = @emp_Id 
															  )  AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id	
											IF @Balance IS NULL
    											SET @Balance = 0
		    								
		    								
			    							
    										IF ISNULL(@M_AD_Approval_Amount,0)  = 0 
    					   						SET @M_AD_Approval_Amount = @Balance 
    										ELSE
    											SET @M_AD_Approval_Amount = @M_AD_Approval_Amount  + @Balance
										
										
											
											IF (@Last_Closing + @Reim_CR_Amount) > @M_AD_Approval_Amount
												BEGIN
													SET @Actual_Debit =  @M_AD_Approval_Amount
													SET @Claim_Debit = @M_AD_Approval_Amount 
												END
											ELSE
												BEGIN
													SET @Actual_Debit = @Last_Closing + @Reim_CR_Amount
													SET @Claim_Debit =  @Last_Closing + @Reim_CR_Amount 	
												END
											
											
											
											IF @M_AD_Approval_Amount = 0 
												BEGIN
													SET @Actual_Debit = 0
													SET @Claim_Debit = 0
												END
											
										
											IF @Claim_Debit > 0 
												BEGIN
													UPDATE	dbo.T0140_ReimClaim_Transacation_Payment_Monthly
													SET		Debit = Debit + @Claim_Debit, Balance = Balance - @Claim_Debit
													WHERE	Claim_ID = @RC_Id AND Cmp_ID =@Cmp_ID AND For_Date =@For_Date AND Emp_ID = @Emp_Id
												END
												
											
											IF @Actual_Debit > 0 
												BEGIN	
													IF ISNULL(@S_Sal_tran_id,0) = 0 --THIS CONDITION WAS ADDED BY RAMIZ ON 07/02/2017 AS DURING SETTLEMENT REIM_CREDIT WAS GOING ZERO (0)
														BEGIN
															IF EXISTS(SELECT 1 FROM T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND RC_ID=@RC_ID AND Sal_tran_ID = @Sal_tran_id)
																BEGIN
																	UPDATE	dbo.T0140_ReimClaim_Transacation 
																	SET		Reim_Debit =  Isnull(@Actual_Debit,0) ,
																			Reim_Credit = ISNULL(@M_AD_Amount,0) ,
																			Reim_Closing = (ISNULL(Reim_Opening,0) + ISNULL(Reim_Credit + Isnull(@M_AD_Amount,0),0))  - Isnull(@Actual_Debit,0),
																			sys_date = GETDATE() ,Sal_Tran_ID = @Sal_tran_id	
																	WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
																END
															ELSE
																BEGIN
																	UPDATE	dbo.T0140_ReimClaim_Transacation 
																	SET		Reim_Debit =  Reim_Debit+ Isnull(@Actual_Debit,0) ,
																			Reim_Credit = ISNULL(@M_AD_Amount,0) ,
																			Reim_Closing = (ISNULL(Reim_Opening,0) + ISNULL(Reim_Credit + Isnull(@M_AD_Amount,0),0))  - ISNULL( Reim_Debit + Isnull(@Actual_Debit,0),0),
																			sys_date = GETDATE() ,Sal_Tran_ID = @Sal_tran_id	
																	WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
																END
														END
													ELSE
														BEGIN
															UPDATE	dbo.T0140_ReimClaim_Transacation 
															SET		Reim_Debit =  isnull(Reim_Debit,0)+ Isnull(@Actual_Debit,0) ,
																	Reim_Credit = ISNULL(Reim_Credit,0) + Isnull(@M_AD_Amount,0) ,
																	Reim_Closing = (ISNULL(Reim_Opening,0) + ISNULL(Reim_Credit + Isnull(@M_AD_Amount,0),0)) - ISNULL( Reim_Debit + Isnull(@Actual_Debit,0),0),
																	sys_date = GETDATE() ,--Sal_Tran_ID = @Sal_tran_id	
																	S_Sal_Tran_id = @S_Sal_tran_id, Reim_Sett_CR_Amount = @M_AD_Amount 
															WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
														END
												END
												
													
													
											--Update T0140_ReimClaim_Transacation_Payment_Monthly set Opening = Opening - @Claim_Debit,
											--Balance = Balance - @Claim_Debit 
											--where Claim_ID = @RC_Id and for_date > @For_Date and cmp_ID = @cmp_ID and emp_ID = @Emp_Id	
																
									 		UPDATE	dbo.T0140_ReimClaim_Transacation_Payment_Monthly 
									 		SET		Opening = (Opening + Isnull(@Reim_CR_Amount,0)) - @Claim_Debit,Balance = (Balance  + Isnull(@Reim_CR_Amount,0)) - Isnull(@Claim_Debit,0)
											WHERE	Claim_ID = @RC_Id AND for_date > @For_Date AND cmp_ID = @cmp_ID AND emp_ID = @Emp_Id
													 
													 --update T0140_ReimClaim_Transacation set Reim_Opening = (@Last_Closing + @Reim_CR_Amount) - @Actual_Debit 
														--	,Reim_Closing =(((@Last_Closing + @Reim_CR_Amount) - @Actual_Debit) + isnull(Reim_Credit,0))  - isnull(Reim_debit,0),
														--	sys_date = GETDATE()	
													 --where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
													 
													 -- update T0140_ReimClaim_Transacation set Reim_Opening = @Last_Closing 
														--,Reim_Closing = (@Last_Closing + isnull(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (isnull(@Actual_Debit,0)+ isnull(Reim_debit,0)),
														--sys_date = GETDATE()
													 --where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
											
											UPDATE	dbo.T0140_ReimClaim_Transacation 
											SET		Reim_Opening = (Reim_Opening + Isnull(@Reim_CR_Amount,0)) - Isnull(@Actual_Debit,0),
													Reim_Closing = (Reim_Opening + ISNULL(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (ISNULL(@Actual_Debit,0)+ ISNULL(Reim_debit,0)),sys_date = GETDATE()	
											WHERE	for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												
												
										END
									ELSE
										BEGIN
											
											SELECT	@Last_Closing = ISNULL(Reim_Closing,0) 
											FROM	T0140_ReimClaim_Transacation WITH (NOLOCK)
    										WHERE	for_date = (
    													SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
    													WHERE for_date < @For_date AND RC_ID = @Rc_ID 
    													AND cmp_ID = @cmp_ID AND emp_id = @emp_Id
    												  ) AND cmp_ID = @cmp_ID AND RC_ID = @RC_ID  AND emp_id = @emp_Id
			    											
			    							
											IF @Last_Closing IS NULL 
												SET  @Last_Closing = 0
                                              

											Declare @DEF_ID Numeric(5,0)
											Set @DEF_ID = 0
											Select @DEF_ID = AD_DEF_ID From T0050_AD_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and AD_ID = @RC_Id

											If @DEF_ID = 9
												Begin
													SELECT	@Balance = ISNULL(Balance,0)  
													FROM	dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE	for_date = (
																		 SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly  WITH (NOLOCK)
																		 WHERE for_date < @For_date  
																		 AND For_Date Between dbo.GET_YEAR_START_DATE(Year(@For_date),Month(@For_Date),0) and dbo.GET_YEAR_END_DATE(Year(@For_date),Month(@For_Date),0)
																		 AND Claim_Id = @RC_Id 
																		 AND cmp_ID = @cmp_ID AND emp_id = @emp_Id 
																	  )  AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id
												End
											Else
												Begin
													SELECT	@Balance = ISNULL(Balance,0) 
													FROM	dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE	for_date = (
																		 SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
																		 WHERE for_date < @For_date
																		 AND Claim_Id = @RC_Id 
																		 AND cmp_ID = @cmp_ID AND emp_id = @emp_Id 
																	  )  AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id
												End

												IF @Balance IS NULL
    												SET @Balance = 0
		    					
    											IF ISNULL(@M_AD_Approval_Amount,0) = 0 
    					   							SET @M_AD_Approval_Amount = @Balance 
    											ELSE
    												SET @M_AD_Approval_Amount = @M_AD_Approval_Amount + @Balance
											
												IF (@Last_Closing + @Reim_CR_Amount)  > @M_AD_Approval_Amount
													BEGIN
														SET @Actual_Debit = @M_AD_Approval_Amount
														SET @Claim_Debit = @M_AD_Approval_Amount 
													END
												ELSE
													BEGIN
														SET @Actual_Debit = (@Last_Closing + @Reim_CR_Amount)  
														SET @Claim_Debit = (@Last_Closing + @Reim_CR_Amount) 	 
													END	
										
												IF @M_AD_Approval_Amount = 0 
													BEGIN
														SET @Actual_Debit = 0
														SET @Claim_Debit = 0
													END
												
											
											IF @Claim_Debit > 0 
											   BEGIN
													 INSERT dbo.T0140_ReimClaim_Transacation_Payment_Monthly
													 (Trans_ID,cmp_ID,emp_id,Claim_ID,Sal_Trans_ID,For_Date,Opening,Credit,Debit,Balance)
													 VALUES(@Claim_Tran_ID,@cmp_ID,@emp_id,@Rc_Id,@Sal_tran_id,@for_Date,@Balance,0,@Claim_Debit,@Balance - @Claim_Debit)	
											   END
											 
	
											UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly SET Opening = (Opening + Isnull(@Reim_CR_Amount,0)) - Isnull(@Claim_Debit,0)
											, Balance = (Balance  + Isnull(@Reim_CR_Amount,0)) - Isnull(@Claim_Debit,0) 
											WHERE Claim_ID = @RC_Id AND for_date > @For_Date AND cmp_ID = @cmp_ID AND emp_ID = @Emp_Id
									
											IF ISNULL(@S_Sal_tran_id,0) = 0 --THIS CONDITION WAS ADDED BY RAMIZ ON 07/02/2017 AS DURING SETTLEMENT REIM_CREDIT WAS GOING ZERO (0)
												BEGIN
													UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Debit =  Reim_Debit + Isnull(@Actual_Debit,0) ,
														Reim_Credit = @M_AD_Amount ,
														Reim_Closing = ISNULL(Reim_Opening,0) + ISNULL(Reim_Credit + Isnull(@M_AD_Amount,0),0) - ISNULL( Reim_Debit + Isnull(@Actual_Debit,0),0)
														,Sal_Tran_ID = @Sal_tran_id,sys_date = GETDATE() 	
													WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												END
											ELSE
												BEGIN
													UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Debit =  Reim_Debit+@Actual_Debit ,
														Reim_Credit = ISNULL(Reim_Credit,0) + Isnull(@M_AD_Amount,0) ,
														Reim_Closing = ISNULL(Reim_Opening,0) + ISNULL(Reim_Credit + Isnull(@M_AD_Amount,0),0) - ISNULL( Reim_Debit + Isnull(@Actual_Debit,0),0)
														,sys_date = GETDATE(),
														S_Sal_Tran_id = @S_Sal_tran_id , Reim_Sett_CR_Amount = @M_AD_Amount 	
													WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												END
												
											 --update T0140_ReimClaim_Transacation set Reim_Opening =  (@Last_Closing  + @Reim_CR_Amount) - @Actual_Debit
												--	,Reim_Closing = (((@Last_Closing + @Reim_CR_Amount) - @Actual_Debit )  + isnull(Reim_Credit,0)) - isnull(Reim_debit,0),
												--	sys_date = GETDATE()	
											 --where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
													  UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Opening = (Reim_Opening + Isnull(@Reim_CR_Amount,0)) - Isnull(@Actual_Debit,0)
														,Reim_Closing = (Reim_Opening + ISNULL(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (ISNULL(@Actual_Debit,0)+ ISNULL(Reim_debit,0)),
														sys_date = GETDATE()	
													 WHERE  for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
											 
									END
								END
							ELSE
								BEGIN
									IF ISNULL(@S_Sal_tran_id,0) = 0 
										BEGIN 
											IF EXISTS(SELECT 1 FROM T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND RC_ID=@RC_ID AND Sal_tran_ID = @Sal_tran_id)
												BEGIN
													UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Debit =  @M_AD_Approval_Amount ,
														Reim_Credit = @M_AD_Amount,
														Sal_Tran_Id = @Sal_tran_id, 
														Reim_Closing = ISNULL(Reim_Opening,0) + ISNULL(@Reim_CR_Amount,0) - Isnull(@M_AD_Approval_Amount,0),sys_date = GETDATE() 	
													WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												END
											ELSE
												BEGIN
													UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Debit =  Reim_Debit+@M_AD_Approval_Amount ,
														Reim_Credit = @M_AD_Amount,
														Sal_Tran_Id = @Sal_tran_id, 
														Reim_Closing = ISNULL(Reim_Opening,0) + ISNULL(@Reim_CR_Amount,0) - ISNULL( Reim_Debit + Isnull(@M_AD_Approval_Amount,0),0),sys_date = GETDATE() 	
													WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												END
										END
									ELSE
										BEGIN
											UPDATE dbo.T0140_ReimClaim_Transacation 
											SET Reim_Debit =  Reim_Debit + Isnull(@M_AD_Approval_Amount,0) ,
												Reim_Credit = ISNULL(Reim_Credit,0) + Isnull(@M_AD_Amount,0) ,
												Reim_Closing = ISNULL(Reim_Opening,0) + ( ISNULL(Reim_Credit,0) + ISNULL(@Reim_CR_Amount,0)) - ISNULL( Reim_Debit + Isnull(@M_AD_Approval_Amount,0),0), --Reim_Credit--Added by Ankit 08032016
 												sys_date = GETDATE() ,
												S_Sal_Tran_id = @S_Sal_tran_id , Reim_Sett_CR_Amount = @M_AD_Amount
											WHERE  for_date = @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
										
										END	
									
									UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Opening = Reim_Opening + Isnull(@Reim_CR_Amount,0)
										,Reim_Closing = ISNULL(Reim_Opening,0) + ISNULL(@Reim_CR_Amount,0) - ISNULL(@M_AD_Approval_Amount,0) - ISNULL(Reim_debit,0),sys_date = GETDATE()	
									WHERE  for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
									
									
									----Ankit------
				
									SET @Pre_Closing = 0
									SELECT @Pre_Closing = ISNULL(Reim_Closing,0) FROM T0140_ReimClaim_Transacation  WITH (NOLOCK)
									 WHERE for_date = (SELECT MAX(for_date) FROM T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE for_date <= @For_date  
									 AND rc_id = @rc_id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id)   
									 AND Cmp_ID = @Cmp_ID  
									 AND rc_id = @rc_id AND emp_Id = @emp_Id  
			       
										 IF @Pre_Closing IS NULL  
											SET @Pre_Closing = 0  
				        
										DECLARE cur1 CURSOR FOR   
											SELECT reim_tran_id,For_Date FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE rc_id = @rc_id AND emp_id = @emp_id   
											AND Cmp_ID = @Cmp_ID AND for_date > @For_date ORDER BY for_date  
										OPEN cur1  
											FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur  
												WHILE @@FETCH_STATUS = 0  
													BEGIN  
				       
															BEGIN  
																UPDATE dbo.T0140_ReimClaim_Transacation SET   
																Reim_Opening = @Pre_Closing,  
																Reim_Closing = @Pre_Closing + ISNULL(Reim_Credit,0) - ISNULL(Reim_Debit,0)
																WHERE reim_tran_id = @Chg_Tran_Id  
															   
																SET @Pre_Closing = ISNULL((SELECT ISNULL(Reim_Closing,0) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE reim_tran_id = @Chg_Tran_Id),0)  
															END  
				        
														FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur  
													END  
										CLOSE cur1  
										DEALLOCATE cur1 
							----Ankit-----
							END
						END
					ELSE
						BEGIN
							SELECT @Reim_Tran_ID = ISNULL(MAX(Reim_Tran_ID),0) + 1 FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
						
							SELECT @Last_Closing = ISNULL(Reim_Closing,0) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
    												WHERE for_date = (SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
    														WHERE for_date < @For_date
    													AND RC_Id = @RC_Id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
    													AND Cmp_ID = @Cmp_ID
    													AND RC_id = @RC_Id AND emp_Id = @emp_Id

								--SELECT @Last_Closing = isnull(Reim_Closing,0) from dbo.T0140_ReimClaim_Transacation R Where exists
								--(Select 1 from  (
								--(select max(for_date) as For_date from dbo.T0140_ReimClaim_Transacation 
								--where for_date < @For_date
								--and RC_Id = @RC_Id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id ) )Qry Where Qry.For_date = r.For_Date)
								--and Cmp_ID = @Cmp_ID
								--and RC_id = @RC_Id and emp_Id = @emp_Id	and R.For_Date = For_date	
								    													
							IF @Setting_Value = 1 
								BEGIN
									SELECT  @Claim_Tran_ID = ISNULL(MAX(trans_ID),0) + 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
								
										IF NOT EXISTS( SELECT 1 FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK) WHERE Claim_Id = @RC_Id AND Cmp_ID = @Cmp_ID AND For_Date = @For_Date AND Emp_ID = @Emp_Id)
											BEGIN
											
												SELECT @Balance = ISNULL(Balance,0) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE for_date = (SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE for_date < @For_date AND Claim_Id = @RC_Id AND cmp_ID = @cmp_ID AND emp_id = @emp_Id ) 
    												AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id
				    										
    											IF @Balance IS NULL
    												SET @Balance = 0
						    				    					
    											IF ISNULL(@M_AD_Approval_Amount,0) = 0 
    					   							SET @M_AD_Approval_Amount = @Balance 
    											ELSE
    												SET @M_AD_Approval_Amount = @M_AD_Approval_Amount + @Balance
						    					    	
											
												IF (@Last_Closing + @Reim_CR_Amount)   > @M_AD_Approval_Amount
													BEGIN
														SET @Actual_Debit = @M_AD_Approval_Amount
														SET @Claim_Debit = @M_AD_Approval_Amount
													END
												ELSE
													BEGIN
														SET @Actual_Debit = (@Last_Closing + @Reim_CR_Amount)
														SET @Claim_Debit = (@Last_Closing + @Reim_CR_Amount)	  	
													END
												
												
												IF @M_AD_Approval_Amount = 0 
													BEGIN
														SET @Actual_Debit = 0
														SET @Claim_Debit = 0
													END
														
												IF @Claim_Debit > 0 
													BEGIN
														INSERT dbo.T0140_ReimClaim_Transacation_Payment_Monthly
														 (Trans_ID,cmp_ID,emp_id,Claim_ID,Sal_Trans_ID,For_Date,Opening,Credit,Debit,Balance)
														 VALUES(@Claim_Tran_ID,@cmp_ID,@emp_id,@Rc_Id,@Sal_tran_id,@for_Date,@Balance,0,@Claim_Debit,@Balance - @Claim_Debit)	
													END
												--Update T0140_ReimClaim_Transacation_Payment_Monthly set Opening = Opening - @Claim_Debit
												--, Balance = Balance - @Claim_Debit 
												--where Claim_ID = @RC_Id and for_date > @For_Date and cmp_ID = @cmp_ID and emp_ID = @Emp_Id
												UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly SET Opening = (Opening + @Reim_CR_Amount) - @Claim_Debit
												, Balance = (Balance  + @Reim_CR_Amount) - @Claim_Debit 
												WHERE Claim_ID = @RC_Id AND for_date > @For_Date AND cmp_ID = @cmp_ID AND emp_ID = @Emp_Id
												
												INSERT INTO dbo.T0140_ReimClaim_Transacation
	    										(Reim_Tran_ID,Cmp_ID,RC_ID,Emp_ID,For_Date,Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing,Sal_tran_ID)
	    										VALUES (@Reim_Tran_ID,@Cmp_ID,@RC_Id,@emp_id,@For_Date,@Last_Closing,@Reim_CR_Amount, @Claim_Debit,(@Last_Closing + @Reim_CR_Amount) - @Actual_Debit,@Sal_tran_id)
					            
												 --update T0140_ReimClaim_Transacation set Reim_Opening = ((@Last_Closing + @Reim_CR_Amount) - @Actual_Debit)
													--		,Reim_Closing = ((@Last_Closing + @Reim_CR_Amount) - @Actual_Debit) + isnull(@Reim_CR_Amount,0) - isnull(@Actual_Debit,0) - isnull(Reim_debit,0),
													--		sys_date = GETDATE()	
													-- where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
												
												
												 --update T0140_ReimClaim_Transacation set Reim_Opening = @Last_Closing 
													--		,Reim_Closing = (@Last_Closing + isnull(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (isnull(@Actual_Debit,0)+ isnull(Reim_debit,0)),
													--		sys_date = GETDATE()	
													-- where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
													 UPDATE dbo.T0140_ReimClaim_Transacation 
													 SET Reim_Opening = (Reim_Opening + @Reim_CR_Amount) - Isnull(@Actual_Debit,0)
														,Reim_Closing = (Reim_Opening + ISNULL(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (ISNULL(@Actual_Debit,0)+ ISNULL(Reim_debit,0)),
																sys_date = GETDATE()	
															 WHERE  for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												
												END
										ELSE
											BEGIN
													SELECT @Balance = ISNULL(Balance,0) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE for_date = (SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    												WHERE for_date < @For_date AND Claim_Id = @RC_Id AND cmp_ID = @cmp_ID AND emp_id = @emp_Id ) 
    												AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id
				    										
    											IF @Balance IS NULL
    												SET @Balance = 0
						    				    
						    				   		
    											IF ISNULL(@M_AD_Approval_Amount,0) = 0 
    					   							SET @M_AD_Approval_Amount = @Balance 
    											ELSE
    												SET @M_AD_Approval_Amount = @M_AD_Approval_Amount + @Balance
						    					    	
										 
												IF (@Last_Closing + @Reim_CR_Amount) > @M_AD_Approval_Amount
													BEGIN
														SET @Actual_Debit = @M_AD_Approval_Amount
														SET @Claim_Debit = @M_AD_Approval_Amount
													END
												ELSE
													BEGIN
														SET @Actual_Debit = (@Last_Closing + @Reim_CR_Amount)	  	
														SET @Claim_Debit = (@Last_Closing + @Reim_CR_Amount)	  	
													END
												
												IF @M_AD_Approval_Amount = 0 
													BEGIN
														SET @Actual_Debit = 0
														SET @Claim_Debit = 0
													END
													
													
														
													IF @Claim_Debit > 0 
													 BEGIN
															UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly
																SET Debit = @Claim_Debit, Balance = Balance - @Claim_Debit
															WHERE Claim_ID = @RC_Id AND Cmp_ID =@Cmp_ID AND For_Date =@For_Date AND Emp_ID = @Emp_Id
													 END
												UPDATE dbo.T0140_ReimClaim_Transacation_Payment_Monthly SET Opening = (Opening + @Reim_CR_Amount) - @Claim_Debit
												, Balance = (Balance  + @Reim_CR_Amount) - @Claim_Debit 
												WHERE Claim_ID = @RC_Id AND for_date > @For_Date AND cmp_ID = @cmp_ID AND emp_ID = @Emp_Id
									   
										INSERT INTO dbo.T0140_ReimClaim_Transacation
	    									(Reim_Tran_ID,Cmp_ID,RC_ID,Emp_ID,For_Date,Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing,Sal_tran_ID,S_Sal_Tran_id, Reim_Sett_CR_Amount)
	    									VALUES (@Reim_Tran_ID,@Cmp_ID,@RC_Id,@emp_id,@For_Date,@Last_Closing,@Reim_CR_Amount, @Actual_Debit,(Isnull(@Last_Closing,0) + Isnull(@Reim_CR_Amount,0)) - @Actual_Debit,@Sal_tran_id,@S_Sal_tran_id,Case When ISNULL(@S_Sal_tran_id,0) >0 Then @M_AD_Amount Else 0 End)
					            
										
												 --update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening + @Last_Closing 
													--		,Reim_Closing = (@Last_Closing + isnull(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (isnull(@Actual_Debit,0)+ isnull(Reim_debit,0)),
													--		sys_date = GETDATE()	
													-- where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
													 UPDATE dbo.T0140_ReimClaim_Transacation SET Reim_Opening = (Reim_Opening + Isnull(@Reim_CR_Amount,0)) - Isnull(@Actual_Debit,0)
																,Reim_Closing = (Reim_Opening + ISNULL(@Reim_CR_Amount,0) + ISNULL(Reim_Credit,0)) - (ISNULL(@Actual_Debit,0)+ ISNULL(Reim_debit,0)),
																sys_date = GETDATE()	
															 WHERE  for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
												END										
										
								END
							ELSE
								BEGIN
									
	    							INSERT	INTO dbo.T0140_ReimClaim_Transacation
	    									(Reim_Tran_ID,Cmp_ID,RC_ID,Emp_ID,For_Date,Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing,Sal_tran_ID,S_Sal_Tran_id,Reim_Sett_CR_Amount)
	    									VALUES (@Reim_Tran_ID,@Cmp_ID,@RC_Id,@emp_id,@For_Date,@Last_Closing,@Reim_CR_Amount, @M_AD_Approval_Amount,(@Last_Closing + @Reim_CR_Amount) -@M_AD_Approval_Amount,@Sal_tran_id,@S_Sal_tran_id,Case When ISNULL(@S_Sal_tran_id,0) >0 Then @M_AD_Amount Else 0 End)
								
									UPDATE	dbo.T0140_ReimClaim_Transacation SET
											Reim_Opening = Reim_Opening + (Isnull(@Reim_CR_Amount,0)) - Isnull(@M_AD_Approval_Amount,0)
											,Reim_Closing = ISNULL(Reim_Closing,0) + ISNULL((Isnull(@Reim_CR_Amount,0)) - Isnull(@M_AD_Approval_Amount,0),0),sys_date = GETDATE()	
									WHERE  for_date > @For_Date AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id AND rc_id = @RC_Id
									
									
								END
							
							----- Approval amount condition added by Hardik 07/01/2016
							--if @Setting_Value = 0 and @M_AD_Approval_Amount > 0   -- Not Require for Monthly base Reimbersument Payment.-1  ,,, 
							--	begin
							--			INSERT INTO T0210_MONTHLY_Reim_DETAIL (
							--							Cmp_ID,
							--								Emp_ID,
							--								RC_ID,
							--								RC_apr_ID,										
							--								Temp_Sal_tran_ID,
							--								Sal_tran_ID,
							--								for_Date,
							--								Amount,
							--								Taxable,
							--								Tax_Free_amount)
															
							--			SELECT	RT.Cmp_ID,RT.Emp_ID,RC_ID,NULL,NULL, RT.Sal_tran_ID, RT.for_Date, 0,@M_AD_Approval_Amount,0 -- @M_AD_Amount,0        --M_AD_Amount commented by Hardik 07/01/2016
							--			FROM	T0140_ReimClaim_Transacation RT
							--					inner join INSERTED I on RT.Emp_ID= I.Emp_ID and RT.For_Date=I.For_Date and RT.RC_ID = I.AD_ID and I.FOR_FNF=0
							--	end

						END		
				END
			ELSE 		
				BEGIN
					IF EXISTS(SELECT 1 FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) WHERE for_date = @For_date AND emp_id = @emp_Id  AND rc_id=@RC_Id AND Cmp_ID = @Cmp_ID)
						BEGIN
						
							---change By Nilay : 04/08/2014
							IF @Setting_Value = 1 
								BEGIN
									SELECT @Balance = ISNULL(Balance,0) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
    								WHERE for_date = (SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation_Payment_Monthly WITH (NOLOCK)
									WHERE for_date < @For_date AND Claim_Id = @RC_Id AND 
									cmp_ID = @cmp_ID AND emp_id = @emp_Id ) 
									AND cmp_ID = @cmp_ID AND Claim_Id = @RC_Id  AND emp_id = @emp_Id			
									
									UPDATE dbo.T0140_ReimClaim_Transacation 
									SET for_Fnf=1, 
										Reim_Debit = ISNULL(@Balance,0), 
										Reim_Credit = ISNULL(Reim_Credit,0)+ ISNULL(@Balance,0) ,
										Reim_Closing =0				
									 WHERE for_date = @For_date AND emp_id = @emp_Id  AND rc_id=@RC_Id AND Cmp_ID = @Cmp_ID	
									
									---Performance
									UPDATE dbo.T0140_ReimClaim_Transacation SET 
										Posting_Amount=  ISNULL(Reim_Debit,0) - (ISNULL(RT.Reim_Opening,0) + ISNULL(RT.Reim_Credit,0)) 											
										FROM 	T0140_ReimClaim_Transacation RT 
										WHERE RT.Emp_ID= @Emp_Id AND RT.For_Date=@For_Date AND RT.RC_ID = @RC_Id
											--inner join #INSERTED I on 
											--	RT.Emp_ID= I.Emp_ID and RT.For_Date=I.For_Date and RT.RC_ID = I.AD_ID
																
										UPDATE dbo.T0210_MONTHLY_AD_DETAIL SET 
												M_AD_Amount = I.Reim_Debit 
										FROM 	T0210_MONTHLY_AD_DETAIL RT INNER JOIN T0140_ReimClaim_Transacation I ON 
												RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.AD_ID = I.RC_ID
												AND RT.for_Fnf=1 
										
								END
							ELSE
								BEGIN
									---Performance
									UPDATE dbo.T0140_ReimClaim_Transacation SET 
											for_Fnf=1, Reim_Debit = Reim_Debit + ISNULL(Mad.Amount,0), --Reim_Credit=ISNULL(Reim_Credit,0)+ ISNULL(Mad_Amount,0) , /* reim_Credit Comment by Ankit 04072016 [WCL Case - FNF Employee LTA Statement not match openning + credit - Debit and set Closing amount ] */
											Reim_Closing =0				
									FROM 	dbo.T0140_ReimClaim_Transacation RT 
											--inner join #INSERTED I on 
											--RT.Emp_ID= I.Emp_ID and RT.For_Date=I.For_Date and RT.RC_ID = I.AD_ID
											INNER JOIN 				
											(SELECT Emp_ID, AD_ID,for_Date,SUM(ISNULL(M_AD_Amount,0) + ISNULL(M_AREAR_AMOUNT,0)+ISNULL(M_AREAR_AMOUNT_Cutoff,0)) AS Amount ,
													SUM(ISNULL(M_AREAR_AMOUNT,0)) AS Mad_Amount	
												FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
												WHERE Emp_ID = @Emp_ID AND AD_ID = @RC_Id AND For_Date=@For_Date
											 GROUP BY Emp_ID,AD_ID,for_Date ) AS Mad				 				
											--on I.Emp_ID = mad.Emp_ID and I.AD_ID = Mad.AD_ID and I.For_Date=mad.for_Date 
											ON RT.Emp_ID = mad.Emp_ID AND RT.RC_ID = Mad.AD_ID AND RT.For_Date=mad.for_Date 
											--inner join
											--(select Emp_ID, AD_ID,for_Date,sum(isnull(M_AREAR_AMOUNT,0)) as Mad_Amount 
											--	from dbo.T0210_MONTHLY_AD_DETAIL
											--	where Emp_ID = @Emp_ID and AD_ID = @RC_Id and For_Date=@For_Date
											-- group BY Emp_ID,AD_ID,for_Date ) as Mad1				 				
											--on I.Emp_ID = Mad1.Emp_ID and I.AD_ID = Mad1.AD_ID and I.For_Date=Mad1.for_Date
						
									---Performance
									UPDATE dbo.T0140_ReimClaim_Transacation SET 
										Posting_Amount =  (ISNULL(RT.Reim_Opening,0) + ISNULL(RT.Reim_Credit,0)) - ISNULL(Reim_Debit,0) --Ankit/Hardikbhai [closing & Posting Amount Not Match - Gift Reim Case - 10082016]
													--ISNULL(Reim_Debit,0) - (ISNULL(RT.Reim_Opening,0) + ISNULL(RT.Reim_Credit,0)) 
									FROM 	dbo.T0140_ReimClaim_Transacation RT 
									WHERE Emp_ID = @Emp_ID AND RT.RC_ID = @RC_Id AND For_Date=@For_Date
										--inner join #INSERTED I on 
										--	RT.Emp_ID= I.Emp_ID and RT.For_Date=I.For_Date and RT.RC_ID = I.AD_ID
									
									UPDATE dbo.T0210_MONTHLY_AD_DETAIL SET 
											M_AD_Amount = I.Reim_Debit 
									FROM 	dbo.T0210_MONTHLY_AD_DETAIL RT INNER JOIN T0140_ReimClaim_Transacation I ON 
											RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.AD_ID = I.RC_ID
											AND RT.for_Fnf=1
						   
								END
								
							IF @Setting_Value = 0  -- Not Required For Monthly Base REimbursement Payment -3
								BEGIN
								
									IF EXISTS(SELECT 1 FROM dbo.T0210_Monthly_Reim_Detail WITH (NOLOCK) WHERE For_Date=@For_Date AND Emp_ID=@Emp_Id AND Cmp_ID=@Cmp_ID AND RC_ID=@RC_Id)
										BEGIN
										
											UPDATE	dbo.T0210_Monthly_Reim_Detail 
											SET		Taxable=ISNULL(Taxable,0) +@M_AD_Amount 
											FROM	T0210_Monthly_Reim_Detail RT 
													INNER JOIN #INSERTED I ON 
													RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.RC_ID = I.AD_ID AND I.FOR_FNF=1
										END
									ELSE
										BEGIN
										
											INSERT INTO dbo.T0210_MONTHLY_Reim_DETAIL (
																Cmp_ID,
																Emp_ID,
																RC_ID,
																RC_apr_ID,										
																Temp_Sal_tran_ID,
																Sal_tran_ID,
																for_Date,
																Amount,
																Taxable,
																Tax_Free_amount)
											SELECT	RT.Cmp_ID,RT.Emp_ID,RC_ID,NULL,NULL, RT.Sal_tran_ID, RT.for_Date, 0,rt.reim_credit + @M_AD_Amount,0 
											FROM	dbo.T0140_ReimClaim_Transacation RT WITH (NOLOCK)
													INNER JOIN #INSERTED I ON 
													RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.RC_ID = I.AD_ID AND I.FOR_FNF=1
										END
								END
						END
					ELSE
						BEGIN
							SELECT	@Reim_Tran_ID = ISNULL(MAX(Reim_Tran_ID),0) + 1 FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
				
							SELECT	@Last_Closing = ISNULL(Reim_Closing,0) 
							FROM	dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
							WHERE	for_date = (SELECT MAX(for_date) FROM dbo.T0140_ReimClaim_Transacation WITH (NOLOCK)
													WHERE for_date < @For_date
												AND RC_Id = @RC_Id AND Cmp_ID = @Cmp_ID AND emp_Id = @emp_Id) 
												AND Cmp_ID = @Cmp_ID
												AND RC_id = @RC_Id AND emp_Id = @emp_Id
							INSERT INTO dbo.T0140_ReimClaim_Transacation
										(Reim_Tran_ID,Cmp_ID,RC_ID,Emp_ID,For_Date,Reim_Opening,Reim_Credit,Reim_Debit,Reim_Closing,Sal_tran_ID, Posting_amount, For_FNF,S_Sal_Tran_id)
							VALUES (@Reim_Tran_ID,@Cmp_ID,@RC_Id,@emp_id,@For_Date,@Last_Closing,@Reim_CR_Amount, 0,(@Last_Closing + @Reim_CR_Amount) -@M_AD_Amount - @M_AD_Amount,@Sal_tran_id, @M_AD_Amount, 1,@S_Sal_tran_id)

							UPDATE	dbo.T0210_MONTHLY_AD_DETAIL 
							SET		M_AD_Amount = I.Posting_Amount
							FROM 	T0210_MONTHLY_AD_DETAIL RT INNER JOIN T0140_ReimClaim_Transacation I ON 
									RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.AD_ID = I.RC_ID
									AND RT.for_Fnf=1
									
									
							IF @Setting_Value = 0  -- Not Required For Monthly Based Reimbursement Payment -2
									BEGIN
    									INSERT INTO dbo.T0210_MONTHLY_Reim_DETAIL (
													Cmp_ID,
													Emp_ID,
													RC_ID,
													RC_apr_ID,										
													Temp_Sal_tran_ID,
													Sal_tran_ID,
													for_Date,
													Amount,
													Taxable,
													Tax_Free_amount)
													
											SELECT	RT.Cmp_ID,RT.Emp_ID,RC_ID,NULL,NULL, RT.Sal_tran_ID, RT.for_Date, 0, Posting_Amount,0 
											FROM	dbo.T0140_ReimClaim_Transacation RT WITH (NOLOCK) INNER JOIN #INSERTED I ON 
													RT.Emp_ID= I.Emp_ID AND RT.For_Date=I.For_Date AND RT.RC_ID = I.AD_ID AND I.FOR_FNF=1
									 END
						END
				END

			
		END
				
END




