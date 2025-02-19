




CREATE FUNCTION [DBO].[Split2](@STRING NVARCHAR(MAX), @DELIMITER CHAR(1))     
returns @temptable TABLE (Row_Id Numeric, items nvarchar(max))     
as     
begin  
--select dbo.Split1('4#55#108#2','#')   
	declare @idx int     
	declare @slice nvarchar(max)    
	declare @row_id numeric 
    Set @row_id = 0
	select @idx = 1     
		if len(@String)<1 or @String is null  return     
    
	while @idx!= 0     
	begin     
		set @idx = charindex(@Delimiter,@String)     
		if @idx!=0     
			set @slice = left(@String,@idx - 1)     
		else     
			set @slice = @String     
		
		Set @row_id = @row_id + 1
	If(len(@slice)>0)
		Begin		  
			insert into @temptable(Row_Id, Items) values(@row_id,@slice)     
        End
     Else
		Begin
			set @row_id=@row_id-1
		End
		set @String = right(@String,len(@String) - @idx)     
		if len(@String) = 0 break     
	end 
return     
end




