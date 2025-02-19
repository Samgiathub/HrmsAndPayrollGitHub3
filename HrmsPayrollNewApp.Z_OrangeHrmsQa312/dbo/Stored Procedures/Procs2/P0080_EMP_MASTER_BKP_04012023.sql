
  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_BKP_04012023]
 @Emp_ID   numeric(18,0) output  
   ,@Cmp_ID   numeric(18,0)  
   ,@Branch_ID  numeric(18,0)  
   ,@Cat_ID   numeric(18,0)  
   ,@Grd_ID   numeric(18,0)  
   ,@Dept_ID  numeric(18,0)  
   ,@Desig_Id  numeric(18,0)  
   ,@Type_ID  numeric(18,0)  
   ,@Shift_ID  numeric(18,0)  
   ,@Bank_ID  numeric(18,0)  
   ,@Increment_ID numeric(18,0) output  
   ,@Emp_code  numeric(18,0)  
   ,@Initial  varchar(10)  
   ,@Emp_First_Name varchar(100)  
   ,@Emp_Second_Name varchar(100)  
   ,@Emp_Last_Name varchar(100)  
   ,@Curr_ID  numeric(18,0)  
   ,@Date_Of_Join datetime  
   ,@SSN_No   varchar(30)  
   ,@SIN_No   varchar(30)  
   ,@Dr_Lic_No  varchar(30)  
   ,@Pan_No   varchar(30)  
   ,@Date_Of_Birth  DATETIME = null  
   ,@Marital_Status varchar(20)  
   ,@Gender   char(1)  
   ,@Dr_Lic_Ex_Date DATETIME = NULL  
   ,@Nationality varchar(20)  
   ,@Loc_ID   numeric(18,0)  
   ,@Street_1  varchar(250)  
   ,@City   varchar(30)  
   ,@State   varchar(20)  
   ,@Zip_code  varchar(20)  
   ,@Home_Tel_no varchar(30)  
   ,@Mobile_No  varchar(30)  
   ,@Work_Tel_No varchar(30)  
   ,@Work_Email  varchar(50)  
   ,@Other_Email varchar(50)  
   ,@Present_Street varchar(250)  
   ,@Present_City   varchar(30)  
   ,@Present_State  varchar(60)  
   ,@Present_Post_Box varchar(20)  
   ,@Emp_Superior   numeric(18)  
   ,@Basic_Salary numeric(18,2)  
   ,@Image_Name  varchar(100)  
   ,@Wages_Type  varchar(10)  
   ,@Salary_Basis_On varchar(15)  
   ,@Payment_Mode varchar(20)  
   ,@Inc_Bank_AC_No varchar(20)  
   ,@Emp_OT   numeric(18)  
   ,@Emp_OT_Min_Limit varchar(10)  
   ,@Emp_OT_Max_Limit varchar(10)  
   ,@Emp_Late_mark Numeric(18)  
   ,@Emp_Full_PF Numeric(18)  
   ,@Emp_PT   Numeric(18)  
   ,@Geo numeric(18)
   ,@Emp_Fix_Salary Numeric(18)  
   ,@tran_type  char(1)  
   ,@Gross_salary numeric(22,2)=0  
   ,@Tall_Led_Name varchar(250)  
   ,@Religion varchar(50)  
   ,@Height  varchar(50)  
   ,@Mark_Of_Idetification varchar(250)  
   ,@Dispencery varchar(50)  
   ,@Doctor_name varchar(100)  
   ,@DispenceryAdd varchar(250)  
   ,@Insurance_No varchar(50)  
   ,@Is_Gr_App tinyint  
   ,@Is_Yearly_Bonus numeric(5, 2)  
   ,@Yearly_Leave_Days numeric(7, 2)  
   ,@Yearly_Leave_Amount numeric(7, 2)  
   ,@Yearly_Bonus_Per numeric(5, 2)  
   ,@Yearly_Bonus_Amount numeric(7, 2)  
   ,@Emp_Late_Limit varchar(10)  
   ,@Late_Dedu_Type varchar(10)  
   ,@Emp_Part_Time  numeric(10)  
   ,@Emp_Confirmation_date dateTime  
   ,@Is_On_Probation numeric(1,0)  
   ,@Tally_Led_ID numeric(18,0)  
   ,@Blood_Group varchar(10)  
   ,@Probation numeric(18,2)  
   ,@enroll_No numeric(18,0)  
   ,@Dep_Reminder tinyint=1  
   ,@Adult_NO numeric(18,0) = 0  
   ,@Father_Name varchar(100)  
   ,@Bank_BSR_No varchar(100)  
   ,@Old_Ref_No Varchar(50)=NULL  
   ,@Login_Id int = 0  
   ,@Alpha_Code varchar(100) = ''  
   ,@Chg_Pwd int = 0  -- Added By Alpesh on 25-05-2011 for first time login change password dialogbox for employee   
   ,@Ifsc_Code Varchar(50)=NULL--Added By Nikunj on 13-June-2011  
   ,@Leave_In_Probation As TinyInt=0  
   ,@Is_LWF As tinyInt = 0  
   ,@CTC Numeric(18,2)  
   ,@Emp_Early_mark numeric(1, 0) = 0  
   ,@Early_Dedu_Type varchar(10) = ''  
   ,@Emp_Early_Limit varchar(10) = '00:00'  
   ,@Emp_Deficit_mark numeric(1, 0) = 0  
   ,@Deficit_Dedu_Type varchar(10)  = ''  
   ,@Emp_Deficit_Limit varchar(10) = ''  
   ,@Center_ID numeric(18,0) --'Alpesh 23-Sep-2011  
   ,@DBRD_Code varchar(50)  
   ,@Dealer_Code varchar(50)  
   ,@CCenter_Remark varchar(500)  
   ,@Emp_wd_ot_rate numeric(5,3) = 0  
   ,@Emp_wo_ot_rate numeric(5,3) = 0  
   ,@Emp_ho_ot_rate numeric(5,3) = 0  
   ,@Emp_PF_Opening numeric(18,2) = 0  
   ,@Emp_Category varchar(50) = ''   -- Added by Mihir 15032012  
   ,@Emp_UIDNo varchar(25) = ''       -- Added by Mihir 15032012  
   ,@Emp_Cast varchar(50) = ''       -- Added by Mihir 15032012  
   ,@Emp_Anniversary_Date Varchar(25) = '' -- Added by Mihir 15032012  
   ,@Extra_AB_Deduction numeric(18,2) = 0.0 ---Alpesh 19-Mar-2012  
   ,@Min_CompOff_Limit varchar(10) = '00:00'  
   ,@mother_name varchar(100) = ''  
   ,@no_of_chlidren numeric =  0  
   ,@is_metro tinyint = 0  
   ,@is_physical tinyint = 0  
   ,@Min_Wages numeric(18,2) = 0  --- Jignesh 09_Oct_2012  
   ,@Emp_Offer_date dateTime = ''  
   ,@Login_Alias varchar(100) = ''  
   ,@Salary_Cycle_id numeric = 0  
   ,@Auto_vpf numeric(18) = 0  
   ,@Segment_ID numeric = 0  ---Added by Gadriwala Muslim on 20/07/2013  
   ,@Vertical_ID numeric =0  ---Added by Gadriwala Muslim on 20/07/2013  
   ,@SubVertical_ID numeric =0 ---Added by Gadriwala Muslim on 20/07/2013  
   ,@GroupJoiningDate datetime = Null -- Added by Gadriwala Muslim on 20/07/2013  
   ,@subBranch_ID numeric = 0 -- ---Added by Gadriwala Muslim on 30/07/2013  
   ,@Monthly_Deficit_Adjust_OT_Hrs tinyint =0   --Ankit 25102013  
   ,@Fix_OT_Hour_Rate_WD numeric(18,3)=0  --Ankit 29102013  
   ,@Fix_OT_Hour_Rate_WO_HO numeric(18,3)=0  --Ankit 29102013  
   ,@Bank_ID_Two numeric(18,2) = 0   -- Added by Ali 14112013  
   ,@Payment_Mode_Two varchar(20) = ''  -- Added by Ali 14112013   
   ,@Inc_Bank_AC_No_Two varchar(20) = '' -- Added by Ali 14112013  
   ,@Bank_Branch_Name varchar(50) = ''  -- Added by Ali 14112013  
   ,@Bank_Branch_Name_Two varchar(50) = '' -- Added by Ali 14112013  
   ,@Ifsc_Code_Two varchar(50) = ''  -- Added by Ali 14112013  
   ,@Code_Date_Format varchar(20) = ''  
   ,@Code_Date varchar(20) = ''  
     
   -- Added by Ali 14112013 -- Start  
   ,@EmpName_Alias_PrimaryBank varchar(100) = ''  
   ,@EmpName_Alias_SecondaryBank varchar(100) = ''  
   ,@EmpName_Alias_PF varchar(100) = ''  
   ,@EmpName_Alias_PT varchar(100) = ''  
   ,@EmpName_Alias_Tax varchar(100) = ''  
   ,@EmpName_Alias_ESIC varchar(100) = ''  
   ,@EmpName_Alias_Salary varchar(100) = ''  
   -- Added by Ali 14112013 -- End  
     
   -- Added by Ali 29112013 -- Start  
   ,@Emp_Notice_Period numeric(18,0) = 0  
   -- Added by Ali 29112013 -- End  
     
   -- Added by Ali 25032014 -- Start  
   ,@Dress_Code as varchar(50) = ''  
   ,@Shirt_Size as varchar(50) = ''  
   ,@Pent_Size as varchar(50) = ''  
   ,@Shoe_Size as varchar(50) = ''  
   ,@Canteen_Code as varchar(50) = ''  
   -- Added by Ali 25032014 -- End  
     
   -- Added by Ali 03042014 -- Start  
   ,@Thana_Id as numeric = 0  
   ,@Tehsil as varchar(50) = ''  
   ,@District as varchar(50) = ''  
   ,@Thana_Id_Wok as numeric = 0  
   ,@Tehsil_Wok as varchar(50) = ''  
   ,@District_Wok as varchar(50) = ''  -- Added by Ali 03042014 -- End  
   ,@SkillType_ID as numeric = 0 -- Added by Gadriwala 24042014  
   ,@UAN_No varchar(100)='' -- Hardik 07/10/2014  
   ,@CompOff_WO_App_Days as numeric(18,2) = 0 -- Added by Gadriwala 20112014  
   ,@CompOff_WO_Avail_Days as numeric(18,2)= 0 -- Added by Gadriwala 20112014  
   ,@CompOff_WD_App_Days as numeric(18,2)= 0 -- Added by Gadriwala 20112014  
   ,@CompOff_WD_Avail_Days as numeric(18,2)= 0 -- Added by Gadriwala 20112014  
   ,@CompOff_HO_App_Days as numeric(18,2)= 0 -- Added by Gadriwala 20112014  
   ,@CompOff_HO_Avail_Days as numeric(18,2)= 0 -- Added by Gadriwala 20112014  
   ,@Date_Of_Retirement  DATETIME = null -- Added by Nilesh Patel on 29012015  
   ,@Is_Salary_Depends_On_Production_Details as numeric(2,0)= 0 -- Added by Nilesh Patel on 11032015  
   ,@Ration_Card_Type As Varchar(10) = 'APL' --Added by Nimesh 2015-05-09  
   ,@Ration_Card_No As Varchar(50) = '' --Added by Nimesh 2015-05-09  
   ,@Vehicle_NO as VarChar(50) = '' --added jimit 15052015  
   ,@Training_Month AS Numeric(18,2) = 0  --Added by nilesh  patel on 29052015   
   ,@Is_On_Training As Numeric(2,0) = 0 -- Added by nilesh patel on 29052015  
   ,@Aadhar_Card_No as Varchar(50) = '' --Ramiz on 07082015  
   ,@pay_scale_id As Numeric(2,0) = 0  
   ,@Actual_Date_Of_Birth AS DATETIME = NULL --Ankit 10102015  
   ,@Is_PF_Trust tinyint =0  
   ,@PF_Trust_No varchar(500)=null --Added by Sumit 01022016  
   ,@Extension_No varchar(10)=null --Added by Mukti 23042016  
   ,@LinkedIn_Id VARCHAR(100) = '' --Ankit 05072016  
   ,@Twitter_ID  VARCHAR(100) = '' --Ankit 05072016  
   ,@Manager_Probation numeric(18,0) = 0 --Rohit 19082016  
   ,@Customer_Audit tinyint = 0 -- Added by Jaina 22-08-2016  
   ,@PF_Start_Date datetime = null  --Added By Jaina 02-09-2016  
   ,@Sales_Code VARCHAR(20) = '' --Added By Ramiz on 07122016  
   ,@User_Id numeric =0  --Added by Mukti 04012017  
   ,@IP_Address varchar(30)= ''--Added by Mukti 04012017  
   ,@Default_Pwd varchar(100)= '' -- Added by nilesh patel on 25102017  
   ,@Leave_Encash_Working_Day Numeric (18,2) = 0 --Added By Jimit 03022018  
   ,@Rejoin_Emp_Id numeric(18,0) = 0 --Added by Jaina 03-03-2018  
   ,@Physical_Percent numeric(18,2) = 0 --added by Krushna 05-07-2018  
   ,@Is_Probation_Month_Days TINYINT = 0 --Added by Mukti(16102018)  
   ,@Is_Trainee_Month_Days TINYINT = 0 --Added by Mukti(16102018)  
   ,@Induction_Training Varchar(50) = '' --Added By Nilesh Patel on 19102018  
   ,@WeekdayCompOffAvail_After_Days numeric(18,2) =0 --added binal 03020220  
   ,@WeekOffCompOffAvail_After_Days numeric(18,2) =0 --added binal 03020220  
   ,@HolidayCompOffAvail_After_Days numeric(18,2) =0 --added binal 03020220  
   ,@Sign_ImageName Varchar(100) = '' --added binal 03020220  
   ,@Is_PieceTransSalary TINYINT = 0 --added binal 03020220  
   ,@Is_VBA TINYINT = 0  
   ,@Band_id numeric(18,0)   
   ,@Is_PMGKY TINYINT = 0  
   ,@Is_PFMem TINYINT = 0  
   ,@Emp_Cast_Join varchar(50) = '' --added by mehul 24052022

   ------------------------Added by ronakk 30052022 ----------------------
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
   ----------------------------------End by ronakk 30052022 ---------------------

