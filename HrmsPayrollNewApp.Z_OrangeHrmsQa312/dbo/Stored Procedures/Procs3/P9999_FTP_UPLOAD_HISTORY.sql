

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 15-03-2019
-- Description:	FOR RECORING ALL FTP UPLOAD RECORD IN A TABLE FOR SECURITY AND AUDIT PURPOSE
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P9999_FTP_UPLOAD_HISTORY]
	@Cmp_ID				NUMERIC,
	@Login_ID			NUMERIC,
	@FtpUsername		VARCHAR(100),
	@FtpPassword		VARCHAR(100),
	@LocalIP_Address	VARCHAR(50),
	@GlobalIP_Address	VARCHAR(50),
	@MacAddress			VARCHAR(50),
	@FileName			VARCHAR(200),
	@MobileNo			VARCHAR(14)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	DECLARE @EXTENSION_NO AS NUMERIC
	SET @EXTENSION_NO = CAST(RIGHT(@FileName , 3) AS NUMERIC)
	
	DECLARE @REMARKS AS VARCHAR(500)
	
	IF NOT EXISTS (SELECT 1 FROM T0100_FTP_DETAILS WITH (NOLOCK))
		SET @REMARKS = 'FTP Details not Enterred in Table.'
			
	INSERT INTO T9999_FTP_UPLOAD_HISTORY
		(Cmp_ID, Login_ID, FTP_Username, FTP_Password, Login_Date, LocalIp_Address, GlobalIp_Address, MacAddress, Ftp_FileName, FileExtension , Mobile_Number , Remarks)
	VALUES
		(@Cmp_ID , @Login_ID , @FtpUsername , @FtpPassword ,GETDATE(), @LocalIP_Address , @GlobalIP_Address , @MacAddress , @FileName , @EXTENSION_NO , @MobileNo , @REMARKS)
		
		
END

