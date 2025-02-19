-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 10-07-2020
-- Description:	Dispaly Fields 
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Default_Display_Fields]	
	@Cmp_ID numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Tran_ID Numeric
	DECLARE @CAPTION_NAME VARCHAR(250)
	
	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Vertical')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields  WITH (NOLOCK)			
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Vertical' and Cmp_Id=@Cmp_ID
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Vertical','Dropdownlist',@CAPTION_NAME,0,1
		End
	ELSE
		BEGIN	
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Vertical' and Cmp_Id=@Cmp_ID
			UPDATE T0040_Setting_Display_Fields SET Control_Display_Name=@CAPTION_NAME WHERE Field_Name='Vertical' and Cmp_Id=@Cmp_ID
		END
		
	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Business_Segment')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)  
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Business Segment' and Cmp_Id=@Cmp_ID
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Business_Segment','Dropdownlist',@CAPTION_NAME,0,2
		End
	ELSE
		BEGIN	
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Business Segment' and Cmp_Id=@Cmp_ID
			UPDATE T0040_Setting_Display_Fields SET Control_Display_Name=@CAPTION_NAME WHERE Field_Name='Business_Segment' and Cmp_Id=@Cmp_ID
		END

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Sub_Vertical')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK) 			
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='SubVertical' and Cmp_Id=@Cmp_ID
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Sub_Vertical','Dropdownlist',@CAPTION_NAME,0,3
		End
	ELSE
		BEGIN	
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='SubVertical' and Cmp_Id=@Cmp_ID
			UPDATE T0040_Setting_Display_Fields SET Control_Display_Name=@CAPTION_NAME WHERE Field_Name='Sub_Vertical' and Cmp_Id=@Cmp_ID
		END

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Cost_Center')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields  WITH (NOLOCK)			
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Cost Center' and Cmp_Id=@Cmp_ID
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Cost_Center','Dropdownlist',@CAPTION_NAME,0,4
		End
	ELSE
		BEGIN	
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Cost Center' and Cmp_Id=@Cmp_ID
			UPDATE T0040_Setting_Display_Fields SET Control_Display_Name=@CAPTION_NAME WHERE Field_Name='Cost_Center' and Cmp_Id=@Cmp_ID
		END

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Aadhar_Card_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Aadhar_Card_No','Textbox','Aadhar Card No',0,5
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'PAN_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','PAN_No','Textbox','PAN No',0,6
		End	

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Bank_Name')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Bank_Name','Dropdownlist','Bank Name',0,7
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Bank_Account_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Bank_Account_No','Textbox','Bank Account No',0,8
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Bank_IFSC_Code')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Bank_IFSC_Code','Textbox','Bank IFSC Code',0,9
		End
	
	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Bank_Branch_Name')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Bank_Branch_Name','Textbox','Bank Branch Name',0,10
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'ESIC_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','ESIC_No','Textbox','ESIC No',0,11
		End

	--IF Not Exists(Select 1 From T0040_Setting_Display_Fields Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'PF_No')
	--	Begin
	--		Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields
	--		Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','PF_No','Textbox','PF No',0,12
	--	End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Enroll_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Enroll_No','Textbox','Enroll No',0,12
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'UAN_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','UAN_No','Textbox','UAN No',0,13
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Mobile_No')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Mobile_No','Textbox','Mobile No',0,14
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Official_Email_ID')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Official_Email_ID','Textbox','Official Email ID',0,15
		End

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Sub_Branch')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Sub Branch' and Cmp_Id=@Cmp_ID
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Sub_Branch','Dropdownlist',@CAPTION_NAME,0,16
		End
	ELSE
		BEGIN	
			SELECT @CAPTION_NAME=Alias FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE Caption='Sub Branch' and Cmp_Id=@Cmp_ID
			UPDATE T0040_Setting_Display_Fields SET Control_Display_Name=@CAPTION_NAME WHERE Field_Name='Sub_Branch' and Cmp_Id=@Cmp_ID
		END

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Module_Name='Employee' and Field_Name= 'Minimum_Wages_Skill_Type_Master')
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			Exec P0040_Setting_Display_Fields @Tran_ID,@Cmp_ID,'Employee','Minimum_Wages_Skill_Type_Master','Dropdownlist','Minimum Wages Skill Type Master',0,17
		End
END

