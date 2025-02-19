

-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 09-11-2017
-- Description:	CHANGE CAPTION FOR CUSTOMIZED REPORT
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Caption_List]
     @Cmp_ID        numeric,
     @constraint    varchar(MAX)     
    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @COLUMN_NAME AS VARCHAR(100)
	DECLARE @ALIAS AS VARCHAR(100)
	DECLARE @TEMP_COL_NAME VARCHAR(100)
	
	CREATE TABLE #CAPTION_LIST
	(
		caption_name  VARCHAR(100)
	)
    
    Insert Into #CAPTION_LIST
    select  data  from dbo.Split (@constraint,'#')  WHERE DATA <> ''
    
	CREATE TABLE #MY_CAPTIONS
	(					
		Caption			Varchar(100),
		Alias			Varchar(100)					
	)				     
  	
	DECLARE CAPTION_DETAILS CURSOR FOR
	select caption_name FROM #CAPTION_LIST
	OPEN CAPTION_DETAILS
	FETCH NEXT FROM CAPTION_DETAILS into @COLUMN_NAME
	while @@fetch_status = 0
		Begin
			set @ALIAS=''
			set @ALIAS= @COLUMN_NAME
			SET @TEMP_COL_NAME = REPLACE(REPLACE(@COLUMN_NAME, '_',''), ' ', '')
						
			IF @TEMP_COL_NAME = 'BranchName'
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'BRANCH'
			ELSE IF @TEMP_COL_NAME in('CategoryName','CatName')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Category' 
			ELSE IF @TEMP_COL_NAME in('GradeName','GrdName')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Grade'
			ELSE IF @TEMP_COL_NAME IN ('Type','EmployeeType','TypeName')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Employee Type'
			ELSE IF @TEMP_COL_NAME IN ( 'VerticalName' , 'Vertical')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Vertical'
			ELSE IF @TEMP_COL_NAME IN ('SubVerticalName','SubVertical')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'SubVertical'
			ELSE IF @TEMP_COL_NAME IN ('subBranchName','subBranch')
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'subBranch'
			ELSE IF @TEMP_COL_NAME = 'SegmentName' 
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Business Segment'
			ELSE IF @TEMP_COL_NAME = 'OldRefNo' 
				SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'Old Reference Code' 
			ELSE
				BEGIN 
					IF EXISTS(SELECT 1 FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = @COLUMN_NAME)
						SELECT @ALIAS = ALIAS FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = @COLUMN_NAME
					ELSE IF EXISTS(SELECT 1 FROM	T0040_CAPTION_SETTING WITH (NOLOCK)
									WHERE	Cmp_ID=@Cmp_ID and CHARINDEX(Caption,@COLUMN_NAME) > 0)
						BEGIN
							SELECT	@ALIAS = REPLACE(@ALIAS, Caption, Alias) 
							FROM	T0040_CAPTION_SETTING WITH (NOLOCK)
							WHERE	Cmp_ID=@Cmp_ID and CHARINDEX(Caption,@COLUMN_NAME) > 0
							
							--PRINT 'cap : ' +@COLUMN_NAME + ' :: alias: '+ @ALIAS
						END
					ELSE
						SET @ALIAS = ''
				END
			
			
			IF ISNULL(@ALIAS,'') <>''
				BEGIN
					INSERT INTO #MY_CAPTIONS
					VALUES (@COLUMN_NAME, @ALIAS)
				END
			FETCH NEXT FROM CAPTION_DETAILS into @COLUMN_NAME
		End
	close CAPTION_DETAILS 
	deallocate CAPTION_DETAILS

	select * from #MY_CAPTIONS
		
