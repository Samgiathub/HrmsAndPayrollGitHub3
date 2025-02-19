


CREATE FUNCTION [DBO].[Split3]
(
	@RowData nvarchar(max),
	@SplitOn nvarchar(5)
)  
RETURNS @RtnValue table 
(
	Id int identity(1,1),
	Data varchar(256) PRIMARY KEY
) 
AS  
BEGIN 
	Declare @Cnt int
	Set @Cnt = 1;
	
	DECLARE @DATA varchar(100);

	While (Charindex(@SplitOn,@RowData)>0)
	
	Begin
		SET @DATA = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))
	
		if not EXISTS (Select 1 from @RtnValue WHERE DATA = @DATA) AND @DATA <> ''
			Insert Into @RtnValue VALUES(@DATA)
		--Select Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))

		Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))
		Set @Cnt = @Cnt + 1
	End
	
	Insert Into @RtnValue (data)
	Select Data = ltrim(rtrim(@RowData))

	Return
END




