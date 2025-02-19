



-- =============================================
-- Author	  :	<Alpesh>
-- ALTER date: <24-Apr-2012>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_LEAVE_CF_SLAB]
	 @Slab_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	,@Effective_Date datetime
	,@Type_ID		numeric(18, 0)
	,@Leave_ID		numeric(18, 0)
	,@From_Days		numeric(18, 2)
	,@To_Days		numeric(18, 2)
	,@CF_Days		numeric(18, 2)
	,@Flag			char(2)
	,@TransType		varchar(1)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @TransType = 'I' OR @TransType = 'U'
		Begin			
			Select @Slab_ID = ISNULL(max(Slab_ID),0)+1 from T0050_LEAVE_CF_SLAB WITH (NOLOCK)
			Insert Into T0050_LEAVE_CF_SLAB
			Values(@Slab_ID,@Cmp_ID,@Effective_Date,@Type_ID,@Leave_ID,@From_Days,@To_Days,@CF_Days,@Flag)						
		End
	Else If @TransType = 'N'
		Begin
			Update T0050_LEAVE_CF_SLAB Set
				 Type_ID = @Type_ID
				,Leave_ID = @Leave_ID
				,From_Days = @From_Days
				,To_Days = @To_Days
				,CF_Days = @CF_Days
				,SLAB_Flag=@Flag
				,Effective_Date = @Effective_Date
			Where Slab_ID = @Slab_ID			
		End
	Else If @TransType = 'D'
		Begin
			Delete from T0050_LEAVE_CF_SLAB where Slab_ID=@Slab_ID
	    End
END



