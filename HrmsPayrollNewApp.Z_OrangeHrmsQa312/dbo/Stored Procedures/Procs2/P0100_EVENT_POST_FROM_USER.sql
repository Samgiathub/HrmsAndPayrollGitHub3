



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EVENT_POST_FROM_USER]
	@For_Date datetime ,
	@Emp_ID numeric 
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


IF @EMP_Id = 0

SET @EMP_ID = null

Declare @Temp_Table  TAble
	( 
		Event_ID numeric 
	)

Insert into @Temp_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='D'
	and ( Event_show = 1  AND  ShowAll=1) 

Insert into @Temp_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date =@For_Date and Event_Repeate ='N'
	and (Event_show = 1 AND ShowAll=1  )

Insert into @Temp_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='M'
	and day(Event_Date) =Day(@For_date)		
	and ( Event_show = 1  AND ShowAll=1 )

Insert into @Temp_Table ( Event_ID )

	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='Y'
	and day(Event_Date) =day(@For_date) and month(Event_Date) =month(@For_date)
	and ( Event_show = 1  AND ShowAll=1 )



select Distinct em.*,em.Emp_ID,em.Cmp_ID,E.Emp_Full_Name from @Temp_Table t 
    Inner Join T0040_Event_Master em WITH (NOLOCK) on t.event_ID = Em.Event_ID
    Inner join t0080_emp_master E WITH (NOLOCK) on em.Emp_ID = E.Emp_ID