AS   
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
       set @Street_1 = dbo.fnc_ReverseHTMLTags(@Street_1)  --added by Ronak 131021    
	    set @Present_Street = dbo.fnc_ReverseHTMLTags(@Present_Street)  --added by Ronak 191021    
		 set @CCenter_Remark = dbo.fnc_ReverseHTMLTags(@CCenter_Remark)  --added by Ronak 191021

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
 --if @Curr_ID =0  
 -- set @Curr_ID = null  
 if @Bank_ID =0  
  set @Bank_ID = null  
   
 -- Added By Ali 14112013 -- Start  
 if @Bank_ID_Two =0  
  set @Bank_ID_Two = null  
 -- Added By Ali 14112013 -- End  
   
   
 if @Basic_Salary =0   
  set @Basic_Salary = null  
    
 if  @Tally_Led_ID  = 0  
  set @Tally_Led_ID =null  
      
 if @Date_Of_Birth =  ''  
  set  @Date_Of_Birth = null  
 if @Date_Of_Retirement = '' --Added by nilesh patel on 29012015  
  Set @Date_Of_Retirement = null  
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
   set @Emp_Confirmation_date=null  
 if @Emp_Offer_date = ''   
   set @Emp_Offer_date=null  
 if @Increment_ID= 0   
  set @Increment_ID= null  
 if @Image_Name = ''  
  Begin  
   --set @Image_Name = '0.jpg' 
	If Upper(@Initial)= 'MS.' or Upper(@Initial) = 'MRS.'
		Set @Image_Name= 'Emp_Default_Female.png'
	ELSE
		Set @Image_Name = 'Emp_Default.png'
  END  
 Else  
  Begin  
   set @Image_Name = REPLACE(@Image_Name,'?',''); --In App file not saving with ? symobol but in DB its saved so replace with blank  
  End --Added this code by Sumit and Ramiz for replacing unused character from image name error coming on Home page  
     
 If @Alpha_Code=''  
  Set @Alpha_Code = NULL    
 if @Segment_ID = 0  
  set @Segment_ID = null  
    
 if @Vertical_ID = 0   
  set @Vertical_ID = null  
 if @SubVertical_ID = 0   
  set @SubVertical_ID = null  
   
 if @GroupJoiningDate = ''  
 set @GroupJoiningDate = Null  
 if @subBranch_ID = 0   
 set @subBranch_ID = Null  
   
 -- Added by rohit on 07042015  
 if isnull(@Late_Dedu_Type,'') = '' or isnull(@Late_Dedu_Type,'') = '0'   
  set @Late_Dedu_Type ='Day'    
 if isnull(@Early_Dedu_Type,'') ='' or isnull(@Early_Dedu_Type,'') = '0'  
  set @Early_Dedu_Type ='Day'    
   
 -- Added by rohit on 30012014 For marital Status Showing Wrong in Employee master   
 if @Marital_Status = 'Single' or @Marital_Status = ''  --Change by Jaina 24-05-2019 (Default entry is not added)  
  set @Marital_Status=0  
 else if @Marital_Status = 'Married'  
  set @Marital_Status = 1  
 else If @Marital_Status = 'Divorced'  
  set @Marital_Status = 2  
 else if @Marital_Status = 'Saperated'  
  set @Marital_Status = 3  
 else  
  set @Marital_Status = @Marital_Status  
 -- Ended by rohit on 03012014   
   
   if @Curr_ID =0  
   begin
		Select @Curr_ID = Curr_ID from T0040_CURRENCY_MASTER where Curr_Name = 'Rupees' and Cmp_ID = @Cmp_ID 
   end
  
   
 ---Added by Hardik 08/06/2015  
 If Isnull(@Gender,'') = ''  
  BEGIN  
   If Upper(@Initial)= 'MS.' or Upper(@Initial) = 'MRS.'  
    Set @Gender = 'F'  
   ELSE  
    Set @Gender = 'M'  
  END  
   
 --For Old Values in Audit Trail  
 SELECT * INTO #T0080_EMP_MASTER_DELETED FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID=@Emp_ID  
   
 --Added by Nimesh 2015-05-09 (Ration Card Detail)  
 IF (@Ration_Card_No = '')  
  SET @Ration_Card_No = NULL;  
 IF (@Ration_Card_Type = '')  
  SET @Ration_Card_No = 'APL';  
 --END: Nimesh  
   
 IF (@Vehicle_NO = '')      --added jimit 15052015  
     set @Vehicle_NO = NULL;    
   
 IF(@Aadhar_Card_No = '') --Added By Ramiz on 07082015  
  set @Aadhar_Card_No = NULL  
   
 IF @Actual_Date_Of_Birth =  '' or Cast(@Actual_Date_Of_Birth as datetime) =  '1900-01-01 00:00:00.000'  
  SET  @Actual_Date_Of_Birth = NULL   
    
 if @PF_Trust_No=''  
  Set @PF_Trust_No=null;  --Added by Sumit 01022016  
    
 IF @PF_Start_Date = ''   --Added By Jaina 02-09-2016  
  set @PF_Start_Date = NULL  
      
 declare @Get_Emp_code  as varchar(100)  --Added BY GAdriwala 18112013  
 declare @Get_Alpha_code  as varchar(100)  --Added BY GAdriwala 18112013  
 Declare @Emp_Full_Name as varchar(250)  
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
 Declare @Increment_Mode as TinyINT --Added By Ramiz on 11/05/2016 as it was throwing Error While Employee master Update  
 DECLARE @ErrString VARCHAR(1000)  
 -- uncommented by deepal on 06-09-2023
 DECLARE @Alt_W_Name AS VARCHAR(100)--add by chetan 150617  
 DECLARE @Alt_W_Full_Day_Cont As VARCHAR(100)--add by chetan 150617  
 DECLARE @Weekoff_Day_value As VARCHAR(250) --add by chetan 160617  
 -- uncommented by deepal on 06-09-2023
 
 set @Get_Emp_code = '' --Added BY GAdriwala 18112013  
 set @Get_Alpha_code = '' --Added BY GAdriwala 18112013  
 Set @Increment_Mode = 0 --Added By Ramiz on 11/05/2016 as it was throwing Error While Employee master Update  

