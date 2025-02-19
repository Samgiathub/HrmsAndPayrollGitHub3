
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Audit_Trail]
 @Cmp_ID		NUMERIC
,@Audit_Change_Type	nvarchar(20)
,@Audit_Module_Name	nvarchar(500)
,@Audit_Modulle_Description	nvarchar(max)
,@Audit_Change_For		NUMERIC(18,0)
,@Audit_Change_By		NUMERIC(18,0)
,@Audit_Ip	nvarchar(100)
,@is_Emp	tinyint = 0
,@GUID varchar(500) = '0'

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Audit_Date as DateTime
	set @Audit_Date=GETDATE()
	
	
	if Exists(SELECT 1 From T9999_Audit_Trail WITH (NOLOCK) where Cmp_ID = @Cmp_ID AND Audit_Change_Type = @Audit_Change_Type AND Audit_Module_Name = @Audit_Module_Name AND Audit_Change_For = @Audit_Change_For AND KeyGUID = @GUID AND @GUID <> '0')
	BEGIN
		
			Update T9999_Audit_Trail Set Audit_Modulle_Description += @Audit_Modulle_Description where Cmp_ID = @Cmp_ID AND Audit_Change_Type = @Audit_Change_Type AND Audit_Module_Name = @Audit_Module_Name AND Audit_Change_For = @Audit_Change_For AND KeyGUID = @GUID
	END
	Else
	Begin
		
			declare @Audit_Trail_Id as numeric(18,0)		
			select @Audit_Trail_Id = isnull(max(Audit_Trail_Id),0) + 1  from T9999_Audit_Trail WITH (NOLOCK)	

			insert into T9999_Audit_Trail (Audit_Trail_Id,Cmp_ID,Audit_Change_Type,Audit_Module_Name,Audit_Modulle_Description,Audit_Change_For,Audit_Change_By,Audit_Date,Audit_Ip,is_emp_id,KeyGUID)
		    Values(@Audit_Trail_Id,@Cmp_ID,@Audit_Change_Type,@Audit_Module_Name,@Audit_Modulle_Description,@Audit_Change_For,@Audit_Change_By,GETDATE(),@Audit_Ip,@is_Emp,@GUID)
			
	End

RETURN

