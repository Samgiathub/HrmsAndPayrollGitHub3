
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_Faculty_Rating_Details]
	@Faculty_Rating_Id AS NUMERIC output,
	@CMP_ID NUMERIC,
	@Training_Apr_ID  numeric,
	@Faculty_ID	numeric,
	@Rating numeric(18,2),
	@Comments varchar(500),
	@tran_type varchar(1),
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '' 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @tran_type  = 'I'
		Begin
			--if NOT EXISTS(select 1 from T0110_Faculty_Rating_Details where Cmp_ID=@CMP_ID and Training_Apr_ID=@Training_Apr_ID and Faculty_ID=@Faculty_ID)
				--BEGIN
					select @Faculty_Rating_Id= Isnull(max(Faculty_Rating_Id),0) + 1 	From T0110_Faculty_Rating_Details WITH (NOLOCK)
			
					insert into T0110_Faculty_Rating_Details(Faculty_Rating_Id,Cmp_ID,Training_Apr_ID,Faculty_ID,Rating,Comments)
					VALUES(@Faculty_Rating_Id,@Cmp_ID,@Training_Apr_ID,@Faculty_ID,@Rating,@Comments)	
				--END
			--ELSE
			--	BEGIN 
			--		update T0110_Faculty_Rating_Details set Rating=@Rating
			--		where Cmp_ID=@CMP_ID and Training_Apr_ID=@Training_Apr_ID and Faculty_ID=@Faculty_ID
			--	END
		end	
	RETURN




