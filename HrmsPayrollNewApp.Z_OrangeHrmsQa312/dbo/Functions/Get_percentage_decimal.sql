

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION Get_percentage_decimal
(
 @val1 as numeric(18,2) 
,@val2 as numeric(18,2) 

)
RETURNS numeric(18,2)
AS
BEGIN
		DECLARE @val as numeric(18,2) 
		
		set @val = @val1 * 100/ @val2
		
		RETURN @val

END

