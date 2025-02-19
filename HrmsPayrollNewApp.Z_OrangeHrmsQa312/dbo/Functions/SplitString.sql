


CREATE FUNCTION [DBO].[SplitString] 
(
    -- Add the parameters for the function here
    @myString varchar(8000),
    @deliminator varchar(10)
)
RETURNS 
@ReturnTable TABLE 
(
    -- Add the column definitions for the TABLE variable here
    [id] [int] IDENTITY(1,1) NOT NULL,
    [part] [varchar](8000) NULL
)
AS
BEGIN
        Declare @iSpaces int
        Declare @part varchar(8000)

        --initialize spaces
        Select @iSpaces = charindex(@deliminator,@myString,0)
        While @iSpaces > 0

        Begin
            Select @part = substring(@myString,0,charindex(@deliminator,@myString,0))

            Insert Into @ReturnTable(part)
            Select @part

    Select @myString = substring(@mystring,charindex(@deliminator,@myString,0)+ len(@deliminator),len(@myString) - charindex(' ',@myString,0))


            Select @iSpaces = charindex(@deliminator,@myString,0)
        end

        If len(@myString) > 0
            Insert Into @ReturnTable
            Select @myString

    RETURN 
END

