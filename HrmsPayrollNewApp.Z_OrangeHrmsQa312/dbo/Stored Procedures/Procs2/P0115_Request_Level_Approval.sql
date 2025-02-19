


CREATE PROCEDURE [dbo].[P0115_Request_Level_Approval]
	 @Tran_id				Numeric output
	,@Request_id			Numeric 
	,@Cmp_id				Numeric
	,@Emp_ID			    Numeric
	,@Request_Type_id		Numeric
	,@Change_Reason			Varchar(500)
	,@Request_Apr_Date		Datetime
	,@Shift_From_Date		Datetime
	,@Shift_To_Date		    Datetime
	,@Curr_Details			varchar(500)
	,@New_Details			varchar(500)
	,@Curr_Tehsil			varchar(100)
	,@Curr_District			varchar(100)
	,@Curr_Thana			varchar(100)
	,@Curr_City_Village		varchar(100)
	,@Curr_State			varchar(100)
	,@Curr_Pincode		    Numeric(18,0)
	,@New_Tehsil			varchar(100)
	,@New_District			varchar(100)
	,@New_Thana				varchar(100)
	,@New_City_Village		varchar(100)
	,@New_State				Varchar(100)
	,@New_Pincode			Numeric(18,0)
	,@Request_Apr_status	Varchar(1)
	,@Request_Apr_Remarks	Varchar(100)
	,@Request_Level			Numeric(18,0)
	,@S_Emp_Id				Numeric(18,0)
	,@Effective_Date        Datetime
	,@Qu_Type Numeric(6,0)
	,@Qu_Specialization  Varchar(500)
	,@Qu_Passing_year Numeric(6,0)
	,@Qu_Passing_Score Varchar(100)
	,@Qu_Start_Date datetime
	,@Qu_End_Date datetime
	,@Dependant_Name Varchar(500)
	,@Dependant_Relationship Varchar(500)
	,@Dependant_Gender Varchar(1)
	,@Dependant_DOB datetime
	,@Dependant_Age Numeric(18,1)
	,@Dependant_Is_Resident Numeric(1,0)
	,@Dependant_Is_Depended Numeric(1,0)
	,@Pass_Visa_Citizenship Numeric(18,0)
	,@Pass_Visa_No Varchar(100)
	,@Pass_Visa_Issue_Date datetime
	,@Pass_Visa_Exp_Date  datetime
	,@Pass_Visa_Review_Date datetime
	,@Pass_Visa_Status  Varchar(100)
	,@License_ID Numeric(18,0)
	,@License_Type VarChar(100)
	,@License_IssueDate DateTime
	,@License_No VarChar(100)
	,@License_ExpDate DateTime
	,@License_Is_Expired  Numeric(1,0)
	,@Image_Path Varchar(1000)
	,@tran_type				varchar(1)
	,@Curr_IFSC_Code VarChar(200)
	,@Curr_Account_No VarChar(200)
    ,@Curr_Branch_Name VarChar(200)
    ,@New_IFSC_Code VarChar(200)
    ,@New_Account_No VarChar(200)
    ,@New_Branch_Name VarChar(200)
	,@Nominees_Address VarChar(500) --Added by nilesh Patel on 23042016
	,@Nominees_Share Numeric(18,2) --Added by nilesh Patel on 23042016
	,@Nominees_For Numeric(18,2) --Added by nilesh Patel on 23042016
	,@Nominees_Row_ID VarChar(500) --Added by nilesh Patel on 23042016
	,@Hospital_Name VarChar(500) --Added by nilesh Patel on 23042016
	,@Hospital_Address VarChar(500) --Added by nilesh Patel on 23042016
	,@Admit_Date DateTime --Added by nilesh Patel on 23042016
	,@MediCalim_Approval_Amount Numeric(18,2) --Added by nilesh Patel on 23042016
	,@Old_Pan_No Varchar(200) --Added by nilesh patel on 02082016
	,@New_Pan_No Varchar(200) --Added by nilesh patel on 02082016
	,@Old_Adhar_No Varchar(200) --Added by nilesh patel on 02082016
	,@New_Adhar_No Varchar(200) --Added by nilesh patel on 02082016
	,@Loan_Installment_Month Numeric(2,0) = 0 --Added by nilesh patel on 02082016
	,@Loan_Installment_Year  Numeric(4,0) = 0 --Added by nilesh patel on 02082016
	,@New_Loan_Install_Amt Varchar(Max) = '' --Added by nilesh patel on 30082016
	,@Child_Birth_Date datetime = NULL  --Added by Jaina 27-04-2018


	
		 -----------------------Added by ronakk 22062022 -----------------------------------

	  ,@DepOccupationID int =0
	  ,@DepHobbyID nvarchar(500) = ''
	  ,@DepHobbyName nvarchar(1000) = ''
	  ,@DepCompany nvarchar(200) =''
	  ,@DepCmpCity nvarchar(200) = ''
	  ,@DepStandardId int=0
	  ,@DepSchCol nvarchar(200) = ''
	  ,@DepSchColCity nvarchar(200) = ''
	  ,@DepExtAct nvarchar(200)=''

	 -------------------------End by ronakk 22062022 -----------------------------------


	   ------------------------Added by ronakk 22062022 ----------------------
	 ,@EmpFavSportID Nvarchar(500) = ''
	 ,@EmpFavSportName Nvarchar(1000) = ''
	 ,@EmpHobbyID Nvarchar(500) = ''
	 ,@EmpHobbyName Nvarchar(1000) = ''
	 ,@EmpFavFood Nvarchar(100) = ''
	 ,@EmpFavRestro Nvarchar(100) = ''
	 ,@EmpFavTrvDestination Nvarchar(100) = ''
	 ,@EmpFavFestival Nvarchar(100) = ''
	 ,@EmpFavSportPerson Nvarchar(100) = ''
	 ,@EmpFavSinger Nvarchar(100) = ''
    ----------------------------------End by ronakk 22062022 ---------------------


	 ------------------------Added by ronakk 24062022 ----------------------
	 ,@CurrEmpFavSportID Nvarchar(500) = ''
	 ,@CurrEmpFavSportName Nvarchar(1000) = ''
	 ,@CurrEmpHobbyID Nvarchar(500) = ''
	 ,@CurrEmpHobbyName Nvarchar(1000) = ''
	 ,@CurrEmpFavFood Nvarchar(100) = ''
	 ,@CurrEmpFavRestro Nvarchar(100) = ''
	 ,@CurrEmpFavTrvDestination Nvarchar(100) = ''
	 ,@CurrEmpFavFestival Nvarchar(100) = ''
	 ,@CurrEmpFavSportPerson Nvarchar(100) = ''
	 ,@CurrEmpFavSinger Nvarchar(100) = ''
    ----------------------------------End by ronakk 24062022 ---------------------

	--------------------------------------Added by ronakk 27062022 -----------------------
	 ,@DepOtherHobby nvarchar(1000)=''
	 ,@DepPancard nvarchar(50)=''
	 ,@DepAdharCard nvarchar(50)=''
	 ,@DepHeight nvarchar(20)=''
	 ,@DepWeight nvarchar(20)=''

	 ,@otherFavHobyy nvarchar(1000) = ''
	 ,@otherFavSport nvarchar(1000) = '' 

	--------------------------------------End by ronakk 27062022  -----------------------


	---------------------------------------------Added by ronakk 06072022----------------------------------

	,@CurDepID int
	,@CurDepName nvarchar(100)
	,@CurDepGender nvarchar(1) 
	,@CurDepDOB nvarchar(20)
	,@CurDepCAGE numeric(18,2)
	,@CurDepRelationship nvarchar(100)
	,@CurDepISResi int
	,@CurDepISDep int
	,@CurDepImagePath nvarchar(1000) 
	,@CurDepPanCard nvarchar(20)
	,@CurDepAdharCard nvarchar(20)
	,@CurDepHeight nvarchar(10)
	,@CurDepWeight nvarchar(10)
	,@CurDepOccupationID int
	,@CurDepOccupationName nvarchar(100)
	,@CurDepHobbyID nvarchar(500)
	,@CurDepHobbyName nvarchar(1000)
	,@CurDepCompanyName nvarchar(100)
	,@CurDepCompanyCity nvarchar(100)
	,@CurDepStandardID int
	,@CurDepStandardName nvarchar(100)
	,@CurDepSchCol nvarchar(100)
	,@CurDepSchColCity nvarchar(100)
	,@CurDepExtraActivity nvarchar(100)


	------------------------------------------------End  by ronakk 06072022 -------------------------------

	
	,@DepSpecialization nvarchar(200)	   --Added by ronakk 21072022
	,@CurDepSpecialization nvarchar(200)   --Added by ronakk 21072022




