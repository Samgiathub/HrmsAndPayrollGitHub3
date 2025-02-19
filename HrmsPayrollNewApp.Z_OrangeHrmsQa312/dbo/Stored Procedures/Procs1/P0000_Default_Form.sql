
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Default_Form]
	@Form_ID		INT OUTPUT,
	@Form_Name		Varchar(100),
	@Alias			Varchar(100),	
	@Under_Form_ID	INT,
	@Page_Flag		Char(2),
	@Module_Name	Varchar(100),
	@Form_Type		BIT,
	@Sort_ID		INT OUTPUT,  
	@Sort_ID_Check	INT OUTPUT,
	@Form_URL		Varchar(500) = NULL,
	@Form_Image_URL	Varchar(500) = NULL,
	@Is_Active_For_Menu BIT = 1,
	@Chinese_Alias	NVarchar(1000) = NULL
AS	
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		--First Trial
		SELECT @Form_ID=Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name=@Form_Name AND  Page_Flag=@Page_Flag

		--Second Trial
		
		IF IsNull(@Form_ID,0) = 0
			BEGIN
				SELECT @Form_ID=Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name=@Form_Name AND Under_Form_ID=@Under_Form_ID --AND Page_Flag Is Null									
			END

		IF IsNull(@Form_ID,0) > 0
			BEGIN
				UPDATE	T0000_DEFAULT_FORM
				SET		Alias=@Alias,	
						Page_Flag=@Page_Flag,
						Under_Form_ID=IsNull(@Under_Form_ID,Under_Form_ID),
						Module_Name=IsNull(@Module_Name,Module_Name),
						Form_Type=IsNull(@Form_Type,Form_Type),
						Sort_ID=IsNull(@Sort_ID,Sort_ID), 
						Sort_ID_Check=IsNull(@Sort_ID_Check,Sort_ID_Check),
						Form_URL=@Form_URL,
						Form_Image_URL=@Form_Image_URL,
						Is_Active_For_Menu=@Is_Active_For_Menu,
						Chinese_Alias=@Chinese_Alias
				WHERE	Form_ID=@Form_ID
			END
		ELSE
			BEGIN
				SELECT @Form_ID = Max(Form_ID) FROM T0000_DEFAULT_FORM WITH (NOLOCK)
				IF @Form_ID IS NULL
					SET @Form_ID = 1000 --Default Starts from 1000
				SET @Form_ID = @Form_ID +1

				
				INSERT INTO T0000_DEFAULT_FORM(Form_ID,Form_Name,Alias,Under_Form_ID,Page_Flag,Module_name,
						Form_Type,Sort_ID,Sort_Id_Check,Form_url,Form_Image_url,Is_Active_For_menu,chinese_alias)
				VALUES (@Form_ID,@Form_Name,@Alias,@Under_Form_ID,@Page_Flag,@Module_Name,
						@Form_Type,@Sort_ID,IsNull(@Sort_ID_Check,1),@Form_URL,@Form_Image_URL,@Is_Active_For_Menu,@Chinese_Alias)
			END

		IF EXISTS(SELECT 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Form_ID)
			SET @Form_ID = @Form_ID + 1
		ELSE
			SET @Sort_ID_Check = IsNull(@Sort_ID_Check,1) + 1
	END




