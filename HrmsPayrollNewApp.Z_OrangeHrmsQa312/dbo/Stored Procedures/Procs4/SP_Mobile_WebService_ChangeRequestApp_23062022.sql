-- =============================================
-- Author:		<Author,,Nilesh Patel>
-- Create date: <Create Date,12-Dec-2014 ,>
-- Description:	<Description, For Change Application Details,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChangeRequestApp_23062022] 
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
	  ,@Request_id Numeric(18,0) output
	  ,@Result Varchar(250) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--if @Dependant_Age = ''  
--  SET @Dependant_Age  = NULL
  
--  if @Dependant_Age is not null
--  Begin
--        set @Dependant_Age = DateDiff(year,@Dependant_Age,getdate())
--  end
--  else
--		set @Dependant_Age =	0.00
	
	IF @Shift_From_Date = ''
		Begin
			Set @Shift_From_Date = NULL
		End
	IF @Shift_To_Date = ''
		Set @Shift_To_Date = NULL
	
	--IF @Curr_Tehsil = ''
	--	Set @Curr_Tehsil = NULL
		
	--IF @Curr_District = ''
	--	Set @Curr_District = NULL
		
	--IF @Curr_Thana = ''
	--	Set @Curr_Thana = NULL
		
	--IF @Curr_City_Village = ''
	--	Set @Curr_City_Village = NULL
		
	--IF @Curr_State = ''
	--	Set @Curr_State = NULL
		
	--IF @Curr_Pincode = 0
	--	Set @Curr_Pincode = NULL
		
	--IF @New_Tehsil = ''
	--	Set @New_Tehsil = NULL
	
	--IF @New_District = ''
	--	Set @New_District = NULL
	
	--IF @New_Thana = ''
	--	Set @New_Thana = NULL	
		
	--IF @New_City_Village = ''
	--	Set @New_City_Village = NULL
	
	--IF @New_State = ''
	--	Set @New_State = NULL
		
	--IF @New_Pincode = 0
	--	Set @New_State = NULL
	
	--If @Curr_Details = '01/01/1900'
	--	Set @Curr_Details = NULL
		
	--If @Qu_Start_Date = '01/01/1900'
	--	Set @Qu_Start_Date = NULL
		
	--If @Qu_End_Date = '01/01/1900'
	--	Set @Qu_End_Date = NULL
	
	--If @Dependant_DOB = '01/01/1900'
	--	Set @Dependant_DOB = NULL
	
	--If @Pass_Visa_Issue_Date = '01/01/1900'
	--	Set @Pass_Visa_Issue_Date = NULL
	
	--If @Pass_Visa_Exp_Date = '01/01/1900'
	--	Set @Pass_Visa_Exp_Date = NULL
		
	--if @Pass_Visa_Review_Date = '01/01/1900' 				 
	--	Set @Pass_Visa_Review_Date = NULL
		
	--if @License_IssueDate  = '01/01/1900' 		
	--	Set @License_IssueDate = NULL
		
	--if	@License_ExpDate = '01/01/1900' 
	--	Set @License_ExpDate = NULL
	
	--if @Admit_Date = '01/01/1900'
	--	Set @Admit_Date = NULL
	
	--IF @Child_Birth_Date = '01/01/1900'   --Added by Jaina 27-04-2018
	--	set @Child_Birth_Date  = NULL	
		
		
	--if @Nominees_Row_ID = 'Self'
	--	Set @Nominees_Row_ID = '0'
			
		DECLARE @MONTH NUMERIC(18,0)
		DECLARE @YEAR NUMERIC(18,0)
		DECLARE @YEAR_ST_DATE DATETIME
		DECLARE @YEAR_END_DATE DATETIME		
		Declare @App_Count numeric(18,0) = 0
		DECLARE @Appr_Count numeric(18,0) = 0
		Declare @Count numeric(18,0) = 0 
		Declare @Max_Limit numeric(18,0) 
		declare @Message varchar(2000)
		
	If @Request_Type_id= 3 -- For Shift Change -- Added by Hardik 31/03/2020 for unison query redmine # 8680
		Begin
			Create Table #Error
			(
				Error_Msg varchar(max)
			)
		End

    if @tran_type = 'I'
		Begin	
			if @Request_Type_id = 20
			BEGIN
				--select @Max_Limit = Max_Limit from T0040_Change_Request_Master where Cmp_ID=@Cmp_Id and Request_type='Child Birth Limit (For Paternity Leave)'
				select @Max_Limit = Max_Leave_Lifetime FROM T0040_LEAVE_MASTER WITH (NOLOCK)  WHERE CMP_ID = @CMP_ID and Leave_Type='Paternity Leave'  --Added by Jaina 14-03-2019
			
				
				select @App_Count = COUNT(1) FROM T0090_Change_Request_Application WITH (NOLOCK) where Cmp_id=@Cmp_Id and Emp_ID=@Emp_id and Request_Type_id = 20 and Request_status='P' and Request_id <> @Request_id
				SELECT @Appr_Count = COUNT(1) FROM T0090_Change_Request_Approval WITH (NOLOCK) where Cmp_id=@Cmp_Id AND Emp_ID=@Emp_id AND Request_Type_id=20 and Request_status = 'A'
				
				set @Count = ISNULL(@App_Count,0) + ISNULL(@Appr_Count,0)

				if @CHILD_BIRTH_DATE > getdate()
				begin
					set @Message = '@@Can''t Allow Future Child Birth Date @@'
					RAISERROR(@Message,16,2)
					RETURN
				end
				
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
					
																		
								
					IF EXISTS (SELECT 1 FROM T0090_CHANGE_REQUEST_APPLICATION WITH (NOLOCK) WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID AND Request_status='P'
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year @@',16,2)
						RETURN
					END
					
					IF EXISTS (SELECT 1 FROM T0090_Change_Request_Approval WITH (NOLOCK) WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID 
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE)
					BEGIN
						RAISERROR('@@You can''t apply this request for paternity leave within this year @@',16,2)
						RETURN
					END
			END

				If @Request_Type_id= 3 -- For Shift Change -- Added by Hardik 31/03/2020 for unison query redmine # 8680
					Begin
						Insert into #Error
						exec P_VALIDATE_HW_SHIFT @Cmp_ID=@CMP_ID,@Effective_date=@shift_From_Date,@Constraint=@Emp_Id,@Error_msg='',@Module_name='Shift Change'
						
						IF Exists(Select 1 From #Error where Isnull(Error_Msg,'') <> '')
							BEGIN
								Select @Message = '@@' + Error_Msg + '@@' From #Error where Isnull(Error_Msg,'') <> ''
								RAISERROR (@MESSAGE,16,2)
								RETURN
							END
					End
		
			If Exists(Select Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id and Request_status = 'P' AND isnull(Shift_From_Date,'') = isnull(@Shift_From_Date,'') and isnull(Shift_To_Date,'') = isnull(@Shift_To_Date,''))
				begin					
					Select @Request_id = Request_id From T0090_Change_Request_Application WITH (NOLOCK) Where Emp_id = @Emp_ID and Request_Type_id = @Request_Type_id and Request_status = 'P'
					Set @Request_id = 0
					Return
				end
			Else
			Begin										
					select @Request_id = Isnull(max(Request_id),0) + 1 	From dbo.T0090_Change_Request_Application WITH (NOLOCK)
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
					 --Curr_Details,
					 --New_Details,
					 --Curr_Tehsil,
					 --Curr_District,
					 --Curr_Thana,
					 --Curr_City_Village,
					 --Curr_State,
					 --Curr_Pincode,
					 --New_Tehsil,
					 --New_District,
					 --New_Thana,
					 --New_City_Village,
					 --New_State,
					 --New_Pincode,
					 --Request_status,
					 --Quaulification_ID,
					 --Specialization,
      --               Passing_Year,
					 --Score,
					 --Quaulification_Star_Date,
					 --Quaulification_End_Date,
					 Dependant_Name,
					 Dependant_Relationship,
					 Dependant_Gender,
					 Dependant_DOB,
					 Dependant_Age,
					 Dependant_Is_Resident,
					 Dependant_Is_Dependant,
					 --Pass_Visa_Citizenship,
					 --Pass_Visa_No,
					 --Pass_Visa_Issue_Date,
					 --Pass_Visa_Exp_Date,
					 --Pass_Visa_Review_Date,
					 --Pass_Visa_Status,
					 --License_ID,
					 --License_Type,
					 --License_IssueDate,
					 --License_No,
					 --License_ExpDate,
					 --License_Is_Expired,
					 --Image_path,
					 --Curr_IFSC_Code,
					 --Curr_Account_No,
					 --Curr_Branch_Name,
					 --New_IFSC_Code,
					 --New_Account_No,
					 --New_Branch_Name,
					 --Nominess_Address,
					 --Nominess_Share,
					 --Nominess_For,
					 --Nominees_Row_ID,
					 --Hospital_Name,
					 --Hospital_Address,
					 --Admit_Date,
					 --MediCalim_Approval_Amount,
					 --Old_Pan_No,
					 --New_Pan_No,
					 --Old_Adhar_No,
					 --New_Adhar_No,
					 --Loan_Month,
					 --Loan_Year,
					 --Loan_Skip_Details,
					 Child_Birth_Date

					 ---------------------------------------- Added by ronakk 21062022 ----------------------------
					 ,Dep_OccupationID
					 ,Dep_HobbyID
					 ,Dep_HobbyName
					 ,Dep_DepCompanyName
					 ,Dep_CmpCity
					 ,Dep_Standard_ID
					 ,Dep_Shcool_College
					 ,Dep_SchCity
					 ,Dep_ExtraActivity
					 -------------------------------------------End by ronakk 21062022 ----------------------------


					  ---------------------------------------- Added by ronakk 22062022 ----------------------------
					  --,Emp_Fav_Sport_id 
					  --,Emp_Fav_Sport_Name 
					  --,Emp_Hobby_id 
					  --,Emp_Hobby_Name 
					  --,Emp_Fav_Food  
				   --   ,Emp_Fav_Restro 
					  --,Emp_Fav_Trv_Destination 
					  --,Emp_Fav_Festival 
					  --,Emp_Fav_SportPerson 
					  --,Emp_Fav_Singer
					   -------------------------------------------End by ronakk 22062022 ----------------------------

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
					 --@Curr_Details,
					 --@New_Details,
					 --@Curr_Tehsil,	
					 --@Curr_District,
					 --@Curr_Thana,
					 --@Curr_City_Village,
					 --@Curr_State,
					 --@Curr_Pincode,
					 --@New_Tehsil,
					 --@New_District,
					 --@New_Thana,
					 --@New_City_Village,
					 --@New_State,
					 --@New_Pincode,
					 --@Request_status,
					 --@Qu_Type,
					 --@Qu_Specialization,
	     --            @Qu_Passing_year,
	     --            @Qu_Passing_Score,
	     --            @Qu_Start_Date,
	     --            @Qu_End_Date,
	                 @Dependant_Name,
					 @Dependant_Relationship,
					 @Dependant_Gender,
					 @Dependant_DOB,
					 @Dependant_Age,
					 @Dependant_Is_Resident,
					 @Dependant_Is_Depended,
					 --@Pass_Visa_Citizenship,
					 --@Pass_Visa_No,
					 --@Pass_Visa_Issue_Date,
					 --@Pass_Visa_Exp_Date,
					 --@Pass_Visa_Review_Date,
					 --@Pass_Visa_Status,
					 --@License_ID,
					 --@License_Type,
					 --@License_IssueDate,
					 --@License_No,
					 --@License_ExpDate,
					 --@License_Is_Expired,
					 --@Image_Path,
					 --@Curr_IFSC_Code,
					 --@Curr_Account_No,
					 --@Curr_Branch_Name,
					 --@New_IFSC_Code,
					 --@New_Account_No,
					 --@New_Branch_Name,
					 --@Nominees_Address,
					 --@Nominees_Share,
	     --            @Nominees_For,
	     --            @Nominees_Row_ID,
					 --@Hospital_Name,
					 --@Hospital_Address,
					 --@Admit_Date,
					 --@MediCalim_Approval_Amount,
					 --@Old_Pan_No,
					 --@New_Pan_No,
					 --@Old_Adhar_No,
					 --@New_Adhar_No,
					 --@Loan_Installment_Month,
					 --@Loan_Installment_Year,
					 --@Loan_New_Install_Amt,
					 @Child_Birth_Date

					 -----------------------------------------Added by ronakk 21062022 ------------------------------

					 ,@DepOccupationID
					 ,@DepHobbyID
					 ,@DepHobbyName
					 ,@DepCompany
					 ,@DepCmpCity
					 ,@DepStandardId
					 ,@DepSchCol
					 ,@DepSchColCity
					 ,@DepExtAct
					 ----------------------------------------------End by ronakk 21062022 ---------------------------


					  -----------------------------------------Added by ronakk 22062022 ------------------------------
					  --,@EmpFavSportID 
					  --,@EmpFavSportName
					  --,@EmpHobbyID 
					  --,@EmpHobbyName
					  --,@EmpFavFood 
					  --,@EmpFavRestro
					  --,@EmpFavTrvDestination
		     --         ,@EmpFavFestival
					  --,@EmpFavSportPerson
					  --,@EmpFavSinger

					  -----------------------------------------End by ronakk 22062022 ------------------------------
					 )

					 if @Request_id > 0
					Begin 
						SET @Result = 'Inserted Successfully#True#'
					END
					RETURN 
			 End
		End
	Else if @Tran_Type = 'U'
		begin
				if @Request_Type_id = 20
				BEGIN
					SET @MONTH = MONTH(@CHILD_BIRTH_DATE)
					SET @YEAR = YEAR(@CHILD_BIRTH_DATE)
					
					SET @YEAR_END_DATE = DBO.GET_MONTH_END_DATE(@MONTH,@YEAR)
					SET @YEAR_ST_DATE = DATEADD(yyyy,-1,@YEAR_END_DATE)									
					
					if @CHILD_BIRTH_DATE > getdate()
					begin
						set @Message = '@@Can''t Allow Future Child Birth Date @@'
						RAISERROR(@Message,16,2)
						RETURN
					end
						
					IF EXISTS (SELECT 1 FROM T0090_CHANGE_REQUEST_APPLICATION WITH (NOLOCK) WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID AND Request_status='P'
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE AND Request_id <> @Request_Id)
					BEGIN
						RAISERROR('You can''t apply this request for paternity leave within this year ',16,2)
						RETURN
					END
					
					IF EXISTS (SELECT 1 FROM T0090_Change_Request_Approval WITH (NOLOCK) WHERE CMP_ID =@CMP_ID 
								AND REQUEST_TYPE_ID=20 AND EMP_ID=@EMP_ID 
								AND CHILD_BIRTH_DATE BETWEEN @YEAR_ST_DATE AND @YEAR_END_DATE AND Request_id <> @Request_Id)
					BEGIN
						RAISERROR('You can''t apply this request for paternity leave within this year ',16,2)
						RETURN
					END
				END

				If @Request_Type_id= 3 -- For Shift Change -- Added by Hardik 31/03/2020 for unison query redmine # 8680
					Begin
						Insert into #Error
						exec P_VALIDATE_HW_SHIFT @Cmp_ID=@CMP_ID,@Effective_date=@shift_From_Date,@Constraint=@Emp_Id,@Error_msg='',@Module_name='Shift Change'
						
						IF Exists(Select 1 From #Error where Isnull(Error_Msg,'') <> '')
							BEGIN
								Select @Message = '@@' + Error_Msg + '@@' From #Error where Isnull(Error_Msg,'') <> ''
								RAISERROR (@MESSAGE,16,2)
								RETURN
							END
					End
					
				Update T0090_Change_Request_Application
				set  Change_Reason = @Change_Reason,
					 Request_Type_id = @Request_Type_id,
					 --Request_Date = @Request_Date,
					 Shift_From_Date = @Shift_From_Date,
					 Shift_To_Date = @Shift_To_Date,
					 --Curr_Details = @Curr_Details,
					 --New_Details =  @New_Details,
					 --Curr_Tehsil = @Curr_Tehsil,
					 --Curr_District = @Curr_District,
					 --Curr_Thana = @Curr_Thana,
					 --Curr_City_Village = @Curr_City_Village,
					 --Curr_State = @Curr_State,
					 --Curr_Pincode = @Curr_Pincode,
					 --New_Tehsil = @New_Tehsil,
					 --New_District = @New_District,
					 --New_Thana = @New_Thana,
					 --New_City_Village = @New_City_Village,
					 --New_State = @New_State,
					 --New_Pincode = @New_Pincode,
					 --Request_status = @Request_status,
					 --Quaulification_ID = @Qu_Type,
					 --Specialization = @Qu_Specialization,
      --               Passing_Year = @Qu_Passing_year,
					 --Score = @Qu_Passing_Score,
					 --Quaulification_Star_Date = @Qu_Start_Date,
					 --Quaulification_End_Date = @Qu_End_Date,
					 Dependant_Name = @Dependant_Name,
					 Dependant_Relationship = @Dependant_Relationship,
					 Dependant_Gender = @Dependant_Gender,
					 Dependant_DOB = @Dependant_DOB,
					 Dependant_Age = @Dependant_Age,
					 Dependant_Is_Resident = @Dependant_Is_Resident,
					 Dependant_Is_Dependant = @Dependant_Is_Depended,
					 --Pass_Visa_Citizenship = @Pass_Visa_Citizenship,
					 --Pass_Visa_No = @Pass_Visa_No,
					 --Pass_Visa_Issue_Date = @Pass_Visa_Issue_Date,
					 --Pass_Visa_Exp_Date = @Pass_Visa_Exp_Date,
					 --Pass_Visa_Review_Date = @Pass_Visa_Review_Date,
					 --Pass_Visa_Status = @Pass_Visa_Status,
					 --License_ID = @License_ID,
					 --License_Type = @License_Type,
					 --License_IssueDate = @License_IssueDate,
					 --License_No = @License_No,
					 --License_ExpDate = @License_ExpDate,
					 --License_Is_Expired = @License_Is_Expired,
					 --Image_path = @Image_Path,
					 --Curr_IFSC_Code = @Curr_IFSC_Code,
					 --Curr_Account_No = @Curr_Account_No,
					 --Curr_Branch_Name = @Curr_Branch_Name,
					 --New_IFSC_Code = @New_IFSC_Code,
					 --New_Account_No = @New_Account_No,
					 --New_Branch_Name = @New_Branch_Name,
					 --Nominess_Address = @Nominees_Address,
					 --Nominess_Share = @Nominees_Share,
					 --Nominess_For = @Nominees_For,
					 --Nominees_Row_ID = @Nominees_Row_ID,
					 --Hospital_Name = @Hospital_Name,
					 --Hospital_Address = @Hospital_Address,
					 --Admit_Date = @Admit_Date,
					 --MediCalim_Approval_Amount = @MediCalim_Approval_Amount,
					 --Old_Pan_No = @Old_Pan_No,
					 --Old_Adhar_No = @Old_Adhar_No,
					 --New_Adhar_No = @New_Adhar_No,
					 --New_Pan_No = @New_Pan_No,
					 --Loan_Year = @Loan_Installment_Year,
					 --Loan_Month = @Loan_Installment_Month,
					 --Loan_Skip_Details = @Loan_New_Install_Amt,
					 Child_Birth_Date = @Child_Birth_Date


					 -----------------------------------------Added by ronakk 21062022 ------------------------------

					 ,Dep_OccupationID= @DepOccupationID
					 ,Dep_HobbyID = @DepHobbyID
					 ,Dep_HobbyName = @DepHobbyName
					 ,Dep_DepCompanyName = @DepCompany
					 ,Dep_CmpCity = @DepCmpCity
					 ,Dep_Standard_ID = @DepStandardId
					 ,Dep_Shcool_College = @DepSchCol
					 ,Dep_SchCity = @DepSchColCity
					 ,Dep_ExtraActivity =  @DepExtAct

					 ----------------------------------------------End by ronakk 21062022 ---------------------------

					 ---------------Added by ronakk 22062022 -----------------------------------------
				    --,Emp_Fav_Sport_id = @EmpFavSportID
				    --,Emp_Fav_Sport_Name = @EmpFavSportName
				    --,Emp_Hobby_id = @EmpHobbyID
				    --,Emp_Hobby_Name = @EmpHobbyName
				    --,Emp_Fav_Food = @EmpFavFood
				    --,Emp_Fav_Restro = @EmpFavRestro
				    --,Emp_Fav_Trv_Destination = @EmpFavTrvDestination
				    --,Emp_Fav_Festival = @EmpFavFestival
				    --,Emp_Fav_SportPerson = @EmpFavSportPerson
				    --,Emp_Fav_Singer = @EmpFavSinger 
				   
				    ---------------End by ronakk 22062022 -----------------------------------------



				where Request_id= @Request_id and Cmp_id = @Cmp_id and Emp_ID = @Emp_ID
				
				
		end
	Else if @Tran_Type = 'D'
		begin
			
			Delete From T0090_Change_Request_Application Where Request_id= @Request_id and Cmp_id = @Cmp_id  and Emp_ID = @Emp_ID
			Delete From T0100_Monthly_Loan_Skip_Application Where Request_id= @Request_id and Cmp_id = @Cmp_id  and Emp_ID = @Emp_ID
		end
	
	 --if @Loan_New_Install_Amt <> '' 
		--	Begin
		--		Declare @Loan_Apr_Id Numeric(18,0)
		--		Declare @Loan_New_Installment_Amt Numeric(18,2)
							
		--		Set @Loan_Apr_Id = 0
		--		Set @Loan_New_Installment_Amt = 0
							
		--		IF Exists(SELECT 1 From T0100_Monthly_Loan_Skip_Application  WITH (NOLOCK) Where Request_ID = @Request_id)
		--			BEGIN
		--				DELETE From T0100_Monthly_Loan_Skip_Application Where Request_ID = @Request_id
		--			End
							
		--			Declare @Loan_ID Numeric(18,0)
		--			Declare @Loan_Install_Amt Numeric(18,0)
							
		--			Declare Loan_Coursor Cursor For
		--			Select LEFT(Data,CHARINDEX(',',data)-1),RIGHT(Data,LEN(data)-CHARINDEX(',',data)) From dbo.Split(@Loan_New_Install_Amt,'#')
		--				Open Loan_Coursor
		--					fetch next from Loan_Coursor into @Loan_Apr_Id,@Loan_New_Installment_Amt
		--						while @@fetch_status = 0
		--							Begin
		--								Select @Loan_ID = isnull(Loan_ID,0),@Loan_Install_Amt = isnull(Loan_Apr_Installment_Amount,0) From T0120_LOAN_APPROVAL WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id
		--								Exec P0100_Monthly_Loan_Skip_Application @Tran_ID = 0,@Request_ID = @Request_id,@Cmp_ID = @Cmp_id,@Emp_ID = @Emp_ID,@Loan_Apr_ID = @Loan_Apr_Id,@Loan_ID = @Loan_ID,@Old_Install_Amount = @Loan_Install_Amt,@New_Install_Amount = @Loan_New_Installment_Amt
		--								fetch next from Loan_Coursor into @Loan_Apr_Id,@Loan_New_Installment_Amt
		--							End
		--				close Loan_Coursor
		--				deallocate Loan_Coursor
		--	End
END

