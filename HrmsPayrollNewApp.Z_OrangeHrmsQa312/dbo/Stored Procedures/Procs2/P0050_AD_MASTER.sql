---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0050_AD_MASTER]    
    @AD_ID   numeric output    
   ,@CMP_ID   numeric    
   ,@AD_NAME  varchar(50)    
   ,@AD_SORT_NAME varchar(10)    
   ,@AD_LEVEL  numeric(18,0)    
   ,@AD_FLAG  char(1)    
   ,@AD_CALCULATE_ON varchar(30)    
   ,@AD_MODE   VARCHAR(10)      
   ,@AD_PERCENTAGE   numeric(18,5)     -- Changed by Gadriwala Muslim 19032015
   ,@AD_AMOUNT       numeric(22,3)
   ,@AD_ACTIVE       numeric(1,0)    
   ,@AD_MAX_LIMIT    numeric(18,0)    
   ,@AD_DEF_ID       numeric(18,0)    
   ,@AD_NOT_EFFECT_ON_PT numeric(1)    
   ,@AD_NOT_EFFECT_SALARY numeric(1)    
   ,@AD_EFFECT_ON_CTC numeric(1,0)    
   ,@AD_EFFECT_ON_OT  numeric(1)   
   ,@AD_EFFECT_ON_EXTRA_DAY numeric(1)    
   ,@tran_type   varchar(1)    
   ,@AD_RPT_DEF_ID  tinyint    
   ,@AD_IT_DEF_ID  tinyint    
   ,@AD_EFFECT_MONTH VARCHAR(100)  
   ,@LEAVE_TYPE VARCHAR(10)  
   ,@AD_CAL_TYPE varchar(20)   --Change by Ripal 16July2014
   ,@AD_EFFECT_FROM varchar(20) 
   ,@Constraint varchar(500) 
   ,@Effect_Net_Salary numeric(1,0) 
   ,@Effect_Net_TDS numeric(1,0)
   ,@AD_NOT_EFFECT_ON_LWP numeric(1,0) 
   ,@AD_PART_OF_CTC tinyint = 0
   ,@For_FnF tinyint = 0
   ,@Not_effect_on_Monthly_ctc tinyint = 0
   ,@Is_Yearly tinyint = 0
   ,@Not_effect_on_Basic_Calculation tinyint = 0
   ,@User_Id numeric(18,0) = 0
   ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012
   ,@AD_EFFECT_ON_BONUS tinyint = 0	--Ankit 11042013
   ,@AD_EFFECT_ON_LEAVE tinyint = 0	--Ankit 11042013
   ,@GradeXML XML = ''
   ,@AD_Formula  nvarchar(max) = ''
   ,@Is_Attach_Man tinyint  =0 ,
    @Is_AutoPaid	  tinyint = 0,	
    @Is_Display_Balance tinyint =0,
    @Allowance_type varchar(10),
    @Non_Taxable_Limit decimal =0,    
    @Taxable_Limt decimal =0,
    @Is_CF tinyint =0,
    @Num_App_Block as int =0,
    @Negative_Balance tinyint =0,
    @LTA_Leave_App_Limit numeric(18,2) = 0 ,--Ripal 16Jan2014
    @No_OF_Month  numeric(18,1) = 0, --Added By Gadriwala Muslim 02042014
    @Display_In_salary AS INTEGER = 0,
    @Add_in_sal_amt as tinyint = 0, -- Added By Ali 28042014	
	@AD_Formula_Eligible as nvarchar(MAX) = '',
	@AD_Effect_On_Short_Fall as numeric(1),
	@Is_Optional tinyint = 0,
	@AD_Code as varchar(50) = '', -- Added By Ripal 13Jun2014
	@Monthly_Limit as int = 0, --Added by Ripal 06Nov2014
	@DefineReimExpenseLimit as tinyint = 0, --Added by Ripal 08Nov2014
	@Effect_In_NightHalt as numeric(1)=0 --Added by sumit 19122014
	,@Effect_Gate_Pass as tinyint=0, --- Added by Gadriwala Muslim 06012015
	@Effect_On_ESIC as tinyint=0, --Added by Sumit 27052015
	@Cal_on_Imported as tinyint=0 --Added by Sumit 27052015
	,@SRXML XML = ''
	,@Auto_Ded_TDS as tinyint=0 ----Added by Sumit 16072015
	,@Reim_Guideline As Varchar(Max) = ''		--Added by Nimesh 12-Aug-2015
	,@Is_Claim_Base as tinyint =1 --Added by Hardik 22/08/2015
	,@HideAutoCreditAmt as tinyint =0 --Added by Sumit 16032016
	,@AD_Rounding as tinyint =0 --Added by Sumit on 05072016
	,@Hide_In_Reports as tinyint = 0  --Added by Jaina 09-09-2016
	,@Show_In_Pay_Slip as tinyint =0 --Added by Jaina 21-02-2018
	,@Quarterly_Reim as tinyint =0 --Added by Nilesh 23-08-2018
	,@Claim_ID  as Numeric(18,0) = 0  --Added by Jaina  27-10-2020
	,@IsBonusCaldays as int =0 --Added by ronakk 04012023
	,@BonusDays as int =0 --Added by ronakk 04012023
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as  varchar(max)
Declare @String as varchar(max)
set @String=''
set @OldValue =''

-- Added by Hardik 30/12/2020 for Manubhai Client
Declare @Auto_Insert_to_IT_Form_Design tinyint 
Declare @Row_ID int
DECLARE @Fin_year VARCHAR(9)
DECLARE @Form_Id INT
SELECT @Form_Id = Form_Id FROM T0040_Form_Master WHERE Cmp_ID = @Cmp_ID
SELECT @Fin_year = [DBO].[F_GET_FINANCIAL_YEAR] (Getdate())
SET @Auto_Insert_to_IT_Form_Design = 1


--Add By Paras 19-10-2012
--declare @OldValue as  varchar(max)
--declare @OldAD_NAME as varchar(50)
--declare @OldAD_SORT_NAME as varchar(10)
--declare @OldAD_LEVEL  as varchar(20)
--declare @OldAD_FLAG as varchar(1)
--declare @OldAD_CALCULATE_ON  as varchar(10)
--declare @OldAD_MODE as  varchar(18)
--declare @OldAD_PERCENTAGE as 	varchar(15)
--declare @OldAD_AMOUNT  as 	Varchar(25)
--declare @OldAD_ACTIVE  as varchar(2) 
--declare @OldAD_MAX_LIMIT as varchar(18)
--declare @OldAD_NOT_EFFECT_ON_PT as varchar(2)
--declare @OldAD_NOT_EFFECT_SALARY  as varchar(2)
--declare @OldAD_EFFECT_ON_CTC as  varchar(1)
--declare @OldAD_EFFECT_ON_OT as 	varchar(1)
--declare @OldAD_EFFECT_ON_EXTRA_DAY   as Varchar(2)
--declare @OldAD_EFFECT_MONTH  as varchar(100)
--declare @OldLEAVE_TYPE  as varchar(10)
--declare @OldAD_CAL_TYPE  as varchar(20)  --Added By Ripal 16July2014
--declare @OldAD_EFFECT_FROM  as varchar(20)
--declare @OldConstraint  as varchar(500)
--declare @OldEffect_Net_Salary  as varchar(1)
--declare @OldEffect_Net_TDS  as varchar(1)
--declare @OldAD_NOT_EFFECT_ON_LWP  as varchar(1)
--declare @OldAD_PART_OF_CTC  as varchar(4)
--declare @OldFor_FnF  as varchar(1)
--declare @OldNot_effect_on_Monthly_ctc  as varchar(1)
--declare @OldIs_Yearly  as varchar(1)
--declare @OldNot_effect_on_Basic_Calculation  as varchar(1) 
--declare @OldAD_EFFECT_ON_BONUS  as varchar(1) 
--declare @OldAD_EFFECT_ON_LEAVE  as varchar(1) 

