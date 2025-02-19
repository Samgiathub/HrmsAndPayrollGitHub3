
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0070_EMP_INCREMENT_APP]	
	 @Increment_ID				Int OUTPUT
	,@Cmp_ID					Int
	,@Emp_Tran_ID				bigint
	,@Emp_Application_ID		int
	,@Branch_ID					Int
	,@Cat_ID					Int
	,@Grd_ID					Int
	,@Dept_ID					Int
	,@Desig_ID					Int
	,@Type_ID					Int
	,@Bank_ID					Int
	,@Curr_ID					Int
	,@Wages_Type				VARCHAR(10)
	,@Salary_Basis_On			VARCHAR(20)
	,@Basic_Salary				NUMERIC(18, 4)
	,@Gross_Salary				NUMERIC(18, 4)	
	,@Increment_Date			DATETIME OUTPUT
	,@Increment_Effective_Date	DATETIME 
	,@Payment_Mode				VARCHAR(20)
	,@Inc_Bank_AC_No			VARCHAR(20)
	,@Emp_OT					Int
	,@Emp_OT_Min_Limit			VARCHAR(10)
	,@Emp_OT_Max_Limit			VARCHAR(10)
	,@Increment_Per				NUMERIC(18, 4)
	,@Increment_Amount			NUMERIC(18, 4)
	,@Pre_Basic_Salary			NUMERIC(18, 4)
	,@Pre_Gross_Salary			NUMERIC(18, 4)
	,@Increment_Comments		VARCHAR(250)
	,@Emp_Late_mark				NUMERIC
	,@Emp_Full_PF				NUMERIC
	,@Emp_PT					NUMERIC
	,@Emp_Fix_Salary			NUMERIC
	,@Emp_Late_Limit			VARCHAR(10) = '00:00'
    ,@Late_Dedu_type			VARCHAR(10)
    ,@Emp_part_Time				NUMERIC(1,0)
	,@Is_Master_Rec				TINYINT = 0	-- Define this parameter in only Insert statement
	,@Login_ID					NUMERIC(18) = 0
	,@Yearly_Bonus_Amount		NUMERIC(18, 4) = 0
	,@Deputation_End_Date		DATETIME = NULL 
	,@emp_superior				int = 0
	,@Dep_Reminder				TINYINT=1
	,@Is_Emp_Master				TINYINT=0
	,@CTC						NUMERIC(18, 4) = 0
	,@Dep_Amount				NUMERIC(18, 4) = 0
	,@Dep_Month					Int = 0
	,@Dep_Year					Int = 0
	,@Set_Amount				NUMERIC(18, 4) = 0
	,@Set_Month					Int = 0
	,@Set_Year					Int = 0
	,@Emp_Early_mark			Int = 0 -- Added by Mitesh on 25/08/2011
	,@Early_Dedu_Type			VARCHAR(10)	= ''
	,@Emp_Early_Limit			VARCHAR(10)	= '00:00'
	,@Emp_Deficit_mark			Int = 0
	,@Deficit_Dedu_Type			VARCHAR(10)	 = ''
	,@Emp_Deficit_Limit			VARCHAR(10)	= ''
	,@Center_ID					Int = 0 --'Alpesh 23-Sep-2011
	,@Emp_wd_ot_rate			NUMERIC(5,3) = 0
    ,@Emp_wo_ot_rate			NUMERIC(5,3) = 0
    ,@Emp_ho_ot_rate			NUMERIC(5,3) = 0
    ,@Pre_CTC_Salary			NUMERIC(18, 4) = 0
	,@Incerment_Amount_gross	NUMERIC(18, 4) = 0
	,@Incerment_Amount_CTC		NUMERIC(18, 4) = 0
	,@Increment_Mode			TINYINT = 0
	,@no_of_chlidren			NUMERIC = 0
    ,@is_metro					TINYINT = 0
    ,@is_physical				TINYINT = 0
    ,@Salary_Cycle_id			NUMERIC = 0
    ,@auto_vpf					Int = 0 -- Rohit 18072013
    ,@Segment_ID				Int = 0
    ,@Vertical_ID				Int = 0
    ,@SubVertical_ID			Int = 0
    ,@subBranch_ID				Int = 0 --Added By Gadriwala 30072013
    ,@Monthly_Deficit_Adjust_OT_Hrs tinyint =0	--Ankit 25102013
    ,@Fix_OT_Hour_Rate_WD numeric(18,3)=0		--Ankit 29102013
    ,@Fix_OT_Hour_Rate_WO_HO numeric(18,3)=0	--Ankit 29102013
    ,@Bank_ID_Two		Int = 0			-- Added by Ali 14112013
	,@Payment_Mode_Two	varchar(20)	= ''			-- Added by Ali 14112013
	,@Inc_Bank_AC_No_Two	varchar(20)	= ''		-- Added by Ali 14112013
	,@Bank_Branch_Name	varchar(50)	= ''			-- Added by Ali 14112013
	,@Bank_Branch_Name_Two	varchar(50)	= ''		-- Added by Ali 14112013
	,@Reason_ID  Int=0	             -- Added by nilesh patel on 21012016
	,@Reason_Name varchar(200)	= ''	     -- Added by nilesh patel on 21012016
	,@User_Id Int = 0   --Added By Mukti 01072016
	,@IP_Address varchar(30)= '' --Added By Mukti 01072016
	,@Customer_Audit  tinyint = 0	--Added by Jaina 22-08-2016		
	,@Old_Join_Date datetime=null --Added by Sumit on 28092016
	,@Sales_Code VARCHAR(20) = '' --Added By Ramiz on 08122016
	,@Physical_Percent NUMERIC(18,2) = 0 --added by Krushna 05-07-2018
	,@Approved_Emp_ID int
	,@Approved_Date Datetime = NULL
	,@Rpt_Level int
	,@Pay_Scale_ID int=0
	,@Pay_Scale_Effective_Date Datetime = NULL
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--SET DEADLOCK_PRIORITY NORMAL;
	
	--Added By Mukti 29-06-2016(Start)for Audit_Trail
	declare @OldValue as  varchar(max) 
	Declare @String as varchar(max)
	declare @Tran_Type Char(1)
	set @String =''
	set @OldValue = ''	
	--Added By Mukti 29-06-2016(End)

	DECLARE @Date_Of_Join DATETIME
	-- ** Increment Cross Company Approval - Ankit 29072016
	SELECT @Cmp_ID = Cmp_ID , @Date_Of_Join = Date_Of_Join From T0060_EMP_MASTER_APP WITH (NOLOCK)
	WHERE Emp_Tran_ID= @Emp_Tran_ID and  Emp_Application_ID=@Emp_Application_ID
	 
	
	DECLARE @Increment_Type	VARCHAR(30)
	SET @Increment_Type = 'Joining'


	--DECLARE @Allow_Same_Date_Increment TINYINT		--Ankit 17022015
	--SET @Allow_Same_Date_Increment  = 0
	--SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0) 
	--FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'

	--For Old Values in Audit Trail
	SELECT * INTO #T0070_EMP_INCREMENT_APP_DELETED FROM T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID=@Increment_ID

	  --IF EXISTS(SELECT Increment_ID FROM dbo.T0070_EMP_INCREMENT_APP  WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
			--BEGIN
			--	RAISERROR('@@Same Date Entry Exists@@',16,2)
			--	RETURN
			--END
	IF @is_physical = 0
		SET @Physical_Percent = 0
		
	IF @Deputation_End_Date = ''  
		SET @Deputation_End_Date  = NULL 

	IF @Emp_OT_Max_Limit ='0:' OR @Emp_OT_Max_Limit ='00:' OR @Emp_OT_Max_Limit ='0'OR @Emp_OT_Max_Limit = ''
		SET @Emp_OT_Max_Limit ='00:00'
	
	IF @Emp_OT_Min_Limit ='0:' OR @Emp_OT_Min_Limit ='00:' OR @Emp_OT_Min_Limit ='0'OR @Emp_OT_Min_Limit = ''
		SET @Emp_OT_Min_Limit ='00:00'
		
	IF @Emp_Late_Limit	= '0' OR @Emp_Late_Limit = ''
		SET @Emp_Late_Limit = '00:00'	
	
	IF @Emp_Early_Limit	= '0' OR @Emp_Early_Limit = ''
		SET @Emp_Early_Limit = '00:00'	
		
	IF @Emp_OT IS NULL
		SET @Emp_OT=0
	
	IF @Dept_ID = 0
		SET @Dept_ID = NULL 
	IF @Desig_Id = 0
		SET @Desig_Id = NULL 
	IF @Cat_ID = 0
		SET @Cat_ID = NULL	
		
	IF @Pay_Scale_Effective_Date = ''  
			SET @Pay_Scale_Effective_Date  = NULL 
	--IF @Bank_ID = 0
	--	SET @Bank_ID = NULL
		
	---- Added By Ali 14112013 -- Start
	--IF @Bank_ID_Two = 0
	--	SET @Bank_ID_Two = NULL
	---- Added By Ali 14112013 -- End
	
	
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Curr_ID = 0
		SET @Curr_ID = NULL	
	IF @Login_ID =0
		SET @Login_ID = NULL
	IF @emp_superior=0
		SET @emp_superior = NULL
	IF @Segment_ID = 0
		SET @Segment_ID = NULL
	IF @Vertical_ID = 0 
		SET @Vertical_ID = NULL
	IF @SubVertical_ID = 0 
		SET @SubVertical_ID = NULL
	IF @subBranch_ID  =0
		SET @subBranch_ID = NULL
	IF @Salary_Cycle_id = 0				--Added By Gadriwala Muslim 28092013
		SET @Salary_Cycle_id = null
    IF @Reason_Name = ''				-- Added by nilesh patel on 21012016
		SET @Reason_Name = NULL
    If @Center_ID = 0					-- Added by Ramiz on 05052016
		SET @Center_ID = NULL		
	if (IsNull(@Old_Join_Date,'1900-01-01') = '1900-01-01') --Added by Sumit on 29092016
		Begin
			set @Old_Join_Date = @Increment_Effective_Date
		End
			
		
		
		
		
	DECLARE @PT_Amount			NUMERIC 
	DECLARE @AD_Other_Amount	NUMERIC 
	DECLARE @Max_Increment_ID	NUMERIC 
	DECLARE @Max_Shift_ID NUMERIC
	DECLARE @Current_Date DATETIME
	DECLARE @Old_Bank_Id				Numeric(18, 0) 
	DECLARE @Old_Bank_Branch_Name		varchar(50)	
	DECLARE @Old_Bank_ID_Two			numeric(18, 0) 
	DECLARE @Old_Inc_Bank_AC_No_Two		varchar(20)	
	DECLARE @Old_Bank_Branch_Name_Two	varchar(50)	
	DECLARE @Old_Payment_Mode_Two		varchar(20)
	Declare @Old_Emp_Part_time   numeric(18,0) --Added by Jaina 12-01-2019
	set @Old_Bank_Id				= 0	
	set @Old_Bank_Branch_Name		= ''	
	set @Old_Bank_ID_Two			= 0	
	set @Old_Inc_Bank_AC_No_Two		= ''
	set @Old_Bank_Branch_Name_Two	= ''
	set @Old_Emp_Part_time = 0
	--DECLARE @Old_Payment_Mode_Two			varchar(20)	
	SELECT @Current_Date = GETDATE()
	SET @PT_Amount = 0
	Set @Old_Payment_Mode_Two = ''
	-- Added  By Hiral 14 August, 2013 (Start)
	Declare @Temp_Effective_date As Datetime
	Set @Temp_Effective_date = DATEADD(month,month(@Increment_Effective_Date)-1,DATEADD(year,year(@Increment_Effective_Date)-1900,0))
	-- Added By Hiral 14 August, 2013 (End)
	
			
	
	DECLARE @Reporting_Row_ID NUMERIC
	
	--print @emp_superior
	IF @emp_superior IS NOT NULL
		BEGIN	
		
			EXEC P0065_EMP_REPORTING_DETAIL_APP 0,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,'Supervisor',@emp_superior,'Direct','i',0,@User_Id,@IP_Address,@Approved_Emp_ID,@Approved_Date,@Rpt_Level,@Increment_Effective_Date
				
			--IF NOT EXISTS(SELECT Row_ID FROM T0065_EMP_REPORTING_DETAIL_APP WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND R_Emp_ID=@emp_superior and Effect_Date = @Increment_Effective_Date) --Added By Ramiz on 08/06/2016
			--	BEGIN				
			--		if (@Increment_Effective_Date <> @old_Join_Date) --Increment Effective date as New date of Join
			--			Begin
							
			--				select @Reporting_Row_ID=isnull(MAX(Row_ID),0) from T0065_EMP_REPORTING_DETAIL_APP 
			--				where Emp_Tran_ID= @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID 
			--				--Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID
			--				 and Effect_Date=@Old_Join_Date-- Added by Sumit to update old join date in reporting manager table and also get max row id because of same date 2 reporting manager could be added so on 28092016							
			--				EXEC P0065_EMP_REPORTING_DETAIL_APP  @Reporting_Row_ID,@Emp_Tran_ID,@Emp_Application_ID,'Supervisor',@emp_superior,'Direct','u',0,@User_Id,@IP_Address,@Increment_Effective_Date
			--				--added binal @Emp_Tran_ID,@Emp_Application_ID
			--			End
			--		Else
			--			Begin														
			--				if not exists(SELECT ED.R_Emp_ID FROM T0065_EMP_REPORTING_DETAIL_APP ED 
			--							  INNER JOIN(SELECT MAX(Row_ID)Row_ID,Emp_ID  
			--							  FROM T0065_EMP_REPORTING_DETAIL_APP 
			--							  WHERE  Reporting_Method='Direct' 
			--							and  Emp_Tran_ID= @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID 
			--							  --AND emp_ID = @Emp_ID  --and Effect_Date <= @Increment_Effective_Date 
			--							  group by Emp_ID)ED1 on ED1.Row_ID=ED.Row_ID 
			--							  where  Emp_Tran_ID= @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID
			--							  --ED.cmp_id=@Cmp_ID and ed.Emp_ID=@Emp_ID
			--							  and R_Emp_ID=@emp_superior )--and Effect_Date = @Increment_Effective_Date  --Mukti(17032017)
			--				begin								
			--				--@User_Id,@IP_Address add by chetan 230517
			--					EXEC P0065_EMP_REPORTING_DETAIL_APP 0,@Emp_Tran_ID,@Emp_Application_ID,'Supervisor',@emp_superior,'Direct','i',0,@User_Id,@IP_Address,@Increment_Effective_Date
			--					--added binal @Emp_Tran_ID,@Emp_Application_ID
								
			--				END
			--			End	
			--	END
		END		
	--Else
	--	Begin
	--		select @emp_superior_old = Emp_superior from T0060_EMP_MASTER_APP where Emp_ID = @Emp_ID			
	--		Select @Reporting_Row_ID = Row_ID from T0065_EMP_REPORTING_DETAIL_APP Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=isnull(@emp_superior_old,0)
			
	--		if @Reporting_Row_ID is null
	--			set @Reporting_Row_ID = 0
				
	--		exec P0065_EMP_REPORTING_DETAIL_APP @Reporting_Row_ID,@Emp_ID,@Cmp_ID,'',@emp_superior,'Direct','d'
	--	End
	---End
	
	IF @Emp_PT = 1
		BEGIN
			SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0075_EMP_EARN_DEDUCTION_APP EED WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID 
				 WHERE Increment_ID=@Increment_ID AND E_AD_Flag ='I' AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 0
				 
			SET @AD_Other_Amount = @Basic_Salary + ISNULL(@AD_Other_Amount,0)
			--need to ask nimeshbhai Modify
			--EXEC SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount OUTPUT,'',@Branch_ID
		END

	
	IF ISNULL(@Increment_ID,0) = 0
		BEGIN
		
			
			--SELECT @Increment_ID = ISNULL(MAX(Increment_ID),0) + 1 FROM dbo.T0070_EMP_INCREMENT_APP 

			-- COMMENTED ABOVE AND ADDED NEW CONDITION BY HARDIK 09/07/2020 AS INCREMENT_ID DUPLICATING
			SELECT @INCREMENT_ID = ISNULL(MAX(INCREMENT_ID),0) + 1 
			From
			(
				SELECT MAX(INCREMENT_ID) Increment_Id from T0095_INCREMENT WITH (NOLOCK)
				Union All
				SELECT MAX(INCREMENT_ID) Increment_Id from T0070_EMP_INCREMENT_APP WITH (NOLOCK)
			) QRY

			
		
			-- Added By Hiral 14 August, 2013 (Start) 
			--need to Modify
			/*
			If Isnull(@Salary_Cycle_id,0) > 0
				Begin
					If Exists(Select 1 From T0095_Emp_Salary_Cycle 
					Where Cmp_ID = @Cmp_id And Emp_Id = @Emp_id And Effective_date = @Temp_Effective_date)
						Begin
							Update T0095_Emp_Salary_Cycle
								Set SalDate_id = @Salary_Cycle_id
								Where Cmp_ID = @Cmp_id 
								
								--And Emp_Id = @Emp_id 
								And Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								And Effective_date = @Temp_Effective_date
						End
					Else
						Begin
						--Need to Ask About Nimesh bhai Modify
							INSERT INTO T0095_Emp_Salary_Cycle
									  (Cmp_id, Emp_id, SalDate_id, Effective_date)
								VALUES (@Cmp_id,@Emp_id,@Salary_Cycle_id,@Temp_Effective_date)
						End
				End
			*/
			-- Added By Hiral 14 August, 2013 (End)
			
			INSERT INTO dbo.T0070_EMP_INCREMENT_APP
					(Emp_Tran_ID,Emp_Application_ID,Increment_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,Emp_Late_Limit,Emp_PT_Amount,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, Pre_CTC_Salary ,Incerment_Amount_gross,Incerment_Amount_CTC,Increment_Mode,Emp_Childran,Is_Metro_City,is_physical,salDate_id,Emp_Auto_Vpf,Segment_ID,Vertical_ID,SubVertical_ID,SubBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Bank_Branch_Name,Bank_Branch_Name_Two,Inc_Bank_AC_No_Two,Reason_ID,Reason_Name,Customer_Audit , Sales_Code,Physical_Percent,Approved_Emp_ID,Approved_Date,Rpt_Level,Pay_Scale_ID,Pay_Scale_Effective_Date)
				VALUES (@Emp_Tran_ID,@Emp_Application_ID,@Increment_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary,@Increment_Type,@Increment_Date,@Increment_Effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Pre_Basic_Salary,@Pre_Gross_Salary,@Increment_Comments,@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_part_Time,@Late_Dedu_type,@Emp_Late_Limit,@PT_Amount,@Is_Master_Rec,@Login_ID,GETDATE(),@Yearly_Bonus_Amount,@Deputation_End_Date,@CTC,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID,@Emp_wd_ot_rate,@Emp_wo_ot_rate,@Emp_ho_ot_rate, @Pre_CTC_Salary ,@Incerment_Amount_gross,@Incerment_Amount_CTC,@Increment_Mode,@no_of_chlidren ,@is_metro ,@is_physical,@Salary_Cycle_id,@auto_vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,@Inc_Bank_AC_No_Two,@Reason_ID,@Reason_Name,@Customer_Audit , @Sales_Code,@Physical_Percent,@Approved_Emp_ID,@Approved_Date,@Rpt_Level,@Pay_Scale_ID,@Pay_Scale_Effective_Date) -- Added By Ali 14112013  ''Added By Jaina 22-08-2016 (Customer_audit)
				
			
			/*Commented by Nimesh on 12-Feb-2019 (Method Updated)*/
			--Added By Mukti 01-07-2016(Start)					
			set @Tran_Type = 'I'						
			--exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
			--set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti 01-07-2016(End)		
			
						
			--need to ask Nimeshbhai For modify		
										
			/* IF (@Dep_Amount>0 AND @Dep_Month>0 AND @Dep_Year>0) OR (@Set_Amount>0 AND @Set_Month>0 AND @Set_Year>0)
				BEGIN 		
							
				    EXEC P0190_Monthly_AD_Detail_DepSett @Cmp_ID,@Emp_ID,@Increment_ID,@Dep_Amount,@Dep_Month,@Dep_Year,@Set_Amount,@Set_Month,@Set_Year 							
				END	
				*/

			
		END
	ELSE 
		BEGIN
		IF EXISTS (SELECT Emp_Tran_ID,Emp_Application_ID  FROM dbo.T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID =@Increment_ID AND ISNULL(Is_Master_Rec,0) = 1)
				BEGIN
					IF ISNULL(@Is_Emp_Master,0)=1
						BEGIN	
						 
							--Added By Mukti 01-07-2016(Start)					
							set @Tran_Type = 'U'						
							exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
							set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)	
								
							UPDATE dbo.T0070_EMP_INCREMENT_APP
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
									Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
									Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder,
									CTC = @CTC,
									Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,
									Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type	,Emp_Deficit_Limit=@Emp_Deficit_Limit,
									Center_ID=@Center_ID,
									Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate
									,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical
									,salDate_id = @Salary_Cycle_id,Emp_Auto_Vpf= isnull(@Auto_Vpf,0) -- rohit 18072013
									,Segment_ID = @Segment_ID,vertical_ID = @Vertical_ID,SubVertical_ID = @SubVertical_ID ,subbranch_ID = @subBranch_ID-- Added By Gadriwala Muslim 24072013
									,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs
									,Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD
									,Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO
									,Bank_ID_Two = @Bank_ID_Two								-- Added By Ali 14112013
									,Payment_Mode_Two = @Payment_Mode_Two					-- Added By Ali 14112013
									,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two				-- Added By Ali 14112013
									,Bank_Branch_Name = @Bank_Branch_Name					-- Added By Ali 14112013
									,Bank_Branch_Name_Two = @Bank_Branch_Name_Two			-- Added By Ali 14112013
									,@Reason_ID = Reason_ID								-- Added By Nilesh Patel 21012016
									,@Reason_Name = Reason_Name							-- Added By Nilesh Patel 21012016
									,Customer_Audit = @Customer_Audit					--Added By Jaina 22-08-2016
									,Sales_Code = @Sales_Code							--Added By Ramiz 07122016
									,Physical_Percent = @Physical_Percent				--adde by Krushna 05-07-2018
									,Approved_Emp_ID=@Approved_Emp_ID
									,Approved_Date=@Approved_Date
									,Rpt_Level=@Rpt_Level
									,Pay_Scale_ID=@Pay_Scale_ID
									,Pay_Scale_Effective_Date=@Pay_Scale_Effective_Date
								WHERE Increment_ID = @Increment_ID  AND 
								--Emp_ID = @Emp_ID
								Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)		
							
							/*
							IF ISNULL(@Salary_Cycle_id,0) <> 0
								BEGIN
									IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WHERE Emp_id = @Emp_ID)
										BEGIN	
										--need to ask modify																
											INSERT INTO T0095_Emp_Salary_Cycle
													(Cmp_id, Emp_id, SalDate_id, Effective_date)
												VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)		-- Added By Hiral 16 August, 2013
												-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)		-- Commented By Hiral 16 August, 2013
										END
									ELSE
										BEGIN
										--need to ask for modify
											UPDATE T0095_Emp_Salary_Cycle
												SET SalDate_id = @Salary_Cycle_id 
												WHERE Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID	-- Added By Hiral 16 August, 2013
												-- WHERE Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID		-- Commented By Hiral 16 August, 2013
										END
								END
							*/
						END 						
						
					ELSE
						BEGIN
							
							--Added By Mukti 01-07-2016(Start)					
								set @Tran_Type = 'U'						
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)
								
							UPDATE dbo.T0070_EMP_INCREMENT_APP
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
									Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
									Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder,
									CTC = @CTC,
									Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,
									Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type	,Emp_Deficit_Limit=@Emp_Deficit_Limit,
									Center_ID=@Center_ID,
									Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate,
									Pre_CTC_Salary = @Pre_CTC_Salary ,Incerment_Amount_gross = @Incerment_Amount_gross,Incerment_Amount_CTC = @Incerment_Amount_CTC,Increment_Mode = @Increment_Mode
									,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical
									,salDate_id = @Salary_Cycle_id,Emp_Auto_Vpf=@Auto_Vpf -- rohit 18072013
									,Segment_ID = @Segment_ID ,Vertical_ID = @Vertical_ID,SubVertical_ID = @SubVertical_ID,subbranch_ID = @subBranch_ID -- Added By Gadriwala Muslim 24072013
									,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs
									,Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD
									,Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO
									,Bank_ID_Two = @Bank_ID_Two							-- Added By Ali 14112013
									,Payment_Mode_Two = @Payment_Mode_Two					-- Added By Ali 14112013
									,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two				-- Added By Ali 14112013
									,Bank_Branch_Name = @Bank_Branch_Name					-- Added By Ali 14112013
									,Bank_Branch_Name_Two = @Bank_Branch_Name_Two			-- Added By Ali 14112013
									,@Reason_ID = Reason_ID								-- Added By Nilesh Patel 21012016
									,@Reason_Name = Reason_Name							-- Added By Nilesh Patel 21012016
									,Customer_Audit = @Customer_Audit					--Added By Jaina 22-08-2016
									 ,Sales_Code = @Sales_Code							--Added By Ramiz 07122016
									 ,Physical_Percent = @Physical_Percent				--added by Krushna 05-07-2018
									 ,Approved_Emp_ID=@Approved_Emp_ID
									 ,Approved_Date=@Approved_Date
									 ,Rpt_Level=@Rpt_Level
									 ,Pay_Scale_ID=@Pay_Scale_ID
									,Pay_Scale_Effective_Date=@Pay_Scale_Effective_Date
								WHERE Increment_ID = @Increment_ID  
								AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
							
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)					
							--need to ask modify	
							/*
								IF ISNULL(@Salary_Cycle_id,0) <> 0
									BEGIN
										IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WHERE Emp_id = @Emp_ID)
											BEGIN
												INSERT INTO T0095_Emp_Salary_Cycle
														(Cmp_id, Emp_id, SalDate_id, Effective_date)
													VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)		-- Added By Hiral 16 August, 2013
													-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)	-- Commented By Hiral 16 August, 2013
											END
										ELSE
											BEGIN
												UPDATE T0095_Emp_Salary_Cycle
													SET SalDate_id = @Salary_Cycle_id 
													WHERE Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID	-- Added By Hiral 16 August, 2013
													-- WHERE Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID	-- Commented By Hiral 16 August, 2013
											END
									END
							*/
						END	
				END
			ELSE
				BEGIN
																
					IF @Increment_Type = 'Joining'																						
						BEGIN
							
							SELECT @Pre_Basic_Salary = Pre_Basic_Salary ,@Pre_Gross_Salary = ISNULL(Pre_Gross_Salary,0) --Gross_Salary --Commented and Added By Ramiz on 11/05/2016 as it was Updating Wrong Gross when Employee is Updated from Employee master
								FROM dbo.T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID = @Increment_ID
								
						END		
									
					if @Increment_Mode = 1		
						BEGIN
							SET @Increment_Amount = @Basic_Salary - @Pre_Basic_Salary

						END
					else
						BEGIN
							
							IF @Pre_Basic_Salary > 0								
								SET @Increment_Amount = ((@Basic_Salary - @Pre_Basic_Salary) * 100)/@Pre_Basic_Salary;
															--print @Increment_Amount
						END	
					
					IF ISNULL(@Is_Emp_Master,0)=1
						BEGIN
						--Added By Mukti 01-07-2016(Start)					
								set @Tran_Type = 'U'						
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti 01-07-2016(End)
						
							UPDATE dbo.T0070_EMP_INCREMENT_APP
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
									Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder,
									CTC = @CTC,
									Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,
									Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type	,Emp_Deficit_Limit=@Emp_Deficit_Limit,
									Center_ID=@Center_ID,
									Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate
									,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical =@is_physical
									,salDate_id = @Salary_Cycle_id,Emp_Auto_Vpf=@Auto_Vpf -- rohit 18072013
									,Segment_ID = @Segment_ID ,Vertical_ID = @Vertical_ID,SubVertical_ID = @SubVertical_ID ,subbranch_ID = @subBranch_ID-- Added By Gadriwala Muslim 24072013
									,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs
									,Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD
									,Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO
									,Bank_ID_Two = @Bank_ID_Two							-- Added By Ali 14112013
									,Payment_Mode_Two = @Payment_Mode_Two					-- Added By Ali 14112013
									,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two				-- Added By Ali 14112013
									,Bank_Branch_Name = @Bank_Branch_Name					-- Added By Ali 14112013
									,Bank_Branch_Name_Two = @Bank_Branch_Name_Two			-- Added By Ali 14112013
									,@Reason_ID = Reason_ID								-- Added By Nilesh Patel 21012016
									,@Reason_Name = Reason_Name							-- Added By Nilesh Patel 21012016
									,Customer_Audit = @Customer_Audit					--Added By Jaina 22-08-2016
									 ,Sales_Code = @Sales_Code							--Added By Ramiz 07122016
									 ,Physical_Percent = @Physical_Percent				--added By Krushna 05-07-2018
								     ,Approved_Emp_ID=@Approved_Emp_ID
									 ,Approved_Date=@Approved_Date
									 ,Rpt_Level=@Rpt_Level
									 ,Pay_Scale_ID=@Pay_Scale_ID
									,Pay_Scale_Effective_Date=@Pay_Scale_Effective_Date
								WHERE Increment_ID = @Increment_ID  
								AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
						
						--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti 01-07-2016(End)			
						
						--Commented by Hardik 12/09/2018 discuss with Nimesh as below code not required now
						/*
						-- Added by rohit for Bank detail not Update if transfer given  08102015
						if  Exists (select Emp_id from T0070_EMP_INCREMENT_APP where Increment_ID = @Increment_ID  and (increment_type='Transfer' or increment_type='Deputation' ))
							begin
							Declare @increment_Without_transfer as numeric(18,0)
							set @increment_Without_transfer = 0
							select @increment_Without_transfer = MAX(increment_id) from T0070_EMP_INCREMENT_APP where Increment_Effective_Date <= @Increment_Effective_Date and increment_type <> 'Transfer' and increment_type <> 'Deputation' and Emp_ID = @Emp_ID 
							update T0070_EMP_INCREMENT_APP 
							set Bank_ID = @Bank_ID
								,Payment_Mode = @Payment_Mode
								,Inc_Bank_AC_No = @Inc_Bank_AC_No
								,Bank_Branch_Name = @Bank_Branch_Name
								
							WHERE Increment_ID = @increment_Without_transfer  AND Emp_ID = @Emp_ID
						end
						--ended by rohit on 08102015	
						*/
								
								/*
							IF ISNULL(@Salary_Cycle_id,0) <> 0
								BEGIN
								--need to ask modify	
									IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WHERE Emp_id = @Emp_ID)
										BEGIN
											INSERT INTO T0095_Emp_Salary_Cycle
													(Cmp_id, Emp_id, SalDate_id, Effective_date)
												VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)		-- Added By Hiral 16 August, 2013
												-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)  -- Commented By Hiral 16 August, 2013
										END
									ELSE
										BEGIN
											UPDATE T0095_Emp_Salary_Cycle
												SET SalDate_id = @Salary_Cycle_id
												WHERE Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID	-- Added By Hiral 16 August, 2013
												-- WHERE Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID	-- Commented By Hiral 16 August, 2013
										END
								END
								*/
						END
					ELSE
						BEGIN
						
						--Added By Mukti 01-07-2016(Start)					
						set @Tran_Type = 'U'	
						exec P9999_Audit_get @table='T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))				
						--Added By Mukti 01-07-2016(End)	
						
							UPDATE  dbo.T0070_EMP_INCREMENT_APP
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
									Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder,
									CTC = @CTC,Increment_Effective_Date = @Increment_Effective_Date,
									Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,
									Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type,Emp_Deficit_Limit=@Emp_Deficit_Limit,
									Center_ID=@Center_ID,
									Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate,
									Pre_CTC_Salary = @Pre_CTC_Salary ,Incerment_Amount_gross = @Incerment_Amount_gross,Incerment_Amount_CTC = @Incerment_Amount_CTC,Increment_Mode = @Increment_Mode
									,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical
									,salDate_id = @Salary_Cycle_id,Emp_Auto_Vpf=@Auto_Vpf -- rohit 18072013
									,Segment_ID = @Segment_ID ,Vertical_ID = @Vertical_ID ,SubVertical_ID = @SubVertical_ID,subbranch_ID = @subBranch_ID -- Added By Gadriwala Muslim 24072013
									,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs
									,Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD
									,Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO
									,Bank_ID_Two = @Bank_ID_Two							-- Added By Ali 14112013
									,Payment_Mode_Two = @Payment_Mode_Two					-- Added By Ali 14112013
									,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two				-- Added By Ali 14112013
									,Bank_Branch_Name = @Bank_Branch_Name					-- Added By Ali 14112013
									,Bank_Branch_Name_Two = @Bank_Branch_Name_Two			-- Added By Ali 14112013
									,Reason_ID = @Reason_ID							-- Added By Nilesh Patel 21012016
									,Reason_Name = @Reason_Name 							-- Added By Nilesh Patel 21012016
									,Customer_Audit = @Customer_Audit     --Added By Jaina 22-08-2016
									 ,Sales_Code = @Sales_Code		--Ramiz on 07122016
									 ,Physical_Percent = @Physical_Percent					--added by Krushna 05-07-2018
									 ,Approved_Emp_ID=@Approved_Emp_ID
									 ,Approved_Date=@Approved_Date
									 ,Rpt_Level=@Rpt_Level
									 ,Pay_Scale_ID=@Pay_Scale_ID
									,Pay_Scale_Effective_Date=@Pay_Scale_Effective_Date
								WHERE Increment_ID = @Increment_ID 
								 AND Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
								 -- Emp_ID = @Emp_ID
							
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0070_EMP_INCREMENT_APP' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)	
									
									/*
								IF ISNULL(@Salary_Cycle_id,0) <> 0
									BEGIN
									--need to ask modify 
										IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WHERE Emp_id = @Emp_ID)
											BEGIN																	
												INSERT INTO T0095_Emp_Salary_Cycle
														(Cmp_id, Emp_id, SalDate_id, Effective_date)
													VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)	-- Added By Hiral 16 August, 2013
													-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)	-- Commented By Hiral 16 August, 2013	
												END
											ELSE
												BEGIN
													UPDATE T0095_Emp_Salary_Cycle
														SET SalDate_id = @Salary_Cycle_id 
														WHERE Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID	-- Added By Hiral 16 August, 2013
														-- WHERE Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID	-- Commented By Hiral 16 August, 2013	
												END
									END
									*/
						END
				END
		--Need to ask modify
			/*IF (@Dep_Amount>0 AND @Dep_Month>0 AND @Dep_Year>0) OR (@Set_Amount>0 AND @Set_Month>0 AND @Set_Year>0)
				BEGIN 							
					EXEC P0190_Monthly_AD_Detail_DepSett @Cmp_ID,@Emp_ID,@Increment_ID,@Dep_Amount,@Dep_Month,@Dep_Year,@Set_Amount,@Set_Month,@Set_Year 							
				END	
				*/		
		END
	
	--- Update latest record in Employee Master 

	SELECT @Max_Increment_ID = I.Increment_ID, @Increment_Effective_Date = I.Increment_Effective_Date 
		FROM dbo.T0070_EMP_INCREMENT_APP I WITH (NOLOCK)
			INNER JOIN (SELECT MAX(Increment_ID)Increment_ID, Emp_Tran_ID FROM dbo.T0070_EMP_INCREMENT_APP WITH (NOLOCK)
			WHERE  Emp_Tran_ID = @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID
			--Emp_ID=@Emp_ID 
			GROUP BY Emp_Tran_ID)Q 
			ON  i.Increment_ID =q.Increment_ID
							
	--Added by Falak on 19-APR-2011
	--Alter TABLE T0060_EMP_MASTER_APP DISABLE TRIGGER ALL
	
	UPDATE T0060_EMP_MASTER_APP 
		SET Increment_Id =@Max_Increment_ID	
			--,emp_superior=@emp_superior			
		WHERE Emp_Tran_ID = @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID
		
	IF ISNULL(@emp_superior,0) <> 0
		BEGIN
			UPDATE	T0060_EMP_MASTER_APP 
			SET		emp_superior=@emp_superior
			WHERE	Emp_Tran_ID = @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID
			--Emp_ID =@Emp_ID 
		END
	
	--Alter TABLE T0060_EMP_MASTER_APP Enable TRIGGER ALL
	UPDATE T0075_EMP_EARN_DEDUCTION_APP 
		SET	Approved_Date = @Increment_Effective_Date
		WHERE  Emp_Tran_ID = @Emp_Tran_ID and Emp_Application_ID= @Emp_Application_ID
		--Emp_ID = @Emp_ID
		 AND Increment_Id = @Increment_ID
	
	--zalak for manager history
	--EXEC P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@emp_superior,@Increment_Effective_Date
	----------------------------------------------
	--add by Krushna 05-04-2018
	
	--Comenetd binal need to ask modify
	/*UPDATE E
		SET		Branch_ID = @Branch_ID
		FROM	T9999_EMPLOYEE_ENROLLMENT E 
			INNER JOIN T0060_EMP_MASTER_APP EM ON E.Enroll_No=EM.Enroll_No
		WHERE	EM.Emp_ID=@Emp_ID */
		--end binal 
	--end Krushna
	--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Increment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1 --added By Mukti 01072016

	--For New Values in Audit Trail
	SELECT * INTO #T0070_EMP_INCREMENT_APP_INSERTED FROM T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID=@Increment_ID
	
	
	EXEC P9999_AUDIT_LOG @TableName='T0070_EMP_INCREMENT_APP', @IDFieldName='Increment_ID',@Audit_Module_Name='Employee Increment',
				@User_Id=@User_Id,@IP_Address=@IP_Address,@MandatoryFields='Increment_Date,Increment_Type,Increment_Effective_Date',
			@Audit_Change_Type=@Tran_Type	
	

RETURN