AS
BEGIN
	SET NOCOUNT ON;
	
	
	IF @Shift_From_Date = '1900-01-01 00:00:00.000'
		Begin
			Set @Shift_From_Date = NULL
		End
	IF @Shift_To_Date = '1900-01-01 00:00:00.000'
		Set @Shift_To_Date = NULL
	
	IF @Curr_Tehsil = ''
		Set @Curr_Tehsil = NULL
		
	IF @Curr_District = ''
		Set @Curr_District = NULL
		
	IF @Curr_Thana = ''
		Set @Curr_Thana = NULL
		
	IF @Curr_City_Village = ''
		Set @Curr_City_Village = NULL
		
	IF @Curr_State = ''
		Set @Curr_State = NULL
		
	IF @Curr_Pincode = 0
		Set @Curr_Pincode = NULL
		
	IF @New_Tehsil = ''
		Set @New_Tehsil = NULL
	
	IF @New_District = ''
		Set @New_District = NULL
	
	IF @New_Thana = ''
		Set @New_Thana = NULL	
		
	IF @New_City_Village = ''
		Set @New_City_Village = NULL
	
	IF @New_State = ''
		Set @New_State = NULL
		
	IF @New_Pincode = 0
		Set @New_State = NULL
	
	If @Qu_Start_Date = '01/01/1900'
		Set @Qu_Start_Date = NULL
		
	If @Qu_End_Date = '01/01/1900'
		Set @Qu_End_Date = NULL
	
	if @Dependant_DOB = '01/01/1900'
		Set @Dependant_DOB = NULL
	
	if @Pass_Visa_Issue_Date = '01/01/1900'
		Set @Pass_Visa_Issue_Date = NULL
		
	if @Pass_Visa_Exp_Date = '01/01/1900'
		Set @Pass_Visa_Exp_Date = NULL
		
	if @Pass_Visa_Review_Date = '01/01/1900'
		Set @Pass_Visa_Review_Date = NULL
		
	if @License_IssueDate = '01/01/1900'
		Set @License_IssueDate = NULL
		
	if @License_ExpDate = '01/01/1900'
		Set @License_ExpDate = NULL
	
	IF @Child_Birth_DAte = '01/01/1900'  --Added by Jaina 27-04-2018
		set @Child_Birth_Date = NULL
		
	--if @Nominees_Row_ID = 'Self'
	--	Set @Nominees_Row_ID = '0'
		DECLARE @MONTH NUMERIC(18,0)
		DECLARE @YEAR NUMERIC(18,0)
		DECLARE @YEAR_ST_DATE DATETIME
		DECLARE @YEAR_END_DATE DATETIME		
		Declare @App_Count numeric(18,0) = 0
		DECLARE @Appr_Count numeric(18,0) = 0
		Declare @Count numeric(18,0) = 0  --Added by Jaina 11-05-2018
		Declare @Max_Limit numeric(18,0) --Added by Jaina 11-05-2018
		declare @Message varchar(200)
		
		
		
			-------------------------Added by ronakk 27062022 -------------------
		Declare @OtherHobby nvarchar(1000) =''
		if @Request_Type_id =8 
		begin
		    set @OtherHobby = @DepOtherHobby
		end
		else if  @Request_Type_id =23
		Begin
		       set @OtherHobby = @otherFavHobyy
		End

		-------------------------------End by ronakk 27062022 ---------------

		Declare @Cur_Dep_DOB datetime

		if @CurDepDOB <> ''
		Begin
		 set @Cur_Dep_DOB =CONVERT(Datetime, @CurDepDOB, 103)
		End
		Else
		Begin
		     set @Cur_Dep_DOB =null
		End

	
	If Upper(@tran_type) = 'I'
		Begin
			
			if @Request_Type_id = 20
			BEGIN
				--select @Max_Limit = Max_Limit from T0040_Change_Request_Master where Cmp_ID=@Cmp_Id and Request_type='Child Birth Limit (For Paternity Leave)'
				select @Max_Limit = Max_Leave_Lifetime FROM T0040_LEAVE_MASTER WHERE CMP_ID = @CMP_ID and Leave_Type='Paternity Leave'  --Added by Jaina 14-03-2019
					
			
				select @App_Count = COUNT(1) FROM T0090_Change_Request_Application where Cmp_id=@Cmp_Id and Emp_ID=@Emp_id and Request_Type_id = 20 and Request_status='P' and Request_id <> @Request_id
				SELECT @Appr_Count = COUNT(1) FROM T0090_Change_Request_Approval where Cmp_id=@Cmp_Id AND Emp_ID=@Emp_id AND Request_Type_id=20 and Request_status = 'A'
				
				--select @App_Count,@Appr_Count
				set @Count = isnull(@App_Count,0) + ISNULL(@Appr_Count,0)
				
				if @CHILD_BIRTH_DATE > getdate()
				begin
					set @Message = '@@Can''t Allow Future Child Birth Date @@'
					RAISERROR(@Message,16,2)
					RETURN
				end
				
				--select @Count,@Max_Limit
				IF @Max_Limit <= @Count And @Max_Limit <> 0
				BEGIN
					set @Message = '@@Maximum limit is over for Paternity leave Request@@'
					RAISERROR(@Message,16,2)
					RETURN
				end	
				
					SET @MONTH = MONTH(@CHILD_BIRTH_DATE)
					SET @YEAR = YEAR(@CHILD_BIRTH_DATE)
					
					SET @YEAR_END_DATE = DBO.GET_MONTH_END_DATE(@MONTH,@YEAR)
					SET @YEAR_ST_DATE = DATEADD(yyyy,-1,@YEAR_END_DATE)									
								
					IF EXISTS (SELECT 1 FROM T0090_CHANGE_REQUEST_APPLICATION WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID AND Request_status='P'
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE AND Request_id <> @Request_id)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year @@',16,2)
						RETURN
					END
					
					IF EXISTS (SELECT 1 FROM T0090_Change_Request_Approval WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID 
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE AND Request_id <> @Request_id)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year @@',16,2)
						RETURN
					END
			END
		    
		    SELECT @Cmp_ID = Cmp_ID From T0090_Change_Request_Application Where  Request_id = @Request_id  and Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id
		    
			IF Exists(Select 1 From T0115_Request_Level_Approval Where Emp_ID=@Emp_ID and Request_id = @Request_id And S_Emp_Id = @S_Emp_Id And Rpt_Level = @Request_Level)
				Begin
					Set @Tran_ID = 0
					Return
				End
			
			Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0115_Request_Level_Approval
			
			Insert Into T0115_Request_Level_Approval
					(
						 Tran_id,
						 Request_id,
						 Cmp_id,
						 Emp_ID,
						 Effective_Date,
						 Request_Type_id, 
						 Request_Apr_Date,
						 Change_Reason,
						 Shift_From_Date,
						 Shift_To_Date,
						 Curr_Details,
						 New_Details,
						 Curr_Tehsil,
						 Curr_District,
						 Curr_Thana,
						 Curr_City_Village,
						 Curr_State,
						 Curr_Pincode,
						 New_Tehsil,
						 New_District,
						 New_Thana,
						 New_City_Village,
						 New_State,
						 New_Pincode,
						 Request_Apr_Remarks,
						 Rpt_Level,
						 Request_Apr_Status,
						 S_Emp_ID,
						 Quaulification_ID,
						 Specialization,
						 Passing_Year,
						 Score,
						 Quaulification_Star_Date,
						 Quaulification_End_Date,
						 Dependant_Name,
						 Dependant_Relationship,
						 Dependant_Gender,
						 Dependant_DOB,
						 Dependant_Age,
						 Dependant_Is_Resident,
						 Dependant_Is_Dependant,
						 Pass_Visa_Citizenship,
						 Pass_Visa_No,
					     Pass_Visa_Issue_Date,
						 Pass_Visa_Exp_Date,
						 Pass_Visa_Review_Date,
						 Pass_Visa_Status,
						 License_ID,
						 License_Type,
						 License_IssueDate,
						 License_No,
						 License_ExpDate,
						 License_Is_Expired,
						 Image_path,
						 Curr_IFSC_Code,
						 Curr_Account_No,
						 Curr_Branch_Name,
						 New_IFSC_Code,
						 New_Account_No,
						 New_Branch_Name,
						 Nominess_Address,
						 Nominess_Share,
						 Nominess_For,
						 Nominees_Row_ID,
						 Hospital_Name,
						 Hospital_Address,
						 Admit_Date,
						 MediCalim_Approval_Amount,
						 Old_Pan_No,
						 New_Pan_No,
						 Old_Adhar_No,
						 New_Adhar_No,
						 Loan_Month,
						 Loan_Year,
						 Loan_Skip_Details,
						 Child_Birth_Date


						 
						---------------------------------------- Added by ronakk 22062022 ----------------------------
						,Dep_OccupationID
						,Dep_HobbyID
						,Dep_HobbyName
						,Dep_DepCompanyName
						,Dep_CmpCity
						,Dep_Standard_ID
						,Dep_Shcool_College
						,Dep_SchCity
						,Dep_ExtraActivity
						-------------------------------------------End by ronakk 22062022 ----------------------------


						  ---------------------------------------- Added by ronakk 22062022 ----------------------------
					  ,Emp_Fav_Sport_id 
					  ,Emp_Fav_Sport_Name 
					  ,Emp_Hobby_id 
					  ,Emp_Hobby_Name 
					  ,Emp_Fav_Food  
				      ,Emp_Fav_Restro 
					  ,Emp_Fav_Trv_Destination 
					  ,Emp_Fav_Festival 
					  ,Emp_Fav_SportPerson 
					  ,Emp_Fav_Singer
					   -------------------------------------------End by ronakk 22062022 ----------------------------


					   
					   ---------------------------------------- Added by ronakk 24062022 ----------------------------
					  ,Curr_Emp_Fav_Sport_id 
					  ,Curr_Emp_Fav_Sport_Name 
					  ,Curr_Emp_Hobby_id 
					  ,Curr_Emp_Hobby_Name 
					  ,Curr_Emp_Fav_Food  
				      ,Curr_Emp_Fav_Restro 
					  ,Curr_Emp_Fav_Trv_Destination 
					  ,Curr_Emp_Fav_Festival 
					  ,Curr_Emp_Fav_SportPerson 
					  ,Curr_Emp_Fav_Singer
					   -------------------------------------------End by ronakk 24062022 ----------------------------

					     -----------------------------------------Added by ronakk 27062022 ---------------------------
					   ,OtherHobby
					   ,Dep_PancardNo
					   ,Dep_AdharcardNo
					   ,Dep_Height
					   ,Dep_Weight
					   ,OtherSports
					   -------------------------------------------End by ronakk 27062022 ---------------------------

					      ----------------------------------------Added by ronakk 06072022 --------------------------
					   ,Curr_Dep_ID 
					   ,Curr_Dep_Name 
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
					   ------------------------------------------End  by ronakk 06072022 -------------------------
					    ,Dep_Std_Specialization 		--Added by ronakk 21072022
					   ,Curr_Dep_Std_Specialization --Added by ronakk 21072022

					)
			Values
					(        
							 @Tran_id
							,@Request_id
							,@Cmp_id
							,@Emp_ID
							,@Effective_Date
							,@Request_Type_id
							,@Request_Apr_Date
							,@Change_Reason
							,@Shift_From_Date
							,@Shift_To_Date
							,@Curr_Details
							,@New_Details
							,@Curr_Tehsil
							,@Curr_District
							,@Curr_Thana
							,@Curr_City_Village
							,@Curr_State
							,@Curr_Pincode
							,@New_Tehsil
							,@New_District
							,@New_Thana
							,@New_City_Village
							,@New_State
							,@New_Pincode
							,@Request_Apr_Remarks
							,@Request_Level
							,@Request_Apr_status
							,@S_Emp_Id
							,@Qu_Type
							,@Qu_Specialization
							,@Qu_Passing_year
							,@Qu_Passing_Score
							,@Qu_Start_Date
							,@Qu_End_Date
							,@Dependant_Name
							,@Dependant_Relationship
							,@Dependant_Gender
							,@Dependant_DOB
							,@Dependant_Age
							,@Dependant_Is_Resident
							,@Dependant_Is_Depended
							,@Pass_Visa_Citizenship
							,@Pass_Visa_No
							,@Pass_Visa_Issue_Date
							,@Pass_Visa_Exp_Date
							,@Pass_Visa_Review_Date
							,@Pass_Visa_Status
							,@License_ID
							,@License_Type
							,@License_IssueDate
							,@License_No
							,@License_ExpDate
							,@License_Is_Expired
							,@Image_Path
							,@Curr_IFSC_Code
							,@Curr_Account_No
							,@Curr_Branch_Name
							,@New_IFSC_Code
							,@New_Account_No
							,@New_Branch_Name
							,@Nominees_Address
							,@Nominees_Share
							,@Nominees_For
							,@Nominees_Row_ID
							,@Hospital_Name
							,@Hospital_Address
							,@Admit_Date
							,@MediCalim_Approval_Amount
							,@Old_Pan_No
							,@New_Pan_No
							,@Old_Adhar_No
							,@New_Adhar_No
							,@Loan_Installment_Month
							,@Loan_Installment_Year
							,@New_Loan_Install_Amt
							,@Child_Birth_date


							
						     -----------------------------------------Added by ronakk 22062022 ------------------------------

							 ,@DepOccupationID
							 ,@DepHobbyID
							 ,@DepHobbyName
							 ,@DepCompany
							 ,@DepCmpCity
							 ,@DepStandardId
							 ,@DepSchCol
							 ,@DepSchColCity
							 ,@DepExtAct
							 ----------------------------------------------End by ronakk 22062022 ---------------------------

					 -----------------------------------------Added by ronakk 22062022 ------------------------------
					  ,@EmpFavSportID 
					  ,@EmpFavSportName
					  ,@EmpHobbyID 
					  ,@EmpHobbyName
					  ,@EmpFavFood 
					  ,@EmpFavRestro
					  ,@EmpFavTrvDestination
		              ,@EmpFavFestival
					  ,@EmpFavSportPerson
					  ,@EmpFavSinger

					  -----------------------------------------End by ronakk 22062022 ------------------------------

					    -----------------------------------------Added by ronakk 24062022 ------------------------------
					   ,@CurrEmpFavSportID 
					   ,@CurrEmpFavSportName
					   ,@CurrEmpHobbyID 
					   ,@CurrEmpHobbyName
					   ,@CurrEmpFavFood 
					   ,@CurrEmpFavRestro
					   ,@CurrEmpFavTrvDestination
					   ,@CurrEmpFavFestival
					   ,@CurrEmpFavSportPerson
					   ,@CurrEmpFavSinger
					  
					   -----------------------------------------End by ronakk 24062022 ------------------------------

					    --------------------------------Add by ronakk 27062022--------------------------------
					   ,@OtherHobby
					   ,@DepPancard
					   ,@DepAdharCard
					   ,@DepHeight
					   ,@DepWeight
					   ,@otherFavSport
					   -----------------------------------End by ronakk 27062022 ----------------------------

					     ---------------------------------------------Added by ronakk 06072022 -------------------------------
					   ,@CurDepID 
					   ,@CurDepName
					   ,@CurDepGender 
					   ,@Cur_Dep_DOB 
					   ,@CurDepCAGE 
					   ,@CurDepRelationship 
					   ,@CurDepISResi 
					   ,@CurDepISDep 
					   ,@CurDepImagePath 
					   ,@CurDepPanCard
					   ,@CurDepAdharCard
					   ,@CurDepHeight 
					   ,@CurDepWeight 
					   ,@CurDepOccupationID 
					   ,@CurDepOccupationName
					   ,@CurDepHobbyID 
					   ,@CurDepHobbyName 
					   ,@CurDepCompanyName 
					   ,@CurDepCompanyCity 
					   ,@CurDepStandardID 
					   ,@CurDepStandardName 
					   ,@CurDepSchCol 
					   ,@CurDepSchColCity 
					   ,@CurDepExtraActivity
					   
					   --------------------------------------------------End by ronakk 06072022 ----------------------------
					    ,@DepSpecialization	   --Added by ronakk 21072022
					   ,@CurDepSpecialization  --Added by ronakk 21072022

					)
			
			Declare @Loan_Apr_Id Numeric(18,0)
			Declare @Loan_New_Install_Amt Numeric(18,2)
							
			Set @Loan_Apr_Id = 0
			Set @Loan_New_Install_Amt = 0
							
			Declare @Loan_ID Numeric(18,0)
			Declare @Loan_Install_Amt Numeric(18,0)
			
			if @New_Loan_Install_Amt <> ''
				Begin
					Declare Cur_Loan Cursor For
					Select LEFT(Data,CHARINDEX(',',data)-1),RIGHT(Data,LEN(data)-CHARINDEX(',',data)) From dbo.Split(@New_Loan_Install_Amt,'#')
					Open Cur_Loan 
					fetch next from Cur_Loan into @Loan_Apr_Id,@Loan_New_Install_Amt
						While @@fetch_status = 0
							Begin
								Select @Loan_ID = isnull(Loan_ID,0),@Loan_Install_Amt = isnull(Loan_Apr_Installment_Amount,0) From T0120_LOAN_APPROVAL where Loan_Apr_ID = @Loan_Apr_Id
								Exec P0100_Monthly_Loan_Skip_Approval @Tran_ID = 0,@Request_Apr_ID = 0,@Request_id = @Request_id,@Cmp_ID = @Cmp_id,@Emp_ID = @Emp_ID,@Loan_Apr_ID = @Loan_Apr_Id,@Loan_ID = @Loan_ID,@Old_Install_Amount = @Loan_Install_Amt,@New_Install_Amount = @Loan_New_Install_Amt,@Rpt_Level = @Request_Level,@S_Emp_Id = @S_Emp_Id,@Final_Approval = 0
								fetch next from Cur_Loan into @Loan_Apr_Id,@Loan_New_Install_Amt
							End
					Close Cur_Loan
					deallocate Cur_Loan
				End	
		End
	Else If Upper(@tran_type) = 'D'
		BEGIN
			
			Declare @Increment_ID Numeric(18,0)
			Declare @Increment_ID_old Numeric(18,0)
			
			
			If not exists(Select Request_id From T0090_Change_Request_Approval where  Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id AND (Request_status = 'A' OR Request_status = 'R'))
				BEGIN
					Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
					if @Request_Type_id = 17
						Begin
							Delete From T0100_Monthly_Loan_Skip_Approval where Request_ID = @Request_id and Emp_ID = @Emp_ID and S_Emp_Id = @S_Emp_Id	
						End		
				End	
				
			
			If exists (Select Request_id From T0090_Change_Request_Approval where  Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id AND (Request_status = 'A' OR Request_status = 'R')) 
				Begin
					
					
					if @Request_Type_id = 1 -- For Birthday Change Request 
					Begin
							
						    UPDATE EM
							SET EM.Date_Of_Birth = (Case When CRA.Curr_Details = '' THEN NULL ELSE CONVERT(datetime,CRA.Curr_Details,103) End)
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
							
					End
					if @Request_Type_id = 3 -- For Change Shift 
						Begin
							
							Declare @Old_Shift_From_Date Datetime
							Declare @Old_Shift_To_Date Datetime
							Declare @Shift_Tran_ID Numeric
							Declare @old_New_Details Numeric
							
							Select 
							@Old_Shift_From_Date = CRA.Shift_From_Date,
							@Old_Shift_To_Date = CRA.Shift_To_Date,
							@old_New_Details = CRA.New_Details
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							
							If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID And 
								@Old_Shift_From_Date >= Month_St_Date and @Old_Shift_To_Date <= ISNULL(Cutoff_Date,Month_End_Date))
								Begin
									 --Raiserror('@@This Months Salary Exists.So You Cant Delete This Record.@@',16,2)
									 Set @Tran_id = 0
									 Return @Tran_id
								End
							Else
								Begin
									Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
									Delete From T0100_EMP_SHIFT_DETAIL Where Emp_ID = @Emp_ID and Cmp_ID = @cmp_id and Shift_ID = @old_New_Details and For_Date >= @Old_Shift_From_Date and For_Date <= @Old_Shift_To_Date
								End
						End
					if @Request_Type_id = 4 -- For Maritals Status Request 
					Begin
						    UPDATE EM
							SET EM.Marital_Status = CRA.Curr_Details
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 5 -- For Permanent Address Request 
					Begin
						    UPDATE EM
							Set EM.Street_1 = CRA.Curr_Details,
							    EM.Tehsil	 = CRA.Curr_Tehsil,
							    EM.Thana_Id =  CRA.Curr_Thana,
							    EM.District =  CRA.Curr_District,
							    EM.City	 =   CRA.Curr_City_Village,
							    EM.State	 =   CRA.Curr_State,
							    EM.Zip_code =   CRA.Curr_Pincode
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					
					if @Request_Type_id = 6 -- For Present Address Request 
					Begin
						    UPDATE EM
							Set Present_Street = CRA.Curr_Details,
							    Tehsil_Wok = CRA.Curr_Tehsil,
							    Thana_Id_Wok = CRA.Curr_Thana,
							    District_Wok = CRA.Curr_District,
							    Present_City = CRA.Curr_City_Village,
							    Present_State = CRA.Curr_State,
							    Present_Post_Box = CRA.Curr_Pincode
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					if @Request_Type_id = 2 -- For Branch Request 
					Begin
								
						    	SELECT @Increment_ID = Increment_ID,@Increment_ID_old = Increment_ID_old FROM T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
						       --Select @Increment_ID,@Increment_ID_old
						    	
						    	UPDATE EM
								Set EM.Branch_ID = CRA.Curr_Details,
									EM.Increment_ID = @Increment_ID_old
								FROM T0080_EMP_MASTER	EM
								INNER JOIN T0090_Change_Request_Approval CRA
								on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
								Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
								
															
								Delete FROM T0100_Emp_Manager_History where Increment_id = @Increment_ID
								
								Delete From  T0100_EMP_EARN_DEDUCTION  where increment_id = @Increment_ID
								
								Delete From T0095_INCREMENT where increment_id = @Increment_ID
								
								Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
								--Update T0080_EMP_MASTER Set Increment_ID = @Increment_ID_old where Cmp_id = @cmp_id and Emp_ID = @Emp_ID and Increment_ID = @Increment_ID		
								Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
					End
					
					if @Request_Type_id = 7 -- For Qualification
						Begin
							Declare @Qual_ID Numeric(6,0)
							Select @Qual_ID = Quaulification_ID From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							Delete From T0090_EMP_QUALIFICATION_DETAIL where emp_id=@Emp_ID And Qual_ID=@Qual_ID 
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
						End
					
					if @Request_Type_id = 8 -- For Dependent
						Begin



							Declare @DepID int
							Select @DepID = Curr_Dep_ID  From T0090_Change_Request_Approval WITH (NOLOCK) 
							where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 

						if @DepID<>0
						Begin

						   Update ECD
						   Set ECD.Name=RA.Curr_Dep_Name
						       ,ECD.Gender = RA.Curr_Dep_Gender
							   ,ECD.Date_Of_Birth = RA.Curr_Dep_DOB
							   ,ECD.C_Age = RA.Curr_Dep_CAGE
							   ,ECD.Relationship = RA.Curr_Dep_Relationship
							   ,ECD.Is_Resi = RA.Curr_Dep_ISResi
							   ,ECD.Is_Dependant = RA.Curr_Dep_ISDep
							   ,ECD.Image_Path = RA.Curr_Dep_ImagePath
							   ,ECD.Pan_Card_No = RA.Curr_Dep_PanCard
							   ,ECD.Adhar_Card_No = RA.Curr_Dep_AdharCard
							   ,ECD.Height = RA.Curr_Dep_Height
							   ,ECD.Weight = RA.Curr_Dep_Weight
							   ,ECD.OccupationID = RA.Curr_Dep_OccupationID
							   ,ECD.HobbyID = RA.Curr_Dep_HobbyID
							   ,ECD.HobbyName = RA.Curr_Dep_HobbyName
							   ,ECD.DepCompanyName = RA.Curr_Dep_CompanyName
							   ,ECD.CmpCity = RA.Curr_Dep_CompanyCity
							   ,ECD.Standard_ID = RA.Curr_Dep_StandardID
							   ,ECD.Shcool_College = RA.Curr_Dep_SchCol
							   ,ECD.City = RA.Curr_Dep_SchColCity
							   ,ECD.ExtraActivity = RA.Curr_Dep_ExtraActivity
							   ,ECD.Std_Specialization = RA.Curr_Dep_Std_Specialization -- Added by ronakk 21072022

							   From  T0090_EMP_CHILDRAN_DETAIL ECD
							   inner join T0090_Change_Request_Approval RA On ECD.Row_ID = RA.Curr_Dep_ID and ECD.Emp_ID= RA.Emp_ID
							   where RA.Request_id = @Request_id and ECD.Emp_ID = @Emp_ID and RA.Request_Type_id = @Request_Type_id
							   and ECD.Row_ID =@CurDepID
						   

							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 

						End
						else
						Begin


							Declare @DepedantName Varchar(100)
							Select @DepedantName = Dependant_Name From T0090_Change_Request_Approval WITH (NOLOCK) where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							Delete From T0090_EMP_CHILDRAN_DETAIL where emp_id=@Emp_ID And Name =  @DepedantName
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 


						End



							--Declare @Depedant_Name Varchar(100)
							--Select @Depedant_Name = Dependant_Name From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							--Delete From T0090_EMP_CHILDRAN_DETAIL where emp_id=@Emp_ID And Name =  @Depedant_Name
							--Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							--Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
						End
					if @Request_Type_id = 13
						Begin
							
							Declare @EffectiveDate_1 Datetime
							Select @EffectiveDate_1 = Effective_Date From T0090_Change_Request_Approval  where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
							Select @EffectiveDate_1
							
							Update T0080_EMP_MASTER
								SET Ifsc_Code = CRA.Curr_IFSC_Code
							FROM T0080_EMP_MASTER	EM
							INNER JOIN T0090_Change_Request_Approval CRA
							on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
								
							Select * From T0090_Change_Request_Approval where Request_id = 35			
							Update I SET 
								I.Bank_ID = CRA.Curr_Details,
								I.Inc_Bank_AC_No = CRA.Curr_Account_No,
								I.Bank_Branch_Name = CRA.Curr_Branch_Name
							From T0095_INCREMENT I Inner JOIN 
							(
								SELECT MAX(Increment_Effective_Date) as Effective_Date,Emp_ID
								FROM T0095_INCREMENT Where Cmp_ID = @Cmp_id and Increment_Effective_Date <= @EffectiveDate_1
								GROUP By Emp_ID
							) as Qry
							On I.Increment_Effective_Date = Qry.Effective_Date and I.Emp_ID = Qry.Emp_ID
							Inner JOIN T0090_Change_Request_Approval CRA
							on  I.Emp_ID  = CRA.Emp_ID and I.Cmp_ID = CRA.Cmp_id
							Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id 
							
							Select * From T0090_Change_Request_Approval where Request_id = 35
							
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End
					if @Request_Type_id = 9 -- For Passport
						Begin 
							
							Declare @passport_no Varchar(100)
							Select @passport_no = Pass_Visa_No From T0090_Change_Request_Approval  where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		 	
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End 
					
					if @Request_Type_id = 10 -- For Visa
						Begin 
							Declare @visa_no Varchar(100)
							Select @visa_no = @Pass_Visa_No From T0090_Change_Request_Approval  where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
							Delete FROM T0090_EMP_IMMIGRATION_DETAIL where Emp_ID = @Emp_ID and Imm_No = @visa_no 
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End 
					
					if @Request_Type_id = 11 -- For License
						Begin 
							Declare @LicenseID Varchar(100)
							Select @LicenseID = License_ID From T0090_Change_Request_Approval  where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		 	
							Delete FROM T0090_EMP_LICENSE_DETAIL where Emp_ID = @Emp_ID and LIC_ID = @LicenseID 
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End
					if @Request_Type_id = 14
						Begin
							Declare @Nominees_RowID Varchar(100)
							Select @Nominees_RowID = Nominees_Row_ID From T0090_Change_Request_Approval  where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		 	
							Delete FROM T0090_EMP_DEPENDANT_DETAIL Where Emp_ID = @Emp_ID and Row_ID = @Nominees_RowID
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End
					if @Request_Type_id = 15
						Begin
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End
					if @Request_Type_id = 16
						Begin
							Update EM
								SET Pan_No = RA.Old_Pan_No,
								Aadhar_Card_No = RA.Old_Adhar_No
							From T0080_EMP_MASTER EM Inner JOIN  T0090_Change_Request_Approval RA
							On EM.Emp_ID = RA.Emp_ID
							where RA.Request_id = @Request_id and EM.Emp_ID = @Emp_ID and RA.Request_Type_id = @Request_Type_id 
											
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End	
					if @Request_Type_id = 17
						BEGIN
							
							if Exists(SELECT 1 From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id )
								BEGIN
									DECLARE @Sal_Month Numeric(2,0)
									Declare @Sal_Year Numeric(4,0)
									Set @Sal_Year = 0
									Set @Sal_Month = 0 
									Select @Sal_Month = Loan_Month,@Sal_Year=Loan_Year From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id AND Request_id = @Request_id
									
									if exists(SELECT 1 From T0200_MONTHLY_SALARY Where Month(Month_St_Date) = @Sal_Month AND Year(Month_St_Date) = @Sal_Year AND Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID)
										BEGIN
											--RAISERROR ('Salary Exists So You Can not Delete it.',16,1)
											Set @Tran_id = 0
											return  @Tran_id
										END
									Else
										Begin
											Declare @Loan_Request_AprID numeric(18,0)
											
											Select @Loan_Request_AprID = Request_Apr_ID From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 
											Delete From T0100_Monthly_Loan_Skip_Approval where Request_Apr_ID = @Loan_Request_AprID and Emp_ID = @Emp_ID 
											Delete From T0100_Monthly_Loan_Skip_Approval where Request_ID = @Request_id and Emp_ID = @Emp_ID and S_Emp_Id = @S_Emp_Id
											
											Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
											Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 	
															
										End
								END
							Else
								Begin
									Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
									Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
								End
						End
						if @Request_Type_id = 18
							BEGIN
								Declare @LeftDate Datetime
								Set @LeftDate = ''
								
								Select 
								@LeftDate = CONVERT(datetime,CRA.New_Details,103) 
								FROM T0080_EMP_MASTER	EM
								INNER JOIN T0090_Change_Request_Approval CRA
								on  EM.Emp_ID  = CRA.Emp_ID and EM.Cmp_ID = CRA.Cmp_id
								Where CRA.Request_id = @Request_id and CRA.Cmp_ID = @cmp_id and CRA.Emp_ID = @Emp_ID and CRA.Request_Type_id = @Request_Type_id
								
								Declare @Request_Apr_ID Numeric(18,0)
								Set @Request_Apr_ID = 0
								Select @Request_Apr_ID = Request_Apr_ID From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id	
									
								Declare @Left_id Numeric(18,2)
								Set @Left_id = 0
							    Select @Left_id = Left_ID From T0100_LEFT_EMP Where Emp_ID = @Emp_ID and Reg_Date = @LeftDate
							    
								exec P0100_LEFT_EMP @Left_ID = @Left_id output,@Emp_ID=@Emp_ID,@Cmp_ID=@Cmp_id,@Left_Date=@LeftDate ,@Reg_Accept_Date=@LeftDate,@Left_Reason='',@New_Employer='',@Is_Terminate='0',@tran_type='Delete',@Uniform_Return=0,@Exit_Interview=0,@Notice_period=0,@Is_Death=0,@Reg_Date=@LeftDate,@Is_FnF_Applicable=1,@RptManager_ID=0,@IS_Retire=0,@User_Id=0,@IP_Address='',@Request_Apr_ID =@Request_Apr_ID
								Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
								Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id	
							End
						if @Request_Type_id = 19
							BEGIN
							
								Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
								Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
							End
						if @Request_Type_id = 20   --Added by Jaina 14-05-2018
						begin
								declare @From_Date datetime
								declare @To_Date datetime								
								declare @Leave_ID numeric(18,0)
								select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER where Leave_Type = 'Paternity Leave' and Cmp_ID=@Cmp_ID
								
								
								Create table #Paternity_Leave
								(
									Leave_Tran_Id numeric(18,0),
									Emp_id numeric(18,0),
									For_Date datetime,
									Leave_Opening numeric(18,2),
									Leave_Closing numeric(18,2),
									Laps_Days numeric(18,2),
									From_Date datetime,
									To_Date datetime
								)
								
								insert INTO #Paternity_Leave
								EXEC P_RESET_PATERNITY_LEAVE @CMP_ID = @CMP_ID,@EMP_ID=@EMP_ID
									
								
								SELECT @From_Date = From_Date, @To_Date = To_Date 
								FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID and From_Date = @Child_Birth_Date
								
								
								IF EXISTS (SELECT  1 FROM T0100_LEAVE_APPLICATION LA INNER JOIN 
									       T0110_LEAVE_APPLICATION_DETAIL LAd ON LA.Leave_Application_ID = LAd.Leave_Application_ID INNER JOIN
										   T0040_LEAVE_MASTER L ON L.Leave_ID = LAd.Leave_ID INNER JOIN
										   T0090_Change_Request_Approval CRA ON CRA.Emp_ID = LA.Emp_ID INNER JOIN
										   T0040_Change_Request_Master CM ON CM.Request_id = CRA.Request_Type_id
										WHERE L.Cmp_ID = @Cmp_id AND L.Leave_Type = 'Paternity Leave' AND CM.Request_type = 'Child Birth Detail'
											AND La.Emp_ID = @Emp_ID	AND LAd.From_Date BETWEEN @From_Date AND @To_Date )
								  BEGIN
										RAISERROR('@@Reference Exists, In Leave Application @@',16,2)
										return
								  END							
								ELSE IF EXISTS (SELECT 1 FROM T0140_LEAVE_TRANSACTION LT INNER JOIN 
												T0040_LEAVE_MASTER LA ON LT.Leave_ID = LA.Leave_ID INNER JOIN
												T0090_Change_Request_Approval CRA ON CRA.Emp_ID = LT.Emp_ID INNER JOIN
												T0040_Change_Request_Master CM ON CM.Request_id = CRA.Request_Type_id
										WHERE LT.Cmp_ID = @Cmp_id AND LA.Leave_Type = 'Paternity Leave' AND CM.Request_type = 'Child Birth Detail'
										and lt.Emp_ID = @Emp_ID AND LT.For_Date BETWEEN @From_Date AND @To_Date AND LT.Leave_Used > 0)
									BEGIN
										RAISERROR('@@Reference Exists, In Leave Approval @@',16,2)
										return
									END
									
								Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
								Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id									
						end
						

						
							if @Request_Type_id = 23
						Begin
						            --Change by ronakk 24062022
						       
							Update EM
							SET   Emp_Fav_Sport_id 	= RA.Curr_Emp_Fav_Sport_id 
								 ,Emp_Fav_Sport_Name = RA.Curr_Emp_Fav_Sport_Name 
								 ,Emp_Hobby_id = RA.Curr_Emp_Hobby_id 
								 ,Emp_Hobby_Name = RA.Curr_Emp_Hobby_Name 
								 ,Emp_Fav_Food = RA.Curr_Emp_Fav_Food  
								 ,Emp_Fav_Restro = RA.Curr_Emp_Fav_Restro 
								 ,Emp_Fav_Trv_Destination = RA.Curr_Emp_Fav_Trv_Destination 
								 ,Emp_Fav_Festival = RA.Curr_Emp_Fav_Festival 
								 ,Emp_Fav_SportPerson = RA.Curr_Emp_Fav_SportPerson 
								 ,Emp_Fav_Singer = RA.Curr_Emp_Fav_Singer

							From T0080_EMP_MASTER EM 	 
							Inner JOIN  T0090_Change_Request_Approval RA On EM.Emp_ID = RA.Emp_ID
							where RA.Request_id = @Request_id and EM.Emp_ID = @Emp_ID and RA.Request_Type_id = @Request_Type_id 
											
							Delete From T0115_Request_Level_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id and S_Emp_Id = @S_Emp_Id
							Delete From T0090_Change_Request_Approval where Request_id = @Request_id and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id 		
						End	


					UPDATE   T0090_Change_Request_Application
					SET      Request_status = 'P'
					WHERE    Request_id = @Request_id and Cmp_ID=@Cmp_ID and Emp_ID = @Emp_ID and Request_Type_id = @Request_Type_id
					
				End
		End
END
Return