-- uncommented by deepal on 06-09-2023   
 SET @Alt_W_Name = 0  
 SET @Alt_W_Full_Day_Cont = ''  
 SET @Weekoff_Day_value = ''  
 -- uncommented by deepal on 06-09-2023 
  
 If @Emp_Code =0   
  Begin  
   --select @Emp_code = isnull(max(Emp_Code),0) + 1 from dbo.T0080_EMP_MASTER WHERE CMP_ID =@CMP_ID  
   exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1,@Desig_Id,@Cat_ID,@Type_ID,@Date_OF_Birth  
   set @Emp_code = cast(@Get_Emp_code as numeric)  
  end  
    
 if isnull(@Alpha_Code,'') = '' -- changed by rohit on 24052016 for bma  
  begin  
   set @Alpha_Code = @Get_Alpha_code  
  end  
   
  
 if @Is_On_Probation = 1 and @Probation = 0  --added by nilesh patel for Probation   
  begin  
   SELECT @Probation = isnull(GS.Probation,0),@Is_Probation_Month_Days=GS.Is_Probation_Month_Days FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) where GS.Cmp_ID = @cmp_ID and GS.Branch_ID = @Branch_ID  
  End    
 if @Is_On_Training = 1 and @Training_Month = 0  --added by jimit 07102016  
  begin  
   SELECT @Training_Month = isnull(GS.Training_Month,0),@Is_Trainee_Month_Days=GS.Is_Trainee_Month_Days FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) where GS.Cmp_ID = @cmp_ID and GS.Branch_ID = @Branch_ID  
  End    
  
 Declare @Cmp_Code as varchar(5)  
 Declare @Branch_Code as varchar(10)  
 Declare @Alpha_Emp_Code as varchar(100)  
 DECLARE @Is_Auto_Alpha_Numeric_Code TINYINT  
 Declare @No_Of_Digits numeric  
 Declare @Comp_offlimit as varchar(10)  
 Declare @Is_Date_wise tinyint   
 Declare @Is_GroupOFCmp Numeric --Ankit 15072014  
 Declare @Branch_Weekday_OT_Rate Numeric(10,3) --Added by nilesh patel on 09012016  
 Declare @Branch_Weekoff_OT_Rate Numeric(10,3) --Added by nilesh patel on 09012016   
 Declare @Branch_Holiday_OT_Rate Numeric(10,3) --Added by nilesh patel on 09012016  
 Declare @Branch_Full_PF Numeric(1,0) --Added by nilesh patel on 09012016  
 Declare @Branch_Company_Full_PF Numeric(1,0) --Added by nilesh patel on 09012016  
   
 Set @Branch_Weekday_OT_Rate = 0  --Added by nilesh patel on 09012016  
 Set @Branch_Weekoff_OT_Rate = 0 --Added by nilesh patel on 09012016   
 Set @Branch_Holiday_OT_Rate = 0 --Added by nilesh patel on 09012016  
 Set @Branch_Full_PF = 0 --Added by nilesh patel on 09012016  
 Set @Branch_Company_Full_PF = 0 --Added by nilesh patel on 09012016  
   
 if @Rejoin_Emp_Id > 0  --Added by Jaina 03-03-2018  
 BEGIN        
   if exists ( SELECT 1 from T0080_EMP_MASTER WITH (NOLOCK) where Rejoin_Emp_Id =@Rejoin_Emp_Id and Cmp_ID=@Cmp_id)  
   BEGIN  
    RAISERROR ('Already Exist Employee', 16, 2)  
    return    
   END  
     
   select      
   @Bank_ID = Bank_ID,             
   @Curr_ID = Curr_ID,     
   @SSN_No = SSN_No,  
   @SIN_No = SIN_No,  
   @Dr_Lic_No = Dr_Lic_No,  
   @Pan_No = Pan_No,  
      @Date_Of_Birth = Date_Of_Birth,   
      @Marital_Status = Marital_Status,  
      @Gender = Gender,  
      @Dr_Lic_Ex_Date = Dr_Lic_Ex_Date,  
      @Nationality = Nationality,  
      @Loc_ID = Loc_ID,   
   @Street_1 = Street_1,  
   @City = City,  
   @State = State,  
   @Zip_code = Zip_code,  
      @Home_Tel_no = Home_Tel_no,   
   @Mobile_No = Mobile_No,  
   @Work_Tel_No = Work_Tel_No,  
   @Work_Email = Work_Email,  
   @Other_Email = Other_Email,   
   @Emp_Superior= Emp_Superior,  
   @Basic_Salary = Basic_Salary,  
      @Emp_Full_Name  = Emp_Full_Name,  
   @Present_Street= Present_Street,  
   @Present_City = Present_City,  
   @Present_State = Present_State,  
   @Present_Post_Box=Present_Post_Box,    
   @enroll_No  = enroll_No,    
   @Tall_Led_Name = Tally_Led_Name,  
   @Religion=Religion,   
   @Height=Height,    
   @Mark_Of_Idetification = Emp_Mark_Of_Identification,   
   @Dispencery=Despencery,  
   @Doctor_Name=Doctor_name,   
   @DispenceryAdd = DespenceryAddress,   
   @Insurance_No=Insurance_No,   
   @Is_Gr_App=Is_Gr_App,  
   @Is_Yearly_Bonus=Is_Yearly_Bonus,  
   @Yearly_Leave_Days=Yearly_Leave_Days,  
   @Yearly_Leave_Amount =Yearly_Leave_Amount,  
   @Yearly_Bonus_Per=Yearly_Bonus_Per,  
   @Yearly_Bonus_Amount=Yearly_Bonus_Amount,  
   @Emp_Confirmation_date = Emp_Confirm_Date ,  
   @Is_On_Probation =Is_On_Probation,  
   @Tally_Led_ID=Tally_Led_ID,  
   @Blood_Group=Blood_Group,  
   @Probation=Probation,  
   @Father_Name=Father_Name,  
   @Bank_BSR_No = Bank_BSR,  
   @login_id = login_Id,     
   @Old_Ref_No=Old_Ref_No,  
   @Ifsc_Code=Ifsc_Code,--Nikunj 13-06-2011  
   @Leave_In_Probation=Leave_In_Probation,--Nikunj 15-06-2011  
   @Is_LWF = Is_LWF, --Hardik 24/06/2011  
   @DBRD_Code=DBRD_Code,  --'Alpesh 23-Sep-2011  
   @Dealer_Code=Dealer_Code,  
   @CCenter_Remark=CCenter_Remark,   
   @Emp_PF_Opening = Emp_PF_Opening,  -- Added by Mihir 01022012   
   @Emp_Category= Emp_Category , -- Added by Mihir 15032012   
   @Emp_UIDNo = Emp_UIDNo,-- Added by Mihir 15032012  
   @Emp_Cast = Emp_Cast,  -- Added by Mihir 15032012  
   @Emp_Anniversary_Date = Emp_Annivarsary_Date,  
   @Extra_AB_Deduction = Extra_AB_Deduction, ---Alpesh 19-Mar-2012  
   @Min_CompOff_Limit = CompOff_Min_hrs ,   
   @mother_name = mother_name,  
   @Min_Wages= Min_Wages,   
   @Emp_Offer_Date = Emp_Offer_date,  
   @Segment_ID = Segment_ID,   
   @Vertical_ID =Vertical_ID,  
   @SubVertical_ID = SubVertical_ID,  
   @GroupJoiningDate = GroupJoiningDate,  
   @subBranch_ID = subBranch_ID,  
   @Bank_ID_Two= Bank_ID_Two,  
   @Ifsc_Code_Two = Ifsc_Code_Two,  
   @EmpName_Alias_PrimaryBank = EmpName_Alias_PrimaryBank,  
   @EmpName_Alias_SecondaryBank = EmpName_Alias_SecondaryBank,   
   @EmpName_Alias_PF = EmpName_Alias_PF,  
   @EmpName_Alias_PT = EmpName_Alias_PT,  
   @EmpName_Alias_Tax = EmpName_Alias_Tax,  
   @EmpName_Alias_ESIC = EmpName_Alias_ESIC,  
   @EmpName_Alias_Salary = EmpName_Alias_Salary,           
   @Emp_Notice_Period = Emp_Notice_Period,            
   @Dress_Code = Emp_Dress_Code  ,  
   @Shirt_Size = Emp_Shirt_Size,  
   @Pent_Size = Emp_Pent_Size,  
   @Shoe_Size = Emp_Shoe_Size,           
   @Canteen_Code = Emp_Canteen_Code,  
   @Thana_Id = Thana_Id,  
   @Tehsil = Tehsil,  
   @District = District,  
   @Thana_Id_Wok = Thana_Id_Wok,  
   @Tehsil_Wok = Tehsil_Wok,  
   @District_Wok = District_Wok,  
   @SkillType_ID = SkillType_ID,   
   @UAN_No = UAN_No,  
      @CompOff_WD_App_Days = CompOff_WD_App_Days,   
   @CompOff_WD_Avail_Days  = CompOff_WD_Avail_Days,    
   @CompOff_WO_App_Days = CompOff_WO_App_Days,  
   @CompOff_WO_Avail_Days = CompOff_WO_Avail_Days,  
   @CompOff_HO_App_Days = CompOff_HO_App_Days,   
      @CompOff_HO_Avail_Days = CompOff_HO_Avail_Days,    
   @Date_of_Retirement = Date_Of_Retirement,   
   @Is_Salary_Depends_On_Production_Details = Salary_Depends_on_Production,    
   @Ration_Card_Type=Ration_Card_Type,   
   @Ration_Card_No= Ration_Card_No,   
   @Vehicle_NO = Vehicle_NO,    
   @Training_Month = Training_Month,    
   @Is_On_Training = Is_On_Training,   
   @Aadhar_card_no = Aadhar_Card_No,    
   @Actual_Date_Of_Birth = Actual_Date_Of_Birth,  
   @is_PF_Trust=Is_PF_Trust,  
   @PF_Trust_No=PF_Trust_No,  
   @Extension_No=Extension_No,    
   @LinkedIn_Id = LinkedIn_Id,  
   @Twitter_ID = Twitter_ID,  
   @Manager_Probation = Manager_Probation,  
   @PF_Start_Date = PF_Start_Date,    
   @Adult_No = Worker_Adult_No,  
   @Leave_Encash_working_Day = Leave_Encash_Working_Days ,  
   @WeekdayCompOffAvail_After_Days=WeekdayCompOffAvail_After_Days ,--added binal 03022020  
   @WeekOffCompOffAvail_After_Days=WeekOffCompOffAvail_After_Days , --added binal 03022020  
   @HolidayCompOffAvail_After_Days=HolidayCompOffAvail_After_Days,   --added binal 03022020  
   @Is_VBA = IS_Vba,  
   @Band_id = Band_id,  
   @Is_PMGKY = Is_Pradhan_Mantri,  
   @Is_PFMem = Is_1time_PF_Member,  
   @Emp_Cast_Join = Emp_Cast_Join , -- Added by MEhul 24052022
   ---------------Added by ronakk 30052022 -------------------------------------

   @EmpFavSportID =Emp_Fav_Sport_id,
   @EmpFavSportName = Emp_Fav_Sport_Name,
   @EmpHobbyID =Emp_Hobby_id,
   @EmpHobbyName = Emp_Hobby_Name,
   @EmpFavFood = Emp_Fav_Food,
   @EmpFavRestro = Emp_Fav_Restro,
   @EmpFavTrvDestination = Emp_Fav_Trv_Destination,
   @EmpFavFestival =Emp_Fav_Festival,
   @EmpFavSportPerson = Emp_Fav_SportPerson ,
   @EmpFavSinger = Emp_Fav_Singer

    ---------------End by ronakk 30052022 -------------------------------------

  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMP_ID= @REJOIN_EMP_ID  
         
    
 END  
   
 declare @OldValue as  varchar(max) --Added by Sumit 14062016  
 Declare @String as varchar(max)  
 set @String =''  
 set @OldValue = ''  
   
 DECLARE @Max_Emp_Code Varchar(64)  
 DECLARE @Is_Alpha_Numeric_Branchwise TINYINT --HARDIK 17/06/2019 For RMP Bearing Client  
   
 SET @Is_Date_wise = 0  
 Set @Is_GroupOFCmp = 0  
 set @Add_Initial_In_Emp_Full_Name = '0'  
 Set @Is_Alpha_Numeric_Branchwise = 0  
   
 SELECT @Branch_Code = Branch_Code   
 FROM T0030_BRANCH_MASTER WITH (NOLOCK)  
 WHERE Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID   
  
 Select @Domain_Name = Domain_Name,@Cmp_Code = Cmp_Code,@Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code,   
   @No_Of_Digits = No_Of_Digit_Emp_Code,@Is_Date_wise = Is_DateWise ,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0),  
   @Max_Emp_Code = Max_Emp_Code, @Is_Alpha_Numeric_Branchwise = isnull(Is_Alpha_Numeric_Branchwise,0)  
 From dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  
 WHERE CMP_ID = @CMP_ID  
  
 Select @Comp_offlimit = CompOff_Min_Hours   
 from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)    --Modified by Ramiz on 15092014  
  
 select @Add_Initial_In_Emp_Full_Name = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Add initial in employee full name'  
  
 --Added by Nilesh Patel on 29032019 -- For Kataria Client   
 Declare @Employee_Strength_Setting tinyint  
 select @Employee_Strength_Setting = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'  
   
 IF @Employee_Strength_Setting = 1  
  Begin  
   IF @Branch_ID > 0 AND @Desig_Id > 0  
   Begin  
    Declare @Branch_Desig_Wise_Count Numeric(18,0)  
    Set @Branch_Desig_Wise_Count = 0  
  
    Declare @Branch_Desig_Strength_Count Numeric(18,0)  
    Set @Branch_Desig_Strength_Count = 0  
  
     Select   
     @Branch_Desig_Wise_Count = Count(1)  
    FROM  
     (SELECT   
      I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID  
     FROM T0095_INCREMENT I1 WITH (NOLOCK)  
     INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')  
     INNER JOIN (  
        SELECT   
         MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
        FROM T0095_INCREMENT I2 WITH (NOLOCK)  
        INNER JOIN (  
            SELECT   
             MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
            FROM T0095_INCREMENT I3 WITH (NOLOCK)  
            WHERE I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID And Emp_ID <> @Emp_Id  
            GROUP BY I3.Emp_ID  
           ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                    
        WHERE I2.Cmp_ID = @Cmp_Id   
        GROUP BY I2.Emp_ID  
       ) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID   
     WHERE I1.Cmp_ID=@Cmp_Id   
     AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WITH (NOLOCK) WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))           
     ) I  
    WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @Desig_Id   
  
    Select @Branch_Desig_Strength_Count = ESM.Strength  
     From T0040_Employee_Strength_Master ESM WITH (NOLOCK)  
     INNER JOIN(  
        Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id   
         From T0040_Employee_Strength_Master WITH (NOLOCK)  
        Where Branch_Id <> 0 and Desig_Id <> 0  
        Group By Branch_ID,Desig_Id   
     ) as Qry   
    ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id  
    where ESM.Branch_Id=@Branch_ID and ESM.Desig_Id=@Desig_Id  
      
    if @Branch_Desig_Wise_Count >= @Branch_Desig_Strength_Count  
     Begin  
      set @Emp_ID = 0  
      RAISERROR ('Employee Strength Limit has been Fulfilled as per the Defined limit', 16, 2)  
      return  
     End  
   End  
  End   
 --Added by Nilesh Patel on 29032019 -- For Kataria Client   
   
   
   
 if substring(@Domain_Name,1,1) <> '@'   
  set @Domain_Name = '@' + @Domain_Name  
 Declare @len as numeric  
 set @len = LEN(CAST (@emp_code as varchar(20)))  
   
 Declare @Retirement_Year Numeric(18,0)  
 select @Retirement_Year = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Employee Retirement Age'  
   
 if @Date_Of_Birth is not null and @Date_Of_Retirement is null and @Retirement_Year <> 0 -- Added by nilesh patel on 29012015  
  Begin  
   Set @Date_Of_Retirement = DATEADD(YEAR,@Retirement_Year,@Date_Of_Birth)-1    -- change by Deepali -Support #22731 Retirement Date Is Calculate More One Day - Shaily
  End   
   
 if @len > @No_Of_Digits  
  set @len = @No_Of_Digits  
   
 --IF @Is_Auto_Alpha_Numeric_Code = 1  
 -- Begin    
 --  If @Cmp_Code IS NULL  
 --   Begin  
 --    Set @Alpha_Code =      @Branch_Code  
 --    Set @Alpha_Emp_Code =  @Branch_Code + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10))  
 --   End  
 --  Else  
 --   Begin  
 --    Set @Alpha_Code =     @Cmp_Code + @Branch_Code  
 --    Set @Alpha_Emp_Code = @Cmp_Code + @Branch_Code + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10))  
 --   End   
 -- END  
 --ELSE  
 -- BEGIN  
 --  IF @Alpha_Code Is Not NULL  
 --   BEGIN  
 --    Set @Alpha_Emp_Code = @Alpha_Code  + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10))   
 --   END  
 --  ELSE  
 --   Begin  
 --    Set @Alpha_Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10))  
 --   END  
 -- END  
  if @Is_Auto_Alpha_Numeric_Code = 1  
  begin  
   if @Emp_code <> 0 and @Alpha_Code <> ''  
    begin  
      if @Is_Date_wise = 1   
       set @Alpha_Emp_Code = @Alpha_Code + @Code_Date +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
      else  
       set @Alpha_Emp_Code = @Alpha_Code +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
    end   
   else  
    begin  
      if @Is_Date_wise = 1   
        set @Alpha_Emp_Code =  @Code_Date + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
      else  
        set @Alpha_Emp_Code =   REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
    end  
  end  
  else  
   begin  
     if @Is_Date_wise = 1   
      set @Alpha_Emp_Code = @Code_Date + REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
     else  
      set @Alpha_Emp_Code =  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(20))   
   end  
   
 --Modified By Ramiz on 30/08/2016 , as when Second Name and Last Name was not Passed , it was Adding an extra Space and that cause problem in PF Files and other places.   
 If @Add_Initial_In_Emp_Full_Name = 1  
  Begin   
   --set @Emp_Full_Name = @Initial + ' ' + @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name   
   Set @Emp_Full_Name = @Initial  + RTRIM(' ' + LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name))   
  End  
 Else  
  Begin   
   --set @Emp_Full_Name = @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name   
   Set @Emp_Full_Name = RTRIM(LTRIM(@Emp_First_Name)) + RTRIM(' ' + LTRIM(@Emp_Second_Name)) + RTRIM(' ' + LTRIM(@Emp_Last_Name))   
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
       
     select @Is_Short_Fall_Grade_wise = Is_Shortfall_Gradewise , @short_Fall_days = Short_Fall_Days from T0040_GENERAL_SETTING WITH (NOLOCK) where Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID and For_Date = (select max(for_date) From T0040_General_Setting 
WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)   -- Modified by Ramiz on 15092014  
     if @Is_Short_Fall_Grade_wise = 1  
     BEGIN  
      select @short_Fall_days = Short_Fall_Days from T0040_GRADE_MASTER WITH (NOLOCK) where Grd_ID = @Grd_ID  
     END   
     Set @Emp_Notice_Period = @short_Fall_days  
   END  
  -- Added by Ali 29112013 -- Start  
  
 --If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Work_Email = @Work_Email And Emp_Id <> @Emp_ID)  
 -- begin     
 --  set @Emp_ID = 0  
 --  RAISERROR ('Work Email Id Already Exists', 16, 2)  
 --  return    
 -- end  
    
 If @tran_type  = 'I'  
  Begin  
     
     
   Select @Branch_Weekday_OT_Rate = isnull(Emp_WeekDay_OT_Rate,0)  
     ,@Branch_Weekoff_OT_Rate = isnull(Emp_WeekOff_OT_Rate,0)  
     ,@Branch_Holiday_OT_Rate = isnull(Emp_Holiday_OT_Rate,0)  
     ,@Branch_Full_PF = isnull(Full_PF,0)  
     ,@Branch_Company_Full_PF = isnull(Company_Full_PF,0)  
     ,@Yearly_Bonus_Per =ISNULL(Bonus_Per,0) --Ankit 19082016  
   from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)    --Modified by Ramiz on 15092014  
      
   IF @Is_GroupOFCmp = 0   
    Begin  
     If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code)  
      begin     
       select  @Emp_Code,'Code'  
       set @Emp_ID = 0  
       RAISERROR ('Employee Code already exists.', 16, 2)  
       return    
      end  
       
    End   
   Else If @Is_GroupOFCmp = 1  
    Begin  
     DECLARE @EXISTING_DETAIL VARCHAR(256)  
  
     If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Alpha_Emp_Code And Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1))  
      AND @Max_Emp_Code = 'Group_Company_Wise'  
      BEGIN         
       SELECT @EXISTING_DETAIL = Cmp_Name   
       FROM T0080_EMP_MASTER E WITH (NOLOCK)  
         INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON e.Cmp_ID=c.Cmp_Id   
       WHERE EMP_CODE = @Emp_code AND C.is_GroupOFCmp=1  
       SET @EXISTING_DETAIL = 'Employee Code already exist in "' + @EXISTING_DETAIL + '" Company.'  
      END  
     ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID)  
      AND @Max_Emp_Code = 'Company_Wise'  And @Is_Alpha_Numeric_Branchwise = 0  
      begin                   
       SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'  
      END  
     ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE (Alpha_Emp_Code = @Alpha_Emp_Code) And Cmp_ID = @Cmp_ID And Branch_ID = @Branch_Id)  
      AND @Max_Emp_Code = 'Company_Wise' And @Is_Alpha_Numeric_Branchwise = 1  
      begin                   
       SET @EXISTING_DETAIL = 'Employee Code already exist in Current Company.'  
      END  
        
     IF (@EXISTING_DETAIL IS NOT NULL)  
      BEGIN  
       SET @Emp_ID = 0  
       SELECT  @Emp_Code,'Code'  
       RAISERROR (@EXISTING_DETAIL , 16, 2)  
       RETURN    
      END  
    End   
      
   Declare @Backdate_Allowed Numeric  
   Select @Backdate_Allowed = Setting_Value From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Setting_Name='Allowed Backdated Joining upto Days'  
     
  --ADDED BY MUKTI(09072020)START   
    DECLARE @AGE NUMERIC  
    DECLARE @MaxAgeLimit INT  
    SET @AGE = dbo.F_GET_AGE (@Date_Of_Birth,GETDATE(),'N','N')  
    SELECT @MaxAgeLimit = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Maximum Age Limit for Employee Joining'  
    IF @AGE >@MaxAgeLimit  
    BEGIN  
     SET @Emp_ID = 0  
     SET @ErrString='@@Employee Age is more than ' + ' ' +  @MaxAgeLimit  + ' ' + ' years@@'  
     RAISERROR (@ErrString, 16, 2)  
     RETURN  
    END  
  --ADDED BY MUKTI(09072020)END  
   
   if @Backdate_Allowed > 0  
    Begin  
     --Added By Nilesh Patel For Kataria Client After Discuss With Ankur Sir   
     if Not Exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Login_ID = @User_Id and Login_Name LIKE 'admin@%')  
     BEGIN  
      DECLARE @Dt_From_Date Datetime  
      DECLARE @Dt_To_Date Datetime  
        
      SET @Dt_To_Date = CAST(Convert(char(11),GETDATE(),113) AS datetime)  
      SET @Dt_From_Date =  DATEADD(d,((@Backdate_Allowed) * (-1)),@Dt_To_Date)  
        
      if @Date_of_Join < @Dt_From_Date   
       Begin  
        Declare @Errormsg1  varchar(500)  
        set @Errormsg1 = '@@You can enter date of joining upto ' + ' ' + Cast(CONVERT(varchar(11),@Dt_From_Date,103) as Varchar(11)) + ' ' + ' Date,for more detail contact to administrator.@@.'  
        set @Emp_ID = 0  
        RAISERROR (@Errormsg1, 16, 2)  
        return    
       End   
     End   
    End  
  
      
           
    DECLARE @Count as numeric(18,0) ----Added by Hasmukh for employee License  14072011  
    DECLARE @Emp_LCount NUMERIC      
      
    set @Emp_LCount = 0  
      
    SELECT @Count =Count(Emp_ID) from dbo.T0080_EMP_MASTER WITH (NOLOCK) where Emp_Left<>'y'          
       
        -- Modify Jignesh 24-09-2012  
    --SELECT @Emp_LCount = isnull(Emp_License_Count,0) FROM dbo.Emp_Lcount  
    SELECT @Emp_LCount = dbo.Decrypt(Emp_License_Count) FROM dbo.Emp_Lcount WITH (NOLOCK)  
    SELECT @ErrString = 'Employee Limit Exceed, Contact Administrator, Total Active Employees =' + ' ' + CAST(@Count AS VARCHAR(18)) + ' ' + 'Current Employee License =' + ' ' + CAST(@Emp_LCount AS VARCHAR(18))      
      
    if @Count > @Emp_LCount  
      Begin  
      set @Emp_ID = 0  
      RAISERROR (@ErrString, 16, 2)   
      return   
      End  
       
    -- zalak audit trail for employee data updates -- 14-oct-2010  
    --exec GenerateAudittrail 'T0080_EMP_MASTER',0,@cmp_id--comment this line at clinet side  
      
    select @Emp_ID = Isnull(max(Emp_ID),0) + 1  From dbo.T0080_EMP_MASTER WITH (NOLOCK)  
      
    select @Adult_No = Isnull(max(Worker_Adult_No),0) + 1  From dbo.T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID=@Cmp_ID  
     
    -- Added By Alpesh on 25-05-2011 for first time login change password dialogbox for employee   
    if exists (select Module_Id From T0011_module_detail WITH (NOLOCK) where Cmp_Id=@Cmp_ID And chg_pwd=1)  
     Begin  
        Set @Chg_Pwd=1  
     End  
    ---------------------End------------------   
    --Added by Nimesh on 02-Feb-2016 (To generate the Employee PF Number automatically if duplicate)  
    IF EXISTS(Select 1 From T0040_SETTING WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID  AND Setting_Name='Auto Generate Employee PF Number' AND Setting_Value=1)  
     BEGIN  
      IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE SSN_No=@SSN_No AND CMP_ID=@CMP_ID AND IsNull(@SSN_No,'') <> '')  
       BEGIN      
        EXEC dbo.P_GET_NEXT_EMP_PF_NO @Cmp_ID, @SSN_No Output  
       END  
     END  
      
      
   -- Below Code is Created by Darshan on 19/01/2021 for Auto Active Mobile User during Employee Creation  
  
   DECLARE @lSettingValueForAutoActiveMobileUser INT,@lLicenceCount INT,@lActiveEmpCount INT  
   SELECT @lSettingValueForAutoActiveMobileUser = ISNULL(Setting_Value,0)  
   FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and setting_name = 'Auto Active Mobile User during Employee Creation'  
  
   IF @lSettingValueForAutoActiveMobileUser = 1  
    BEGIN  
     SELECT @lLicenceCount = dbo.Decrypt(Emp_License_Count_Mobile) FROM Emp_Lcount  
     SELECT @lActiveEmpCount = COUNT(1) FROM Active_InActive_Users_Mobile WHERE Cmp_ID = @Cmp_ID and is_for_mobile_Access = 1  
       
     IF @lActiveEmpCount > @lLicenceCount  
      BEGIN  
       SET @Emp_ID = 0  
       RAISERROR ('Mobile Activation Failed due to Mobile License Limit has been exceed', 16, 2)   
       --RETURN  
      END        
    END  
  
   -- Code end for Auto Active Mobile User during Employee Creation  
  
    INSERT INTO dbo.T0080_EMP_MASTER  
           (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
           Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
           Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,  
           Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation,  
           Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,Is_LWF,  
           DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast
           ,Emp_Annivarsary_Date,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Min_Wages,Segment_ID  
           ,Vertical_ID,SubVertical_ID,GroupJoiningDate,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,code_Date,code_date_Format  
           ,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT,EmpName_Alias_Tax  
           ,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Is_On_Probation,System_Date_Join_left,Emp_Dress_Code,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code  
           ,Thana_Id,Tehsil,District,Thana_Id_Wok,Tehsil_Wok,District_Wok,SkillType_ID,UAN_No,CompOff_WD_App_Days,CompOff_WD_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days  
           ,CompOff_HO_App_Days,CompOff_HO_Avail_Days,Date_of_Retirement,Salary_Depends_on_Production -- Added by Gadriwala Muslim 20112014  
           ,Ration_Card_Type, Ration_Card_No,Vehicle_NO,Training_Month,Is_On_Training,Aadhar_card_no,Actual_Date_Of_Birth,is_PF_Trust,PF_Trust_No,Extension_No,LinkedIn_Id,Twitter_ID,Yearly_Bonus_Per,Manager_Probation,PF_Start_Date --Added by Nimesh 2015-05-09  
          ,Leave_Encash_Working_days,Rejoin_Emp_Id,Is_Probation_Month_Days,Is_Trainee_Month_Days,Induction_Training,HolidayCompOffAvail_After_Days,WeekOffCompOffAvail_After_Days,WeekdayCompOffAvail_After_Days,Signature_Image_Name,Is_VBA,Band_Id,
		  Is_Pradhan_Mantri,Is_1time_PF_Member,Emp_Cast_Join,
		  Emp_Fav_Sport_id ,Emp_Fav_Sport_Name ,Emp_Hobby_id ,Emp_Hobby_Name ,Emp_Fav_Food , --Added by ronakk 30052022
          Emp_Fav_Restro ,Emp_Fav_Trv_Destination ,Emp_Fav_Festival ,Emp_Fav_SportPerson ,Emp_Fav_Singer)   --Added by ronakk 30052022
       VALUES     
	   (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
          @Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,  
          @Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,  
          @Image_Name,  
          @Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation,  
          @Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,@Is_LWF,  
          @DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast
          ,@Emp_Anniversary_Date,@Extra_AB_Deduction,@Comp_offlimit,@mother_name,@Min_Wages,@Segment_ID  
          ,@Vertical_ID,@SubVertical_ID,@GroupJoiningDate,@subBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two  
          ,@Code_Date,@Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF  
          ,@EmpName_Alias_PT,@EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Is_On_Probation,getdate(),@Dress_Code,@Shirt_Size,@Pent_Size,@Shoe_Size,@Canteen_Code  
          ,@Thana_Id,@Tehsil,@District,@Thana_Id_Wok,@Tehsil_Wok,@District_Wok,@SkillType_ID,@UAN_No,@CompOff_WD_App_Days,@CompOff_WD_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_HO_App_Days,@CompOff_HO_Avail_Days,@Date_Of_Retirement,@Is_Salary_Depends_On_Production_Details -- Added by Gadriwala Muslim 20112014  
          ,@Ration_Card_Type, @Ration_Card_No,@Vehicle_NO,@Training_Month,@Is_On_Training,@Aadhar_Card_No,@Actual_Date_Of_Birth,@Is_PF_Trust,@PF_Trust_No,@Extension_No,@LinkedIn_Id,@Twitter_ID,@Yearly_Bonus_Per,@Manager_Probation,@PF_Start_Date --Added byNimesh 2015-05-09  --Change By Jaina 02-09-2016  
           ,@Leave_Encash_Working_Day,@Rejoin_Emp_Id,@Is_Probation_Month_Days,@Is_Trainee_Month_Days,@Induction_Training,@HolidayCompOffAvail_After_Days,@WeekOffCompOffAvail_After_Days,@WeekdayCompOffAvail_After_Days,@Sign_ImageName,@Is_VBA,@Band_id,@Is_PMGKY
		   ,@Is_PFMem,@Emp_Cast_Join
		   ,@EmpFavSportID ,@EmpFavSportName,@EmpHobbyID ,@EmpHobbyName,@EmpFavFood ,@EmpFavRestro,@EmpFavTrvDestination  --Added by ronakk 30052022
		   ,@EmpFavFestival,@EmpFavSportPerson,@EmpFavSinger)  --Added by ronakk 30052022
           -- Added By Ali 03042014  
         
        IF @lSettingValueForAutoActiveMobileUser = 1  
        BEGIN  
         UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = 1   
         WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID  
        END  
            
       INSERT INTO dbo.T0080_EMP_MASTER_Clone  
           (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
           Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
           Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,  
           Emp_Full_Name,Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box,enroll_No,Blood_Group,Is_Gr_App,Is_Yearly_Bonus,Probation,  
           Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,Is_LWF,  
           DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast,Emp_Annivarsary_Date  
           ,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Segment_ID,Vertical_ID,SubVertical_ID,GroupJoiningDate  
           ,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,code_date,Code_Date_Format,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,  
           EmpName_Alias_PT,EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Is_On_Probation,System_Date_Join_left,Emp_Dress_Code,  
           Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code,Thana_Id,Tehsil,District,Thana_Id_Wok,Tehsil_Wok,District_Wok,SkillType_ID,CompOff_WD_App_Days,  
           CompOff_WD_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days,CompOff_HO_App_Days,CompOff_HO_Avail_Days,Date_of_Retirement,Salary_Depends_on_Production,  
           Training_Month,Is_On_Training , Aadhar_card_no,Induction_Training,HolidayCompOffAvail_After_Days,WeekOffCompOffAvail_After_Days,
		   WeekdayCompOffAvail_After_Days,Emp_Cast_Join
		   ,Emp_Fav_Sport_id ,Emp_Fav_Sport_Name ,Emp_Hobby_id ,Emp_Hobby_Name ,Emp_Fav_Food  --Added by ronakk 30052022
		   ,Emp_Fav_Restro ,Emp_Fav_Trv_Destination ,Emp_Fav_Festival ,Emp_Fav_SportPerson ,Emp_Fav_Singer)   --Added by ronakk 30052022
           -- Added By Ali 03042014  
       VALUES     
	   (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
          @Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,  
          @Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,  
          @Emp_Full_Name,'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@enroll_No,@Blood_Group,@Is_Gr_App,@Is_Yearly_Bonus,@Probation,  
          @Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,@Is_LWF,  
          @DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast  
          ,@Emp_Anniversary_Date,@Extra_AB_Deduction,@Comp_offlimit,@mother_name,@Segment_ID,@Vertical_ID  
          ,@SubVertical_ID,@GroupJoiningDate,@subBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two,@Code_Date  
          ,@Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF  
          ,@EmpName_Alias_PT,@EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Is_On_Probation,getdate(),@Dress_Code,@Shirt_Size,@Pent_Size,@Shoe_Size,@Canteen_Code  
          ,@Thana_Id,@Tehsil,@District,@Thana_Id_Wok,@Tehsil_Wok,@District_Wok,@SkillType_ID,@CompOff_WD_App_Days,@CompOff_WD_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_HO_App_Days,  
          @CompOff_HO_Avail_Days,@Date_Of_Retirement,@Is_Salary_Depends_On_Production_Details,@Training_Month,@Is_On_Training,@Aadhar_Card_No,@Induction_Training,
		  @HolidayCompOffAvail_After_Days,@WeekOffCompOffAvail_After_Days,@WeekdayCompOffAvail_After_Days,@Emp_Cast_Join
		  ,@EmpFavSportID ,@EmpFavSportName,@EmpHobbyID ,@EmpHobbyName,@EmpFavFood ,@EmpFavRestro,@EmpFavTrvDestination  --Added by ronakk 30052022
		  ,@EmpFavFestival,@EmpFavSportPerson,@EmpFavSinger)  --Added by ronakk 30052022
		  -- Added by Gadriwala Muslim 20112014  
      
      
      -- uncommented by deepal on 06-09-2023
    select @Default_Weekof = Default_Holiday   
    --@add by chetan 150617  
    ,@Alt_W_Name = Alt_W_Name  
     ,@Alt_W_Full_Day_Cont = Alt_W_Full_Day_Cont  
     from dbo.T0010_COMPANY_MASTER where Cmp_Id = @Cmp_ID  
       
     SET @Weekoff_Day_value =   REPLACE(@Default_Weekof,'#',' 1.0#')+' 1.0'  --add by chetan 160617  
  -- uncommented by deepal on 06-09-2023
    set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name   
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
      
    --EXEC p0011_Login 0,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2  
    EXEC p0011_Login @Login_ID=0,@Cmp_ID=@Cmp_Id,@Login_Name=@loginname,@Login_Password=@Default_Pwd,@Emp_ID=@Emp_ID,@Branch_ID=NULL,@Login_Rights_ID=NULL,@trans_type='I',@Is_Default=2, @ChangedBy=@User_Id, @ChangedFromIP=@IP_Address  
    EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0  
      
    Declare @late_limit varchar(10)  --Alpesh 18-Aug-2012  
    Declare @early_limit varchar(10) --Alpesh 18-Aug-2012  
    Declare @ot_min_limit varchar(10) --Alpesh 18-Aug-2012  
    Declare @ot_max_limit varchar(10) --Alpesh 18-Aug-2012  
      
    select @G_FOR_DATE = max(for_date) from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date<= getdate()  
    select @IS_OT = IS_OT ,@IS_PT = IS_PT ,@IS_PF= IS_PF ,@IS_LATE_MARK =IS_LATE_MARK  
    ,@late_limit = isnull(Late_Limit,'00:00'),@early_limit=isnull(Early_Limit,'00:00'),@ot_min_limit=ISNULL(OT_App_Limit,'00:00'),@ot_max_limit=ISNULL(OT_Max_Limit,'00:00')   
    from T0040_GENERAL_SETTING WITH (NOLOCK) where branch_id= @Branch_ID and for_date= @G_FOR_DATE  
      
    --Alpesh 18-Aug-2012  
    if (isnull(@Emp_Late_Limit,'')='' or @Emp_Late_Limit = '00:00')  
       set @Emp_Late_Limit = @late_limit  
         
    if isnull(@Emp_Early_Limit,'')='' or @Emp_Early_Limit = '00:00'  
       set @Emp_Early_Limit = @early_limit  
         
    if (isnull(@Emp_OT_Min_Limit,'')='' or @Emp_OT_Min_Limit = '00:00')  
       set @Emp_OT_Min_Limit = @ot_min_limit  
         
    if isnull(@Emp_OT_Max_Limit,'')='' or @Emp_OT_Max_Limit = '00:00'  
       set @Emp_OT_Max_Limit = @ot_max_limit     
    --- End ---  
      
    --Added by nilesh patel on 09012016 -start  
    if @Emp_wd_ot_rate = 0  
     set @Emp_wd_ot_rate =  @Branch_Weekday_OT_Rate  
      
    if @Emp_wo_ot_rate = 0  
     set @Emp_wo_ot_rate =  @Branch_Weekoff_OT_Rate  
       
    if @Emp_ho_ot_rate = 0  
     Set @Emp_ho_ot_rate = @Branch_Holiday_OT_Rate  
      
    if @Emp_Full_PF = 0  
     Set @Emp_Full_PF = @Branch_Full_PF  
         
    if @Auto_Vpf = 0  
     Set @Auto_Vpf = @Branch_Company_Full_PF  
       
    --Added by nilesh patel on 09012016 -End  
      
    --Added by Nilesh Patel on 20022019 -- Auto Set Wages Type if Assign Grade Wise -- Chiripal  
    IF Exists(Select 1 From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID and Isnull(Grd_WAGES_TYPE,'') <> '')  
     Begin  
      Select @Wages_Type = Grd_WAGES_TYPE From T0040_GRADE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Grd_ID = @Grd_ID  
     End  


      
    --EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join output,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@IS_OT,@Emp_OT_Min_Limit,0,0,0,0,0,'',@IS_LATE_MARK,@IS_PF,@IS_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@emp_superior,@Dep_Reminder,1,@CTC,0,0,0,0,0,0,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID, @Emp_wd_ot_rate, @Emp_wo_ot_rate, @Emp_ho_ot_rate      
    -- Above Line Commented by mihir Adeshara and Changes Done for @Emp_Full_PF Check box values on 11062012  
    EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join output,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_Type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@emp_superior,@Dep_Reminder,1,@CTC,0,0,0,0,0,0,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID, @Emp_wd_ot_rate, @Emp_wo_ot_rate, @Emp_ho_ot_rate,0,0,0,0,@no_of_chlidren,@is_metro,@is_physical,@Salary_Cycle_id,@auto_Vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Inc_Bank_AC_No_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,0,'',@User_Id,@IP_Address,@Customer_Audit , @Sales_Code,@Physical_Percent,@Is_PieceTransSalary,@Band_id,@Is_PMGKY,@Is_PFMem --Change by Jaina 22-08-2016 -- Ramiz Added Sales Code on 07/12/2016  
    -- End Line Commented by mihir Adeshara and Changes Done for @Emp_Full_PF Check box values on 11062012  
  	
    -- Below SP add by Niraj DATE :- 23082022
		--EXEC P0080_DATALINK_HRMS_VMS @CMP_ID ,@BRANCH_ID ,@EMP_ID ,@DEPT_ID ,@DESIG_ID ,@LOC_ID , @Present_State , @Present_City, @Login_Alias , 'I'
	-- End
	--uncommented by deepal on 06092023

	--select @Default_Weekof
    --select @Default_Weekof,123
	If isnull(@Default_Weekof,'') <> ''  
    EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,@Weekoff_Day_value,@Alt_W_Name,@Alt_W_Full_Day_Cont,'',0,'I',@User_Id,@IP_Address --comment by chetan 300617  

    exec P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID,@Branch_ID  
    --EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_Of_Join,null
	--uncommented by deepal on 06092023
	
	EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_Of_Join,null,0,1   ---added to restrict monthlock validation
    --zalak for manager history--190111  
    exec P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@Emp_Superior,@Date_Of_Join   
         
     if not exists (SELECT 1 from T0011_LOGIN WITH (NOLOCK) where Login_Alias = isnull(@Login_Alias,'') AND Emp_ID <> @Emp_ID)  
     begin  
      update T0011_LOGIN SET login_alias = isnull(@Login_Alias,'') where Emp_ID = @Emp_ID  
     end  
    if @pay_scale_id <> 0  
     Begin  
      EXEC P0050_EMP_PAY_SCALE_DETAIL @Cmp_ID,0,@Emp_ID,@pay_scale_id,@Date_Of_Join,1  
     End   
       
   if @Rejoin_Emp_Id > 0  --Added by Jaina 03-03-2018  
   BEGIN  
    exec P_Rejoin_Employee_Detail @Cmp_ID,@Emp_ID,@Rejoin_Emp_Id  
   ENd  
  


  ---Added by ronakk for gross salary update 13022023 -------
				  Create table #CTCCal
				(
				AD_NAME Varchar(1000),
				AD_Tran_ID int,
				CMP_ID int,
				EMP_ID int,
				AD_ID int,
				INCREMENT_ID INT,
				FOR_DATE DATETIME,
				E_AD_FLAG VARCHAR(10),
				E_AD_MODE VARCHAR(10),
				E_AD_PER NUMERIC(18,2),
				E_AD_AMT NUMERIC(18,2),
				E_AD_MAX_LIMIT NUMERIC(18,2),
				E_AD_LEVEL NUMERIC(18,0),
				AD_NOT_EFFECT_SALARY NUMERIC(18,0),
				AD_PART_OF_CTC NUMERIC(18,0),
				AD_ACTIVE NUMERIC(18,0),
				AD_NOT_EFFECT_ON_PT NUMERIC(18,0),
				FOR_FNF NUMERIC(18,0),
				AD_NOT_EFFECT_ON_MONTHLY_CTC NUMERIC(18,0),
				Is_yearly NUMERIC(18,0),
				Not_Effect_on_Basic_Calculation NUMERIC(18,0),
				AD_CALCULATE_ON VARCHAR(100),
				Effect_Net_Salary NUMERIC(18,0),
				AD_EFFECT_MONTH varchar(100),
				E_AD_Flag1 varchar(100),
				Add_in_sal_amt varchar(100),
				AD_DEF_ID int,
				ENTRY_TYPE varchar(100),
				Alpha_Emp_Code varchar(100),
				Emp_code varchar(100),
				Emp_First_Name varchar(100),
				Emp_Full_Name varchar(500),
				Branch_ID int,
				Grd_ID int,
				AD_Effect_ON_CTC int,
				Hide_In_Report int,
				Pre_for_Date datetime,
				Pre_AD_PER numeric(18,2),
				Pre_AD_Amount numeric(18,2)
				)

			 insert into #CTCCal
			 exec P0100_EMP_EARN_DEDUCTION_REVISED @Emp_ID=@Emp_ID,@Cmp_ID=@Cmp_ID,@For_Date=@Date_Of_Join,@Show_Hidden_Allowance=0   

			 select @Gross_salary = sum(E_AD_AMT)+@Basic_Salary from #CTCCal where AD_NOT_EFFECT_SALARY=0 and E_AD_FLAG='I'
			 update T0095_INCREMENT set Gross_Salary =@Gross_salary where Emp_ID= @Emp_ID and Cmp_ID= @Cmp_ID

			 drop table #CTCCal
    ---End by ronakk for gross salary update 13022023 -------


   --Added below code by Sumit on 14062016 for entry in Audit Trail----------------------------------------  
   exec P9999_Audit_get @table = 'T0080_EMP_MASTER' ,@key_column='Emp_Id',@key_Values=@Emp_ID ,@String=@String output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))   
   --Ended--------------------------------------------------------------        
  End  
 Else if @Tran_Type = 'U'  
  begin  
  
   --If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code and Emp_ID <> @Emp_ID)  
   -- begin     
       
   --  set @Emp_ID = 0  
   --   RAISERROR ('Already Exist Employee Code', 16, 2)  
   --  return    
   -- end   
    --If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WHERE Cmp_ID= @Cmp_ID and Emp_code = @Emp_Code and Emp_ID <> @Emp_ID)  
    -- begin  
    --  set @Emp_ID = 0  
    --  return    
    -- end  
       
     declare @Emp_Superior_o as numeric(18,0)  
     declare @Old_Code_Date as varchar(50)   
     declare @Old_Code_Date_Format as varchar(50)   
      
     select @old_Join_Date = DAte_of_join ,@Emp_Superior_o=Emp_Superior, @Old_Code_Date = Code_Date,@Old_Code_Date_Format = Code_Date_Format From dbo.T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID  
       
     -- zalak audit trail for employee data updates -- 14-oct-2010  
     --exec GenerateAudittrail 'T0080_EMP_MASTER',0,@cmp_id--comment this line at clinet side  
     ----  
     --------------------------------------------------------------------------------------------      
     if (@Date_Of_Join <> @old_Join_Date)  
      Begin        
       --if Exists(select top 1 1 from t0200_monthly_salary where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Month_St_Date <= dateadd(M,-1,@Date_Of_Join))  
       if Exists(select top 1 1 from t0200_monthly_salary WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Month_St_Date <= @Date_Of_Join)  
        Begin           
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Salary Exists.@@', 16, 2)  
         return  
        End  
       Else if Exists(select top 1 1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID=LAD.Leave_Application_ID  where LA.Emp_ID=@Emp_ID and LA.Cmp_ID=@Cmp_ID and LAD.From_Date <= @Date_Of_Join)  
        Begin  
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Leave Records Exists.@@', 16, 2)  
         return  
        End   
       Else if Exists(select top 1 1 from dbo.T0100_LOAN_APPLICATION WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Loan_App_Date <= dateadd(M,-1,@Date_Of_Join))  
        Begin           
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Loan Records Exists.@@', 16, 2)  
         return  
        End   
       Else if Exists(select top 1 1 from dbo.T0120_leave_Approval LA WITH (NOLOCK) inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID=LAD.Leave_Approval_ID  where Emp_ID=@Emp_ID and LA.Cmp_ID=@Cmp_ID and LAD.From_Date <= @Date_Of_Join)  
        Begin           
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Leave Records Exists.@@', 16, 2)  
         return  
        End  
       Else if Exists(select top 1 1 from dbo.T0095_LEAVE_OPENING WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and For_Date <= @Date_Of_Join and Leave_Op_Days <> 0) -- Added this condition after discussion with Sandip bhai because leave opening records are not deleting from front end 8/11/2016  
        Begin           
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Leave Opening Records Exists.@@', 16, 2)  
         return  
        End  
       Else if Exists(select top 1 1 from dbo.T0120_LOAN_APPROVAL WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Loan_Apr_Date <= @Date_Of_Join)  
        Begin           
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Loan Records Exists.@@', 16, 2)  
         return  
        End  
       Else if Exists(Select top 1 1 from T0095_INCREMENT WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND (Increment_Type = 'Increment' or Increment_Type='Transfer'))  
        Begin      
         set @Emp_ID = 0  
         RAISERROR ('@@Date of Join cannot be updated. Increment Records Exists.@@', 16, 2)  
         return  
        End    
      End     
     --Added below exists condition by Sumit for Date of Join Update in case salary exists of previous months------------------------------------------------------------------------------------------  
       
       
       
     --Added by nilesh patel on 09012016 -start  
      if @Emp_wd_ot_rate = 0  
       set @Emp_wd_ot_rate =  @Branch_Weekday_OT_Rate  
        
      if @Emp_wo_ot_rate = 0  
       set @Emp_wo_ot_rate =  @Branch_Weekoff_OT_Rate  
         
      if @Emp_ho_ot_rate = 0  
       Set @Emp_ho_ot_rate = @Branch_Holiday_OT_Rate  
        
      if @Emp_Full_PF = 0  
       Set @Emp_Full_PF = @Branch_Full_PF  
        
        
      if @Auto_Vpf = 0  
       Set @Auto_Vpf = @Branch_Company_Full_PF  
        
     --Added by nilesh patel on 09012016 -End  
     --CODE ADDED BY SUMIT 14062016---------------------------------------------------------------------  
     exec P9999_Audit_get @table='T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID,@String=@String output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
       
     ---------------------------------------------------------  
       
       
     if @Emp_Superior = 0   
      set @Emp_Superior =NULL   
  
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
         Yearly_Bonus_Amount=@Yearly_Bonus_Amount,  
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
         Emp_Cast = @Emp_Cast,  -- Added by Mihir 15032012  
		 Is_Geofence_enable = @Geo,
         Emp_Annivarsary_Date = @Emp_Anniversary_Date,  
         Extra_AB_Deduction = @Extra_AB_Deduction, ---Alpesh 19-Mar-2012  
         CompOff_Min_hrs = @Min_CompOff_Limit   
         ,mother_name = @mother_name  
         ,Min_Wages= @Min_Wages --- Jignesh 09_Oct_2012  
         ,Emp_Offer_Date = @Emp_Offer_date  
          ,Segment_ID =@Segment_ID   
         ,Vertical_ID =@Vertical_ID  
         ,SubVertical_ID = @SubVertical_ID  
         ,GroupJoiningDate = @GroupJoiningDate  
         ,subBranch_ID = @subBranch_ID  
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
          -- Added By Ali 25032014 -- Start  
         ,Emp_Dress_Code = @Dress_Code  
         ,Emp_Shirt_Size = @Shirt_Size  
         ,Emp_Pent_Size = @Pent_Size  
         ,Emp_Shoe_Size = @Shoe_Size  
         -- Added By Ali 25032014 -- End  
         ,Emp_Canteen_Code = @Canteen_Code  
         ,Thana_Id = @Thana_Id  
         ,Tehsil = @Tehsil  
         ,District = @District  
         ,Thana_Id_Wok = @Thana_Id_Wok  
         ,Tehsil_Wok = @Tehsil_Wok  
         ,District_Wok = @District_Wok  
         ,SkillType_ID = @SkillType_ID -- Added by Gadriwala 24042014  
         ,UAN_No = @UAN_No  
         ,CompOff_WD_App_Days = @CompOff_WD_App_Days -- Added by Gadriwala 20112014  
         ,CompOff_WD_Avail_Days  = @CompOff_WD_Avail_Days  -- Added by Gadriwala 20112014  
         ,CompOff_WO_App_Days = @CompOff_WO_App_Days  -- Added by Gadriwala 20112014  
         ,CompOff_WO_Avail_Days = @CompOff_WO_Avail_Days  -- Added by Gadriwala 20112014  
         ,CompOff_HO_App_Days = @CompOff_HO_App_Days  -- Added by Gadriwala 20112014  
         ,CompOff_HO_Avail_Days = @CompOff_HO_Avail_Days  -- Added by Gadriwala 20112014  
         ,Date_of_Retirement = @Date_Of_Retirement -- Added by Nilesh Patel on 29012015  
         ,Salary_Depends_on_Production = @Is_Salary_Depends_On_Production_Details -- Added by Nilesh Patel on 11032015  
         ,Ration_Card_Type=@Ration_Card_Type --Added by Nimesh 2015-05-09  
         ,Ration_Card_No=@Ration_Card_No --Added by Nimesh 2015-05-09  
         ,Vehicle_NO = @Vehicle_NO     --added jimit 15052015  
         ,Training_Month = @Training_Month  --Added by nilesh patel on 29052015  
         ,Is_On_Training = @Is_On_Training --Added by nilesh patel on 29052015  
         ,Aadhar_card_no = @Aadhar_Card_No  --Added By Ramiz on 07/08/2015  
         ,Actual_Date_Of_Birth = @Actual_Date_Of_Birth  
         ,is_PF_Trust=@Is_PF_Trust  
         ,PF_Trust_No=@PF_Trust_No  
         ,Extension_No=@Extension_No  --Mukti(23042016)  
         ,LinkedIn_Id = @LinkedIn_Id  
         ,Twitter_ID = @Twitter_ID  
          ,Manager_Probation = @Manager_Probation  
         ,PF_Start_Date = @PF_Start_Date  --Added By Jaina 02-09-2016  
         ,Worker_Adult_No=@Adult_No  --Mukti(09032017)  
         ,Leave_Encash_working_Days = @Leave_Encash_Working_Day --Added By Jimit 03022018  
         ,Is_Probation_Month_Days = @Is_Probation_Month_Days  
         ,Is_Trainee_Month_Days = @Is_Trainee_Month_Days  
         ,HolidayCompOffAvail_After_Days=@HolidayCompOffAvail_After_Days  
         ,WeekOffCompOffAvail_After_Days=@WeekOffCompOffAvail_After_Days  
         ,WeekdayCompOffAvail_After_Days=@WeekdayCompOffAvail_After_Days  
         ,Is_VBA=@Is_VBA  
         ,Band_id = @Band_id  
         ,Is_Pradhan_Mantri = @Is_PMGKY  
         ,Is_1time_PF_Member= @Is_PFMem  
		 ,Emp_Cast_Join = @Emp_Cast_Join  -- Added by MEhul 24052022

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


         --,Induction_Training = @Induction_Training  
     WHERE   Emp_ID = @Emp_ID And cmp_Id=@Cmp_Id   

	 -- Add by Niraj 23082022 Link HRMS and VMS Database for Enpay
    --EXEC P0080_DATALINK_HRMS_VMS @CMP_ID ,@BRANCH_ID ,@EMP_ID ,@DEPT_ID ,@DESIG_ID ,@LOC_ID , @Present_State , @Present_City, @Login_Alias, 'U'
	 -- END by Niraj 23082022

     --Added by nilesh patel on 05042016 , wrong Alphacode insert into Employee Master Clone  
     Select @Alpha_Code = Alpha_Code ,@Alpha_Emp_Code=Alpha_Emp_Code,@Emp_code = Emp_code From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID  
    
	print @Present_State

    INSERT INTO dbo.T0080_EMP_MASTER_Clone  
          (Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
         Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
         Loc_ID, Street_1, City, State, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email,Emp_Superior, Basic_Salary, Image_Name,  
        Emp_Full_Name
		,Emp_Left
		,Present_Street
		,Present_City
		,Present_State
		,Present_Post_Box
		,enroll_No
		,Blood_Group
		,Is_Gr_App
        ,Is_Yearly_Bonus
		,Probation
		,  
          Worker_Adult_No,Father_Name,Bank_BSR,system_date,login_id,Old_Ref_No,Chg_Pwd,Alpha_Code ,Alpha_Emp_Code,Ifsc_Code,Leave_In_Probation,Is_LWF,  
          DBRD_Code,Dealer_Code,CCenter_Remark,Emp_PF_Opening,Emp_Category,Emp_UIDNo,Emp_Cast,Emp_Annivarsary_Date
		  ,Extra_AB_Deduction,CompOff_Min_hrs,mother_name,Segment_ID,Vertical_ID  
         ,SubVertical_ID,GroupJoiningDate,subBranch_ID,Bank_ID_Two,Ifsc_Code_Two,Code_Date  
       ,Code_Date_Format,EmpName_Alias_PrimaryBank,EmpName_Alias_SecondaryBank,EmpName_Alias_PF,EmpName_Alias_PT ,
	 EmpName_Alias_Tax,EmpName_Alias_ESIC,EmpName_Alias_Salary,Emp_Notice_Period,Emp_Dress_Code,Emp_Shirt_Size,Emp_Pent_Size,Emp_Shoe_Size,Emp_Canteen_Code  
         ,Thana_Id,Tehsil,District,Thana_Id_Wok,Tehsil_Wok,District_Wok,SkillType_ID,CompOff_WD_App_Days
		,CompOff_WD_Avail_Days,CompOff_WO_App_Days,CompOff_WO_Avail_Days,CompOff_HO_App_Days,CompOff_HO_Avail_Days,Date_of_Retirement,  
          Salary_Depends_on_Production,Training_Month,Is_On_Training , Aadhar_card_no,Induction_Training,HolidayCompOffAvail_After_Days,
		  WeekOffCompOffAvail_After_Days,WeekdayCompOffAvail_After_Days,Emp_Cast_Join
		    ,Emp_Fav_Sport_id ,Emp_Fav_Sport_Name ,Emp_Hobby_id ,Emp_Hobby_Name ,Emp_Fav_Food  --Added by ronakk 30052022
		    ,Emp_Fav_Restro ,Emp_Fav_Trv_Destination ,Emp_Fav_Festival ,Emp_Fav_SportPerson ,Emp_Fav_Singer
			)   --Added by ronakk 30052022
		    -- Added By Ali 03042014  
      VALUES     (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
         @Emp_Last_Name,@Curr_ID,@Date_Of_Join,@SSN_No,@SIN_No,@Dr_Lic_No,@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,@Dr_Lic_Ex_Date,@Nationality,  
         @Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Emp_Superior,@Basic_Salary,@Image_Name,  
       @Emp_Full_Name
	   ,'N'
	   ,@Present_Street
	   ,@Present_City
	   ,@Present_State
	   ,@Present_Post_Box
	   ,@enroll_No
	   ,@Blood_Group
	   ,@Is_Gr_App
	   ,@Is_Yearly_Bonus
	   ,@Probation
	   ,  
         @Adult_No,@Father_Name,@Bank_BSR_No,getdate(),@login_id,@Old_Ref_No,@Chg_Pwd,@Alpha_Code ,@Alpha_Emp_Code,@Ifsc_Code,@Leave_In_Probation,@Is_LWF,  
        @DBRD_Code,@Dealer_Code,@CCenter_Remark,@Emp_PF_Opening,@Emp_Category,@Emp_UIDNo,@Emp_Cast ,@Emp_Anniversary_Date,
		 @Extra_AB_Deduction,@Min_CompOff_Limit,@mother_name,@Segment_ID,@Vertical_ID  
         ,@SubVertical_ID,@GroupJoiningDate,@subBranch_ID,@Bank_ID_Two,@Ifsc_Code_Two,@Old_Code_Date  
        ,@Old_Code_Date_Format,@EmpName_Alias_PrimaryBank,@EmpName_Alias_SecondaryBank,@EmpName_Alias_PF ,@EmpName_Alias_PT,
		 @EmpName_Alias_Tax,@EmpName_Alias_ESIC,@EmpName_Alias_Salary,@Emp_Notice_Period,@Dress_Code,@Shirt_Size,@Pent_Size,@Shoe_Size,@Canteen_Code  
         ,@Thana_Id,@Tehsil,@District,@Thana_Id_Wok,@Tehsil_Wok,@District_Wok,@SkillType_ID,@CompOff_WD_App_Days,
		 @CompOff_WD_Avail_Days,@CompOff_WO_App_Days,@CompOff_WO_Avail_Days,@CompOff_HO_App_Days,@CompOff_HO_Avail_Days,@Date_Of_Retirement,  
         @Is_Salary_Depends_On_Production_Details,@Training_Month,@Is_On_Training,@Aadhar_card_no,@Induction_Training,@HolidayCompOffAvail_After_Days,
		  @WeekOffCompOffAvail_After_Days,@WeekdayCompOffAvail_After_Days,@Emp_Cast_Join
		   ,@EmpFavSportID ,@EmpFavSportName,@EmpHobbyID ,@EmpHobbyName,@EmpFavFood 
		   ,@EmpFavRestro,@EmpFavTrvDestination,@EmpFavFestival,@EmpFavSportPerson,@EmpFavSinger
		   )  --Added by ronakk 30052022
		  -- Added by Gadriwala 24042014 -- Added By Ali 03042014 --Aadhar Added by Ramiz on 07/08/2015  
          
     ---Update Query Update by Nikunj 16-04-2011 Please Every where Put Cmp_Id and in where So Sometimes it creates problem  
     
     --Set @loginname = cast(@Emp_Code as varchar(10))  +  @Domain_Name   
    -- If @Alpha_Emp_Code is NOT NULL  
    -- Begin        
        
    --  Set @loginname = cast(@Alpha_Emp_Code as varchar(50)) + @Domain_Name  
    -- End  
    --Else  
    -- Begin  
       
    --  Set @loginname = cast(@Emp_Code as varchar(10)) + @Domain_Name   
    -- End       
       
    -- Update T0011_Login  
    -- set Login_Name = @loginname  
    --    -- Branch_ID = @Branch_Id  
    -- where Emp_ID = @Emp_ID   
       
     SET @Increment_ID  =ISNULL(@Increment_ID ,0)  
       
     SELECT @FOR_DATE = INCREMENT_EFFECTIVE_DATE , @INCREMENT_MODE = INCREMENT_MODE FROM T0095_INCREMENT WITH (NOLOCK) WHERE INCREMENT_ID=@INCREMENT_ID --Added By Ramiz on 11/05/2016 as it was Updating Wrong amount in Increment without this Paramater  
       
       
     EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,@Old_Join_Date  
     --@User_ID,@IP_Address add by chetan 220517  
     EXEC P0095_INCREMENT_INSERT @Increment_ID output ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join ,@Date_OF_Join,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,0,0,0,0,'',@Emp_Late_Mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_Late_Limit,@Late_Dedu_type,@Emp_Part_Time,1,0,@Yearly_Bonus_Amount,Null,@emp_superior,@Dep_Reminder,1,@CTC,0,0,0,0,0,0,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID, @Emp_wd_ot_rate, @Emp_wo_ot_rate, @Emp_ho_ot_rate,0,0,0,@INCREMENT_MODE,@no_of_chlidren,@is_metro,@is_physical,@Salary_Cycle_id,@Auto_Vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Inc_Bank_AC_No_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,0,'',@User_Id,@IP_Address,@Customer_Audit
