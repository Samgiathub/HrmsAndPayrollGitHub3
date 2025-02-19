
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChangeRequestApp] 
	 @Row_id Numeric(18,0),
	 @Cmp_id Numeric(18,0),
	 @Emp_ID Numeric(18,0),
	 @Request_Type_id Numeric(18,0),
	 @Change_Reason Varchar(500),
	 @Request_Date datetime,
	 @Shift_From_Date Varchar(50) = NULL,
	 @Shift_To_Date Varchar(50) = NULL,
	 @Dependant_Name Varchar(500) = NULL,
	 @Dependant_Relationship Varchar(500) = NULL,
	 @Dependant_Gender Varchar(1) = NULL,
	 @Dependant_DOB datetime,
	 @Dependant_Age Numeric(18,2) = 0,
	 @Dependant_Is_Resident Numeric(1,0) = 0,
	 @Dependant_Is_Depended Numeric(1,0) = 0
	 ,@tran_type		char(1)
	 ,@Child_Birth_Date Varchar(50) = null  
	 ,@DepOccupationID int =0
	 ,@DepHobbyID nvarchar(500) = ''
	 ,@DepHobbyName nvarchar(1000) = ''
	 ,@DepCompany nvarchar(200) =''
	 ,@DepCmpCity nvarchar(200) = ''
	 ,@DepStandardId int= 0
	 ,@DepSchCol nvarchar(200) = ''
	 ,@DepSchColCity nvarchar(200) = ''
	 ,@DepExtAct nvarchar(200)=''
	 ,@Image_path VarChar(250) = ''
	 ,@PanCard nvarchar(250)= ''	 
	 ,@AdharCard nvarchar(250)= ''	
	 ,@Height nvarchar(20)  = ''
	 ,@Weight nvarchar(20)  = ''
	 ,@OtherHobby nvarchar(200)  = ''
	 ,@DepSpecialization nvarchar(200) = '' -- aded by prapti 25072022
	 ,@Request_id Numeric(18,0) output
	 ,@Result Varchar(250) output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  if @Dependant_DOB is not null
  Begin
        set @Dependant_Age = DateDiff(year,@Dependant_DOB,getdate())
  end
  else
		set @Dependant_Age =	0.00
	
	IF @Shift_From_Date = ''
		Begin
			Set @Shift_From_Date = NULL
		End
	IF @Shift_To_Date = ''
		Set @Shift_To_Date = NULL

    if @tran_type = 'I'
		Begin	
			If Exists(Select Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID 
			and Request_Type_id = @Request_Type_id and Request_status = 'P' and Curr_Dep_ID = @Row_id
			--AND isnull(Shift_From_Date,'') = isnull(@Shift_From_Date,'') and isnull(Shift_To_Date,'') = isnull(@Shift_To_Date,'')
			--and Dependant_Relationship = @Dependant_Relationship
			)
				begin					
					Select @Request_id = Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID
					and Request_Type_id = @Request_Type_id and Request_status = 'P'
					Set @Request_id = 0
					if @Request_id = 0
					Begin 
						--SET @Result = 'Employee already exists#False#'
						SET @Result = 'Application already exists in pending status#False#'
						
					END
					Return
				end
			Else
			Begin		
					 
					select @Request_id = Isnull(max(Request_id),0) + 1 	From dbo.T0090_Change_Request_Application WITH (NOLOCK)
					
					if @Row_id > 0
					BEGIN	
						Declare @CurrDepID			  as  numeric(18,0) = 0
						Declare @CurrDepName		  as  varchar(100) =  ''
						Declare @CurrDepGender		  as  varchar(100) =  ''
						Declare @CurrDepDOB			  as  varchar(100) =  ''
						Declare @CurrDepCAGE		  as  varchar(100) =  ''
						Declare @CurrDepRelationship  as  varchar(100) =  ''
						Declare @CurrDepISResi		  as  numeric(18,0) = 0
						Declare @CurrDepISDep		  as  numeric(18,0) = 0
						Declare @CurrDepImagePath	  as  varchar(100) =  ''
						Declare @CurrDepPanCard		  as  varchar(100) =  ''
						Declare @CurrDepAdharCard	  as  varchar(100) =  ''
						Declare @CurrDepHeight		  as  varchar(100) =  ''
						Declare @CurrDepWeight		  as  varchar(100) =  ''
						Declare @CurrDepOccupationID	  as  numeric(18,0) = 0
						Declare @CurrDepOccupationName as  varchar(100) =  ''
						Declare @CurrDepHobbyID		  as  varchar(100) =  ''
						Declare @CurrDepHobbyName	  as  varchar(100) =  ''
						Declare @CurrDepCompanyName	  as  varchar(100) =  ''
						Declare @CurrDepCompanyCity	  as  varchar(100) =  ''
						Declare @CurrDepStandardID	  as  numeric(18,0) = 0
						Declare @CurrDepStandardName	  as  varchar(100) =  ''
						Declare @CurrDepSchCol		  as  varchar(100) =  ''
						Declare @CurrDepSchColCity	  as  varchar(100) =  ''
						Declare @CurrDepExtraActivity  as  varchar(100) =  ''
						Declare @CurDepSpecialization  as  varchar(100) =  ''

						SELECT @CurrDepID = Row_ID,@CurrDepName=NAME,@CurrDepGender=GENDER,@CurrDepDOB=DATE_OF_BIRTH,@CurrDepCAGE=C_AGE,@CurrDepRelationship=RELATIONSHIP
						,@CurrDepISResi=IS_RESI,@CurrDepISDep=IS_DEPENDANT,@CurrDepImagePath=IMAGE_PATH,@CurrDepPanCard=PAN_CARD_NO,@CurrDepAdharCard =ADHAR_CARD_NO
						,@CurrDepHeight= HEIGHT
						,@CurrDepWeight= WEIGHT,@CurrDepOccupationID=OCCUPATIONID,@CurrDepOccupationName =QM.Occupation_Name,@CurrDepHobbyID=HOBBYID
						,@CurrDepHobbyName=HOBBYNAME
						,@CurrDepCompanyName=DEPCOMPANYNAME,@CurrDepStandardID = STANDARD_ID,@CurrDepStandardName=Isnull(SM.StandardName,'') 
						,@CurrDepSchCol=SHCOOL_COLLEGE,@CurrDepExtraActivity=EXTRAACTIVITY
						,@CurrDepCompanyCity=CMPCITY,@CurDepSpecialization = Std_Specialization  -- aded by prapti 25072022
						FROM T0090_EMP_CHILDRAN_DETAIL D
						left join   T0040_Occupation_Master QM on d.OccupationID = qm.O_ID
						left join   T0040_Dep_Standard_Master SM on D.Standard_ID = SM.S_ID
						WHERE ROW_ID = @Row_id
					END
					
					insert into T0090_Change_Request_Application  
					(
					 Request_id,
					 Cmp_id,
					 Emp_ID,
					 Request_Type_id,
					 Change_Reason,
					 Request_Date,
					 Shift_From_Date,
					 Shift_To_Date,
					 Dependant_Name,
					 Dependant_Relationship,
					 Dependant_Gender,
					 Dependant_DOB,
					 Dependant_Age,
					 Dependant_Is_Resident,
					 Dependant_Is_Dependant,
					 Child_Birth_Date
					 ,Dep_OccupationID
					 ,Dep_HobbyID
					 ,Dep_HobbyName
					 ,Dep_DepCompanyName
					 ,Dep_CmpCity
					 ,Dep_Standard_ID
					 ,Dep_Shcool_College
					 ,Dep_SchCity
					 ,Dep_ExtraActivity
					 ,Dep_PancardNo
					 ,Dep_AdharcardNo
					 ,Dep_Height
					 ,Dep_Weight
					 ,OtherHobby
					 ,Request_Status,
					 Image_path,
					 Curr_Dep_ID,
					 Curr_Dep_Name
					 ,Curr_Dep_Gender
					 ,Curr_Dep_DOB
					 ,Curr_Dep_CAGE
					 ,Curr_Dep_Relationship
					 ,Curr_Dep_ISResi
					 ,Curr_Dep_ISDep
					 ,Curr_Dep_ImagePath
					 ,Curr_Dep_PanCard
					 ,Curr_Dep_AdharCard
					 ,Curr_Dep_Height
					 ,Curr_Dep_Weight
					 ,Curr_Dep_OccupationID
					 ,Curr_Dep_OccupationName
					 ,Curr_Dep_HobbyID
					 ,Curr_Dep_HobbyName
					 ,Curr_Dep_CompanyName
					 ,Curr_Dep_CompanyCity
					 ,Curr_Dep_StandardID
					 ,Curr_Dep_StandardName
					 ,Curr_Dep_SchCol
					 ,Curr_Dep_SchColCity
					 ,Curr_Dep_ExtraActivity
					 ,Dep_Std_Specialization -- aded by prapti 25072022
					 ,Curr_Dep_Std_Specialization --aded by prapti 25072022
					 ) 
					 VALUES
					 (@Request_id,
					 @Cmp_id,
					 @Emp_ID,
					 @Request_Type_id,
					 @Change_Reason,
					 @Request_Date,
					 @Shift_From_Date,
					 @Shift_To_Date,
	                 @Dependant_Name,
					 @Dependant_Relationship,
					 @Dependant_Gender,
					 @Dependant_DOB,
					 @Dependant_Age,
					 @Dependant_Is_Resident,
					 @Dependant_Is_Depended,
					 @Child_Birth_Date
					 ,@DepOccupationID
					 ,@DepHobbyID
					 ,@DepHobbyName
					 ,@DepCompany
					 ,@DepCmpCity
					 ,@DepStandardId
					 ,@DepSchCol
					 ,@DepSchColCity
					 ,@DepExtAct,
					 @PanCard
					 ,@AdharCard,
					 @Height,
					 @Weight,
					 @OtherHobby,
					 'P',
					 @Image_path,
					 @CurrDepID,
					 @CurrDepName		  
					,@CurrDepGender		  
					,@CurrDepDOB			  
					,@CurrDepCAGE		  
					,@CurrDepRelationship  
					,@CurrDepISResi		  
					,@CurrDepISDep		  
					,@CurrDepImagePath	  
					,@CurrDepPanCard		  
					,@CurrDepAdharCard	  
					,@CurrDepHeight		  
					,@CurrDepWeight		  
					,@CurrDepOccupationID	
					,@CurrDepOccupationName
					,@CurrDepHobbyID		  
					,@CurrDepHobbyName	  
					,@CurrDepCompanyName	  
					,@CurrDepCompanyCity	  
					,@CurrDepStandardID	  
					,@CurrDepStandardName	
					,@CurrDepSchCol		  
					,@CurrDepSchColCity	  
					,@CurrDepExtraActivity 
					,@DepSpecialization -- aded by prapti 25072022
					,@CurDepSpecialization -- aded by prapti 25072022
					 )

					if @Request_id > 0
					Begin 
						SET @Result = 'Inserted Successfully#True#'+cast(@Request_id as varchar)+''
						
					END
					RETURN 
			 End
		End
	Else if @Tran_Type = 'U'
		begin
		
				Update T0090_Change_Request_Application
				set  Change_Reason = @Change_Reason,
					 Request_Type_id = @Request_Type_id,
					 Shift_From_Date = @Shift_From_Date,
					 Shift_To_Date = @Shift_To_Date,
					 Dependant_Name = @Dependant_Name,
					 Dependant_Relationship = @Dependant_Relationship,
					 Dependant_Gender = @Dependant_Gender,
					 Dependant_DOB = @Dependant_DOB,
					 Dependant_Age = @Dependant_Age,
					 Dependant_Is_Resident = @Dependant_Is_Resident,
					 Dependant_Is_Dependant = @Dependant_Is_Depended,
					 Child_Birth_Date = @Child_Birth_Date
					 ,Dep_OccupationID= @DepOccupationID
					 ,Dep_HobbyID = @DepHobbyID
					 ,Dep_HobbyName = @DepHobbyName
					 ,Dep_DepCompanyName = @DepCompany
					 ,Dep_CmpCity = @DepCmpCity
					 ,Dep_Standard_ID = @DepStandardId
					 ,Dep_Shcool_College = @DepSchCol
					 ,Dep_SchCity = @DepSchColCity
					 ,Dep_ExtraActivity =  @DepExtAct
					 ,Dep_PancardNo = @PanCard
					 ,Dep_AdharcardNo = @AdharCard
					 ,Dep_Height = @Height
					 ,Dep_Weight=@Weight
					 ,Image_path=@Image_path
					 ,OtherHobby = @OtherHobby
					 ,Dep_Std_Specialization = @DepSpecialization
				where Request_id= @Row_id and Cmp_id = @Cmp_id and Emp_ID = @Emp_ID
				
				if @Row_id > 0
				Begin 
					SET @Result = 'Updated Successfully#True#'
				END
				RETURN 
				
		end
	Else if @Tran_Type = 'D'
		begin
			
			Delete From T0090_Change_Request_Application Where Request_id= @Row_id and Cmp_id = @Cmp_id  and Emp_ID = @Emp_ID
			--Delete From T0100_Monthly_Loan_Skip_Application Where Request_id= @Request_id and Cmp_id = @Cmp_id  and Emp_ID = @Emp_ID
			if @Row_id > 0
			Begin 
				SET @Result = 'Deleted Successfully#True#'
			END
			RETURN 
		end
	
	
END

