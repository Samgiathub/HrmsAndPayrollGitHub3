


-- =============================================
-- Author:		Hardik Barot
-- ALTER date: 18/09/2012
-- Description:	For Checking Leave reset Year
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_CHECK_LEAVE_RESET_YEAR]
	@For_Date datetime,
	@Effective_Date datetime,
	@Reset_Month Numeric,
	@Flag varchar(3) Output,
	@Date Datetime Output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Set @Flag = 'NO'


	While @Effective_Date < @For_date
		Begin
		
			Set @Effective_Date = DATEADD(M,@reset_month,@Effective_Date)
		
			If YEAR(@Effective_Date) =YEAR(@For_date)
				Begin
					Set @Flag = 'YES'
					Set @Date = @Effective_Date
				End
			Else
				Begin
					Set @Flag = 'NO'
					Set @Date = @Effective_Date
				End
		End 

END
Return


