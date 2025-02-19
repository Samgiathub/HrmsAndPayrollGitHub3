Create function [dbo].[RemoveCharSpecialSymbolValue_New](@Temp nvarchar(4000))  
Returns nVarChar(4000)
AS
Begin
---Remove special character and allow space.
    Declare @KeepValues as nvarchar(4000)
    Set @KeepValues = '%[^A-Z0-9  -._]%'
    While PatIndex(@KeepValues, @Temp) > 0
        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')

    Return @Temp
End