
--Drop Table T0010_Yearly_Odd_Even_WeekOff

--drop table T0010_Yearly_Odd_Even_WeekOff
--exec  OddOrEvenWeakOff '' , 'Even' 
CREATE Procedure [dbo].[OddOrEvenWeakOff]
	@EffectiveDate date = NULL,
	@Type char(5) 	
As
BEGIN 
	
	declare @d datetime select @d = DATEADD(yy, DATEDIFF(yy,0,GETDATE()),0)
	If isnull(@EffectiveDate,'') = ''
		set @EffectiveDate = DATEADD(yy, DATEDIFF(yy,0,GETDATE()),0)
	
	-- Getting all satrday and sunday records
	;with  Data_CTE  as (
			select ROW_NUMBER() OVER (ORDER BY number) SrNo
			,datename(weekday, (dateadd(dd, number, @d))) as Name
			, dateadd(dd,number,@d) as WeekOffDate 
			from master..spt_values 
			where type = 'p' 
			and year(dateadd(dd,number,@d))=year(@d)
			and datename(weekday, (dateadd(dd, number, @d))) in ('Saturday' /* Specify Day Name */)
		) select * into T0010_Yearly_Odd_Even_WeekOff  from Data_CTE 
	
	--if @Type = 'ODD'
	--Begin
	--	;with  Data_CTE  as (
	--		select ROW_NUMBER() OVER (ORDER BY number) SrNo
	--		,datename(weekday, (dateadd(dd, number, @d))) as Name
	--		, dateadd(dd,number,@d) as WeekOffDate 
	--		from master..spt_values 
	--		where type = 'p' 
	--		and year(dateadd(dd,number,@d))=year(@d)
	--		and datename(weekday, (dateadd(dd, number, @d))) in ('Saturday' /* Specify Day Name */)
	--	) select * into T0010_Odd_WeekOff  from Data_CTE where SrNo % 2 <> 0 and WeekOffDate >= @EffectiveDate 
	--END

	--IF Upper(@Type) = 'EVEN'
	--BEGIN
	--	;with  Data_CTE  as (
	--		select ROW_NUMBER() OVER (ORDER BY number) SrNo
	--		,datename(weekday, (dateadd(dd, number, @d))) as Name
	--		, dateadd(dd,number,@d) as WeekOffDate
	--		from master..spt_values 
	--		where type = 'p' 
	--		and year(dateadd(dd,number,@d))=year(@d)
	--		and datename(weekday, (dateadd(dd, number, @d))) in ('Saturday' /* Specify Day Name */)
	--	) select * from Data_CTE where SrNo % 2 = 0 and WeekOffDate >= @EffectiveDate 
	--END
END 
