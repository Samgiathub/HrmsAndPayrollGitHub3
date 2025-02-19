

create  PROCEDURE [dbo].[P0110_Training_Induction_Details_aswini] 
	 @Tran_ID Numeric(18,0) output
	,@Training_Induction_ID Numeric(18,0)
	,@Cmp_Id Numeric(18,0)
	,@Training_Date  datetime
	,@Training_Time	 Datetime
	,@Emp_ID Numeric(18,0)	
	,@Trans_Type char(1)
	,@User_Id numeric(18,0) = 0 
    ,@IP_Address varchar(30)= '' 
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	If @Trans_Type  = 'I' 
		Begin
	   
			If not Exists(select Tran_ID From T0110_Training_Induction_Details WITH (NOLOCK) Where Training_Induction_ID=@Training_Induction_ID and emp_id=@emp_id)
				Begin
					select @Tran_ID = Isnull(max(Tran_ID),0) + 1 	From T0110_Training_Induction_Details WITH (NOLOCK)
					INSERT INTO T0110_Training_Induction_Details
							(Tran_ID,Training_Induction_ID,Cmp_Id,Emp_ID,Training_Date,Training_Time,Modify_By,Modify_Date,IP_Address)    
					VALUES(@Tran_ID,@Training_Induction_ID,@Cmp_Id,@Emp_ID,@Training_Date,@Training_Time,@User_Id,getdate(),@IP_Address) 
				End
			ELSE
				BEGIN		
					update T0110_Training_Induction_Details
					set Training_Date=@Training_Date,Training_Time=@Training_Time
					Where Training_Induction_ID=@Training_Induction_ID and emp_id=@emp_id	
				END
				
		End
			
	Else If @Trans_Type = 'D'
		begin
			Delete From T0110_Training_Induction_Details Where Tran_ID=@Tran_ID		
		end
	
RETURN