,@old_Join_Date , @Sales_Code,@Physical_Percent,@Is_PieceTransSalary,@Band_id,@Is_PMGKY,@Is_PFMem --Change By Jaina 22-08-2016  
     --EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@for_date,@Old_Join_Date  
       
     --EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_Of_Join,@Old_Join_Date
	 EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_Of_Join,@Old_Join_Date,0,1    ---added 1 for optional parameter to restrict month lock validation
       
      --Changed by Gadriwala 17022015 For when Date_of_Join change that time wase not effected auto weekoff,Shift effective date   
     if exists (select For_date from  T0100_WEEKOFF_ADJ WITH (NOLOCK) where For_Date = @Old_Join_Date and   Emp_ID =@Emp_ID and Cmp_ID = @Cmp_ID)  
      begin  
         Update T0100_WEEKOFF_ADJ set For_Date = @Date_Of_Join   
         where Emp_ID = @emp_ID and Cmp_ID =@cmp_ID and For_Date = @old_Join_Date   
      end  
     IF EXISTS(SELECT INCREMENT_EFFECTIVE_DATE FROM T0095_INCREMENT WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND INCREMENT_EFFECTIVE_DATE=@OLD_JOIN_DATE AND CMP_ID=@CMP_ID AND INCREMENT_TYPE='JOINING')  
      BEGIN        
       IF (@DATE_OF_JOIN <> @OLD_JOIN_DATE)  
        BEGIN             
         UPDATE T0095_INCREMENT SET INCREMENT_EFFECTIVE_DATE=@DATE_OF_JOIN WHERE EMP_ID=@EMP_ID  
         AND CMP_ID=@CMP_ID AND INCREMENT_EFFECTIVE_DATE=@OLD_JOIN_DATE  
        END   
      END  
     IF EXISTS(SELECT EFFECTIVE_DATE FROM T0011_LOGIN WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND EFFECTIVE_DATE=@OLD_JOIN_DATE AND CMP_ID=@CMP_ID)   
      BEGIN        
       IF (@DATE_OF_JOIN <> @OLD_JOIN_DATE)  
        BEGIN             
         UPDATE T0011_LOGIN SET EFFECTIVE_DATE=@DATE_OF_JOIN WHERE EMP_ID=@EMP_ID  
         AND CMP_ID=@CMP_ID AND EFFECTIVE_DATE=@OLD_JOIN_DATE  
        END   
      END  
        
      --CODE ADDED BY SUMIT 13062016 FOR UPDATE DATE OF JOINING   
        
        
      --if exists (select For_date from  T0100_EMP_SHIFT_DETAIL where For_Date = @Old_Join_Date and   Emp_ID =@Emp_ID and Cmp_ID = @Cmp_ID)  
      --begin  
      --   Update T0100_EMP_SHIFT_DETAIL set For_Date = @Date_Of_Join   
      --   where Emp_ID = @emp_ID and Cmp_ID =@cmp_ID and For_Date = @old_Join_Date   
      --end  
     ------------------------------------------   
     ----Alpesh 26-Mar-2012  
     Declare @Reporting_Row_ID numeric        
     if @Emp_Superior is not null  
      begin                 
       if not exists(Select Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=@Emp_Superior)  
        begin   
         PRINT 'r'  
         exec P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@Emp_Superior,'Direct','i',@Login_Id ,@User_Id,@IP_Address,@Date_Of_Join         
        end  
      end  
     else                                 ----if @Emp_Superior is null  
      begin    
       PRINT @Cmp_ID      
       Select @Reporting_Row_ID = Row_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=isnull(@Emp_Superior_o,0)  
       if @Reporting_Row_ID is null  
        set @Reporting_Row_ID = 0         
       exec P0090_EMP_REPORTING_DETAIL @Reporting_Row_ID,@Emp_ID,@Cmp_ID,'',@Emp_Superior,'Direct','d',@Login_Id,@User_Id,@IP_Address,@Date_Of_Join  
      end  
     --End  
       
     --zalak for manager history--190111  
     if @Emp_Superior_o<>@Emp_Superior  
      exec P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@Emp_Superior,@Date_Of_Join     
        
        
     if not exists (SELECT 1 from T0011_LOGIN WITH (NOLOCK) where Login_Alias = isnull(@Login_Alias,'') AND Emp_ID <> @Emp_ID)  
     begin       
      update T0011_LOGIN SET login_alias = isnull(@Login_Alias,'') where Emp_ID = @Emp_ID        
     end   
      
    --Added by nilesh patel on 10082015 -Start  
    Declare @Pay_Scale_tran_ID as numeric  
    Set @Pay_Scale_tran_ID =0   
    Select @Pay_Scale_tran_ID = Tran_ID From V0050_EMP_PAY_SCALE_DETAIL Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and ROW_NO = 1  
       
    if @Pay_Scale_tran_ID <> 0  
     Begin  
      Update T0050_EMP_PAY_SCALE_DETAIL   
      Set Pay_Scale_ID = @pay_scale_id   
      Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Tran_ID = @Pay_Scale_tran_ID   
     End  
    --Added by nilesh patel on 10082015 -End   
      
    --BELOW CODE ADDED BY SUMIT 14062016----------------------------------------------------------------  
     exec P9999_Audit_get @table = 'T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID ,@String=@String output  
     set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
      
    -------------------------------------------------------------  
      
     end  
 Else If @Tran_Type = 'D'  
  Begin   
    
   --Added by nilesh patel on 08082015 -Start  
   Declare @EmpJoinDate as Datetime  
     
   Select @EmpJoinDate = Date_Of_Join From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @CMP_ID  
  
   IF EXISTS(SELECT 1 FROM  T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID and Cmp_ID=@CMP_ID AND Effective_Date > @EmpJoinDate)  
    Begin  
     --Raiserror('Reference already exists',16,2)  
     set @Emp_ID = 0  
     return @Emp_ID  
       
    End  
   Else  
    Begin  
     Delete FROM T0050_EMP_PAY_SCALE_DETAIL WHERE Cmp_ID=@CMP_ID and Emp_ID = @Emp_ID and Effective_Date = @EmpJoinDate  
    End  
   --Added by nilesh patel on 08082015 -End  
   -----ADDED BELOW CODE BY SUMIT 14062016-----------------------------------------------------------------------------  
   exec P9999_Audit_get @table = 'T0080_EMP_MASTER' ,@key_column='EMP_Id',@key_Values=@Emp_ID ,@String=@String output  
   set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))  
   -------------------------------------------------------------------------  
      
   Update dbo.T0080_EMP_MASTER  Set Increment_ID = Null Where Emp_ID = @Emp_ID And cmp_Id=@Cmp_Id   
       
   Delete From T0090_EMP_CHILDRAN_DETAIL   Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_CONTRACT_DETAIL   Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_DEPENDANT_DETAIL   Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_DOC_DETAIL    Where  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_EMERGENCY_CONTACT_DETAIL Where  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_EXPERIENCE_DETAIL   Where  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_IMMIGRATION_DETAIL  Where  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_LANGUAGE_DETAIL   Where  Emp_ID  = @emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_LICENSE_DETAIL   Where  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_QUALIFICATION_DETAIL  Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_REPORTING_DETAIL   Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   Delete From T0090_EMP_SKILL_DETAIL    Where  Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID     
   DELETE FROM T0110_EMP_LEFT_JOIN_TRAN   WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID  
   DELETE FROM T0100_EMP_EARN_DEDUCTION   WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID  
   DELETE from T0100_Emp_Manager_History   where  Emp_id = @Emp_ID and Cmp_Id=@Cmp_Id--Added By Falak on 19-APR-2011  
   DELETE FROM T0200_MONTHLY_SALARY_LEAVE   WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID --Added By Ramiz on 20-Oct-2015  
   DELETE FROM T0095_INCREMENT      WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID  
   DELETE FROM T0100_WEEKOFF_ADJ     WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID  
   DELETE FROM T0100_EMP_SHIFT_DETAIL    WHERE  EMP_ID = @EMP_ID And cmp_Id=@Cmp_ID  
   DELETE FROM T0140_ADVANCE_TRANSACTION   WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID  
   DELETE FROM T0140_LOAN_TRANSACTION       WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID  
   DELETE FROM T0140_CLAIM_TRANSACTION       WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID  
   DELETE FROM T0140_LEAVE_TRANSACTION       WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID   
   DELETE FROM T0190_MONTHLY_AD_DETAIL_IMPORT     WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID   
   DELETE FROM T0190_MONTHLY_PRESENT_IMPORT     WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID   
   DELETE from T0095_EMP_SCHEME     where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  -- Added by Gadriwala Muslim 08042015  
     
   DELETE FROM T0095_LEAVE_OPENING        WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID -- Added by Mitesh on 27/07/2011   
     
   DELETE from T0100_LEAVE_CF_DETAIL where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  --Added by Nilesh patel 10022016  
   Delete From T0100_LEAVE_CF_Advance_Leave_Balance where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID --Added by Nilesh patel 10022016  
     
   --Added By Jaina 30-10-2015  
   DELETE FROM T0090_EMP_PRIVILEGE_DETAILS WHERE Login_Id = (SELECT Login_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID)  
     
   Declare @Leave_Approval_ID as numeric(18,0)              -- Added by Mitesh on 27/07/2011   
   Select @Leave_Approval_ID=Leave_Approval_ID FROM T0120_LEAVE_APPROVAL WITH (NOLOCK)   WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID -- Added by Mitesh on 27/07/2011        
     
   DELETE FROM T0130_LEAVE_APPROVAL_DETAIL   WHERE  Leave_Approval_ID = @Leave_Approval_ID And cmp_Id=@Cmp_ID -- Added by Mitesh on 27/07/2011   
   DELETE FROM T0120_LEAVE_APPROVAL    WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID -- Added by Mitesh on 27/07/2011   
   delete FROM T0090_Common_Request_Detail where @Emp_ID = @Emp_ID and cmp_id = @Cmp_ID -- Added by Mitesh on 05042013  
  
   Delete From T0150_EMP_INOUT_RECORD              WHERE  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011           
     
     
     
   delete FROM T0095_Emp_Salary_Cycle where Emp_id = @Emp_ID -- added by mitesh on 06072013  
   delete from T0250_Change_Password_History where emp_id=@Emp_ID -- added by rohit on 12082013  
     
  --Added By Mukti(14092015)start  
   declare @Asset_Application_ID as numeric(18,0)  
   declare @Asset_Approval_ID as numeric(18,0)  
   select @Asset_Application_ID  =ISNULL(Asset_Application_ID,0),@Asset_Approval_ID  =ISNULL(Asset_Approval_ID,0) From dbo.T0120_Asset_Approval WITH (NOLOCK) where (Emp_id=@Emp_ID and cmp_id=@cmp_id) or (Applied_by=@Emp_ID and cmp_id=@cmp_id)  
   exec P0120_Asset_Approval_Delete @Asset_Approval_ID,@cmp_id,@Asset_Application_ID  
  --Added By Mukti(14092015)end  
     
   --Added By Sneha(05052016)start  
   Delete from T0090_Emp_JD_Responsibilty where Emp_Id= @Emp_ID  
   --Added By Sneha(05052016)end  
     
   --Added By Jimit 18072018  
   DELETE FROM T0140_REIMCLAIM_TRANSACATION   
   WHERE  EMP_ID= @EMP_ID AND REIM_OPENING = 0 AND  
      REIM_CREDIT = 0 AND REIM_DEBIT = 0 AND REIM_CLOSING = 0 AND  
      REIM_SETT_CR_AMOUNT = 0 AND POSTING_AMOUNT = 0  
   ---ENDED-----   
     

   --'added binal  
   UPDATE APP  
    SET  Is_Final_ApprovaL = 0,  
      Emp_ID=0,  
      Approve_Status='P'  
    FROM T0060_EMP_MASTER_APP APP   
    WHERE APP.Is_Final_Approval=1 AND EMP_ID=@Emp_ID  
   --end added binal  
     
