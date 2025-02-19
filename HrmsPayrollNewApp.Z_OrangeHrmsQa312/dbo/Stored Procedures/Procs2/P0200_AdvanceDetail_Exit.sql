



-- =============================================
-- Author:		
-- ALTER date: 08 june 2012
-- Description:	Advance detail
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_AdvanceDetail_Exit]
	@Cmp_ID as numeric(18,0),
	@Todate as datetime,
	@Emp_Id as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @datevalue datetime 
declare @month_part varchar(2)
declare @fordate datetime
declare @month as varchar(2)
declare @saldate datetime
declare @sal_month as varchar(2)

set @datevalue = @Todate
set @month_part = DATEPART(mm,@datevalue)

set @sal_month = DATEPART(mm,@saldate) 


If @Cmp_ID<> 0
	Begin
		Select @saldate=Max(Sal_Generate_Date) From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_Id
		If @saldate <> Null
			Begin
				set @sal_month = DATEPART(mm,@saldate)
				If @saldate < @datevalue	
					Begin
						select @fordate=for_date from V0100_ADVANCE_PAYMENT where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
						set @month = DATEPART(mm,@fordate)
						select * from V0100_ADVANCE_PAYMENT where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and For_Date > @saldate
					End
			End
		Else
			Begin
				select * from V0100_ADVANCE_PAYMENT where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id 
			End	
				
	End
 
END



