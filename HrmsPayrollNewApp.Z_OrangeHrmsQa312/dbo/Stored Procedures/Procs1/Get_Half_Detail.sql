

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
--exec Get_Half_Detail '01-jan-2013','02-jan-2013'
CREATE PROCEDURE [dbo].[Get_Half_Detail]
	--@Period	Numeric(18,2),
	@From_Date	Datetime,
	@To_Date	Datetime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
declare @for_Date as Datetime
declare @a as NUMERIC

SET @for_date = @From_Date
CREATE table #Data 
(
Half_Day_Date     varchar(50) ,  
Half_Day_Id  numeric
)
	set @a = 1 
	 
--WHILE @for_Date <= @To_Date

--  BEGIN
  
--  insert into #Data (Half_Day_Date,Half_Day_Id)
--  values ( convert(varchar(11),@for_Date,103)+ '-' + 'First Half',@a)
--  set @a = @a+1
--  insert into #Data (Half_Day_Date,Half_Day_Id)
--  values ( convert(varchar(11),@for_Date,103) + '-' + 'Second Half',@a)
--  set @a= @a+1
  
--     set @for_Date = @for_Date + 1
     
--  END

 Declare @Cnt as numeric = 0
 Declare @Temp_date as datetime
 set @Temp_date = @for_Date
  WHILE @Cnt < 1

  BEGIN
  
	  insert into #Data (Half_Day_Date,Half_Day_Id)
	  values ( convert(varchar(11),@Temp_date,103)+ '-' + 'First Half',@a)
	  set @a = @a+1
	  insert into #Data (Half_Day_Date,Half_Day_Id)
	  values ( convert(varchar(11),@Temp_date,103) + '-' + 'Second Half',@a)
	  set @a= @a+1
	  
	 
	set @Cnt = @Cnt+1 
	set @Temp_date = @To_Date 
     
  END
  select * from #Data
	

END


