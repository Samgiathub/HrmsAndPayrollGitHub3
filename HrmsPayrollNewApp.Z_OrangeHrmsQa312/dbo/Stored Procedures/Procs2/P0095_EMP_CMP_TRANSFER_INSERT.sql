

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[P0095_EMP_CMP_TRANSFER_INSERT]
	@Tran_Id		numeric(18,0) output
   ,@Emp_ID			numeric(18,0) output
   ,@Curr_Emp_ID	numeric(18,0)
   ,@Cmp_ID			numeric(18,0)
   ,@Curr_Cmp_ID	numeric(18,0)
   ,@Branch_ID		numeric(18,0)
   ,@Cat_ID			numeric(18,0)
   ,@Grd_ID			numeric(18,0)
   ,@Dept_ID		numeric(18,0)
   ,@Desig_Id		numeric(18,0)
   ,@Type_ID		numeric(18,0)
   ,@Shift_ID		numeric(18,0)
   ,@Increment_Effective_Date dateTime
   ,@Emp_Superior   numeric(18)
   ,@Client_Id		numeric(18,0) = 0	--Client ID as Vertical ID
   ,@Increment_ID	numeric(18,0) output
   ,@Basic_Salary	numeric(18, 2)
   ,@Gross_Salary	numeric(18, 2)
   ,@CTC			Numeric(18, 2) = 0
   ,@Old_Weekoff_Day	Varchar(100)
   ,@New_Weekoff_Day	Varchar(100) 
   ,@New_Privilege	Numeric(18,0)
   ,@tran_type		char(1)
   ,@New_SubVertical_ID	Numeric(18,0)
   ,@New_Segment_ID		Numeric(18,0)
   ,@New_SubBranch_ID	Numeric(18,0)
   ,@New_Login_Alias	varchar(100) = ''
   ,@Old_Login_Alias	varchar(100) = ''
   ,@New_SalCycle_id	numeric = 0
   ,@Is_MultiPage_Flag	Numeric(18,0) = 0
   ,@ReplaceManager     Numeric(18,0) = 0 --added jimit 29122015
   ,@ReplaceManager_Cmp_ID Numeric(18,0) = 0  --Mukti(29072016)
