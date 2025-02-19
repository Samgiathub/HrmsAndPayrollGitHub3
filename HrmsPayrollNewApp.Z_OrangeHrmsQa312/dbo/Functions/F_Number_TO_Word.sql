

CREATE FUNCTION [DBO].[F_Number_TO_Word]
	(
		@dblValue as numeric(22,2)
	)
RETURNS varchar(2000)
AS
	BEGIN
	
	declare @NumToWord  varchar(2000)
	declare @dblNumber integer
	
	-- upto crors
	declare @strValue as varchar(30)
	Declare @is_negetive as tinyint
	Set @is_negetive=0
	if @DblValue < 0
		begin
			Set @DblValue = ABS(@DblValue)
			Set @is_negetive =1
			--set @NumToWord ='Negative Value'
			--RETURN @DblValue 
		end 
			
	set @strValue = cast(@dblValue as varchar(30))
	
	
	while len(@strValue) < len('000000000.00')
	begin
		set @strValue = '0' + @StrValue
	end
	
	set @NumToWord = ''
	
	

	-- carors
	set @dblNumber = cast(substring(@strValue, 1, 2) as numeric)
	if @dblNumber > 0 
	begin
		select @NumToWord = dbo.F_Get_To_Word(@dblNumber) + case when @dblNumber = 1 then ' Crore' else ' Crores' End
	end

	set @dblNumber = cast(substring(@strValue, 3, 2) as numeric)
	if @dblNumber > 0 
	begin
		select @NumToWord = @NumToWord + ' ' + dbo.F_Get_To_Word(@dblNumber) + case when @dblNumber = 1 then ' Lac' else ' Lacs' End
	end

	set @dblNumber = cast(substring(@strValue, 5, 2) as numeric)
	if @dblNumber > 0 
	begin
		select @NumToWord = @NumToWord + ' ' + dbo.F_Get_To_Word(@dblNumber) + ' Thousand'
	end

	set @dblNumber = cast(substring(@strValue, 7, 1) as numeric)
	if @dblNumber > 0 
	begin
		select @NumToWord = @NumToWord + ' ' + dbo.F_Get_To_Word(@dblNumber) + ' Hundred'
	end

	set @dblNumber = cast(substring(@strValue, 8, 2) as numeric)
	if @dblNumber > 0 or @NumToWord = ''
	begin
		select @NumToWord = @NumToWord + ' ' + dbo.F_Get_To_Word(@dblNumber) 
	end

	set @dblNumber = cast(substring(@strValue, 11, 2) as numeric)
	if @dblNumber > 0 
	begin
		if @NumToWord = ''
			select @NumToWord = dbo.F_Get_To_Word(@dblNumber) 
		else
			select @NumToWord = @NumToWord + ' and ' +  dbo.F_Get_To_Word(@dblNumber) 
	end
	
	--set @NumToWord = @strValue
	if @is_negetive = 1
		Set @NumToWord = 'Minus' + @NumToWord
	
	RETURN @NumToWord + ' Only' 
	END




