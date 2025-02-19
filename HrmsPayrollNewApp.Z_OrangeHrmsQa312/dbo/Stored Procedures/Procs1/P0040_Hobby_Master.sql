
CREATE PROCEDURE [dbo].[P0040_Hobby_Master]
	  @Hobby_ID numeric(18) output
	 ,@Hobby varchar(100)
	 ,@Cmp_ID numeric(18,0)
	

AS
	begin

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if exists (Select H_ID  from T0040_Hobby_Master WITH (NOLOCK) Where Upper(HobbyName) = Upper(@Hobby) and Cmp_ID=@Cmp_ID) 
				begin
					set @Hobby_ID=0
					return
				end
			else
				begin
					select @Hobby_ID = isnull(max(H_ID),0) +1  from T0040_Hobby_Master WITH (NOLOCK)
					insert into T0040_Hobby_Master(HobbyName,Cmp_ID) values(@Hobby,@Cmp_ID)
				end
		end 

	RETURN