AS	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Old_Branch_ID		numeric(18,0)
	Declare @Old_Cat_ID			numeric(18,0)
	Declare @Old_Grd_ID			numeric(18,0)
	Declare @Old_Dept_ID		numeric(18,0)
	Declare @Old_Desig_Id		numeric(18,0)
	Declare @Old_Type_ID		numeric(18,0)
	Declare @Old_Shift_ID		numeric(18,0)
	Declare @Old_Increment_Effective_Date dateTime
	Declare @Old_Emp_Superior	numeric(18)
	--Declare @Old_Client_Id		numeric(18,0) 
	Declare @Old_Basic_Salary	numeric(18,2)
	Declare @Old_Gross_salary	numeric(22,2) 
	Declare @Old_Ref_No Varchar(50) 
	Declare @Old_CTC Numeric(18,0)
	Declare @Emp_PT_Amount numeric(18,2)
	Declare @Old_Privilege_ID	Numeric(18,0 )
	declare @Bank_ID		numeric(18,0)
	declare @Emp_code		numeric(18,0)
	declare @Initial		varchar(10)
	declare @Emp_First_Name varchar(100)
	declare @Emp_Second_Name varchar(100)
	declare @Emp_Last_Name	varchar(100)
	declare @Curr_ID		numeric(18,0)
	declare @Date_Of_Join	datetime
	declare @SSN_No			varchar(30)
	declare @SIN_No			varchar(30)
	declare @Dr_Lic_No		varchar(30)
	declare @Pan_No			varchar(30)
	declare @Date_Of_Birth  DATETIME 
	declare @Marital_Status varchar(20)
	declare @Gender			char(1)
	declare @Dr_Lic_Ex_Date DATETIME 
	declare @Nationality	varchar(20)
	declare @Loc_ID			numeric(18,0)
	declare @Street_1		varchar(250)
	declare @City			varchar(30)
	declare @State			varchar(20)
	declare @Zip_code		varchar(20)
	declare @Home_Tel_no	varchar(30)
	declare @Mobile_No		varchar(30)
	declare @Work_Tel_No	varchar(30)
	declare @Work_Email		varchar(50)
	declare @Other_Email	varchar(50)
	declare @Present_Street varchar(250)
	declare @Present_City   varchar(30)
	declare @Present_State  varchar(30)
	declare @Present_Post_Box varchar(20)
	declare @Image_Name		varchar(100)
	declare @Wages_Type		varchar(10)
	declare @Salary_Basis_On varchar(10)
	declare @Payment_Mode	varchar(20)
	declare @Inc_Bank_AC_No	varchar(20)
	declare @Emp_OT			numeric(18)
	declare @Emp_OT_Min_Limit	varchar(10)
	declare @Emp_OT_Max_Limit	varchar(10)
	declare @Emp_Late_mark	Numeric(18)
	declare @Emp_Full_PF	Numeric(18)
	declare @Emp_PT			Numeric(18)
	declare @Emp_Fix_Salary	Numeric(18)
	declare @Tall_Led_Name varchar(250)
	declare @Religion varchar(50)
	declare @Height  varchar(50)
	declare @Mark_Of_Idetification varchar(250)
	declare @Dispencery varchar(50)
	declare @Doctor_name varchar(100)
	declare @DispenceryAdd varchar(250)
	declare @Insurance_No varchar(50)
	declare @Is_Gr_App tinyint
	declare @Is_Yearly_Bonus numeric(5, 2)
	declare @Yearly_Leave_Days numeric(7, 2)
	declare @Yearly_Leave_Amount numeric(7, 2)
	declare @Yearly_Bonus_Per numeric(5, 2)
	declare @Yearly_Bonus_Amount numeric(7, 2)
	declare @Emp_Late_Limit varchar(10)
	declare @Late_Dedu_Type varchar(10)
	declare @Emp_Part_Time  numeric(10)
	declare @Emp_Confirmation_date dateTime
	declare @Is_On_Probation numeric(1,0)
	declare @Tally_Led_ID numeric(18,0)
	declare @Blood_Group varchar(10)
	declare @Probation numeric(5,2)
	declare @enroll_No numeric(18,0)
	declare @Dep_Reminder tinyint 
	declare @Adult_NO numeric(18,0)  
	declare @Father_Name varchar(100)
	declare @Bank_BSR_No varchar(100)
	declare @Login_Id int 
	declare @Alpha_Code varchar(10)  
	declare @Chg_Pwd int  
	declare @Ifsc_Code Varchar(50) 
	declare @Leave_In_Probation As TinyInt 
	Declare @Is_LWF As tinyInt 
	Declare @Emp_Early_mark	numeric(1, 0)  
	Declare @Early_Dedu_Type	varchar(10) 
	Declare @Emp_Early_Limit	varchar(10) 
	Declare @Emp_Deficit_mark	numeric(1, 0) 
	Declare @Deficit_Dedu_Type	varchar(10)	 
	Declare @Emp_Deficit_Limit	varchar(10) 
	Declare @Center_ID numeric(18,0) 
	Declare @DBRD_Code varchar(50)
	Declare @Dealer_Code varchar(50)
	Declare @CCenter_Remark varchar(500)
	Declare @Emp_wd_ot_rate numeric(5,1) 
	Declare @Emp_wo_ot_rate numeric(5,1)  
	Declare @Emp_ho_ot_rate numeric(5,1) 
	Declare @Emp_PF_Opening numeric(18,2)  
	Declare @Emp_Category	varchar(50) 
	Declare @Emp_UIDNo	varchar(25)	       
	Declare @Emp_Cast	varchar(50)	       
	Declare @Emp_Anniversary_Date Varchar(25)  
	Declare @Extra_AB_Deduction	numeric(18,2) 
	Declare @Min_CompOff_Limit varchar(10) 
	Declare @mother_name varchar(100) 
	Declare @no_of_chlidren numeric  
	Declare @is_metro tinyint 
	Declare @is_physical tinyint 
	Declare @Min_Wages numeric(18,2)   
	Declare @Emp_Offer_date dateTime
	Declare @Login_Alias varchar(100) 
	Declare @Old_Salary_Cycle_id numeric 
	Declare @Auto_vpf numeric(18) 
	Declare @Old_Segment_ID numeric   
	Declare @Old_Vertical_ID numeric  
	Declare @Old_SubVertical_ID numeric 
	Declare @GroupJoiningDate datetime  
	Declare @Old_subBranch_ID numeric   
	Declare @Monthly_Deficit_Adjust_OT_Hrs tinyint 
	Declare @Fix_OT_Hour_Rate_WD numeric(18,3) 	 
	Declare @Fix_OT_Hour_Rate_WO_HO numeric(18,3) 
	Declare @Bank_ID_Two numeric(18,2)				 
	Declare @Payment_Mode_Two varchar(20) 		 
	Declare @Inc_Bank_AC_No_Two varchar(20)		 
	Declare @Bank_Branch_Name varchar(50) 		 
	Declare @Bank_Branch_Name_Two varchar(50) 	 
	Declare @Ifsc_Code_Two varchar(50)			 
	Declare @Code_Date_Format varchar(20) 
	Declare @Code_Date varchar(20) 
	Declare @EmpName_Alias_PrimaryBank varchar(100) 
	Declare @EmpName_Alias_SecondaryBank varchar(100) 
	Declare @EmpName_Alias_PF varchar(100) 
	Declare @EmpName_Alias_PT varchar(100) 
	Declare @EmpName_Alias_Tax varchar(100) 
	Declare @EmpName_Alias_ESIC varchar(100) 
	Declare @EmpName_Alias_Salary varchar(100) 
	Declare @Emp_Notice_Period numeric(18,0) 
	Declare @Emp_Full_Name as varchar(250)
	Declare @Tally_Led_Name as varchar(250)
	declare @Emp_Childran as numeric(18,0)
	Declare @Alpha_Emp_Code as varchar(50)
	Declare @Comp_offlimit as varchar(10)
	DECLARE @UAN_No AS VARCHAR(100)					--added jimit 17112015
	DECLARE	@Date_Of_Retirenment AS  DATETIME		--added jimit 17112015
	DECLARE @Emp_Dress_Code AS VARCHAR(50)			--added jimit 17112015
	DECLARE @Emp_Shirt_Size AS VARCHAR(20)			--added jimit 17112015
	DECLARE @Emp_Pent_Size AS VARCHAR(20)			--added jimit 17112015
	DECLARE @Emp_Shoe_Size AS VARCHAR(20)			--added jimit 17112015
	DECLARE @Emp_Canteen_Code AS VARCHAR(50)		--added jimit 17112015
	DECLARE @Vehicle_No AS VARCHAR(50)				--added jimit 17112015
	DECLARE @Aadhar_Card_No AS VARCHAR(50)			--added jimit 17112015
	DECLARE @Ration_Card_No AS VARCHAR(50)			--added jimit 17112015
	DECLARE @Ration_Card_Type AS VARCHAR(10) -- Added By Niraj(02022022)
	DECLARE @Extension_No AS VARCHAR(10) -- Added By Niraj(02022022)
	DECLARE @Actual_Date_Of_Birth AS DATETIME		--added jimit 17112015
	DECLARE @Tehsil	As Varchar(50)					--added jimit 17112015
	DECLARE @Tehsil_Work	As Varchar(50)			--added jimit 17112015
	DECLARE @District	As Varchar(50)				--added jimit 17112015
	DECLARE @District_Work	As Varchar(50)			--added jimit 17112015
	DECLARE @Thana	As NUMERIC						--added jimit 17112015
	DECLARE @Thana_Work	As NUMERIC					--added jimit 17112015
	DECLARE @CompOff_HO_App_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @CompOff_HO_Avail_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @CompOff_WO_App_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @CompOff_WO_Avail_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @CompOff_WD_App_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @CompOff_WD_Avail_Days As NUMERIC(18,2)	--added jimit 17112015
	DECLARE @Yearly_Bonus_Amt AS NUMERIC(7,0)    --Added jimit 19112015
	
	DECLARE @Reason_ID			as numeric(5,0)	--added by Krushna 20-07-2018
	DECLARE @Reason_Name		as varchar(200)	--added by Krushna 20-07-2018
	DECLARE @User_Id			as numeric(18,0)--added by Krushna 20-07-2018
	DECLARE @IP_Address			as varchar(30)	--added by Krushna 20-07-2018
	DECLARE @Customer_Audit		as tinyint		--added by Krushna 20-07-2018
	DECLARE @Sales_Code			as VARCHAR(20)	--added by Krushna 20-07-2018
	DECLARE @Physical_Percent	as NUMERIC(18,2)--added by Krushna 05-07-2018
	---added by aswini 
	declare @is_on_training as numeric(2, 0)
	declare @Is_Piece_Trans_Salary as  tinyint
	declare @Is_1time_PF_Member  as bit
	declare @Is_Pradhan_Mantri as bit
	---added by aswini 
	set @Is_Pradhan_Mantri =0   
	set @Is_1time_PF_Member = 0
	set @Is_Piece_Trans_Salary = 0
	set @is_on_training =0
	---
    set @Emp_Childran = 0
	set @Emp_Full_Name = ''
	set @Old_Privilege_ID = 0
	Set @Old_Branch_ID = 0
	Set @Old_Cat_ID	 = 0
	Set @Old_Grd_ID = 0
	Set @Old_Dept_ID = 0
	Set @Old_Desig_Id = 0
	Set @Old_Type_ID = 0
	Set @Old_Shift_ID = 0
	Set @Old_Emp_Superior = 0
	--Set @Old_Client_Id	 = 0
	Set @Old_Basic_Salary = 0
	Set @Old_Gross_salary = 0
	Set @Old_Ref_No =NULL
	Set @Old_CTC  = 0
    Set @Bank_ID	 = 0
	Set @Emp_code		 = 0
	Set @Initial	  = ''
	Set @Emp_First_Name  = ''
	Set @Emp_Second_Name   = ''
	Set @Emp_Last_Name	  = ''
	Set @Curr_ID		 = 0
	Set @SSN_No			  = ''
	Set @SIN_No			  = ''
	Set @Dr_Lic_No		  = ''
	Set @Pan_No			  = ''
	Set @Date_Of_Birth  = null
	Set @Marital_Status  = ''
	Set @Gender			  = ''
	Set @Dr_Lic_Ex_Date   = NULL
	Set @Nationality	  = ''
	Set @Loc_ID			 = 0
	Set @Street_1		  = ''
	Set @City			  = ''
	Set @State			  = ''
	Set @Zip_code		  = ''
	Set @Home_Tel_no	  = ''
	Set @Mobile_No		  = ''
	Set @Work_Tel_No	  = ''
	Set @Work_Email		  = ''
	Set @Other_Email	  = ''
	Set @Present_Street  = ''
	Set @Present_City    = ''
	Set @Present_State    = ''
	Set @Present_Post_Box  = ''
	Set @Image_Name		  = ''
	Set @Wages_Type		  = ''
	Set @Salary_Basis_On   = ''
	Set @Payment_Mode	  = ''
	Set @Inc_Bank_AC_No	  = ''
	Set @Emp_OT			 = 0
	Set @Emp_OT_Min_Limit	  = ''
	Set @Emp_OT_Max_Limit	  = ''
	Set @Emp_Late_mark	 = 0
	Set @Emp_Full_PF	 = 0
	Set @Emp_PT			 = 0
	Set @Emp_Fix_Salary	 = 0
	--Set @tran_type		  = ''
	Set @Tall_Led_Name   = ''
	Set @Religion   = ''
	Set @Height    = ''
	Set @Mark_Of_Idetification   = ''
	Set @Dispencery   = ''
	Set @Doctor_name   = ''
	Set @DispenceryAdd   = ''
	Set @Insurance_No   = ''
	Set @Is_Gr_App  = 0
	Set @Is_Yearly_Bonus  = 0
	Set @Yearly_Leave_Days  = 0
	Set @Yearly_Leave_Amount  = 0
	Set @Yearly_Bonus_Per  = 0
	Set @Yearly_Bonus_Amount  = 0
	Set @Emp_Late_Limit   = ''
	Set @Late_Dedu_Type   = ''
	Set @Emp_Part_Time   = 0
	Set @Is_On_Probation  = 0
	Set @Tally_Led_ID  = 0
	Set @Blood_Group   = ''
	Set @Probation  = 0
	Set @enroll_No  = 0
	Set @Dep_Reminder =1
	Set @Adult_NO  = 0
	Set @Father_Name   = ''
	Set @Bank_BSR_No   = ''
	Set @Old_Ref_No =NULL
	Set @Login_Id  = 0
	Set @Alpha_Code   = ''
	Set @Chg_Pwd  = 0 
	Set @Ifsc_Code  =NULL
	Set @Leave_In_Probation  =0
	Set @Is_LWF   = 0
	Set @Emp_Early_mark	  = 0
	Set @Early_Dedu_Type	= ''
	Set @Emp_Early_Limit 	= '00:00'
	Set @Emp_Deficit_mark	 = 0
	Set @Deficit_Dedu_Type 	 = ''
	Set @Emp_Deficit_Limit	 	= ''
	Set @Center_ID  = 0
	Set @DBRD_Code   = ''
	Set @Dealer_Code   = ''
	Set @CCenter_Remark   = ''
	Set @Emp_wd_ot_rate  = 0
	Set @Emp_wo_ot_rate = 0
	Set @Emp_ho_ot_rate   = 0
	Set @Emp_PF_Opening  = 0
	Set @Emp_Category	 	= ''   
	Set @Emp_UIDNo	 	= ''       
	Set @Emp_Cast	 	= ''       
	Set @Emp_Anniversary_Date  = '' 
	Set @Extra_AB_Deduction	  = 0.0
	Set @Min_CompOff_Limit = '00:00'
	Set @mother_name   = ''
	Set @no_of_chlidren   =  0
	Set @is_metro   = 0
	Set @is_physical   = 0
	Set @Min_Wages    = 0  
	Set @Login_Alias   = ''
	Set @Old_Salary_Cycle_id   = 0
	Set @Auto_vpf    = 0
	Set @Old_Segment_ID   = 0  
	Set @Old_Vertical_ID   =0	 
	Set @Old_SubVertical_ID   =0  
	Set @GroupJoiningDate   = Null  
	Set @Old_subBranch_ID   = 0  
	Set @Monthly_Deficit_Adjust_OT_Hrs   =0   
	Set @Fix_OT_Hour_Rate_WD   =0		 
	Set @Fix_OT_Hour_Rate_WO_HO  =0		 
	Set @Bank_ID_Two  	= 0			 
	Set @Payment_Mode_Two   = ''		 
	Set @Inc_Bank_AC_No_Two  	= ''	 
	Set @Bank_Branch_Name   = ''		 
	Set @Bank_Branch_Name_Two   = ''	 
	Set @Ifsc_Code_Two  	= ''		 
	Set @Code_Date_Format  = ''
	Set @Code_Date   = ''
	Set @EmpName_Alias_PrimaryBank   = ''
	Set @EmpName_Alias_SecondaryBank   = ''
	Set @EmpName_Alias_PF   = ''
	Set @EmpName_Alias_PT   = ''
	Set @EmpName_Alias_Tax   = ''
	Set @EmpName_Alias_ESIC  = ''
	Set @EmpName_Alias_Salary   = ''
	Set @Emp_Notice_Period   = 0
	set @Tally_Led_Name = ''
	SET @UAN_No = ''				--added jimit 17112015
	SET @Date_Of_Retirenment = ''	--added jimit 17112015
	SET @Emp_Dress_Code = ''		--added jimit 17112015
	SET @Emp_Shirt_Size = ''		--added jimit 17112015
	SEt @Emp_Pent_Size = ''			--added jimit 17112015
	SET @Emp_Shoe_Size = ''			--added jimit 17112015
	SET @Emp_Canteen_Code = ''		--added jimit 17112015
	SET @Vehicle_No = ''			--added jimit 17112015
	SET @Aadhar_Card_No = ''		--added jimit 17112015
	SET @Ration_Card_No = ''		--added jimit 17112015
	SET @Ration_Card_Type = ''		--added by Niraj(02022022)
	SET @Extension_No = ''		--added by Niraj(02022022)
	SET @Actual_Date_Of_Birth = ''	--added jimit 17112015
	SET @Tehsil = ''				--added jimit 17112015
	SET @Tehsil_Work = ''			--added jimit 17112015
	SET @District	= ''			--added jimit 17112015
	SET @District_Work = ''			--added jimit 17112015
	SET @Thana	= 0					--added jimit 17112015
	SET @Thana_Work	= 0				--added jimit 17112015
	SET @CompOff_HO_App_Days = 0	--added jimit 17112015
	SET @CompOff_HO_Avail_Days = 0	--added jimit 17112015
	SET @CompOff_WO_App_Days = 0	--added jimit 17112015
	SET @CompOff_WO_Avail_Days = 0	--added jimit 17112015
	SET @CompOff_WD_App_Days = 0	--added jimit 17112015
	SET @CompOff_WD_Avail_Days = 0	--added jimit 17112015
	SET	@Yearly_Bonus_Amt = 0		--added jimit 17112015
	SET	@Reason_ID			= 0		--added by Krushna 20-07-2018
	SET	@Reason_Name		= ''	--added by Krushna 20-07-2018
	SET	@User_Id			= 0		--added by Krushna 20-07-2018
	SET	@IP_Address			= ''	--added by Krushna 20-07-2018
	SET	@Customer_Audit		= 0		--added by Krushna 20-07-2018	
	SET	@Sales_Code			= ''	--added by Krushna 20-07-2018
	SET	@Physical_Percent	= 0		--added by Krushna 20-07-2018
	
	SELECT      @Emp_code = Emp_code, @Initial = Initial, @Emp_First_Name = Emp_First_Name, @Emp_Second_Name = Emp_Second_Name, 
                      @Emp_Last_Name = Emp_Last_Name, @Curr_ID = Curr_ID, @Date_Of_Join = Date_Of_Join, @SSN_No = SSN_No, @SIN_No = SIN_No, @Dr_Lic_No= Dr_Lic_No, @Pan_No =Pan_No, @Date_Of_Birth = Date_Of_Birth, @Marital_Status = Marital_Status, @Gender = Gender, @Dr_Lic_Ex_Date = Dr_Lic_Ex_Date, 
                      @Nationality = Nationality, @Loc_ID = Loc_ID, 
                      @Street_1 = Street_1, @City= City, @State = State, @Zip_code = Zip_code , @Home_Tel_no = Home_Tel_no, @Mobile_No = Mobile_No, @Work_Tel_No = Work_Tel_No, @Work_Email = Work_Email, @Other_Email = Other_Email,
                      @Image_Name = Image_Name, @Emp_Full_Name = Emp_Full_Name , 
                      @Present_Street = Present_Street, @Present_City = Present_City, @Present_State = Present_State, @Present_Post_Box = Present_Post_Box, @Old_Emp_Superior = Emp_Superior, @Blood_Group= Blood_Group, @Tally_Led_Name = Tally_Led_Name, @Religion = Religion, 
                      @Height = Height , @Doctor_Name = Doctor_Name , @Insurance_No = Insurance_No, @Is_Gr_App = Is_Gr_App, @Is_Yearly_Bonus = Is_Yearly_Bonus, @Yearly_Leave_Days = Yearly_Leave_Days, 
                      @Yearly_Leave_Amount = Yearly_Leave_Amount, @Yearly_Bonus_Per = Yearly_Bonus_Per, @Emp_Confirmation_date = Emp_Confirm_Date , @Is_On_Probation = Is_On_Probation, @Tally_Led_ID = Tally_Led_ID, @Login_ID = Login_ID ,
                      @Probation = Probation, @Adult_No = Worker_Adult_No, @Father_name = Father_name, @Bank_BSR_No = Bank_BSR , @Old_Ref_No = Old_Ref_No, @Chg_Pwd = Chg_Pwd, @Alpha_Code = Alpha_Code , @Ifsc_Code = Ifsc_Code, @Leave_In_Probation = Leave_In_Probation, 
                      @Is_LWF = Is_LWF, @DBRD_Code = DBRD_Code, @Dealer_Code = Dealer_Code, @CCenter_Remark = CCenter_Remark, @Emp_PF_Opening = Emp_PF_Opening, @Emp_Category= Emp_Category, @Emp_UIDNo = Emp_UIDNo, @Emp_Cast = Emp_Cast, @Emp_Anniversary_Date = Emp_Annivarsary_Date, @Extra_AB_Deduction = Extra_AB_Deduction, 
                      @Min_CompOff_Limit = CompOff_Min_hrs, @mother_name = mother_name, @Min_Wages = Min_Wages, @Emp_Offer_Date = Emp_Offer_Date, @Old_Segment_ID = Segment_ID, @Old_Vertical_ID = isnull(Vertical_ID,0), @Old_SubVertical_ID =SubVertical_ID, @GroupJoiningDate = ISNULL(GroupJoiningDate,''), @Old_subBranch_ID=subBranch_ID, @Bank_ID_Two = Bank_ID_Two, 
                      @Ifsc_Code_Two = Ifsc_Code_Two, @Code_Date_Format = Code_Date_Format, @Code_Date = Code_Date, @EmpName_Alias_PrimaryBank = EmpName_Alias_PrimaryBank, @EmpName_Alias_SecondaryBank = EmpName_Alias_SecondaryBank, @EmpName_Alias_PF = EmpName_Alias_PF, @EmpName_Alias_PT = EmpName_Alias_PT, 
                      @EmpName_Alias_Tax= EmpName_Alias_Tax, @EmpName_Alias_ESIC = EmpName_Alias_ESIC, @EmpName_Alias_Salary = EmpName_Alias_Salary, @Emp_Notice_Period = Emp_Notice_Period  , @Old_Shift_ID = Shift_ID,@Alpha_Emp_Code = Alpha_Emp_Code, @Mark_Of_Idetification = Emp_Mark_Of_Identification,
                      @Dispencery = Despencery, @DispenceryAdd = DespenceryAddress , @Doctor_name =Doctor_Name,
                      @Comp_offlimit = CompOff_Min_hrs
                      ,@UAN_No = UAN_No,@Date_Of_Retirenment = Date_of_Retirement,
                      @Emp_Dress_Code = Emp_Dress_Code,@Emp_Shirt_Size = Emp_Shirt_Size,@Emp_Pent_Size = Emp_Pent_Size,@Emp_Shoe_Size= Emp_Shoe_Size,
                      @Emp_Canteen_Code = Emp_Canteen_Code,@Vehicle_No = Vehicle_NO,@Aadhar_Card_No = Aadhar_Card_No,
                      @Ration_Card_No = Ration_Card_No,@Ration_Card_Type = Ration_Card_Type,@Extension_No = Extension_No, -- Added By Niraj(02022022)
					  @Actual_Date_Of_Birth = Actual_Date_Of_Birth,
                      @Tehsil = Tehsil,@Tehsil_Work = Tehsil_Wok,@District = District,@District_Work = District_Wok,
                      @Thana = isnull(Thana_Id,0), @Thana_Work = isnull(Thana_Id_Wok,0),@enroll_No = Enroll_No
                      ,@CompOff_HO_App_Days = ISNULL(CompOff_HO_App_Days,0),@CompOff_HO_Avail_Days = ISNULL(CompOff_HO_Avail_Days,0),
                      @CompOff_WO_App_Days = ISNULL(CompOff_WO_App_Days,0),@CompOff_WO_Avail_Days =ISNULL(CompOff_WO_Avail_Days,0),
                      @CompOff_WD_App_Days = ISNULL(CompOff_WD_App_Days,0),@CompOff_WD_Avail_Days = Isnull(CompOff_WD_Avail_Days,0)
                      ,@Yearly_Bonus_Amt = Yearly_Bonus_Amount
	FROM         T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID =@Curr_Cmp_ID And Emp_ID=@Curr_Emp_ID
   
  
	SELECT    @Old_Branch_ID = Branch_ID, @Old_Cat_ID =Isnull(Cat_ID,0), @Old_Grd_ID = Grd_ID, @old_Dept_ID = isnull(Dept_ID,0), @old_Desig_Id = isnull(Desig_Id,0), @old_Type_ID = isnull(Type_ID,0), @Bank_ID = Bank_ID, @Curr_ID = Curr_ID, @Wages_Type = Wages_Type, @Salary_Basis_On = Salary_Basis_On, @Old_Basic_Salary= isnull(Basic_Salary,0), 
			  @Old_Gross_Salary = isnull(Gross_Salary,0) , @Payment_Mode = Payment_Mode, @Inc_Bank_AC_No = Inc_Bank_AC_No, @Emp_OT= Emp_OT, @Emp_OT_Min_Limit = Emp_OT_Min_Limit, @Emp_OT_Max_Limit =Emp_OT_Max_Limit, 
			  @Emp_Late_mark = Emp_Late_mark, @Emp_Full_PF = Emp_Full_PF, @Emp_PT =Emp_PT, @Emp_Fix_Salary =Emp_Fix_Salary, 
			  @Emp_Part_Time = Emp_Part_Time, @Late_Dedu_Type = Late_Dedu_Type, @Emp_Late_Limit = Emp_Late_Limit, @Emp_PT_Amount= Emp_PT_Amount, @no_of_chlidren =Emp_Childran , @Yearly_Bonus_Amount= Yearly_Bonus_Amount, 
			  @Old_CTC= isnull(CTC,0), @Emp_Early_mark= Emp_Early_mark, @Early_Dedu_Type= Early_Dedu_Type, @Emp_Early_Limit=Emp_Early_Limit, @Emp_Deficit_mark=Emp_Deficit_mark, @Deficit_Dedu_Type=Deficit_Dedu_Type, 
			  @Emp_Deficit_Limit=Emp_Deficit_Limit, @Emp_wd_ot_rate=Emp_WeekDay_OT_Rate, @Emp_wo_ot_rate=Emp_WeekOff_OT_Rate, @Emp_ho_ot_rate=Emp_Holiday_OT_Rate, @Is_Metro =Is_Metro_City  , 
			  @is_physical=is_physical, @Old_Salary_Cycle_id=SalDate_id, @Auto_vpf=Emp_Auto_Vpf,-- @Segment_ID=Segment_ID, @Vertical_ID=Vertical_ID, @SubVertical_ID=SubVertical_ID, @subBranch_ID=subBranch_ID, 
			  @Monthly_Deficit_Adjust_OT_Hrs=Monthly_Deficit_Adjust_OT_Hrs, @Fix_OT_Hour_Rate_WD=Fix_OT_Hour_Rate_WD, @Fix_OT_Hour_Rate_WO_HO=Fix_OT_Hour_Rate_WO_HO, @Bank_ID_Two=Bank_ID_Two, @Payment_Mode_Two=Payment_Mode_Two, @Inc_Bank_AC_No_Two=Inc_Bank_AC_No_Two, 
			  @Bank_Branch_Name=Bank_Branch_Name, @Bank_Branch_Name_Two=Bank_Branch_Name_Two
			  ,@Reason_ID = Reason_ID
			  ,@Reason_Name = Reason_Name
			  ,@Customer_Audit = Customer_Audit
			  ,@Physical_Percent = Physical_Percent
	FROM      T0095_INCREMENT WITH (NOLOCK)
	Where	  Emp_ID = @Curr_Emp_ID And Cmp_ID = @Curr_Cmp_ID 
			  And Increment_ID = (Select MAX(Increment_ID) As Increment_ID From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Curr_Emp_ID And Cmp_ID = @Curr_Cmp_ID ) -- Ankit 11092014 for Same Date Increment
	
	Declare @Old_Login_Id Numeric
	Declare @Old_Password_ID varchar(500) 
		
	Set @Old_Login_Id = 0	
	select @Old_Login_Id = Login_ID,@Old_Password_ID = (Case When Login_Password <> '' THEN Login_Password Else 'VuMs/PGYS74=' END)  From T0011_LOGIN WITH (NOLOCK)
		Where Emp_ID = @Curr_Emp_ID And Effective_Date = (select MAX(Effective_Date) From T0011_LOGIN WITH (NOLOCK) where Emp_ID = @Curr_Emp_ID)

	select @Old_Privilege_ID = Privilege_Id From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
		Where Login_Id = @Old_Login_Id And From_Date = (select MAX (From_Date) From T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) where Login_Id = @Old_Login_Id)

	Set @Date_Of_Join = @Increment_Effective_Date
	
	IF @GroupJoiningDate IS NULL or @GroupJoiningDate = ''
		Set @GroupJoiningDate = @Increment_Effective_Date
		
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null 
	if @Desig_Id = 0
		set @Desig_Id = null
	if @Type_ID =0
		set @Type_ID= null
	if @Loc_ID =0
		set @Loc_ID = null
	if @Curr_ID =0
		set @Curr_ID = null
	if @Bank_ID =0
		set @Bank_ID = null
	-- Added By Ali 14112013 -- Start
	if @Bank_ID_Two =0
		set @Bank_ID_Two = null
	-- Added By Ali 14112013 -- End
	--if @Basic_Salary =0 
	--	set @Basic_Salary = 0
	if  @Tally_Led_ID	 = 0
		set @Tally_Led_ID	=null
	if @Date_Of_Birth =  ''
		set  @Date_Of_Birth = null
	if @Dr_Lic_Ex_Date = ''
		set @Dr_Lic_Ex_Date = null
	if @Wages_Type = ''
		set @Wages_Type= 'Monthly'
	if @Salary_Basis_On =''
		set @Salary_Basis_On ='Day'
	if @Payment_Mode =''
		set @Payment_Mode= 'Cash'
	if @Inc_Bank_AC_No = ''
		set @Inc_Bank_AC_No = NULL
	if isnull(@Emp_OT_Min_Limit,'') = ''
		set @Emp_OT_Min_Limit = '00:00'
	if isnull(@Emp_OT_Max_Limit,'') = ''
		set @Emp_OT_Max_Limit = '00:00'
	if @Emp_Superior = 0 
		set @Emp_Superior =NULL	
	if @Emp_Confirmation_date = '' 
	  set	@Emp_Confirmation_date=null
	if @Emp_Offer_date = '' 
	  set	@Emp_Offer_date=null
	if @Increment_ID= 0	
		set @Increment_ID= null
	if @Image_Name = ''
		set @Image_Name = '0.jpg'	
	If @Alpha_Code=''
		Set @Alpha_Code = NULL 	
	if @New_Segment_ID = 0
		set @New_Segment_ID = null
	--if @Vertical_ID = 0 
	--	set @Vertical_ID = null
	if @New_SubVertical_ID = 0 
		set @New_SubVertical_ID = null
	if @GroupJoiningDate = ''
		set @GroupJoiningDate = Null
	if @New_SubBranch_ID = 0 
		set @New_SubBranch_ID = Null
	IF @New_SalCycle_id = 0
		Set @New_SalCycle_id = Null
		
	declare @Get_Emp_code  as varchar(40)		--Added BY GAdriwala 18112013
	declare @Get_Alpha_code  as varchar(40)		--Added BY GAdriwala 18112013
	--Declare @Emp_Full_Name as varchar(250)
	Declare @loginname as varchar(50)
	Declare @Domain_Name as varchar(50)
	Declare @old_Join_Date as datetime 
	Declare @Default_Weekof as varchar(50)	
	Declare @IS_OT As Numeric(18)
	Declare @IS_PT As Numeric(18)
	Declare @IS_PF As Numeric(18)
	Declare @IS_LATE_MARK As Numeric(18)
	declare @G_FOR_DATE as DATETIME	
	Declare @For_Date as DateTime
	Declare @Add_Initial_In_Emp_Full_Name  nvarchar (1)
		
	
	--set @Get_Emp_code = ''	--Added BY GAdriwala 18112013
	--set @Get_Alpha_code = '' --Added BY GAdriwala 18112013
	
	--If @Emp_Code =0 
	--	Begin
	--		--select @Emp_code = isnull(max(Emp_Code),0) + 1 from dbo.T0080_EMP_MASTER WHERE CMP_ID =@CMP_ID
	--		exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1
	--		set @Emp_code = cast(@Get_Emp_code as numeric)
		
	--	end
		
	--if @Alpha_Code = ''
	--begin
	--	set @Alpha_Code = @Get_Alpha_code
	--end
	
	Declare @Cmp_Code as varchar(5)
	Declare @Branch_Code as varchar(10)
	DECLARE @Is_Auto_Alpha_Numeric_Code TINYINT
	Declare @No_Of_Digits numeric
	Declare @Is_Date_wise tinyint
	
	set @Add_Initial_In_Emp_Full_Name = '0'
	Set @Is_Date_wise = 0
	select @Branch_Code = Branch_Code from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID 
	Select @Domain_Name = Domain_Name,@Cmp_Code = Cmp_Code,@Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code, @No_Of_Digits = No_Of_Digit_Emp_Code,@Is_Date_wise = Is_DateWise From dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
	Select @Comp_offlimit = CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified by Ramiz on 15092014
	select @Add_Initial_In_Emp_Full_Name = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Add initial in employee full name'
	 
	if substring(@Domain_Name,1,1) <> '@'	
		set @Domain_Name = '@' + @Domain_Name
	Declare @len as numeric
		set @len = LEN(CAST (@emp_code as varchar(10)))
	
	
	--if @len > @No_Of_Digits
	--	set @len = @No_Of_Digits
	
	--if @Is_Auto_Alpha_Numeric_Code = 1
	--	begin
	--		if @Emp_code <> 0 and @Alpha_Code <> ''
	--			begin
	--					if @Is_Date_wise = 1 
	--						set @Alpha_Emp_Code = @Alpha_Code + @Code_Date +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--					else
	--						set @Alpha_Emp_Code = @Alpha_Code +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--			end	
	--		else
	--			begin
	--					if @Is_Date_wise = 1 
	--						 set @Alpha_Emp_Code =  @Code_Date + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--					else
	--						 set @Alpha_Emp_Code =   REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--			end
	--	end
	--	else
	--		begin
	--				if @Is_Date_wise = 1	
	--					set @Alpha_Emp_Code = @Code_Date + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--				else
	--					set @Alpha_Emp_Code =  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
	--		end
		
	If @Add_Initial_In_Emp_Full_Name = 1
		Begin 
			set @Emp_Full_Name = @Initial + ' ' + @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name 
		End
	Else
		Begin 
			set @Emp_Full_Name = @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name 
		End 
	
	-- Added by Ali 19112013 -- Start
	 
	 if @EmpName_Alias_PrimaryBank = ''
		Set @EmpName_Alias_PrimaryBank = @Emp_Full_Name
		
	 if @EmpName_Alias_SecondaryBank = ''
		Set @EmpName_Alias_SecondaryBank = @Emp_Full_Name
		
	 if @EmpName_Alias_PT = ''
		Set @EmpName_Alias_PT = @Emp_Full_Name
		
	 if @EmpName_Alias_PF = ''
		Set @EmpName_Alias_PF = @Emp_Full_Name
		
	 if @EmpName_Alias_Tax = ''
		Set @EmpName_Alias_Tax = @Emp_Full_Name
		
	 if @EmpName_Alias_ESIC = ''
		Set @EmpName_Alias_ESIC = @Emp_Full_Name
		
	if @EmpName_Alias_Salary = ''
		Set @EmpName_Alias_Salary = @Emp_Full_Name
		
	 -- Added by Ali 19112013 -- End
	 
	  -- Added by Ali ` -- Start
		IF @Emp_Notice_Period = 0
			BEGIN
					Declare @Is_Short_Fall_Grade_wise tinyint
					Set @Is_Short_Fall_Grade_wise = 0
					Declare @short_Fall_days numeric(18,0)
					Set @short_Fall_days = 0
					
					select @Is_Short_Fall_Grade_wise = Is_Shortfall_Gradewise , @short_Fall_days = Short_Fall_Days from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
					if @Is_Short_Fall_Grade_wise = 1
					BEGIN
						select @short_Fall_days = Short_Fall_Days from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @Grd_ID
					END	
					Set @Emp_Notice_Period = @short_Fall_days
			END
	 -- Added by Ali 29112013 -- Start
	 
	If @tran_type  = 'I'
		Begin
		
		--SELECT @Alpha_Emp_Code
				--If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code)
				--	begin			
				--		select 	@Emp_Code,'Code'
				--		set @Emp_ID = 0
				--		RAISERROR ('Already Exist Employee Code', 16, 2)
				--		return  
				--	end
									
				DECLARE @Count as numeric(18,0) ----Added by Hasmukh for employee License  14072011
				DECLARE @Emp_LCount NUMERIC
				DECLARE @ErrString VARCHAR(1000)
				
				set @Emp_LCount = 0
				
				SELECT @Count =Count(Emp_ID) from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_Left<>'y'								
	    
	     		SELECT @Emp_LCount = dbo.Decrypt(Emp_License_Count) FROM dbo.Emp_Lcount
				SELECT @ErrString = '##Employee Limit Exceed, Contact Administrator, Total Active Employees =' + ' ' + CAST(@Count AS VARCHAR(18)) + ' ' + 'Current Employee License =' + ' ' + CAST(@Emp_LCount AS VARCHAR(18))  +'##'  
				
				if @Count > @Emp_LCount
					 Begin
						set @Emp_ID = 0
						RAISERROR (@ErrString, 16, 2) 
						return 
					 End
				 
				
				select @Emp_ID = Isnull(max(Emp_ID),0) + 1 	From dbo.T0080_EMP_MASTER WITH (NOLOCK)
				
				select @Adult_No = Isnull(max(Worker_Adult_No),0) + 1 	From dbo.T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID=@Cmp_ID
			
				-- Added By Alpesh on 25-05-2011 for first time login change password dialogbox for employee 
				if exists (select Module_Id From T0011_module_detail WITH (NOLOCK) where Cmp_Id=@Cmp_ID And chg_pwd=1)
					Begin
						  Set @Chg_Pwd=1
					End
				
				--Insert Transfer Record Ankit 02122013--
				Select @Tran_ID = Isnull(max(Tran_ID),0) + 1  From dbo.T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK)
				
				INSERT INTO dbo.T0095_EMP_COMPANY_TRANSFER(Tran_Id,Old_Cmp_id,Old_Emp_Id,Old_Branch_Id,Old_Grd_Id,Old_Desig_Id,Old_Dept_Id,Old_Shift_Id,Old_Type_Id,Old_Cat_Id,Old_Client_Id,Old_Emp_Manager_Id,Old_Emp_Weekoff_Day,
							Effective_Date,New_Cmp_id,New_Emp_Id,New_Branch_Id,New_Grd_Id,New_Desig_Id,New_Dept_Id,New_Shift_Id,New_Type_Id,New_Cat_Id,New_Client_Id,New_Emp_Mngr_Id,New_Emp_Weekoff_Day,Old_Privilege_ID,New_Privilege_ID,
							New_SubVertical_ID ,New_Segment_ID ,New_SubBranch_ID ,New_Login_Alias ,Old_Login_Alias,Old_Segment_ID ,Old_SubVertical_ID,Old_subBranch_ID,New_SalCycle_Id,Old_SalCycle_Id,Is_MultiPage_Flag,ReplaceManager_Cmp_ID,ReplaceManager_ID)
				
				Values	   (@Tran_Id,@Curr_Cmp_ID,@Curr_Emp_ID,@Old_Branch_id,@Old_Grd_Id,@Old_Desig_Id,@Old_Dept_Id,@Old_Shift_Id,@Old_Type_Id,@Old_Cat_Id,@Old_Vertical_ID,0,@Old_Weekoff_Day,
							@Date_Of_Join,@Cmp_id,@Emp_Id,@Branch_Id,@Grd_Id,@Desig_Id,@Dept_Id,@Shift_Id,@Type_Id,@Cat_Id,@Client_Id,@Emp_Superior,@New_Weekoff_Day,@Old_Privilege_ID,@New_Privilege,
							@New_SubVertical_ID ,@New_Segment_ID ,@New_SubBranch_ID ,@New_Login_Alias ,@Old_Login_Alias,@Old_Segment_ID ,@Old_SubVertical_ID,@Old_subBranch_ID,@New_SalCycle_id,@Old_Salary_Cycle_id,@Is_MultiPage_Flag,@ReplaceManager_Cmp_ID,@ReplaceManager)
				
				
				Declare @Row_ID Numeric	--Insert Salary Detail record--
				Select @Row_Id = Isnull(max(Row_Id),0) + 1 	From T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL WITH (NOLOCK)
				
				INSERT INTO dbo.T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL(Row_Id,Tran_Id,Old_Cmp_Id,Old_Emp_Id,Old_Basic_Salary,Old_Gross_Salary,Old_CTC,New_Cmp_Id,New_Emp_Id,New_Basic_Salary,New_Gross_Salary,New_CTC)
				Values		(@Row_Id,@Tran_Id,@Curr_Cmp_ID,@Curr_Emp_ID,@Old_Basic_Salary,@Old_Gross_salary,@Old_CTC,@Cmp_ID,@Emp_ID,@Basic_Salary,@Gross_Salary,@CTC)
				
				
				--added jimit 17112015------
				Declare @Thana_Name as varchar(50)
				
				SELECT @Thana_Name = ISNULL(ThanaName,'') FROM T0030_Thana_Master WITH (NOLOCK) WHERE Thana_Id = @Thana AND Cmp_ID=@Curr_Cmp_ID
				
										IF EXISTS(SELECT Thana_Id FROM T0030_Thana_Master WITH (NOLOCK) WHERE Upper(ThanaName) = upper(@Thana_Name) AND Cmp_ID=@Cmp_ID )  
											BEGIN  
												SELECT @Thana = Thana_Id FROM T0030_Thana_Master WITH (NOLOCK) WHERE Upper(ThanaName) = upper(@Thana_Name) AND Cmp_ID=@Cmp_ID
											END  
										ELSE  IF (@Thana <> 0)
											BEGIN        
												EXEC P0030_Thana_Master @Thana OUTPUT ,@Cmp_ID,@Thana_Name,'I'
											END
										
										
					SET  @Thana_Work = @Thana	
				--------ended-----------------------------
				--Insert Transfer Record Ankit 02122013--
				-- Start Added by Niraj (04022022)
				Declare @Bank_Name varchar(20)= ''
				Declare @Tally_Name varchar(20)= ''
				
				Select @Bank_Name = Bank_Name from T0040_BANK_MASTER where Bank_ID = @Bank_ID and Cmp_Id = @Curr_Cmp_ID
  				Select @Bank_ID = Bank_ID FROM T0040_BANK_MASTER Where Bank_Name = @Bank_Name and Cmp_Id = @Cmp_ID
				Select @Tally_Name = Tally_Led_Name from T0040_Tally_Led_Master where Tally_Led_ID = @Tally_Led_ID and Cmp_Id = @Curr_Cmp_ID
  				Select @Tally_Led_ID = Tally_Led_ID FROM T0040_Tally_Led_Master Where Tally_Led_Name = @Tally_Name and Cmp_Id = @Cmp_ID

				-- End Added by Niraj (04022022)
				
				INSERT INTO dbo.T0080_EMP_MASTER
							  (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name, 
							  Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality, 
							  Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,
							  Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation,
							  Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,
							  DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast
							  ,Emp_Annivarsary_Date,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Min_Wages,Segment_ID
							  ,Vertical_ID,SubVertical_ID,GroupJoiningDate,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,code_Date,code_date_Format
							  ,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT,EmpName_Alias_Tax
							  ,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Is_On_Probation,System_Date_Join_left,
							  Religion,Height,Emp_Mark_Of_Identification,Insurance_No,Emp_Confirm_Date,Despencery,Doctor_Name,DespenceryAddress,Emp_Offer_Date,Yearly_Leave_Days,
							  Yearly_Leave_Amount,Yearly_Bonus_Per,UAN_No,Date_of_Retirement,
							  Emp_Dress_Code,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code,Vehicle_NO,Aadhar_Card_No,
							  Ration_Card_No,Ration_Card_Type, Extension_No,Tally_Led_ID, Tally_Led_Name, -- Added By Niraj(02022022)
							  Actual_Date_Of_Birth,Tehsil,Tehsil_Wok,District,District_Wok,Thana_Id,Thana_Id_Wok
							  ,CompOff_HO_App_Days ,CompOff_HO_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days,CompOff_WD_App_Days,CompOff_WD_Avail_Days,Yearly_Bonus_Amount)
				VALUES     (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,
							@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,
							@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,
							@Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation,
							@Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,
							@DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast
							,@Emp_Anniversary_Date,@Extra_AB_Deduction,@Min_CompOff_Limit,@mother_name,@Min_Wages,@New_Segment_ID
							,@Client_Id,@New_SubVertical_ID,@GroupJoiningDate,@New_SubBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two
							,@Code_Date,@Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF
							,@EmpName_Alias_PT,@EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Is_On_Probation,getdate(),
							 @Religion,@Height,@Mark_Of_Idetification,@Insurance_No,@Emp_Confirmation_date,@Dispencery,@Doctor_Name,@DispenceryAdd,@Emp_Offer_Date,@Yearly_Leave_Days,
							 @Yearly_Leave_Amount,@Yearly_Bonus_Per,@UAN_No,@Date_Of_Retirenment,
							 @Emp_Dress_Code,@Emp_Shirt_Size,@Emp_Pent_Size,@Emp_Shoe_Size,@Emp_Canteen_Code,@Vehicle_No,@Aadhar_Card_No,
							 @Ration_Card_No, @Ration_Card_Type,@Extension_No, @Tally_Led_ID, @Tally_Led_Name, -- Added By Niraj(02022022)
							 @Actual_Date_Of_Birth,@Tehsil,@Tehsil_Work,@District,@District_Work,@Thana,@Thana_Work
							 ,@CompOff_HO_App_Days ,@CompOff_HO_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_WD_App_Days,@CompOff_WD_Avail_Days,@Yearly_Bonus_Amt)
							
							
				INSERT INTO dbo.T0080_EMP_MASTER_Clone
						  (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name, 
						  Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality, 
						  Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,
						  Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation,
						  Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,Is_LWF,
						  DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast,Emp_Annivarsary_Date
						  ,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Segment_ID,Vertical_ID,SubVertical_ID,GroupJoiningDate
						  ,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,code_date,Code_Date_Format,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT
						  ,EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Is_On_Probation,System_Date_Join_left,Date_of_Retirement,
						  Emp_Dress_Code,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code,Aadhar_Card_No,Tehsil,Tehsil_Wok,District,District_Wok,Thana_Id,Thana_Id_Wok
						  ,CompOff_HO_App_Days ,CompOff_HO_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days,CompOff_WD_App_Days,CompOff_WD_Avail_Days,Yearly_Bonus_Amount)
				VALUES     (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,
							@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,
							@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,
							@Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation,
							@Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,@Is_LWF,
							@DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast
							,@Emp_Anniversary_Date,@Extra_AB_Deduction,@Min_CompOff_Limit,@mother_name,@New_Segment_ID,@Client_Id
							,@New_SubVertical_ID,@GroupJoiningDate,@New_SubBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two,@Code_Date
							,@Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF
							,@EmpName_Alias_PT,@EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Is_On_Probation,getdate(),@Date_Of_Retirenment,
							@Emp_Dress_Code,@Emp_Shirt_Size,@Emp_Pent_Size,@Emp_Shoe_Size,@Emp_Canteen_Code,@Aadhar_Card_No,@Tehsil,@Tehsil_Work,@District,@District_Work,@Thana,@Thana_Work
							,@CompOff_HO_App_Days ,@CompOff_HO_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_WD_App_Days,@CompOff_WD_Avail_Days,@Yearly_Bonus_Amt)
	
				
				IF @New_Weekoff_Day = ''
					Begin
						select @Default_Weekof = Default_Holiday from dbo.T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID
					End
				Else
					Begin
						Set @Default_Weekof = @New_Weekoff_Day
					End	
					
				If @Alpha_Emp_Code is NOT NULL
					Begin 	
						Set @loginname = cast(@Alpha_Emp_Code as varchar(50)) + @Domain_Name
						set @Login_Alias = isnull(@Login_Alias,@loginname)
					End
				Else
					Begin
						Set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name	
						set @Login_Alias = isnull(@Login_Alias,@loginname)
					End	
				
				EXEC p0011_Login @Login_id Output,@Cmp_Id,@loginname,@Old_Password_ID,@Emp_ID,NULL,NULL,'I',2
				EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0
				
				Declare @late_limit varchar(10)		--Alpesh 18-Aug-2012
				Declare @early_limit varchar(10)	--Alpesh 18-Aug-2012
				Declare @ot_min_limit varchar(10)	--Alpesh 18-Aug-2012
				Declare @ot_max_limit varchar(10)	--Alpesh 18-Aug-2012
				
				select @G_FOR_DATE = max(for_date) from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date<= getdate()
				select @IS_OT = IS_OT ,@IS_PT = IS_PT ,@IS_PF= IS_PF ,@IS_LATE_MARK =IS_LATE_MARK
				,@late_limit = isnull(Late_Limit,'00:00'),@early_limit=isnull(Early_Limit,'00:00'),@ot_min_limit=ISNULL(OT_App_Limit,'00:00'),@ot_max_limit=ISNULL(OT_Max_Limit,'00:00') 
				from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date= @G_FOR_DATE
				
				 
				if (isnull(@Emp_Late_Limit,'')='' or @Emp_Late_Limit = '00:00')
				   set @Emp_Late_Limit = @late_limit
				   
				if isnull(@Emp_Early_Limit,'')='' or @Emp_Early_Limit = '00:00'
				   set @Emp_Early_Limit = @early_limit
				   
				if (isnull(@Emp_OT_Min_Limit,'')='' or @Emp_OT_Min_Limit = '00:00')
				   set @Emp_OT_Min_Limit = @ot_min_limit
				   
				if isnull(@Emp_OT_Max_Limit,'')='' or @Emp_OT_Max_Limit = '00:00'
				   set @Emp_OT_Max_Limit = @ot_max_limit   
	
			Set @Increment_ID = 0
	
				EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join output,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@emp_superior,@Dep_Reminder,1,@CTC,0,0,0,0,0,0,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID, @Emp_wd_ot_rate, @Emp_wo_ot_rate, @Emp_ho_ot_rate,0,0,0,0,@no_of_chlidren,@is_metro,@is_physical,@New_SalCycle_id,@auto_Vpf,@New_Segment_ID,@Client_Id,@New_SubVertical_ID,@New_SubBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Inc_Bank_AC_No_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,@Reason_ID,@Reason_Name,@User_Id,@IP_Address,@Customer_Audit,@Old_Join_Date,@Sales_Code,@Physical_Percent
				
				
				If isnull(@Default_Weekof,'') <> ''
				
				
				EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,'','','','',0,'I' 
				exec P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID 
				EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_Of_Join,null
				
				exec P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@Emp_Superior,@Date_Of_Join	
			
			
			
				IF @New_Login_Alias = ''
					Set @New_Login_Alias = @Login_Alias
				
				Update T0095_EMP_COMPANY_TRANSFER Set New_Login_Alias = @New_Login_Alias WHERE Tran_Id = @Tran_ID And New_Emp_Id = @Emp_ID
				
				if not exists (SELECT 1 from T0011_LOGIN WITH (NOLOCK) where Login_Alias = isnull(@New_Login_Alias,'') AND Emp_ID <> @Emp_ID)
					begin
						update T0011_LOGIN SET login_alias = isnull(@New_Login_Alias,'') where Emp_ID = @Emp_ID
					end
	
	
				Declare @Pas_Login_Id Numeric
				Set @Pas_Login_Id  = 0
				Select @Pas_Login_Id = Login_ID From T0011_LOGIN WITH (NOLOCK) Where Emp_ID = @Emp_ID And Login_ID = @Login_id-- And Effective_Date = @Date_Of_Join
			
				Exec P0090_EMP_PRIVILEGE_DETAILS 0,@New_Privilege,@Cmp_ID,@Pas_Login_Id,@Date_Of_Join,'I'
				
				--'' Update Employee Master Detail ''--
				
				Declare @CurTeam_Emp_Id numeric 		--Emergency Contact Detail 
				Declare	@Name varchar(100)
				Declare	@RelationShip varchar(20)
				Declare	@Home_Tel_No_1 varchar(30)
				Declare	@Home_Mobile_No_1 varchar(30)
				Declare	@Work_Tel_No_1 varchar(30)   	
				Declare @Row_ID_ECONTACT numeric(18,0) 
					
					Set @CurTeam_Emp_Id = 0
					Set @Row_ID_ECONTACT = 0
					 
					Declare CusrUpdateEmerg_Contact cursor for	                 
						select Row_ID From T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateEmerg_Contact
							Fetch next from CusrUpdateEmerg_Contact into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									Set	@Name =''
									Set	@RelationShip =''
									Set	@Home_Tel_No_1 =''
									Set	@Home_Mobile_No_1 =''
									Set	@Work_Tel_No_1 =''
									Set @Row_ID_ECONTACT =0
									   
									Select @Name = Name,@RelationShip = RelationShip,@Home_Tel_No_1 = Isnull(Home_Tel_No,0),@Home_Mobile_No_1 = Isnull(Home_Mobile_No,0),@Work_Tel_No_1 = Isnull(Work_Tel_No ,0)
									From T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
										
										select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK)
														
										INSERT INTO  T0090_EMP_EMERGENCY_CONTACT_DETAIL --EMERGENCY CONTACT DETAIL
													(Emp_ID,Row_ID,Cmp_ID,Name,RelationShip,Home_Tel_No,Home_Mobile_No,Work_Tel_No)
										Values	(@Emp_ID,@Row_ID_ECONTACT,@Cmp_Id,@Name,@RelationShip,@Home_Tel_No_1,@Home_Mobile_No_1,@Work_Tel_No_1 )
								
									fetch next from CusrUpdateEmerg_Contact into @CurTeam_Emp_Id	
								End
						Close CusrUpdateEmerg_Contact                    
					Deallocate CusrUpdateEmerg_Contact
					
					Declare @BirthDate Datetime
					Declare @D_Age	   Numeric(18,1)
					Declare @Address   Varchar(1000)
					Declare @Share	   Numeric(18,2)
					Declare @Is_Resi   Numeric(1,0) 
					Declare @NomineeFor Varchar(30) 
				    Set @NomineeFor =  ''
				    	
					set @Row_ID_ECONTACT = 0
					Declare CusrUpdateDependant_Detail cursor for	--EMP DEPENDANT DETAIL
						select Row_ID From T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateDependant_Detail
							Fetch next from CusrUpdateDependant_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									Set	@Name =''
									Set	@RelationShip =''
									Set	@D_Age =0
									Set	@Is_Resi = 0
									Set	@Share = 0
									Set @Row_ID_ECONTACT =0
									Set @Address = ''
									
									Select @Name = Name,@RelationShip = RelationShip,@BirthDate = BirthDate,@D_Age = isnull(D_Age,0),@Address = isnull(Address,'') ,@Share = isnull(Share,0),@Is_Resi = isnull(Is_Resi,0),@NomineeFor = Isnull(NomineeFor,0)
									From T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									
									
										If @BirthDate = ''  
											SET @BirthDate  = NULL
							
										select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK)
														
										INSERT INTO  T0090_EMP_DEPENDANT_DETAIL  
													(Emp_ID,Row_ID,Cmp_ID,Name,RelationShip,BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor)
										Values	(@Emp_ID,@Row_ID_ECONTACT,@Cmp_Id,@Name,@RelationShip,@BirthDate,@D_Age,@Address,@Share ,@Is_Resi,@NomineeFor )
								
									fetch next from CusrUpdateDependant_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateDependant_Detail                    
					Deallocate CusrUpdateDependant_Detail
				
				Declare @Is_Dependant tinyint
				DECLARE @Image_Path VARCHAR(100)
				Set @Is_Dependant  =0
				set @Row_ID_ECONTACT = 0
					Declare CusrUpdateChild_Detail cursor for	--EMP CHILDRAN DETAIL
						select Row_ID From T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateChild_Detail
							Fetch next from CusrUpdateChild_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									Set	@Name =''
									Set	@RelationShip =''
									Set	@D_Age =0
									Set	@Is_Resi = 0
									Set	@Share = 0
									Set @Row_ID_ECONTACT =0
									Set @Address = ''
									Set @Gender = ''
									set @Is_Dependant = 0
									set @Image_Path = ''
									Select @Name = Name,@RelationShip = RelationShip,@BirthDate = Date_Of_Birth,@D_Age = isnull(C_Age,0),@Is_Resi = isnull(Is_Resi,0),@Is_Dependant = Isnull(Is_Dependant,0),@Gender = Gender
											,@Image_Path = Image_Path
									From T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									--added jimit 07122015------
									
									declare @RelationShip_name	varchar(50)
									declare @Relationship_ID numeric(18,2)							
										
										SELECT @RelationShip_name = ISNULL(RelationShip,'') FROM T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) WHERE Row_ID = @Row_ID AND Cmp_ID=@Curr_Cmp_ID
										
										--if  Not EXISTS(select Relationship_ID from T0040_Relationship_Master where Upper(RelationShip) = upper(RelationShip) AND Cmp_ID=@Cmp_ID )
										--	BEGIN
										select @Relationship_ID = Max(Relationship_ID)+1 from T0040_Relationship_Master WITH (NOLOCK) --WHERE  Cmp_ID=@Cmp_ID
												EXEC  P0040_Relationship_Master @Relationship_ID,@RelationShip,@Cmp_ID
											--	print 1
											--end
										
											IF EXISTS(SELECT Row_ID FROM T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) WHERE Upper(RelationShip) = upper(RelationShip) AND Cmp_ID=@Cmp_ID )  
												BEGIN  
													SELECT @Row_ID = Row_ID FROM T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) WHERE Upper(RelationShip) = upper(@RelationShip) AND Cmp_ID=@Cmp_ID
												END  
											ELSE  IF (@Row_ID <> 0)
												BEGIN        
													EXEC P0090_EMP_CHILDRAN_DETAIL @row_id = @Row_ID OUTPUT,@emp_id = @emp_Id,
													@cmp_id = @Cmp_ID,@Name = @Name,@RelationShip = @RelationShip,@Date_Of_Birth = @BirthDate,
													@C_Age = @D_Age,@Is_Resi = @Is_Resi,@Is_Dependant = @Is_Dependant,@Gender = @Gender,
													@Image_Path = @Image_Path,@tran_type = 'I'
												END
																
																
											SET  @Row_ID = @Row_ID	
								--------ended-----------------------------
									
									 
										If @BirthDate = ''  
											SET @BirthDate  = NULL
							
										select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
														
										INSERT INTO  T0090_EMP_CHILDRAN_DETAIL 
													(Emp_ID,Row_ID,Cmp_ID,Name,RelationShip,Date_Of_Birth,C_Age,Is_Resi,Is_Dependant,Gender,Image_Path)
										Values	(@Emp_ID,@Row_ID_ECONTACT,@Cmp_Id,@Name,@RelationShip,@BirthDate,@D_Age,@Is_Resi,@Is_Dependant,@Gender,@Image_Path )
								
									fetch next from CusrUpdateChild_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateChild_Detail                    
					Deallocate CusrUpdateChild_Detail
					
					Declare @Imm_Type varchar(20)	-- EMP IMMIGRATION DETAIL
					Declare @Imm_No varchar(20)
					Declare @Imm_Issue_Date datetime
					Declare @Imm_Issue_Status varchar(20)
					Declare @Imm_Review_Date datetime
					Declare @Imm_Comments varchar(250)
					Declare @Imm_Date_of_Expiry datetime
					DECLARE @attach_doc     NVARCHAR(MAX)   --added jimit 17112015
					
					Declare CusrUpdateIMMI_Detail cursor for	
						select Row_ID From T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateIMMI_Detail
							Fetch next from CusrUpdateIMMI_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									Set	@Imm_Type =''
									Set	@Imm_No =''
									Set	@Imm_Issue_Date =0
									Set	@Imm_Issue_Status = 0
									Set @Imm_Date_of_Expiry =''
									Set @Imm_Review_Date = ''
									Set @Gender = ''
									set @Imm_Comments = ''
									set @attach_doc = ''
									
									Select @Imm_Type = Imm_Type, @Imm_No = Imm_No,@Imm_Issue_Date = Imm_Issue_Date,@Imm_Issue_Status = ISNULL(Imm_Issue_Status,''), @Imm_Review_Date = Imm_Review_Date, @Imm_Comments = ISNULL(Imm_Comments,''), @Imm_Date_of_Expiry = Imm_Date_of_Expiry,@Loc_ID = Loc_ID
											,@attach_doc = attach_doc
									From T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK)
													
									INSERT INTO  T0090_EMP_IMMIGRATION_DETAIL 
												(Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,attach_doc)
									Values	(@Row_ID_ECONTACT,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,@attach_doc)
								
									fetch next from CusrUpdateIMMI_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateIMMI_Detail                    
					Deallocate CusrUpdateIMMI_Detail
					
					
					--Declare @Asset_ID		Numeric 
					--Declare @Model_no		Varchar(20)
					--Declare @Issue_Date		Datetime
					--Declare @Return_Date	Datetime

					--Declare CusrUpdateAsset_Detail cursor for	--  EMP ASSET DETAIL
					--	select Emp_Asset_ID From T0090_EMP_ASSET_DETAIL Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
					--	Open CusrUpdateAsset_Detail
					--		Fetch next from CusrUpdateAsset_Detail into @CurTeam_Emp_Id
					--		While @@fetch_status = 0                    
					--			Begin 
									
					--				Select @Asset_ID = Asset_ID ,@Model_no = Model_no ,@Issue_Date = Issue_Date ,@return_Date = return_Date , @Comments = Asset_Comment 
					--				From T0090_EMP_ASSET_DETAIL Where Emp_Asset_ID = @CurTeam_Emp_Id
									
					--					Select @Row_ID_ECONTACT =  Isnull(max(Emp_Asset_ID),0) + 1 from T0090_EMP_ASSET_DETAIL 
														
					--					INSERT INTO T0090_EMP_ASSET_DETAIL
					--							   (Emp_Asset_ID,Cmp_ID,Emp_ID,Asset_ID,Model_No,Issue_Date,Return_Date,Asset_Comment)
					--					VALUES     (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@Asset_ID,@Model_No,@Issue_Date,@Return_Date,@Comments)
								
					--				fetch next from CusrUpdateAsset_Detail into @CurTeam_Emp_Id	
					--			End
					--	Close CusrUpdateAsset_Detail                    
					--Deallocate CusrUpdateAsset_Detail
					
					--added jimit 17112015    License
					Declare @CurLice_Row_Id		numeric
					Declare @Lic_Comments		Varchar(250)
					Declare @Lic_For			Varchar(50)
					Declare @Lic_No				Varchar(20)
					Declare @Is_expired			TINYINT
					Declare @Lic_st_date		Datetime
					Declare @Lic_End_date		Datetime
					Declare @Lic_Id				numeric(18,2)

					Declare CusrLicense cursor for	--  EMP License DETAIL
						select Row_Id From T0090_EMP_LICENSE_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrLicense
							Fetch next from CusrLicense into @CurLice_Row_Id
							While @@fetch_status = 0                    
								Begin 
									
									Select @Lic_Id = LIC_ID,@Lic_st_date = Lic_St_Date,@Lic_End_date = Lic_End_Date,
											@Lic_Comments = Lic_Comments,@Lic_For = Lic_For,@Lic_No = Lic_Number,
											@Is_expired = Is_Expired
									From T0090_EMP_LICENSE_DETAIL WITH (NOLOCK) Where Row_Id = @CurLice_Row_Id
									
										Select @Row_ID_ECONTACT =  Isnull(max(Row_Id),0) + 1 from T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)
														
										INSERT INTO T0090_EMP_LICENSE_DETAIL
												   (Row_ID,Cmp_ID,Emp_ID,LIC_ID,Lic_St_Date,Lic_End_Date,Lic_Comments,Lic_For,Lic_Number,Is_Expired)
										VALUES     (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@Lic_Id,@Lic_st_date,@Lic_End_date,@Lic_Comments,@Lic_For,@Lic_No,@Is_expired)
								
									fetch next from CusrLicense into @CurLice_Row_Id	
								End
						Close CusrLicense                    
					Deallocate CusrLicense
					--ended
					Declare @Comments		Varchar(100)
					Set @COMMENTS = ''
					
					Declare @CurContr_Tran_Id		numeric
					Declare @PRJ_ID NUMERIC(18,0)
					Declare @START_DATE DATETIME
					Declare @END_DATE DATETIME
					Declare @IS_RENEW TINYINT
					Declare @IS_REMINDER TINYINT

					Declare CurContract cursor for	--  EMP CONTRACT DETAIL
						select TRAN_ID From T0090_EMP_CONTRACT_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CurContract
							Fetch next from CurContract into @CurContr_Tran_Id
							While @@fetch_status = 0                    
								Begin 
									
									Select @PRJ_ID = PRJ_ID,@START_DATE = START_DATE,@END_DATE = END_DATE,@IS_RENEW = IS_RENEW,@IS_REMINDER = IS_REMINDER,@COMMENTS = COMMENTS
									From T0090_EMP_CONTRACT_DETAIL WITH (NOLOCK) Where TRAN_ID = @CurContr_Tran_Id
									
										Select @Row_ID_ECONTACT =  Isnull(max(TRAN_ID),0) + 1 from T0090_EMP_CONTRACT_DETAIL WITH (NOLOCK)
														
										INSERT INTO T0090_EMP_CONTRACT_DETAIL
												   (TRAN_ID, CMP_ID, EMP_ID, PRJ_ID, START_DATE, END_DATE, IS_RENEW,IS_REMINDER,COMMENTS)
										VALUES     (@Row_ID_ECONTACT,@CMP_ID,@EMP_ID,@PRJ_ID,@START_DATE,@END_DATE,@IS_RENEW,@IS_REMINDER,@COMMENTS)
								
									fetch next from CurContract into @CurContr_Tran_Id	
								End
						Close CurContract                    
					Deallocate CurContract
					
					Set @COMMENTS = ''
					set @End_Date = ''
					
					Declare @Employer_Name varchar(100)		--EMP EXPERIENCE DETAIL
					Declare @Desig_Name varchar(100)
					Declare @St_Date datetime
					--Declare @End_Date datetime	
					Declare @CTC_Amount numeric(18,0)
					Declare @Gross_Salary_Ex numeric(18,0)
					Declare @Exp_Remarks  nvarchar(500) 
					Declare @Emp_Branch varchar(100) 
					Declare @Emp_Location varchar(100) 
					Declare @Manager_Name varchar(100) 
					Declare @Mgr_Contact_number nvarchar(50) 
					
					Set  @CTC_Amount  = 0
					Set @Gross_Salary_Ex  = 0
					Set @Exp_Remarks  = ''
					Set @Emp_Branch = ''
					Set @Emp_Location = ''
					Set @Manager_Name = ''
					
					--Declare @Mgr_Contact_number nvarchar(50)
					Set @Mgr_Contact_number = ''
					Declare CusrUpdateEXPE_Detail cursor for	
						select Row_ID From T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateEXPE_Detail
							Fetch next from CusrUpdateEXPE_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									
									Set @Employer_Name	=''
									Set @Desig_Name		=''
									Set @St_Date		= ''
									Set @CTC_Amount  = 0
									Set @Gross_Salary_Ex  = 0
									Set @Exp_Remarks  = ''
									Set @Emp_Branch = ''
									Set @Emp_Location  = ''
									Set @Manager_Name = ''
									Set @Mgr_Contact_number = '' 
									 
									Select @Employer_Name = Employer_Name , @Desig_Name = Desig_Name , @St_Date =St_Date, @End_Date = End_Date , @CTC_Amount =ISNULL(CTC_Amount,0) ,@Gross_Salary = ISNULL(Gross_Salary,0) , @Exp_Remarks = ISNULL(Exp_Remarks,'') ,
										   @Emp_Branch = ISNULL(Emp_Branch,'') ,@Emp_Location = ISNULL(Emp_Location,'') ,@Manager_Name = ISNULL(Manager_Name,'') ,@Mgr_Contact_number = ISNULL(Contact_number,'') 
								   
								   	From T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
													
									insert into T0090_EMP_EXPERIENCE_DETAIL(Row_ID,Emp_ID ,Cmp_ID ,Employer_Name ,Desig_Name ,St_Date ,End_Date,CTC_Amount,Gross_Salary,Exp_Remarks,Emp_Branch,Emp_Location,Manager_Name,Contact_number)
									
									values(@Row_ID_ECONTACT ,@Emp_ID ,@Cmp_ID ,@Employer_Name ,@Desig_Name ,@St_Date ,@End_Date,@CTC_Amount ,@Gross_Salary,@Exp_Remarks,@Emp_Branch,@Emp_Location,@Manager_Name,@Mgr_Contact_number)
								
									fetch next from CusrUpdateEXPE_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateEXPE_Detail                    
					Deallocate CusrUpdateEXPE_Detail
					
				Declare @Lang_ID	   as Numeric		--EMP LANGUAGE DETAIL
				Declare @Lang_Fluency  as varchar(20)
				Declare @Lang_Ability  as varchar(200)
				Declare @LANG_NAME AS VARCHAR(100)
				
				Declare CusrUpdateLANG_Detail cursor for	
						select Row_ID From T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateLANG_Detail
							Fetch next from CusrUpdateLANG_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									 
									 Set @Lang_Fluency  = ''
									 Set @Lang_Ability  = ''
									 Set @LANG_NAME     = ''
									
										Select @Lang_Ability = ISNULL(Lang_Ability ,''), @Lang_Fluency = ISNULL(Lang_Fluency ,''), @Lang_ID = Lang_ID 
								   		From T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
										
										SELECT @Lang_Name = ISNULL(Lang_Name,'') FROM T0040_LANGUAGE_MASTER WITH (NOLOCK) WHERE Lang_ID = @Lang_ID AND Cmp_ID=@Curr_Cmp_ID
				
										IF EXISTS(SELECT Lang_ID FROM T0040_LANGUAGE_MASTER WITH (NOLOCK) WHERE Upper(Lang_Name) = upper(@Lang_Name) AND Cmp_ID=@Cmp_ID )  
											BEGIN  
												SELECT @Lang_ID = Lang_ID FROM T0040_LANGUAGE_MASTER WITH (NOLOCK) WHERE Upper(Lang_Name) = upper(@Lang_Name) AND Cmp_ID=@Cmp_ID
											END  
										ELSE  
											BEGIN        
												EXEC P0040_LANGUAGE_MASTER @Lang_ID OUTPUT ,@Cmp_ID,@Lang_Name,'I'
											END
										
										Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK)
														
										INSERT INTO T0090_EMP_LANGUAGE_DETAIL
											  (Row_ID, Emp_Id, Cmp_ID, Lang_ID, Lang_Fluency, Lang_Ability)
										VALUES (@Row_ID_ECONTACT, @Emp_Id, @Cmp_ID, @Lang_ID, @Lang_Fluency, @Lang_Ability)
								
									fetch next from CusrUpdateLANG_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateLANG_Detail                    
					Deallocate CusrUpdateLANG_Detail
				
				Declare @Qual_ID	numeric(18,0)		--EMP QUALIFICATION DETAIL
				Declare @Qual_Name	VARCHAR(100) 			
				Declare @Specialization varchar(100)
				Declare @Year	numeric(18,0)
				Declare @Score	varchar(20)
				
				
				Declare CusrUpdateQUAL_Detail cursor for	
						select Row_ID From T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
					
					Open CusrUpdateQUAL_Detail
						Fetch next from CusrUpdateQUAL_Detail into @CurTeam_Emp_Id
						While @@fetch_status = 0                    
							Begin 
									Set @Qual_Name	= ''
									Set @Specialization = ''
									Set @Year	= 0
									Set @Score	= ''
									Set @attach_doc = ''
									
									Select @Qual_ID =Qual_ID , @Specialization = ISNULL( Specialization ,''), @Year = isnull(Year,0) , @Score = ISNULL(Score,''), @St_Date =ISNULL(St_Date,'') , @End_Date = Isnull(End_Date,'') , @Comments = ISNULL(Comments ,'')
							   				,@attach_doc = attach_doc
							   		From T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									SELECT @Qual_Name = ISNULL(Qual_Name,'') FROM T0040_QUALIFICATION_MASTER WITH (NOLOCK) WHERE Qual_ID = @Qual_ID AND Cmp_ID=@Curr_Cmp_ID
				
									IF EXISTS(SELECT Qual_ID FROM T0040_QUALIFICATION_MASTER WITH (NOLOCK) WHERE UPPER(Qual_Name) =Upper(@Qual_Name) AND Cmp_ID=@Cmp_ID)  
										BEGIN  
											SELECT @Qual_ID = Qual_ID FROM T0040_QUALIFICATION_MASTER WITH (NOLOCK) WHERE UPPER(Qual_Name) =Upper(@Qual_Name) AND Cmp_ID=@Cmp_ID
										END  
									ELSE  
										BEGIN        
											EXEC P0040_Qualification_Master @Qual_ID OUTPUT ,@Cmp_ID,@Qual_Name,'I',0,'',''
										END
									
									Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
													
									INSERT INTO T0090_EMP_QUALIFICATION_DETAIL
					                      (Emp_ID, Row_ID, Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,attach_doc)
									VALUES     (@Emp_ID,@Row_ID_ECONTACT,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,@attach_doc)						
							
								fetch next from CusrUpdateQUAL_Detail into @CurTeam_Emp_Id	
							End
					Close CusrUpdateQUAL_Detail                    
				Deallocate CusrUpdateQUAL_Detail
				
				Declare @Skill_ID numeric 
				Declare @Skill_Comments varchar(250)
				Declare @Skill_Experience varchar(50)	
				Declare @Skill_Name AS VARCHAR(50)
				
				Declare CusrUpdateSkill_Detail cursor for	--EMP SKILL DETAIL
						select Row_ID From T0090_EMP_SKILL_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateSkill_Detail
							Fetch next from CusrUpdateSkill_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									
									Set @Skill_Comments = ''
									Set @Skill_Experience = ''
									Set @Skill_Name = ''
									
									Select @Skill_ID = Skill_ID , @Skill_Comments = ISNULL(Skill_Comments ,''), @Skill_Experience = ISNULL(Skill_Experience,'')
									From T0090_EMP_SKILL_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									SELECT @Skill_Name = ISNULL(Skill_Name,'') FROM T0040_Skill_Master WITH (NOLOCK) WHERE Skill_ID = @Skill_ID AND Cmp_ID=@Curr_Cmp_ID
				
									IF EXISTS(SELECT Skill_ID FROM T0040_Skill_Master WITH (NOLOCK) WHERE Upper(Skill_Name) = Upper(@Skill_Name) AND Cmp_ID=@Cmp_ID)  
										BEGIN  
											SELECT @Skill_ID = Skill_ID FROM T0040_Skill_Master WITH (NOLOCK) WHERE Upper(Skill_Name) = Upper(@Skill_Name) AND Cmp_ID=@Cmp_ID
										END  
									ELSE  
										BEGIN        
											EXEC P0040_SKILL_MASTER @Skill_ID OUTPUT,@Skill_Name,@Cmp_ID,@Skill_Name,'I',0,''
										END
										
									Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_SKILL_DETAIL WITH (NOLOCK)
													
									INSERT INTO T0090_EMP_SKILL_DETAIL
												(Row_ID,Emp_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience)
									VALUES      (@Row_ID_ECONTACT,@Emp_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience)
								
									fetch next from CusrUpdateSkill_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateSkill_Detail                    
					Deallocate CusrUpdateSkill_Detail
					
					Declare @R_Emp_ID			Numeric(18, 0)
					Declare @Ref_Description	Varchar(100)
					Declare @Amount				Numeric(18, 2)
					
					Declare @Ref_Month Numeric(5,0)
					Declare @Ref_Year Numeric(5,0)
					Declare @Effect_On_Salary Numeric(3,0)
					
					Declare CusrUpdateRefe_Detail cursor for	-- EMP REFERENCE DETAIL
						select Reference_ID From T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateRefe_Detail
							Fetch next from CusrUpdateRefe_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									Set @Ref_Description = ''
									Set @Amount	= 0
					
									Select @R_Emp_ID = R_Emp_ID,@For_Date = For_Date,
										   @Ref_Description = ISNULL(Ref_Description,''),
										   @Amount = Isnull(Amount,0),
										   @Comments = ISNULL(Comments,''),
										   @Ref_Month = Ref_Month,
										   @Ref_Year = Ref_Year,
										   @Effect_On_Salary = Effect_In_Salary
									From T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK) Where Reference_ID = @CurTeam_Emp_Id
									
										Select @Row_ID_ECONTACT =  Isnull(max(Reference_ID),0) + 1 from T0090_EMP_REFERENCE_DETAIL WITH (NOLOCK)
														
										INSERT INTO T0090_EMP_REFERENCE_DETAIL
													(Reference_ID,Cmp_ID,Emp_ID,R_Emp_ID,For_Date,Ref_Description,Amount,Comments,Ref_Month,Ref_Year,Effect_In_Salary)
										VALUES      (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@R_Emp_ID,@For_Date,@Ref_Description,@Amount,@Comments,@Ref_Month,@Ref_Year,@Effect_On_Salary)
								
									fetch next from CusrUpdateRefe_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateRefe_Detail                    
					Deallocate CusrUpdateRefe_Detail
				  
					Declare @Doc_Path		Varchar(500)
					Declare @Doc_Comments	Varchar(250)	
					Declare @Doc_ID			Numeric
					Declare @Doc_Name		Varchar(100)
					
					Declare CusrUpdateDoc_Detail cursor for	-- EMP DOC DETAIL
						select Row_ID From T0090_EMP_DOC_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CusrUpdateDoc_Detail
							Fetch next from CusrUpdateDoc_Detail into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									
									set @Doc_Comments = ''
									set @Doc_Path = ''
									
									Select @Doc_Comments = ISNULL(Doc_Comments,'') , @Doc_Path = Doc_Path ,@Doc_ID =  Doc_ID 
									From T0090_EMP_DOC_DETAIL WITH (NOLOCK) Where Row_ID = @CurTeam_Emp_Id
									
									SELECT @Doc_Name = ISNULL(Doc_Name,'') FROM T0040_DOCUMENT_MASTER WITH (NOLOCK) WHERE Doc_ID = @Doc_ID AND Cmp_ID=@Curr_Cmp_ID
				
									IF EXISTS(SELECT Doc_ID FROM T0040_DOCUMENT_MASTER WITH (NOLOCK) WHERE Upper(Doc_Name) = Upper(@Doc_Name) AND Cmp_ID=@Cmp_ID)  
										BEGIN  
											SELECT @Doc_ID = Doc_ID FROM T0040_DOCUMENT_MASTER WITH (NOLOCK) WHERE Upper(Doc_Name) = Upper(@Doc_Name) AND Cmp_ID=@Cmp_ID
										END  
									ELSE  
										BEGIN        
											EXEC P0040_DOCUMENT_MASTER @Doc_ID OUTPUT,@Cmp_ID,@Doc_Name,'','I',0,0,'',0
										END
									
									Select @Row_ID_ECONTACT =  Isnull(max(Row_ID),0) + 1 from T0090_EMP_DOC_DETAIL WITH (NOLOCK)
													
									INSERT INTO T0090_EMP_DOC_DETAIL
											    (Row_ID, Emp_Id, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments)
									VALUES      (@Row_ID_ECONTACT, @Emp_Id, @Cmp_ID, @Doc_ID, @Doc_Path, @Doc_Comments)
								
									fetch next from CusrUpdateDoc_Detail into @CurTeam_Emp_Id	
								End
						Close CusrUpdateDoc_Detail                    
					Deallocate CusrUpdateDoc_Detail
					
					
					--Declare @Ins_Cmp_Name   VARCHAR(50)
					--Declare @Ins_Policy_No	VARCHAR(50)
					--Declare @Ins_Taken_Date DATETIME
					--Declare @Ins_Due_Date	DATETIME
					--Declare @Ins_Exp_Date   DATETIME
					--Declare @Ins_Amount		NUMERIC(18,2)
					--Declare @Ins_Anual_Amt  NUMERIC(18,2)
					--Declare @Ins_Tran_ID	Numeric
					
					--Declare CusrUpdateInsur_Detail cursor for	-- EMP INSURANCE DETAIL
					--	select Emp_Ins_Tran_ID From T0090_EMP_INSURANCE_DETAIL Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
					--	Open CusrUpdateInsur_Detail
					--		Fetch next from CusrUpdateInsur_Detail into @CurTeam_Emp_Id
					--		While @@fetch_status = 0                    
					--			Begin 
									
					--				Select @Ins_Tran_ID = Ins_Tran_ID,@Ins_Cmp_Name = Ins_Cmp_name,@Ins_Policy_No = Ins_Policy_No,@Ins_Taken_Date = Ins_Taken_Date,@Ins_Due_Date = Ins_Due_Date,@Ins_Exp_Date = Ins_Exp_Date,@Ins_Amount = Ins_Amount,@Ins_Anual_Amt = Ins_Anual_Amt
					--				From T0090_EMP_INSURANCE_DETAIL Where Emp_Ins_Tran_ID = @CurTeam_Emp_Id
									
					--					Select @Row_ID_ECONTACT =  Isnull(max(Emp_Ins_Tran_ID),0) + 1 from T0090_EMP_INSURANCE_DETAIL 
														
					--					INSERT INTO T0090_EMP_INSURANCE_DETAIL 
					--								(Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID)
					--					VALUES      (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,@Login_ID)	
								
					--				fetch next from CusrUpdateInsur_Detail into @CurTeam_Emp_Id	
					--			End
					--	Close CusrUpdateInsur_Detail                    
					--Deallocate CusrUpdateInsur_Detail
					
					Declare @CurIns_Emp_Ins_Tran_ID numeric
					Declare @Ins_Cmp_Name   VARCHAR(50)
					Declare @Ins_Policy_No	VARCHAR(50)
					Declare @Ins_Taken_Date DATETIME
					Declare @Ins_Due_Date	DATETIME
					Declare @Ins_Exp_Date   DATETIME
					Declare @Ins_Amount		NUMERIC(18,2)
					Declare @Ins_Anual_Amt  NUMERIC(18,2)
					Declare @Ins_Tran_ID	Numeric
					Declare @Monthly_Premium Numeric(18,2)  --added jimit 04112015
					DECLARE @Sal_Effective_Date	DATETIME	--added jimit 04112015
					Declare @Insu_Name VARCHAR(50)
					Declare @Description	NVARCHAR(MAX)
					Declare @Type			Varchar(20)
					declare @Emp_Dependent_ID VARCHAR(MAX) --added jimit 07122015
					--DECLARE @row_Id numeric
					Declare @RowIDtemp Varchar(50)
					
					
					Declare CurInsurance CURSOR for	-- EMP INSURANCE DETAIL
						select Emp_Ins_Tran_ID From T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) Where Emp_Id = @Curr_Emp_Id And Cmp_Id = @Curr_Cmp_Id
						
						Open CurInsurance
							Fetch next from CurInsurance into @CurIns_Emp_Ins_Tran_ID
							While @@fetch_status = 0                    
								Begin 
									
									SET  @Ins_Tran_ID = 0
									SET	 @Ins_Cmp_Name = ''
									SET	 @Ins_Policy_No = ''
									SET  @Ins_Taken_Date = ''
									SET  @Ins_Due_Date = ''
									SET  @Ins_Exp_Date = ''
									SET  @Ins_Amount = 0
									SET  @Ins_Anual_Amt = 0
									SET  @Monthly_Premium = 0
									SET  @Sal_Effective_Date = ''
									set @Insu_Name = ''
									set @Description = ''
									set  @Type= ''
									set @Emp_Dependent_ID = ''
									
									Select @Ins_Tran_ID = Ins_Tran_ID,@Ins_Cmp_Name = Ins_Cmp_name,@Ins_Policy_No = Ins_Policy_No,@Ins_Taken_Date = Ins_Taken_Date,@Ins_Due_Date = Ins_Due_Date,@Ins_Exp_Date = Ins_Exp_Date,@Ins_Amount = Ins_Amount,@Ins_Anual_Amt = Ins_Anual_Amt
										   ,@Monthly_Premium =  Monthly_Premium,@Sal_Effective_Date = Sal_Effective_Date--,@Emp_Dependent_ID = Emp_Dependent_ID
									From T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) Where Emp_Ins_Tran_ID = @CurIns_Emp_Ins_Tran_ID
									
									SELECT @Insu_Name=Ins_Name , @Description = Ins_Desc , @Type = Type
									FROM T0040_INSURANCE_MASTER WITH (NOLOCK)
									WHERE Ins_Tran_ID = @Ins_Tran_ID
									---------Added jimit 07122015----------------
					
								---Commented by Hardik 18/12/2017 As Samarth has issue varchar to Numeric, And added below code.							
								--SELECT  @ROW_ID  =  SUBSTRING(EMP_DEPENDENT_ID,0,2) 
								--FROM    T0090_EMP_INSURANCE_DETAIL 
								--WHERE   CMP_ID = @CURR_CMP_ID AND EMP_ID = @CURR_EMP_ID 						
					
					
								--IF @ROW_ID = 0 
								--	BEGIN	  
								--		set @EMP_DEPENDENT_ID = null									
  						--				SELECT @EMP_DEPENDENT_ID = COALESCE(@EMP_DEPENDENT_ID + '#'  , '') + CAST(ROW_ID AS VARCHAR(10))  FROM T0090_EMP_CHILDRAN_DETAIL WHERE EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID 
								--		SET @EMP_DEPENDENT_ID = '0' + @EMP_DEPENDENT_ID
								--	END
								--ELSE
								--	BEGIN 
								--		set @EMP_DEPENDENT_ID = null
								--		SELECT @EMP_DEPENDENT_ID = COALESCE(@EMP_DEPENDENT_ID + '#' , '') + CAST(ROW_ID AS VARCHAR(10))  FROM T0090_EMP_CHILDRAN_DETAIL WHERE EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID									
								--	END										

								SELECT  @EMP_DEPENDENT_ID  =  EMP_DEPENDENT_ID
								FROM    T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)
								WHERE   CMP_ID = @CURR_CMP_ID AND EMP_ID = @CURR_EMP_ID 						

										
									-------------ended---------------------------
									
									
									IF EXISTS(SELECT 1 FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE Upper(Ins_name) = Upper(@Insu_Name) AND Cmp_ID=@Cmp_ID)  
										BEGIN 										 
											SELECT @Ins_Tran_ID  = Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE Upper(Ins_name) = Upper(@Insu_Name) AND Cmp_ID=@Cmp_ID
										END  
									ELSE  
										BEGIN  
											EXEC P0040_INSURANCE_MASTER @Ins_Tran_ID = @Ins_Tran_ID OUTPUT,@Cmp_Id = @Cmp_ID,@Ins_Name = @Insu_Name,
																		@Ins_Desc = @Description,@Type = @Type,@Default_Value = '',@Tran_Type = 'I'
											
										END
									
										Select @Row_ID_ECONTACT =  Isnull(max(Emp_Ins_Tran_ID),0) + 1 from T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)
														
										INSERT INTO T0090_EMP_INSURANCE_DETAIL 
													(Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID,Monthly_Premium,Sal_Effective_Date,Emp_Dependent_ID)
										VALUES      (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@Ins_Tran_ID,@Ins_Cmp_Name,@Ins_Policy_No,@Ins_Taken_Date,@Ins_Due_Date,@Ins_Exp_Date,@Ins_Amount,@Ins_Anual_Amt,@Login_ID,@Monthly_Premium,@Sal_Effective_Date,@Emp_Dependent_ID)	
								
									fetch next from CurInsurance into @CurIns_Emp_Ins_Tran_ID	
								End
						Close CurInsurance                    
					Deallocate CurInsurance
					
						--added jimit 17112015  medical details
						Declare @CurMed_Tran_Id numeric
						Declare @For_date_Med   DATETIME
						--Declare @Description	NVARCHAR(MAX)
						Declare @Medical_Id		Numeric
						Declare @Ins_Name       Varchar(100)
						--Declare @Type			Varchar(20)
						
						Declare CusrMedical cursor for	-- EMP Medical DETAIL
						SELECT Tran_Id 
						FROM T0090_Emp_Medical_Checkup MC WITH (NOLOCK) INNER JOIN
							(
								SELECT max(for_date) AS for_date,Medical_ID 
								FROM T0090_Emp_Medical_Checkup WITH (NOLOCK)
								WHERE Emp_Id = @Curr_emp_ID AND cmp_Id = @curr_cmp_Id
								GROUP BY Medical_ID 
							)qry ON qry.For_Date =  MC.For_Date AND Qry.Medical_ID = MC.MEdical_ID
						WHERE Emp_Id = @Curr_Emp_Id AND Cmp_Id = @Curr_Cmp_Id
						
						Open CusrMedical
							Fetch next from CusrMedical into @CurMed_Tran_Id
							While @@fetch_status = 0                    
								Begin 
										
									 SET @For_date_Med   = ''
									 SET @Description = ''
									 SET @Medical_Id = 0
									 SET @Ins_Name  = ''     
									 SET @Type	= ''									
									
															 										
									SELECT @Ins_Name=Im.ins_name,@Description=MC.[Description],@Type = Im.[Type]
											,@Ins_Tran_ID = Ins_Tran_ID	--,@Medical_Id = Mc.Medical_ID
											,@For_date_Med = Mc.For_Date																											
									FROM T0040_INSURANCE_MASTER IM WITH (NOLOCK) INNER JOIN
												T0090_EmP_Medical_Checkup Mc WITH (NOLOCK) ON IM.Ins_Tran_ID = Mc.Medical_ID 
									WHERE  Im.type = 'Medical' AND Im.Cmp_Id = @Curr_Cmp_Id AND Mc.Tran_Id = @CurMed_Tran_Id
									
									
									IF EXISTS(SELECT 1 FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE Upper(Ins_name) = Upper(@Ins_Name) AND Cmp_ID=@Cmp_ID)  
										BEGIN 										 
											SELECT @Medical_Id  = Ins_Tran_ID FROM T0040_INSURANCE_MASTER WITH (NOLOCK) WHERE Upper(Ins_name) = Upper(@Ins_Name) AND Cmp_ID=@Cmp_ID
										END  
									ELSE  
										BEGIN  
											EXEC P0040_INSURANCE_MASTER @Ins_Tran_ID = @CurMed_Tran_Id OUTPUT,@Cmp_Id = @Cmp_ID,@Ins_Name = @Ins_Name,
																		@Ins_Desc = @Description,@Type = @Type,@Default_Value = '',@Tran_Type = 'I'
											set @Medical_Id  = @CurMed_Tran_Id
										END
										
												
									SELECT @Row_ID_ECONTACT =  Isnull(max(Tran_Id),0) + 1 from T0090_Emp_Medical_Checkup WITH (NOLOCK)
									
									
									INSERT INTO T0090_Emp_Medical_Checkup 
													(Tran_Id,Cmp_ID,Emp_Id,Medical_ID,For_Date,[Description])
									VALUES      (@Row_ID_ECONTACT,@Cmp_ID,@Emp_ID,@Medical_Id,@For_date_Med,@Description)	
													
																					
								
									fetch next from CusrMedical into @CurMed_Tran_Id	
								End
						Close CusrMedical                    
					Deallocate CusrMedical
						
						--ended 
						
								 	
				--'' Update Employee Master Detail ''--
				
				-- '' Update Employee IT Declaration 	 
				
				Declare @Old_IT_Name		VARCHAR(MAX)
				Declare @Old_IT_ID			NUMERIC
				Declare @Old_FOR_DATE		DATETIME 
				Declare @Old_AMOUNT			NUMERIC 
				Declare @Old_DOC_NAME		VARCHAR(MAX)
				Declare @Old_REPEAT_YEARLY  TINYINT
				Declare @Old_AMOUNT_ESS		NUMERIC
				Declare @Old_IT_Flag		TINYINT
				Declare @Old_FINANCIAL_YEAR VARCHAR(20)
				Declare @Old_Is_Lock		AS BIT
				Declare @IT_ID				NUMERIC
				
				SET @Old_Is_Lock = 0
				SET @Old_IT_ID			= 0
				SET @Old_FOR_DATE		= ''
				SET @Old_AMOUNT			= 0
				SET @Old_DOC_NAME		= ''
				SET @Old_REPEAT_YEARLY  = 0
				SET @Old_AMOUNT_ESS		= 0
				SET @Old_IT_Flag		= 0
				SET @Old_FINANCIAL_YEAR = ''
				SET @Old_Is_Lock		= 0
				
				Declare @F_StartDate	DATETIME
				Declare @F_EndDate		DATETIME
				Declare @To_Date		DATETIME
				Declare @FINANCIAL_YEAR VARCHAR(15)
				Declare @Sal_St_Date	DATETIME 
				
				Set @To_Date = GETDATE()
				
				SET @F_StartDate = DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, @To_Date)) - 4)%12), @To_Date ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, @To_Date)) - 4)%12),@To_Date ))+1 ) )
				SET @F_EndDate = DATEADD(SS,-1,DATEADD(mm,12,@F_StartDate))
				  
				SET @FINANCIAL_YEAR = Cast(Year(@F_StartDate) as Varchar(4))+'-'+ Cast(year(@F_EndDate) As Varchar(4))
				
				
				IF Exists(SELECT 1 FROM T0100_IT_DECLARATION WITH (NOLOCK) WHERE EMP_ID = @Curr_Emp_Id And FINANCIAL_YEAR = @FINANCIAL_YEAR)
					Begin
						Declare CusrIT cursor for	                 
							SELECT IT_ID ,FOR_DATE, AMOUNT, DOC_NAME, REPEAT_YEARLY, AMOUNT_ESS, IT_Flag, FINANCIAL_YEAR,Is_Lock
							FROM T0100_IT_DECLARATION WITH (NOLOCK) WHERE EMP_ID = @Curr_Emp_Id And FINANCIAL_YEAR = @FINANCIAL_YEAR 
							
							Open CusrIT
								Fetch next from CusrIT into @Old_IT_ID,@Old_FOR_DATE,@Old_AMOUNT,@Old_DOC_NAME, @Old_REPEAT_YEARLY, @Old_AMOUNT_ESS, @Old_IT_Flag, @Old_FINANCIAL_YEAR,@Old_Is_Lock
								While @@fetch_status = 0                    
									Begin 
			 							SET @Old_IT_Name = ''
										SET @IT_ID = 0
										
										SELECT @Old_IT_Name = IT_Name FROM T0070_IT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Curr_Cmp_ID AND IT_ID = @Old_IT_ID
										SELECT @IT_ID = IT_ID FROM T0070_IT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And UPPER(IT_Name) = UPPER(@Old_IT_Name)
									
										IF @IT_ID > 0
											Begin
   												EXEC P0100_IT_DECLARATION 0,@Cmp_ID,@IT_ID,@EMP_ID,@Old_FOR_DATE,@Old_AMOUNT,@Old_DOC_NAME,0,@Old_REPEAT_YEARLY,'Insert',@Old_AMOUNT_ESS,@Old_IT_Flag,@Old_FINANCIAL_YEAR,@Old_Is_Lock,0,''
											End
											
										fetch next from CusrIT into @Old_IT_ID,@Old_FOR_DATE,@Old_AMOUNT,@Old_DOC_NAME, @Old_REPEAT_YEARLY, @Old_AMOUNT_ESS, @Old_IT_Flag, @Old_FINANCIAL_YEAR,@Old_Is_Lock
									End
							Close CusrIT                    
						Deallocate CusrIT
						
						Declare @Date Datetime				---- IT For Employee Detail
						Declare @Amount_IT numeric(18,2) 
						Declare @Detail_1 varchar(Max) 
						Declare @Detail_2 varchar(Max) 
						Declare @Detail_3 varchar(Max) 
						Declare @Comments_IT varchar(Max) 
						Declare @Op as tinyint 
						Declare @FileName varchar(200) 
						Declare @IT_Def_ID Numeric(18,0)
						
						SET @Old_IT_ID	= 0
						SET @Amount_IT	= 0.0
						SET @Date		= NULL
						SET @Detail_1	= ''
						SET @Detail_2	= ''
						SET @Detail_3	= ''
						SET @Comments_IT	= ''	 
						SET @Op			= 0
						SET @FileName	= ''
						SET @IT_Def_ID	= 0
						
						Declare CusrITEmp_Details cursor for	                 
							SELECT Financial_Year,IT_ID,[Date],Amount,Detail_1,Detail_2,Detail_3,Comments,FileName
							FROM T0110_IT_Emp_Details WITH (NOLOCK) WHERE EMP_ID = @Curr_Emp_Id And FINANCIAL_YEAR = @FINANCIAL_YEAR
							
							Open CusrITEmp_Details
								Fetch next from CusrITEmp_Details into @Financial_Year,@Old_IT_ID,@Date,@Amount_IT,@Detail_1,@Detail_2,@Detail_3,@Comments_IT,@FileName
								While @@fetch_status = 0                    
									Begin 
			 							SET @Old_IT_Name = ''
			 							SET @IT_ID = 0
			 							SET @IT_Def_ID = 0
			 							SET @Op = 0
										
										SELECT @Old_IT_Name = IT_Name FROM T0070_IT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Curr_Cmp_ID AND IT_ID = @Old_IT_ID
										SELECT @IT_ID = IT_ID , @IT_Def_ID = IT_Def_ID FROM T0070_IT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And UPPER(IT_Name) = UPPER(@Old_IT_Name)
										
										IF @IT_Def_ID = 1
											SET @Op = 0
										Else IF @IT_Def_ID = 153
											SET @Op = 3
										Else
											SET @Op = 2	
											
										IF @Old_IT_ID = 0
											BEGIN
												SET @IT_ID  = 0
												SET @Detail_1 = 'Other Documents'
												SET @Op = 1
											END	
											
										IF @IT_ID >= 0
											Begin
   												EXEC P0110_IT_Emp_Details @Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,@Amount_IT,@Detail_1,@Detail_2,@Detail_3,@Comments_IT,@Op,@FileName,0
											End
											
										fetch next from CusrITEmp_Details into @Financial_Year,@Old_IT_ID,@Date,@Amount_IT,@Detail_1,@Detail_2,@Detail_3,@Comments_IT,@FileName
									End
							Close CusrITEmp_Details                    
						Deallocate CusrITEmp_Details
					End			 
					
		End
	Else if @Tran_Type = 'U'
		begin
					
			--If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code and Emp_ID <> @Emp_ID)
			--	begin			
					
			--		set @Emp_ID = 0
			--			RAISERROR ('Already Exist Employee Code', 16, 2)
			--		return  
			--	end
					
					
				--If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Emp_code = @Emp_Code and Emp_ID <> @Emp_ID)
				--	begin
				--		set @Emp_ID = 0
				--		return  
				--	end
				
				
					
					declare @Emp_Superior_o as numeric(18,0)
					declare @Old_Code_Date as varchar(50) 
					declare @Old_Code_Date_Format as varchar(50) 
				
					select @old_Join_Date = DAte_of_join ,@Increment_ID = Increment_ID,@Emp_Superior_o=Emp_Superior, @Old_Code_Date = Code_Date,@Old_Code_Date_Format = Code_Date_Format From dbo.T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID
					
					-- zalak audit trail for employee data updates -- 14-oct-2010
					--exec GenerateAudittrail 'T0080_EMP_MASTER',0,@cmp_id--comment this line at clinet side
					----
			 
					if @Emp_Superior = 0 
						set @Emp_Superior =NULL	
					
					---Update Company Transfer---
					Update  dbo.T0095_EMP_COMPANY_TRANSFER	--Employee Information
					Set		Effective_Date=@Date_Of_Join,
							New_Cmp_id=@Cmp_id,
							New_Emp_Id=@Emp_Id,
							New_Branch_Id=@Branch_Id,
							New_Grd_Id=@Grd_Id,
							New_Desig_Id = @Desig_Id,
							New_Dept_Id = @Dept_Id,
							New_Shift_Id=@Shift_Id,
							New_Type_Id = @Type_Id,
							New_Cat_Id = @Cat_Id,
							New_Client_Id = @Client_Id,
							New_Emp_Mngr_Id = @Emp_Superior,
							New_Emp_Weekoff_Day =@New_Weekoff_Day,
							New_Privilege_ID = @New_Privilege,							
							New_SubBranch_ID= @New_SubBranch_ID,
							New_SubVertical_ID= @New_SubVertical_ID,
							New_Segment_ID= @New_Segment_ID,  --Ronakb260224
							New_SalCycle_ID	= @New_SalCycle_ID,					
							ReplaceManager_Cmp_ID=@ReplaceManager_Cmp_ID, --Mukti(01082016)
							ReplaceManager_ID=@ReplaceManager --Mukti(01082016)
					Where	Tran_Id = @Tran_Id
					
					Update  dbo.T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL	--Salary Detail
					Set	    New_Cmp_Id = @Cmp_ID,
							New_Emp_Id = @Emp_ID,
							New_Basic_Salary = @Basic_Salary,
							New_Gross_Salary = @Gross_Salary,
							New_CTC =@CTC					
					where   Tran_Id = @Tran_Id
					
					------	
					
					UPDATE dbo.T0080_EMP_MASTER
					SET    Branch_ID = @Branch_ID,
						   Cat_ID = @Cat_ID,
						   Grd_ID = @Grd_ID,
						   Dept_ID = @Dept_ID,
						   Desig_Id = @Desig_ID, 
						   Type_ID = @Type_ID,
						   Shift_ID = @Shift_ID,
						   Bank_ID = @Bank_ID,
						   --Emp_code = @Emp_code,
						   Initial = @Initial,
						   Emp_First_Name = @Emp_First_Name, 
						   Emp_Second_Name = @Emp_Second_Name,
						   Emp_Last_Name = @Emp_Last_Name,
						   Curr_ID = @Curr_ID,
						   Date_Of_Join = @Date_Of_Join, 
						   SSN_No = @SSN_No,
						   SIN_No = @SIN_No,
						   Dr_Lic_No = @Dr_Lic_No,
						   Pan_No = @Pan_No,
						   Date_Of_Birth = @Date_Of_Birth, 
						   Marital_Status = @Marital_Status,
						   Gender = @Gender,
						   Dr_Lic_Ex_Date = @Dr_Lic_Ex_Date,
						   Nationality = @Nationality,
						   Loc_ID = @Loc_ID, 
						   Street_1 = @Street_1,
						   City = @City,
						   State = @State,
						   Zip_code = @Zip_code,
						   Home_Tel_no = @Home_Tel_no, 
						   Mobile_No = @Mobile_No,
						   Work_Tel_No = @Work_Tel_No,
						   Work_Email = @Work_Email,
						   Other_Email = @Other_Email, 
						   Emp_Superior=@Emp_Superior,
						   Basic_Salary = @Basic_Salary,
						   Emp_Full_Name  = @Emp_Full_Name,
						   Present_Street=@Present_Street,
						   Present_City=@Present_City,
						   Present_State=@Present_State,
						   Present_Post_Box=@Present_Post_Box,  
						   enroll_No  = @enroll_No,  
						   Tally_Led_Name =  @Tall_Led_Name,
						   Religion=@Religion, 
						   Height=@Height,  
						   Emp_Mark_Of_Identification=@Mark_Of_Idetification, 
						   Despencery=@Dispencery,
						   Doctor_Name=@Doctor_name, 
						   DespenceryAddress=@DispenceryAdd, 
						   Insurance_No=@Insurance_No, 
						   Is_Gr_App=@Is_Gr_App,
						   Is_Yearly_Bonus=@Is_Yearly_Bonus,
						   Yearly_Leave_Days=@Yearly_Leave_Days,
						   Yearly_Leave_Amount =@Yearly_Leave_Amount,
						   Yearly_Bonus_Per=@Yearly_Bonus_Per,
						   Yearly_Bonus_Amount=@Yearly_Bonus_Amt,
						   Emp_Confirm_Date = @Emp_Confirmation_date,
						   Is_On_Probation =@Is_On_Probation,
						   Tally_Led_ID=@Tally_Led_ID,
						   Blood_Group=@Blood_Group,
						   Probation=@Probation,
						   Father_Name=@Father_Name,
						   Bank_BSR=@Bank_BSR_No,
						   login_id = @login_Id,
						   system_date=Getdate(),
						   Old_Ref_No=@Old_Ref_No,
						   --Alpha_Code = @Alpha_Code ,
						   --Alpha_Emp_Code = @Alpha_Emp_Code ,
						   Ifsc_Code=@Ifsc_Code,--Nikunj 13-06-2011
						   Leave_In_Probation=@Leave_In_Probation,--Nikunj 15-06-2011
						   Is_LWF = @Is_LWF, --Hardik 24/06/2011
						   DBRD_Code=@DBRD_Code,  --'Alpesh 23-Sep-2011
						   Dealer_Code=@Dealer_Code,
						   CCenter_Remark=@CCenter_Remark,	
						   Emp_PF_Opening = @Emp_PF_Opening,  -- Added by Mihir 01022012	
						   Emp_Category= @Emp_Category , -- Added by Mihir 15032012	
						   Emp_UIDNo = @Emp_UIDNo,-- Added by Mihir 15032012
						   Emp_Cast = @Emp_Cast,		-- Added by Mihir 15032012
						   Emp_Annivarsary_Date = @Emp_Anniversary_Date,
						   Extra_AB_Deduction = @Extra_AB_Deduction,	---Alpesh 19-Mar-2012
						   CompOff_Min_hrs = @Min_CompOff_Limit 
						   ,mother_name = @mother_name
						   ,Min_Wages= @Min_Wages --- Jignesh 09_Oct_2012
						   ,Emp_Offer_Date = @Emp_Offer_date
						    ,Segment_ID =@New_Segment_ID 
						   ,Vertical_ID =@Client_Id
						   ,SubVertical_ID = @New_SubVertical_ID
						   ,GroupJoiningDate = @GroupJoiningDate
						   ,subBranch_ID = @New_SubBranch_ID
						   ,Bank_ID_Two= @Bank_ID_Two
						   ,Ifsc_Code_Two = @Ifsc_Code_Two
						 --  ,code_date = @Old_Code_Date
						--   ,code_date_Format = @Old_Code_Date_Format
						    -- Added By Ali 19112013 -- Start
						   ,EmpName_Alias_PrimaryBank = @EmpName_Alias_PrimaryBank
						   ,EmpName_Alias_SecondaryBank = @EmpName_Alias_SecondaryBank 
						   ,EmpName_Alias_PF = @EmpName_Alias_PF
						   ,EmpName_Alias_PT = @EmpName_Alias_PT
						   ,EmpName_Alias_Tax = @EmpName_Alias_Tax
						   ,EmpName_Alias_ESIC = @EmpName_Alias_ESIC
						   ,EmpName_Alias_Salary = @EmpName_Alias_Salary
						   -- Added By Ali 19112013 -- End
						   ,Emp_Notice_Period = @Emp_Notice_Period
						 
							,UAN_No =@UAN_No									--added jimit 17112015				
							,Date_of_Retirement = @Date_Of_Retirenment			--added jimit 17112015
							,Emp_Dress_Code	=@Emp_Dress_Code					--added jimit 17112015
							,Emp_Shirt_Size	= @Emp_Shirt_Size					--added jimit 17112015
							,Emp_Pent_Size	= @Emp_pent_Size					--added jimit 17112015
							,Emp_Shoe_Size	= @Emp_Shoe_Size					--added jimit 17112015
							,Emp_Canteen_Code = @Emp_Canteen_Code				--added jimit 17112015
							,Vehicle_No  = @Vehicle_No							--added jimit 17112015
							,Aadhar_Card_No = @Aadhar_Card_No					--added jimit 17112015
							,Ration_Card_No = @Ration_Card_No					--added jimit 17112015
							,Ration_Card_Type = @Ration_Card_Type --added by Niraj(02022022)
							,Extension_No = @Extension_No --added by Niraj(02022022)
							,Actual_Date_Of_Birth = Actual_Date_Of_Birth		--added jimit 17112015
							,Tehsil = @Tehsil									--added jimit 17112015
							,Tehsil_Wok = @Tehsil_Work							--added jimit 17112015
							,District = @District								--added jimit 17112015
							,District_Wok = @District_Work						--added jimit 17112015
							,Thana_Id = @Thana									--added jimit 17112015
							,Thana_Id_Wok = @Thana_Work							--added jimit 17112015
							,CompOff_HO_App_Days= @CompOff_HO_App_Days 			--added jimit 17112015
							,CompOff_HO_Avail_Days = @CompOff_HO_Avail_Days		--added jimit 17112015
							,CompOff_WO_App_Days = @CompOff_WO_App_Days			--added jimit 17112015
							,CompOff_WO_Avail_Days = @CompOff_WO_Avail_Days		--added jimit 17112015
							,CompOff_WD_App_Days = @CompOff_WD_App_Days			--added jimit 17112015
							,CompOff_WD_Avail_Days = @CompOff_WD_Avail_Days		--added jimit 17112015	
					WHERE   Emp_ID = @Emp_ID And cmp_Id=@Cmp_Id	
					
					
					INSERT INTO dbo.T0080_EMP_MASTER_Clone
									  (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name, 
									  Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality, 
									  Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,
									  Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation,
									  Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,Is_LWF,
									  DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast,Emp_Annivarsary_Date,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Segment_ID,Vertical_ID
									  ,SubVertical_ID,GroupJoiningDate,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,Code_Date
									  ,Code_Date_Format,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT
									  ,EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Date_of_Retirement,
										Emp_Dress_Code,Emp_Pent_Size,Emp_Shirt_Size,Emp_Shoe_Size,Emp_Canteen_Code,Aadhar_Card_No,Tehsil,Tehsil_Wok,District,District_Wok,Thana_Id,Thana_Id_Wok
										,CompOff_HO_App_Days ,CompOff_HO_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days,CompOff_WD_App_Days,CompOff_WD_Avail_Days,Yearly_Bonus_Amount)
							VALUES     (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,
										@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,
										@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,
										@Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation,
										@Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,@Is_LWF,
										@DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast
										,@Emp_Anniversary_Date,@Extra_AB_Deduction,@Min_CompOff_Limit,@mother_name,@New_Segment_ID,@Client_Id
										,@New_SubVertical_ID,@GroupJoiningDate,@New_SubBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two,@Old_Code_Date
										,@Old_Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF
										,@EmpName_Alias_PT,@EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Date_Of_Retirenment,
										@Emp_Dress_Code,@Emp_Pent_Size,@Emp_Shirt_Size,@Emp_Shoe_Size,@Emp_Canteen_Code,@Aadhar_Card_No,@Tehsil,@Tehsil_Work,@District,@District_Work,@Thana,@Thana_Work
										,@CompOff_HO_App_Days ,@CompOff_HO_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_WD_App_Days,@CompOff_WD_Avail_Days,@Yearly_Bonus_Amt)
												
					---Update Query Update by Nikunj 16-04-2011 Please Every where Put Cmp_Id and in where So Sometimes it creates problem
			
					--Set @loginname = cast(@Emp_Code as varchar(10))  +  @Domain_Name	
				--	If @Alpha_Emp_Code is NOT NULL
				--	Begin 			  
						
				--		Set @loginname = cast(@Alpha_Emp_Code as varchar(50)) + @Domain_Name
				--	End
				--Else
				--	Begin
					
				--		Set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name	
				--	End					
					
				--	Update T0011_Login
				--	set Login_Name = @loginname
				--	   -- Branch_ID = @Branch_Id
				--	where Emp_ID = @Emp_ID 
					
					SET @Increment_ID  =ISNULL(@Increment_ID ,0)
					EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,@Old_Join_Date
				
					EXEC P0095_INCREMENT_INSERT	@Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join ,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@emp_superior,@Dep_Reminder,1,@CTC,0,0,0,0,0,0,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID, @Emp_wd_ot_rate, @Emp_wo_ot_rate, @Emp_ho_ot_rate,0,0,0,0,@no_of_chlidren,@is_metro,@is_physical,@New_SalCycle_id,@Auto_Vpf,@New_Segment_ID,@Client_Id,@New_SubVertical_ID,@New_SubBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Inc_Bank_AC_No_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,@Reason_ID,@Reason_Name,@User_Id,@IP_Address,@Customer_Audit,@Old_Join_Date,@Sales_Code,@Physical_Percent
					
					Select @for_date = increment_effective_date from T0095_Increment WITH (NOLOCK) where Increment_ID=@Increment_ID
										
					
				
					EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@for_date,@Old_Join_Date
					
					---Alpesh 26-Mar-2012
					Declare @Reporting_Row_ID numeric
					
					if @Emp_Superior is not null
						begin							
							if not exists(Select Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=@Emp_Superior)
							begin								
								exec P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@Emp_Superior,'Direct','i',@Login_Id								
							end
						end
					else                                 ----if @Emp_Superior is null
						begin
							
							Select @Reporting_Row_ID = Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=isnull(@Emp_Superior_o,0)
							
							if @Reporting_Row_ID is null
								set @Reporting_Row_ID = 0
							
							exec P0090_EMP_REPORTING_DETAIL @Reporting_Row_ID,@Emp_ID,@Cmp_ID,'',@Emp_Superior,'Direct','d',@Login_Id
						end
					---End
					
					--zalak for manager history--190111
					if @Emp_Superior_o<>@Emp_Superior
						exec P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@Emp_Superior,@Date_Of_Join			
						
						
				 if not exists (SELECT 1 from T0011_LOGIN WITH (NOLOCK) where Login_Alias = isnull(@New_Login_Alias,'') AND Emp_ID <> @Emp_ID)
					begin
						update T0011_LOGIN SET login_alias = isnull(@New_Login_Alias,'') where Emp_ID = @Emp_ID
					end
					
					
					--added jimit 29122015	
					
					--insert into T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY(Emp_id,Old_R_Emp_id,New_R_Emp_id,Cmp_id,Change_date,Comment)
					--	select emp_ID,R_Emp_ID,@ReplaceManager,Cmp_ID,GETDATE(),'Left' from T0090_EMP_REPORTING_DETAIL where  R_Emp_ID = @Curr_Emp_ID
					--DECLARE @New_R_Emp_id as NUMERIC
					Declare @R_Cmp_Id Numeric	
					Declare @R_Desig_Id Numeric
					--select @New_R_Emp_id = New_R_Emp_id from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY where  Old_R_Emp_id = @Emp_ID
					
					--UPDATE T0090_EMP_REPORTING_DETAIL 
					--	SET  R_Emp_ID = @ReplaceManager ,Effect_date = @Increment_Effective_Date
					--	WHERE R_Emp_ID = @New_R_Emp_id 
					
					--Update T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY set New_R_Emp_id = @ReplaceManager, Change_date = GETDATE()  where Old_R_Emp_id = @Emp_ID
					
					
					select @R_Cmp_Id = cmp_Id from t0080_emp_master WITH (NOLOCK) where emp_Id = @ReplaceManager
					
					if @R_Cmp_Id <> @Curr_Cmp_Id
						BEGIN
							Set	@R_Desig_Id = 0 
						End
					--ELSE
					--	BEGIN
					--		Set	@R_Desig_Id = @Desig_Id 
					--	End
					
					UPDATE T0050_Scheme_Detail	
					SET		App_Emp_ID = @ReplaceManager ,R_Desg_Id = @R_Desig_Id,
							R_Cmp_Id = @R_Cmp_Id					
					WHERE Is_RM = 0 AND 
						  App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Curr_Emp_ID)

					Update T0051_Scheme_Detail_History
					SET New_App_Emp_ID = @ReplaceManager , System_date = GETDATE()
						,Cmp_Id = @R_Cmp_Id
					WHERE New_App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Curr_Emp_ID)	

					
					---ended--------
							
		   end
	Else If @Tran_Type = 'D'
		Begin 
			Update dbo.T0080_EMP_MASTER  Set Increment_ID = Null Where Emp_ID = @Emp_ID And cmp_Id=@Cmp_Id 			
			Delete From T0090_EMP_CHILDRAN_DETAIL			Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_CONTRACT_DETAIL			Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_DEPENDANT_DETAIL			Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_DOC_DETAIL				Where		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_EMERGENCY_CONTACT_DETAIL	Where		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_EXPERIENCE_DETAIL			Where		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_IMMIGRATION_DETAIL		Where		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_LANGUAGE_DETAIL			Where		Emp_ID  = @emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_LICENSE_DETAIL			Where		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_QUALIFICATION_DETAIL		Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_REPORTING_DETAIL			Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID
			Delete From T0090_EMP_SKILL_DETAIL				Where		Emp_ID	= @Emp_ID And cmp_Id=@Cmp_ID			
			DELETE FROM T0110_EMP_LEFT_JOIN_TRAN			WHERE		EMP_ID	= @EMP_ID And cmp_Id=@Cmp_ID
			DELETE FROM T0100_EMP_EARN_DEDUCTION			WHERE		EMP_ID	= @EMP_ID And cmp_Id=@Cmp_ID
			DELETE from T0100_Emp_Manager_History			where		Emp_id = @Emp_ID and Cmp_Id=@Cmp_Id--Added By Falak on 19-APR-2011
			DELETE FROM T0095_INCREMENT						WHERE		EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID
			DELETE FROM T0100_WEEKOFF_ADJ					WHERE		EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID
			DELETE FROM T0100_EMP_SHIFT_DETAIL				WHERE		EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID
			DELETE FROM T0140_ADVANCE_TRANSACTION			WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID
			DELETE FROM T0140_LOAN_TRANSACTION			    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID
			DELETE FROM T0140_CLAIM_TRANSACTION			    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID
			DELETE FROM T0140_LEAVE_TRANSACTION			    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	
			DELETE FROM T0190_MONTHLY_AD_DETAIL_IMPORT	    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	
			DELETE FROM T0090_Emp_Medical_Checkup			WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	  --added jimit 05112015
			DELETE FROM T0090_EMP_REFERENCE_DETAIL			WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	  --added jimit 05112015
			DELETE FROM T0090_EMP_INSURANCE_DETAIL			WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	  --added jimit 05112015
			DELETE FROM T0190_MONTHLY_PRESENT_IMPORT	    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	

			
			DELETE FROM T0095_LEAVE_OPENING				    WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	-- Added by Mitesh on 27/07/2011	
			
			Declare @Leave_Approval_ID as numeric(18,0)														-- Added by Mitesh on 27/07/2011	
			Select @Leave_Approval_ID=Leave_Approval_ID FROM T0120_LEAVE_APPROVAL	WITH (NOLOCK)			WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	-- Added by Mitesh on 27/07/2011						
			
			DELETE FROM T0130_LEAVE_APPROVAL_DETAIL			WHERE		Leave_Approval_ID = @Leave_Approval_ID And cmp_Id=@Cmp_ID	-- Added by Mitesh on 27/07/2011	
			DELETE FROM T0120_LEAVE_APPROVAL				WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	-- Added by Mitesh on 27/07/2011	
			delete FROM T0090_Common_Request_Detail where @Emp_ID = @Emp_ID and cmp_id = @Cmp_ID -- Added by Mitesh on 05042013
			Declare @DLogin_ID as numeric(18,0)														-- Added by Mitesh on 27/07/2011	
			Select @DLogin_ID=Login_ID FROM T0011_Login	WITH (NOLOCK)	WHERE		EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID	-- Added by Mitesh on 27/07/2011									
			
			Delete From T0011_LOGIN_HISTORY					WHERE		Login_ID  = @DLogin_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011									
			Delete From T0015_LOGIN_FORM_RIGHTS				WHERE		Login_ID  = @DLogin_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011									
			Delete From T0011_Login			                WHERE		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID
			
			Delete From T0150_EMP_INOUT_RECORD              WHERE		Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011									
			
			delete FROM T0095_Emp_Salary_Cycle where Emp_id = @Emp_ID -- added by mitesh on 06072013
			delete from T0250_Change_Password_History where emp_id=@Emp_ID -- added by rohit on 12082013
			DELETE FROM dbo.T0080_EMP_MASTER	            WHERE       Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID
			
		End	
	RETURN
	

