



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Return_Without_Sec]

 @Totsec as numeric 
,@Return_Without_Sec as numeric output

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
	declare @intHour as numeric
	declare @intMin as numeric
	declare @intSec as numeric

	set @intHour = 0
	set @intSec = 0

	if @TotSec >= 3600
		set @intHour = floor((@TotSec / 3600))
	else
		set @intHour = 0
	
	set @TotSec = @TotSec - (@intHour * 3600)
	
	if @TotSec >= 60
		set @intMin = floor(@TotSec /60)
	else
		set @intMin = 0

   
    
    set @Return_Without_Sec = (@intHour * 3600)
    set @Return_Without_Sec = @Return_Without_Sec + (@intMin * 60)

	
	RETURN 




