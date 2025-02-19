CREATE Procedure SAP_Data_Sycn_GD
@CmpID as int 
As
Begin



DECLARE @count INT = 1
DECLARE @limit INT = 0



-----------------------------------------------------For Store the Data from Temp table -----------------------------------------
Declare @Temp_ID int
Declare @Emp_Code nvarchar(100)
Declare @Emp_StartDate nvarchar(100)
Declare @Initial nvarchar(100)
Declare @EmpLastName nvarchar(100)
Declare @EmpFirstName nvarchar(100)
Declare @EmpMidName nvarchar(100)
Declare @Gender nvarchar(100)
Declare @DateofBirth nvarchar(100)
Declare @Nationality nvarchar(100)
Declare @MeritalStatus nvarchar(100)
Declare @Emp_AnniverDate nvarchar(100)
Declare @NoofChild nvarchar(100)
Declare @BankAcNO nvarchar(100)
Declare @Probation nvarchar(100)
Declare @MobNo nvarchar(100)
Declare @Email nvarchar(100)
-------------------------------------------------------------------------------  END --------------------------------------------------------------------



select ROW_NUMBER() Over (order by id) as rn , * into #temp from SAP_GDAPIdata_Import where Flag_Done=0

select @limit = count(1) from #temp

WHILE @count<= @limit
BEGIN

   select @Temp_ID=id
   ,@Emp_Code=Personnel_number_PERNR		--Direct
   ,@Emp_StartDate = StartDate_BEGDA		--Convert
   ,@Initial = Form_Addr_ANRED				--From Master
   ,@EmpLastName = LastName_NACHN			--Direct
   ,@EmpFirstName = FirstName_VORNA			--Direct
   ,@EmpMidName =MiddleName_MIDNM			--Direct
   ,@Gender = Gender_GESCH					--From Master
   ,@DateofBirth = Birthdate_GBDAT			--Convert
   ,@Nationality =Nationality_NATIO			--From Master
   ,@MeritalStatus = MaritalStatus_FAMST	--From Master
   ,@Emp_AnniverDate = Since_FAMDT			--Convert
   ,@NoofChild = No_child_ANZKD				--Direct
   ,@BankAcNO = BankAccount_BANKN			--Direct
   ,@Probation = ProbPeriod_PRBZT			--Direct(With Condtion)
   ,@MobNo = IDnumber_USRID_0010			--DIrect
   ,@Email = IDNumber_USRID_0035			--Direct
   from #temp where  rn = @count


  If Exists(select * from T0080_EMP_MASTER where Emp_code=@Emp_Code and Cmp_ID=@CmpID)
  Begin

			update SAP_GDAPIdata_Import set Flag_Done=2,UDTM=GETDATE() where id=@Temp_ID
			print 'No'
  
  End
  else
  Begin


			---------------For Get Employee ALpha Code--------------------------------------						
			declare @EmpCode as table
			(
			      Alpha_Code varchar(10),
				  Emp_Code varchar(100)
			)
			
			insert into @EmpCode
			exec Get_Employee_Code @Cmp_ID=@CmpID,@Branch_Id=0,@JoiningDate='',@Desig_ID=0,@Cate_ID=0,@Type_ID=0,@Date_OF_Birth='',@Grd_ID=0
			
			
			Declare @Emp_Alpha as varchar(10) --For Employee Aplha
	        select top 1 @Emp_Alpha=  case when Alpha_Code = '' then 'S' else Alpha_Code end from @EmpCode

			---------------------------------------------------  END  -------------------------------------------



			------------------------------------------For Get Joining Date Converted for Data----------------------------------
			Declare @EmpJoinDateCN datetime
			if @Emp_StartDate <>''
			Begin
					set @EmpJoinDateCN = CONVERT(VARCHAR(10), CONVERT(date, @Emp_StartDate, 105), 23)
			End
			else
			Begin
						set @EmpJoinDateCN = null
			End
			-------------------------------------------------------  END  ------------------------------------------------------





			------------------------------------------For Get Birthdate Date Converted for Data----------------------------------
			Declare @EmpDOBDateCN datetime
			if @DateofBirth <>''
			Begin
					set @EmpDOBDateCN = CONVERT(VARCHAR(10), CONVERT(date, @DateofBirth, 105), 23)
			End
			else
			Begin
						set @EmpDOBDateCN = null
			End
			--------------------------------------------------  END  ------------------------------------------------------------


			------------------------------------------For Get Anniversary date Converted for Data----------------------------------
			Declare @EmpAnniverDateCN datetime
			if @Emp_AnniverDate <>''
			Begin
					set @EmpAnniverDateCN = CONVERT(VARCHAR(10), CONVERT(date, @Emp_AnniverDate, 105), 23)
			End
			else
			Begin
						set @EmpAnniverDateCN = null
			End
			------------------------------------------------------  END  -----------------------------------------------------------



			--------------------------------------------Get Data from Master(SAP_ANRED)  for Initial    ---------------------------------------------------
			Declare @InitialMast as varchar(50)
			select @InitialMast = Alias from SAP_ANRED where ANRED=@Initial
			-------------------------------------------------------------  END  ---------------------------------------------------------------------------


			--------------------------------------------Get Data from Master(SAP_GESCH) for Gender     ---------------------------------------------------
            Declare @GenderMst as varchar(1)
			select @GenderMst = Alias from SAP_GESCH where  GESCH =@Gender
			---------------------------------------------------------------------   END   ----------------------------------------------------------------

			--------------------------------------------Get Data from Master(SAP_NATIO)  Nationality   ---------------------------------------------------
            Declare @NationalityMst as varchar(100)
			select @NationalityMst = Alias from SAP_NATIO where NATIO =@Nationality
			--------------------------------------------------------------------   END   ----------------------------------------------------------------

			--------------------------------------------Get Data from Master(SAP_GESCH)  Marital Status    ---------------------------------------------------
            Declare @MeritalStatusMst as varchar(10)
			select @MeritalStatusMst = Alias from SAP_FAMST where  FAMST =@MeritalStatus 
			 
			 Declare @NoChildCN int

			if @NoofChild <>''
			Begin
			      set @NoChildCN = @NoofChild
			End
			else
			Begin
					set @NoChildCN = 0
			End


			--------------------------------------------------------   END   ----------------------------------------------------------------

			------------------------------------------------Check Employee for Probation ------------------------------------------------------
			Declare @isPr0bation int 
			if @Probation <>''
			Begin
					set @isPr0bation =1
			End
			else
			Begin
					set @isPr0bation =0
			End
			-------------------------------------------------------End----------------------------------------------------------------------

		
		
			-------------------------------------------------------------- Get EMP Type --------------------------------------------------------------------
			Declare @TypID int
			select @TypID = [Type_ID] from T0040_TYPE_MASTER where Cmp_ID=@CmpID and [Type_Name]  like '%permanent%'
			-------------------------------------------------------End----------------------------------------------------------------------
			






