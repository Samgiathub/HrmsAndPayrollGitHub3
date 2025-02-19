

-- =============================================
-- Author:		Binal Prajapati
-- Create date: 17012020
-- Description:	This is used for display mobile number and email addeess in forgot password page for select otp options
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Sp_Get_Forgot_Email_Structure]
	-- Add the parameters for the stored procedure here
	@Email  nvarchar(max) ='',
	@Phone varchar(50)=''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	IF  @Email <> ''
	BEGIN

		DECLARE @size_email AS INT
		DECLARE @tmp_size_email AS INT
		DECLARE	@hide_email AS VARCHAR(MAX)

		SET @hide_email = 'X'

		SET @size_email = CHARINDEX('@',@Email)-4

		SET @tmp_size_email=@size_email
				
		IF @size_email > 1 
			BEGIN
				WHILE @size_email > 0
				BEGIN
					SELECT @hide_email = @hide_email + 'x'
					SET @size_email = @size_email - 1
				END
			END

		IF LEN(@hide_email) = 0 
		BEGIN
			SET @hide_email = ''
		END
		
		IF LEN(@hide_email) <> LEN(@tmp_size_email)
		BEGIN
			SET @hide_email = SUBSTRING(@hide_email,1,len(@hide_email)-1)
		END
		


		IF @tmp_size_email <> 0
		BEGIN
			Set @Email= @hide_email + SUBSTRING(@Email,CHARINDEX('@',@Email)-3,50)
	    END
		

	End
	

	IF  @Phone <> ''
	BEGIN
			Set @Phone= 'XXXXXX'+ RIGHT(@Phone,4)
	END
	 
	SELECT @Email as EmailDisplay,@Phone as PhoneDisplay
END

