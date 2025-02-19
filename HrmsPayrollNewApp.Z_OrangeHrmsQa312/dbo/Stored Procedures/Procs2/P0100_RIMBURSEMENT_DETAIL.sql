



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_RIMBURSEMENT_DETAIL]
	@RIMB_TRAN_ID numeric output
   ,@RIMB_ID numeric
   ,@Cmp_ID numeric
   ,@EMP_ID numeric
   ,@FOR_DATE datetime
   ,@RIMB_AMOUNT numeric
   ,@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @tran_type  = 'I'
		Begin
	
				--delete from T0100_RIMBURSEMENT_DETAIL where RIMB_ID = @RIMB_ID and Cmp_ID = @Cmp_ID and 
				--			Emp_ID = Emp_ID and FOR_DATE = @FOR_DATE  
				If Exists(select Rimb_Tran_ID From 	T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) where RIMB_ID = @RIMB_ID and Cmp_ID = @Cmp_ID and 
							Emp_ID = @Emp_ID and FOR_DATE = @FOR_DATE  )
					Begin
							UPDATE    T0100_RIMBURSEMENT_DETAIL
							SET              RIMB_ID = @RIMB_ID, 
											 RIMB_AMOUNT = @RIMB_AMOUNT,
											 FOR_DATE = @FOR_DATE 
							where RIMB_ID = @RIMB_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and FOR_DATE = @FOR_DATE  
					End
				else
					Begin
						select @RIMB_TRAN_ID = Isnull(max(RIMB_TRAN_ID),0) + 1 	From T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK)
						
						INSERT INTO T0100_RIMBURSEMENT_DETAIL
											  (RIMB_TRAN_ID, RIMB_ID,Emp_ID,Cmp_ID,RIMB_AMOUNT,FOR_DATE)
						VALUES     (@RIMB_TRAN_ID,@RIMB_ID,@Emp_ID,@Cmp_ID,@RIMB_AMOUNT,@FOR_DATE)
					End
		End
	Else if @Tran_Type = 'U'
		begin
			IF Exists(select RIMB_TRAN_ID From T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) Where RIMB_ID = @RIMB_ID and Cmp_ID = @Cmp_ID and 
							Emp_ID = @Emp_ID and FOR_DATE = @FOR_DATE and  RIMB_TRAN_ID <> @RIMB_TRAN_ID)
				Begin
					set @RIMB_TRAN_ID = 0
					Return 
				End
					
				UPDATE    T0100_RIMBURSEMENT_DETAIL
				SET              RIMB_ID = @RIMB_ID, 
				                 RIMB_AMOUNT = @RIMB_AMOUNT,
				                 FOR_DATE = @FOR_DATE 
				where RIMB_TRAN_ID = @RIMB_TRAN_ID
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0100_RIMBURSEMENT_DETAIL Where RIMB_TRAN_ID = @RIMB_TRAN_ID
		end

	
	RETURN




