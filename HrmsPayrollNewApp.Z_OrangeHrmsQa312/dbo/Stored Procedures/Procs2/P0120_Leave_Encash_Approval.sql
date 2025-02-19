CREATE PROCEDURE [dbo].[P0120_Leave_Encash_Approval]
	@Lv_Encash_Apr_ID		Numeric output
   ,@Lv_Encash_App_ID		Numeric
   ,@Cmp_ID					Numeric
   ,@Emp_ID					Numeric
   ,@Leave_ID				Numeric
   ,@Lv_Encash_Apr_Days		Numeric(18,4)
   ,@Lv_Encash_Apr_Code		Varchar(50)
   ,@Lv_Encash_Apr_Date		Datetime
   ,@Lv_Encash_Apr_Status	Char(1)
   ,@Lv_Encash_Apr_Comments Varchar(250)
   ,@Login_ID				Numeric
   ,@System_Date			Datetime
   ,@tran_type				Varchar(1)
   ,@Is_FNF					Int = 0
   ,@Eff_In_Salary			tinyInt = 1
   ,@Upto_Date				DateTime = null
   ,@CompOffString			varchar(max) = '' -- Added by Gadriwala Muslim 02102014
   ,@Lv_Encash_Balance numeric(18,2) = 0 -- Added by Gadriwala Muslim 02102014
   ,@User_Id numeric(18,0) = 0  --Mukti(02072016)
   ,@Effect_Date				Date = null
   ,@IP_Address varchar(30)= '' --Mukti(02072016)
   ,@Leave_Recover Numeric(18,2) = 0
   ,@IsTaxFree				tinyint = 0 --Added By Jimit 12022018
