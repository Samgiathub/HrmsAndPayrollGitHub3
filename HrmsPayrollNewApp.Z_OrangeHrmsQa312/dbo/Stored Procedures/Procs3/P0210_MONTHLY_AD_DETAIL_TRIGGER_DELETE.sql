

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0210_MONTHLY_AD_DETAIL_TRIGGER_DELETE]
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Reim_Tran_ID numeric 
		Declare @M_AD_Tran_ID numeric 
		declare @Cmp_ID as numeric
		declare @Emp_Id as numeric
		declare @RC_Id as numeric
		declare @For_Date as datetime
		declare @Sal_tran_id as Numeric
		declare @Reim_CR_Amount as numeric (18,2)
		declare @S_Sal_tran_id as Numeric
		declare @Reim_Sett_CR_Amount as numeric (18,2)
		declare @Last_Reim_Closing as numeric (18,2)
		DECLARE @Last_Closing AS NUMERIC (18,2)
		DECLARE @ReimShow AS NUMERIC
		Declare @M_AD_Amount as numeric(18,2)
		declare @M_AD_Approval_Amount as numeric(18,2)
		declare @For_FNF as numeric(18,2)
		Declare @Setting_Value as tinyint -- Added by Gadriwala Muslim 22062015
		Declare @Actual_Debit numeric(18,2) -- Added by Gadriwala Muslim 22062015
		Declare @Claim_Debit numeric(18,2)-- Added by Gadriwala Muslim 22062015

		Declare @Chg_Tran_Id numeric    
		Declare @For_Date_Cur Datetime
		Declare @Pre_Closing numeric(18,2) 
		declare @reim_amount numeric(18,2) -- Added by rohit on 25032016

		set @Last_Reim_Closing = 0
		set @Reim_Sett_CR_Amount = 0
		set @Last_Reim_Closing = 0
		set @Last_Closing = 0
		set @M_AD_Approval_Amount =0
		set @For_FNF = 0
		set @Actual_Debit = 0 -- Added by Gadriwala Muslim 22062015
		set @Claim_Debit = 0 -- Added by Gadriwala Muslim 22062015
		set @Setting_Value = 0 -- Added by Gadriwala Muslim 22062015

		Set @Chg_Tran_Id  = 0    
		Set @Pre_Closing = 0
							    
		if exists(SELECT 1 from #DELETED)
		  begin 
			declare curDel cursor for
			select del.Cmp_ID ,Del.Emp_Id,del.AD_ID,del.For_date,del.sal_tran_id,ISNULL(del.m_ad_amount,0) + ISNULL(del.M_AREAR_AMOUNT,0)+ ISNULL(del.M_AREAR_AMOUNT_Cutoff,0),del.S_Sal_Tran_ID, del.FOR_FNF,reimamount from #DELETED del inner join T0050_AD_MASTER AM WITH (NOLOCK) on del.AD_ID = AM.AD_ID where AM.AD_NOT_EFFECT_SALARY = 1 and AM.Allowance_type='R'-- and del.S_Sal_Tran_ID is null
			open curDel
			fetch next from curDel into @Cmp_ID,@Emp_Id , @RC_Id,@For_Date,@Sal_tran_id,@Reim_CR_Amount,@S_Sal_tran_id,@for_fnf,@reim_amount
			while @@fetch_status = 0
			begin 
				BEGIN		
				
						-- Changed by Gadriwala Muslim 24062015
					select @Setting_Value = Setting_Value from T0040_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and setting_Name = 'Monthly base get reimbursement claim amount'
					
					 
						
					IF isnull(@for_fnf,0) = 1
					BEGIN
						
				  		    
						--delete FROM T0140_ReimClaim_Transacation  where  Sal_tran_ID=@Sal_tran_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id																																		
						delete from T0210_Monthly_Reim_Detail where Sal_Tran_ID=@Sal_tran_id and Cmp_ID = @Cmp_ID	
					
					IF @Setting_Value = 1  -- Changed by Gadriwala 24062015
					  BEGIN
			  			select @Last_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation WITH (NOLOCK)
    											where for_date = (
    												select max(for_date) from T0140_ReimClaim_Transacation  WITH (NOLOCK)
    												where for_date < @For_date and RC_ID = @Rc_ID 
    												and cmp_ID = @cmp_ID and emp_id = @emp_Id
    											  ) and cmp_ID = @cmp_ID and RC_ID = @RC_ID  and emp_id = @emp_Id
		    				
		    
		    											
						if @Last_Closing is null 
						set  @Last_Closing = 0
							
					
							
						update T0140_ReimClaim_Transacation set 
						Reim_opening = @Last_Closing,
						Reim_Debit = 0, 
						Reim_Credit=0 ,
						Reim_Closing = @Last_Closing
						,sys_date = GETDATE() 	
						where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and Sal_tran_id=@Sal_tran_id

						update T0140_ReimClaim_Transacation set Reim_Opening = @Last_Closing,
								Reim_Debit = 0,
								Reim_Credit = 0
							,Reim_Closing = @Last_Closing ,sys_date = GETDATE()			
						from  T0140_ReimClaim_Transacation RT 
						where  RT.for_date >= @For_Date and RT.Cmp_ID = @Cmp_ID and RT.emp_Id = @emp_Id and RT.rc_id = @RC_Id
						
						UPDATE T0140_ReimClaim_Transacation SET Sal_tran_ID = NULL 
						where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and Sal_tran_id=@Sal_tran_id
						
						delete from T0140_ReimClaim_Transacation_Payment_Monthly
						where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and Claim_ID = @RC_Id and Sal_Trans_ID =@Sal_tran_id
					
					  END
					 ELSE
						Begin

							update T0140_ReimClaim_Transacation set Reim_Debit =  0 , --Reim_Debit , --Changed by Hardik 06/06/2015 as if i get amount in F&F and now when delete F&F, amount should not #DELETED
								Reim_Credit=0 ,
								Reim_Closing = isnull(Reim_Opening,0)  --  - isnull(Reim_Debit,0) -- Commented by Hardik 06/06/2015
								,sys_date = GETDATE() 
								,Sal_tran_id =null	
							where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and Sal_tran_id=@Sal_tran_id 


							
							--update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening - @Reim_CR_Amount
							--	,Reim_Closing = isnull(Reim_Opening,0) - isnull(@Reim_CR_Amount,0) - isnull(@M_AD_Approval_Amount,0) - isnull(Reim_Debit,0)  ,sys_date = GETDATE()	
							--where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
							----Annkit------
								
								set @Pre_Closing = 0
								select @Pre_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation  WITH (NOLOCK)
										 where for_date = (select max(for_date) from T0140_ReimClaim_Transacation WITH (NOLOCK) where for_date <= @For_date  
										 and rc_id = @rc_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
										 and Cmp_ID = @Cmp_ID  
										 and rc_id = @rc_id and emp_Id = @emp_Id  
				       
											 if @Pre_Closing is null  
												set @Pre_Closing = 0  
					        
											declare cur1 cursor for   
												Select reim_tran_id,For_Date from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @rc_id and emp_id = @emp_id   
												and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
											open cur1  
												fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
													while @@fetch_status = 0  
														begin  
					       
																	Begin  
																			update dbo.T0140_ReimClaim_Transacation set   
																			Reim_Opening = @Pre_Closing,  
																			Reim_Closing = @Pre_Closing + isnull(Reim_Credit,0) - isnull(Reim_Debit,0)
																			where reim_tran_id = @Chg_Tran_Id  
																	   
																		set @Pre_Closing = isnull((select isnull(Reim_Closing,0) from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where reim_tran_id = @Chg_Tran_Id),0)  
																	End  
					        
																fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
														end  
											close cur1  
											deallocate cur1 
								----Ankit-----
						end
						
						
							    
					END
					ELSE
					BEGIN		    	
						--delete FROM T0140_ReimClaim_Transacation  where  Sal_tran_ID=@Sal_tran_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id																																		
						delete from T0210_Monthly_Reim_Detail where Sal_Tran_ID=@Sal_tran_id and Cmp_ID = @Cmp_ID			
						
						select @for_Date=for_date FROM T0140_ReimClaim_Transacation WITH (NOLOCK) where  Sal_tran_ID=@Sal_tran_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id																																		
						
						
						select @Last_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation WITH (NOLOCK)
    											where for_date = (
    												select max(for_date) from T0140_ReimClaim_Transacation WITH (NOLOCK)
    												where for_date < @For_date and RC_ID = @Rc_ID 
    												and cmp_ID = @cmp_ID and emp_id = @emp_Id
    											  ) and cmp_ID = @cmp_ID and RC_ID = @RC_ID  and emp_id = @emp_Id
									
									
						if @Last_Closing is null 
						set  @Last_Closing = 0
						if @Setting_Value = 1  -- Changed by Gadriwala Muslim 24062015
							begin	
							IF ISNULL(@S_Sal_tran_id,0) = 0 
								BEGIN
									Update T0140_ReimClaim_Transacation 
											set Reim_Opening = @Last_Closing,
												Reim_Credit =0,
												Reim_Debit = 0,
												Reim_Closing = @Last_Closing ,
												sys_Date = getdate()  
									 from T0140_ReimClaim_Transacation RT 
									 where  RT.Cmp_ID = @Cmp_ID and RT.emp_Id = @emp_Id and rc_id = @RC_Id and RT.Sal_tran_id=@Sal_tran_id
								End
							Else
								
								BEGIN
								
									update T0140_ReimClaim_Transacation 
									set Reim_Debit =   Reim_Debit - isnull(@reim_amount,0),--Is null Condition added by Sumit 04042016 error in salary settlement deleting
										Reim_Credit = case WHEN Reim_Sett_CR_Amount <> 0 THEN Reim_Credit - Reim_Sett_CR_Amount ELSE Reim_Credit END ,
										Reim_Closing = Reim_Opening + case WHEN Reim_Sett_CR_Amount > 0 THEN Reim_Credit - Reim_Sett_CR_Amount ELSE Reim_Credit END
										,sys_date = GETDATE() 
										,S_Sal_tran_id =null	
										,Reim_Sett_CR_Amount = 0
									where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and S_Sal_tran_id=@S_Sal_tran_id
								
									
								END

								--update T0140_ReimClaim_Transacation 
								--set Reim_Opening = @Last_Closing,
								--	Reim_credit = 0,
								--	Reim_debit = 0
								--,Reim_Closing = @Last_Closing ,sys_date = GETDATE()	
								--from  T0140_ReimClaim_Transacation RT 
								--where  RT.for_date >= @For_Date and RT.Cmp_ID = @Cmp_ID and RT.emp_Id = @emp_Id and RT.rc_id = @RC_Id
								set @Pre_Closing = 0
								select @Pre_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation  WITH (NOLOCK) 
										 where for_date = (select max(for_date) from T0140_ReimClaim_Transacation WITH (NOLOCK) where for_date <= @For_date  
										 and rc_id = @rc_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
										 and Cmp_ID = @Cmp_ID  
										 and rc_id = @rc_id and emp_Id = @emp_Id  
				       
											 if @Pre_Closing is null  
												set @Pre_Closing = 0  
					        
											declare cur1 cursor for   
												Select reim_tran_id,For_Date from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @rc_id and emp_id = @emp_id   
												and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
											open cur1  
												fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
													while @@fetch_status = 0  
														begin  
					       
																	Begin  
																			update dbo.T0140_ReimClaim_Transacation set   
																			Reim_Opening = @Pre_Closing,  
																			Reim_Closing = @Pre_Closing + isnull(Reim_Credit,0) + isnull(Reim_Sett_CR_Amount,0)- isnull(Reim_Debit,0)
																			where reim_tran_id = @Chg_Tran_Id  
																	   
																		set @Pre_Closing = isnull((select isnull(Reim_Closing,0) from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where reim_tran_id = @Chg_Tran_Id),0)  
																	End  
					        
																fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
														end  
											close cur1  
											deallocate cur1 

								UPDATE T0140_ReimClaim_Transacation SET Sal_tran_ID = NULL 
								where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and Sal_tran_id=@Sal_tran_id
								
								delete from T0140_ReimClaim_Transacation_Payment_Monthly
								where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and Claim_ID = @RC_Id and Sal_Trans_ID =@Sal_tran_id
							end	
						else
							begin	
							
							IF ISNULL(@S_Sal_tran_id,0) = 0 
								BEGIN
								
									update T0140_ReimClaim_Transacation 
									set Reim_Debit = Reim_Debit - isnull(@reim_amount,0),  --0 -- change by rohit for reim debit update to zero--Reim_Debit ,	--Comment b'cos Reim Debit amount unable to rollback in salary	--Ankit after discuss with Hardik Ji	--06112015
										Reim_Credit=0 ,
										--Reim_Closing = Reim_Opening -- isnull(Reim_Opening,0) - isnull(Reim_Debit,0) --Comment b'cos Reim Debit amount unable to rollback in salary	--Ankit after discuss with Hardik Ji	--06112015
										Reim_Closing = Reim_Opening - Reim_Debit + isnull(@reim_amount,0) -- comment and add by rohit on 12042016
										,sys_date = GETDATE() 
										,Sal_tran_id =null	
									where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and Sal_tran_id=@Sal_tran_id
								END
							ELSE
								BEGIN
								
									update T0140_ReimClaim_Transacation 
									set Reim_Debit =   Reim_Debit - isnull(@reim_amount,0),--Is null Condition added by Sumit 04042016 error in salary settlement deleting
										Reim_Credit = case WHEN Reim_Sett_CR_Amount > 0 THEN Reim_Credit - Reim_Sett_CR_Amount ELSE Reim_Credit END ,
										Reim_Closing = Reim_Opening + case WHEN Reim_Sett_CR_Amount > 0 THEN Reim_Credit - Reim_Sett_CR_Amount ELSE Reim_Credit END
										,sys_date = GETDATE() 
										,S_Sal_tran_id =null	
										,Reim_Sett_CR_Amount = 0
									where  Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id and S_Sal_tran_id=@S_Sal_tran_id
								END	



								--update T0140_ReimClaim_Transacation set Reim_Opening = Reim_Opening - @Reim_CR_Amount
								--	,Reim_Closing = isnull(Reim_Opening,0) - isnull(@Reim_CR_Amount,0) - isnull(@M_AD_Approval_Amount,0) - isnull(Reim_Debit,0)  ,sys_date = GETDATE()	
								--where  for_date > @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id and rc_id = @RC_Id
								
								----Annkit------
								
								set @Pre_Closing = 0
								select @Pre_Closing = isnull(Reim_Closing,0) from T0140_ReimClaim_Transacation  WITH (NOLOCK)
										 where for_date = (select max(for_date) from T0140_ReimClaim_Transacation WITH (NOLOCK) where for_date <= @For_date  
										 and rc_id = @rc_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
										 and Cmp_ID = @Cmp_ID  
										 and rc_id = @rc_id and emp_Id = @emp_Id  
				       
											 if @Pre_Closing is null  
												set @Pre_Closing = 0  
					        
											declare cur1 cursor for   
												Select reim_tran_id,For_Date from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where rc_id = @rc_id and emp_id = @emp_id   
												and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
											open cur1  
												fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
													while @@fetch_status = 0  
														begin  
					       
																	Begin  
																			update dbo.T0140_ReimClaim_Transacation set   
																			Reim_Opening = @Pre_Closing,  
																			Reim_Closing = @Pre_Closing + isnull(Reim_Credit,0) + isnull(Reim_Sett_CR_Amount,0) - isnull(Reim_Debit,0)
																			where reim_tran_id = @Chg_Tran_Id  
																	   
																		set @Pre_Closing = isnull((select isnull(Reim_Closing,0) from dbo.T0140_ReimClaim_Transacation WITH (NOLOCK) where reim_tran_id = @Chg_Tran_Id),0)  
																	End  
					        
																fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
														end  
											close cur1  
											deallocate cur1 
								----Ankit-----
								
							end
						
					END
				END			
			  fetch next from curDel into  @Cmp_ID,@Emp_Id , @RC_Id,@For_Date,@Sal_tran_id,@Reim_CR_Amount,@S_Sal_tran_id,@for_fnf,@reim_Amount
			end 			
			close curDel
			deallocate curDel


			/***************************
			***** For GPF Balance ******
			***************************/
			
			DECLARE @GPF_TRAN_ID NUMERIC(18,0)
			
			SET @Sal_tran_id = NULL;
			
			SELECT	@Cmp_ID=D.Cmp_ID,@Emp_Id=D.Emp_Id,@For_Date=D.To_date,
					@Sal_tran_id=D.Sal_Tran_ID
			FROM	#DELETED D INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON D.AD_ID = AM.AD_ID 
			WHERE	AM.AD_DEF_ID=14 AND D.Sal_Tran_ID IS NOT NULL
			
			IF (@Sal_tran_id IS NOT NULL)
			BEGIN
				DELETE FROM T0140_EMP_GPF_TRANSACTION 
				WHERE	EMP_ID=@Emp_Id AND SAL_TRAN_ID =@Sal_tran_id AND CMP_ID=@Cmp_ID AND GPF_CREDIT > 0
			END
					
			EXEC dbo.P0140_UPDATE_GPF_CLOSING @Cmp_ID, @Emp_Id, @For_Date
		END
	END




