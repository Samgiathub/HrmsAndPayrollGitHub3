


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 06-06-2019
-- Description:	Set Date Wise Amount for Disability,Medical,Hostel
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_IT_MAX_LIMIT_DYNAMIC]
	@From_Date Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @From_Date > '01-Apr-2000' 
	  Begin
		Select 75000 as Normal_Disability,
			   125000 as Severe_Disability,
			   40000 as Max_Limit_80DDB_Below_60,
			   100000 as Max_Limit_80DDB_Above_60,
			   300 as Hostel_Per_Child
	  End
END

