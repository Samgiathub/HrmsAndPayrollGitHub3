
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_REJOIN_EMP]
	  @Tran_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Emp_ID numeric(18,0)
	 ,@Left_Date datetime
	 ,@Rejoin_Date datetime
	 ,@Remarks varchar(200)
	 ,@System_Date datetime	 
	 ,@Tran_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	if isnull(@Rejoin_Date,'') = ''
		set @Rejoin_Date = null
			
		
	If @tran_type ='I' 
		Begin
			Select @Tran_ID= isnull(max(TRAN_ID),0) + 1  from T0100_REJOIN_EMP WITH (NOLOCK)

			Insert Into T0100_REJOIN_EMP
				(Tran_ID,Cmp_ID,Emp_ID,Left_Date,Rejoin_date,Remarks,System_Date)
			values
				(@Tran_ID,@Cmp_ID,@Emp_ID,@Left_Date,@Rejoin_Date,@Remarks,@System_Date)
			
			
			UPDATE T0080_EMP_MASTER 
			SET EMP_LEFT  = 'N' , Emp_Left_Date = Null--, Date_Of_Join = @Rejoin_Date
			WHERE EMP_ID = @EMP_ID

			EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Rejoin_Date,'','',0
			
			--delete from T0100_LEFT_EMP where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID
		End 
		
	Else if @tran_type ='U' 
			begin
			
				
				If exists (select Rejoin_Date from T0100_REJOIN_EMP WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Emp_Id=@Emp_ID and Rejoin_Date>@Rejoin_Date)
					Begin 
						--select @Tran_ID=0
						RAISERROR ('Rejoin Employee Detail cant be Update', -- Message text.
									16, -- Severity.
									1   -- State.
									);
						Return
					End
					
				Update T0100_REJOIN_EMP 
				Set Left_Date = @Left_Date,
					Rejoin_Date= @Rejoin_Date,
					Remarks = @Remarks,
					System_Date = @System_Date
				Where Tran_ID = @Tran_ID and Cmp_ID = @Cmp_ID 
				
				UPDATE T0080_EMP_MASTER 
				SET EMP_LEFT  = 'N' , Emp_Left_Date = Null--,  Date_Of_Join = @Rejoin_Date
				WHERE EMP_ID = @EMP_ID
				
				EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Rejoin_Date,'','',0
				
			end	
	Else If @tran_type ='D'
			Begin
				
				If exists (select Rejoin_Date from T0100_REJOIN_EMP WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Emp_Id=@Emp_ID and Rejoin_Date>@Rejoin_Date)
					Begin 
						--select @Tran_ID=0
						RAISERROR ('Rejoin Date is Exists', -- Message text.
									16, -- Severity.
									1   -- State.
									);
						Return
					End	
				Else If exists (select Left_Date from T0100_LEFT_EMP WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Emp_Id=@Emp_ID and Left_Date > @Rejoin_Date)
					Begin 
						--select @Tran_ID=0
						RAISERROR ('Left Date is Exists', -- Message text.
									16, -- Severity.
									1   -- State.
									);
						Return
					End						
				Else	
					Begin
						--Declare @Old_Join_Date as Datetime
				
						delete  from T0100_REJOIN_EMP where Tran_Id = @Tran_ID
						Delete From T0110_EMP_LEFT_JOIN_TRAN where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Join_Date=@Rejoin_Date

						--Set @Old_Join_Date = 
						--	(Select Max(Join_Date) From T0110_EMP_LEFT_JOIN_TRAN Where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID And Join_Date < @Rejoin_Date)
					--If Exists(Select Max(Left_Date) From T0110_EMP_LEFT_JOIN_TRAN Where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID And Left_Date < @Left_Date)
						Begin
							UPDATE T0080_EMP_MASTER 
							SET EMP_LEFT  = 'Y' , EMP_LEFT_DATE = @Left_Date--, Date_Of_Join = @Old_Join_Date
							WHERE EMP_ID = @EMP_ID
						End
					
					End
			End

	RETURN


