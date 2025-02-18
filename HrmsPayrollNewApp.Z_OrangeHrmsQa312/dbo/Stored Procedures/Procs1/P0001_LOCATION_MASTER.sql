﻿


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0001_LOCATION_MASTER]
	@LOC_ID NUMERIC OUTPUT, 
	@LOC_NAME VARCHAR(100)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if @LOC_ID is null -- Added by nilesh patel for Loc Name is not Entered (Employee Import)
		Set @LOC_ID = 0
	
	IF @LOC_ID = 0 
		BEGIN
			if not exists(select 1 from T0001_LOCATION_MASTER where Loc_name = @LOC_NAME) 	
			BEGIN
				SELECT @LOC_ID =ISNULL(MAX(LOC_ID),0) +1 FROM T0001_LOCATION_MASTER WITH (NOLOCK)
				INSERT INTO T0001_LOCATION_MASTER
									  (Loc_ID, Loc_name)
				VALUES     (@Loc_ID, @Loc_name)
		END
	END
	ELSE
		BEGIN
			UPDATE T0001_LOCATION_MASTER
			SET Loc_name = @Loc_name
			WHERE LOC_ID =@LOC_ID
		END
	
	RETURN




