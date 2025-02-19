

-- =============================================
-- Author:		<Jaina>
-- Create date: <03-03-2018>
-- Description:	<Rejoin Employee Detail>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Rejoin_Employee_Detail]
   @Cmp_ID	numeric(18,0),
   @Emp_Id	numeric(18,0),
   @Rejoin_EmpId numeric(18,0)
   
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	-------- Employee Increment Detail Start ---------------
	DECLARE @INCREMENT_ID NUMERIC(18,0)
	SELECT @INCREMENT_ID = INCREMENT_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @REJOIN_EMPID AND CMP_ID =@CMP_ID	
	
	DECLARE @MAX_INCREMENT NUMERIC
	select @MAX_INCREMENT = Increment_ID from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @Emp_id and Cmp_ID=@Cmp_id
		
	  DECLARE @Bank_ID numeric(18,0)
      Declare @Curr_ID numeric(18,0)
      Declare @Wages_Type VARCHAR(10)
      Declare @Salary_Basis_On VARCHAR(20)
      Declare @Basic_Salary NUMERIC(18, 4)
      Declare @Gross_Salary NUMERIC(18, 4)
      Declare @Increment_Type VARCHAR(30)
      Declare @Increment_Date Datetime
      Declare @Increment_Effective_Date Datetime
      Declare @Payment_Mode VARCHAR(20)
      Declare @Inc_Bank_AC_No VARCHAR(20)
      Declare @Emp_OT NUMERIC(18, 0)
      Declare @Emp_OT_Min_Limit VARCHAR(10)
      Declare @Emp_OT_Max_Limit VARCHAR(10)
      Declare @Increment_Per NUMERIC(18, 4)
      Declare @Increment_Amount NUMERIC(18, 4)
      Declare @Pre_Basic_Salary NUMERIC(18, 4)
      Declare @Pre_Gross_Salary NUMERIC(18, 4)
      Declare @Increment_Comments VARCHAR(250)
      Declare @Emp_Late_mark NUMERIC
      Declare @Emp_Full_PF NUMERIC
      Declare @Emp_PT NUMERIC
      Declare @Emp_Fix_Salary NUMERIC
      Declare @Emp_Part_Time NUMERIC(1,0)
      Declare @Late_Dedu_Type VARCHAR(10)
      Declare @Emp_Late_Limit VARCHAR(10) = '00:00'
      Declare @Emp_PT_Amount numeric(5,0)
      Declare @Emp_Childran tinyint
      Declare @Is_Master_Rec tinyint
      Declare @Login_ID numeric(18,0)      
      Declare @Yearly_Bonus_Amount NUMERIC(18, 4)
      Declare @Deputation_End_Date datetime
      Declare @Is_Deputation_Reminder tinyint
      Declare @Appr_Int_ID numeric(18,0)
      Declare @CTC numeric(18,4)
      Declare @Emp_Early_mark numeric
      Declare @Early_Dedu_Type varchar(10)
      Declare @Emp_Early_Limit varchar(10)
      Declare @Emp_Deficit_mark numeric
      Declare @Deficit_Dedu_Type varchar(10)
      Declare @Emp_Deficit_Limit varchar(10)
      Declare @Center_ID numeric(18,0)
      Declare @Emp_WeekDay_OT_Rate numeric(10,3)
      Declare @Emp_WeekOff_OT_Rate numeric(10,3)
      Declare @Emp_Holiday_OT_Rate numeric(10,3)
      Declare @Is_Metro_City tinyint
      Declare @Pre_CTC_Salary numeric(18,4)
      Declare @Incerment_Amount_gross numeric(18,4)
      Declare @Incerment_Amount_CTC numeric(18,4)
      Declare @Increment_Mode tinyint
      Declare @is_physical tinyint
      Declare @SalDate_id numeric(18,0)
      Declare @Emp_Auto_Vpf tinyint
      Declare @Segment_ID numeric(10,0)
      Declare @Vertical_ID numeric(10,0)
      Declare @SubVertical_ID numeric(10,0)
      Declare @subBranch_ID numeric(10,0)
      Declare @Monthly_Deficit_Adjust_OT_Hrs tinyint
      Declare @Fix_OT_Hour_Rate_WD numeric(18,3)
      Declare @Fix_OT_Hour_Rate_WO_HO numeric(18,3)
      Declare @Bank_ID_Two numeric(18,0)
      Declare @Payment_Mode_Two varchar(20)
      Declare @Inc_Bank_AC_No_Two varchar(20)
      Declare @Bank_Branch_Name varchar(50)
      Declare @Bank_Branch_Name_Two varchar(50)
      Declare @Reason_ID numeric(5,0)
      Declare @Reason_Name varchar(500)
      Declare @Increment_App_ID numeric(18,0)
      Declare @Customer_Audit tinyint
      Declare @Sales_Code varchar(20)
	
	
	select
	   @Bank_ID = Bank_ID
      ,@Curr_ID = Curr_ID
      ,@Wages_Type = Wages_Type
      ,@Salary_Basis_On = Salary_Basis_On
      ,@Basic_Salary = Basic_Salary
      ,@Gross_Salary = Gross_Salary
      ,@Increment_Type = Increment_Type
      ,@Increment_Date = Increment_Date
      ,@Increment_Effective_Date = Increment_Effective_Date
      ,@Payment_Mode = Payment_Mode
      ,@Inc_Bank_AC_No = Inc_Bank_AC_No
      ,@Emp_OT = Emp_OT
      ,@Emp_OT_Min_Limit = Emp_OT_Min_Limit
      ,@Emp_OT_Max_Limit = Emp_OT_Max_Limit
      ,@Increment_Per = Increment_Per
      ,@Increment_Amount = Increment_Amount
      ,@Pre_Basic_Salary = Pre_Basic_Salary
      ,@Pre_Gross_Salary = Pre_Gross_Salary
      ,@Increment_Comments = Increment_Comments
      ,@Emp_Late_mark = Emp_Late_mark
      ,@Emp_Full_PF = Emp_Full_PF
      ,@Emp_PT = Emp_PT
      ,@Emp_Fix_Salary = Emp_Fix_Salary
      ,@Emp_Part_Time = Emp_Part_Time
      ,@Late_Dedu_Type = Late_Dedu_Type
      ,@Emp_Late_Limit = Emp_Late_Limit
      ,@Emp_PT_Amount = Emp_PT_Amount
      ,@Emp_Childran = Emp_Childran
      ,@Is_Master_Rec = Is_Master_Rec            
      ,@Yearly_Bonus_Amount = Yearly_Bonus_Amount
      ,@Deputation_End_Date = Deputation_End_Date
      ,@Is_Deputation_Reminder = Is_Deputation_Reminder
      ,@Appr_Int_ID = Appr_Int_ID
      ,@CTC = CTC
      ,@Emp_Early_mark = Emp_Early_mark
      ,@Early_Dedu_Type = Early_Dedu_Type
      ,@Emp_Early_Limit = Emp_Early_Limit
      ,@Emp_Deficit_mark = Emp_Deficit_mark
      ,@Deficit_Dedu_Type = Deficit_Dedu_Type
      ,@Emp_Deficit_Limit = Emp_Deficit_Limit
      ,@Center_ID = Center_ID
      ,@Emp_WeekDay_OT_Rate = Emp_WeekDay_OT_Rate
      ,@Emp_WeekOff_OT_Rate = Emp_WeekOff_OT_Rate
      ,@Emp_Holiday_OT_Rate = Emp_Holiday_OT_Rate
      ,@Is_Metro_City = Is_Metro_City
      ,@Pre_CTC_Salary = Pre_CTC_Salary
      ,@Incerment_Amount_gross = Incerment_Amount_gross
      ,@Incerment_Amount_CTC = Incerment_Amount_CTC
      ,@Increment_Mode = Increment_Mode
      ,@is_physical = is_physical
      ,@SalDate_id = SalDate_id
      ,@Emp_Auto_Vpf = Emp_Auto_Vpf
      ,@Segment_ID = Segment_ID
      ,@Vertical_ID = Vertical_ID
      ,@SubVertical_ID = SubVertical_ID
      ,@subBranch_ID = subBranch_ID
      ,@Monthly_Deficit_Adjust_OT_Hrs = Monthly_Deficit_Adjust_OT_Hrs
      ,@Fix_OT_Hour_Rate_WD = Fix_OT_Hour_Rate_WD
      ,@Fix_OT_Hour_Rate_WO_HO = Fix_OT_Hour_Rate_WO_HO
      ,@Bank_ID_Two = Bank_ID_Two
      ,@Payment_Mode_Two = Payment_Mode_Two
      ,@Inc_Bank_AC_No_Two = Inc_Bank_AC_No_Two
      ,@Bank_Branch_Name = Bank_Branch_Name
      ,@Bank_Branch_Name_Two = Bank_Branch_Name_Two
      ,@Reason_ID = Reason_ID
      ,@Reason_Name = Reason_Name
      ,@Increment_App_ID = Increment_App_ID
      ,@Customer_Audit = Customer_Audit
      ,@Sales_Code = Sales_Code
  FROM T0095_INCREMENT WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Increment_ID = @INCREMENT_ID
	
		--Not Updated Basic Salary, Gross Salary,CTC,Increment_Type,Increment_date,Increment_Effectivce_Date, Login_Id,System_date
		--Before Bank_ID Column
	
 UPDATE T0095_INCREMENT
 SET   Bank_ID = @Bank_ID
      ,Curr_ID = @Curr_ID
      ,Wages_Type = @Wages_Type
      ,Salary_Basis_On = @Salary_Basis_On      
      ,Payment_Mode = @Payment_Mode
      ,Inc_Bank_AC_No = @Inc_Bank_AC_No
      ,Emp_OT = @Emp_OT
      ,Emp_OT_Min_Limit = @Emp_OT_Min_Limit
      ,Emp_OT_Max_Limit = @Emp_OT_Max_Limit
      ,Increment_Per = @Increment_Per
      ,Increment_Amount = @Increment_Amount
      ,Pre_Basic_Salary = @Pre_Basic_Salary
      ,Pre_Gross_Salary = @Pre_Gross_Salary
      ,Increment_Comments = @Increment_Comments
      ,Emp_Late_mark = @Emp_Late_mark
      ,Emp_Full_PF = @Emp_Full_PF
      ,Emp_PT = @Emp_PT
      ,Emp_Fix_Salary = @Emp_Fix_Salary
      ,Emp_Part_Time = @Emp_Part_Time
      ,Late_Dedu_Type = @Late_Dedu_Type
      ,Emp_Late_Limit = @Emp_Late_Limit
      ,Emp_PT_Amount = @Emp_PT_Amount
      ,Emp_Childran = @Emp_Childran
      ,Is_Master_Rec = @Is_Master_Rec            
      ,Yearly_Bonus_Amount = @Yearly_Bonus_Amount
      ,Deputation_End_Date = @Deputation_End_Date
      ,Is_Deputation_Reminder = @Is_Deputation_Reminder
      ,Appr_Int_ID = @Appr_Int_ID      
      ,Emp_Early_mark = @Emp_Early_mark
      ,Early_Dedu_Type = @Early_Dedu_Type
      ,Emp_Early_Limit = @Emp_Early_Limit
      ,Emp_Deficit_mark = @Emp_Deficit_mark
      ,Deficit_Dedu_Type = @Deficit_Dedu_Type
      ,Emp_Deficit_Limit = @Emp_Deficit_Limit
      ,Center_ID = @Center_ID
      ,Emp_WeekDay_OT_Rate = @Emp_WeekDay_OT_Rate
      ,Emp_WeekOff_OT_Rate = @Emp_WeekOff_OT_Rate
      ,Emp_Holiday_OT_Rate = @Emp_Holiday_OT_Rate
      ,Is_Metro_City = @Is_Metro_City
      ,Pre_CTC_Salary = @Pre_CTC_Salary
      ,Incerment_Amount_gross = @Incerment_Amount_gross
      ,Incerment_Amount_CTC = @Incerment_Amount_CTC
      ,Increment_Mode = @Increment_Mode
      ,is_physical = @is_physical
      ,SalDate_id = @SalDate_id
      ,Emp_Auto_Vpf = @Emp_Auto_Vpf
      ,Segment_ID = @Segment_ID
      ,Vertical_ID = @Vertical_ID
      ,SubVertical_ID = @SubVertical_ID
      ,subBranch_ID = @subBranch_ID
      ,Monthly_Deficit_Adjust_OT_Hrs = @Monthly_Deficit_Adjust_OT_Hrs
      ,Fix_OT_Hour_Rate_WD = @Fix_OT_Hour_Rate_WD
      ,Fix_OT_Hour_Rate_WO_HO = @Fix_OT_Hour_Rate_WO_HO
      ,Bank_ID_Two = @Bank_ID_Two
      ,Payment_Mode_Two = @Payment_Mode_Two
      ,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two
      ,Bank_Branch_Name = @Bank_Branch_Name
      ,Bank_Branch_Name_Two = @Bank_Branch_Name_Two
      ,Reason_ID = @Reason_ID
      ,Reason_Name = @Reason_Name
      ,Increment_App_ID = @Increment_App_ID
      ,Customer_Audit = @Customer_Audit
      ,Sales_Code = @Sales_Code
  where Emp_ID = @Emp_ID and Increment_ID = @MAX_INCREMENT

	
	-------- Employee Increment Detail End ---------------
	
	-------- Emergency Contact Detail Start  ---------------    
    
    IF  exists (select 1 from T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Emp_ID = @Rejoin_EmpId)
    BEGIN	
			DECLARE @Row_EMER as numeric
			select @Row_EMER = Isnull(max(Row_ID),0)  From T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK)
					
			INSERT INTO T0090_EMP_EMERGENCY_CONTACT_DETAIL
				   (Emp_ID, Row_ID, Cmp_ID, RelationShip, Name, Home_Tel_No, Home_Mobile_No, Work_Tel_No)			
			select @Emp_Id,@Row_EMER + ROW_NUMBER() over(ORDER BY Row_ID) as Row_ID ,@Cmp_id,RelationShip,Name,Home_Tel_No,Home_Mobile_No, Work_Tel_No 
			from   T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK)
			where  Emp_ID = @Rejoin_EmpId  and Cmp_ID=@Cmp_ID
	END				
	
    -------- Emergency Contact Detail End  ---------------
    
    -------- Emergency Dependant Detail End  ---------------
    IF exists ( SELECT 1  from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_id  and Emp_ID = @Rejoin_EmpId)
    BEGIN
			DECLARE @ROW_DEPENDANT AS NUMERIC
			select @ROW_DEPENDANT = Isnull(max(Row_ID),0)  From T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK)
										
			INSERT INTO T0090_EMP_DEPENDANT_DETAIL
				   (Emp_ID, Row_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,Pan_Card_No,Adhar_Card_No)
			SELECT @Emp_id,@ROW_DEPENDANT + ROW_NUMBER() over (ORDER BY Row_ID) As Row_ID ,@Cmp_id,
					Name,RelationShip,BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,Pan_Card_No,Adhar_Card_No
		    from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK)
		    where Cmp_ID = @Cmp_ID and Emp_ID=@Rejoin_EmpId
	End			                      
	-------- Emergency Depandant Contact Detail End  ---------------
	
	-------- Employee member Detail Start ---------------------------------
	
	IF exists ( SELECT 1 from T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Emp_ID=@Rejoin_EmpId)
	BEGIN
			DECLARE @ROW_CHIDRAN AS NUMERIC
			select @ROW_CHIDRAN = Isnull(max(Row_ID),0)  From T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_CHILDRAN_DETAIL (ROW_ID,EMP_ID,CMP_ID,NAME,GENDER,DATE_OF_BIRTH,C_AGE,IS_RESI,RELATIONSHIP,IS_DEPENDANT,IMAGE_PATH,PAN_CARD_NO,ADHAR_CARD_NO) 
			SELECT @ROW_CHIDRAN + ROW_NUMBER() over ( ORDER BY Row_ID) as Row_ID,@EMP_ID,@CMP_ID,NAME,GENDER,DATE_OF_BIRTH,C_AGE,IS_RESI,RELATIONSHIP,IS_DEPENDANT,IMAGE_PATH,PAN_CARD_NO,ADHAR_CARD_NO
			FROM T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
			WHERE CMP_ID=@CMP_ID AND EMP_ID=@REJOIN_EMPID
	END
	
	-------- Employee member Detail End ---------------------------------
	
	
	-------- Immegration Detail Start ------------------------------
	IF exists ( SELECT 1 FROM T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Emp_ID= @Rejoin_EmpId)
	BEGIN
			DECLARE @ROW_IMMI AS NUMERIC
			select @ROW_IMMI = Isnull(max(Row_ID),0)  From T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_IMMIGRATION_DETAIL
						(Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,attach_doc)
			SELECT @ROW_IMMI + ROW_NUMBER() over(ORDER BY Row_ID) as Row_ID,@Emp_Id,@Cmp_Id,Imm_Type,Imm_No,Imm_Issue_Date,Imm_Issue_Status,Imm_Review_Date,Imm_Comments,Imm_Date_of_Expiry,Loc_ID,attach_doc
			from T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK)
			where Cmp_ID=@Cmp_Id AND Emp_ID= @Rejoin_EmpId	
	END			                      
	-------- Immegration Detail End ------------------------------
	
	
	-------- License Detail Start ---------------------------------
	IF EXISTS (SELECT 1 FROM T0090_EMP_LICENSE_DETAIL WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND EMP_ID=@REJOIN_EMPID)
	BEGIN
			DECLARE @ROW_LIC AS NUMERIC
			select @ROW_LIC = Isnull(max(Row_ID),0)  From T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_LICENSE_DETAIL
					   (EMP_ID, ROW_ID, CMP_ID, LIC_ID, LIC_ST_DATE, LIC_END_DATE, LIC_COMMENTS,LIC_FOR,LIC_NUMBER,IS_EXPIRED)
			SELECT @EMP_ID,@ROW_LIC + ROW_NUMBER() over (ORDER BY Row_ID) AS ROW_ID, @CMP_ID, LIC_ID,LIC_ST_DATE,LIC_END_DATE,LIC_COMMENTS,LIC_FOR,LIC_NUMBER,IS_EXPIRED
			FROM T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)
			WHERE CMP_ID= @CMP_ID AND EMP_ID=@REJOIN_EMPID
	END
	
	-------- License Detail End ---------------------------------
	-------- Employee Experience Detail Start --------------------------
	IF EXISTS( SELECT 1 FROM T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND EMP_ID= @REJOIN_EMPID)
	BEGIN
			DECLARE @ROW_EXPERIENCE AS NUMERIC
			select @ROW_EXPERIENCE = Isnull(max(Row_ID),0)  From T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_EXPERIENCE_DETAIL(ROW_ID ,EMP_ID ,CMP_ID ,EMPLOYER_NAME,DESIG_NAME,ST_DATE,END_DATE,CTC_AMOUNT,GROSS_SALARY,EXP_REMARKS,EMP_BRANCH,EMP_LOCATION,MANAGER_NAME,CONTACT_NUMBER,EMPEXP,INDUSTRYTYPE)
			SELECT @ROW_EXPERIENCE + ROW_NUMBER() over(ORDER BY Row_ID) AS ROW_ID,@EMP_ID,@CMP_ID,EMPLOYER_NAME,DESIG_NAME,ST_DATE,END_DATE,CTC_AMOUNT,GROSS_SALARY,EXP_REMARKS,EMP_BRANCH,EMP_LOCATION,MANAGER_NAME,CONTACT_NUMBER,EMPEXP,INDUSTRYTYPE
			FROM T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
			WHERE CMP_ID =@CMP_ID AND EMP_ID = @REJOIN_EMPID
						
	END			                      
	
	-------- Employee Experience Detail End --------------------------
	
	-------- Employee Language Detail Start --------------------------
	
	if exists ( SELECT 1 FROM T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK)  where Cmp_ID = @Cmp_Id AND Emp_Id = @Rejoin_EmpId)
	BEGIN
			DECLARE @ROW_LANGUAGE AS NUMERIC
			select @ROW_LANGUAGE = Isnull(max(Row_ID),0)  From T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_LANGUAGE_DETAIL
					   (Row_ID, Emp_Id, Cmp_ID, Lang_ID, Lang_Fluency, Lang_Ability)
			SELECT @ROW_LANGUAGE + ROW_NUMBER() over (ORDER BY Row_ID) AS ROW_ID,@Emp_Id,@Cmp_Id,Lang_ID,Lang_Fluency,Lang_Ability
			FROM T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_Id AND Emp_Id = @Rejoin_EmpId				                      
	END				            
	-------- Employee Language Detail End --------------------------
	
	-------- Employee Qualification Detail Start  ------------------------
	IF exists ( SELECT 1 FROM  T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Emp_ID = @Rejoin_EmpID)
	BEGIN
			DECLARE @ROW_QUA AS NUMERIC
			select @ROW_QUA = Isnull(max(Row_ID),0)  From T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
						
			INSERT INTO T0090_EMP_QUALIFICATION_DETAIL
						(Emp_ID, Row_ID, Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,attach_doc)
			SELECT @Emp_Id,@ROW_QUA + ROW_NUMBER() over (ORDER BY Row_ID) AS ROW_ID,@Cmp_id,Qual_ID,Specialization,Year,Score,St_Date,End_Date,Comments,attach_doc
			from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
			where Cmp_ID = @Cmp_Id and Emp_ID = @Rejoin_EmpID
	END				                      
	-------- Employee Qualification Detail End  ------------------------
	
	-------- Employee Skill Detail Start  ------------------------
	
	if exists ( SELECT 1 from T0090_EMP_SKILL_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Emp_ID = @Rejoin_EmpID)
	BEGIN
			DECLARE @ROW_SKILL AS NUMERIC
			select @ROW_SKILL = Isnull(max(Row_ID),0)  From T0090_EMP_SKILL_DETAIL WITH (NOLOCK)
												
			INSERT INTO T0090_EMP_SKILL_DETAIL
					   (Row_ID,Emp_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience)
			SELECT @ROW_SKILL + ROW_NUMBER() over(ORDER BY Row_ID) AS ROW_ID,@Emp_Id,@Cmp_id,Skill_ID,Skill_Comments,Skill_Experience
			from T0090_EMP_SKILL_DETAIL WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Emp_ID = @Rejoin_EmpID
	END
	-------- Employee Skill Detail End  ------------------------
	
	
	---------- Employee Attachment Doc Detail Start ---------------------
	
	if exists (SELECT 1 FROM T0090_EMP_DOC_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id AND Emp_ID = @Rejoin_EmpID)
	BEGIN
			DECLARE @ROW_DOC AS NUMERIC
			select @ROW_DOC = Isnull(max(Row_ID),0)  From T0090_EMP_DOC_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_DOC_DETAIL
		               (Row_ID, Emp_Id, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments,Date_of_Expiry)
			SELECT @ROW_DOC + ROW_NUMBER()over (ORDER BY Row_ID) AS ROW_ID, @Emp_Id,@Cmp_Id,Doc_ID,Doc_Path,Doc_Comments,Date_of_Expiry 
			FROM T0090_EMP_DOC_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id AND Emp_ID = @Rejoin_EmpID
	ENd
	---------- Employee Attachment Doc Detail End ---------------------
	
	
	----------- Employee Insurance Detail Start --------------------
	
	if exists (SELECT 1  from T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id and Emp_Id = @Rejoin_EmpID)
	BEGIN
			DECLARE @ROW_INSU AS NUMERIC
			select @ROW_INSU = Isnull(max(Emp_Ins_Tran_ID),0)  From T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK)
			
			INSERT INTO T0090_EMP_INSURANCE_DETAIL (Emp_Ins_Tran_ID,Cmp_ID,Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date,Emp_Dependent_ID) 
			SELECT  @ROW_INSU + ROW_NUMBER() over (ORDER BY Emp_Ins_Tran_ID) as Emp_Ins_Tran_ID,@cmp_Id, @Emp_Id,Ins_Tran_ID,Ins_Cmp_name,Ins_Policy_No,Ins_Taken_Date,Ins_Due_Date,Ins_Exp_Date,Ins_Amount,Ins_Anual_Amt,Login_ID,Monthly_Premium,Deduct_From_Salary,Sal_Effective_Date,Emp_Dependent_ID
			from T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id and Emp_Id = @Rejoin_EmpID
	END
	----------- Employee Insurance Detail End --------------------
	
	
	---------- Employee Medical Checkup Detail Start  --------------
	if exists (SELECT 1 from T0090_Emp_Medical_Checkup WITH (NOLOCK) where cmp_Id =@Cmp_id AND Emp_Id = @Rejoin_EmpId)
	BEGIN
			DECLARE @ROW_MEDICAL AS NUMERIC
			select @ROW_MEDICAL = Isnull(max(Tran_ID),0)  From T0090_Emp_Medical_Checkup WITH (NOLOCK)
			
			Insert into dbo.T0090_EMP_Medical_Checkup(Tran_ID,Cmp_ID,Emp_ID,Medical_ID,For_Date,Description)  
			SELECT @ROW_MEDICAL + ROW_NUMBER() over (ORDER BY Tran_Id) as Tran_ID,@Cmp_id,@Emp_Id,Medical_ID,For_Date,Description 
			from T0090_Emp_Medical_Checkup WITH (NOLOCK) where cmp_Id =@Cmp_id AND Emp_Id = @Rejoin_EmpId
	END	
	---------- Employee Medical Checkup Detail End  --------------
	
	
	-------- Customized Filed  Start  -----------------------------
	IF exists ( SELECT 1 from T0082_Emp_Column WITH (NOLOCK) WHERE cmp_Id= @Cmp_id AND Emp_Id = @Rejoin_EmpId)
	BEGIN	
			
			insert into t0082_emp_Column (mst_Tran_Id,cmp_Id,Emp_Id,Value,sys_Date)
			SELECT mst_Tran_Id,@cmp_id,@Emp_id,Value,GETDATE()
			from T0082_Emp_Column WITH (NOLOCK) WHERE cmp_Id= @Cmp_id AND Emp_Id = @Rejoin_EmpId
		
	END
	-------- Customized Filed  End  -----------------------------
END


