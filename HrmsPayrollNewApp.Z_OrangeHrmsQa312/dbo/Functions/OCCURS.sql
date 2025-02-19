




CREATE FUNCTION OCCURS  (@CSEARCHEXPRESSION NVARCHAR(4000), @CEXPRESSIONSEARCHED NVARCHAR(4000))
returns smallint
as
    begin
      declare @start_location smallint,  @occurs  smallint
      select  @start_location = charindex(@cSearchExpression COLLATE Latin1_General_BIN, @cExpressionSearched COLLATE Latin1_General_BIN),   @occurs = 0

     while @start_location > 0
          select  @occurs = @occurs + 1,  @start_location  = charindex(@cSearchExpression COLLATE Latin1_General_BIN, @cExpressionSearched COLLATE Latin1_General_BIN, @start_location+1)
    
     return  @occurs
    end




