


CREATE FUNCTION [DBO].[F_Remove_Zero_Decimal]
(
	@Value Numeric(18,5)
)
RETURNS varchar(100)
AS

BEGIN
Declare @Table table
( id numeric,
  data varchar(100)
)

Declare @T as varchar(100)
Set @T = PARSENAME(@Value,2)
    + '.'
    + REVERSE(CAST(REVERSE(PARSENAME(@Value,1)) as int))


If exists(Select id from dbo.Split(@T,'.') where id=2 and data=0)
	Select  @T = Data + '.00' from dbo.Split(@T,'.') where id=1


return @T
    

--return Case When Charindex('.',CAST(@Value as float),0) > 0 then 
--	Cast(CAST(@Value as float) As varchar(100))
--  else 
--	Cast(Cast(CAST(@Value as float) as varchar(100)) +  Cast('.00' as varchar(3)) as varchar(100))
-- end

END

