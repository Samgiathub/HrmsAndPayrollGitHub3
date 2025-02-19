

CREATE PROCEDURE THIRD_PARTY_TO_EMPLOYEE_MAKER_DATA_UPDATE

AS
BEGIN

--BEGIN TRAN 
--SELECT * FROM [NKP_NEW].dbo.LUBI_ORACAL

DECLARE @EMP_CODE INT  
DECLARE @INTIAL_NAME NVARCHAR(4)  
DECLARE @Emp_First_Name NVARCHAR(50)   
DECLARE @Emp_Second_Name NVARCHAR(50)   
DECLARE @Emp_Last_Name NVARCHAR(50)  
DECLARE @Date_of_Join DATE  
DECLARE @Date_of_Birth DATE  

  
DECLARE EMP_CURSOR CURSOR  
LOCAL  FORWARD_ONLY  FOR  
SELECT * FROM [NKP_NEW].dbo.LUBI_ORACAL  
OPEN EMP_CURSOR  
FETCH NEXT FROM EMP_CURSOR INTO  @EMP_CODE ,@INTIAL_NAME,@Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_of_Join,@Date_of_Birth
WHILE @@FETCH_STATUS = 0  
BEGIN  
IF NOT EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WHERE EMP_CODE = @EMP_CODE)
BEGIN
exec P0060_EMP_MASTER_APP @Emp_Tran_ID=0,@Emp_Application_ID=0 
,@Emp_ID=0
,@Cmp_ID=126
--,@Branch_ID=714,@Cat_ID=0,@Grd_ID=511,@Dept_ID=577,@Desig_ID=1066
,@Branch_ID=0
,@Cat_ID=0
,@Grd_ID=0
,@Dept_ID=0
,@Desig_ID=0
--,@Type_ID=198,@Shift_ID=318,@Bank_ID=0,@Increment_ID=0,@Emp_code=51
,@Type_ID=0
,@Shift_ID=262
,@Bank_ID=0
,@Increment_ID=0
,@Emp_code=@EMP_CODE -- Added By Sajid 06042022
--,@Initial='Mr.'
,@Initial=@INTIAL_NAME -- Added By Sajid 06042022
,@Emp_First_Name=@Emp_First_Name -- Added By Sajid 06042022
,@Emp_Second_Name=@Emp_Second_Name -- Added By Sajid 06042022
,@Emp_Last_Name=@Emp_Last_Name -- Added By Sajid 06042022
,@Curr_ID=0
--,@Date_Of_Join='2021-01-01 00:00:00'
,@Date_Of_Join=@Date_of_Join -- Added By Sajid 06042022
,@SSN_No='',@SIN_No='',@Dr_Lic_No='',@Pan_No=''
--,@Date_Of_Birth='1990-01-01 00:00:00'
,@Date_Of_Birth=@Date_of_Birth -- Added By Sajid 06042022
,@Marital_Status='',@Gender=' ',@Dr_Lic_Ex_Date='',@Nationality=''
,@Loc_ID=1,@Street_1='',@City='',@State='',@Zip_code='',@Home_Tel_no='',@Mobile_No='',@Work_Tel_No='',@Work_Email=''
,@Other_Email='',@Present_Street='',@Present_City='',@Present_State='',@Present_Post_Box=''
,@Emp_Superior=0,@Basic_Salary=0,@Image_Name='Emp_default.png',@Wages_Type='',@Salary_Basis_On=''
,@Payment_Mode='',@Inc_Bank_AC_No='',@Emp_OT=1,@Emp_OT_Min_Limit='',@Emp_OT_Max_Limit=''
,@Emp_Late_mark=0,@Emp_Full_PF=0,@Emp_PT=1,@Emp_Fix_Salary=0
,@tran_type='Insert'
,@Gross_salary=0,@Tall_Led_Name='',@Religion='',@Height='',@Mark_Of_Idetification='',@Dispencery='',@Doctor_name='',@DispenceryAdd='',@Insurance_No='',@Is_GR_App=0,@Is_Yearly_Bonus=1,@Yearly_Leave_Days=0,@Yearly_Leave_Amount=0,@Yearly_Bonus_Per=0,@Yearly_Bonus_Amount=0
,@Emp_Late_Limit='00:00',@Late_Dedu_type=''
,@Emp_Part_Time=0,@Emp_Confirmation_date='',@Is_On_Probation=0,@Tally_Led_ID=0,@Blood_Group='',@Probation=0,@enroll_No=0,@Dep_Reminder=1,@Father_name='',@Bank_BSR_No=''
,@Login_Id=0
,@Old_Ref_No=''
,@Alpha_Code=''
,@Leave_In_Probation=0,@Is_LWF=0,@CTC=0,@Center_ID=0,@DBRD_Code='',@Dealer_Code='',@CCenter_Remark=''
,@Emp_Early_mark=0,@Early_Dedu_Type='',@Emp_Early_Limit=''
,@ifsc_code='',@Emp_wd_ot_rate=0,@Emp_wo_ot_rate=0,@Emp_ho_ot_rate=0
,@Emp_PF_Opening=0,@Emp_Category='',@Emp_UIDNo='',@Emp_Cast='',@Emp_Anniversary_Date='',@Extra_AB_Deduction=0,@Min_CompOff_Limit='',@Mother_name=''
,@no_of_chlidren=0,@is_metro=0,@is_physical=0,@Emp_Offer_date='',@Login_Alias='',@Salary_Cycle_id=0,@Auto_Vpf=0 ,@Segment_ID=0,@Vertical_ID=0,@SubVertical_ID=0
--,@GroupJoiningDate='2021-01-01 00:00:00'
,@GroupJoiningDate=@Date_of_Join -- Added By Sajid 06042022
,@subBranch_ID=0,@Monthly_Deficit_Adjust_OT_Hrs=0 ,@Fix_OT_Hour_Rate_WD=0,@Fix_OT_Hour_Rate_WO_HO=0,@Code_Date_Format='',@Code_Date='',@Bank_ID_Two=0,@Payment_Mode_Two='',@Inc_Bank_AC_No_Two='',@Ifsc_Code_Two=''
,@Bank_Branch_Name='',@Bank_Branch_Name_Two='',@EmpName_Alias_PrimaryBank='',@EmpName_Alias_SecondaryBank='',@EmpName_Alias_PF='',@EmpName_Alias_PT='',@EmpName_Alias_Tax='',@EmpName_Alias_ESIC=''
,@EmpName_Alias_Salary='',@Emp_Notice_Period=0,@Dress_Code='',@Shirt_Size='',@Pent_Size='',@Shoe_Size='',@Canteen_Code='',@Thana_Id=0,@Tehsil='',@District='',@Thana_Id_Wok=0,@Tehsil_Wok='',@District_Wok='',@SkillType_ID=0,@UAN_No=''
,@CompOff_WO_App_Days=0,@CompOff_WO_Avail_Days=0,@CompOff_WD_App_Days=0,@CompOff_WD_Avail_Days=0,@CompOff_HO_App_Days=0,@CompOff_HO_Avail_Days=0
,@Date_Of_Retirement='',@Is_Salary_Depends_On_Production_Details=0,@Ration_Card_Type='APL',@Ration_Card_No='',@Vehicle_NO=''
,@Training_Month=0,@Is_On_Training=0,@Aadhar_Card_No='',@pay_scale_id=0,@Actual_Date_Of_Birth='',@Is_PF_Trust=0,@PF_Trust_No=''
,@Extension_No='',@LinkedIn_Id='',@Twitter_ID='',@Manager_Probation=0,@Customer_Audit=0,@PF_Start_Date='',@Sales_Code=''
,@User_Id='1'
,@IP_Address='192.168.1.53',@Adult_NO=0,@Default_Pwd='VuMs/PGYS74='
,@Leave_Encash_Working_Day=0,@Rejoin_Emp_Id=0,@Physical_Percent=0,@Is_Probation_Month_Days=0,@Is_Trainee_Month_Days=0,@Induction_Training='',@Approved_Emp_ID=0
,@Approved_Date='2022-04-01 00:00:00'
,@Rpt_Level=1,@Approve_Status='P',@Is_Final_Approval=0,@Ref_Emp_Tran_ID=0,@WeekdayCompOffAvail_After_Days=0,@WeekOffCompOffAvail_After_Days=0,@HolidayCompOffAvail_After_Days=0,@Signature_Image_Name='sign_default.png',@Band_ID=0,@Is_PMGKY=0,@Is_PFMem=0 

END
FETCH NEXT FROM EMP_CURSOR INTO  @EMP_CODE ,@INTIAL_NAME,@Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_of_Join,@Date_of_Birth 
END  
CLOSE EMP_CURSOR  
DEALLOCATE EMP_CURSOR  
--Select * From T0060_EMP_MASTER_APP Where CMP_ID=126
--COMMIT
--ROLLBACK

END