--ADDED BY MR.MEHUL FOR EMPLOYEE MASTER EMPLOYEE DELETE AFTER EMPLOYEE APPROVAL (MAKER CHECKER) 26072022
	
	--DELETE FROM T0100_WEEKOFF_ADJ WHERE Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
  
     DELETE FROM dbo.T0080_EMP_MASTER             WHERE       Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  
   
   Declare @DLogin_ID as numeric(18,0)              -- Added by Mitesh on 27/07/2011   
   Select @DLogin_ID=Login_ID FROM T0011_Login WITH (NOLOCK) WHERE  EMP_ID = @EMP_iD And cmp_Id=@Cmp_ID -- Added by Mitesh on 27/07/2011           
   
   Delete From T0011_LOGIN_HISTORY     WHERE  Login_ID  = @DLogin_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011           
   Delete From T0015_LOGIN_FORM_RIGHTS    WHERE  Login_ID  = @DLogin_ID And cmp_Id=@Cmp_ID  -- Added by Mitesh on 27/07/2011           
   Delete From T0011_Login                   WHERE  Emp_ID  = @Emp_ID And cmp_Id=@Cmp_ID  and Login_ID = @DLogin_ID
     

   Delete from T0090_EMP_REFERENCE_DETAIL where Emp_ID = @Emp_ID And cmp_Id=@Cmp_ID  

   
   update T0060_RESUME_FINAL set confirm_emp_id=0 where confirm_emp_id=@Emp_ID and cmp_id=@cmp_id  
     
    
  End   
  Declare @TranType Varchar(20)  
  Set @TranType = (Case When @Tran_Type = 'I' then 'Insert' When @Tran_Type = 'U' then 'Update' When @Tran_Type = 'D' Then 'Delete' end)  
    
  --exec P9999_Audit_Trail @Cmp_ID,@TranType,'Employee Master',@OldValue,@Emp_ID,@User_Id,@IP_Address,@is_Emp=1  
     
  --For New Values in Audit Trail  
  SELECT * INTO #T0080_EMP_MASTER_INSERTED FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID=@Emp_ID  
     
  EXEC P9999_AUDIT_LOG @TableName='T0080_EMP_MASTER', @IDFieldName='Emp_ID',@Audit_Module_Name='Employee Master',  
   @User_Id=@User_Id,@IP_Address=@IP_Address,@MandatoryFields='Alpha_Emp_Code,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Joining,Grd_ID,Branch_ID,Dept_ID,Desig_ID',  
   @Audit_Change_Type=@Tran_Type   
 RETURN  
  
  
  
  