--declare @Old_Is_Attach_Man  as varchar(10) 
--declare @Old_Is_AutoPaid  as varchar(10) 
--declare @Old_Is_Display_Balanc  as varchar(10) 
--declare @Old_Allowance_type  as varchar(10) 
--Declare @OldLTA_Leave_App_Limit as numeric(18,2) --Ripal 16Jan2014
--Declare @OldNo_OF_Month as varchar(10)  -- Added By Gadriwala Muslim 02042014
--declare @Old_Is_Optional as tinyint
--Declare @Old_AD_Code as varchar(50)	--Added By Ripal 13Jun2014
--Declare @Old_Monthly_Limit as int --Added By Ripal 06Nov2014
--Declare @OldDefineReimExpenseLimit as tinyint  --Added By Ripal 08Nov2014
--declare @OldEffectNightHalt as numeric(1)
--declare @OldEffectGatePass as tinyint -- Added by Gadriwala Muslim 06012015
--declare @OldEffectESIC as tinyint
--declare @OldCal_on_Imported as tinyint --Added by Sumit 27052015
--declare @OldAutoDedTDS as tinyint --Added by Sumit 10072015


--set @OldEffectGatePass = 0
--set @Old_AD_Code = ''

--set @Old_Is_Attach_Man =''
--set @Old_Is_Optional = 0
--set @Old_Is_AutoPaid =''
--set @Old_Is_Display_Balanc =''
-- set @Old_Allowance_type =''
--set @OldAD_NAME = ''
--set @OldAD_SORT_NAME = ''
--set @OldAD_LEVEL  = ''
--set @OldAD_FLAG = ''
--set @OldAD_CALCULATE_ON  = ''
--set @OldAD_MODE =  ''
--set @OldAD_PERCENTAGE = ''
--set @OldAD_AMOUNT  = 	''
--set @OldAD_ACTIVE  = '' 
--set @OldAD_MAX_LIMIT = ''

