

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Quick_Access_Link]
	-- Add the parameters for the stored procedure here
	@Cmp_ID			INT,
	@Emp_ID			INT,
	@Privilege_ID	INT = 0,
	@Module_Name    VARCHAR(64),
	@Flag			Char(2)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	CREATE TABLE #Form_Links
	(
			
			Form_ID		INT,
			Form_Name	Varchar(512),			
			Alias		Varchar(512),
			Form_Url	Varchar(512)
					
	)
		
	--SET @Module_Name = 'ATT_LEAVE'	

	DECLARE  @FORMS VARCHAR(MAX) 


	DECLARE @FLAGS VARCHAR(64)

	IF @FLAG ='A'
		SET @FLAGS = 'DA;AP;AR;HA'
	ELSE
		SET @FLAGS = 'DH;EP;ER;HP:IP'


	IF @Module_Name = 'ATT_LEAVE'
		SET @FORMS = 'Leave Application My#;Employee CTC Report Member#;FORM 11 (PF) My#;Employee Warning My#;Register With Settlement My#'
		
	Else IF @Module_Name = 'ATT_ATTANDANCE_LEAVE' 
		SET @FORMS = 'Attendance Register My#;Attendance Regularization My#;Attendance Approval My#;Leave Approval My#;'
		
	/*Put here more condition in future	*/
	--Insert Into #Form_Links(Form_ID,Form_Name,Alias,Form_Url)	
	SELECT	D.Form_ID,
	CASE lower(substring(REPLACE(REPLACE(D.Form_Name, '#My', ''),'#',''), datalength(REPLACE(REPLACE(D.Form_Name, '#My', ''),'#','')) - 1, datalength( REPLACE(REPLACE(D.Form_Name, '#My', ''),'#','') ) ))
	WHEN 'my'
	THEN	
		substring( REPLACE(REPLACE(D.Form_Name, '#My', ''),'#',''), 1, datalength( REPLACE(REPLACE(D.Form_Name, '#My', ''),'#','') ) - 2 ) + '' 
	ELSE
		REPLACE(REPLACE(D.Form_Name, '#My', ''),'#','')
	END as Form_Name, 
	CASE lower(substring( REPLACE(REPLACE(D.Alias, '#My', ''),'#',''), datalength( REPLACE(REPLACE(D.Alias, '#My', ''),'#','') ) - 1, datalength( REPLACE(REPLACE(D.Alias, '#My', ''),'#','') ) ))
	WHEN 'my'
	THEN	
		substring( REPLACE(REPLACE(D.Alias, '#My', ''),'#',''), 1, datalength( REPLACE(REPLACE(D.Alias, '#My', ''),'#','') ) - 2 ) + '' 
	ELSE
		REPLACE(REPLACE(D.Alias, '#My', ''),'#','')
	END	 as Alias ,
	 D.Form_Url
	FROM	T0000_DEFAULT_FORM D WITH (NOLOCK)
			LEFT OUTER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON D.Form_ID=PD.Form_Id AND PD.Privilage_ID=@Privilege_ID AND (Is_Edit + Is_View + Is_Save + Is_Delete  + Is_Print) > 0
	WHERE	EXISTS(SELECT 1 FROM dbo.Split(@FLAGS, ';') F Where F.Data = D.Page_Flag)
			AND (Case When @Privilege_ID > 0  AND IsNull(PD.Privilage_ID,0) = 0 Then 0 Else 1 End ) = 1  
			AND EXISTS(SELECT 1 FROM T0011_module_detail M WITH (NOLOCK) WHERE IsNull(D.Module_name, 'Payroll') = M.module_name AND M.module_status=1)
			AND EXISTS(SELECT 1 FROM dbo.Split(@FORMS, ';') t where t.data = d.Form_Name)
			
			
		
		--DECLARE @JSONData NVarchar(Max)

		--SELECT  @JSONData = COALESCE(@JSONData + ',', '') + '
		--			{
						
		--				"Form_ID" :' + Cast(Form_ID As Varchar(10)) + ',
		--				"Form_Name" : "' + Form_Name + '",
		--				"Alias" :' + ISNULL('"' + Alias + '"', 'null') + ',
		--				"Form_Url" :' + ISNULL('"' + Replace(Form_Url, '"', '''') + '"', 'null') + '
		--			}'					
		--FROM	#Form_Links N				
		
		--IF @JSONData Is Not Null
		--	SET @JSONData = '['  + @JSONData +  ']'
		
		--select @JSONData
		--print @JSONData
END

