


-- =============================================
-- Author:		<Hiral>
-- ALTER date: <23 May, 2013>
-- Description:	<Insert/Update Record of T0011_Password_Settings >
-- =============================================
CREATE PROCEDURE [dbo].[P0011_Password_Settings]
	 @Password_ID			Numeric(18,0)
	,@Cmp_ID				Numeric(18,0)
	,@Enable_Validation		TinyInt
	,@Min_Chars				Numeric(18,0)
	,@Upper_Char			TinyInt
	,@Lower_Char			TinyInt
	,@Is_Digit				TinyInt
	,@Special_Char			TinyInt
	,@Password_Format		Varchar(200)
	,@Pass_Exp_Days			Numeric(18,0)
	,@Reminder_Days			Numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	If @Pass_Exp_Days = 0
		Set @Pass_Exp_Days = NULL
		
	If @Reminder_Days = 0
		Set @Reminder_Days = NULL

	If Exists (Select Password_ID From T0011_Password_Settings WITH (NOLOCK) Where Cmp_ID = @Cmp_ID)
		Begin
			Update T0011_Password_Settings 
				Set  Enable_Validation	= @Enable_Validation
					,Min_Chars			= @Min_Chars
					,Upper_Char			= @Upper_Char
					,Lower_Char			= @Lower_Char
					,Is_Digit			= @Is_Digit
					,Special_Char		= @Special_Char
					,Password_Format	= @Password_Format
					,Pass_Exp_Days		= @Pass_Exp_Days
					,Reminder_Days		= @Reminder_Days
				Where Cmp_ID = @Cmp_ID
		End
	Else
		Begin
			Select @Password_ID = ISNULL(MAX(Password_ID),0) + 1 from T0011_Password_Settings WITH (NOLOCK)
			
			Insert Into T0011_Password_Settings 
				(Password_ID, Cmp_ID, Enable_Validation, Min_Chars, Upper_Char, Lower_Char, 
				 Is_Digit, Special_Char, Password_Format, Pass_Exp_Days, Reminder_Days)
				Values (@Password_ID, @Cmp_ID, @Enable_Validation, @Min_Chars, @Upper_Char, @Lower_Char,
				 @Is_Digit, @Special_Char, @Password_Format, @Pass_Exp_Days, @Reminder_Days)
		End
END


