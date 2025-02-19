
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_EMPCHILDRANDETAIL]
	 @Row_ID numeric(18,0) 
	,@Emp_ID numeric(18,0)
    ,@Cmp_ID numeric(18,0)
    ,@Name varchar(100)
    ,@Gender char(1)
    ,@Date_Of_Birth Varchar(50) = ''
    ,@C_Age numeric(18,1)
    ,@RelationShip varchar(50)
    ,@Is_Resi  numeric(1,0)
    ,@Is_Dependant tinyint
    ,@tran_type char(1)
    ,@Login_Id numeric(18,0)=0 
    ,@Image_Path varchar(500) = NULL
    ,@Pan_Card_No Varchar(20) = ''  
    ,@Adhar_Card_No Varchar(20) = '' 
	,@Height VARCHAR(10) = NULL 
	,@Weight VARCHAR(10) = NULL 
	---------------------------------- Added by ronakk 02062022 -------------------------------------
    ,@OccupationID int =0
	,@HobbyID nvarchar(500) = ''
	,@HobbyName nvarchar(1000) = ''
	,@DepCompany nvarchar(200) = ''
	,@StandardID int =0
	,@SchoolCol nvarchar(200) = ''
	,@ExtActivity nvarchar(500) = ''
    ---------------------------------- End by ronakk 02062022 ---------------------------------------
	,@CitySchCol nvarchar(200) = '' 
	,@CmpCity nvarchar(200) = '' 
	,@Result varchar(250) output
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Date_Of_Birth = ''  
  SET @Date_Of_Birth  = NULL
  
  if @Date_Of_Birth is not null
  Begin
		Declare @Age as numeric(18,2)
        set @Age = DateDiff(year,@Date_Of_Birth,getdate())
  end
  else
		set @age =	0.00

  
	If @tran_type  = 'I'
		Begin
			
				If exists(select Row_ID from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And Date_Of_Birth = @Date_Of_Birth And Gender=@Gender)
				BEgin 
					Set @Result = 'Employee already exists#False#'
					return
				End
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
					
				insert into T0090_EMP_CHILDRAN_DETAIL 
				(
				 Row_ID 
				,Emp_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant 
				,Image_path
				,Pan_Card_No
				,Adhar_Card_No
				,Height
				,Weight
				------------------------------Added  by ronakk 02062022 -------------------------------
				,OccupationID
				,HobbyID
				,HobbyName
				,DepCompanyName
				,Standard_ID
				,Shcool_College
				,ExtraActivity
				------------------------------End  by ronakk 02062022 ---------------------------------
				,City 
				,CmpCity 
				) 
				values
				(
				 @Row_ID 
				,@Emp_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant--Alpesh 06-Aug-2011
				,@Image_Path
				,@Pan_Card_No
				,@Adhar_Card_No
				,@Height
				,@Weight
			 ---------------------------------- Added by ronakk 02062022 -------------------------------------
				 ,@OccupationID 
				 ,@HobbyID 
				 ,@HobbyName 
				 ,@DepCompany 
				 ,@StandardID 
				 ,@SchoolCol
				 ,@ExtActivity 
			
            ---------------------------------- End by ronakk 02062022 ---------------------------------------
			     ,@CitySchCol --Added by ronakk 03062022
				 ,@CmpCity --Added by ronakk 04062022

				)
				


				insert into T0090_EMP_CHILDRAN_DETAIL_Clone 
				(
				 Row_ID 
				,Emp_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant 
				,System_Date
				,Login_Id
				,Image_path
				------------------------------Added  by ronakk 02062022 -------------------------------
				,OccupationID
				,HobbyID
				,HobbyName
				,DepCompanyName
				,Standard_ID
				,Shcool_College
				,ExtraActivity
				------------------------------End  by ronakk 02062022 ---------------------------------
				,City --Added by ronakk 03062022
				,CmpCity --Added by ronakk 04062022

				) values
				(
				 @Row_ID 
				,@Emp_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant
				,GETDATE()
				,@Login_Id
				,@Image_Path
				---------------------------------- Added by ronakk 02062022 -------------------------------------
				 ,@OccupationID 
				 ,@HobbyID 
				 ,@HobbyName 
				 ,@DepCompany 
				 ,@StandardID 
				 ,@SchoolCol
				 ,@ExtActivity 
                 ---------------------------------- End by ronakk 02062022 ---------------------------------------
				 ,@CitySchCol --Added by ronakk 03062022
				 ,@CmpCity --Added by ronakk 04062022
				)				
					
				if @Row_ID > 0
				Begin 
					SET @Result = 'Inserted Successfully#True#'
				END
				RETURN 
		End
	Else if @Tran_Type = 'U'
		begin
				If exists(select Row_ID from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And Date_Of_Birth = @Date_Of_Birth And Gender=@Gender And Row_ID <> @Row_ID)
				BEgin 
					Set @Row_ID = 0
					return
				End
			
		UPDATE    T0090_EMP_CHILDRAN_DETAIL
		   SET              
				 Cmp_ID = @Cmp_ID
				,Name  = @Name
				,Gender = @Gender
				,Date_Of_Birth=@Date_Of_Birth
				,C_Age=@Age
				,Is_Resi = @Is_Resi
				,RelationShip=@RelationShip
				,Is_Dependant=@Is_Dependant
				,Image_path = @Image_Path
				,Pan_Card_No = @Pan_Card_No
				,Adhar_Card_No = @Adhar_Card_No
				,Height = @Height
				,Weight = @Weight
				------------------------------Added  by ronakk 02062022 -------------------------------
				,OccupationID=@OccupationID 
				,HobbyID=@HobbyID 
				,HobbyName=@HobbyName 
				,DepCompanyName=@DepCompany 
				,Standard_ID=@StandardID 
				,Shcool_College=@SchoolCol
				,ExtraActivity=@ExtActivity 
				------------------------------End  by ronakk 02062022 ---------------------------------
				,City = @CitySchCol --Added by ronakk 03062022
				,CmpCity = @CmpCity --Added by ronakk 04062022

		   WHERE     (Emp_ID = @Emp_ID) and Row_ID = @Row_ID
		   
		   insert into T0090_EMP_CHILDRAN_DETAIL_Clone 
				(
				 Row_ID 
				,Emp_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant 
				,System_Date
				,Login_Id
				,Image_path
				------------------------------Added  by ronakk 02062022 -------------------------------
				,OccupationID
				,HobbyID
				,HobbyName
				,DepCompanyName
				,Standard_ID
				,Shcool_College
				,ExtraActivity
				------------------------------End  by ronakk 02062022 ---------------------------------
				,City --Added by ronakk 03062022
				,CmpCity --Added by ronakk 04062022
				) values
				(
				 @Row_ID 
				,@Emp_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant
				,GETDATE()
				,@Login_Id
				,@Image_Path
				---------------------------------- Added by ronakk 02062022 -------------------------------------
				 ,@OccupationID 
				 ,@HobbyID 
				 ,@HobbyName 
				 ,@DepCompany 
				 ,@StandardID 
				 ,@SchoolCol
				 ,@ExtActivity 
                 ---------------------------------- End by ronakk 02062022 ---------------------------------------
				 ,@CitySchCol --Added by ronakk 03062022
				 ,@CmpCity --Added by ronakk 04062022
				)		

				SET @Result = 'Updated Successfully#True#'

					Return
		   end
	Else if @Tran_Type = 'D'
		begin
			if Exists(Select 1 FROM T0090_EMP_CHILDRAN_DETAIL WHERE Emp_ID = @Emp_ID and  Row_ID = @Row_ID)
			Begin 
				DELETE FROM T0090_EMP_CHILDRAN_DETAIL WHERE Emp_ID = @Emp_ID and  Row_ID = @Row_ID				
				SET @Result = 'Deleted Successfully#True#'
			END
			else
			BEGIN
				SET @Result = 'Employee does not exists#True#'
			END
			Return
		end

		--------------------Added by ronakk 13062022 -----------

		Else if @Tran_Type = 'G'
		begin
			if Exists(Select 1 FROM T0090_EMP_CHILDRAN_DETAIL WHERE Emp_ID =@Emp_ID and Cmp_ID=@Cmp_ID)
			Begin 
				
				select  Emp_ID,Row_ID,CD.Cmp_ID,Name,Gender,Date_Of_Birth,
				case when isnull(C_Age,0) = 0 then 0.00 else C_Age end as C_age,Relationship,Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height
				,Weight,isnull(OccupationID,0) as OccupationID,HobbyID,HobbyName,DepCompanyName,isnull(Standard_ID,0) as Standard_ID,
				Shcool_College,ExtraActivity,City,CDTM,CmpCity,Std_Specialization,DepWorkTime
				,CRM.Request_id,CRM.Request_type
				from T0090_EMP_CHILDRAN_DETAIL CD
				inner join T0040_Change_Request_Master CRM on CD.Cmp_ID = CRM.Cmp_ID
				where Emp_ID =@Emp_ID and CD.Cmp_ID=@Cmp_ID and CRM.Request_type = 'Dependent'

				SET @Result = 'Successfully#True#'
			END
			else
			BEGIN
			    select * from T0090_EMP_CHILDRAN_DETAIL where Emp_ID =@Emp_ID and Cmp_ID=@Cmp_ID
				
			END
			Return
		end
		Else if @Tran_Type = 'S'
		begin
			if Exists(Select 1 FROM T0090_EMP_CHILDRAN_DETAIL WHERE Emp_ID =@Emp_ID and Cmp_ID=@Cmp_ID and Row_ID=@Row_ID)
			Begin 
			
			select --ECD.*
				 Emp_ID,Row_ID,ECD.Cmp_ID,Name,Gender,Date_Of_Birth,case when isnull(C_Age,0) = 0 then 0.00 else C_Age end as C_age,Relationship
				 ,Is_Resi,Is_Dependant
				 ,isnull(Image_Path,'') Image_Path --Change by ronakk 30072022
				 ,Pan_Card_No
				 ,Adhar_Card_No,Height,Weight,isnull(OccupationID,0) as OccupationID ,HobbyID,HobbyName,DepCompanyName
				 ,isnull(Standard_ID,0) as Standard_ID ,Shcool_College,ExtraActivity,City,CDTM,CmpCity,Std_Specialization,DepWorkTime
				,isnull(OM.Occupation_Name,'') Occupation_Name,isnull(DSM.StandardName,'') StandardName ,CRM.Request_id,CRM.Request_type,DepWorkTime
				from T0090_EMP_CHILDRAN_DETAIL ECD
				inner join T0040_Change_Request_Master CRM on ECD.Cmp_ID = CRM.Cmp_ID
				left join T0040_Occupation_Master OM on OM.O_ID = ECD.OccupationID
				left join T0040_Dep_Standard_Master DSM on DSM.S_ID = ECD.Standard_ID
				 where ECD.Emp_ID =@Emp_ID and ECD.Cmp_ID=@Cmp_ID and ECD.Row_ID=@Row_ID
				 and CRM.Request_type = 'Dependent'

				
				--select * from T0090_EMP_CHILDRAN_DETAIL where Emp_ID =@Emp_ID and Cmp_ID=@Cmp_ID and Row_ID=@Row_ID

				SET @Result = 'Successfully#True#'
			END
			else
			BEGIN
				--select 'Employee Family Details does not exists#True#' as Error
				SET @Result = 'Employee Family Details does not exists#False#'
			END
			Return
		end



		--------------------End by ronakk 13062022 -------------

	RETURN




