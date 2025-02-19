


---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P9999_IMPORT_Week_SCHEDULE]
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
	Declare @Emp_ID			numeric 
	Declare @Cmp_ID			numeric 
	DEclare @Emp_Code		numeric 
	Declare @Month			numeric 
	Declare @Year			numeric 
	Declare @Day1			varchar(10)	
--	Declare @Day2			varchar(10)
--	Declare @Day3			varchar(10)
--	DEclare @Day4			varchar(10)
--	DEclare @Day5			varchar(10)
--	DEclare @Day6			varchar(10)
--	Declare @Day7			varchar(10)	
--	DEclare @Day8			varchar(10)	
---	Declare @Day9			varchar(10)
--	Declare @Day10			varchar(10)
--	Declare @Day11			varchar(10)	
--	Declare @Day12			varchar(10)
--	Declare @Day13			varchar(10)
--	Declare @Day14			varchar(10)
--	Declare @Day15			varchar(10)
---	Declare @Day16			varchar(10)
--	Declare @Day17			varchar(10)
--	Declare @Day18			varchar(10)
--	Declare @Day19			varchar(10)
--	Declare @Day20			varchar(10)
--	Declare @Day21			varchar(10)
--	Declare @Day22			varchar(10)
--	Declare @Day23			varchar(10)
--	Declare @Day24			varchar(10)
--	Declare @Day25			varchar(10)
--	Declare @Day26			varchar(10)
--	Declare @Day27			varchar(10)	
--	Declare @Day28			varchar(10)
--	Declare @Day29			varchar(10)
--	Declare @Day30			varchar(10)
--	Declare @Day31			varchar(10)
	Declare @For_Date		Datetime
	Declare @Weekoff_day	numeric(1,0)									  			
	Declare @W_Tran_ID		numeric		
	
			
	Declare Cur_week cursor for
		select Cmp_ID,s.Emp_Id,s.Emp_Code,Month,Year ,Day1,Day2,Day3,Day4,Day5,Day6,Day7,Day8,Day9,Day10
										  ,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20
										  ,Day21,Day22,Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31
				From T9999_IMPORT_Week_SCHEDULE S WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on s.emp_ID=e.emp_ID and
					s.emp_code =e.emp_Code						  
				Where Month > 0 and year >0	
	Open Cur_week
	fetch next from Cur_week into @Cmp_Id,@Emp_ID,@Emp_Code,@Month,@Year ,@Day1
	While @@fetch_Status=0
		begin
				Delete from T0010_weekoff_adj where emp_ID=@Emp_ID and Month(For_Date) =@month and Year(for_Date)=@Year
				
				
			
	if ( charindex('W',@Day1,0) > 0 and len(@Day1) > 1 ) or isnumeric(@Day1) =1 
					begin

						set @Day1 = replace(@day1,'W','')
						
						if isnumeric(@Day1) =1 
						
								if exists (Select W_Tran_ID  from T0100_WEEKOFF_ADJ WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID AND For_Date=@For_Date) 
									begin
										set @W_Tran_ID=0
									end
								else
									begin
									Select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1  from T0100_WEEKOFF_ADJ WITH (NOLOCK)
									select  @For_Date = dbo.GET_MONTH_ST_DATE(@month,@Year)
										Insert Into T0100_WEEKOFF_ADJ(W_Tran_ID,Cmp_ID,Emp_ID,For_Date,Weekoff_Day)values
											(@W_Tran_ID,@Cmp_ID,@Emp_ID,@For_Date,@Weekoff_Day)
					
				end 
							end
				end




