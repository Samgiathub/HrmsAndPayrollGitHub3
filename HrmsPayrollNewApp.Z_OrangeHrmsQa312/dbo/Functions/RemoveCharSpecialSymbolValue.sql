CREATE function [dbo].[RemoveCharSpecialSymbolValue](@Temp varchar(5000))  
Returns VarChar(5000)
AS
Begin
---Remove special character and allow space.
    Declare @KeepValues as varchar(5000)
    Set @KeepValues = '%[^A-Z0-9  -._]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End