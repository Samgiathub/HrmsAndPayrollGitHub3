


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Publish_News_Letter_Import]

@Cmp_ID				numeric(18, 0),
@News_Title			varchar(500),
@News_Description	varchar(Max),
@Start_Date			datetime,
@End_Date			datetime,
@Is_Show			numeric(18,0)= 0,
@Is_Thought			numeric(18,0)= 0,
@Is_Popup			numeric(18,0)= 0,
@Log_Status			numeric(18,0) output,
@Row_No				numeric(18,0),
@GUID				varchar(500)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @MODULE varchar(500)	
	SET @MODULE = 'Publish News Letter Import';
		
	if @News_Title is null or @News_Title = ''
		 BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,'' ,'News Letter Title Doesn''t exists','','Enter News Letter title',GetDate(),@MODULE,@GUID)			
			RETURN
		END
	
	if @News_Description is null or @News_Title = ''
		 BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,'' ,'News Letter Description Doesn''t exists','','Enter News Letter Description',GetDate(),@MODULE,@GUID)			
			RETURN
		END
		
	if @Start_Date is null or @Start_Date = ''
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,'' ,'News Letter Start Date Doesn''t exists','','Enter News Letter Start Date',GetDate(),@MODULE,@GUID)			
			RETURN
		End 
		
	if @End_Date is null or @End_Date = ''
		BEGIN
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,'' ,'News Letter End Date Doesn''t exists','','Enter News Letter End Date',GetDate(),@MODULE,@GUID)			
			RETURN
		End
	if @Start_Date > @End_Date
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,'' ,'News Letter End Date Doesn''t exists','','Please Enter Valid Date',GetDate(),@MODULE,@GUID)			
			RETURN
		End 
	
	DECLARE @News_Letter_ID Numeric(18,0)
	select 	@News_Letter_ID = isnull(max(News_Letter_ID),0)+1 from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK)
		
		INSERT INTO T0040_NEWS_LETTER_MASTER
					(News_Letter_ID,Cmp_ID,News_Title,News_Description,Start_Date,End_Date,Is_Visible,Flag_T,Flag_P)
			VALUES	(@News_Letter_ID,@Cmp_ID,@News_Title,@News_Description,@Start_Date,@End_Date,@Is_Show,@Is_Thought,@Is_Popup)
	
END


