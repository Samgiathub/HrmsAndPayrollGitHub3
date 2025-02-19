



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_COMPANY_LEAVE_TRANSFER]
	 @Row_ID 		Numeric output
	,@Leave_Tran_ID Numeric output
	,@Tran_Id		Numeric
	,@Cmp_ID		Numeric
	,@Emp_ID		Numeric
	,@Leave_Id		Numeric
	,@Old_Balance   Numeric(18,2)
	,@Curr_Emp_ID	Numeric
	,@Curr_Cmp_ID	Numeric
	,@Curr_Leave_Id Numeric
	,@New_Balance	Numeric(18,2)
	,@For_Date		DateTime
	,@Leave_Row_Id	Numeric
	,@Tran_Type		varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	If @Tran_Type ='I' 
			Begin

				IF Exists(Select 1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK) where  Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Leave_ID = @Curr_Leave_Id 
						   AND For_date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
											WHERE Emp_ID = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Leave_ID = @Curr_Leave_Id))
				Begin
					Update T0140_LEAVE_TRANSACTION
					Set    Leave_Closing = 0 ,
						   Leave_Posting = @Old_Balance
					where  Emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Leave_ID =@Curr_Leave_Id
						   AND For_date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										WHERE emp_id = @Curr_Emp_ID AND Cmp_ID = @Curr_Cmp_ID And Leave_ID = @Curr_Leave_Id)
				End
				
				Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 	From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				
					INSERT INTO T0140_LEAVE_TRANSACTION
						(Leave_Tran_ID
						,Cmp_ID
						,Leave_ID
						,Emp_ID
						,For_Date
						,Leave_Opening
						,Leave_Credit,Leave_Used,Leave_Closing,Leave_Posting
						)
					VALUES   
						(@Leave_Tran_ID
						,@Cmp_ID
						,@Leave_Id
						,@Emp_ID
						,@For_Date
						,@New_Balance
						,0,0,@New_Balance,0
						)
			
			Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_LEAVE_TRANSFER WITH (NOLOCK)
															
					INSERT INTO T0100_EMP_COMPANY_LEAVE_TRANSFER
						(Row_Id
						,Tran_Id
						,Cmp_ID
						,Emp_Id
						,Leave_Id
						,Old_Balance
						,New_Cmp_Id
						,New_Emp_Id
						,New_Leave_Id
						,New_Balance
						,Leave_Row_Id
						)
					VALUES   
						(@Row_Id
						,@Tran_Id
						,@Curr_Cmp_ID
						,@Curr_Emp_ID
						,@Curr_Leave_Id
						,@Old_Balance
						,@Cmp_ID
						,@Emp_ID
						,@Leave_Id
						,@New_Balance
						,@Leave_Row_Id
						)	
			END
	Else If @Tran_Type ='U' 
			begin
				DELETE FROM T0140_LEAVE_TRANSACTION WHERE Leave_ID = @Leave_Id and Emp_ID = @Emp_ID-- Leave_Tran_ID = @Leave_Tran_ID
				DELETE FROM T0100_EMP_COMPANY_LEAVE_TRANSFER WHERE Tran_Id=@Tran_ID and New_Leave_Id = @Leave_Id
				
				Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 	From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_LEAVE_TRANSFER WITH (NOLOCK)
				
					INSERT INTO T0140_LEAVE_TRANSACTION
							(Leave_Tran_ID
							,Cmp_ID
							,Leave_ID
							,Emp_ID
							,For_Date
							,Leave_Opening
							,Leave_Credit,Leave_Used,Leave_Closing,Leave_Posting
							)
						VALUES   
							(@Leave_Tran_ID
							,@Cmp_ID
							,@Leave_Id
							,@Emp_ID
							,@For_Date
							,@New_Balance
							,0,0,@New_Balance,0
							)
					
					INSERT INTO T0100_EMP_COMPANY_LEAVE_TRANSFER
							(Row_Id
							,Tran_Id
							,Cmp_ID
							,Emp_Id
							,Leave_Id
							,Old_Balance
							,New_Cmp_Id
							,New_Emp_Id
							,New_Leave_Id
							,New_Balance
							,Leave_Row_Id
							)
						VALUES   
							(@Row_Id
							,@Tran_Id
							,@Curr_Cmp_ID
							,@Curr_Emp_ID
							,@Curr_Leave_Id
							,@Old_Balance
							,@Cmp_ID
							,@Emp_ID
							,@Leave_Id
							,@New_Balance
							,@Leave_Row_Id
							)		
					
			End
	else if @Tran_Type ='D'
			Begin
				DELETE FROM T0140_LEAVE_TRANSACTION where Leave_Tran_ID = @Leave_Tran_ID
				DELETE FROM T0100_EMP_COMPANY_LEAVE_TRANSFER WHERE Row_Id = @Row_Id And Tran_Id=@Tran_Id
			End
			
RETURN

