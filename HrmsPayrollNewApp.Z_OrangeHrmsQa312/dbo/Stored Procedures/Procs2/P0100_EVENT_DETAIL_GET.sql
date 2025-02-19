



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EVENT_DETAIL_GET]
	@For_Date datetime ,
	@Emp_ID numeric,
	@Cmp_ID numeric 
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--IF @EMP_Id = 0  --commented Alpesh 12-aug-2011
--SET @EMP_ID = null  

Declare @Temp_Table  TAble
	( Event_ID numeric 

)

Declare @Temp_future_Table  TAble
	( Event_ID numeric 

)

declare @future_date as datetime
set @future_date = dateadd(dd,7,@for_date)

Insert into @Temp_Table ( Event_ID )

	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='D'
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date =@For_Date and Event_Repeate ='N'
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='M'
	and day(Event_Date) =Day(@For_date)		
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_Table ( Event_ID )

	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date <=@For_Date and Event_Repeate ='Y'
	and day(Event_Date) =day(@For_date) and month(Event_Date) =month(@For_date)
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID



select Distinct em.*,Emp_ID,Cmp_ID,
 Case When row_number() OVER ( PARTITION BY em.Event_Type order by Em.Event_id) = 1 
		Then em.Event_Type Else null End Event_Type_1
 from @Temp_Table t Inner Join 
		T0040_Event_Master em WITH (NOLOCK) on t.event_ID = Em.Event_ID order by Event_Type
		


Insert into @Temp_future_Table ( Event_ID )

	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where EVent_Date >@for_date and EVent_Date <@future_date and Event_Repeate ='D'
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_future_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where  EVent_Date >@for_date and EVent_Date <@future_date and Event_Repeate ='N'
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_future_Table ( Event_ID )
	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where  EVent_Date >@for_date and EVent_Date <@future_date and Event_Repeate ='M'
	and day(Event_Date) =Day(@For_date)		
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

Insert into @Temp_future_Table ( Event_ID )

	select Event_ID From T0040_Event_Master WITH (NOLOCK) Where  EVent_Date >@for_date and EVent_Date <@future_date and Event_Repeate ='Y'
	and day(Event_Date) =day(@For_date) and month(Event_Date) =month(@For_date)
	and ((Emp_ID = @Emp_ID  and Event_show = 1)  or  isnull(ShowAll,0)=1 ) and Cmp_ID = @Cmp_ID

	
	select Distinct 
		em.*,Emp_ID,Cmp_ID,
		Case When row_number() OVER ( PARTITION BY em.Event_Type order by Em.Event_Id) = 1 
		Then em.Event_Type Else null End Event_Type_1
	from @Temp_future_Table t Inner Join 
		T0040_Event_Master em WITH (NOLOCK) on t.event_ID = Em.Event_ID  order by Event_Type
		



