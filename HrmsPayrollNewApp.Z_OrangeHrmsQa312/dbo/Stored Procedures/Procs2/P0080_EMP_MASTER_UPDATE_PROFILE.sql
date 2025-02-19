

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_UPDATE_PROFILE] 
	@Emp_ID				numeric(18,0) 
   ,@Cmp_ID				numeric(18,0)
   ,@Gender				char(1)
   ,@Marital_Status		varchar(20)
   ,@Date_Of_Birth		DATETIME = null
   ,@Pan_No				varchar(30)
   ,@SSN_No				varchar(30)
   ,@SIN_No				varchar(30)
   ,@Dr_Lic_No			varchar(30)
   ,@Dr_Lic_Ex_Date		DATETIME = NULL
   ,@Other_Email		varchar(50)
   ,@Street_1		varchar(250)
   ,@City			varchar(30)
   ,@State			varchar(20)
   ,@Zip_code		varchar(20)
   ,@Loc_ID			numeric(18,0)
   ,@Home_Tel_no	varchar(30)
   ,@Nationality	varchar(20)
   ,@Work_Tel_No	varchar(30)
   ,@Mobile_No		varchar(30)
   ,@Present_Street varchar(250)
   ,@Present_City   varchar(30)
   ,@Present_State  varchar(30)
   ,@Present_Post_Box varchar(20)
   ,@tran_type			 char(1)
   ,@Login_Id	int = 0 --Added by Falak on 19-APR-2011
   ,@father_name    varchar(50) --Added by Mihir Trivedi on 09042012
   ,@MarkID         varchar(150) --Added by Mihir Trivedi on 09042012
   ,@Anniversery_Date   Datetime = null --Added by Mihir Trivedi on 09042012
   ,@Bloodgroup     varchar(50)  --Added by Mihir Trivedi on 09042012
   ,@TellyLedgerName varchar(100)
   ,@Religion        varchar(20)
   ,@UIDNo           varchar(20)
   ,@Category        varchar(20)
   ,@Height			 varchar(10)
   ,@Cast            varchar(20)
   ,@Insurance_No	 varchar(20)
   ,@Confirm_Date    Datetime = null
   ,@Probation       numeric(18,0) 
   ,@Dispensery		 varchar(50)
   ,@Doctor_Name     varchar(50)
   ,@dis_Address     varchar(200)
   ,@mother_name varchar(150) = ''
   ,@no_of_chlidren numeric =  0
   ,@is_metro tinyint = 0
   ,@is_physical tinyint = 0
   ,@Dress_Code			varchar(50) = ''	-- Added By Ali 25032014
   ,@Shirt_Size			varchar(20) = ''	-- Added By Ali 25032014
   ,@Pent_Size			varchar(20)	= ''	-- Added By Ali 25032014
   ,@Shoe_Size			varchar(20)	= ''	-- Added By Ali 25032014
   ,@Canteen_Code		varchar(50)	= ''	-- Added By Ali 01042014
   ,@Thana_Id as numeric = 0				-- Added By Ali 03042014
   ,@Tehsil as varchar(50) = ''				-- Added By Ali 03042014
   ,@District as varchar(50) = ''			-- Added By Ali 03042014	
   ,@Thana_Id_Wok as numeric = 0			-- Added By Ali 03042014
   ,@Tehsil_Wok as varchar(50) = ''			-- Added By Ali 03042014
   ,@District_Wok as varchar(50) = ''		-- Added By Ali 03042014
   ,@Aadhar_Card_No as Varchar(50) = ''		--Added By Ramiz on 07/08/2015
   ,@Vehicle_No as Varchar(50) = ''			--added jimit 08082015
   ,@RationCardType as varchar(50) = ''		--added jimit 07032016
   ,@RationCardNo	as varchar(50) = ''		--added jimit 07032016   
   ,@ActualBirthDate	as varchar(50) = '' --added jimit 07032016
   ,@Extension_No as varchar(10) = '' --added Mukti 23042016
   ,@LinkedIn_Id		AS VARCHAR(100) = '' --Ankit 05072016
   ,@Twitter_ID			AS VARCHAR(100) = '' --Ankit 05072016
   ,@Cast_Join           varchar(20)  --added by mehul 24052022


    ------------------------Added by ronakk 31052022 ----------------------
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
   ----------------------------------End by ronakk 31052022 ---------------------




AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Dr_Lic_Ex_Date = '' --change by Falak on 12-OCT-2010 
	set @Dr_Lic_Ex_Date = null
if @Date_Of_Birth = ''
	set @Date_Of_Birth = null
IF @ActualBirthDate = '1900-01-01'  --Added by Jaina 30-08-2017
	set @ActualBirthDate = NULL

Declare @OldValue as  varchar(max) --Added by Sumit 14062016
Declare @String as varchar(max)
set @String =''
set @OldValue = ''
	
