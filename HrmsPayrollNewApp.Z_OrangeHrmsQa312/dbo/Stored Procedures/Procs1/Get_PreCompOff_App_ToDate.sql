


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <21/May/2015>
-- Description:	< Get Pre CompOff Application  To Date>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PreCompOff_App_ToDate]
@From_Date datetime,
@Period	   numeric(18,2)	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	Declare @To_Date as datetime
	set @Period = @Period - 1
	If isnull(@Period,0) >= 0
		begin
			set @To_Date = DATEADD(d,Floor(@period),@From_date)
			if @Period - FLOOR(@Period) > 0 
				begin
					set @To_Date = DateAdd(d,1,@to_Date)
				end
		end 
	ELSE	--Ankit For Half Day Pre-Compoff --13072016
		BEGIN
			set @To_Date = DATEADD(dd,@Period, @From_Date)
		END	
    
	select @To_Date as To_Date
END

