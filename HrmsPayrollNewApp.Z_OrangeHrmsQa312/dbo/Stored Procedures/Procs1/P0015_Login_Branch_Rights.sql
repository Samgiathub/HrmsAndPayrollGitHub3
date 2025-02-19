



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0015_Login_Branch_Rights]
		  @Tran_ID		numeric(18,0)	output
		 ,@Login_ID		numeric(18,0)
		 ,@Cmp_ID		numeric
		 ,@Branch_ID	numeric(18,0)
		 ,@tran_Type	varchar(1)	
AS	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Branch_ID Is null
		Set @Branch_Id = 0
	
	if @Branch_ID = 0 
		begin
			if @Login_ID > 0   -- this is temporary code
				Begin				
					Delete from dbo.T0015_Login_Branch_Rights Where Login_ID =@Login_ID 	
				End
			return 
		end

	If @tran_type ='I' 
		  Begin						  
			 Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from dbo.T0015_Login_Branch_Rights WITH (NOLOCK)			 
			 Select @Login_ID= isnull(Max(Login_ID),0) from T0015_Login_form_rights WITH (NOLOCK) where Cmp_ID=@Cmp_ID
--Nikunj 21-04-2011
---Above Please Don't DO Max+1 becuase here max is ok.becuase it already insert in T0015_Login_form_rights form and we take that max from T0015_Login_form_rights.

			If exists(Select Login_ID from dbo.T0015_Login_Branch_Rights WITH (NOLOCK) Where Login_ID=@Login_ID)--Put By nikunj 21-04-2011
				 Begin
					Set @Tran_ID=-1
					Return
				 End
			 Else
				Begin
					 Insert into dbo.T0015_Login_Branch_Rights
					(Tran_ID,cmp_ID,Branch_ID,Login_ID) values(@Tran_ID,@cmp_ID,@Branch_ID,@Login_ID)
					
					If @Branch_ID<>0 --This Condition Put by nikunj 21-04-2011.becuase we have to update at login table also.
					Begin
						Update dbo.T0011_LOGIN Set Branch_Id=@Branch_Id where Login_Id=@Login_Id And Cmp_Id=@Cmp_Id	And Is_Default<>3
					End
				End
		End				
	Else if @tran_type ='U'
		 Begin 
			if exists( select Login_ID from dbo.T0015_Login_Branch_Rights WITH (NOLOCK) Where Login_ID=@Login_ID)
				Begin
					Update dbo.T0015_Login_Branch_Rights
					Set Branch_ID =@Branch_ID  Where Login_ID=@Login_ID And Cmp_Id=@Cmp_ID
					
					If @Branch_ID<>0 --This Condition Put by nikunj 21-04-2011.becuase we have to update at login table also.
					Begin
						Update dbo.T0011_LOGIN Set Branch_Id=@Branch_Id where Login_Id=@Login_Id And Cmp_Id=@Cmp_Id And Is_Default<>3
					End					
				End
			else	
				Begin				
					 Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from dbo.T0015_Login_Branch_Rights WITH (NOLOCK)
					 Insert into dbo.T0015_Login_Branch_Rights
						(Tran_ID,cmp_ID,Branch_ID,Login_ID) values(@Tran_ID,@cmp_ID,@Branch_ID,@Login_ID)
						
					If @Branch_ID<>0 --This Condition Put by nikunj 21-04-2011.becuase we have to update at login table also.
					Begin
						Update dbo.T0011_LOGIN Set Branch_Id=@Branch_Id where Login_Id=@Login_Id And Cmp_Id=@Cmp_Id And Is_Default<>3
					End						
				End
		 End
	RETURN




