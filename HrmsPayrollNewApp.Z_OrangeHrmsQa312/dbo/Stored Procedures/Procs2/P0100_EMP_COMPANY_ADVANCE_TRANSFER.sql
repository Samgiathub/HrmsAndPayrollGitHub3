

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_COMPANY_ADVANCE_TRANSFER]
	 @Row_ID 		Numeric output
	,@Adv_Tran_ID 	Numeric output
	,@Tran_Id		Numeric
	,@Emp_ID		Numeric
	,@Cmp_ID		Numeric
	,@For_Date		DateTime
	,@Old_Balance   Numeric
	,@Adv_Amount	Numeric
	,@Curr_Emp_ID	Numeric
	,@Curr_Cmp_ID	Numeric
	,@Tran_Type		varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	If @tran_type ='I' 
			begin
			
				IF Exists (Select 1 From T0100_EMP_COMPANY_ADVANCE_TRANSFER AT WITH (NOLOCK) Inner Join T0095_EMP_COMPANY_TRANSFER CT WITH (NOLOCK) ON AT.Tran_Id = CT.Tran_Id Where AT.Tran_Id=@Tran_Id And CT.Effective_Date = @For_Date)
					Begin
						Select @Tran_Id
						Return
					End
				
			 --  If exists( Select 1 From T0140_Advance_Transaction WHERE Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID AND 
				--	For_date = (SELECT MAX(for_date) FROM T0140_Advance_Transaction WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID))
					
				--	Begin
				--		Update  T0140_Advance_Transaction
				--		Set		Adv_Closing = 0
				--		where	Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID 
				--				AND For_date = (SELECT MAX(for_date) FROM T0140_Advance_Transaction 
				--								WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID)
				--	End
					
				--Select @Adv_Tran_ID = Isnull(max(Adv_Tran_ID),0) + 1 	From T0140_ADVANCE_TRANSACTION
																
				--			INSERT INTO T0140_ADVANCE_TRANSACTION
				--			(Adv_Tran_ID
				--			,Cmp_ID
				--			,Emp_ID
				--			,For_Date
				--			,Adv_Opening
				--			,Adv_Closing,Adv_Issue,Adv_Return
				--			)
				--			VALUES   
				--			(@Adv_Tran_ID
				--			,@Cmp_ID
				--			,@Emp_ID
				--			,@For_Date
				--			,@Adv_Amount
				--			,@Adv_Amount,0,0
				--			)
				
			--added jimit 02122015	
				if EXISTS(select 1 FROM T0100_ADVANCE_PAYMENT WITH (NOLOCK) where Emp_ID = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_Id
							and For_Date = (SELECT Max(for_date) from T0100_ADVANCE_PAYMENT WITH (NOLOCK) where emp_id = @Curr_Emp_ID and cmp_id = @Curr_cmp_ID))
							
							BEGIN
									
									UPDATE T0100_ADVANCE_PAYMENT
									set Adv_Amount =  0
									where	Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID 
											AND For_date = (SELECT MAX(for_date) FROM T0100_ADVANCE_PAYMENT WITH (NOLOCK)
															WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID)
									
							END
							
				Select @Adv_Tran_ID = Isnull(max(Adv_ID),0) + 1 	From T0100_ADVANCE_PAYMENT WITH (NOLOCK)
							
							print 	@Adv_Tran_ID								
							INSERT INTO T0100_ADVANCE_PAYMENT
							(Adv_ID
							,Cmp_ID
							,Emp_ID
							,For_Date
							,Adv_Approx_Salary
							,Adv_Amount,Adv_Comments,Adv_P_Days,Adv_Approval_ID
							)
							VALUES   
							(@Adv_Tran_ID
							,@Cmp_ID
							,@Emp_ID
							,@For_Date
							,0
							,@Adv_Amount,'Company Transfer',0,0
							)			
							
										
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_ADVANCE_TRANSFER WITH (NOLOCK)
																
							INSERT INTO T0100_EMP_COMPANY_ADVANCE_TRANSFER
							(Row_Id
							,Tran_Id
							,Cmp_ID
							,Old_Balance
							,New_Cmp_Id
							,New_Balance
							)
							VALUES   
							(@Row_Id
							,@Tran_Id
							,@Curr_Cmp_ID
							,@Old_Balance
							,@Cmp_ID
							,@Adv_Amount
							)
							
							--ended	
			END
	else if @tran_type ='U' 
			begin
				
				--IF Exists (Select 1 From T0140_ADVANCE_TRANSACTION Where Emp_ID=@Emp_ID And For_Date=@For_Date And Adv_Opening = @Adv_Amount)
				--	Begin
				--		Select @Tran_Id
				--		Return
				--	End
					
				--DELETE FROM T0140_ADVANCE_TRANSACTION WHERE Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And For_Date=@For_Date
				--DELETE FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WHERE Tran_Id=@Tran_Id-- And Tran_Id=@Adv_Tran_ID
				
				--Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_ADVANCE_TRANSFER
				--Select @Adv_Tran_ID = Isnull(max(Adv_Tran_ID),0) + 1 	From T0140_ADVANCE_TRANSACTION
				
				--INSERT INTO T0140_ADVANCE_TRANSACTION
				--	(Adv_Tran_ID
				--	,Cmp_ID
				--	,Emp_ID
				--	,For_Date
				--	,Adv_Opening
				--	,Adv_Closing,Adv_Issue,Adv_Return
				--	)
				--VALUES   
				--	(@Adv_Tran_ID
				--	,@Cmp_ID
				--	,@Emp_ID
				--	,@For_Date
				--	,@Adv_Amount
				--	,@Adv_Amount,0,0
				--	)
				-------added  jimit 02122015	
				IF Exists (Select 1 From T0100_ADVANCE_PAYMENT WITH (NOLOCK) Where Emp_ID=@Emp_ID And For_Date=@For_Date And Adv_Amount = @Adv_Amount)
					Begin
						Select @Tran_Id
						Return
					End
					
				DELETE FROM T0100_ADVANCE_PAYMENT WHERE Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And For_Date=@For_Date
				DELETE FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WHERE Tran_Id=@Tran_Id-- And Tran_Id=@Adv_Tran_ID
				
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_ADVANCE_TRANSFER WITH (NOLOCK)
				Select @Adv_Tran_ID = Isnull(max(Adv_ID),0) + 1 	From T0100_ADVANCE_PAYMENT WITH (NOLOCK)
				
				INSERT INTO T0100_ADVANCE_PAYMENT
					(Adv_ID
					,Cmp_ID
					,Emp_ID
					,For_Date
					,Adv_Approx_Salary
					,Adv_Amount,Adv_Comments,Adv_P_Days,Adv_Approval_ID
					)
				VALUES   
					(@Adv_Tran_ID
					,@Cmp_ID
					,@Emp_ID
					,@For_Date
					,0
					,@Adv_Amount,'Company Transfer',0,0
					)
				----------ended---------------
				
				INSERT INTO T0100_EMP_COMPANY_ADVANCE_TRANSFER
					(Row_Id
					,Tran_Id
					,Cmp_ID
					,Old_Balance
					,New_Cmp_Id
					,New_Balance
					)
				VALUES   
					(@Row_Id
					,@Tran_Id
					,@Curr_Cmp_ID
					,@Old_Balance
					,@Cmp_ID
					,@Adv_Amount
					)			
					
			End
	else if @tran_type ='D'
			Begin
				--DELETE FROM T0140_ADVANCE_TRANSACTION where Adv_Tran_ID = @Adv_Tran_ID
				DELETE FROM T0100_ADVANCE_PAYMENT where Adv_ID = @Adv_Tran_ID
				DELETE FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WHERE Row_Id = @Row_Id And Tran_Id=@Tran_Id
			End
			
RETURN

