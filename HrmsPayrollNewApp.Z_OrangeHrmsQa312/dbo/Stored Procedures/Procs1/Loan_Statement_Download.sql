-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <12/03/2015>
-- Description:	<Loan Statement Which Download From Loan Application>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Loan_Statement_Download]
@cmp_ID numeric(18,0),
@emp_ID numeric(18,0),
@Loan_ID numeric(18,0),
@Loan_Application datetime,
@Loan_Max_Limit numeric(18,2),
@Loan_Amount numeric(18,2),
@Interest_Type varchar(20),
@Interest_Per numeric(18,4),
@No_Of_Installment numeric(18,0),
@Installment_Amount numeric(18,2),
@Installment_Start_Date datetime,
@Deduction_Type varchar(20) = 'Monthly',
@Is_Intrest_Amount_As_Perquisite_IT bit = 0, --Added by nilesh patel on 08112016
@Loan_Apr_ID Numeric(18,0) = 0 --Added by nilesh patel on 08112016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	If @Loan_Apr_ID = 0
		BEGIN			
			SELECT  @Loan_Apr_ID=Loan_Apr_ID 
			FROM	T0120_LOAN_APPROVAL LAR WITH (NOLOCK)
					LEFT OUTER JOIN   T0100_LOAN_APPLICATION LAP WITH (NOLOCK) ON LAR.Loan_App_ID=LAP.Loan_App_ID
			WHERE	LAR.Emp_ID=@emp_ID AND ISNULL(LAP.LOAN_APP_DATE,LAR.LOAN_APR_DATE)=@Loan_Application
		END
	
	Create Table #Loan_Statement
	(
		Emp_Id numeric(18,0),
		Loan_Id numeric(18,0),
		Loan_Application varchar(25),
		Loan_Amount numeric(18,2),
		Deduction_Type varchar(20),
		No_Of_Installment numeric(18,0),
		Installment_Amount numeric(18,2),
		Interest_Type varchar(20),
		Interest_Per numeric(18,4),
		Interest_Amount numeric(18,2),
		Installment_Start_Date varchar(25),
		Balance_Loan_Amount numeric(18,2),
		Pending_Loan numeric(18,2)
	)
	
	Declare @Pre_Installment_Date as datetime
	Declare @Interest_Amount as numeric(18,2)
	Declare @Pending_Loan_Amount as numeric(18,2)
	Declare @Loan_Days as numeric(18,0)
	Declare @Month_Days as numeric(18,0)
	Declare @Temp_Installment_Amount as numeric(18,2)
	Declare @Balance_Loan_Amount as numeric(18,2)
	
	DECLARE @Round_Loan_Interest	NUMERIC(18,0)	----Ankit 24092015
	SET @Round_Loan_Interest = 0
	SELECT @Round_Loan_Interest = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Round Loan Interest Amount'

	Declare @Is_Principal_First_than_Int tinyint
	Select @Is_Principal_First_than_Int = isnull(Is_Principal_First_than_Int,0) From T0040_LOAN_MASTER WITH (NOLOCK) Where Loan_ID = @Loan_ID
	

	--commented by deepal
	--if @Installment_Start_Date > @Loan_Application -- Added by nilesh 11102017 Bugs No 0006585
	--	Begin
			
	--		Set @Loan_Application = @Installment_Start_Date
	--	End
	--commented by deepal
	
	DECLARE @SettingValue as int = 0	
	SELECT @SettingValue = Setting_Value from T0040_SETTING where Setting_Name = '1 st installment start date from EMI start date deduct like bank rule' and Cmp_ID =@cmp_ID
	


	IF @SETTINGVALUE = 0
	BEGIN
		SET @MONTH_DAYS = DATEDIFF(D,DBO.GET_MONTH_ST_DATE(MONTH(@LOAN_APPLICATION),YEAR(@LOAN_APPLICATION)),DBO.GET_MONTH_END_DATE(MONTH(@LOAN_APPLICATION),YEAR(@LOAN_APPLICATION))) --+ 1
		SET @LOAN_DAYS = DATEDIFF(D,@LOAN_APPLICATION,@INSTALLMENT_START_DATE)  --+ 1
	END
	ELSE
	BEGIN
		SET @MONTH_DAYS = DATEDIFF(D,DBO.GET_MONTH_ST_DATE(MONTH(@LOAN_APPLICATION),YEAR(@LOAN_APPLICATION)),DBO.GET_MONTH_END_DATE(MONTH(@LOAN_APPLICATION),YEAR(@LOAN_APPLICATION))) --+ 1
		SET @LOAN_DAYS = DATEDIFF(D,@LOAN_APPLICATION,@INSTALLMENT_START_DATE) --+ 1
	END
	
	


	----------
	Declare @Branch_ID_Temp As Numeric
	Declare @Sal_St_Date   Datetime
	Declare @Sal_End_Date Datetime
	Declare @Installment_Date As Datetime    
	declare @manual_salary_period as numeric(18,0) -- Comment and added By rohit on 11022013
	

	Select @Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN     
		   ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <= @Installment_Start_Date and 
				Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id group by emp_ID
			) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
	Where I.Emp_ID = @Emp_ID 


	
		declare @CutofDate datetime --Added by ronakk 03052023
		declare @IsCutofDed int --Added by ronakk 04052023

	SELECT @Sal_St_Date = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0),@CutofDate = Cutoffdate_Salary FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp 
	  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Installment_Start_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    
	


	select @IsCutofDed =  Setting_Value from T0040_SETTING where Setting_Name='Allow Cutoff Date as Loan Installment/Paid Date' and Cmp_ID=@cmp_id  --Added by ronakk 04052023

	
	If (@CutofDate is not null) and (@IsCutofDed =1)  --Added by ronakk 03052023 Condtion and cutoff logic for loan 
	Begin
			   set @Sal_St_Date =  cast(Format(Dateadd(DAY,1,@CutofDate),'dd') + '-' + cast(datename(mm,@Loan_Application) as varchar(10)) + '-' +  cast(year(@Loan_Application)as varchar(10)) as smalldatetime)    

			   --set @Sal_St_Date =  cast(Format(Dateadd(DAY,1,@CutofDate),'dd') + '-' + cast(datename(mm,dateadd(m,-1,@Loan_Application)) as varchar(10)) + '-' +   cast(year(dateadd(m,-1,@Loan_Application) )as varchar(10)) as smalldatetime)    

			   set @Sal_End_Date =dateadd(d,-1, dateadd(m,1,@Sal_St_Date) )
	   
	End
	else if isnull(@Sal_St_Date,'') = ''  or day(@Sal_St_Date) =1
		begin    					
			set @Sal_St_Date  = cast('1-' + cast(datename(mm,@Loan_Application) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Loan_Application) )as varchar(10)) as smalldatetime)    
			set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		end     
	else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		begin    
			--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Loan_Application) as varchar(10)) + '-' +  cast(year(@Loan_Application)as varchar(10)) as smalldatetime)    
			--set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			if @manual_salary_period = 0 
				begin
					
					set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,0,@Loan_Application)) as varchar(10)) + '-' +  cast(year(dateadd(m,0,@Loan_Application) )as varchar(10)) as smalldatetime)    
					set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
				end 
			else
				begin
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Installment_Start_Date) and YEAR=year(@Installment_Start_Date)
				end   
		end

	if @SettingValue = 0
	Begin
			if @Loan_Application >cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Application) as varchar(10)),3) + '-' +  cast(year(@Loan_Application)as varchar(10)) as smalldatetime)
			Begin
			 	Set @Installment_Date = @Sal_End_Date 
				set @Loan_Days = DATEDIFF(d,@Loan_Application,@Installment_Date) --+ 1
				set @Month_Days = DATEDIFF(d,@Sal_St_Date,@Sal_End_Date) + 1
			End
			else
			Begin
				Set @Installment_Date = cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Application) as varchar(10)),3) + '-' +  cast(year(@Loan_Application)as varchar(10)) as smalldatetime) 
				set @Loan_Days = DATEDIFF(d,@Loan_Application,@Installment_Date)
				set @Month_Days = DATEDIFF(d,@Sal_St_Date,@Sal_End_Date) + 1

			End
	END
	ELSe
	BEGIN
		--Set @Installment_Date = cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Application) as varchar(10)),3) + '-' +  cast(year(@Loan_Application)as varchar(10)) as smalldatetime)
		set @Installment_Date = @Installment_Start_Date
		set @Loan_Days = DATEDIFF(d,@Loan_Application,@Installment_Date)
		--set @Month_Days = DATEDIFF(d,@Sal_St_Date,@Sal_End_Date) + 1
	END

	
	set @Pending_Loan_Amount = @Loan_Amount 	
	set @Balance_Loan_Amount = @Loan_Amount
	
	Declare @lcount int =0
			while 	@Pending_Loan_Amount > 0 
				begin
						set @Temp_Installment_Amount  = @Installment_Amount
						
						
			
						If not @Pre_Installment_Date Is Null  --And @Pre_Installment_Date <> @Loan_Apr_Date
							Begin
								Set @Pre_Installment_Date = DATEADD(D,1,@Pre_Installment_Date)
							end
						Else
							Begin
								Set @Pre_Installment_Date = @Loan_Application
							end	


						--If not @Pre_Installment_Date Is Null 
						--If @Interest_Type = 'Reducing'
						--	begin
						--		If @Deduction_Type = 'Quaterly'
						--			Set @Pre_Installment_Date = DATEADD(M,3,@Pre_Installment_Date)
						--		Else If @Deduction_Type = 'Half Yearly'
						--			Set @Pre_Installment_Date = DATEADD(M,5,@Pre_Installment_Date)
						--		Else If @Deduction_Type = 'Yearly'
						--			Set @Pre_Installment_Date = DATEADD(M,11,@Pre_Installment_Date)
						--		else
						--			BEGIN
						--				--Set @Pre_Installment_Date = DATEADD(M,1,@Pre_Installment_Date)
									
						--				If day(@Sal_St_Date) = 1 
						--				Begin 
						--					Set @Pre_Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,1,@Pre_Installment_Date)),YEAR(DATEADD(m,1,@Pre_Installment_Date)))
						--				END
						--				else
						--				Begin

						--					if @manual_salary_period = 0 
						--						Set @Pre_Installment_Date = cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Pre_Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Pre_Installment_Date))as varchar(10)) as smalldatetime)
						--					Else
						--						--Select @Pre_Installment_Date = end_date from salary_period where month= month(@Pre_Installment_Date) and YEAR=year(@Pre_Installment_Date)
						--						Select @Pre_Installment_Date = end_date from salary_period where month= month(Dateadd(m,1,@Pre_Installment_Date)) and YEAR = Case When month(Dateadd(m,1,@Pre_Installment_Date))=1 then year(@Pre_Installment_Date)+1 else year(@Pre_Installment_Date) End
						--				END
						--			END
						--	end
						--Else
						--	begin
						--		--Set @Pre_Installment_Date = @Loan_Application -- @Installment_Start_Date -- Comment by nilesh patel on 12122016
						--		if @manual_salary_period = 0
						--			Begin
						--				Set @Pre_Installment_Date = dbo.GET_MONTH_END_DATE(MONTH(@Loan_Application),year(@Loan_Application)) 
						--				set @Loan_Days = DATEDIFF(d,@Loan_Application,@Pre_Installment_Date) + 1
						--			End
						--		Else
						--			Begin
						--				Select @Pre_Installment_Date = end_date from salary_period where month= month(@Installment_Start_Date) and YEAR=year(@Installment_Start_Date)
						--			End
						--	end
							
						if @Is_Intrest_Amount_As_Perquisite_IT = 1
							Begin
								Select @Interest_Per = LID.Standard_Rates From T0050_Loan_Interest_Details LID WITH (NOLOCK)
								Inner JOIN
								(
									Select MAX(Effective_Date) as Effective_Date,Loan_ID From T0050_Loan_Interest_Details WITH (NOLOCK)
									Where Effective_Date <= @Pre_Installment_Date and Loan_ID = @Loan_ID
									Group BY Loan_ID
								) as Qry
								ON LID.Loan_ID = Qry.Loan_ID and LID.Effective_Date = Qry.Effective_Date
								
								if Exists(Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_ID and Loan_Payment_Date = @Pre_Installment_Date and Loan_Pay_Amount = 0)
									BEGIN
										--SELECT 'NIL'
										SET @Temp_Installment_Amount = 0 
									End
							End
							
							
		

						If UPPER(@Interest_Type) = UPPER('Reducing')
							begin
									
									if (month(@Loan_Application) = MONTH(@Pre_Installment_Date) and YEAR(@Loan_Application) = Year(@Pre_Installment_Date) ) and (@lcount = 0)
									   begin
										
											If @Deduction_Type = 'Quaterly'
												Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 3
											Else If @Deduction_Type = 'Half Yearly'
												Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 5
											Else If @Deduction_Type = 'Yearly'
												Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 11
											else
											BEgin
												if @SettingValue = 0	
													set @Interest_Amount = round(((((@Pending_Loan_Amount * @Interest_Per) / 100) / 12) / @Month_Days) * @Loan_Days,2)
												ELSE
													set @Interest_Amount = round((((@Pending_Loan_Amount * @Interest_Per) / 100) / 365) * @Loan_Days,2)
											END	

										

									  if @Is_Intrest_Amount_As_Perquisite_IT = 1 --Added by nilesh patel on 01032017
												Begin
													set @Loan_Days = DATEDIFF(d,@Loan_Application,@Pre_Installment_Date) + 1
													set @Interest_Amount = round(((((@Pending_Loan_Amount * @Interest_Per) / 100) / 12) / @Month_Days) * @Loan_Days,2)
												End
									   end
									else
										begin
											
											If @Deduction_Type = 'Quaterly'
												Set @Interest_Amount = ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 4
											Else If @Deduction_Type = 'Half Yearly'
												Set @Interest_Amount = ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 6
											Else If @Deduction_Type = 'Yearly'
												Set @Interest_Amount = ((@Pending_Loan_Amount * @Interest_Per / 100)/12) * 12
											Else If @Deduction_Type = 'Monthly'
												Set @Interest_Amount = (@Pending_Loan_Amount * @Interest_Per / 100)/12	
												
										end
								
							end
						 else
							begin	
								
										If @Deduction_Type = 'Quaterly'
											Set @Interest_Amount = ((@Loan_Amount * @Interest_Per / 100)/12) * 4
										Else If @Deduction_Type = 'Half Yearly'
											Set @Interest_Amount = ((@Loan_Amount * @Interest_Per / 100)/12) * 6
										Else If @Deduction_Type = 'Yearly'
											Set @Interest_Amount = ((@Loan_Amount * @Interest_Per / 100)/12) * 12
										Else
											BEGIN
												-- Added Code by nilesh patel on 12122016 For Interest Calculation Prorata
												
												If (Month(@Loan_Application) = MONTH(@Pre_Installment_Date) And YEAR(@Loan_Application) = YEAR(@Pre_Installment_Date)) and (@lcount = 0)
													BEGIN

														if @Is_Intrest_Amount_As_Perquisite_IT = 1 --Added by nilesh patel on 01032017
															Begin
																set @Loan_Days = DATEDIFF(d,@Loan_Application,@Pre_Installment_Date) + 1
																set @Interest_Amount = ((((@Loan_Amount * @Interest_Per) / 100) / 12) / @Month_Days) * @Loan_Days
															End
														Else
															Begin															
																Set @Interest_Amount = (@Loan_Amount * @Interest_Per / 100)/12
															End
													END
												Else If @Deduction_Type = 'Monthly'
												Begin
													Set @Interest_Amount = (@Loan_Amount * @Interest_Per / 100)/12
													END
												--Set @Interest_Amount = (@Loan_Amount * @Interest_Per / 100)/12 Comment by nilesh patel on 12122016 For interest calculation on prorata																																	
											END
									
							end
						
								set  @lcount = @lcount + 1
				
			

						if Exists(Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
									Where Loan_Apr_ID = @Loan_Apr_ID 
											and Loan_Pay_Amount <> 0)
							BEGIN
								
								Select	@Temp_Installment_Amount=Loan_Pay_Amount,
										@Interest_Amount = Interest_Amount
								From	T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
								Where	Loan_Apr_ID = @Loan_Apr_ID and Loan_Payment_Date = @Pre_Installment_Date and Loan_Pay_Amount <> 0
								
							END
		