if @tran_type = 'P'
		Begin
			exec P9999_Audit_get @table='T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))

			Update dbo.T0080_EMP_MASTER  
			SET  Gender = @Gender,
				Marital_Status = @Marital_Status,
   				Date_Of_Birth = @Date_Of_Birth,
   				Pan_NO = @Pan_No,
   				SSN_No = @SSN_No,
   				SIN_No = @SIN_No,
   				Dr_Lic_No = @Dr_Lic_No,
   				Dr_Lic_Ex_Date = @Dr_Lic_Ex_Date,
   				Other_Email = @Other_Email,
   				Login_id = @Login_Id,
   				Father_name = @father_name, --Added by Mihir Trivedi on 09042012
   				Emp_Mark_Of_Identification = @MarkID, --Added by Mihir Trivedi on 09042012
   				Emp_Annivarsary_Date = @Anniversery_Date, --Added by Mihir Trivedi on 09042012
   				Blood_Group = @Bloodgroup,  --Added by Mihir Trivedi on 09042012
   				Tally_Led_Name = @TellyLedgerName, 
   				Religion = @Religion,
   				Emp_UIDNo = @UIDNo,
   				Emp_Category = @Category,
   				Height = @Height,
   				Emp_Cast = @Cast,
   				Insurance_No = @Insurance_No,
   				Emp_Confirm_Date = @Confirm_Date,
   				Probation = @Probation,
   				Despencery=@Dispensery,
   				Doctor_Name = @Doctor_Name,
   				DespenceryAddress = @dis_Address,
   				mother_name=@mother_name,
   				Emp_Dress_Code = @Dress_Code, -- Added By Ali 25032014
   				Emp_Shirt_Size = @Shirt_Size, -- Added By Ali 25032014
   				Emp_Pent_Size = @Pent_Size,   -- Added By Ali 25032014
   				Emp_Shoe_Size = @Shoe_Size,	  -- Added By Ali 25032014
   				Emp_Canteen_Code = @Canteen_Code, -- Added By Ali 01042014
   				Aadhar_card_no = @Aadhar_Card_No,  --Added By Ramiz on 07/08/2015
   				Vehicle_NO = @Vehicle_No,   --added jimit 08082015
   				Ration_Card_Type = @RationCardType,		 --added jimit 05032016
   				Ration_Card_No = @RationCardNo,		     --added jimit 05032016   					
   				Actual_Date_Of_Birth = @ActualBirthDate,  --added jimit 05032016
   				Extension_No=@Extension_No , --Mukti(23042016)
   				LinkedIn_ID = @LinkedIn_Id , Twitter_ID = @Twitter_ID,
   				System_Date = GETDATE()
				,Emp_Cast_Join = @Cast_Join

				 
				 ---------------Added by ronakk 30052022 -----------------------------------------
				
				,Emp_Fav_Sport_id = @EmpFavSportID
				,Emp_Fav_Sport_Name = @EmpFavSportName
				,Emp_Hobby_id = @EmpHobbyID
				,Emp_Hobby_Name = @EmpHobbyName
				,Emp_Fav_Food = @EmpFavFood
				,Emp_Fav_Restro = @EmpFavRestro
				,Emp_Fav_Trv_Destination = @EmpFavTrvDestination
				,Emp_Fav_Festival = @EmpFavFestival
				,Emp_Fav_SportPerson = @EmpFavSportPerson
				,Emp_Fav_Singer = @EmpFavSinger 

				---------------End by ronakk 30052022 -----------------------------------------



			WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
   				
   			UPDATE    dbo.T0095_INCREMENT
   			SET Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical
										WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID

			exec P9999_Audit_get @table = 'T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID ,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
   		End
	
	else if @tran_type = 'C'
			Begin
				exec P9999_Audit_get @table='T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))

				    Update dbo.T0080_EMP_MASTER 
				SET  Street_1 = @Street_1,
					City = @City,
					State = @State,
					Zip_code = @Zip_code,
					Loc_ID = @Loc_ID,
					Home_Tel_no = @Home_Tel_no,
					Nationality = @Nationality,
					Work_Tel_No = @Work_Tel_No,
					Mobile_No = @Mobile_No,
					Present_Street = @Present_Street,
					Present_City = @Present_City,
					Present_State = @Present_State,
					Present_Post_Box = @Present_Post_Box,
					Login_id = @Login_Id
					,Thana_Id = @Thana_Id 				-- Added By Ali 03042014
					,Tehsil =  @Tehsil 					-- Added By Ali 03042014
					,District= @District				-- Added By Ali 03042014	
					,Thana_Id_Wok = @Thana_Id_Wok		-- Added By Ali 03042014
					,Tehsil_Wok = @Tehsil_Wok			-- Added By Ali 03042014
					,District_Wok = @District_Wok		-- Added By Ali 03042014
					,Extension_No=@Extension_No  --Mukti(23042016)
					,System_Date = GETDATE()
				WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID	
					
				exec P9999_Audit_get @table = 'T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID ,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))					
			End
			exec P9999_Audit_Trail @Cmp_ID,'U','Employee Profile',@OldValue,@Emp_ID,@Login_Id,'',@is_Emp=1
	RETURN




