




CREATE FUNCTION DBO.F_GET_AMPM 
	(

	@Date as datetime

	)
  
RETURNS Varchar(10)

AS
BEGIN 
	declare @Time as varchar(10)

	Set @Time = 
		case
			when substring(substring(right(convert(varchar(20),@Date),7),1,5) + ' ' + substring(right(convert(varchar(20),@Date),7),6,2),1,1) = ' ' then
				replace(substring(substring(right(convert(varchar(20),@Date),7),1,5) + ' ' + substring(right(convert(varchar(20),@Date),7),6,2),1,1),' ','0') + 
				substring(substring(right(convert(varchar(20),@Date),7),1,5) + ' ' + substring(right(convert(varchar(20),@Date),7),6,2),2,7)
			else
				substring(right(convert(varchar(20),@Date),7),1,5) + ' ' + substring(right(convert(varchar(20),@Date),7),6,2)
		End

		 
	return @Time
End 




