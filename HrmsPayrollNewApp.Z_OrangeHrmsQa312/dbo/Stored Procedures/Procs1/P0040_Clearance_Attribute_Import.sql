

-- =============================================
-- Author:		<Jaina>
-- Create date: <08-06-2016>
-- Description:	<Exit Clearance Attribute>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Clearance_Attribute_Import] 
	@Clearance_id numeric(18,0) output,
	@Cmp_id numeric(18,0),
	@DepartName varchar(200),
	@Item_code varchar(50),
	@Item_Name varchar(500),
	@Active tinyint,
	@Tran_Type varchar(1)='',
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '', 
	@Log_Status Int = 0 Output,
	@Row_No Int,
	@GUID Varchar(2000) = '' --Added by nilesh patel on 15062016

	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @OldValue As varchar(max)
Declare @OldDepartment As varchar(500)
Declare @NewDepartment As varchar(500)
Declare @OldItem_code As varchar(50)
Declare @OldItem_Name As varchar(500)
Declare @OldActive As varchar(10)
Declare @NewActive As varchar(10)
declare @Dept_id As numeric(18,0)

set @OldActive =''
set @OldDepartment = ''
set @OldItem_code = ''
set @OldItem_Name = ''
set @OldValue = ''
set @NewDepartment = ''
set @NewActive = ''
set @Dept_id = 0 

if isnull(@Tran_Type,'') = 'I'
Begin

	If @DepartName = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Department Name is not Properly Inserted',0,'Enter Proper Department Name',GetDate(),'Clearance Attribute Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
		
	IF @Item_Name = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Attribute Name is not Properly Inserted',0,'Enter Proper Attribute Name',GetDate(),'Clearance Attribute Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	--(Upper(Item_Code) = Upper(@Item_code) OR
	IF NOT EXISTS (SELECT DEPT_ID FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND UPPER(DEPT_NAME) = UPPER(isnull(@DEPARTNAME,'')) )
	BEGIN
	
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Department Name Not Exists',0,'Enter Proper Department Name',GETDATE(),'Clearance Attribute Import',@GUID)						
			SET @LOG_STATUS=1			
			RETURN
	END
	ELSE
		BEGIN
			SELECT @DEPT_ID = DEPT_ID FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND UPPER(DEPT_NAME) = UPPER(@DEPARTNAME)
		END
	
	IF EXISTS (SELECT CLEARANCE_ID  FROM T0040_CLEARANCE_ATTRIBUTE WITH (NOLOCK) WHERE  UPPER(ITEM_NAME) = UPPER(@ITEM_NAME)  AND CMP_ID = @CMP_ID AND Dept_id = @Dept_id) 
	BEGIN
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Attribute Name Not Exists',0,'Enter Proper Attribute Name',GETDATE(),'Clearance Attribute Import',@GUID)						
			SET @LOG_STATUS=1			
			RETURN
	END
	
	SELECT @CLEARANCE_ID = ISNULL(MAX(CLEARANCE_ID),0)+ 1 FROM T0040_CLEARANCE_ATTRIBUTE WITH (NOLOCK)

	INSERT INTO T0040_Clearance_Attribute (Clearance_id,Cmp_id,Dept_id,Item_Code,Item_Name,Active)	
			VALUES (@Clearance_id,@Cmp_id,@Dept_id,@Item_code,@Item_Name,@Active)
	
	If @Active = 1	
		set @NewActive = 'YES'
	Else
		set @NewActive = 'NO'
						
	select @NewDepartment = Dept_Name from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Dept_Id = @Dept_id
			    
	set @OldValue = 'New Value' + '#' + 'Department Name :' + ISNULL(@NewDepartment,'') + 
								  --'#' + 'Item Code :' + ISNULL(@Item_code ,'') + 
								  '#' + 'Item Name :' + ISNULL(@Item_Name,'')+ 
								  '#' + 'Is Active :' + ISNULL(@NewActive,'')+ '#' 
											  
			
End

if isnull(@Tran_Type,'') = 'U'
Begin
	--upper(Item_Code) = upper(@Item_code) and
	IF Exists(select Clearance_id From dbo.T0040_Clearance_Attribute WITH (NOLOCK) Where Upper(Item_Name) = Upper(@Item_Name)AND  Cmp_ID = @Cmp_ID and Clearance_id <> @Clearance_id)  
    Begin  
	  print 1
     set @Clearance_id = 0  
     Return   
    End  
    
	select @OldDepartment = ( SELECT DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Dept_Id = CA.Dept_id),
		   @OldItem_code = Item_code,
		   @OldItem_Name = Item_name,
		   @OldActive = Active
	from T0040_Clearance_Attribute As CA WITH (NOLOCK)
	where Cmp_id= @Cmp_id and Clearance_id = @Clearance_id
	
	
	update T0040_Clearance_Attribute 
		set Dept_id = @Dept_id,
			Item_code = @Item_code,
			Item_name = @Item_Name,
			Active = @Active
		where Clearance_id = @Clearance_id and Cmp_id = @Cmp_id
	
	If @Active = 1	
		set @NewActive = 'YES'
	Else
		set @NewActive = 'NO'
		
	select @NewDepartment = Dept_Name from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Dept_Id = @Dept_id and Cmp_Id = @Cmp_id
	
	set @OldValue = 'Old Value' + '#' + 'Department Name :' + ISNULL(@OldDepartment,'') + 
								  --'#' + 'Item Code :' + ISNULL(@OldItem_code ,'') + 
								  '#' + 'Item Name :' + ISNULL(@OldItem_Name,'')+ 
								  '#' + 'Is Active :' + case when isnull(@OldActive,0) = 1 then 'YES' ELSE 'NO' end + '#' +
					'New Value' + '#' + 'Department Name :' + ISNULL(@NewDepartment,'') + 
								  --'#' + 'Item Code :' + ISNULL(@Item_code ,'') + 
								  '#' + 'Item Name :' + ISNULL(@Item_Name,'')+ 
								  '#' + 'Is Active :' + ISNULL(@NewActive,'')+ '#' 
End

if isnull(@Tran_Type,'') = 'D'
Begin
	
	IF EXISTS (SELECT 1 FROM T0040_Clearance_Attribute C WITH (NOLOCK) INNER JOIN T0350_Exit_Clearance_Approval_Detail EA WITH (NOLOCK) ON C.Clearance_id = EA.Clearance_id WHERE C.Clearance_id = @Clearance_id)
	BEGIN
			--SET @Tran_Id = 0
			RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
			RETURN 
	END
		
	select @OldDepartment = ( SELECT DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Dept_Id = CA.Dept_id),
		   @OldItem_code = Item_code,
		   @OldItem_Name = Item_name,
		   @OldActive = Active
	from T0040_Clearance_Attribute As CA WITH (NOLOCK)
	where Cmp_id= @Cmp_id and Clearance_id = @Clearance_id
	
	DELETE FROM T0040_Clearance_Attribute where Clearance_id = @Clearance_id and Cmp_id = @Cmp_id
	
	set @OldValue = 'Old Value' + '#' + 'Department Name :' + ISNULL(@OldDepartment,'') + 
								 -- '#' + 'Item Code :' + ISNULL(@OldItem_code ,'') + 
								  '#' + 'Item Name :' + ISNULL(@OldItem_Name,'')+ 
								  '#' + 'Is Active :' + case when isnull(@OldActive,0) = 1 then 'YES' ELSE 'NO' end + '#' 
End

exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Clearance Attribute Master',@OldValue,@Clearance_id,@User_Id,@IP_Address	

END

