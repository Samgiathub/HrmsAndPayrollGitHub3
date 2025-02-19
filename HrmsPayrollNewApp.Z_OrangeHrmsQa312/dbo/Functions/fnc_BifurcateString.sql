-- select * from dbo.fnc_BifurcateString('darshan{%data%}thakkar','{%data%}')
-- drop function dbo.fnc_BifurcateString
create function [dbo].[fnc_BifurcateString](@String varchar(max),@Separator varchar(50))
returns @Table table(val1 varchar(max), val2 varchar(max))
as
begin
	declare @sLen as int, @v1 as varchar(max), @v2 as varchar(max),@c as int
	select @sLen= len(@Separator)
	if @String<>''
	begin
		if @sLen>0
		begin
			select @c=charindex(@Separator,@String)
			select @c=isnull(@c,0)
			if @c>0
			begin
				select @v1=LEFT(@String,@c-1)
				select @v2=RIGHT(@String,LEN(@String)-(@c-1)-@sLen)
			end
			else
			begin
			select @v1=@String, @v2=''
			end
		end
		else
		begin
			select @v1=@String, @v2=''
		end
	end
	else
	begin
		select @v1='', @v2=''
	end
	insert into @Table select @v1,@v2
	return
end