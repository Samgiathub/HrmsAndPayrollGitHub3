



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[p0050_Event_Holiday] 
	
	 
	 @Cmp_ID numeric

    ,@For_Date  dateTime
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	
		
	Declare @Month			Varchar(10) 
	Declare @Year			Varchar(10) 
	Declare @From_Date as DateTime
    Declare @To_Date as DateTime

     Select @Month=Month(@For_Date)
	 Select @Year=Year(@For_Date)


	 select  @From_Date = dbo.GET_MONTH_ST_DATE(@month,@Year)	
	 Select  @To_Date=dbo.GET_MONTH_END_DATE(@month,@Year)
	
	
     select E.*  from T0040_Holiday_Master E WITH (NOLOCK) 
		inner join T0010_company_master CM WITH (NOLOCK) on Cm.Cmp_Id =E.Cmp_ID
		
		WHERE E.Cmp_ID = @Cmp_Id	 and H_From_date>=@From_Date and H_From_date <=@To_Date 
					
	RETURN




