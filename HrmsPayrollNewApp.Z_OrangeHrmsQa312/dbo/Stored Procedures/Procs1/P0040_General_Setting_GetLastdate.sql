


--Created By Ramiz on 13-09-2014------
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_General_Setting_GetLastdate] 
	@cmp_ID numeric,
	@Branch_ID numeric,
	@For_date_New Datetime
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  declare @for_Date as datetime
  
	Select @for_Date=For_Date from T0040_General_setting WITH (NOLOCK) where cmp_ID =@cmp_ID and Branch_ID=@Branch_ID and For_Date <= @For_date_New order by For_Date 
	Select * from T0040_General_Setting WITH (NOLOCK) where for_date=@for_Date and cmp_id=@Cmp_ID 
	
	RETURN