--						select @Interest_Amount deepal
						IF @Round_Loan_Interest = 1
							SET @Interest_Amount = ROUND(@Interest_Amount,0)
						
						
						IF @Installment_Date >= @Installment_Start_Date
							BEGIN

										If @Pending_Loan_Amount <= (@Temp_Installment_Amount - @Interest_Amount)
											Begin
										
												Set @Temp_Installment_Amount = @Pending_Loan_Amount 
												
												Set @Balance_Loan_Amount = @Balance_Loan_Amount  - (@Temp_Installment_Amount)	
										
											End
										Else
											Begin
										
												if @Is_Intrest_Amount_As_Perquisite_IT = 0
													Begin
												
														--Set @Temp_Installment_Amount = CEILING(@Temp_Installment_Amount	)	--Interest Round  Admin Setting Option	--Ankit 01102015
														if @Is_Principal_First_than_Int = 1
															Begin
																Set @Balance_Loan_Amount = @Balance_Loan_Amount - @Installment_Amount
																Set @Temp_Installment_Amount = @Installment_Amount
															End
														Else
															Begin
																Set @Balance_Loan_Amount = @Balance_Loan_Amount - (@Installment_Amount - Isnull(@Interest_Amount,0))
																Set @Temp_Installment_Amount = @Installment_Amount - Isnull(@Interest_Amount,0)
														
															End													
													End
												Else
													Begin
														Set @Balance_Loan_Amount = @Balance_Loan_Amount - isnull(@Installment_Amount,0)
												
													End
											End	
									
							End
						Else
							Begin
								SET @Temp_Installment_Amount = 0;
							End
							
						IF @Temp_Installment_Amount < 0 
							Begin
								Return
							End 
				
			
				

										Insert into #Loan_Statement(
																Emp_Id,
																Loan_Id,
																Loan_Application,
																Loan_Amount,
																Deduction_Type,
																No_Of_Installment,
																Installment_Amount,
																Interest_Type,
																Interest_Per,
																Interest_Amount,
																Installment_Start_Date,
																Balance_Loan_Amount,
																Pending_Loan
															)
												values		(
																@emp_ID,
																@Loan_ID,
																Convert(varchar(25),@Loan_Application,103),
																@Loan_Amount,
																@Deduction_Type,
																@No_Of_Installment,
																@Temp_Installment_Amount,
																@Interest_Type,
																@Interest_Per,
																@Interest_Amount,
															    Convert(varchar(25),@Installment_Date,103),
																@Balance_Loan_Amount,
																@Pending_Loan_Amount
															)

								Set @Pending_Loan_Amount = @Pending_Loan_Amount - @Temp_Installment_Amount
								
					

				 	 Set @Pre_Installment_Date = @Installment_Date		
								
				
					   -- Added by nilesh for not correct calculate when set installment start date from 01-12-2016 
					   
					  

						If @Deduction_Type = 'Quaterly' 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,3,@Installment_Date)),YEAR(DATEADD(m,3,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,3,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,3,@Installment_Date) )as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Half Yearly'
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,6,@Installment_Date)),YEAR(DATEADD(m,6,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,6,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,6,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Yearly'
								If day(@Sal_St_Date) = 1 
								begin
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(YY,1,@Installment_Date)),YEAR(DATEADD(YY,1,@Installment_Date)))
								end
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(YY,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(YY,1,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Monthly'
								If day(@Sal_St_Date) = 1
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,1,@Installment_Date)),YEAR(DATEADD(m,1,@Installment_Date)))
								else
									if @manual_salary_period = 0 
										Set @Installment_Date = cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
									 Else
									 Select @Installment_Date = end_date from salary_period where month= month(Dateadd(m,1,@Installment_Date)) and YEAR = Case When month(Dateadd(m,1,@Installment_Date))=1 then year(@Installment_Date)+1 else year(@Installment_Date) End
										--Set @Installment_Date = cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
						-- Added by nilesh for not correct calculate when set installment start date from 01-12-2016 
					
				end
				
			-- Added by nilesh Patel For Interest Calculation Consider As Perquisites in Income Tax on 08112016
			if @Is_Intrest_Amount_As_Perquisite_IT = 1
				Begin
					insert into #Loan_Statement_Interest
					Select *  From #Loan_Statement
				End
			-- Added by nilesh Patel For Interest Calculation Consider As Perquisites in Income Tax on 08112016
			if @Is_Intrest_Amount_As_Perquisite_IT = 0 
				Begin
			select L.*,LM.Loan_Name,E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
					Branch_Address Comp_Name,Cmp_Name,Cmp_Address,BM.BRANCH_ID,
					Case When Isnull(L.Installment_Amount,0) + ISNULL(L.Interest_Amount,0) < @Installment_Amount Then
								Isnull(L.Installment_Amount,0) + ISNULL(L.Interest_Amount,0)
					Else
								@Installment_Amount
					End as App_Inst_Amount
			From #Loan_Statement L Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
			INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK)  inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	
					where Increment_Effective_date <= @Loan_Application
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
				T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
				T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.TYPE_ID = TM.TYPE_ID Inner Join
				T0040_LOAN_MASTER LM WITH (NOLOCK) On L.Loan_Id = LM.Loan_ID Inner Join
				T0010_COMPANY_MASTER C WITH (NOLOCK) On E.Cmp_ID = C.Cmp_Id 
				order by Emp_code,convert(datetime,Installment_Start_Date ,103) -- installment date added by rohit for datewise record on 26032016	
			End
END

