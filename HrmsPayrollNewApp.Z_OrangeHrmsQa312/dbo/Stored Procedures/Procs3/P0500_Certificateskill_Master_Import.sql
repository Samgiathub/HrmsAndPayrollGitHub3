
CREATE PROCEDURE [dbo].[P0500_Certificateskill_Master_Import]
	 @Cmp_Id		NUMERIC(18,0)
	,@Cert_Name   VARCHAR(100)			
	,@Cert_Code   varchar(100)=''	
	,@CatSkill	varchar(200)
	,@SubCat_Name   VARCHAR(100)
	,@SortNO		INT = 0
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
	DECLARE @SubCat_Id as Numeric(18,0)	
    
    Set @Tran_ID = 0
    Set @Cat_Id = 0	
    Set @SubCat_Id = 0	

	
	if (@Entry_Type='')
		Begin
			set @Entry_Type='Insert'
		End
	
	if @Cert_Name = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Certificate Name is not Provided',@Cert_Name,'Enter proper Certificate Name',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN	
		End		
	
	if @CatSkill = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Cat. Skill Name is not Provided',@CatSkill,'Enter proper Cat. Skill Name',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN	
		End	

		
	if @SubCat_Name = '' 
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Sub Cat. Skill Name is not Provided',@SubCat_Name,'Enter Sub proper Cat. Skill Name',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN	
		End	
		
	
		
	  select @Cat_Id=isnull(Cat_Id,0) from T0500_CatSkill_Master WITH (NOLOCK) where CMP_ID=@Cmp_Id and upper(Cat_Name)=upper(@CatSkill)
	   if ISNULL(@Cat_Id,0)=0
	   begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Cat. Skill Name Doesn''t exists',@CatSkill,'Enter proper Cat. Skill Name',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN	
	   end

	   	  select @SubCat_Id=isnull(SubCat_Id,0) from T0500_SubCatSkill_Master WITH (NOLOCK) where CMP_ID=@Cmp_Id and upper(SubCat_Name)=upper(@SubCat_Name) and Cat_Id=@Cat_Id
	   if ISNULL(@SubCat_Id,0)=0
	   begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Sub Cat. Skill Name Doesn''t exists',@SubCat_Name,'Enter proper Sub Cat. Skill Name',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN	
	   end

	
	--and Cat_Id=@Cat_Id
	IF EXISTS (SELECT 1 FROM T0500_Certificateskill_Master WITH (NOLOCK) WHERE Certificate_Name=@Cert_Name and @Entry_Type='I')
		Begin
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,0,'Certificate Skill Mapping exists for this Certificate',@Cert_Name,'Enter proper Certificate Skill Mapping',GETDATE(),'Certificate Skill Mapping',@GUID)
			RETURN
		End
	Else
		Begin
			
					select @Tran_ID = isnull(max(Certi_Id),0) + 1  from T0500_Certificateskill_Master WITH (NOLOCK)
			
						INSERT INTO T0500_Certificateskill_Master 
					(Certi_Id,Cmp_id,Certificate_Name,Certificate_Code,Cat_ID,SubCat_Id,Created_By,Sorting_No,Created_Date)
					VALUES(@Tran_ID,@Cmp_Id,@Cert_Name,@Cert_Code,@Cat_ID,@SubCat_Id,@UserID,@SortNO,GETDATE())

		End

