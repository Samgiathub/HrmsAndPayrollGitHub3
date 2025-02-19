

CREATE PROCEDURE [dbo].[P0095_INCREMENT_INSERT_15062021]
	 @Increment_ID				NUMERIC(18, 0) OUTPUT
	,@Emp_ID					NUMERIC(18, 0)
	,@Cmp_ID					NUMERIC(18, 0)
	,@Branch_ID					NUMERIC(18, 0)
	,@Cat_ID					NUMERIC(18, 0)
	,@Grd_ID					NUMERIC(18, 0)
	,@Dept_ID					NUMERIC(18, 0)
	,@Desig_Id					NUMERIC(18, 0)
	,@Type_ID					NUMERIC(18, 0)
	,@Bank_ID					NUMERIC(18, 0)
	,@Curr_ID					NUMERIC(18, 0)
	,@Wages_Type				VARCHAR(10)
	,@Salary_Basis_On			VARCHAR(20)
	,@Basic_Salary				NUMERIC(18, 4)
	,@Gross_Salary				NUMERIC(18, 4)
	,@Increment_Type			VARCHAR(30)
	,@Increment_Date			DATETIME OUTPUT
	,@Increment_Effective_Date	DATETIME 
	,@Payment_Mode				VARCHAR(20)
	,@Inc_Bank_AC_No			VARCHAR(20)
	,@Emp_OT					NUMERIC(18, 0)
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
	,@emp_superior				NUMERIC(18,0) = 0
	,@Dep_Reminder				TINYINT=1
	,@Is_Emp_Master				TINYINT=0
	,@CTC						NUMERIC(18, 4) = 0
	,@Dep_Amount				NUMERIC(18, 4) = 0
	,@Dep_Month					NUMERIC(18,0) = 0
	,@Dep_Year					NUMERIC(18,0) = 0
	,@Set_Amount				NUMERIC(18, 4) = 0
	,@Set_Month					NUMERIC(18,0) = 0
	,@Set_Year					NUMERIC(18,0) = 0
	,@Emp_Early_mark			NUMERIC(1, 0) = 0 -- Added by Mitesh on 25/08/2011
	,@Early_Dedu_Type			VARCHAR(10)	= ''
	,@Emp_Early_Limit			VARCHAR(10)	= '00:00'
	,@Emp_Deficit_mark			NUMERIC(1, 0) = 0
	,@Deficit_Dedu_Type			VARCHAR(10)	 = ''
	,@Emp_Deficit_Limit			VARCHAR(10)	= ''
	,@Center_ID					NUMERIC(18,0) = 0 --'Alpesh 23-Sep-2011
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
    ,@auto_vpf					NUMERIC(18) = 0 -- Rohit 18072013
    ,@Segment_ID				NUMERIC = 0
    ,@Vertical_ID				NUMERIC = 0
    ,@SubVertical_ID			NUMERIC = 0
    ,@subBranch_ID				NUMERIC = 0 --Added By Gadriwala 30072013
    ,@Monthly_Deficit_Adjust_OT_Hrs tinyint =0	--Ankit 25102013
    ,@Fix_OT_Hour_Rate_WD numeric(18,3)=0		--Ankit 29102013
    ,@Fix_OT_Hour_Rate_WO_HO numeric(18,3)=0	--Ankit 29102013
    ,@Bank_ID_Two		numeric(18, 0) = 0			-- Added by Ali 14112013
	,@Payment_Mode_Two	varchar(20)	= ''			-- Added by Ali 14112013
	,@Inc_Bank_AC_No_Two	varchar(20)	= ''		-- Added by Ali 14112013
	,@Bank_Branch_Name	varchar(50)	= ''			-- Added by Ali 14112013
	,@Bank_Branch_Name_Two	varchar(50)	= ''		-- Added by Ali 14112013
	,@Reason_ID  numeric(5,0)=0	             -- Added by nilesh patel on 21012016
	,@Reason_Name varchar(200)	= ''	     -- Added by nilesh patel on 21012016
	,@User_Id numeric(18,0) = 0   --Added By Mukti 01072016
	,@IP_Address varchar(30)= '' --Added By Mukti 01072016
	,@Customer_Audit  tinyint = 0	--Added by Jaina 22-08-2016		
	,@Old_Join_Date datetime=null --Added by Sumit on 28092016
	,@Sales_Code VARCHAR(20) = '' --Added By Ramiz on 08122016
	,@Physical_Percent NUMERIC(18,2) = 0 --added by Krushna 05-07-2018
	,@Piece_TransSalary TinyInt = 0
