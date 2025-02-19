

-- Created by rohit for get branch wise working Days on 01032016.
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_BranchWise_Working]
  @Cmp_Id	numeric output	 
  ,@From_Date  datetime
  ,@To_Date  datetime
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
SET ANSI_WARNINGS OFF;
begin

	Create table #branch_Detail
(
branch_id numeric,
Branch_Name Varchar(500),
From_Date datetime,        
to_date Datetime,
month_name varchar(500),        
WorkingDay  numeric(18,2),
Holiday  numeric(18,2),     
Weekoff  numeric(18,2),
TotalDay  numeric(18,2)
 )
 


	declare @Temp_Date datetime
	Declare @count numeric 
	declare @defaultholiday varchar(500)=''
	select @defaultholiday = Default_Holiday from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id
	
	set @Temp_Date = @From_Date 
	set @count = 1 
	while @Temp_Date <=@To_Date 
	Begin
	
	insert into #branch_Detail (branch_id,Branch_Name,From_Date,to_date,month_name,WorkingDay,Holiday,Weekoff,TotalDay)
	select Branch_ID,Branch_Name,@Temp_Date,dateadd(m,1,@Temp_date)-1,datename(MONTH, @Temp_date),0,0,dbo.fnc_NumberOfWeekEnds(@defaultholiday,@Temp_Date,dateadd(m,1,@Temp_date)),DATEDIFF(DD,@Temp_Date,dateadd(m,1,@Temp_date)) from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_Id 
	
	set @Temp_Date = dateadd(m,1,@Temp_date)
	set @count = @count + 1  
	End



	DECLARE @curbranch_ID NUMERIC
	DECLARE @Curfrom_Date DATETIME
	DECLARE @Curto_Date DATETIME
	Declare @holiday numeric(18,2)

	Declare CusrBranchMST cursor for	                  
	select branch_id,From_Date,To_date from #branch_Detail 
	Open CusrBranchMST
	Fetch next from CusrBranchMST into @curbranch_ID,@Curfrom_Date, @Curto_Date
	While @@fetch_status = 0         
	Begin  
		set @holiday =0
	
			select @holiday= isnull(SUM(isnull(DATEDIFF(dd,H_FROM_DATE,H_TO_DATE),0) + 1),0) from (SELECT DISTINCT CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@Curto_Date) THEN CAST(YEAR(@Curfrom_Date)AS VARCHAR(4)) ELSE CAST(YEAR(@Curto_Date)AS VARCHAR(4)) END AS DATETIME) AS H_FROM_DATE,
			CAST(CAST(DATENAME(DAY,H_TO_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_TO_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_TO_DATE) > MONTH(@Curto_Date) THEN CAST(YEAR(@Curfrom_Date)AS VARCHAR(4)) ELSE CAST(YEAR(@Curto_Date)AS VARCHAR(4)) END AS DATETIME) AS H_TO_DATE,
			ISNULL(IS_HALF,0) as is_half ,ISNULL(IS_P_COMP,0)as IS_P_COMP , IS_FIX 
		FROM T0040_HOLIDAY_MASTER WITH (NOLOCK) 
			WHERE CMP_ID=@CMP_ID AND IS_FIX = 'Y' AND ISNULL(IS_OPTIONAL,0)= 0 AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@curbranch_ID) AND
				@Curfrom_Date <= 
					CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@Curto_Date) THEN CAST(YEAR(@Curfrom_Date)AS VARCHAR(4)) ELSE CAST(YEAR(@Curto_Date)AS VARCHAR(4)) END AS DATETIME) 
				AND 
				@Curto_Date >= 
					CAST(CAST(DATENAME(DAY,H_FROM_DATE) AS VARCHAR(2)) + '-' + CAST(DATENAME(MONTH,H_FROM_DATE)AS VARCHAR(3)) + '-' + CASE WHEN MONTH(H_FROM_DATE) > MONTH(@Curto_Date) THEN CAST(YEAR(@Curfrom_Date)AS VARCHAR(4)) ELSE CAST(YEAR(@Curto_Date)AS VARCHAR(4)) END AS DATETIME)
				And ISNULL(Is_P_Comp,0) = 0 --Added by nilesh patel for Compulsory Present on holiday 

		UNION ALL
		
			SELECT DISTINCT  H_FROM_DATE , H_TO_DATE ,ISNULL(IS_HALF,0) as is_half ,ISNULL(IS_P_COMP,0) as IS_P_COMP , IS_FIX 
			FROM T0040_HOLIDAY_MASTER WITH (NOLOCK)
			WHERE CMP_ID=@CMP_ID AND
			(
				(@Curfrom_Date BETWEEN H_FROM_DATE AND H_To_Date) OR 
				(@Curto_Date BETWEEN H_FROM_DATE AND H_To_Date) OR
				(H_FROM_DATE BETWEEN @Curfrom_Date AND @Curto_Date) OR
				(H_To_Date BETWEEN @Curfrom_Date AND @Curto_Date) 	
			)
			AND ISNULL(IS_OPTIONAL,0)=0 AND IS_FIX = 'N'
			AND (ISNULL(BRANCH_ID,0) = 0 OR ISNULL(BRANCH_ID,0) =@curbranch_ID) And ISNULL(Is_P_Comp,0) = 0
		) holiday
		
		
		update #branch_Detail set Holiday = @holiday,WorkingDay = TotalDay - (Weekoff + @holiday )  where branch_id = @curbranch_ID and From_Date = @Curfrom_Date and to_date = @Curto_Date
		
	
	fetch next from CusrBranchMST into @curbranch_ID,@Curfrom_Date, @Curto_Date
	end
	close CusrBranchMST  
	deallocate CusrBranchMST

select Branch_Name ,convert(varchar(12),From_Date , 103) as FROM_DATE,convert(varchar(12),To_date,103) as To_date,month_name,WorkingDay,Holiday,Weekoff,TotalDay from #branch_Detail order by branch_name,From_Date 

end
return




