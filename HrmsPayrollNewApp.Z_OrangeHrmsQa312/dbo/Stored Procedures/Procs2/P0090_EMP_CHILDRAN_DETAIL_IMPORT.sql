
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_CHILDRAN_DETAIL_IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@Name varchar(100)
     ,@Gender char(1)
     ,@Date_Of_Birth datetime
     ,@C_Age numeric(18,1)
     ,@RelationShip varchar(50)
     ,@Is_Resi  numeric(1,0) = 0
     ,@Is_Dependant tinyint = 0 --Alpesh 06-Aug-2011
	 --------------------------Added by ronakk 06062022 ------------------------------------------
	 
	 ,@Occupation nvarchar(100) = ''
	 ,@Hobby nvarchar(1000) = ''
	 ,@CompanyName nvarchar(100) = ''
	 ,@CompanyCity nvarchar(100) = ''
	 ,@DepWorkTime nvarchar(200) = ''
	 ,@Standard nvarchar(100) = ''
	 ,@StdSpecialization nvarchar(200) = '' --Added by ronakk 22072022
	 ,@SchoolCol nvarchar(100) = ''
	 ,@SchoolColCity nvarchar(100) = ''
	 ,@ExtActivity  nvarchar(500) = ''

     -----------------------------End by ronakk 06062022 -----------------------------------------
     ,@Tran_Type varchar(1)	 
	 ,@GUID Varchar(2000) = '' --Added by nilesh patel on 17062016

 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
DECLARE @Emp_id numeric
Set @Emp_id = 0
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id

if isnull(@Emp_id,0) = 0
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GETDATE(),'Employee FamilyMember',@GUID)
		RETURN
	End

If @RelationShip = ''
	Set @RelationShip = NULL
	
if @RelationShip IS NULL 
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Employee Relation Detail Doesn''t exists',@Alpha_Emp_Code,'Enter proper Relation Detail of Family Member',GETDATE(),'Employee FamilyMember',@GUID)
		RETURN
	End 


if not exists (select 1 from T0040_Relationship_Master where Cmp_Id=@Cmp_ID and Relationship = @RelationShip)
Begin
--Added by ronakk 07062022
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Employee Relation Detail Doesn''t exists',@Alpha_Emp_Code,'Enter proper Relation Detail of Family Member',GETDATE(),'Employee FamilyMember',@GUID)
		RETURN
End



IF @Date_Of_Birth = ''  
  SET @Date_Of_Birth  = NULL 
  
if @Date_Of_Birth Is NULL 
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Employee Date of Birth Details Doesn''t exists',@Alpha_Emp_Code,'Employee Date of Birth Details Doesn''t exists',GETDATE(),'Employee FamilyMember',@GUID)
		RETURN
	End
  
  --Added BY Jimit 14032019
	IF @Date_Of_Birth > GETDATE()
		BEGIN
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Future Birth Date is not Allowed.',0,'Enter Valid Birth Date',GETDATE(),'Employee Master',@GUID) 
				RETURN
		END				
	--ENDED

Declare @Age numeric(18,2)
set @Age= datediff(year,@Date_Of_Birth,getdate())