AS	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @str_Emp_Code as varchar(5)
	DECLARE @Emp_Code as varchar(5)		

	IF @Lv_Encash_App_ID = 0 
		SET @Lv_Encash_App_ID=null
		  
	Declare @Max_No_Of_Application numeric(18, 0)
	Declare @L_Enc_Percentage_Of_Current_Balance numeric(18, 2)
	Declare @Total_Application numeric(18, 0)
	Declare @Enc_Days numeric(18, 4)
	Declare @For_Date_Encash datetime
	Declare @Encashment_After_Months numeric(18, 4)	
	Declare @Date_Of_Join datetime
	DECLARE @Apply_Hourly NUMERIC  ---Added by Sid for Apply hourly 31032014
	Declare @Default_Short_Name  varchar(25) -- Added by Gadriwala Muslim 02102014
	Declare @Min_Leave_Encash numeric(18,2) -- Added by Gadriwala Muslim 02102014
	Declare @Max_Leave_Encash numeric(18,2) -- Added by Gadriwala Muslim 02102014
	Declare @Bal_After_Encash numeric(18,2) -- Added by Gadriwala Muslim 02102014
	Declare @Temp_Lv_Encash_W_Day as numeric(18,2)
	DECLARE @Leave_EncashDay_Half_Payment	AS TINYINT	--Ankit 04022016
	SET @Leave_EncashDay_Half_Payment = 0
	declare @setting_Value as tinyint=0
	Declare @Year as numeric
	Declare @date as varchar(20)

	Declare @Lv_Encash_Apr_Hours Numeric(18,4) -- Added by Hardik 19/11/2019 for Hourly Compoff Case, Client : Diamines


	Declare @First_Min_Bal_then_Percent_Curr_Balance tinyint
	Set @First_Min_Bal_then_Percent_Curr_Balance = 0

	--Added By Mukti(start)02072016
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	SET @String=''
	SET @OldValue =''
	--Added By Mukti(end)02072016
	
	IF Exists(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Month_St_Date <= @Lv_Encash_Apr_Date and Month_End_Date >= @Lv_Encash_Apr_Date and IsNull(@Eff_In_Salary,0) = 1) 
		Begin
			Raiserror('@@This Month Salary Exists@@',16,2)
			return -1
		End

	select @setting_Value=IsNull(setting_value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@CMP_ID and Setting_Name='Display Leave Detail by Selected Period'

	-- Added by Ali 17042014 -- Start
	declare @E_date as varchar(20)
	SET @Year = YEAR(GETDATE())		
	IF (@setting_Value=0 or @setting_Value=1)
		Begin			
			SET @date = '01-Jan-'+ convert(varchar(5),@Year)
			SET @E_date = '31-Dec-'+convert(varchar(5),@Year)
		End
	ELSE
		Begin
			IF MONTH(GETDATE()) > 3
			BEGIN
				SET @Year = @Year + 1
			END		
			SET @date = '31-Mar-'+ convert(varchar(5),@Year)
		End
		
	DECLARE @START_YEAR DATETIME;
	DECLARE @END_YEAR DATETIME;

	DECLARE @Branch_ID  NUMERIC
	DECLARE @Sal_St_Date DATETIME
	DECLARE @Sal_End_Date DateTime
	Declare @Emp_Left_Date Datetime -- Added by Hardik for cera 
	
	if @Is_FNF = 1
		BEGIN
			Select @Emp_Left_Date = Emp_Left_Date From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_Id = @Emp_Id --- Added by Hardik 24/02/2020 for Cera as same month encash taking last month's end date.. it should encash on left date
			If @Lv_Encash_Apr_Date > @Emp_Left_Date
				Begin

					SELECT	@Branch_ID = Branch_ID
					FROM	dbo.fn_getEmpIncrement(@Cmp_ID,@Emp_ID,@Lv_Encash_Apr_Date)

 
					SELECT	@Sal_St_Date  =Sal_st_Date 
					FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK) 
					WHERE	cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID AND 
							For_Date = (SELECT	MAX(For_Date) 
										FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
										WHERE	For_Date <= @Lv_Encash_Apr_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
						
					SET @Sal_St_Date =  CAST(CAST(DAY(@Sal_St_Date)as VARCHAR(5)) + '-' + CAST(datename(mm,DateAdd(m,-1,@Lv_Encash_Apr_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DateAdd(m,-1,@Lv_Encash_Apr_Date) )as VARCHAR(10)) AS smalldatetime)    				
					SET @Sal_End_Date = DateAdd(d,-1,DateAdd(m,1,@Sal_St_Date)) 		   
					SET @Lv_Encash_Apr_Date = @Sal_End_Date
				End			
		END
		
	--Comment by Jaina 18-07-2017
	--SET @END_YEAR = CAST(@date AS DATETIME)
	--SET @START_YEAR = DATEADD(d, 1,DATEADD(yyyy, -1, @END_YEAR))
	SET @START_YEAR =  CAST(@date AS DATETIME)
		
	SET @END_YEAR = cast(@E_date as datetime)
		--select @date
		
	select	@Max_No_Of_Application = t.Max_No_Of_Application,@L_Enc_Percentage_Of_Current_Balance = t.L_Enc_Percentage_Of_Current_Balance,
			@Encashment_After_Months = t.Encashment_After_Months, @Default_Short_Name = IsNull(Default_Short_Name,''), --changed by gadriwala Muslim 02102014
			@Min_Leave_Encash = Min_Leave_Encash,@Max_Leave_Encash = Max_Leave_Encash,@Bal_After_Encash = Bal_After_Encash 
			,@First_Min_Bal_then_Percent_Curr_Balance = First_Min_Bal_then_Percent_Curr_Balance 
	from	((select case when IsNull(temp.Max_No_Of_Application,0)=0 then lm.Max_No_Of_Application ELSE temp.Max_No_Of_Application end as Max_No_Of_Application,
					 case when IsNull(temp.L_Enc_Percentage_Of_Current_Balance,0)=0 then lm.L_Enc_Percentage_Of_Current_Balance ELSE temp.L_Enc_Percentage_Of_Current_Balance end as L_Enc_Percentage_Of_Current_Balance
					,case when IsNull(temp.Encash_Appli_After_month,0)=0 then lm.Encashment_After_Months  ELSE temp.Encash_Appli_After_month end as Encashment_After_Months		
					,IsNull(Default_Short_Name,'') as Default_Short_Name -- Added by Gadriwala Muslim 02102014
					,case when IsNull(temp.Min_Leave_Encash,0)=0 then lm.Leave_Min_Encash  ELSE temp.Min_Leave_Encash end as Min_Leave_Encash	-- Added by Gadriwala Muslim 02102014	
					,case when IsNull(temp.Max_Leave_Encash,0)=0 then lm.Leave_Max_Encash  ELSE temp.Max_Leave_Encash end as Max_Leave_Encash	-- Added by Gadriwala Muslim 02102014	
					,case when IsNull(temp.Bal_After_Encash,0)=0 then lm.Leave_Min_Bal  ELSE temp.Bal_After_Encash end as Bal_After_Encash	-- Added by Gadriwala Muslim 02102014	
					,LM.First_Min_Bal_then_Percent_Curr_Balance
			from	T0040_Leave_MASTER LM WITH (NOLOCK)
					left join (	Select Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encash_Appli_After_month,Leave_ID, Max_Leave_Encash,Min_Leave_Encash,Bal_After_Encash 
								from T0050_LEAVE_DETAIL WITH (NOLOCK)
								where Leave_ID = @Leave_Id 
										and Cmp_ID = @Cmp_ID and Grd_ID in (Select I.Grd_ID 
																			from   dbo.T0095_Increment I WITH (NOLOCK)
																					INNER JOIN  (SELECT		MAX(Increment_ID) AS Increment_ID , Emp_ID 
																								 FROM		dbo.T0095_Increment IM	WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
																								 WHERE		Increment_Effective_date <= @date 
																								 GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID 
																					INNER JOIN dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
																			where	em.Cmp_ID = @Cmp_Id and em.Emp_ID = @Emp_Id
																			)
							 ) as temp on LM.leave_id = temp.leave_id 
			where	LM.Leave_ID = @Leave_Id and Leave_Type = 'Encashable' 
			)) as t
		
	--Select @Max_No_Of_Application=Max_No_Of_Application, @L_Enc_Percentage_Of_Current_Balance=L_Enc_Percentage_Of_Current_Balance,@Encashment_After_Months=Encashment_After_Months from T0040_LEAVE_MASTER where Leave_ID=@leave_ID  	
		
	-- Added by Ali 17042014 -- End
	 

	IF @Max_No_Of_Application is null
		SET @Max_No_Of_Application = 0
	
	IF @L_Enc_Percentage_Of_Current_Balance is null
		SET @L_Enc_Percentage_Of_Current_Balance = 0 

	IF @Encashment_After_Months is null
		SET @Encashment_After_Months = 0 
	IF @Min_Leave_Encash is null	-- Added by Gadriwala Muslim 02102014
		SET @Min_Leave_Encash = 0 
	IF @Max_Leave_Encash is null -- Added by Gadriwala Muslim 02102014
		SET @Max_Leave_Encash = 0
	IF @Bal_After_Encash is null	-- Added by Gadriwala Muslim 02102014	
		SET @Bal_After_Encash = 0 


	---Added Below Condition by Hardik 08/08/2018 for Aatash, As they don't use this policy during F&F
	IF Isnull(@Is_FNF,0)=1
		BEGIN
			Set @L_Enc_Percentage_Of_Current_Balance = 0
			Set @Bal_After_Encash = 0
			Set @Min_Leave_Encash = 0
			Set @Max_Leave_Encash = 0
		END
	
 
	If	@Encashment_After_Months > 0 And Isnull(@Is_FNF,0)=0
		Begin
			Select @Date_Of_Join = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID
		
		
			IF DATEDIFF(d,@Date_Of_Join,getdate()) < DATEDIFF(d,@Date_Of_Join,DATEADD(m,@Encashment_After_Months,@Date_Of_Join))
				Begin
					Raiserror('@@You Cannot Encash Leave As Per Leave Policy@@',16,2)
					return -1
				End
		End
	--Added by Gadriwala 02102014 - Start	
	Declare @ErrorMsg as varchar(100)
	IF @Min_Leave_Encash > 0 and @is_fnf=0  --IS_FNF is Added by Ramiz on 24/02/2016
		begin
			IF @Min_Leave_Encash > @Lv_Encash_Apr_Days
				begin
					SET @ErrorMsg = '@@you cannot Encash Leave Less than '+ cast(@Min_Leave_Encash as varchar(10)) + ' As Per Leave Policy@@'
					RaisError(@ErrorMsg,16,2)
					return -1	
				end
		end
	IF @Max_Leave_Encash > 0 and @is_fnf=0  --added By Mukti condition @is_fnf=0 to save FNF details
		begin
			IF @Max_Leave_Encash < @Lv_Encash_Apr_Days
				begin
					SET @ErrorMsg = '@@you cannot Encash Leave More than '+ cast(@Max_Leave_Encash as varchar(10)) + ' As Per Leave Policy@@'
					RaisError(@ErrorMsg,16,2)
					return -1	
				end
		end	
	 --Added by Gadriwala 02102014 - End   
	 
	----Added by Jaina 10-11-2017 Start  
	 if exists (SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_ID and Leave_ID=@Leave_ID AND For_Date > @Upto_Date AND Leave_Encash_Days <> 0)
	 BEGIN		
				set @ErrorMsg = '@@You Cannot Encash Leave, Already Encash Leave after this date : ' + Cast(CONVERT(varchar,@Upto_Date,103) AS varchar) +'@@'
				RaisError(@ErrorMsg,16,2)
				return -1	
	 END
  ----Added by Jaina 10-11-2017 End
  
	SELECT @Apply_Hourly = Apply_Hourly,@Temp_Lv_Encash_W_Day = Lv_Encase_Calculation_Day,@Leave_EncashDay_Half_Payment = Leave_EncashDay_Half_Payment
	FROM T0040_leave_Master WITH (NOLOCK)
	WHERE Leave_ID = @Leave_ID 
		
	Select @Total_Application = count(Lv_Encash_Apr_ID) from T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK)
								where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Leave_ID=@leave_ID 
										and Lv_Encash_Apr_Status='A' 
										and Lv_Encash_Apr_Date BETWEEN @START_YEAR AND @END_YEAR

		IF @Apply_Hourly = 1
			BEGIN 
				Set @Lv_Encash_Apr_Hours = @Lv_Encash_Apr_Days --- Hardik 19/11/2019 for Diamines
				SET @Lv_Encash_Apr_Days = FLOOR(CAST(@Lv_Encash_Apr_Days AS FLOAT)/CAST(8 AS FLOAT)*16)/16
			end
	
		IF @Default_Short_Name = 'COMP' -- Added by Gadriwala 02102014 - Start
			BEGIN
				IF @L_Enc_Percentage_Of_Current_Balance > 0 
					BEGIN
						SET @Enc_DAys =  ((@Lv_Encash_Balance*@L_Enc_Percentage_Of_Current_Balance)/100)
						IF @Lv_Encash_Apr_Days > IsNull(@Enc_Days,0) and IsNull(@Enc_Days,0) > 0
							BEGIN
								SET @ErrorMsg = '@@you cannot Encash Leave More than '+ cast(@Enc_DAys as varchar(10)) + ' As Per Leave Policy@@'
								RaisError(@ErrorMsg,16,2)
								RETURN -1
							END
					END	
				IF @Bal_After_Encash > 0
					BEGIN
						IF @Bal_After_Encash > (@Lv_Encash_Balance- @Lv_Encash_Apr_Days)
							BEGIN
								SET @ErrorMsg = '@@After Encash, Leave Balance should be remaining '+ cast(@Bal_After_Encash as varchar(10)) + ' As Per Leave Policy@@'
								RaisError(@ErrorMsg,16,2)
								RETURN -1
							END
					END					
			END
		 ELSE		-- Added by Gadriwala 02102014 - End
			BEGIN	
				IF @L_Enc_Percentage_Of_Current_Balance > 0
					BEGIN
						SELECT	@For_Date_Encash = max(For_Date) 
						From	T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
						WHERE	Emp_ID = @Emp_ID
								AND FOR_DATE <=IsNull(@Upto_Date,getdate()) and Leave_ID=@Leave_id
						If @First_Min_Bal_then_Percent_Curr_Balance = 0
							BEGIN

								SELECT	@Enc_Days = ((LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100) 
								FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID 
													FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													WHERE	EMP_ID = @Emp_ID AND FOR_DATE <=@For_Date_Encash AND Leave_ID=@Leave_id 
													GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
										LEFT OUTER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
								WHERE Leave_Type='Encashable' --And (LT.Leave_Closing*@L_Enc_Percentage_Of_Current_Balance)/100 >= LM.Leave_Min_Bal 
				
								IF @Lv_Encash_Apr_Days > IsNull(@Enc_Days,0) and IsNull(@Enc_Days,0) > 0 
									SET @Lv_Encash_Apr_Days = @Enc_Days
							END	
						Else
							Begin
								SELECT @Enc_Days = dbo.F_Lower_Round((((LT.Leave_Closing - Leave_Min_Bal) * @L_Enc_Percentage_Of_Current_Balance)/100),LT.Cmp_ID) 
								FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner JOIN 
									( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@For_Date_Encash And Leave_ID=@Leave_Id
									GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
									LT.FOR_DATE = Q.FOR_DATE left outer JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
								where Leave_Type='Encashable' And LT.Leave_Closing >= Leave_Min_Bal And LT.Leave_ID = @Leave_ID	
							END
						
					END

				IF @Bal_After_Encash > 0 -- Added by Gadriwala Muslim 02102014
					BEGIN
						---Commented by Hardik 12/01/2018 As Balance is already passed from Parameter 
						
						--If @Lv_Encash_Balance = 0 --- Added by Hardik 31/03/2020 for Cera as direct leave encash, balance passing 0 so need to set again.
							BEGIN
								SELECT	@Lv_Encash_Balance = (LT.Leave_Closing)  
								FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID 
													FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													WHERE	EMP_ID = @Emp_ID AND FOR_DATE <=ISNULL(@UPTO_DATE,GETDATE()) AND Leave_ID=@Leave_id 
													GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
										LEFT OUTER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
								WHERE	Leave_Type='Encashable' And LT.Leave_id = @Leave_ID
							END
		
						--IF @Bal_After_Encash > @Enc_Days
						IF @Bal_After_Encash > (@Lv_Encash_Balance- @Lv_Encash_Apr_Days)
							BEGIN
								SET @ErrorMsg = '@@After Encash, Leave Balance should be remaining '+ CAST(@Bal_After_Encash AS VARCHAR(10)) + ' As Per Leave Policy@@'
								RaisError(@ErrorMsg,16,2)
								RETURN -1
							END
					END
			END
	
		-- Added by rohit for Leave Encash Amount on 24122015	
	
		declare @Increment_Id_New as numeric(18,0)
		declare @upto_Gross_Salary as numeric(18,2)
		declare @upto_Basic_Salary as numeric(18,2)
		declare @Type_Id as numeric(18,0)
		declare @Wages_Type as varchar(500)
		declare @SalaryBasis as varchar(500)
		declare @Allow_Effect_on_Leave as numeric(18,2)
		
		declare @OutOf_Days as numeric(18,2)
		--declare @Is_Cancel_Holiday as tinyint
		Declare @Is_Cancel_Weekoff as tinyint
		Declare @Lv_Encash_W_Day as numeric(18,2)
		Declare @chk_lv_on_working as tinyint
		Declare @Lv_Encash_Cal_On as varchar(500)
		Declare @IS_ROUNDING as tinyint
		Declare @Holiday_days as numeric(18,2)
		Declare @WeekOff_Days as numeric(18,2)
		Declare @Inc_Weekoff as numeric(18,2)
		Declare @Inc_holiday as numeric(18,2)
		Declare @Working_Days as numeric(18,2)
		Declare @Day_Salary as numeric(18,2)
		declare @Gross_Salary_ProRata as numeric(18,2)
		Declare @Salary_Amount as numeric(18,2)
		Declare @Encashment_Rate as numeric(18,2)
		DECLARE @Temp_Date as Datetime
		DECLARE @GRD_ID as numeric
		DECLARE @Grade_BasicSalary as numeric(18,2)
	
		SET @Temp_Date = IsNull(@upto_date,@Lv_Encash_Apr_Date)
	
	
		-- commeneted and added by rohit on 04032016
		--select @upto_Basic_Salary = Basic_Salary,@upto_Gross_Salary = Gross_Salary,@Increment_Id_New = I.Increment_ID,@Type_Id=I.Type_ID,@Branch_ID=I.Branch_ID,
		--@Wages_Type=Wages_Type,@SalaryBasis=Salary_Basis_On 
		--		from dbo.T0095_Increment I inner join 
		--				( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
		--				where Increment_Effective_date <= @Temp_Date
		--				and Cmp_ID = @Cmp_ID
		--				group by emp_ID  ) Qry on
		--				I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
		--		Where I.Emp_ID = @Emp_ID
		
		SELECT	@upto_Basic_Salary = Basic_Salary,@upto_Gross_Salary = Gross_Salary,@Increment_Id_New = I.Increment_ID,@Type_Id=I.Type_ID,@Branch_ID=I.Branch_ID,
				@Wages_Type=Wages_Type,@SalaryBasis=Salary_Basis_On , @GRD_ID = I.Grd_ID
		FROM	dbo.T0095_Increment I WITH (NOLOCK)
				INNER JOIN (SELECT	MAX(TI.Increment_ID) Increment_Id,ti.Emp_ID 
							FROM	T0095_INCREMENT TI WITH (NOLOCK)
									INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date,Emp_ID 
												FROM	T0095_Increment WITH (NOLOCK)
												WHERE	Increment_effective_Date <= @Temp_Date 
												and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'  --Added by Jaina 18-12-2017 (After Discuss with Hardikbhai)
												GROUP BY emp_ID) new_inc ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							WHERE	TI.Increment_effective_Date <= @Temp_Date 
							GROUP BY ti.emp_id) Qry ON I.Increment_Id = Qry.Increment_Id
		WHERE	I.Emp_ID = @Emp_ID
		-- ended by rohit on 04032016
	
		SELECT	@Grade_BasicSalary = IsNull(Fix_Basic_Salary,0) 
		FROM	T0040_GRADE_MASTER WITH (NOLOCK)
		WHERE	Grd_ID = @Grd_Id	--Added By Ramiz on 02062016		
		--Hardik 01/05/2012											
		--Select @Allow_Effect_on_Leave = SUM(E_AD_AMOUNT) from dbo.T0100_EMP_EARN_DEDUCTION EED 
		--	Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
		--Where INCREMENT_ID = @Increment_Id_New And EMP_ID = @Emp_Id And IsNull(AM.AD_EFFECT_ON_LEAVE,0) = 1
			
		--Select @Allow_Effect_on_Leave = SUM(Qry1.E_AD_AMOUNT) from
		--(
		--select Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT ELSE Qry1.E_AD_AMOUNT End As E_AD_AMOUNT
		--from dbo.T0100_EMP_EARN_DEDUCTION EED 
		--			Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
		--			LEFT OUTER JOIN
		--			( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
		--				From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
		--				( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
		--					Where Emp_Id = @Emp_Id
		--					And For_date <= IsNull(@upto_date,@Lv_Encash_Apr_Date)
		--				 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
		--			) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
		--		Where INCREMENT_ID = @Increment_Id_New And EED.EMP_ID = @Emp_Id And IsNull(AM.AD_EFFECT_ON_LEAVE,0) = 1
		--		And Case When Qry1.ENTRY_TYPE IS null Then '' ELSE Qry1.ENTRY_TYPE End <> 'D'

		--UNION ALL			

		--SELECT E_Ad_Amount
		--	FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
		--		( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
		--			Where Emp_Id  = @Emp_Id And For_date <= IsNull(@upto_date,@Lv_Encash_Apr_Date) 
		--			Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
		--	   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
		--	WHERE emp_id = @emp_id 
		--			And Adm.AD_ACTIVE = 1
		--			And EEd.ENTRY_TYPE = 'A'
		--			And IsNull(ADM.AD_EFFECT_ON_LEAVE,0) = 1
		--			) Qry1
			
		Create table #Tbl_Get_AD
		(
			Emp_ID numeric(18,0),
			Ad_ID numeric(18,0),
			for_date datetime,
			E_Ad_Percentage numeric(18,5),
			M_Ad_Amount numeric(18,2)
		)

		INSERT INTO #Tbl_Get_AD
		EXEC P_Emp_Revised_Allowance_Get @Cmp_ID,@Temp_Date,@Emp_Id, @GRD_ID , @Grade_BasicSalary

		SELECT	@Allow_Effect_on_Leave = SUM(M_Ad_Amount) 
		FROM	#Tbl_Get_AD EED 
				INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID 
		WHERE	EED.EMP_ID = @Emp_Id AND IsNull(AM.AD_EFFECT_ON_LEAVE,0) = 1
		
	
		SELECT	--@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
				@Lv_Encash_W_Day = IsNull(Lv_Encash_W_Day,0),
				@IS_ROUNDING = IsNull(AD_Rounding,0),@chk_lv_on_working = IsNull(chk_lv_on_working,0),@Lv_Encash_Cal_On=IsNull(Lv_Encash_Cal_On,''),@Inc_Weekoff=Inc_Weekoff 
		FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
		WHERE	Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID
				AND For_Date = (SELECT	MAX(For_Date) 
								FROM	dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
								WHERE	For_Date <=@Temp_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		
		
		IF IsNull(@Sal_St_Date,'') = ''    
			BEGIN    
				SET @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Temp_Date),year(@Temp_Date))    
				SET @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Temp_Date),year(@Temp_Date))
				SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			END     
		ELSE IF DAY(@Sal_St_Date) = 1 --and month(@Sal_St_Date)= 1    
			BEGIN    
				SET @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Temp_Date),year(@Temp_Date))    
				SET @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Temp_Date),year(@Temp_Date))
				SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1  
			END     
		ELSE IF @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			BEGIN    
				SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Temp_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Temp_Date) )as varchar(10)) as smalldatetime)    
				SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			    SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			END	
		ELSE
			BEGIN
				SET @Sal_St_Date = dateadd(mm,1,@Sal_St_Date)
				SET @Sal_End_Date = dateadd(mm,1,@Sal_End_Date)
				SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			END
		 
		SET @upto_Basic_Salary = IsNull(@upto_Basic_Salary ,0) + IsNull(@Allow_Effect_on_Leave,0)


		--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_End_Date,null,null,@Is_Cancel_Holiday,null ,@Holiday_days output,null,0,@Branch_ID
		--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_End_Date,null,null,@Is_Cancel_weekoff,null,null ,@Weekoff_Days output ,null ,0,1
		CREATE TABLE #EMP_WEEKOFF
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(4,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
		
		CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

		DECLARE @CONSTRAINT VARCHAR(10)
		SET @CONSTRAINT = CAST(@Emp_ID AS VARCHAR(10))

		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Sal_St_Date, @TO_DATE=@Sal_End_Date, @All_Weekoff = 0, @Exec_Mode=0		


		SELECT @Holiday_Days = SUM(H_DAY) FROM #EMP_HOLIDAY WHERE EMP_ID=@Emp_ID
		SELECT @Weekoff_Days = SUM(W_DAY) FROM #EMP_WEEKOFF WHERE EMP_ID=@Emp_ID
		
		IF @Temp_Lv_Encash_W_Day > 0
			BEGIN 
				SET @Lv_Encash_W_Day = @Temp_Lv_Encash_W_Day 
			END
		
		---Added By Jimit 08022018
				DECLARE @LV_ENCASH_W_DAY_Master as NUMERIC
				SELECT @LV_ENCASH_W_DAY_Master = LEAVE_ENCASH_WORKING_DAYS 
				FROM T0080_EMP_MASTER WITH (NOLOCK)
				WHERE EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID				
				
				IF @LV_ENCASH_W_DAY_Master > 0
					SET @Lv_Encash_W_Day = @LV_ENCASH_W_DAY_Master
					
		---Ended
		
		IF @Inc_Weekoff <> 1
			SET @Working_Days = @Outof_Days - @WeekOff_Days 
		ELSE
			SET @Working_Days = @Outof_Days 
	
		IF @Wages_Type = 'Monthly' 
			BEGIN
				IF @Lv_Encash_W_Day > 0 
					BEGIN
						SET @Day_Salary = 	@upto_Basic_Salary / @Lv_Encash_W_Day
						SET @Gross_Salary_ProRata = @upto_Gross_Salary/@Lv_Encash_W_Day	
					END
				ELSE IF @chk_lv_on_working = 1
					BEGIN		
						SET @Day_Salary = 	@upto_Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
						SET @Gross_Salary_ProRata = @upto_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
					END 
				ELSE IF @Inc_Weekoff = 1
					BEGIN
						SET @Day_Salary = 	@upto_Basic_Salary / @Outof_Days 
						SET @Gross_Salary_ProRata = @upto_Gross_Salary/@Outof_Days
					END 
				ELSE
					BEGIN
						SET @Day_Salary = 	@upto_Basic_Salary / @Working_Days
						SET @Gross_Salary_ProRata = @upto_Gross_Salary/@Working_Days
					END 
			END
		ELSE
			BEGIN
				SET @Day_Salary = 	@upto_Basic_Salary
			END
	
		SELECT	@Encashment_Rate = IsNull(Encashment_Rate,1)  
		FROM	T0040_TYPE_MASTER WITH (NOLOCK)
		WHERE	TYPE_ID=@Type_Id  
		If @Lv_Encash_Cal_On = 'Gross' 
			SET @Salary_Amount  = IsNull(@Salary_Amount,0) + IsNull(Round(@Gross_Salary_ProRata * @Encashment_Rate * @Lv_Encash_Apr_Days,0),0)
		Else
			SET @Salary_Amount  = IsNull(@Salary_Amount,0) + IsNull(Round(@Day_Salary * @Encashment_Rate * @Lv_Encash_Apr_Days,0),0)

		--- Added Condition by Hardik 19/11/2019 for Diamines, Compoff Hour will again allocated to Days column so insert Hours in Table
		IF @Apply_Hourly = 1
			BEGIN 
				Set @Lv_Encash_Apr_Days = @Lv_Encash_Apr_Hours
			END
		
		IF @Leave_EncashDay_Half_Payment = 1
			SET @Salary_Amount = @Salary_Amount / 2
	--Select @Day_Salary
		------added by sid Ends-----
		IF @tran_type  = 'I'
			BEGIN
				IF @Max_No_Of_Application = 0 
					OR (@Max_No_Of_Application > IsNull(@Total_Application,0) AND @Max_No_Of_Application > 0) 
					OR @Is_FNF = 1 --DURING FNF MAX LIMIT OF LEAVE ENCASH SHOULD NOT BE CHECKED (RAMIZ - 25052017)
					BEGIN 
				
						SELECT	@Lv_Encash_apr_ID = IsNull(MAX(Lv_Encash_apr_ID),0) + 1 	
						FROM	dbo.T0120_Leave_Encash_Approval WITH (NOLOCK)
				
						IF @Upto_Date = null
							BEGIN
								SELECT @Upto_Date = GETDATE()
							END
			
						SET @Lv_Encash_apr_Code = cast(@Lv_Encash_Apr_ID AS VARCHAR(50))
				
						--INSERT INTO dbo.T0120_Leave_Encash_Approval
						--		(Lv_Encash_Apr_ID, Lv_Encash_App_ID, Cmp_ID, Emp_ID,Leave_ID,Lv_Encash_Apr_Code,Lv_Encash_Apr_Days,Lv_Encash_Apr_Date, Lv_Encash_Apr_Status, Lv_Encash_Apr_Comments,Login_ID,System_Date,Is_FNF,Eff_In_Salary,Upto_Date,Leave_CompOff_Dates,leave_encash_amount,Leave_Recover) --changed by Gadriwala Muslim 02102014
						--VALUES	(@Lv_Encash_Apr_ID,@Lv_Encash_App_ID,@Cmp_ID,@Emp_ID,@Leave_ID,@Lv_Encash_Apr_Code,@Lv_Encash_Apr_Days,@Lv_Encash_Apr_Date,@Lv_Encash_Apr_Status,@Lv_Encash_Apr_Comments,@Login_ID,@System_Date,@Is_FNF,@Eff_In_Salary,IsNull(@Upto_Date,GETDATE()),@CompOffString,@Salary_Amount,@Leave_Recover)	 --changed by Gadriwala Muslim 02102014				
						
						/*
						Code is commented by Nimesh on 11-May-2018 (Client: VIVO MP) (i.e. Employee is Left on 31-Mar-2018, FNF is processing on 11-May-2018, Sal Cycle is 26-Apr-2018 To 25-May-2018.. So, Aproval Date is taking wrong)
						IF day(@Sal_St_Date) <> 1 AND @Is_FNF = 1	--NEW CASE ADDED BY RAMIZ (ONLY FOR FNF AND SALARY START DATE <> 1 ) (Added @Temp_Date)
							BEGIN
								INSERT INTO dbo.T0120_Leave_Encash_Approval
										(Lv_Encash_Apr_ID, Lv_Encash_App_ID, Cmp_ID, Emp_ID,Leave_ID,Lv_Encash_Apr_Code,Lv_Encash_Apr_Days,Lv_Encash_Apr_Date, Lv_Encash_Apr_Status, Lv_Encash_Apr_Comments,Login_ID,System_Date,Is_FNF,Eff_In_Salary,Upto_Date,Leave_CompOff_Dates,leave_encash_amount,Leave_Recover,Is_Tax_Free) --changed by Gadriwala Muslim 02102014
								VALUES	(@Lv_Encash_Apr_ID,@Lv_Encash_App_ID,@Cmp_ID,@Emp_ID,@Leave_ID,@Lv_Encash_Apr_Code,@Lv_Encash_Apr_Days,@Temp_Date,@Lv_Encash_Apr_Status,@Lv_Encash_Apr_Comments,@Login_ID,@System_Date,@Is_FNF,@Eff_In_Salary,isnull(@Upto_Date,GETDATE()),@CompOffString,@Salary_Amount,@Leave_Recover,@IsTaxFree)	 --changed by Gadriwala Muslim 02102014				
							END
						ELSE
							BEGIN*/
								INSERT INTO dbo.T0120_Leave_Encash_Approval
										(Lv_Encash_Apr_ID, Lv_Encash_App_ID, Cmp_ID, Emp_ID,Leave_ID,Lv_Encash_Apr_Code,Lv_Encash_Apr_Days,Lv_Encash_Apr_Date, Lv_Encash_Apr_Status, Lv_Encash_Apr_Comments,Login_ID,System_Date,Is_FNF,Eff_In_Salary,Upto_Date,Leave_CompOff_Dates,leave_encash_amount,Leave_Recover,Is_Tax_Free,Day_Salary) --changed by Gadriwala Muslim 02102014
								VALUES	(@Lv_Encash_Apr_ID,@Lv_Encash_App_ID,@Cmp_ID,@Emp_ID,@Leave_ID,@Lv_Encash_Apr_Code,@Lv_Encash_Apr_Days,@Lv_Encash_Apr_Date,@Lv_Encash_Apr_Status,@Lv_Encash_Apr_Comments,@Login_ID,@System_Date,@Is_FNF,@Eff_In_Salary,isnull(@Upto_Date,GETDATE()),@CompOffString,@Salary_Amount,@Leave_Recover,@IsTaxFree,@Day_Salary)	 --changed by Gadriwala Muslim 02102014				
							/*END*/
						--Added By Mukti(start)02072016									
						EXEC P9999_Audit_get @table = 'T0120_Leave_Encash_Approval' ,@key_column='Lv_Encash_Apr_ID',@key_Values=@Lv_Encash_Apr_ID,@String=@String output
						SET @OldValue = @OldValue + 'New Value' + '#' + cast(@String AS VARCHAR(MAX))
						--Added By Mukti(end)02072016
					END
				ELSE 
					BEGIN
						SET @Lv_Encash_apr_ID = 0
						RETURN					
					END
		 
			
			END
		ELSE IF @Tran_Type = 'U'
			BEGIN
				--Added By Mukti(start)02072016	
				EXEC P9999_Audit_get @table='T0120_Leave_Encash_Approval' ,@key_column='Lv_Encash_Apr_ID',@key_Values=@Lv_Encash_Apr_ID,@String=@String OUTPUT
				SET @OldValue = @OldValue + 'old Value' + '#' + CAST(@String AS VARCHAR(MAX))
				--Added By Mukti(end)02072016
		
				UPDATE	dbo.T0120_Leave_Encash_Approval			
				SET		@Lv_Encash_Apr_ID=@Lv_Encash_Apr_ID,
						@Lv_Encash_App_ID=@Lv_Encash_App_ID,
						@Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,
						Leave_ID =@Leave_ID,Lv_Encash_Apr_Code=@Lv_Encash_Apr_Code,
						Lv_Encash_Apr_Days=@Lv_Encash_Apr_Days,
						Lv_Encash_Apr_Date=@Lv_Encash_Apr_Date,
						Lv_Encash_Apr_Status=@Lv_Encash_Apr_Status,
						Lv_Encash_Apr_Comments=@Lv_Encash_Apr_Comments,
						Login_ID=@Login_ID,System_Date=@System_Date,
						Is_FNF =@Is_FNF,Eff_In_Salary=@Eff_In_Salary,
						Upto_Date = @Upto_Date,
						Leave_CompOff_Dates = @CompOffString,
						leave_encash_amount = @Salary_Amount,
						Is_Tax_Free = @IsTaxFree
						,Day_Salary = @Day_Salary -- Added By Sajid 09-02-2022
				WHERE  Lv_Encash_Apr_ID=@Lv_Encash_Apr_ID
			
				--Added By Mukti(start)02072016	
				EXEC P9999_Audit_get @table = 'T0120_Leave_Encash_Approval' ,@key_column='Lv_Encash_Apr_ID',@key_Values=@Lv_Encash_Apr_ID,@String=@String OUTPUT
				SET @OldValue = @OldValue + 'New Value' + '#' + CAST(@String AS VARCHAR(MAX))
				--Added By Mukti(end)02072016	
			END
		ELSE IF @Tran_Type = 'D'
		BEGIN		
				IF (select COUNT(1) from T0200_MONTHLY_SALARY where cmp_ID=@Cmp_ID and emp_ID=@Emp_ID and Month_St_Date >= @Effect_Date and Month_End_Date >= @Effect_Date ) > 0 OR 
					(select count(1) from V0000_MONTHLY_EMP_BANK_PAYMENT where cmp_ID=@Cmp_ID and emp_ID=@Emp_ID and For_Date >= @Effect_Date and Payment_Date >= @Effect_Date and Process_Type= 'Leave Encashment') >0 
					BEGIN
					SET @Lv_Encash_Apr_ID = 0
					RETURN
					END
				ELSE
					BEGIN
						IF IsNull(@Lv_Encash_App_ID,0) > 0 --Condition added by Hardik 23/03/2016 as Leave Encash Approval admin side will pass encash_application_id
							BEGIN
								DELETE FROM dbo.T0120_Leave_Encash_Approval WHERE Lv_Encash_App_ID = @Lv_Encash_App_ID					
								SET @Lv_Encash_Apr_ID =@Lv_Encash_App_ID --SET this because out this is the output perameter so we have to pass proper id so message will show on form by Sumit 01072016
							END
						ELSE
							BEGIN	
								--Added By Mukti(start)02072016	
								EXEC P9999_Audit_get @table='T0120_Leave_Encash_Approval' ,@key_column='Lv_Encash_Apr_ID',@key_Values=@Lv_Encash_Apr_ID,@String=@String OUTPUT
								SET @OldValue = @OldValue + 'old Value' + '#' + CAST(@String AS VARCHAR(MAX))
								--Added By Mukti(end)02072016		
								DELETE FROM dbo.T0120_Leave_Encash_Approval WHERE Lv_Encash_Apr_ID = @Lv_Encash_Apr_ID					
							END
							EXEC P9999_Audit_Trail @CMP_ID,@Tran_Type,'Leave Encashment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  --Mukti(02072016)
					END
			END
		--	BEGIN		
		--		IF IsNull(@Lv_Encash_App_ID,0) > 0 --Condition added by Hardik 23/03/2016 as Leave Encash Approval admin side will pass encash_application_id
		--			BEGIN
		--				DELETE FROM dbo.T0120_Leave_Encash_Approval WHERE Lv_Encash_App_ID = @Lv_Encash_App_ID					
		--				SET @Lv_Encash_Apr_ID =@Lv_Encash_App_ID --SET this because out this is the output perameter so we have to pass proper id so message will show on form by Sumit 01072016
		--			END
		--		ELSE
		--			BEGIN	
		--				--Added By Mukti(start)02072016	
		--				EXEC P9999_Audit_get @table='T0120_Leave_Encash_Approval' ,@key_column='Lv_Encash_Apr_ID',@key_Values=@Lv_Encash_Apr_ID,@String=@String OUTPUT
		--				SET @OldValue = @OldValue + 'old Value' + '#' + CAST(@String AS VARCHAR(MAX))
		--				--Added By Mukti(end)02072016		
					
		--				DELETE FROM dbo.T0120_Leave_Encash_Approval WHERE Lv_Encash_Apr_ID = @Lv_Encash_Apr_ID					
		--			END
		--	END
		--EXEC P9999_Audit_Trail @CMP_ID,@Tran_Type,'Leave Encashment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  --Mukti(02072016)
	RETURN









