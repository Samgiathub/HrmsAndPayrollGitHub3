




CREATE FUNCTION DBO.F_Return_HHMM
	(
		@Date as DateTime
	)
RETURNS  Varchar(10)
AS
	BEGIN
	
	DEclare @Time as varchar(10)
	Declare @Hours as numeric 
	Declare @Min as numeric 
	declare @strHours as varchar(5)
	DEclare @StrMin as varchar(5)
	set @Hours = 0
	set @Min = 0
	
	set @StrHours = datepart(hh,@Date)
	set @StrMin =  datepart(mi,@Date)
	
	if len(@StrHours) =1 
		set @StrHours = '0' + @StrHours
	if len(@StrMin) =1 
		set @StrMin= '0' + @StrMin
		
--	select @strHours =data From dbo.F_Format('00',@Hours) 
--	select  @strMin = data From dbo.f_Format('00',@Min)
	
	set @Time = @StrHours + ':' + @StrMin
	
	RETURN @Time
	end




