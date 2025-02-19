


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_CUSTOMIZED_REPORT]
	@ReportType		Varchar(128),
	@TypeID			INT,
	@ReportName		Varchar(128),
	@SortID			INT = NULL,
	@ReportID		INT = NULL OUTPUT,
	@ModuleName		Varchar(100)= 'Payroll' 
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @TranType TINYINT
		SET @TranType = 1 --INSERT

		IF EXISTS(SELECT 1 FROM T0250_CUSTOMIZED_REPORT WITH (NOLOCK) WHERE ReportID = @ReportID)
			SET @TranType = 2 --UPDATE
		ELSE IF @ReportID IS NULL
			SELECT @ReportID = IsNull(Max(ReportID),0) + 1 FROM T0250_CUSTOMIZED_REPORT WITH (NOLOCK)
		
		IF EXISTS(SELECT 1 FROM T0250_CUSTOMIZED_REPORT WITH (NOLOCK) WHERE ReportName=@ReportName AND ReportType=@ReportType)
			BEGIN
				SELECT @ReportID = IsNull(ReportID,@ReportID) FROM T0250_CUSTOMIZED_REPORT WITH (NOLOCK) WHERE ReportName=@ReportName AND ReportType=@ReportType
				SET @TranType = 2 --UPDATE
			END
			
		Declare @ReportUrl Varchar(128)
		SET @ReportUrl = 'Report_Customized.aspx?rid=' + Cast(@ReportID As varchar(10))

		--For Insert
		IF @TranType = 1
			BEGIN		
			--print 22 ---mansi
				INSERT INTO T0250_CUSTOMIZED_REPORT (ReportID, ReportName, TypeID, ReportType)
				VALUES(@ReportID, @ReportName,@TypeID,@ReportType)				
			END
		ELSE IF @TranType = 2 --For Update
			BEGIN
				UPDATE	T
				SET		ReportName=@ReportName,
						ReportType=@ReportType
				FROM	T0250_CUSTOMIZED_REPORT T
				WHERE	ReportID=@ReportID
			END

		Declare @Under_Form_ID Varchar(128)
		SELECT @Under_Form_ID = Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name=Replace(@ReportType, ' & ', '_') + ' Customize' AND Page_Flag='AR'

		IF IsNull(@Under_Form_ID,0) = 0
			BEGIN
				SELECT	@Under_Form_ID = Form_ID 
				FROM	T0000_DEFAULT_FORM WITH (NOLOCK)
				WHERE	Form_Name LIKE Replace(@ReportType, ' & ', '_') + ' Customize'
			END

		
		IF @Under_Form_ID > 0 
			BEGIN 
				DECLARE @Form_ID INT
				DECLARE @Sort_ID_Check INT

				SELECT	@Form_ID = Form_id,@Sort_ID_Check=Sort_ID_Check
				FROM	T0000_DEFAULT_FORM WITH (NOLOCK)
				WHERE	Form_name = @ReportName And Under_Form_ID=@Under_Form_ID 
				
				

				EXEC P0000_DEFAULT_FORM 
						@Form_ID = @Form_ID OUTPUT,
						@Form_Name=@ReportName,
						@Alias=@ReportName,	
						@Under_Form_ID=@Under_Form_ID,
						@Page_Flag='AR',
						@Module_Name=@ModuleName,
						@Form_Type=1,
						@Sort_ID=1, 
						@Sort_ID_Check=@Sort_ID_Check OUTPUT,
						@Is_Active_For_Menu = 1

				UPDATE T0250_CUSTOMIZED_REPORT SET Form_ID=@Form_ID WHERE ReportID=@ReportID
				
				IF @Form_ID IS NOT NULL
					BEGIN
						UPDATE	T0000_DEFAULT_FORM 
						SET		Alias = @ReportName,
								Form_url = IsNull(@ReportUrl,Form_url),
								Page_Flag = 'AR',
								Sort_ID=IsNull(@SortID,Sort_ID)
						WHERE	Form_name = @ReportName And Under_Form_ID=@Under_Form_ID 
					END	
				/*ELSE
					BEGIN
						
						SELECT @Form_ID = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM 
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias], [Page_Flag])
						values (@Form_ID,@ReportName,@Under_Form_ID,IsNull(@SortID,@ReportID),1,@ReportUrl,'',1,@ReportName,'AR')	
					END
				*/
				
			END
	END
