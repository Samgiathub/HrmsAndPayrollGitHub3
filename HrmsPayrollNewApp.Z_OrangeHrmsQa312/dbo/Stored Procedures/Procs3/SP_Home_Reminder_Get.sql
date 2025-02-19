



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Home_Reminder_Get] 
	@Cmp_ID numeric,
	@Type numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Type = 0 
	  Begin 
		Declare @Birthday table
		(
		Emp_Full_Name varchar(100),
		Date_Of_birth datetime,
		Month_Name varchar(10)
		)
	
	    Declare @From_Date DateTime
	    Declare @To_Date DateTime
	    
	    set @From_Date =    GETDATE() + 1
	    set @To_Date=   GETDATE() + 5
	    
		
		
		insert into @Birthday Values('<b>TODAYS</b>',null,'')
		
		insert into @Birthday
		Select (CAST(Emp_Code AS varchar(20))+ '-' + Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name),CONVERT(VARCHAR(11),Date_Of_birth , 106) as Date_Of_Birth,'' from T0080_Emp_master WITH (NOLOCK) where cmp_id=@Cmp_ID 
	    and Month(Date_Of_Birth)=Month(Getdate()) And day(Date_Of_Birth)=day(Getdate())-- >=@From_Date and Date_Of_Birth <=@To_Date

		insert into @Birthday Values('<b>UPCOMING</b>',null,'')
		
		insert into @Birthday
		Select (CAST(Emp_Code AS varchar(20))+ '-' + Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name),CONVERT(VARCHAR(11),Date_Of_birth , 106) as Date_Of_Birth,''  from T0080_Emp_master WITH (NOLOCK) where cmp_id=@Cmp_ID 
	    and ((Month(Date_Of_Birth)=Month(@From_Date) And day(Date_Of_Birth)=day(@From_Date)) OR 
	    (Month(Date_Of_Birth)=Month(@From_Date+1) And day(Date_Of_Birth)=day(@From_Date+1)) OR
	    (Month(Date_Of_Birth)=Month(@From_Date+2) And day(Date_Of_Birth)=day(@From_Date+2))) 
	    
	    -- >=@From_Date and Date_Of_Birth <=@To_Date
	    
	    
	    --Select Emp_ID,Emp_Full_Name,CONVERT(VARCHAR(11),Date_Of_birth , 106) as Date_Of_Birth  from T0080_Emp_master where cmp_id=@Cmp_ID 
	    --and Date_Of_Birth >=@From_Date and Date_Of_Birth <=@To_Date
	  
	  End
	  Update  @Birthday set Month_Name = (cast(Day(Date_Of_birth) as varchar(3)) + '-' + Left(dbo.F_GET_MONTH_NAME(Month(Date_Of_birth)),3) )
	select Emp_Full_Name,Month_Name from @Birthday
	RETURN