--set @OldAD_NOT_EFFECT_ON_PT = ''
--set @OldAD_NOT_EFFECT_SALARY  = ''
--set @OldAD_EFFECT_ON_CTC =  ''
--set @OldAD_EFFECT_ON_OT = ''
--set @OldAD_EFFECT_ON_EXTRA_DAY   = ''
--set @OldAD_EFFECT_MONTH  = ''
--set @OldLEAVE_TYPE  =''
--set @OldAD_CAL_TYPE  = ''
--set @OldAD_EFFECT_FROM  =''
--set @OldConstraint  = ''
--set @OldEffect_Net_Salary  = ''
--set @OldEffect_Net_TDS  = ''
--set @OldAD_NOT_EFFECT_ON_LWP  = ''
--set @OldAD_PART_OF_CTC  = ''
--set @OldFor_FnF  = ''
--set @OldNot_effect_on_Monthly_ctc  = ''
--set @OldIs_Yearly  = ''
--set @OldNot_effect_on_Basic_Calculation  = ''
--set @OldAD_EFFECT_ON_BONUS  = ''
--set @OldAD_EFFECT_ON_LEAVE  = ''
--set @OldLTA_Leave_App_Limit = 0 --Ripal 16Jan2014
--set @OldNo_OF_Month = 0
--set @OldEffectESIC = 0
--set @OldCal_on_Imported=0 --Sumit 27052015
--set @OldAutoDedTDS=0 --Sumit 16072015
 ----- 

  if @AD_CAL_TYPE = 'select'   
 set @AD_CAL_TYPE=null  
  if @AD_CALCULATE_ON <> 'Leave Senario'   
 set @LEAVE_TYPE = null 
  if @AD_CALCULATE_ON <> 'Bonus'
 set @AD_EFFECT_FROM=null
 
 --if (@AD_Rounding=0)
	--Begin
	--	set @AD_Rounding=null;
	--End --Added by Sumit on 05072016
		
  If @tran_type  = 'I'     
  Begin    
    If Exists(select AD_ID From T0050_AD_MASTER WITH (NOLOCK)  Where cmp_ID = @Cmp_ID and (upper(AD_NAME) = upper(@AD_NAME) or UPPER(AD_SORT_NAME) = UPPER(@AD_SORT_NAME)))    -- Modified by Mitesh 04/08/2011 for different collation db.
     Begin    
		  set @AD_ID = 0    
		  Return     
		end    
   
 if @Is_Optional = 1
	   Begin
		   if exists(select Ad_ID from T0050_Ad_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Allowance_type = @Allowance_type 
								and UPPER(AD_Code) = UPPER(@AD_Code))
			Begin
				Set @AD_ID = 0
				Return
			End
	   End
  
    select @AD_ID = Isnull(max(AD_ID),0) + 1 From T0050_AD_MASTER WITH (NOLOCK)  
    
   
  --Change by ronakk 04012023
 
    INSERT INTO T0050_AD_MASTER    
          (AD_ID, CMP_ID, AD_NAME, AD_SORT_NAME, AD_LEVEL, AD_FLAG, AD_CALCULATE_ON, AD_MODE, AD_PERCENTAGE, AD_AMOUNT, 
          AD_ACTIVE,     
          AD_MAX_LIMIT, AD_DEF_ID,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,AD_EFFECT_ON_EXTRA_DAY,AD_EFFECT_ON_SHORT_FALL,    
          AD_RPT_DEF_ID,AD_IT_DEF_ID,AD_EFFECT_ON_CTC,AD_EFFECT_MONTH,LEAVE_TYPE,AD_CAL_TYPE,AD_EFFECT_FROM,Effect_Net_Salary,
          Ad_Effect_On_TDS,AD_NOT_EFFECT_ON_LWP,AD_PART_OF_CTC,FOR_FNF,Not_effect_on_Monthly_ctc,Is_Yearly,
          Not_Effect_on_Basic_Calculation,AD_EFFECT_ON_BONUS,AD_EFFECT_ON_LEAVE,
          Attached_Mandatory,Auto_Paid,Display_Balance,Allowance_Type,Negative_Balance,LTA_Leave_App_Limit,No_Of_Month, Display_In_salary,Add_in_sal_amt,
          Is_optional,AD_Code,Monthly_Limit,DefineReimExpenseLimit,Ad_Effect_on_Nighthalt,Ad_Effect_on_Gatepass,Ad_Effect_On_Esic,Is_Calculated_On_Imported_Value,Auto_Ded_TDS,
          Reim_Guideline,Is_Claim_Base,Not_display_auto_credit_amount_IT,IS_ROUNDING,Hide_In_Reports,Show_In_Pay_Slip,IS_Quarterly_Reim,Claim_ID
		  ,isBonusCalDays,BonusDays)    -- Added By Ali 28042014
    VALUES         
		 (@AD_ID, @CMP_ID, @AD_NAME, @AD_SORT_NAME, @AD_LEVEL, @AD_FLAG, @AD_CALCULATE_ON, @AD_MODE, @AD_PERCENTAGE, @AD_AMOUNT, @AD_ACTIVE,     
          @AD_MAX_LIMIT, @AD_DEF_ID,@AD_NOT_EFFECT_ON_PT,@AD_NOT_EFFECT_SALARY,@AD_EFFECT_ON_OT,@AD_EFFECT_ON_EXTRA_DAY,@AD_Effect_On_Short_Fall,
          @AD_RPT_DEF_ID,@AD_IT_DEF_ID,@AD_EFFECT_ON_CTC,@AD_EFFECT_MONTH,@LEAVE_TYPE,@AD_CAL_TYPE,@AD_EFFECT_FROM,@Effect_Net_Salary,
          @Effect_Net_TDS,@AD_NOT_EFFECT_ON_LWP,@AD_PART_OF_CTC,@For_FnF,@Not_effect_on_Monthly_ctc,@Is_Yearly,
          @Not_effect_on_Basic_Calculation,@AD_EFFECT_ON_BONUS,@AD_EFFECT_ON_LEAVE,@Is_Attach_Man,
          @Is_AutoPaid,@Is_Display_Balance,@Allowance_type,@Negative_Balance,@LTA_Leave_App_Limit,@No_OF_Month,@Display_In_salary,
          @Add_in_sal_amt,@Is_Optional,@AD_Code,@Monthly_Limit,@DefineReimExpenseLimit,@Effect_In_NightHalt,@Effect_Gate_Pass,@Effect_On_ESIC,@Cal_on_Imported,@Auto_Ded_TDS,
          @Reim_Guideline,@Is_Claim_Base,@HideAutoCreditAmt,@AD_Rounding,@Hide_In_Reports,@Show_In_Pay_Slip,@Quarterly_Reim,@Claim_ID
		  ,@IsBonusCaldays,@BonusDays)    -- Added By Ali 28042014  --Change by Jaina 09-09-2016
                   
			
            Select @Ad_ID = AD_ID  from T0050_AD_MASTER WITH (NOLOCK) Where Upper(AD_NAME) = Upper(@AD_NAME) and Cmp_ID = @Cmp_ID
					
					exec P9999_Audit_get @table = 'T0050_AD_MASTER' ,@key_column='AD_ID',@key_Values=@AD_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
                   
                          
           --Add By Paras 19-10-2012
        --set @OldValue = 'New Value' + '#'+ 'AD NAME :' +ISNULL( @AD_NAME,'') + '#' + 'AD SORT NAME :' + ISNULL( @AD_SORT_NAME,'') + '#' + 'AD LEVEL :' + CAST(ISNULL(@AD_LEVEL,0) AS VARCHAR(20)) + '#' + 'AD FLAG :' + ISNULL( @AD_FLAG,'') + '#' + 'AD CALCULATE ON :' +ISNULL( @AD_CALCULATE_ON,'') + ' #'+ 'AD MODE :' +ISNULL(@AD_MODE,'') + ' #'+ 'AD PERCENTAGE :' +CAST(ISNULL(@AD_PERCENTAGE,0)as varchar(15)) + ' #'+ 'AD AMOUNT :' + CAST(ISNULL(@AD_AMOUNT,0)AS VARCHAR(25))  + ' #'
        --                              + '#'+ 'AD ACTIVE:' +CAST(ISNULL( @AD_ACTIVE,0)as varchar(1)) + '#' + 'AD MAX LIMIT :' +CAST( ISNULL(@AD_MAX_LIMIT,0)as varchar(20)) + '#' + 'AD NOT EFFECT ON PT :' + CAST(ISNULL(@AD_NOT_EFFECT_ON_PT,0) AS VARCHAR(2)) + '#' + 'AD NOT EFFECT SALARY :' +CAST( ISNULL( @AD_NOT_EFFECT_SALARY,0)AS VARCHAR(2)) + '#' + 'AD EFFECT ON CTC :' +CAST(ISNULL( @AD_EFFECT_ON_CTC,0)AS VARCHAR(2)) + ' #'+ 'AD EFFECT ON OT :' +CAST(ISNULL(@AD_EFFECT_ON_OT,0)AS VARCHAR(1)) + ' #'+ 'AD EFFECT ON EXTRA DAY :' +CAST(ISNULL( @AD_EFFECT_ON_EXTRA_DAY,0)as varchar(1)) + ' #'+ 'AD EFFECT MONTH  :' + ISNULL(@AD_EFFECT_MONTH ,'')  + ' #'
        --                              + '#'+ 'LEAVE TYPE :' +ISNULL(@LEAVE_TYPE,'') + '#' + 'AD EFFECT FROM:' + ISNULL(@AD_EFFECT_FROM,'') + '#' + 'Constraint :' + ISNULL(@Constraint,'')  + '#' + 'Effect Net Salary :' +CAST( ISNULL( @Effect_Net_Salary,0)AS VARCHAR(1)) + '#' + 'Effect Net TDS :' +CAST(ISNULL(@Effect_Net_TDS,0)AS VARCHAR(2)) + ' #'+ 'AD NOT EFFECT ON LWP :' +CAST(ISNULL(@AD_NOT_EFFECT_ON_LWP,0)AS VARCHAR(2)) + ' #'+ 'AD PART OF CTC:' +CAST(ISNULL(@AD_PART_OF_CTC,0)AS VARCHAR(1)) + ' #'+ 'For FnF :' + CAST(ISNULL(@For_FnF,0)AS VARCHAR(1))  + ' #'
        --                              + ' #'+ 'Not effect on Monthly ctc :' +CAST(ISNULL(@Not_effect_on_Monthly_ctc,0)AS VARCHAR(1)) + ' #'+ 'Is Yearly:' +CAST(ISNULL(@Is_Yearly,0)AS VARCHAR(1)) + ' #'+ 'Not effect on Basic Calculation :' + CAST(ISNULL(@Not_effect_on_Basic_Calculation,0)AS VARCHAR(1))  + ' #' 
        --                              + 'AD EFFECT ON LEAVE :' + CAST(ISNULL(@AD_EFFECT_ON_LEAVE,0)AS VARCHAR(1))  + ' #'+ 
        --                              'AD EFFECT ON BONUS :' + CAST(ISNULL(@AD_EFFECT_ON_BONUS,0)AS VARCHAR(1))  + ' #'
        --                              +' #'+ 'Attached_Mandatory :' + CAST(ISNULL(@Is_Attach_Man,0)AS VARCHAR(1))  
        --                              +' #'+ 'Auto_Paid :' + CAST(ISNULL(@Is_AutoPaid,0)AS VARCHAR(10))  
        --                              +' #'+ 'Display_Balance :' + CAST(ISNULL(@Is_Display_Balance,0)AS VARCHAR(10))  
        --                              +' #'+ 'Allowance_Type :' + CAST(ISNULL(@Allowance_type,0)AS VARCHAR(10))  
        --                              +' #'+ 'LTA Leave App. Limit :' + CAST(ISNULL(@LTA_Leave_App_Limit,0)AS VARCHAR(10))
        --                              +' #'+ 'Number of Month :' + CAST(ISNULL(@No_OF_Month,0)AS VARCHAR(10))
        --                              +' #'+ 'Display_In_salary :' + CAST(ISNULL(@Display_In_salary,0)AS VARCHAR(10))
        --                              +' #'+ 'Optional :' + CAST(ISNULL(@Is_Optional,0)AS VARCHAR(10))
        --                              +' #'+ 'Code :' + Cast(ISNULL(@AD_Code,'') as varchar(50))
        --                              +' #'+ 'Monthly Limit :' + Cast(isnull(@Monthly_Limit,'0') as varchar(50))
        --                              +' #'+ 'DefineReimExpenseLimit :' + cast(isnull(@DefineReimExpenseLimit,'0') as varchar(50) )
        --                              +' #'+ 'EffectOnNightHalt :' + cast(isnull(@Effect_In_NightHalt,'0') as varchar(50) ) --Added by sumit 19122014
        --                              +' #'+ 'EffectOnGatePass :' + cast(isnull(@Effect_Gate_Pass,'0') as varchar(50) ) --Added by Gadriwala 06012015
        --                              +' #'+ 'EffectOnESIC :' + cast(isnull(@Effect_On_ESIC,'0') as varchar(20) ) --Added by Sumit 27052015
        --                              +' #'+ 'Cal_on_Imported :' + cast(isnull(@Cal_on_Imported,'0') as varchar(20) ) --Added by Sumit 27052015
        --                              +' #'+ 'Auto_Ded_TDS :' + cast(isnull(@Auto_Ded_TDS,'0') as varchar(20) ) --Added by Sumit 10072015
        --                              +' #'+ 'Reim_Guideline :' + ISNULL(@Reim_Guideline,'')  --Added by Sumit 10072015
        --                              +' #'+ 'Is_Claim_Base :' + Cast(ISNULL(@Is_Claim_Base,1) as varchar)  --Added by Hardik 22/08/2015
        --                              +' #'+ 'Hide_Auto_Credit_Amt :' + Cast(ISNULL(@HideAutoCreditAmt,0) as varchar)  --Added by Sumit 17032016
                                      
                   ----
                   
		EXEC P0120_GRADEWISE_ALLOWANCE  0,@CMP_ID,@AD_ID,@Tran_Type,@Constraint,@AD_LEVEL,@GradeXML                            				
		
		EXEC P0190_Seniority_Award_Slab  0,@CMP_ID,@AD_ID,@Tran_Type,@SRXML -- Added by rohit on 02062015
		
		IF @AD_Formula <> ''
			BEGIN
				EXEC P0040_AD_Formula_Setting 0,@CMP_ID,@AD_ID,@AD_Formula,@Tran_Type   
			END

		IF @AD_Formula_Eligible <> ''
			BEGIN
				
				EXEC P0040_AD_Formula_Eligible_Setting 0,@CMP_ID,@AD_ID,@AD_Formula_Eligible,@Tran_Type   
			END
		
		exec P0040_ReimClaim_Setting 0,@CMP_ID,@AD_ID,@Non_Taxable_Limit,@Taxable_Limt,@Is_CF,@Num_App_Block,@Tran_Type
		
		---ADDED BY HARDIK 31/12/2020 FOR MANUBHAI CLIENT
		If @Auto_Insert_to_IT_Form_Design = 1 And @AD_FLAG = 'I'
			BEGIN
				If Not Exists (Select 1 From T0100_IT_FORM_DESIGN WITH (NOLOCK) Where Cmp_Id = @CMP_ID And (AD_Id = @AD_ID OR Rimb_ID = @AD_ID) AND FINANCIAL_YEAR = @FIN_YEAR)
					BEGIN
						SELECT @ROW_ID = ISNULL(MAX(ROW_ID),0) + 1 
						FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
						WHERE CMP_ID = @CMP_ID AND ROW_ID < 101 AND FINANCIAL_YEAR = @FIN_YEAR

						IF ISNULL(@Allowance_type,'A') = 'R'
							EXEC P0100_IT_FORM_DESIGN 
								@Tran_ID = 0, @Cmp_ID=@Cmp_ID, @Format_Name = '', @Row_ID = @Row_ID, @Field_Name = @AD_NAME, @Field_Type= 0,
								@AD_ID=NULL ,@Rimb_ID=@AD_ID, @Default_Def_Id = 0, @Is_Total= 0,@From_Row_ID= 0,@To_Row_ID= 0, @Multiple_Row_ID='', 
								@Is_Exempted = 0, @Max_Limit = 0,@Max_Limit_Compare_Row_ID= 0,@Max_Limit_Compare_Type= 0, @Is_Proof_Req=0, @Login_ID=@User_Id,
								@IT_ID=0, @Tran_Type='I',@Form_ID=@Form_Id, @Col_No=0, @Is_Show=0, @Concate_Space=0, @Is_Salary_Comp=0, @Exem_Againt_Row_ID=0, 
								@Financial_Year=@Fin_year, @Show_In_SalarySlip=0, @Display_Name_For_Salaryslip = @AD_NAME,
								@24Q_Column=0, @Net_Income_Range=0, @Surcharge_Percentage =0,@TotalFormula = '',@User_Id= 0, @IP_Address= ''
						ELSE
							EXEC P0100_IT_FORM_DESIGN 
								@Tran_ID = 0, @Cmp_ID=@Cmp_ID, @Format_Name = '', @Row_ID = @Row_ID, @Field_Name = @AD_NAME, @Field_Type= 0,
								@AD_ID=@AD_ID ,@Rimb_ID=NULL, @Default_Def_Id = 0, @Is_Total= 0,@From_Row_ID= 0,@To_Row_ID= 0, @Multiple_Row_ID='', 
								@Is_Exempted = 0, @Max_Limit = 0,@Max_Limit_Compare_Row_ID= 0,@Max_Limit_Compare_Type= 0, @Is_Proof_Req=0, @Login_ID=@User_Id,
								@IT_ID=0, @Tran_Type='I',@Form_ID=@Form_Id, @Col_No=0, @Is_Show=0, @Concate_Space=0, @Is_Salary_Comp=0, @Exem_Againt_Row_ID=0, 
								@Financial_Year=@Fin_year, @Show_In_SalarySlip=0, @Display_Name_For_Salaryslip = @AD_NAME,
								@24Q_Column=0, @Net_Income_Range=0, @Surcharge_Percentage =0,@TotalFormula = '',@User_Id= 0, @IP_Address= ''

							
					END
			END

  End    
 Else if @Tran_Type = 'U'     
  begin    
      
    If Exists(select AD_ID From T0050_AD_MASTER WITH (NOLOCK) Where cmp_ID = @Cmp_ID and AD_ID <> @AD_ID and 
				(upper(AD_NAME) = upper(@AD_NAME) or UPPER(AD_SORT_NAME) = UPPER(@AD_SORT_NAME)) )    -- Modified by Mitesh 04/08/2011 for different collation db.
     Begin    
     
      set @AD_ID = 0  
      
      Return        
     end
     
   if @Is_Optional = 1
	   Begin
		   if exists(select Ad_ID from T0050_Ad_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Allowance_type = @Allowance_type 
								and UPPER(AD_Code) = UPPER(@AD_Code) and AD_ID <> @AD_ID)
			Begin
				Set @AD_ID = 0
				Return
			End
	   End    
     
   DELETE FROM  T0060_EFFECT_AD_MASTER WHERE AD_ID =@AD_ID    
   

         ---Add By Paras 20-10-2012
  --       select @OldAD_NAME  =ISNULL(AD_NAME,'') ,@OldAD_SORT_NAME  =ISNULL(AD_SORT_NAME,''),@OldAD_LEVEL  = cast(isnull(AD_LEVEL,0)as varchar(20)),@OldAD_FLAG  =isnull(AD_FLAG,''),@OldAD_CALCULATE_ON =isnull(AD_CALCULATE_ON,''),@OldAD_MODE  =isnull(AD_MODE,''),@OldAD_PERCENTAGE  =CAST(isnull(AD_PERCENTAGE,0)as varchar(12)),@OldAD_AMOUNT  =CAST(isnull(AD_AMOUNT ,0)as VArchar(22)),
  --              @OldAD_ACTIVE  =CAST(ISNULL(AD_ACTIVE,0)as varchar(10)) ,@OldAD_MAX_LIMIT  =CAST(ISNULL(AD_MAX_LIMIT,0)as varchar(20)),@OldAD_NOT_EFFECT_ON_PT  =CAST(isnull(AD_NOT_EFFECT_ON_PT,0)as varchar(1)),@OldAD_NOT_EFFECT_SALARY  =CAST(isnull(AD_NOT_EFFECT_SALARY,0)as varchar(1)) ,@OldAD_EFFECT_ON_CTC =CAST(isnull(AD_EFFECT_ON_CTC,0)as varchar(2)),@OldAD_EFFECT_ON_OT  =CAST(isnull(AD_EFFECT_ON_OT,0)as varchar(1)),@OldAD_EFFECT_ON_EXTRA_DAY  =CAST(isnull(AD_EFFECT_ON_EXTRA_DAY,0)AS VARCHAR(1)),@OldAD_EFFECT_MONTH  =isnull(AD_EFFECT_MONTH ,''),
  --              @OldLEAVE_TYPE  =ISNULL(LEAVE_TYPE,'') ,@OldAD_CAL_TYPE  =ISNULL(AD_CAL_TYPE,''),@OldAD_EFFECT_FROM  =isnull(AD_EFFECT_FROM,0),@OldEffect_Net_Salary  =CAST(isnull(Effect_Net_Salary,0)as varchar(2)),@OldEffect_Net_TDS =CAST(isnull(AD_Effect_On_TDS,0)as varchar(1)),@OldAD_NOT_EFFECT_ON_LWP  =CAST(isnull(AD_NOT_EFFECT_ON_LWP,0)as varchar(1)),@OldAD_PART_OF_CTC  =CAST(isnull(AD_PART_OF_CTC,'')as varchar(1)),@OldFor_FnF  =CAST(isnull(For_FnF ,0)as varchar(1)),
  --              @OldNot_effect_on_Monthly_ctc =CAST(ISNULL(Not_effect_on_Monthly_ctc,0)as varchar(1)) ,@OldIs_Yearly  =CAST(ISNULL(@Is_Yearly,0)as varchar(2)),@OldNot_effect_on_Basic_Calculation  =CAST(isnull(Not_effect_on_Basic_Calculation,0)as varchar(2)),@OldAD_EFFECT_ON_BONUS  =CAST(isnull(AD_EFFECT_ON_BONUS,0)as varchar(2)),@OldAD_EFFECT_ON_LEAVE  =CAST(isnull(AD_EFFECT_ON_LEAVE,0)as varchar(2))                    
  --             ,@Old_Is_Attach_Man   = Attached_Mandatory 
		--	   ,@Old_Is_AutoPaid   = Auto_Paid
		--	   ,@Old_Is_Display_Balanc  = Display_Balance 
		--	   ,@Old_Allowance_type  =Allowance_Type   
		--	   ,@OldLTA_Leave_App_Limit = LTA_Leave_App_Limit --Ripal 16Jan2014
		--	   ,@OldNo_OF_Month = No_OF_Month
		--	   ,@Old_AD_Code = AD_Code --Ripal 13Jun2014
		--	   ,@Old_Monthly_Limit = Monthly_Limit -- Ripal 06Nov2014
		--	   ,@OldDefineReimExpenseLimit = DefineReimExpenseLimit --Ripal 08Nov2014
		--	   ,@OldEffectNightHalt=Ad_Effect_on_Nighthalt
		--	   ,@OldEffectGatePass=Ad_Effect_on_gatepass --Gadriwala Muslim 06012015 
		--	   ,@OldEffectESIC=Ad_Effect_On_Esic
		--	   ,@OldCal_on_Imported=Is_Calculated_On_Imported_Value --Added by Sumit 27052015
		--	   ,@OldAutoDedTDS=Auto_Ded_TDS --Added by Sumit 16072015			   
		--From dbo.T0050_AD_MASTER Where Cmp_ID = @Cmp_ID and Ad_Id = @AD_ID
	
				exec P9999_Audit_get @table='T0050_AD_MASTER' ,@key_column='AD_ID',@key_Values=@AD_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		
    
         -----------       
    
   UPDATE    T0050_AD_MASTER    
   SET       CMP_ID = @CMP_ID, AD_NAME = @AD_NAME, AD_SORT_NAME = @AD_SORT_NAME, AD_LEVEL = @AD_LEVEL, AD_FLAG = @AD_FLAG, AD_CALCULATE_ON = @AD_CALCULATE_ON, AD_MODE = @AD_MODE, AD_PERCENTAGE = @AD_PERCENTAGE, AD_AMOUNT = @AD_AMOUNT,     
                      AD_ACTIVE = @AD_ACTIVE, AD_MAX_LIMIT = @AD_MAX_LIMIT, AD_DEF_ID = @AD_DEF_ID    
                      ,AD_NOT_EFFECT_ON_PT=@AD_NOT_EFFECT_ON_PT    
                      ,AD_NOT_EFFECT_SALARY=@AD_NOT_EFFECT_SALARY    
                      ,AD_EFFECT_ON_OT=@AD_EFFECT_ON_OT    
                      ,AD_EFFECT_ON_EXTRA_DAY=@AD_EFFECT_ON_EXTRA_DAY    
                      ,AD_RPT_DEF_ID =@AD_RPT_DEF_ID , AD_IT_DEF_ID= @AD_IT_DEF_ID,AD_EFFECT_ON_CTC = @AD_EFFECT_ON_CTC,AD_EFFECT_MONTH=@AD_EFFECT_MONTH,LEAVE_TYPE=@LEAVE_TYPE  
                      ,AD_CAL_TYPE=@AD_CAL_TYPE
                      ,AD_EFFECT_FROM=@AD_EFFECT_FROM
					  ,Effect_Net_Salary=@Effect_Net_Salary
                      ,AD_Effect_On_TDS =@Effect_Net_TDS
                      ,AD_NOT_EFFECT_ON_LWP = @AD_NOT_EFFECT_ON_LWP
                      ,AD_PART_OF_CTC = @AD_PART_OF_CTC
                      ,FOR_FNF = @For_FnF
                      ,Not_effect_on_Monthly_ctc = @Not_effect_on_Monthly_ctc
                      ,Is_Yearly = @Is_Yearly
                      ,Not_Effect_on_Basic_Calculation = @Not_effect_on_Basic_Calculation
                      ,AD_EFFECT_ON_BONUS=@AD_EFFECT_ON_BONUS
                      ,AD_EFFECT_ON_LEAVE=@AD_EFFECT_ON_LEAVE
                      , Attached_Mandatory = @Is_Attach_Man
                       ,Auto_Paid = @Is_AutoPaid
                       ,Display_Balance = @Is_Display_Balance
                       ,Allowance_Type = @Allowance_type
                       ,Negative_Balance =@Negative_Balance
                       ,LTA_Leave_App_Limit = @LTA_Leave_App_Limit  --Ripal 16Jan2014
                       ,No_OF_Month = @No_OF_Month -- Added By Gadriwala 02/04/2014
                       ,Display_In_salary =@Display_In_Salary
                       ,Add_in_sal_amt = @Add_in_sal_amt -- Added By Ali 28042014
                       ,AD_EFFECT_ON_SHORT_FALL=@AD_Effect_On_Short_Fall --added by Mukti 03062014
                       ,Is_Optional = @Is_Optional
                       ,AD_Code = @AD_Code -- Added By Ripal 13Jun2014
                       ,Monthly_Limit = @Monthly_Limit -- Added By Ripal 06Nov2014
                       ,DefineReimExpenseLimit = @DefineReimExpenseLimit --Added By Ripal 08Nov2014
                       ,Ad_Effect_on_Nighthalt=@Effect_In_NightHalt --Added by sumit 19122014
                       ,Ad_Effect_on_GatePass=@Effect_Gate_Pass --Added by Gadriwala muslim 06012015
                       ,Ad_Effect_On_Esic=@Effect_On_ESIC --Added by Sumit 26052015
                       ,Is_Calculated_On_Imported_Value=@Cal_on_Imported --Added by Sumit 27052015
                       ,Auto_Ded_TDS=@Auto_Ded_TDS --Added by Sumit 16072015
                       ,Reim_Guideline=@Reim_Guideline --Added by Nimesh 12-Aug-2015
                       ,Is_Claim_Base = @Is_Claim_Base --Added by Hardik 22/08/2015
                       ,Not_display_auto_credit_amount_IT=@HideAutoCreditAmt -- Added by Sumit 17032016
                       ,IS_ROUNDING=@AD_Rounding --Added by Sumit on 05072016
                       ,Hide_In_Reports = @Hide_In_Reports --Added By Jaina 09-09-2016
                       ,Show_In_Pay_Slip =@Show_In_Pay_Slip  --Added by Jaina 21-02-2018
					   ,IS_Quarterly_Reim = @Quarterly_Reim	  
					   ,Claim_ID = @Claim_ID  --Added by Jaina 27-10-2020
					   ,isBonusCalDays = @IsBonusCaldays -- Added by ronakk 04012023
					   ,BonusDays =@BonusDays --Added by ronakk 04012023
            Where AD_ID = @AD_ID   
            
      
            exec P9999_Audit_get @table='T0050_AD_MASTER' ,@key_column='AD_ID',@key_Values=@AD_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
            
            ---Add By Paras 19-10-2012
           -- set @OldValue = 'old Value' + + '#'+ 'AD NAME :' +ISNULL( @OldAD_NAME,'') + '#' + 'AD SORT NAME :' + ISNULL( @OldAD_SORT_NAME,'') + '#' + 'AD LEVEL :' + CAST(ISNULL(@OldAD_LEVEL,0) AS VARCHAR(20)) + '#' + 'AD FLAG :' + ISNULL( @OldAD_FLAG,'') + '#' + 'AD CALCULATE ON :' +ISNULL( @OldAD_CALCULATE_ON,'') + ' #'+ 'AD MODE :' +ISNULL(@OldAD_MODE,'') + ' #'+ 'AD PERCENTAGE :' +CAST(ISNULL(@OldAD_PERCENTAGE,0)as varchar(15)) + ' #'+ 'AD AMOUNT :' + CAST(ISNULL(@OldAD_AMOUNT,0)AS VARCHAR(25))  + ' #'
           --                           + '#'+ 'AD ACTIVE:' +CAST(ISNULL( @OldAD_ACTIVE,0)as varchar(1)) + '#' + 'AD MAX LIMIT :' +CAST( ISNULL(@OldAD_MAX_LIMIT,0)as varchar(20)) + '#' + 'AD NOT EFFECT ON PT :' + CAST(ISNULL(@OldAD_NOT_EFFECT_ON_PT,0) AS VARCHAR(2)) + '#' + 'AD NOT EFFECT SALARY :' +CAST( ISNULL( @OldAD_NOT_EFFECT_SALARY,0)AS VARCHAR(2)) + '#' + 'AD EFFECT ON CTC :' +CAST(ISNULL( @OldAD_EFFECT_ON_CTC,0)AS VARCHAR(2)) + ' #'+ 'AD EFFECT ON OT :' +CAST(ISNULL(@OldAD_EFFECT_ON_OT,0)AS VARCHAR(1)) + ' #'+ 'AD EFFECT ON EXTRA DAY :' +CAST(ISNULL( @OldAD_EFFECT_ON_EXTRA_DAY,0)as varchar(1)) + ' #'+ 'AD EFFECT MONTH  :' + ISNULL(@OldAD_EFFECT_MONTH ,'')  + ' #'
           --                           + '#'+ 'LEAVE TYPE :' +ISNULL(@OldLEAVE_TYPE,'') + '#' + 'AD EFFECT FROM:' + ISNULL(@OldAD_EFFECT_FROM,'') + '#' + 'Constraint :' + ISNULL(@OldConstraint,'')  + '#' + 'Effect Net Salary :' +CAST( ISNULL( @OldEffect_Net_Salary,0)AS VARCHAR(1)) + '#' + 'Effect Net TDS :' +CAST(ISNULL(@OldEffect_Net_TDS,0)AS VARCHAR(2)) + ' #'+ 'AD NOT EFFECT ON LWP :' +CAST(ISNULL(@OldAD_NOT_EFFECT_ON_LWP,0)AS VARCHAR(2)) + ' #'+ 'AD PART OF CTC:' +CAST(ISNULL(@OldAD_PART_OF_CTC,0)AS VARCHAR(1)) + ' #'+ 'For FnF :' + CAST(ISNULL(@OldFor_FnF,0)AS VARCHAR(1))  + ' #'
           --                           + ' #'+ 'Not effect on Monthly ctc :' +CAST(ISNULL(@OldNot_effect_on_Monthly_ctc,0)AS VARCHAR(1)) + ' #'+ 'Is Yearly:' +CAST(ISNULL(@OldIs_Yearly,0)AS VARCHAR(1)) + ' #'+ 'Not effect on Basic Calculation :' + CAST(ISNULL(@OldNot_effect_on_Basic_Calculation,0)AS VARCHAR(1))  + ' #'+ 'AD EFFECT ON BONUS :' + CAST(ISNULL(@OldAD_EFFECT_ON_BONUS,0)AS VARCHAR(1))  + ' #' + 'AD EFFECT ON LEAVE :' + CAST(ISNULL(@OldAD_EFFECT_ON_LEAVE,0)AS VARCHAR(1))  + ' #'  
                                      
           --                            +' #'+ 'Attached_Mandatory :' + CAST(ISNULL(@Old_Is_Attach_Man,0)AS VARCHAR(1))  
           --                           +' #'+ 'Auto_Paid :' + CAST(ISNULL(@Old_Is_AutoPaid,0)AS VARCHAR(10))  
           --                           +' #'+ 'Display_Balance :' + CAST(ISNULL(@Old_Is_Display_Balanc,0)AS VARCHAR(10))  
           --                           +' #'+ 'Allowance_Type :' + CAST(ISNULL(@Old_Allowance_type,0)AS VARCHAR(10))  
           --                           +' #'+ 'LTA Leave App. Limit :' + CAST(ISNULL(@OldLTA_Leave_App_Limit,0)AS VARCHAR(10))   
           --                           +' #'+ 'Number of Month :' + CAST(ISNULL(@OldNo_OF_Month,0)AS VARCHAR(10)) 
           --                           +' #'+ 'Code :' + Cast(IsNull(@Old_AD_Code,'') as varchar(50))
           --                           +' #'+ 'Monthly Limit :' + Cast(isnull(@Old_Monthly_Limit,'0') as varchar(50))
           --                           +' #'+ 'DefineReimExpenseLimit :' + cast(isnull(@OldDefineReimExpenseLimit,'0') as varchar(50))
           --                           +' #'+ 'EffectOnNightHallt :' + cast(isnull(@OldDefineReimExpenseLimit,'0') as varchar(50))
									  --+' #'+ 'EffectOnGatePass :' + cast(isnull(@OldEffectGatePass,'0') as varchar(50))		
									  --+' #'+ 'EffectESIC :' + cast(isnull(@OldEffectESIC,'0') as varchar(20))
									  --+' #'+ 'Cal_on_Imported :' + cast(isnull(@OldCal_on_Imported,'0') as varchar(20))		
									  --+' #'+ 'Auto_Ded_TDS :' + cast(isnull(@OldAutoDedTDS,'0') as varchar(20))		
           --                 + 'New Value' + '#'+ 'AD NAME :' +ISNULL( @AD_NAME,'') + '#' + 'AD SORT NAME :' + ISNULL( @AD_SORT_NAME,'') + '#' + 'AD LEVEL :' + CAST(ISNULL(@AD_LEVEL,0) AS VARCHAR(20)) + '#' + 'AD FLAG :' + ISNULL( @AD_FLAG,'') + '#' + 'AD CALCULATE ON :' +ISNULL( @AD_CALCULATE_ON,'') + ' #'+ 'AD MODE :' +ISNULL(@AD_MODE,'') + ' #'+ 'AD PERCENTAGE :' +CAST(ISNULL(@AD_PERCENTAGE,0)as varchar(15)) + ' #'+ 'AD AMOUNT :' + CAST(ISNULL(@AD_AMOUNT,0)AS VARCHAR(25))  + ' #'
           --                           + '#'+ 'AD ACTIVE:' +CAST(ISNULL( @AD_ACTIVE,0)as varchar(1)) + '#' + 'AD MAX LIMIT :' +CAST( ISNULL(@AD_MAX_LIMIT,0)as varchar(20)) + '#' + 'AD NOT EFFECT ON PT :' + CAST(ISNULL(@AD_NOT_EFFECT_ON_PT,0) AS VARCHAR(2)) + '#' + 'AD NOT EFFECT SALARY :' +CAST( ISNULL( @AD_NOT_EFFECT_SALARY,0)AS VARCHAR(2)) + '#' + 'AD EFFECT ON CTC :' +CAST(ISNULL( @AD_EFFECT_ON_CTC,0)AS VARCHAR(2)) + ' #'+ 'AD EFFECT ON OT :' +CAST(ISNULL(@AD_EFFECT_ON_OT,0)AS VARCHAR(1)) + ' #'+ 'AD EFFECT ON EXTRA DAY :' +CAST(ISNULL( @AD_EFFECT_ON_EXTRA_DAY,0)as varchar(1)) + ' #'+ 'AD EFFECT MONTH  :' + ISNULL(@AD_EFFECT_MONTH ,'')  + ' #'
           --                           + '#'+ 'LEAVE TYPE :' +ISNULL(@LEAVE_TYPE,'') + '#' + 'AD EFFECT FROM:' + ISNULL(@AD_EFFECT_FROM,'') + '#' + 'Constraint :' + ISNULL(@Constraint,'')  + '#' + 'Effect Net Salary :' +CAST( ISNULL( @Effect_Net_Salary,0)AS VARCHAR(1)) + '#' + 'Effect Net TDS :' +CAST(ISNULL(@Effect_Net_TDS,0)AS VARCHAR(2)) + ' #'+ 'AD NOT EFFECT ON LWP :' +CAST(ISNULL(@AD_NOT_EFFECT_ON_LWP,0)AS VARCHAR(2)) + ' #'+ 'AD PART OF CTC:' +CAST(ISNULL(@AD_PART_OF_CTC,0)AS VARCHAR(1)) + ' #'+ 'For FnF :' + CAST(ISNULL(@For_FnF,0)AS VARCHAR(1))  + ' #'
           --                           + ' #'+ 'Not effect on Monthly ctc :' +CAST(ISNULL(@Not_effect_on_Monthly_ctc,0)AS VARCHAR(1)) + ' #'+ 'Is Yearly:' +CAST(ISNULL(@Is_Yearly,0)AS VARCHAR(1)) + ' #'+ 'Not effect on Basic Calculation :' + CAST(ISNULL(@Not_effect_on_Basic_Calculation,0)AS VARCHAR(1))  + ' #' + 'AD EFFECT ON BONUS :' + CAST(ISNULL(@AD_EFFECT_ON_BONUS,0)AS VARCHAR(1))  + ' #' + 'AD EFFECT ON LEAVE :' + CAST(ISNULL(@AD_EFFECT_ON_LEAVE,0)AS VARCHAR(1))  + ' #'             
                                      
           --                             +' #'+ 'Attached_Mandatory :' + CAST(ISNULL(@Is_Attach_Man,0)AS VARCHAR(1))  
           --                           +' #'+ 'Auto_Paid :' + CAST(ISNULL(@Is_AutoPaid,0)AS VARCHAR(10))  
           --                           +' #'+ 'Display_Balance :' + CAST(ISNULL(@Is_Display_Balance,0)AS VARCHAR(10))  
           --                           +' #'+ 'Allowance_Type :' + CAST(ISNULL(@Allowance_type,0)AS VARCHAR(10))
           --                           +' #'+ 'LTA Leave App. Limit :' + CAST(ISNULL(@LTA_Leave_App_Limit,0)AS VARCHAR(10))   
           --                           +' #'+ 'Number of Month :' + CAST(ISNULL(@No_OF_Month,0)AS VARCHAR(10))  
           --                           +' #'+ 'Is_Optional :' + CAST(ISNULL(@Is_Optional,0)AS VARCHAR(10))
           --                           +' #'+ 'Code :' + Cast(IsNull(@AD_Code,'') as varchar(50))
           --                           +' #'+ 'Monthly Limit :' + Cast(isnull(@Monthly_Limit,'0') as varchar(50))
           --                           +' #'+ 'DefineReimExpenseLimit :' + cast(isnull(@DefineReimExpenseLimit,'0') as varchar(50))
           --                           +' #'+ 'EffectOnNightHalt :' + cast(isnull(@Effect_In_NightHalt,'0') as varchar(50)) --Added by sumit 19122014
           --                           +' #'+ 'EffectOnGatePass :' + cast(isnull(@Effect_Gate_Pass,'0') as varchar(50))
           --                           +' #'+ 'EffectESIC :' + cast(isnull(@Effect_On_ESIC,'0') as varchar(20))
           --                           +' #'+ 'Cal_on_Imported :' + cast(isnull(@Cal_on_Imported,'0') as varchar(20)) --Added by Sumit 27052015 
           --                           +' #'+ 'Auto_ded_TDS :' + cast(isnull(@Auto_Ded_TDS,'0') as varchar(20)) --Added by Sumit 10072015
                                      
          -----------
    
    EXEC P0120_GRADEWISE_ALLOWANCE  0,@CMP_ID,@AD_ID,@Tran_Type,@Constraint,@AD_LEVEL ,@GradeXML           
	  
   	EXEC P0190_Seniority_Award_Slab  0,@CMP_ID,@AD_ID,@Tran_Type,@SRXML -- Added by rohit on 02062015
   		
   	IF @AD_Formula <> ''
		BEGIN
			EXEC P0040_AD_Formula_Setting 0,@CMP_ID,@AD_ID,@AD_Formula,@Tran_Type   
		END
	Else
		Begin
			Delete From T0040_AD_Formula_Setting Where AD_Id = @AD_ID -- Added by Hardik 23/09/2014
		End

		IF @AD_Formula_Eligible <> ''
			BEGIN
				EXEC P0040_AD_Formula_Eligible_Setting 0,@CMP_ID,@AD_ID,@AD_Formula_Eligible,@Tran_Type   
			END
		Else
			Begin 
				Delete From T0040_AD_Formula_Eligible_Setting Where AD_Id = @AD_ID -- Added by Hardik 23/09/2014
			End
		
		
	exec P0040_ReimClaim_Setting 0,@CMP_ID,@AD_ID,@Non_Taxable_Limit,@Taxable_Limt,@Is_CF,@Num_App_Block,@Tran_Type	
   	
  end    
 Else if @Tran_Type = 'D'     
  begin   
  -------Add By Paras 19-10-2012 
  				exec P9999_Audit_get @table='T0050_AD_MASTER' ,@key_column='AD_ID',@key_Values=@AD_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
  
     Delete from T0040_ReimClaim_Setting where AD_ID=@AD_ID and Cmp_ID=@Cmp_ID
     --select @OldAD_NAME  =ISNULL(AD_NAME,'') ,@OldAD_SORT_NAME  =ISNULL(AD_SORT_NAME,''),@OldAD_LEVEL  = cast(isnull(AD_LEVEL,0)as varchar(20)),@OldAD_FLAG  =isnull(AD_FLAG,''),@OldAD_CALCULATE_ON =isnull(AD_CALCULATE_ON,''),@OldAD_MODE  =isnull(AD_MODE,''),@OldAD_PERCENTAGE  =CAST(isnull(AD_PERCENTAGE,0)as varchar(12)),@OldAD_AMOUNT  =CAST(isnull(AD_AMOUNT ,0)as VArchar(22)),
     --           @OldAD_ACTIVE  =CAST(ISNULL(AD_ACTIVE,0)as varchar(10)) ,@OldAD_MAX_LIMIT  =CAST(ISNULL(AD_MAX_LIMIT,0)as varchar(20)),@OldAD_NOT_EFFECT_ON_PT  =CAST(isnull(AD_NOT_EFFECT_ON_PT,0)as varchar(1)),@OldAD_NOT_EFFECT_SALARY  =CAST(isnull(AD_NOT_EFFECT_SALARY,0)as varchar(1)) ,@OldAD_EFFECT_ON_CTC =CAST(isnull(AD_EFFECT_ON_CTC,0)as varchar(2)),@OldAD_EFFECT_ON_OT  =CAST(isnull(AD_EFFECT_ON_OT,0)as varchar(1)),@OldAD_EFFECT_ON_EXTRA_DAY  =CAST(isnull(AD_EFFECT_ON_EXTRA_DAY,0)AS VARCHAR(1)),@OldAD_EFFECT_MONTH  =isnull(AD_EFFECT_MONTH ,''),
     --           @OldLEAVE_TYPE  =ISNULL(LEAVE_TYPE,'') ,@OldAD_CAL_TYPE  =ISNULL(AD_CAL_TYPE,''),@OldAD_EFFECT_FROM  =isnull(AD_EFFECT_FROM,0),@OldEffect_Net_Salary  =CAST(isnull(Effect_Net_Salary,0)as varchar(2)),@OldEffect_Net_TDS =CAST(isnull(AD_Effect_On_TDS,0)as varchar(1)),@OldAD_NOT_EFFECT_ON_LWP  =CAST(isnull(AD_NOT_EFFECT_ON_LWP,0)as varchar(1)),@OldAD_PART_OF_CTC  =CAST(isnull(AD_PART_OF_CTC,'')as varchar(1)),@OldFor_FnF  =CAST(isnull(For_FnF ,0)as varchar(1)),
     --           @OldNot_effect_on_Monthly_ctc =CAST(ISNULL(Not_effect_on_Monthly_ctc,0)as varchar(1)) ,@OldIs_Yearly  =CAST(ISNULL(@Is_Yearly,0)as varchar(2)),@OldNot_effect_on_Basic_Calculation  =CAST(isnull(Not_effect_on_Basic_Calculation,0)as varchar(2)),@OldAD_EFFECT_ON_BONUS  =CAST(isnull(AD_EFFECT_ON_BONUS,0)as varchar(2)),@OldAD_EFFECT_ON_LEAVE  =CAST(isnull(AD_EFFECT_ON_LEAVE,0)as varchar(2))   
     --          ,@Old_Is_Attach_Man   = Attached_Mandatory 
			  -- ,@Old_Is_AutoPaid   = Auto_Paid
			  -- ,@Old_Is_Display_Balanc  = Display_Balance 
			  -- ,@Old_Allowance_type  =Allowance_Type   
			  -- ,@OldLTA_Leave_App_Limit = LTA_Leave_App_Limit --Ripal 16Jan2014
			  --  ,@OldNo_OF_Month = No_OF_Month
			  --  ,@Old_Is_Optional=Is_Optional
			  --  ,@Old_AD_Code = AD_Code --Ripal 13Jun2014
			  --  ,@Old_Monthly_Limit = Monthly_Limit --Ripal 06Nov2014
			  --  ,@OldDefineReimExpenseLimit = DefineReimExpenseLimit -- Ripal 08Nov2014
			  --  ,@OldEffectNightHalt=Ad_Effect_on_Nighthalt
			  --  ,@OldEffectGatePass = AD_EFFECT_ON_Gatepass -- Addedv by Gadriwala 060120
			  --  ,@OldEffectESIC=Ad_Effect_On_Esic
			  --  ,@OldCal_on_Imported=Is_Calculated_On_Imported_Value --Added by Sumit 27052015
			  --  ,@OldAutoDedTDS=Auto_Ded_TDS --Added by Sumit 16072015
     --From dbo.T0050_AD_MASTER Where Cmp_ID = @Cmp_ID and Ad_Id = @AD_ID       
                    
              ----------------
    EXEC P0120_GRADEWISE_ALLOWANCE  0,@CMP_ID,@AD_ID,@Tran_Type,@Constraint,@AD_LEVEL ,@GradeXML      
    EXEC P0190_Seniority_Award_Slab  0,@CMP_ID,@AD_ID,@Tran_Type,@SRXML -- Added by rohit on 02062015
    	
		---ADDED BY HARDIK 31/12/2020 FOR MANUBHAI CLIENT
		If @Auto_Insert_to_IT_Form_Design = 1 And @AD_FLAG = 'I'
			BEGIN
				If Exists (Select 1 From T0100_IT_FORM_DESIGN WITH (NOLOCK) Where Cmp_Id = @CMP_ID And (AD_Id = @AD_ID OR Rimb_ID = @AD_ID) AND FINANCIAL_YEAR = @FIN_YEAR)
					BEGIN
						DELETE T0100_IT_FORM_DESIGN WHERE Cmp_Id = @CMP_ID And (AD_Id = @AD_ID OR Rimb_ID = @AD_ID) AND FINANCIAL_YEAR = @FIN_YEAR
					END
			END
    
    Delete From T0040_AD_Formula_Setting Where AD_Id = @AD_ID -- Added by Hardik 23/09/2014
    Delete From T0040_AD_Formula_Eligible_Setting Where AD_Id = @AD_ID -- Added by Hardik 23/09/2014
    delete from T0060_EFFECT_AD_MASTER WHERE AD_ID = @AD_ID    
    Delete From T0050_AD_MASTER Where AD_ID = @AD_ID   
	DELETE FROM T0060_Reim_Quarter_Period WHERE AD_ID = @AD_ID
    
    
    ---Add By PAras 19-10-2012
      --set @OldValue = 'old Value' + + '#'+ 'AD NAME :' +ISNULL( @OldAD_NAME,'') + '#' + 'AD SORT NAME :' + ISNULL( @OldAD_SORT_NAME,'') + '#' + 'AD LEVEL :' + CAST(ISNULL(@OldAD_LEVEL,0) AS VARCHAR(20)) + '#' + 'AD FLAG :' + ISNULL( @OldAD_FLAG,'') + '#' + 'AD CALCULATE ON :' +ISNULL( @OldAD_CALCULATE_ON,'') + ' #'+ 'AD MODE :' +ISNULL(@OldAD_MODE,'') + ' #'+ 'AD PERCENTAGE :' +CAST(ISNULL(@OldAD_PERCENTAGE,0)as varchar(15)) + ' #'+ 'AD AMOUNT :' + CAST(ISNULL(@OldAD_AMOUNT,0)AS VARCHAR(25))  + ' #'
      --                            + '#'+ 'AD ACTIVE:' +CAST(ISNULL( @OldAD_ACTIVE,0)as varchar(1)) + '#' + 'AD MAX LIMIT :' +CAST( ISNULL(@OldAD_MAX_LIMIT,0)as varchar(20)) + '#' + 'AD NOT EFFECT ON PT :' + CAST(ISNULL(@OldAD_NOT_EFFECT_ON_PT,0) AS VARCHAR(2)) + '#' + 'AD NOT EFFECT SALARY :' +CAST(ISNULL(@OldAD_NOT_EFFECT_SALARY,0)AS VARCHAR(2)) + '#' + 'AD EFFECT ON CTC :' +CAST(ISNULL( @OldAD_EFFECT_ON_CTC,0)AS VARCHAR(2)) + ' #'+ 'AD EFFECT ON OT :' +CAST(ISNULL(@OldAD_EFFECT_ON_OT,0)AS VARCHAR(1)) + ' #'+ 'AD EFFECT ON EXTRA DAY :' +CAST(ISNULL( @OldAD_EFFECT_ON_EXTRA_DAY,0)as varchar(1)) + ' #'+ 'AD EFFECT MONTH  :' + ISNULL(@OldAD_EFFECT_MONTH ,'')  + ' #'
      --                            + '#'+ 'LEAVE TYPE :' +ISNULL(@OldLEAVE_TYPE,'') + '#' + 'AD EFFECT FROM:' + ISNULL(@OldAD_EFFECT_FROM,'') + '#' + 'Constraint :' + ISNULL(@OldConstraint,'')  + '#' + 'Effect Net Salary :' +CAST( ISNULL( @OldEffect_Net_Salary,0)AS VARCHAR(1)) + '#' + 'Effect Net TDS :' +CAST(ISNULL(@OldEffect_Net_TDS,0)AS VARCHAR(2)) + ' #'+ 'AD NOT EFFECT ON LWP :' +CAST(ISNULL(@OldAD_NOT_EFFECT_ON_LWP,0)AS VARCHAR(2)) + ' #'+ 'AD PART OF CTC:' +CAST(ISNULL(@OldAD_PART_OF_CTC,0)AS VARCHAR(1)) + ' #'+ 'For FnF :' + CAST(ISNULL(@OldFor_FnF,0)AS VARCHAR(1))  + ' #'
      --                            + ' #'+ 'Not effect on Monthly ctc :' +CAST(ISNULL(@OldNot_effect_on_Monthly_ctc,0)AS VARCHAR(1)) + ' #'+ 'Is Yearly:' +CAST(ISNULL(@OldIs_Yearly,0)AS VARCHAR(1)) + ' #'+ 'Not effect on Basic Calculation :' + CAST(ISNULL(@OldNot_effect_on_Basic_Calculation,0)AS VARCHAR(1))  + ' #'  + 'AD EFFECT ON BONUS :' + CAST(ISNULL(@OldAD_EFFECT_ON_BONUS,0)AS VARCHAR(1))  + ' #' + 'AD EFFECT ON LEAVE :' + CAST(ISNULL(@OldAD_EFFECT_ON_LEAVE,0)AS VARCHAR(1))  + ' #'     
                                  
      --                            +' #'+ 'Attached_Mandatory :' + CAST(ISNULL(@Old_Is_Attach_Man,0)AS VARCHAR(1))  
      --                            +' #'+ 'Auto_Paid :' + CAST(ISNULL(@Old_Is_AutoPaid,0)AS VARCHAR(10))  
      --                            +' #'+ 'Display_Balance :' + CAST(ISNULL(@Old_Is_Display_Balanc,0)AS VARCHAR(10))  
      --                            +' #'+ 'Allowance_Type :' + CAST(ISNULL(@Old_Allowance_type,0)AS VARCHAR(10))  
      --                            +' #'+ 'LTA Leave App. Limit :' + CAST(ISNULL(@OldLTA_Leave_App_Limit,0)AS VARCHAR(10))   
						--		  +' #'+ 'Number of Month :' + CAST(ISNULL(@OldNo_OF_Month,0)AS VARCHAR(10))
						--		  +' #'+ 'Code :' + Cast(IsNull(@Old_AD_Code,'') as varchar(50))
						--		  +' #'+ 'Monthly Limit :' + Cast(isnull(@Old_Monthly_Limit,'') as varchar(50))
						--		  +' #'+ 'DefineReimExpenseLimit :' + cast(isnull(@OldDefineReimExpenseLimit,'0') as varchar(50))
						--		  +' #'+ 'EffectOnNIghtHalt :' + cast(isnull(@OldEffectNightHalt,'0') as varchar(50))
						--		  +' #'+ 'EffectOnGatePass :' + cast(isnull(@OldEffectGatePass,'0') as varchar(50))
						--		  +' #'+ 'EffectESIC :' + cast(isnull(@OldEffectESIC,'0') as varchar(20))
						--		  +' #'+ 'Cal_on_Imported :' + cast(isnull(@OldCal_on_Imported,'0') as varchar(20))
						--		  +' #'+ 'Auto_Ded_TDS :' + cast(isnull(@OldAutoDedTDS,'0') as varchar(20))
    
  end    
   exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Allowance Mater',@OldValue,@AD_ID,@User_Id,@IP_Address
   ---------
   
  --exec P0040_ReimClaim_Setting 0,@CMP_ID,@AD_ID,@Non_Taxable_Limit,@Taxable_Limt,@Is_CF,@Num_App_Block,@Tran_Type
     
 RETURN



