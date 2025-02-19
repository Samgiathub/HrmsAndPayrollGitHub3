
CREATE PROCEDURE [dbo].[P0500_SubCatSkill_Master_Import]
	 @Cmp_Id		NUMERIC(18,0)
	,@SubCat_Name   VARCHAR(100)			
	,@SubCat_Code   varchar(100)=''	
	,@CatSkill	varchar(200)
	,@Row_No		INT = 0
	,@Log_Status	INT = 0 OUTPUT
	,@GUID  varchar(2000) = ''
	,@Entry_Type varchar(20)='Insert'
	,@UserID int
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	set @Log_Status =0
	DECLARE @Tran_ID	AS NUMERIC(18,0)
	DECLARE @Cat_Id as Numeric(18,0)		
    
    Set @Tran_ID = 0
    Set @Cat_Id = 0	
	
	if (@Entry_Type='')
		Begin
			set @Entry_Type='Insert'
		End
	
	if @SubCat_Name = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Sub Cat. Skill Name is not Provided',@SubCat_Name,'Enter proper Sub Cat. Skill Name',GETDATE(),'Sub Cat. Skill Master',@GUID)
			RETURN	
		End		
	
	if @CatSkill = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Cat. Skill Name is not Provided',@CatSkill,'Enter proper Cat. Skill Name',GETDATE(),'Sub Cat. Skill Master',@GUID)
			RETURN	
		End	
		
	
	if @SubCat_Code = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Cat. Skill code is not Provided',@SubCat_Code,'Enter proper Cat. Skill Code',GETDATE(),'Sub Cat. Skill Master',@GUID)
			RETURN	
		End
		
		
	select @Cat_Id=isnull(Cat_Id,0) from T0500_CatSkill_Master WITH (NOLOCK) where CMP_ID=@Cmp_Id and upper(Cat_Name)=upper(@CatSkill)

	
	   if ISNULL(@Cat_Id,0)=0
	   begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Cat. Skill Name Doesn''t exists',@CatSkill,'Enter proper Cat. Skill Name',GETDATE(),'Sub Cat. Skill Master',@GUID)
			RETURN	
	   end
	

	IF EXISTS (SELECT 1 FROM T0500_SubCatSkill_Master WITH (NOLOCK) WHERE SubCat_Name=@SubCat_Name and Cat_Id=@Cat_Id and @Entry_Type='I')
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Sub Cat. Skill Name exists',@SubCat_Name,'Enter proper Sub Cat. Skill Name',GETDATE(),'Sub Cat. Skill Master',@GUID)
			RETURN
		End
	Else
		Begin
			
					select @Tran_ID = isnull(max(SubCat_Id),0) + 1 from T0500_SubCatSkill_Master WITH (NOLOCK)
					INSERT INTO T0500_SubCatSkill_Master
								   (SubCat_Id,Cmp_Id,SubCat_Name,SubCat_Code,Cat_Id,Record_Date,Created_By)
						VALUES     (@Tran_ID,@Cmp_ID,@SubCat_Name,@SubCat_Code,@Cat_Id,GETDATE(),@UserID)	

		End

