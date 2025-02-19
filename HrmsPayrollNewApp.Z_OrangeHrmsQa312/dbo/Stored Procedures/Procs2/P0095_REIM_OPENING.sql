
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0095_REIM_OPENING]
  @Reim_Op_ID as numeric output 
 ,@Emp_ID  as numeric
 ,@CMP_Id as numeric
 ,@RC_ID as numeric
 ,@Reim_Opening_Amount as numeric(18,2)
 ,@for_date  as datetime
 ,@tran_type as varchar(1)
 ,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
 ,@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
-- Add By Mukti 11072016(end)

	if @tran_type = 'I'
		begin
			
			SELECT @Reim_Op_ID = ISNULL(MAX(Reim_Op_ID),0) + 1 FROM Dbo.T0095_Reim_Opening WITH (NOLOCK)
				
			INSERT INTO T0095_Reim_Opening (
						Reim_Op_ID,                              
						Emp_ID,                                  
						Cmp_ID ,                                 
						RC_ID  ,                                 
						For_Date,                
						Reim_Opening_Amount,
						User_ID,
						System_Date)
			VALUES     (@Reim_Op_ID,@Emp_Id,@Cmp_ID,@RC_ID,@For_Date,@Reim_Opening_Amount,@User_Id,GETDATE())
			
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table = 'T0095_Reim_Opening' ,@key_column='Reim_Op_ID',@key_Values=@Reim_Op_ID,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
			-- Add By Mukti 11072016(end)		
		end
	ELSE IF @tran_type = 'U'
		begin
		
			If Exists(select Emp_ID From Dbo.T0095_Reim_Opening WITH (NOLOCK) Where Emp_ID= @Emp_ID and RC_ID =@RC_ID and For_Date = @for_Date)
				Begin
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table='T0095_Reim_Opening' ,@key_column='Reim_Op_ID',@key_Values=@Reim_Op_ID,@String=@String_val output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
					-- Add By Mukti 11072016(end)
				
					UPDATE    Dbo.T0095_Reim_Opening
					SET       Reim_Opening_Amount = @Reim_Opening_Amount
					where     CMP_Id = @CMP_Id and  Emp_Id = @Emp_Id and RC_ID =@RC_ID and For_Date = @For_Date 
					
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table = 'T0095_Reim_Opening' ,@key_column='Reim_Op_ID',@key_Values=@Reim_Op_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
					-- Add By Mukti 11072016(end)					
				End
			else
				Begin
					
					SELECT @Reim_Op_ID = ISNULL(MAX(Reim_Op_ID),0) + 1 FROM Dbo.T0095_Reim_Opening WITH (NOLOCK)
				
						
					INSERT INTO Dbo.T0095_Reim_Opening(
								Reim_Op_ID,                              
								Emp_ID,                                  
								Cmp_ID ,                                 
								RC_ID  ,                                 
								For_Date,                
								Reim_Opening_Amount,
								User_ID,
								System_Date) 
					VALUES     (@Reim_Op_ID,@Emp_Id,@Cmp_ID,@RC_ID,@For_Date,@Reim_Opening_Amount,@User_Id,GETDATE())
					
					-- Add By Mukti 11072016(start)
						exec P9999_Audit_get @table = 'T0095_Reim_Opening' ,@key_column='Reim_Op_ID',@key_Values=@Reim_Op_ID,@String=@String_val output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
				-- Add By Mukti 11072016(end)		
				End
			return @Reim_Op_ID
			
		end		
	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Reimbursement Opening',@OldValue,@Emp_Id,@User_Id,@IP_Address,1
RETURN




