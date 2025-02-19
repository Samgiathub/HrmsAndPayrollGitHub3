

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_Relationship_Master]
	  @Relationship_ID numeric(18) output
	 ,@Relationship varchar(100)
	 ,@Cmp_ID numeric(18,0)
	

AS
	begin

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if exists (Select Relationship_ID  from t0040_Relationship_Master WITH (NOLOCK) Where Upper(Relationship) = Upper(@Relationship) and Cmp_ID=@Cmp_ID) 
				begin
					set @Relationship_ID=0
					return
				end
			else
				begin
					select @Relationship_ID = isnull(max(Relationship_ID),0) +1  from t0040_Relationship_Master WITH (NOLOCK)
					insert into t0040_Relationship_Master(Relationship_ID,Relationship,Cmp_ID) values(@Relationship_ID,@Relationship,@Cmp_ID)
				end
		end 

	RETURN




