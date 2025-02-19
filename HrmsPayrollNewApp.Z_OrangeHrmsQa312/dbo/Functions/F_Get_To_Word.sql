





CREATE FUNCTION [dbo].[F_Get_To_Word]
	(
		@dblValue as integer
	)
RETURNS  varchar(2000)
AS
	BEGIN
		declare @NumToWord varchar(2000)

		declare @dblTen integer
		declare @dblOne integer
		
		if @dblValue >= 20 
		begin
			set @dblTen = @dblValue - (@dblValue % 10)
			set @dblOne = @dblValue - @dblTen

			select @NumToWord =
				case @dblTen
					when 20 then 'Twenty'
					when 30 then 'Thirty'
					when 40 then 'Forty'
					when 50 then 'Fifty'
					when 60 then 'Sixty'
					when 70 then 'Seventy'
					when 80 then 'Eighty'
					when 90 then 'Ninty'
				end
			
			if @dblOne > 0 
			begin
				select @NumToWord = @NumToWord + ' ' +
					case @dblOne
						when 1 then 'One'
						when 2 then 'Two'
						when 3 then 'Three'
						when 4 then 'Four'
						when 5 then 'Five'
						when 6 then 'Six'
						when 7 then 'Seven'
						when 8 then 'Eight'
						when 9 then 'Nine'
						when 10 then 'Ten'
					end
			end
		end
		else
		begin
			if @DblValue >= 0 and @DblValue <= 10
			begin
				select @NumToWord =
					case @DblValue 
						when 0 then 'Zero'
						when 1 then 'One'
						when 2 then 'Two'
						when 3 then 'Three'
						when 4 then 'Four'
						when 5 then 'Five'
						when 6 then 'Six'
						when 7 then 'Seven'
						when 8 then 'Eight'
						when 9 then 'Nine'
						when 10 then 'Ten'
					end
			end
			else if @DblValue > 10 and @DblValue <= 20
			begin
				select @NumToWord =
					case @DblValue 
						when 11 then 'Eleven'
						when 12 then 'Twelve'
						when 13 then 'Thirteen'
						when 14 then 'Fourteen'
						when 15 then 'Fifteen'
						when 16 then 'Sixteen'
						when 17 then 'Seventeen'
						when 18 then 'Eighteen'
						when 19 then 'Ninteen'
					end
			end
		end
		

	RETURN @NumToWord 
	END