------------------------------------------------------------ Employee Master  SP Execution -------------------------------------------------------
--Begin tran

declare @p1 int 

set @p1=(select max(Emp_ID) from T0080_EMP_MASTER )

exec P0080_EMP_MASTER @Emp_ID=@p1 output,
@Cmp_ID=@CmpID, --API BUKRS
@Branch_ID=484,  --Required Not Given in API
@Cat_ID=0, 
@Grd_ID=671,  --Required Not Given in API
@Dept_ID=0,
@Desig_ID=622,  --Required Not Given in API

@Type_ID=@TypID,   --ANSVH and other veriose type

@Shift_ID=450,   --Required Not Given in API
@Bank_ID=0,      
@Increment_ID=0,
@Emp_code=@Emp_Code, -- Emp Code PERNR
@Initial=@InitialMast,  -- ANRED
@Emp_First_Name=@EmpFirstName, --VORNA
@Emp_Second_Name=@EmpMidName, --MIDNM
@Emp_Last_Name=@EmpLastName, --NACHN
@Curr_ID=0,
@Date_Of_Join=@EmpJoinDateCN,  --BEGDA
@SSN_No='',
@SIN_No='',
@Dr_Lic_No='',
@Pan_No='',
@Date_Of_Birth=@EmpDOBDateCN, --GBDAT
@Marital_Status=@MeritalStatusMst, --FAMST
@Gender=@GenderMst, --GESCH
@Dr_Lic_Ex_Date='',
@Nationality=@NationalityMst, --NATIO
@Loc_ID=1,
@Street_1='',
@City='',
@State='',
@Zip_code='',
@Home_Tel_no='',
@Mobile_No=@MobNo,   --USRID_0010/USRID_0035
@Work_Tel_No='',
@Work_Email=@Email, --USRID_0010/USRID_0035
@Other_Email='',
@Present_Street='',
@Present_City='',
@Present_State='',
@Present_Post_Box='',
@Emp_Superior=0,
@Basic_Salary=0,
@Image_Name='',
@Wages_Type='',
@Salary_Basis_On='',
@Payment_Mode='',
@Inc_Bank_AC_No=@BankAcNO, --BANKN
@Emp_OT=1,
@Emp_OT_Min_Limit='',
@Emp_OT_Max_Limit='',
@Emp_Late_mark=1,
@Emp_Full_PF=0,
@Emp_PT=1,
@Geo=0,
@Emp_Fix_Salary=0,
@tran_type='Insert',
@Gross_salary=0,
@Tall_Led_Name='',
@Religion='',
@Height='',
@Mark_Of_Idetification='',
@Dispencery='',
@Doctor_name='',
@DispenceryAdd='',
@Insurance_No='',
@Is_GR_App=1,
@Is_Yearly_Bonus=1,
@Yearly_Leave_Days=0,
@Yearly_Leave_Amount=0,
@Yearly_Bonus_Per=0,
@Yearly_Bonus_Amount=0,
@Emp_Late_Limit='00:00',
@Late_Dedu_type='',
@Emp_Part_Time=0, --ANSVH
@Emp_Confirmation_date='',
@Is_On_Probation=@isPr0bation, --PRBZT
@Tally_Led_ID=0,
@Blood_Group='',
@Probation=@Probation, --PRBZT
@enroll_No=0,
@Dep_Reminder=1,
@Father_name='',
@Bank_BSR_No='',
@Login_Id=7017,
@Old_Ref_No='',
@Alpha_Code=@Emp_Alpha,
@Leave_In_Probation=0,
@Is_LWF=0,
@CTC=0,
@Center_ID=0,
@DBRD_Code='',
@Dealer_Code='',
@CCenter_Remark='',
@Emp_Early_mark=1,
@Early_Dedu_Type='',
@Emp_Early_Limit='',
@ifsc_code='',
@Emp_wd_ot_rate=0,
@Emp_wo_ot_rate=0,
@Emp_ho_ot_rate=0,
@Emp_PF_Opening=0,
@Emp_Category='',
@Emp_UIDNo='',
@Emp_Cast='',
@Emp_Anniversary_Date=@EmpAnniverDateCN, --FAMDT
@Extra_AB_Deduction=0,
@Min_CompOff_Limit='',
@Mother_name='',
@no_of_chlidren=@NoChildCN, --ANZKD
@is_metro=0,
@is_physical=0,
@Emp_Offer_date='',
@Login_Alias='',
@Salary_Cycle_id=0,
@Auto_Vpf=0,
@Segment_ID=0,
@Vertical_ID=0,
@SubVertical_ID=0,
@GroupJoiningDate=@EmpJoinDateCN,
@subBranch_ID=0,
@Monthly_Deficit_Adjust_OT_Hrs=0,
@Fix_OT_Hour_Rate_WD=0,
@Fix_OT_Hour_Rate_WO_HO=0,
@Code_Date_Format='',
@Code_Date='',
@Bank_ID_Two=0,
@Payment_Mode_Two='',
@Inc_Bank_AC_No_Two='',  
@Ifsc_Code_Two='',
@Bank_Branch_Name='',
@Bank_Branch_Name_Two='',
@EmpName_Alias_PrimaryBank='',
@EmpName_Alias_SecondaryBank='',
@EmpName_Alias_PF='',
@EmpName_Alias_PT='',
@EmpName_Alias_Tax='',
@EmpName_Alias_ESIC='',
@EmpName_Alias_Salary='',
@Emp_Notice_Period=0,
@Dress_Code='',
@Shirt_Size='',
@Pent_Size='',
@Shoe_Size='',
@Canteen_Code='',
@Thana_Id=0,
@Tehsil='',
@District='',
@Thana_Id_Wok=0,
@Tehsil_Wok='',
@District_Wok='',
@SkillType_ID=0,
@UAN_No='',
@CompOff_WO_App_Days=0,
@CompOff_WO_Avail_Days=0,
@CompOff_WD_App_Days=0,
@CompOff_WD_Avail_Days=0,
@CompOff_HO_App_Days=0,
@CompOff_HO_Avail_Days=0,
@Date_Of_Retirement='',
@Is_Salary_Depends_On_Production_Details=0,
@Ration_Card_Type='APL',
@Ration_Card_No='',
@Vehicle_NO='',
@Training_Month=0,
@Is_On_Training=0,
@Aadhar_Card_No='',
@pay_scale_id=0,
@Actual_Date_Of_Birth='',
@Is_PF_Trust=0,
@PF_Trust_No='',
@Extension_No='',
@LinkedIn_Id='',
@Twitter_ID='',
@Manager_Probation=0,
@Customer_Audit=0,
@PF_Start_Date='',
@Sales_Code='',
@User_Id='7017',  --By default user ID 
@IP_Address='',
@Adult_NO=0,
@Default_Pwd='',
@Leave_Encash_Working_Day=0,
@Rejoin_Emp_Id=0,
@Physical_Percent=0,
@Is_Probation_Month_Days=0,
@Is_Trainee_Month_Days=0,
@Induction_Training='',
@WeekdayCompOffAvail_After_Days=0,
@WeekOffCompOffAvail_After_Days=0,
@HolidayCompOffAvail_After_Days=0,
@Sign_ImageName='sign_default.png',
@Is_PieceTransSalary=0,
@Is_VBA=0,
@Band_id=0,
@Is_PMGKY=0,
@Is_PFMem=0 


--select @p1	

--rollback

print 'Yes'
----------------------------------------------------------------------- END ----------------------------------------------------------------------
             update SAP_GDAPIdata_Import set Flag_Done=1,UDTM=GETDATE() where id=@Temp_ID
  End





  SET @count = @count + 1   -- For Loop Increment 
END


drop table #temp  -- For Flush Temptable  





End