




CREATE FUNCTION DBO.F_Format
(
	@String varchar(10),
	@values numeric
)  
RETURNS @RtnValue table 
(
	Data varchar(10)
) 
AS  
BEGIN 
			Declare @Output as varchar(10)
			set @Output = cast(@values as varchar(10))
			
			While len(@Output ) <len(@String)
				begin
					set @Output = substring(@String,len(@String) - len(@Output),1) + @Output
				End 
	
	Insert Into @RtnValue (data)
	
	Select @Output 

			RETURN 
	END




