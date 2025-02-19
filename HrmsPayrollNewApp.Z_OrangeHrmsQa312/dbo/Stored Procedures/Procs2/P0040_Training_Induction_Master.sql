
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_Training_Induction_Master] 
	 @Training_Induction_ID	Numeric(18,0) output
	,@Dept_ID			Numeric(18,0)
	,@Training_id		Numeric(18,0)		
	,@Cmp_Id	        Numeric(18,0)
	,@Trans_Type        char(1)
	,@Contact_Person_ID	varchar(max)
	,@User_Id			numeric(18,0) = 0
    ,@IP_Address		varchar(30)= ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Trans_Type  = 'I' 
		Begin
	   
				If Exists(select Training_Induction_ID From T0040_Training_Induction_Master WITH (NOLOCK) Where Training_id = @Training_id and  Dept_ID=@Dept_ID and Contact_Person_ID=@Contact_Person_ID and Cmp_Id = @Cmp_Id)
						Begin
							set @Training_Induction_ID = 0
							return 
						End
						
				   select @Training_Induction_ID = Isnull(max(Training_Induction_ID),0) + 1 From T0040_Training_Induction_Master WITH (NOLOCK) 
					INSERT INTO T0040_Training_Induction_Master
							(Training_Induction_ID,Cmp_ID,Dept_ID,Training_id,Contact_Person_ID)    
				    VALUES(@Training_Induction_ID,@Cmp_ID,@Dept_ID,@Training_id,@Contact_Person_ID)   
		End
		
	Else if @Trans_Type = 'U'
 		begin
			If Exists(select Training_Induction_ID From T0040_Training_Induction_Master WITH (NOLOCK) Where Training_id = @Training_id and  Dept_ID=@Dept_ID and Contact_Person_ID=@Contact_Person_id and Cmp_Id = @Cmp_Id and Training_Induction_ID <> @Training_Induction_ID)
				begin
					set @Training_Induction_ID = 0
					return 
				end				
								 
				UPDATE    T0040_Training_Induction_Master
				SET          
							Contact_Person_ID=@Contact_Person_ID,
							Training_id=@Training_id,
							Dept_ID=@Dept_ID
				where Training_Induction_ID = @Training_Induction_ID				
		end
	Else If @Trans_Type = 'D'
		begin
			Delete From T0040_Training_Induction_Master Where Training_Induction_ID = @Training_Induction_ID				
		end
	
RETURN
