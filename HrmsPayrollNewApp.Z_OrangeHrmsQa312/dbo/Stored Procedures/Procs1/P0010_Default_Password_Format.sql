

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 25102017 
-- Description:	Default Password Setting
-- =============================================
CREATE PROCEDURE [dbo].[P0010_Default_Password_Format]
	-- Add the parameters for the stored procedure here
	@Tran_ID Numeric Output,
	@Cmp_ID Numeric,
	@EffectiveDate Datetime,
	@Pwd_Type varchar(100),
	@Pwd_Format Varchar(500),
	@UserID numeric,
	@IP_Address Varchar(50),
	@Tran_Type Char(1)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET @Tran_ID = 0
	
	if Exists(SELECT 1 From T0010_Default_Password_Format WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and EffectiveDate = @EffectiveDate)
		BEGIN
			RAISERROR('@@Same Date Records already exists.@@',16,2)
			return
		End
	
	if @Tran_Type = 'I'
		Begin
			SELECT @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0010_Default_Password_Format WITH (NOLOCK)
			INSERT INTO T0010_Default_Password_Format(Tran_ID,Cmp_ID,EffectiveDate,Pwd_Type,Pwd_Format,UserID,SysDate,IP_Address)
			Values(@Tran_ID,@Cmp_ID,@EffectiveDate,@Pwd_Type,@Pwd_Format,@UserID,GetDate(),@IP_Address)
		End
	Else if @Tran_Type = 'D'
		Begin
			Delete From T0010_Default_Password_Format Where Cmp_ID = @Cmp_ID and Pwd_Type = @Pwd_Type and EffectiveDate = @EffectiveDate
		End
END

