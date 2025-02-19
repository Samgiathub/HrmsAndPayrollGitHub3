
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_CHILDRAN_DETAIL]
	 @Row_ID numeric(18,0) output
	,@Emp_ID numeric(18,0)
    ,@Cmp_ID numeric(18,0)
    ,@Name varchar(100)
    ,@Gender char(1)
    ,@Date_Of_Birth datetime
    ,@C_Age numeric(18,1)
    ,@RelationShip varchar(50)
    ,@Is_Resi  numeric(1,0)
    ,@Is_Dependant tinyint --Alpesh 06-Aug-2011
    ,@tran_type char(1)
    ,@Login_Id numeric(18,0)=0 -- Rathod 18/04/2012	
    ,@Image_Path varchar(500) = NULL
    ,@Pan_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Adhar_Card_No Varchar(20) = ''  --Added By Jimit 13022018
	,@Height VARCHAR(10) = NULL -- Added by Darshan 27-Jan-2021
	,@Weight VARCHAR(10) = NULL -- Added by Darshan 27-Jan-2021

	---------------------------------- Added by ronakk 02062022 -------------------------------------
    ,@OccupationID int =0
	,@HobbyID nvarchar(500) = ''
	,@HobbyName nvarchar(1000) = ''
	,@DepCompany nvarchar(200) = ''
	,@StandardID int =0
	,@SchoolCol nvarchar(200) = ''
	,@ExtActivity nvarchar(500) = ''

    ---------------------------------- End by ronakk 02062022 ---------------------------------------
	,@CitySchCol nvarchar(200) = '' -- Added by ronakk 03062022
	,@CmpCity nvarchar(200) = '' -- Added by ronakk 04062022
	,@Specialization nvarchar (200) ='' -- Added by ronakk 20072022
	,@DepWorkTime  nvarchar(200) = '' --Added by ronakk 02082022
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Date_Of_Birth = ''  
  SET @Date_Of_Birth  = NULL
  
  Declare @Age as numeric(18,2)
  set @Age = DateDiff(year,@Date_Of_Birth,getdate())


  Declare @Occupation as nvarchar(200)
  select @Occupation = Occupation_Name from T0040_Occupation_Master where O_ID=@OccupationID and Cmp_ID=@Cmp_ID

  if @Occupation = 'Student'
		 Begin
		    set @DepCompany = ''
			set @CmpCity = ''
			set @DepWorkTime=''
		 End
		 else if @Occupation = 'Employee' or @Occupation = 'Retired' or @Occupation = 'Self-Employee' 
		 Begin
		     set @StandardID = 0
			 set @SchoolCol = ''
			 set @CitySchCol = ''
			 set @ExtActivity = ''
		 End
		 else if @Occupation = '' 
		 Begin
		     set @DepCompany = ''
			 set @CmpCity = ''
			 set @DepWorkTime =''
			 set @StandardID = 0
			 set @SchoolCol = ''
			 set @CitySchCol = ''
			 set @ExtActivity = ''
		 End



  
  
	If @tran_type  = 'I'
		Begin
			If exists(select Row_ID from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And Date_Of_Birth = @Date_Of_Birth And Gender=@Gender)
				BEgin 
					Set @Row_ID = 0
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
				,Is_Dependant --Alpesh 06-Aug-2011
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
				,City --Added by ronakk 03062022
				,CmpCity -- Added by ronakk 04062022
				,Std_Specialization --Added by ronakk 20072022
				,DepWorkTime --Added by ronakk 02082022
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
				 ,@Specialization --Added by ronakk 20072022
				 ,@DepWorkTime --Added by ronakk 02082022
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
				,Std_Specialization --Added by ronakk 20072022
				,DepWorkTime --Added by ronakk 02082022

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
				 ,@Specialization --Added by ronakk 20072022
				 ,@DepWorkTime --Added by ronakk 02082022
				)				
								
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
				,Std_Specialization = @Specialization --Added by ronakk 20072022
				,DepWorkTime = @DepWorkTime --Added by ronakk 02082022

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
				,Std_Specialization --Added by ronakk 20072022
				,DepWorkTime  --Added by ronakk 02082022
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
				 ,@Specialization --Added by ronakk 20072022
				 ,@DepWorkTime --Added by ronakk 02082022
				)		
		   end
	Else if @Tran_Type = 'D'
		begin
			DELETE FROM T0090_EMP_CHILDRAN_DETAIL
			WHERE     (Emp_ID = @Emp_ID) and  Row_ID = @Row_ID				
		end

	RETURN