if @Gender IS NULL or @Gender = ''
	Begin
		Set @Gender = 'M'
	End


	------------------------------------------------ Added by ronakk 06062022 -------------------------------
	
	if @Occupation <> ''
	Begin

		declare @OccupationID as int = 0 
		select @OccupationID=O_ID from T0040_Occupation_Master where Cmp_ID=@Cmp_ID and Occupation_Name =@Occupation

		if @OccupationID =0 
		Begin
		      INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Family Member Occupation Detail Doesn''t exists',@Alpha_Emp_Code,'Enter proper Occupation Detail of Family Member',GETDATE(),'Employee FamilyMember',@GUID)
			  RETURN
		End

	End

	

	if @Standard <> ''
	Begin

			declare @StandardID as int =0
			select @StandardID = S_ID from T0040_Dep_Standard_Master where Cmp_ID=@Cmp_ID and StandardName = @Standard
			
			if @StandardID = 0
			Begin
			   INSERT INTO dbo.T0080_Import_Log VALUES (@Row_ID,@Cmp_Id,@Alpha_Emp_Code,'Family Member Standard Detail Doesn''t exists',@Alpha_Emp_Code,'Enter proper Standard Detail of Family Member',GETDATE(),'Employee FamilyMember',@GUID)
			   RETURN
			End

	End
	
	
	


		declare @HobbyID as  nvarchar(max)
		declare @HobName as nvarchar(max)
		
		select @HobbyID=COALESCE(@HobbyID + ',' + cast(H_ID as nvarchar),cast(H_ID as nvarchar)),
		       @HobName=COALESCE(@HobName + ',' + cast(HobbyName as nvarchar),cast(HobbyName as nvarchar)) 
		from T0040_Hobby_Master where Cmp_ID=@Cmp_ID and HobbyName in (select cast(data  as nvarchar) from dbo.Split (@Hobby,',')  T Where T.Data <> '')
		


		if @Occupation = 'Student'
		 Begin
		    set @CompanyName = ''
			set @CompanyCity = ''
			set @DepWorkTime='' --Added by ronakk 03082022
		 End
		 else if @Occupation = 'Employee' or @Occupation = 'Retired' or @Occupation = 'Self-Employee' 
		 Begin
		     set @StandardID = 0
			 set @StdSpecialization =''
			 set @SchoolCol = ''
			 set @SchoolColCity = ''
			 set @ExtActivity = ''
		 End
		 else if @Occupation = '' 
		 Begin
		     set @CompanyName = ''
			 set @CompanyCity = ''
			 set @DepWorkTime='' --Added by ronakk 03082022
			 set @StandardID = 0
			 set @StdSpecialization =''
			 set @SchoolCol = ''
			 set @SchoolColCity = ''
			 set @ExtActivity = ''
		 End

	----------------------------------------------------End  by ronakk 06062022 -----------------------------




IF @Tran_Type ='I'
		
		BEGIN 
		 	
			If exists(select Row_ID from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And Gender=@Gender And Date_Of_Birth = @Date_Of_Birth And RelationShip=@RelationShip)
				BEgin 


						--Added by ronakk 070620222

						update T0090_EMP_CHILDRAN_DETAIL set 
						Is_Resi =@Is_Resi
					   ,Is_Dependant=@Is_Dependant
					   ,OccupationID =@OccupationID
					   ,HobbyID = @HobbyID
					   ,HobbyName =@HobName
					   ,DepCompanyName = @CompanyName
					   ,CmpCity = @CompanyCity
					   ,DepWorkTime = @DepWorkTime --Added by ronakk 03082022
					   ,Standard_ID = @StandardID
					   ,Std_Specialization = @StdSpecialization --Added by ronakk 22072022 
					   ,Shcool_College = @SchoolCol
					   ,City = @SchoolColCity
					   ,ExtraActivity =@ExtActivity
						where Emp_ID = @Emp_ID And Name=@Name And Gender=@Gender And Date_Of_Birth = @Date_Of_Birth And RelationShip=@RelationShip

						--End by ronakk 070620222

							--Set @Row_ID = 0
						return

				End
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_CHILDRAN_DETAIL
				                      (Emp_ID, Row_ID, Cmp_ID, Name, Gender, Date_Of_Birth,C_Age,RelationShip,Is_Resi,Is_Dependant
									  ,OccupationID,HobbyID,HobbyName,DepCompanyName,CmpCity,Standard_ID,Std_Specialization,Shcool_College,City,ExtraActivity,DepWorkTime )  -- Added by ronakk 06062022
				VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@Gender,@Date_Of_Birth,@Age,@RelationShip,@Is_Resi,@Is_Dependant
				,@OccupationID,@HobbyID,@HobName,@CompanyName,@CompanyCity,@StandardID,@StdSpecialization,@SchoolCol,@SchoolColCity,@ExtActivity,@DepWorkTime) -- Added by ronakk 06062022
		END
		
RETURN




