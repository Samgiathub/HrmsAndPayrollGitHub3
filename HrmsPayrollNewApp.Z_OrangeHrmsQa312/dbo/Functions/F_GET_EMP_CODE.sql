



---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE  FUNCTION [dbo].[F_GET_EMP_CODE] 
	(
		@Date_Of_Join as datetime =null,
		@CMP_ID as datetime
	)
RETURNS Numeric(22,0)
AS
		begin
			Declare @New_Emp_Code varchar(12)
			Declare @Month varchar(2)
			Declare @Days varchar(2)
			Declare @Count Numeric(22,0)
			
			set @Count=0
			
			if @Date_Of_Join is null
				set @Date_Of_Join=''
				
				if @Date_Of_Join <> ''
					Begin
							if Month(@Date_Of_Join) < 10
								Begin
									set @Month=  cast(Month(@Date_Of_Join) as varchar(2))
									set @Month = '0'+cast(@Month as varchar(2)) 
								End
							else
								Begin
									set @Month=  cast(Month(@Date_Of_Join) as varchar(2))
								End	
							if day(@Date_Of_Join) < 10
								Begin
									set @Days=  cast(day(@Date_Of_Join) as varchar(2))
									set @Days = '0'+cast(@Days as varchar(2)) 
								End
							else
								Begin
									set @Days=  cast(day(@Date_Of_Join) as varchar(2))
								End		
							
							set @New_Emp_Code = @Days + @Month+cast(Year(@Date_Of_Join) as varchar(4))
							
							
						select @Count = isnull(max(EMP_CODE),0) from T0080_EMP_MASTER WITH (NOLOCK) where CMP_ID=@CMP_ID And right(EMP_CODE,8) = cast(@New_Emp_Code as numeric(22,0))
						if @Count=0
							begin 
								set @Count = cast(@New_Emp_Code as numeric(22,0)) + 100000000
							end
						else
							begin
								set @Count = @Count + 100000000
							end	


						--set @New_Emp_Code = cast(@Count as varchar(4)) +  @New_Emp_Code
					End
			RETURN cast(@Count as Numeric(22,0))
		end




