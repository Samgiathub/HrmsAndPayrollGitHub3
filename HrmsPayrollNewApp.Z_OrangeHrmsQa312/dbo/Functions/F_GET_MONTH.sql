




CREATE FUNCTION DBO.F_GET_MONTH
	(
		@Date_Of_Birth as datetime =null,
		@Cur_Date as datetime,
		@With_month as varchar(1) ='Y',
		@With_Days as varchar(1) = 'Y'
		
	)
RETURNS Varchar(10)
AS
		begin
			Declare @Age varchar(10)
			declare @total_Days as int
			
			Declare @year as int
			declare @month as int
			declare @days as int

			set @Total_Days = datediff(d,@Date_Of_Birth,@Cur_date)
		
			if isnull(@Date_Of_Birth,'') <> ''
				begin
					if @Total_Days > 0
						begin
							
							set @Days = @total_Days % 365
							set @Year = (@Total_Days - @Days ) /365
							set @Total_Days = @Days 		
								
						end
					if @Total_Days > 0
						begin
							set @Days = @total_Days % 30
							set @Month = (@Total_Days - @Days ) /30
						end
				
					set @Age = cast(@year  as varchar(5))
					if @With_Month ='Y' 
						set @Age = @Age +'.' + cast(@Month as varchar(5))
					if @With_Days ='Y'
						set @Age = @Age +'.' + cast(@Days as varchar(5))
				end				
			
			RETURN @Month 
		end