AS
 SET NOCOUNT ON;    
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
	  SELECT @Cmp_ID = Cmp_ID , @Date_Of_Join = Date_Of_Join From T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID	--DOJ Added By Ramiz on 07/12/2017

	--Hardik 11/09/2018 for AIA, If Salary has been generated with Same Increment ID or Greater Increment Id, then It should not update or delete
	IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_Id And @Increment_Effective_Date < Month_End_Date) And @Increment_ID > 0 And @INCREMENT_TYPE <> 'Joining'
		IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID =@Emp_Id And Increment_ID >= @Increment_Id) And @Increment_ID > 0
			BEGIN
				RAISERROR('@@Cannot Update, Salary Exists@@',16,2)
				RETURN
			END

	If EXISTS(SELECT 1 from T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Increment_ID > @Increment_ID) And @Increment_Id > 0 And @INCREMENT_TYPE <> 'Joining'
			BEGIN
				RAISERROR('@@Cannot Update, Next Increment Exists@@',16,2)
				RETURN
			END

	
	  DECLARE @Allow_Same_Date_Increment TINYINT		--Ankit 17022015
	  SET @Allow_Same_Date_Increment  = 0
	  SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0) 
	  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'

	--For Old Values in Audit Trail
	SELECT * INTO #T0095_INCREMENT_DELETED FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID=@Increment_ID

	  --IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT  WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
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
	
	-- New code Added by Ramiz on 07/12/2017 ( Restricting Transfer on Joining Date ) --
	IF @Increment_Type = 'Transfer' and @Increment_Effective_Date = @Date_Of_Join
		BEGIN
			RAISERROR('@@Cannot Transfer Employee on Joining Date@@',16,2)
			RETURN
		END
			
	
	DECLARE @Reporting_Row_ID NUMERIC
	
	
	IF @emp_superior IS NOT NULL
		BEGIN		
			IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID AND R_Emp_ID=@emp_superior and Effect_Date = @Increment_Effective_Date) --Added By Ramiz on 08/06/2016
				BEGIN				
					if (@Increment_Effective_Date <> @old_Join_Date) --Increment Effective date as New date of Join
						Begin
							
							select @Reporting_Row_ID=isnull(MAX(Row_ID),0) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Effect_Date=@Old_Join_Date-- Added by Sumit to update old join date in reporting manager table and also get max row id because of same date 2 reporting manager could be added so on 28092016							
							EXEC P0090_EMP_REPORTING_DETAIL @Reporting_Row_ID ,@Emp_ID,@Cmp_ID,'Supervisor',@emp_superior,'Direct','u',0,@User_Id,@IP_Address,@Increment_Effective_Date
						End
					Else
						Begin														
							if not exists(SELECT ED.R_Emp_ID FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK)
										  INNER JOIN(SELECT MAX(Row_ID)Row_ID,Emp_ID  FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
										  WHERE  Reporting_Method='Direct' AND emp_ID = @Emp_ID  --and Effect_Date <= @Increment_Effective_Date 
										  group by Emp_ID)ED1 on ED1.Row_ID=ED.Row_ID where ED.cmp_id=@Cmp_ID and R_Emp_ID=@emp_superior and ed.Emp_ID=@Emp_ID)--and Effect_Date = @Increment_Effective_Date  --Mukti(17032017)
							begin								
							--@User_Id,@IP_Address add by chetan 230517
								EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@emp_superior,'Direct','i',0,@User_Id,@IP_Address,@Increment_Effective_Date
								
							END
						End	
				END
		END		
	--Else
	--	Begin
	--		select @emp_superior_old = Emp_superior from T0080_EMP_MASTER where Emp_ID = @Emp_ID			
	--		Select @Reporting_Row_ID = Row_ID from T0090_EMP_REPORTING_DETAIL Where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and R_Emp_ID=isnull(@emp_superior_old,0)
			
	--		if @Reporting_Row_ID is null
	--			set @Reporting_Row_ID = 0
				
	--		exec P0090_EMP_REPORTING_DETAIL @Reporting_Row_ID,@Emp_ID,@Cmp_ID,'',@emp_superior,'Direct','d'
	--	End
	---End
	
	IF @Emp_PT = 1
		BEGIN
			SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID 
				 WHERE Increment_ID=@Increment_ID AND E_AD_Flag ='I' AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 0
				 
			SET @AD_Other_Amount = @Basic_Salary + ISNULL(@AD_Other_Amount,0)
			EXEC SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@AD_Other_Amount,@PT_Amount OUTPUT,'',@Branch_ID
		END
	
	IF @Increment_Type <> 'Joining'
		BEGIN
			-- This is temparory base. need to added on form side START
			SELECT 	@Emp_Early_mark = Emp_Early_mark, @Late_Dedu_Type = Late_Dedu_Type, @Emp_Late_Limit = Emp_Late_Limit
					,@Emp_Early_Limit = Emp_Early_Limit, @Early_Dedu_Type = Early_Dedu_Type , @Emp_wd_ot_rate = Emp_WeekDay_OT_Rate
					,@Emp_wo_ot_rate = Emp_WeekOff_OT_Rate, @Emp_ho_ot_rate = Emp_Holiday_OT_Rate 
					,@Old_Bank_Id = Bank_Id,@Old_Bank_Branch_Name = Bank_Branch_Name,@Old_Bank_ID_Two = Bank_ID_Two
					,@Old_Inc_Bank_AC_No_Two = Inc_Bank_AC_No_Two,@Old_Bank_Branch_Name_Two = Bank_Branch_Name_Two,@Old_Payment_Mode_Two = Payment_Mode_Two
					,@no_of_chlidren=i.Emp_Childran --added by Hardik 22/11/2017
					,@Old_Emp_Part_time = Emp_Part_Time
				FROM T0095_INCREMENT i WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Increment_ID) Increment_ID, Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE increment_effective_Date <= @Increment_Effective_Date AND emp_ID = @Emp_ID 
									GROUP BY emp_ID
								) Q 
					ON i.emp_ID = Q.emp_ID AND i.Increment_ID = q.Increment_ID 
			-- This is temparory base. need to added on form side END
			
			--For Update Old Bank Detail --Ankit 27062014
			IF @Bank_ID = 0
				SET @Bank_ID = @Old_Bank_Id
			IF @Bank_Branch_Name = ''
				Set @Bank_Branch_Name = @Old_Bank_Branch_Name
			IF @Bank_ID_Two = 0
				SET @Bank_ID_Two = @Old_Bank_ID_Two
			IF @Inc_Bank_AC_No_Two = ''
				Set @Inc_Bank_AC_No_Two = @Old_Inc_Bank_AC_No_Two
			IF 	@Bank_Branch_Name_Two = ''
				Set @Bank_Branch_Name_Two = @Old_Bank_Branch_Name_Two
			IF @Payment_Mode_Two = ''
				Set @Payment_Mode_Two = @Old_Payment_Mode_Two 	
			if @Emp_Part_Time = 0  --Added by Jaina 12-01-2019
				set @Emp_Part_Time = @Old_Emp_Part_time
			--For Update Old Bank Detail --Ankit 27062014	
		END
	
	IF ISNULL(@Increment_ID,0) = 0
		BEGIN
		
			 IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0
				BEGIN
					RAISERROR('@@Same Date Entry Exists@@',16,2)
					RETURN
				END
				
			--IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT  WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date)
			--	BEGIN
			--		RAISERROR('@@Same Date Entry Exists@@',16,2)
			--		RETURN
			--	END
					
			--else if Exists(Select Increment_ID From dbo.T0095_INCREMENT Where Emp_ID = @Emp_ID and Increment_effective_Date > @Increment_effective_Date)
			--	begin
			--		--Raiserror('Max Date Entry Exists',16,2)
			--		return
			--	end
				
			SELECT @Increment_ID = ISNULL(MAX(Increment_ID),0) + 1 FROM dbo.T0095_INCREMENT WITH (NOLOCK)
			
			-- -- Commented By Hiral 14 August, 2013 (Start)
			--IF @Salary_Cycle_id = 0
			--	BEGIN		
			--		SELECT @Salary_Cycle_id = tran_id FROM t0040_salary_cycle_master WHERE cmp_id = @cmp_id
						
			--		IF ISNULL(@Salary_Cycle_id,0) <> 0
			--			BEGIN
			--				INSERT INTO T0095_Emp_Salary_Cycle
			--					  ( Cmp_id, Emp_id, SalDate_id, Effective_date) 							
			--					VALUES (@Cmp_id,@Emp_id,@Salary_Cycle_id,@Increment_Effective_Date)
			--			END
			--	END		
			-- -- Commented By Hiral 14 August, 2013 (End)
				
			-- Added By Hiral 14 August, 2013 (Start) 
			If Isnull(@Salary_Cycle_id,0) > 0
				Begin
					If Exists(Select 1 From T0095_Emp_Salary_Cycle WITH (NOLOCK) Where Cmp_ID = @Cmp_id And Emp_Id = @Emp_id And Effective_date = @Temp_Effective_date)
						Begin
							Update T0095_Emp_Salary_Cycle
								Set SalDate_id = @Salary_Cycle_id
								Where Cmp_ID = @Cmp_id And Emp_Id = @Emp_id And Effective_date = @Temp_Effective_date
						End
					Else
						Begin
							INSERT INTO T0095_Emp_Salary_Cycle
									  (Cmp_id, Emp_id, SalDate_id, Effective_date)
								VALUES (@Cmp_id,@Emp_id,@Salary_Cycle_id,@Temp_Effective_date)
						End
				End
			-- Added By Hiral 14 August, 2013 (End)

			--Added By Jimit 16102019
			Select	@Fix_OT_Hour_Rate_WD = Fix_OT_Hour_Rate_WD,
					@Fix_OT_Hour_Rate_WO_HO = Fix_OT_Hour_Rate_WO_HO 
			from	T0095_INCREMENT INC WITH (NOLOCK) INNER JOIN 
					(
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 	
						FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID INNER JOIN 
								(
									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
									FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
									WHERE	I3.Increment_effective_Date <= @Increment_Effective_Date AND I3.Cmp_ID = @Cmp_ID	
									GROUP BY I3.EMP_ID 
								 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
						GROUP BY I2.Emp_ID 
					) I ON INC.Emp_ID = I.Emp_ID AND INC.Increment_ID = I.Increment_ID
			where INC.Emp_ID=@Emp_ID and Cmp_Id = @Cmp_ID and increment_effective_date <= @Increment_Effective_Date  
			--Ended

			--Select 123
			
			--INSERT INTO dbo.T0095_INCREMENT
			--		(Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,Emp_Late_Limit,Emp_PT_Amount,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, Pre_CTC_Salary ,Incerment_Amount_gross,Incerment_Amount_CTC,Increment_Mode,Emp_Childran,Is_Metro_City,is_physical,salDate_id,Emp_Auto_Vpf,Segment_ID,Vertical_ID,SubVertical_ID,SubBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Bank_Branch_Name,Bank_Branch_Name_Two,Inc_Bank_AC_No_Two,Reason_ID,Reason_Name,Customer_Audit , Sales_Code,Physical_Percent,Is_Piece_Trans_Salary)
			--	VALUES (@Increment_ID,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary,@Increment_Type,@Increment_Date,@Increment_Effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Pre_Basic_Salary,@Pre_Gross_Salary,@Increment_Comments,@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_part_Time,@Late_Dedu_type,@Emp_Late_Limit,@PT_Amount,@Is_Master_Rec,@User_Id,GETDATE(),@Yearly_Bonus_Amount,@Deputation_End_Date,@CTC,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID,@Emp_wd_ot_rate,@Emp_wo_ot_rate,@Emp_ho_ot_rate, @Pre_CTC_Salary ,@Incerment_Amount_gross,@Incerment_Amount_CTC,@Increment_Mode,@no_of_chlidren ,@is_metro ,@is_physical,@Salary_Cycle_id,@auto_vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,@Payment_Mode_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,@Inc_Bank_AC_No_Two,@Reason_ID,@Reason_Name,@Customer_Audit , @Sales_Code,@Physical_Percent,@Piece_TransSalary) -- Added By Ali 14112013  ''Added By Jaina 22-08-2016 (Customer_audit)
			
			INSERT INTO dbo.T0095_INCREMENT
					(Increment_ID,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,Emp_Late_Limit,Emp_PT_Amount,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, Pre_CTC_Salary ,Incerment_Amount_gross,Incerment_Amount_CTC,Increment_Mode,Emp_Childran,Is_Metro_City,is_physical,salDate_id,Emp_Auto_Vpf,Segment_ID,Vertical_ID,SubVertical_ID,SubBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Bank_Branch_Name,Bank_Branch_Name_Two,Inc_Bank_AC_No_Two,Reason_ID,Reason_Name,Customer_Audit , Sales_Code,Physical_Percent,Is_Piece_Trans_Salary)
				VALUES (@Increment_ID,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary,@Increment_Type,@Increment_Date,@Increment_Effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Pre_Basic_Salary,@Pre_Gross_Salary,@Increment_Comments,@Emp_Late_mark,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,@Emp_part_Time,'Day',@Emp_Late_Limit,@PT_Amount,@Is_Master_Rec,@User_Id,GETDATE(),@Yearly_Bonus_Amount,@Deputation_End_Date,@CTC,@Emp_Early_mark,'Day',@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type,@Emp_Deficit_Limit,@Center_ID,@Emp_wd_ot_rate,@Emp_wo_ot_rate,@Emp_ho_ot_rate, @Pre_CTC_Salary ,@Incerment_Amount_gross,@Incerment_Amount_CTC,@Increment_Mode,@no_of_chlidren ,@is_metro ,@is_physical,@Salary_Cycle_id,@auto_vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,'Cheque',@Bank_Branch_Name,@Bank_Branch_Name_Two,@Inc_Bank_AC_No_Two,@Reason_ID,@Reason_Name,@Customer_Audit , @Sales_Code,@Physical_Percent,@Piece_TransSalary)
			
			/*Commented by Nimesh on 12-Feb-2019 (Method Updated)*/
			--Added By Mukti 01-07-2016(Start)					
			set @Tran_Type = 'I'						
			--exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
			--set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti 01-07-2016(End)		
			
										
			IF (@Dep_Amount>0 AND @Dep_Month>0 AND @Dep_Year>0) OR (@Set_Amount>0 AND @Set_Month>0 AND @Set_Year>0)
				BEGIN 							
				    EXEC P0190_Monthly_AD_Detail_DepSett @Cmp_ID,@Emp_ID,@Increment_ID,@Dep_Amount,@Dep_Month,@Dep_Year,@Set_Amount,@Set_Month,@Set_Year 							
				END	

			
			---Commented below code by Hardik 12/09/2018 discuss with Nimesh as this code is not required now.
			/*
					
			------------------------------------------- added by mitesh on 13072012
				
			IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT WHERE Emp_ID = @Emp_ID AND Increment_effective_Date > @Increment_effective_Date AND (Increment_Type = 'Transfer' OR  Increment_Type = 'Deputation'))
				BEGIN						
					DECLARE @Inc_Table TABLE
					(
						inc_id NUMERIC,
						increment_type NVARCHAR(20)
					)
					
					INSERT INTO @Inc_table
						SELECT Increment_ID,Increment_Type FROM dbo.T0095_INCREMENT WHERE Emp_ID = @Emp_ID AND Increment_effective_Date > @Increment_effective_Date 
					
					DECLARE @Inc_id_update NUMERIC
					DECLARE @Inc_flag NUMERIC
					DECLARE @inc_type_update NVARCHAR(20)
					SET @Inc_id_update = 0
					SET @inc_type_update = ''
					SET @Inc_flag = 0
					
					DECLARE cur_inc CURSOR 
					FOR	SELECT inc_id,increment_type FROM @Inc_Table 
					OPEN cur_inc                      
					FETCH NEXT FROM cur_inc INTO @Inc_id_update,@inc_type_update
					WHILE @@FETCH_STATUS = 0                    
						BEGIN							
							IF @inc_type_update = 'Increment'
								BEGIN
									SET @Inc_flag = 1
								END
							ELSE IF @Inc_flag = 0 
								BEGIN
								--Added By Mukti 01-07-2016(Start)					
									set @Tran_Type = 'U'						
									exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
									set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
								--Added By Mukti 01-07-2016(End)
								
									
									UPDATE dbo.T0095_INCREMENT
										SET Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
											  Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, 
											  Payment_Mode = @Payment_Mode, 
											  Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, 
											  Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
											  Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
											  Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
											  Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
											  Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder,
											  CTC = @CTC,
											  Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,
											  Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type	,Emp_Deficit_Limit=@Emp_Deficit_Limit,
											  Center_ID=@Center_ID,
											  Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate
											  ,Pre_CTC_Salary = @Pre_CTC_Salary ,Increment_Mode = @Increment_Mode
											  ,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical
											  ,salDate_id = @Salary_Cycle_id, Emp_Auto_Vpf=@Auto_Vpf --rohit 18072013
											  ,Segment_ID =@Segment_ID			-- Added By Gadriwala Muslim 24072013
											  ,Vertical_ID =@Vertical_ID		-- Added By Gadriwala Muslim 24072013
											  ,SubVertical_ID = @SubVertical_ID -- Added By Gadriwala Muslim 24072013
											  ,subBranch_ID = @subBranch_ID
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
											  ,Customer_Audit = @Customer_Audit						-- Added by Jaina 22-08-2016
											  ,Sales_Code = @Sales_Code								-- Added By Ramiz 07122016
											  ,Physical_Percent = @Physical_Percent
										WHERE Increment_ID = @Inc_id_update  AND Emp_ID = @Emp_ID



								--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
								--Added By Mukti 01-07-2016(End)		
									IF ISNULL(@Salary_Cycle_id,0) <> 0
										BEGIN
											IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WHERE Emp_id = @Emp_ID)
												BEGIN																	
													INSERT INTO T0095_Emp_Salary_Cycle
															  (Cmp_id, Emp_id, SalDate_id, Effective_date)
															VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)	-- Added By Hiral 16 August, 2013
													-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)	-- Commented By Hiral 16 August, 2013
												END
											ELSE
												BEGIN
													UPDATE  T0095_Emp_Salary_Cycle
													SET   SalDate_id = @Salary_Cycle_id 
													WHERE	Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID		-- Added By Hiral 16 August, 2013
													-- WHERE	Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID		-- Commented By Hiral 16 August, 2013
												END
										END
									DELETE T0100_EMP_EARN_DEDUCTION WHERE INCREMENT_ID = @Inc_id_update
										
								END
								FETCH NEXT FROM cur_inc INTO @Inc_id_update,@inc_type_update
						END                    
					CLOSE cur_inc                    
					DEALLOCATE cur_inc
					--drop table @Inc_Table
				END
				------------------------------------------- above added by mitesh on 13072012	
				*/
		END
	ELSE 
		BEGIN
			IF EXISTS (SELECT Emp_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID =@Increment_ID AND ISNULL(Is_Master_Rec,0) = 1)
				BEGIN
					IF ISNULL(@Is_Emp_Master,0)=1
						BEGIN
							--Added By Mukti 01-07-2016(Start)					
							set @Tran_Type = 'U'						
							exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
							set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)	
										
							UPDATE dbo.T0095_INCREMENT
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
									Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
									Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @User_Id,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder,
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
									,Is_Piece_Trans_Salary = @Piece_TransSalary			-- Added  by deepal 05-01-2021
								WHERE Increment_ID = @Increment_ID  AND Emp_ID = @Emp_ID
								
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)		
							
							IF ISNULL(@Salary_Cycle_id,0) <> 0
								BEGIN
									IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID)
										BEGIN																	
											INSERT INTO T0095_Emp_Salary_Cycle
													(Cmp_id, Emp_id, SalDate_id, Effective_date)
												VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Temp_Effective_date)		-- Added By Hiral 16 August, 2013
												-- VALUES (@Cmp_ID,@Emp_ID,@Salary_Cycle_id,@Increment_Effective_Date)		-- Commented By Hiral 16 August, 2013
										END
									ELSE
										BEGIN
											UPDATE T0095_Emp_Salary_Cycle
												SET SalDate_id = @Salary_Cycle_id 
												WHERE Effective_date = @Temp_Effective_date AND Emp_ID = @Emp_ID	-- Added By Hiral 16 August, 2013
												-- WHERE Effective_date = @Increment_Effective_Date AND Emp_ID = @Emp_ID		-- Commented By Hiral 16 August, 2013
										END
								END
						END 
						
					ELSE
						BEGIN
							 IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date) AND @Allow_Same_Date_Increment = 0 AND @Increment_Type <> 'Transfer'
								BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN
								END
							--Added By Mukti 01-07-2016(Start)					
								set @Tran_Type = 'U'						
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)
								
							UPDATE dbo.T0095_INCREMENT
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type, 
									Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary, 
									Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @User_Id,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder,
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
									 ,Is_Piece_Trans_Salary = @Piece_TransSalary
								WHERE Increment_ID = @Increment_ID  AND Emp_ID = @Emp_ID
							
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)					
							
								IF ISNULL(@Salary_Cycle_id,0) <> 0
									BEGIN
										IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID)
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
						END	
				END
			ELSE
				BEGIN
					--select @Increment_Effective_Date = Increment_Effective_Date  , @Increment_Date = Increment_Date From dbo.T0095_INCREMENT Where Increment_ID =@Increment_ID
					-- commented by mitesh on 20/12/2011
					--Select @Pre_Basic_Salary = Basic_Salary ,@Pre_Gross_Salary = Gross_Salary 
					--		from dbo.T0095_INCREMENT I inner join (select Emp_ID ,max(Increment_Effective_Date)Increment_Effective_Date From dbo.T0095_INCREMENT 
					--											where Emp_ID =@Emp_ID and Increment_Effective_Date < @Increment_Effective_Date group by Emp_ID )q on
					--												I.Emp_ID= q.Emp_ID and i.Increment_Effective_Date = q.Increment_Effective_Date
																		
					IF @Increment_Type = 'Joining'																						
						BEGIN
							
							SELECT @Pre_Basic_Salary = Pre_Basic_Salary ,@Pre_Gross_Salary = ISNULL(Pre_Gross_Salary,0) --Gross_Salary --Commented and Added By Ramiz on 11/05/2016 as it was Updating Wrong Gross when Employee is Updated from Employee master
								FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID = @Increment_ID
								
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
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti 01-07-2016(End)
						
							UPDATE dbo.T0095_INCREMENT
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
									Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @User_Id,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Is_Deputation_Reminder=@Dep_Reminder,
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
									 ,Is_Piece_Trans_Salary = @Piece_TransSalary
								WHERE Increment_ID = @Increment_ID  AND Emp_ID = @Emp_ID
						
						--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti 01-07-2016(End)			
						
						--Commented by Hardik 12/09/2018 discuss with Nimesh as below code not required now
						/*
						-- Added by rohit for Bank detail not Update if transfer given  08102015
						if  Exists (select Emp_id from t0095_increment where Increment_ID = @Increment_ID  and (increment_type='Transfer' or increment_type='Deputation' ))
							begin
							Declare @increment_Without_transfer as numeric(18,0)
							set @increment_Without_transfer = 0
							select @increment_Without_transfer = MAX(increment_id) from T0095_INCREMENT where Increment_Effective_Date <= @Increment_Effective_Date and increment_type <> 'Transfer' and increment_type <> 'Deputation' and Emp_ID = @Emp_ID 
							update T0095_INCREMENT 
							set Bank_ID = @Bank_ID
								,Payment_Mode = @Payment_Mode
								,Inc_Bank_AC_No = @Inc_Bank_AC_No
								,Bank_Branch_Name = @Bank_Branch_Name
								
							WHERE Increment_ID = @increment_Without_transfer  AND Emp_ID = @Emp_ID
						end
						--ended by rohit on 08102015	
						*/
								
							IF ISNULL(@Salary_Cycle_id,0) <> 0
								BEGIN
									IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID)
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
						END
					ELSE
						BEGIN
						
							 IF EXISTS(SELECT Increment_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Increment_effective_Date= @Increment_effective_Date AND Increment_ID <> @Increment_ID ) AND @Allow_Same_Date_Increment = 0 AND @Increment_Type <> 'Transfer'
								BEGIN
									RAISERROR('@@Same Date Entry Exists@@',16,2)
									RETURN
								END
							
						--Added By Mukti 01-07-2016(Start)					
						set @Tran_Type = 'U'	
						exec P9999_Audit_get @table='T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))				
						--Added By Mukti 01-07-2016(End)	
						
							UPDATE  dbo.T0095_INCREMENT
								SET Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID, 
									Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type, 
									Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary,Payment_Mode = @Payment_Mode, 
									Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary ,
									Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,
									Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,
									Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,
									Login_ID = @User_Id,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder,
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
									 ,Is_Piece_Trans_Salary = @Piece_TransSalary
								WHERE Increment_ID = @Increment_ID  AND Emp_ID = @Emp_ID
							
							--Added By Mukti 01-07-2016(Start)				
								exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
							--Added By Mukti 01-07-2016(End)	
									
								IF ISNULL(@Salary_Cycle_id,0) <> 0
									BEGIN
										IF NOT EXISTS (SELECT 1 FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID)
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
						END
				END
		
			IF (@Dep_Amount>0 AND @Dep_Month>0 AND @Dep_Year>0) OR (@Set_Amount>0 AND @Set_Month>0 AND @Set_Year>0)
				BEGIN 							
					EXEC P0190_Monthly_AD_Detail_DepSett @Cmp_ID,@Emp_ID,@Increment_ID,@Dep_Amount,@Dep_Month,@Dep_Year,@Set_Amount,@Set_Month,@Set_Year 							
				END			
		END
	
	--- Update latest record in Employee Master 

	SELECT @Max_Increment_ID = I.Increment_ID, @Increment_Effective_Date = I.Increment_Effective_Date 
		FROM dbo.T0095_INCREMENT I WITH (NOLOCK)
			INNER JOIN (SELECT MAX(Increment_ID)Increment_ID, Emp_ID FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID=@Emp_ID GROUP BY emp_ID)Q 
			ON i.Emp_ID= q.Emp_ID  AND i.Increment_ID =q.Increment_ID
							
	--Added by Falak on 19-APR-2011
	ALTER TABLE T0080_Emp_Master DISABLE TRIGGER ALL
	
	UPDATE T0080_Emp_Master 
		SET Increment_Id =@Max_Increment_ID	
		,System_Date = GETDATE()
			--,emp_superior=@emp_superior			
		WHERE Emp_ID =@Emp_ID 
		
	IF ISNULL(@emp_superior,0) <> 0
		BEGIN
			UPDATE	T0080_Emp_Master 
			SET		emp_superior=@emp_superior
			WHERE	Emp_ID =@Emp_ID 
		END
	
	ALTER TABLE T0080_Emp_Master Enable TRIGGER ALL
	UPDATE T0100_EMP_EARN_DEDUCTION 
		SET	FOR_DATE = @Increment_Effective_Date
		WHERE Emp_ID = @Emp_ID AND Increment_Id = @Increment_ID
	
	--zalak for manager history
	EXEC P0100_Emp_Manager_History 0,@Cmp_ID,@Emp_ID,@Increment_ID,@emp_superior,@Increment_Effective_Date
	----------------------------------------------
	--add by Krushna 05-04-2018
	UPDATE E
		SET		Branch_ID = @Branch_ID
		FROM	T9999_EMPLOYEE_ENROLLMENT E 
			INNER JOIN T0080_EMP_MASTER EM ON E.Enroll_No=EM.Enroll_No
		WHERE	EM.Emp_ID=@Emp_ID
	--end Krushna
	--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Increment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1 --added By Mukti 01072016

	--For New Values in Audit Trail
	SELECT * INTO #T0095_INCREMENT_INSERTED FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID=@Increment_ID
	
	
	EXEC P9999_AUDIT_LOG @TableName='T0095_INCREMENT', @IDFieldName='Increment_ID',@Audit_Module_Name='Employee Increment',
				@User_Id=@User_Id,@IP_Address=@IP_Address,@MandatoryFields='Increment_Date,Increment_Type,Increment_Effective_Date',
			@Audit_Change_Type=@Tran_Type	
	

RETURN
