---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LOAN_STATEMENT_REPORT]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(MAX)
,@Loan_Name		varchar(100)
,@Report_Type   VARCHAR(100) = ''   --added jimit 23062015
,@Loan_summary  tinyint = 0 -- Added by Gadriwala Muslim 15072015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	
	
	Declare @Loan_Id As Numeric
	Declare @Loan_Apr_Id As Numeric 
	Declare @Loan_Apr_Code As Numeric 
	Declare @Loan_Apr_Date As Datetime
	Declare @Loan_Amount As Numeric(18,2) 
	Declare @Loan_No_Of_Installment As Numeric 
	Declare @Loan_Installment_Amt As Numeric(18,2)
	Declare @Interest_Type as varchar(20)
	Declare @Interest_Percent As Numeric(18,2)
	Declare @Interest_Amount As Numeric(18,2)
	Declare @Pending_Loan_Amt as Numeric(18,2)
	Declare @Balance_Loan_Amt as Numeric(18,2)
	Declare @Installment_Date As Datetime
	Declare @Paid_Amount as Numeric(18,2)
	Declare @Max_Payment_Date as datetime
	Declare @Sal_Tran_Id As Numeric
	Declare @Salary_Interest_Amt As Numeric(18,2)
	Declare @Deduction_Type As varchar(30)
	Declare @Pending_Loan_AsOn_Date As Numeric(18,2)
	Declare @Payment_Amount As Numeric(18,2)
	Declare @Payment_Date as datetime
	Declare @Pre_Installment_Date as Datetime
	Declare @MonthDays As Numeric
	Declare @LoanDays As Numeric
	Declare @Branch_ID_Temp As Numeric
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime   
	Declare @Month_St_Date  Datetime
	Declare @Month_End_Date  Datetime
	Declare @No_of_Installment_Paid Numeric
	Declare @Is_Principal_First_than_Int Numeric

	Declare @Main_Installement_Amount As Numeric 
	Declare @Installment_Start_Date as Datetime
	
	Declare @Subsidy_Amount as Numeric(18,2) -- Added by rohit on 29072016
	Declare @subsidy_Amount_paid as Numeric(18,2)
	Declare @Is_Subsidy_Loan as tinyint
	
	set @Is_Subsidy_Loan = 0
	set @Subsidy_Amount = 0
	set @subsidy_Amount_paid= 0

	Set @Balance_Loan_Amt = 0	
	Set @Payment_Amount = 0		
	Set @Pre_Installment_Date = Null
	Set @MonthDays = 0
	Set @LoanDays = 0
	Set @Branch_ID_Temp = 0
	Set @Main_Installement_Amount = 0
	Set @No_of_Installment_Paid = 0
	Set @Is_Principal_First_than_Int = 0
	
	Select @Loan_Id = Loan_Id From T0040_LOAN_MASTER WITH (NOLOCK) Where Loan_Name = @Loan_Name And Cmp_ID = @Cmp_ID
	
	DECLARE @Round_Loan_Interest	NUMERIC(18,0)	----Ankit 24092015
	SET @Round_Loan_Interest = 0
	SELECT @Round_Loan_Interest = Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Round Loan Interest Amount'
		
	
CREATE TABLE #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		Begin
			Insert Into #Emp_Cons      
			  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
			  cmp_id=@Cmp_ID 
			   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
			  and Increment_Effective_Date <= @To_Date 
			  and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
						
				Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date) 
		End	

	Declare @Loan Table
	(
		Emp_Id Numeric,
		Loan_Id Numeric,
		Loan_Apr_Id Numeric,
		Loan_Apr_Code Numeric,
		Loan_Apr_Date Datetime,
		Loan_Amount Numeric(18,2),
		Deduction_Type Varchar(30),
		Loan_No_Of_Installment Numeric,
		Loan_Installment_Amt Numeric(18,2),
		Interest_Type varchar(20),
		Interest_Percent Numeric(18,2),
		Interest_Amount Numeric(18,2),
		Installment_Date Datetime,
		Paid_Date varchar(Max),
		Paid_Amount Numeric(18,2),
		Loan_Balance Numeric(18,2),
		Pending_Loan_AsOn_Date Numeric(18,2),
		No_of_Installment_Paid Numeric,
		Subsidy_Amount Numeric(18,2)
	)

/*	Insert Into @Loan 
	(Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Apr_Date,Loan_Amount,Loan_No_Of_Installment,Loan_Installment_Amt,
		Interest_Percent,Interest_Amount)
	Select LA.Emp_ID,Loan_Id,Loan_Apr_ID,Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
		Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount
	From T0120_LOAN_APPROVAL LA Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
	Where LA.Emp_ID = @Emp_ID And Loan_ID = @Loan_Id
*/


declare @count as int
Set @count = 1
	
	
	--Select LA.Emp_ID,LA.Loan_Id,Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
	--		Loan_Apr_Intrest_Type, Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount,Isnull(Installment_Start_Date,Loan_Apr_Date),
	--		isnull(No_of_Installment_Paid,0),LM.Is_Principal_First_than_Int
	--		From T0120_LOAN_APPROVAL LA Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
	--		Inner JOIN T0040_LOAN_MASTER LM ON LA.Loan_ID = LM.Loan_ID and Isnull(LM.Is_GPF,0)=0
	--		Union All
	--		Select LA.Emp_ID,LA.Loan_Id,Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,(Loan_Apr_Amount + IsNull(LA.CF_Loan_Amt,0)) As Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
	--		Loan_Apr_Intrest_Type, Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount,Isnull(Installment_Start_Date,Loan_Apr_Date),
	--		isnull(No_of_Installment_Paid,0),LM.Is_Principal_First_than_Int
	--		From T0120_LOAN_APPROVAL LA Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
	--		Inner JOIN T0040_LOAN_MASTER LM ON LA.Loan_ID = LM.Loan_ID and Isnull(LM.Is_GPF,0)=1 
	--		Where LA.Loan_Apr_ID  = (
	--								Select	MAX(Loan_Apr_ID) 
	--								From	T0120_LOAN_APPROVAL L INNER JOIN T0040_LOAN_MASTER LM ON L.Cmp_ID=LM.Cmp_ID AND L.Loan_ID=LM.Loan_ID
	--								where	EC.Emp_ID = L.Emp_ID AND L.Loan_Apr_Date <= @From_Date AND LM.Is_GPF=1
	--								) 
			
	--RETURN

	DECLARE @PRE_INSTALLMENT_INTEREST NUMERIC(18,4);
	DECLARE @PRE_INSTALLMENT_INTEREST_DAYS INT;




	IF @Loan_summary = 1  -- Added by Gadriwala Muslim 16072015
		begin
			Declare Cur_Loan cursor for 
			Select LA.Emp_ID,LA.Loan_Id,Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
			Loan_Apr_Intrest_Type, Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount,Isnull(Installment_Start_Date,Loan_Apr_Date),
			isnull(No_of_Installment_Paid,0),LM.Is_Principal_First_than_Int
			,LA.Subsidy_Amount,LM.is_Subsidy_Loan
			From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
			Inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID and Isnull(LM.Is_GPF,0)=0
			Union All
			Select LA.Emp_ID,LA.Loan_Id,Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,(Loan_Apr_Amount + IsNull(LA.CF_Loan_Amt,0)) As Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
			Loan_Apr_Intrest_Type, Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount,Isnull(Installment_Start_Date,Loan_Apr_Date),
			isnull(No_of_Installment_Paid,0),LM.Is_Principal_First_than_Int
			,LA.Subsidy_Amount,LM.is_Subsidy_Loan
			From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
			Inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID and Isnull(LM.Is_GPF,0)=1 
			Where LA.Loan_Apr_ID  = (
									Select	MAX(Loan_Apr_ID) 
									From	T0120_LOAN_APPROVAL L WITH (NOLOCK) INNER JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON L.Cmp_ID=LM.Cmp_ID AND L.Loan_ID=LM.Loan_ID
									where	EC.Emp_ID = L.Emp_ID AND L.Loan_Apr_Date <= @From_Date AND LM.Is_GPF=1
									) 
			
		
		end
	else
		begin
			Declare Cur_Loan cursor for 
			Select LA.Emp_ID,LA.Loan_Id,LA.Loan_Apr_ID,Loan_Apr_Code,Loan_Apr_Date,Loan_Apr_Amount,Deduction_Type,Loan_Apr_No_of_Installment,Loan_Apr_Installment_Amount,
			Loan_Apr_Intrest_Type, Loan_Apr_Intrest_Per,Loan_Apr_Intrest_Amount,Loan_Apr_Pending_Amount
			,Isnull(Installment_Start_Date,Loan_Apr_Date),
			isnull(No_of_Installment_Paid,0),LM.Is_Principal_First_than_Int
			,LA.Subsidy_Amount,Is_Subsidy_loan
			From T0120_LOAN_APPROVAL LA WITH (NOLOCK) Inner Join #Emp_Cons EC On LA.Emp_ID = EC.Emp_ID
			Inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.Loan_ID = LM.Loan_ID
			Where LA.Loan_ID = @Loan_Id And Loan_Apr_Date >= @From_Date And Loan_Apr_Date <= @To_Date 
		end

	

	open Cur_Loan
	fetch next from Cur_Loan into @Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Pending_Loan_AsOn_Date,@Installment_Start_Date,@No_of_Installment_Paid,@Is_Principal_First_than_Int,@Subsidy_Amount,@Is_Subsidy_Loan
	while @@fetch_Status = 0
		begin 
		

		
		--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 1'
		
		Declare @Lcount int = 0
		
				Select @Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
				   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   -- Ankit 08092014 for Same Date Increment
				   where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
				   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID Where I.Emp_ID = @Emp_ID 
  
				declare @CutofDate datetime --Added by ronakk 03052023
				declare @IsCutofDed int --Added by ronakk 04052023

				Select @Sal_St_Date = Sal_st_Date  ,@CutofDate = Cutoffdate_Salary
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    

				Set @Main_Installement_Amount = @Loan_Installment_Amt

				select @IsCutofDed =  Setting_Value from T0040_SETTING where Setting_Name='Allow Cutoff Date as Loan Installment/Paid Date' and Cmp_ID=@cmp_id  --Added by ronakk 04052023

				
				If (@CutofDate is not null) and (@IsCutofDed =1) --Added by ronakk 03052023 Condtion and cutoff logic for loan 
				Begin
						   set @Sal_St_Date =  cast(Format(Dateadd(DAY,1,@CutofDate),'dd') + '-' + cast(datename(mm,@Loan_Apr_Date) as varchar(10)) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date =dateadd(d,-1, dateadd(m,1,@Sal_St_Date) )

						 

						   Set @Month_St_Date = @Sal_St_Date
						   Set @Month_End_Date = @Sal_End_Date    

				End
				else if isnull(@Sal_St_Date,'') = ''  or day(@Sal_St_Date) =1
					  begin    
						   --set @Sal_St_Date  = @From_Date     
						   --set @Sal_End_Date = @To_Date 
						   
						   set @Sal_St_Date  = cast('1-' + cast(datename(mm,@Loan_Apr_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,0,@Loan_Apr_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		

						   Set @Month_St_Date = @Sal_St_Date
						   Set @Month_End_Date = @Sal_End_Date      
					  end     
				 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
					  begin    
						   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@Loan_Apr_Date) as varchar(10)) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

						   Set @Month_St_Date = @Sal_St_Date
						   Set @Month_End_Date = @Sal_End_Date    
					  end
				--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 2'
				
				Set @Pending_Loan_Amt = @Loan_Amount
				Set @Balance_Loan_Amt = @Loan_Amount
				--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(@Loan_Apr_Date),YEAR(@Loan_Apr_Date))



				if @Loan_Apr_Date >cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Apr_Date) as varchar(10)),3) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)
				Begin
					Set @Installment_Date = @Sal_End_Date 
				end
				else
				Begin
						Set @Installment_Date = cast(cast(day(@Sal_End_Date)as varchar(5)) + '-' + Left(cast(datename(mm,@Loan_Apr_Date) as varchar(10)),3) + '-' +  cast(year(@Loan_Apr_Date)as varchar(10)) as smalldatetime)
				end


				--Added by Nimesh On 20-July-2016 (CALCULATING PRE INSTALLMENT LOAN INTEREST AMOUNT ON FIRST INSTALLMENT)				
				SET @PRE_INSTALLMENT_INTEREST = 0
				/*IF @Loan_Apr_Date < DATEADD(m, -1, @Installment_Start_Date) AND @Deduction_Type = 'Monthly'
					BEGIN 
						SET @PRE_INSTALLMENT_INTEREST_DAYS = DATEDIFF(d, @Loan_Apr_Date, DATEADD(d, -1 * day(@Installment_Start_Date), @Installment_Start_Date) );
						SET @PRE_INSTALLMENT_INTEREST = round(((@Pending_Loan_Amt * @Interest_Percent / 100)/365)* @PRE_INSTALLMENT_INTEREST_DAYS,0)						
					END
				*/
			
				
				

				Set @MonthDays = DATEDIFF(d,@Month_St_Date,@Month_End_Date) +1
				Set @LoanDays = DATEDIFF(d,@Loan_Apr_Date,@Installment_Date) -- + 1 Redmin Bugs id 452


				Select @Max_Payment_Date = MAX(Loan_Payment_Date) From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id
				--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3'
				While @Pending_Loan_Amt > 0
					Begin 

				


						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 001'
					If not @Pre_Installment_Date Is Null --And @Pre_Installment_Date <> @Loan_Apr_Date
							Begin
								Set @Pre_Installment_Date = DATEADD(D,1,@Pre_Installment_Date)
							end
						Else
							Begin

								if day(@Installment_Date) = 1
								Begin 
										Set @Pre_Installment_Date = @Loan_Apr_Date
								end
								else
								begin
										Set @Pre_Installment_Date = @Installment_Date
								end

							end					
						
					
		
						
						--If @Pending_Loan_Amt <= @Loan_Installment_Amt
							--Set @Loan_Installment_Amt = @Pending_Loan_Amt
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 002'
						
						If @Interest_Type = 'Reducing'
							Begin
								If (Month(@Loan_Apr_Date) = Month(@Installment_Date) And Year(@Loan_Apr_Date) = Year(@Installment_Date)) or (@Lcount = 0)
									Begin
										Set @Interest_Amount = round((((@Pending_Loan_Amt * @Interest_Percent / 100)/12)/@MonthDays)* @LoanDays,2)
										
										If @Deduction_Type = 'Quaterly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 3
										Else If @Deduction_Type = 'Half Yearly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 5
										Else If @Deduction_Type = 'Yearly'
											Set @Interest_Amount = @Interest_Amount + ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 11										

											
									End									
								Else
									Begin										
										If @Deduction_Type = 'Quaterly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 4
										Else If @Deduction_Type = 'Half Yearly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 6
										Else If @Deduction_Type = 'Yearly'
											Set @Interest_Amount = ((@Pending_Loan_Amt * @Interest_Percent / 100)/12) * 12
										Else If @Deduction_Type = 'Monthly'
											Set @Interest_Amount = (@Pending_Loan_Amt * @Interest_Percent / 100)/12							
										
									End	
									
									
							End
						Else
							Begin								
								If @Deduction_Type = 'Quaterly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 4
								Else If @Deduction_Type = 'Half Yearly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 6
								Else If @Deduction_Type = 'Yearly'
									Set @Interest_Amount = ((@Loan_Amount * @Interest_Percent / 100)/12) * 12
								Else If @Deduction_Type = 'Monthly'
									Set @Interest_Amount = (@Loan_Amount * @Interest_Percent / 100)/12
								
							End
						
						
					set @Lcount = @Lcount+1

						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 003'
						
						IF @Round_Loan_Interest = 1
							SET @Interest_Amount = ROUND(ISNULL(@Interest_Amount,0),0)
						
						
						IF @Installment_Date >= @Installment_Start_Date
							BEGIN
								
								If @Pending_Loan_Amt <= @Main_Installement_Amount
									Begin
										
										Set @Loan_Installment_Amt = @Pending_Loan_Amt --+ Isnull(@Interest_Amount,0)
										Set @Balance_Loan_Amt = @Balance_Loan_Amt - (@Loan_Installment_Amt)
									End
								Else
									Begin
								
										if @Is_Principal_First_than_Int = 1 
											Begin
												Set @Loan_Installment_Amt = @Main_Installement_Amount 
												Set @Balance_Loan_Amt = @Balance_Loan_Amt - @Loan_Installment_Amt
											End
										Else
											Begin
												--Select @Loan_Installment_Amt,@Balance_Loan_Amt,@Main_Installement_Amount,Isnull(@Interest_Amount,0)
												Set @Loan_Installment_Amt = @Main_Installement_Amount - Isnull(@Interest_Amount,0)
												Set @Balance_Loan_Amt = @Balance_Loan_Amt - (@Main_Installement_Amount - Isnull(@Interest_Amount,0))

											End 

									End
							END
						ELSE
							SET @Loan_Installment_Amt = 0;
						
						--Added by Nimesh On 20-July-2016 (To calculate pre installment interest)
						/*
						IF @PRE_INSTALLMENT_INTEREST > 0												
							SET @Interest_Amount = @Interest_Amount + @PRE_INSTALLMENT_INTEREST																							
						SET @PRE_INSTALLMENT_INTEREST = 0		
						*/
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 004'
						
						Insert Into @Loan
							(Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Apr_Code,Loan_Apr_Date,Loan_Amount,Deduction_Type,Loan_No_Of_Installment,Loan_Installment_Amt,
							Interest_Type, Interest_Percent,Interest_Amount,Installment_Date,Loan_Balance,Pending_Loan_AsOn_Date,No_of_Installment_Paid)
						Values
							(@Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Installment_Date,@Balance_Loan_Amt,@Pending_Loan_AsOn_Date,@No_of_Installment_Paid)
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 005'

						
						

						If Exists (Select 1 From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id And Month(Loan_Payment_Date) = Month(@Installment_Date) And Year(Loan_Payment_Date) = Year(@Installment_Date)  )--Loan_Payment_Date >= @Pre_Installment_Date And Loan_Payment_Date <= @Installment_Date)
							Begin
								
								set @subsidy_Amount_paid = 0
							
								Declare @Loan_Payment_Date As Varchar(Max)
								Select @Loan_Payment_Date =COALESCE(@Loan_Payment_Date + ', ', '') + convert(varchar(20), Loan_Payment_Date, 103) 
								From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) Where Loan_Apr_ID = @Loan_Apr_Id 
								--And Loan_Payment_Date >= @Pre_Installment_Date And Loan_Payment_Date <= @Installment_Date Order By Loan_Payment_Date
								And Month(Loan_Payment_Date) = Month(@Installment_Date) And Year(Loan_Payment_Date) = Year(@Installment_Date)

--								Select @Sal_Tran_Id = Sal_Tran_ID From T0210_MONTHLY_LOAN_PAYMENT Where Loan_Apr_ID = @Loan_Apr_Id And Month(Loan_Payment_Date) = Month(@Installment_Date) And Year(Loan_Payment_Date) = Year(@Installment_Date) Order By Loan_Payment_Date
--								Select @Salary_Interest_Amt = Isnull(Loan_Intrest_Amount,0) From T0200_MONTHLY_SALARY Where Sal_Tran_ID = @Sal_Tran_Id And Emp_ID = @Emp_ID

								Select @Paid_Amount = SUM(Isnull(Loan_Pay_Amount,0)),@Salary_Interest_Amt = SUM(Isnull(Interest_Amount,0))
								,@subsidy_Amount_paid =  SUM(Isnull(Subsidy_Amount,0)) 
								From T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)
								Where Loan_Apr_ID = @Loan_Apr_Id 
								--And Loan_Payment_Date >= @Pre_Installment_Date And Loan_Payment_Date <= @Installment_Date
								And Month(Loan_Payment_Date) = Month(@Installment_Date) And Year(Loan_Payment_Date) = Year(@Installment_Date)

								Update @Loan Set Paid_Amount = @Paid_Amount + @Salary_Interest_Amt ,Loan_Balance = @Pending_Loan_Amt - @Paid_Amount - @subsidy_Amount_paid, Paid_Date = @Loan_Payment_Date, Interest_Amount = Case When @Salary_Interest_Amt = 0 OR @Salary_Interest_Amt IS null Then Interest_Amount Else @Salary_Interest_Amt End
									,subsidy_Amount = @subsidy_Amount_paid
								Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
							End
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 006'
						
							If Isnull(@Paid_Amount,0) > 0
							Begin
							
								Set @Pending_Loan_Amt = @Pending_Loan_Amt - @Paid_Amount - @subsidy_Amount_paid
							END
							Else
								If not @Max_Payment_Date Is null
									Begin
										If (Month(@Max_Payment_Date) <= MONTH(@Installment_Date) And YEAR(@Max_Payment_Date) <= YEAR(@Installment_Date)) Or (YEAR(@Max_Payment_Date) < YEAR(@Installment_Date))
											Begin
												Set @Pending_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
												Update @Loan Set Loan_Balance = @Pending_Loan_Amt
												Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
											End
										Else
											Begin
												Update @Loan Set Loan_Balance = @Pending_Loan_Amt
												Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
												Set @Balance_Loan_Amt = @Pending_Loan_Amt
											End
									End
								Else
									Begin
										--Update @Loan Set Loan_Balance = @Pending_Loan_Amt - @Loan_Installment_Amt
										--Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
										Set @Balance_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
										Set @Pending_Loan_Amt = @Pending_Loan_Amt - @Loan_Installment_Amt
	--If @count = 2
	--Begin
	--	select @Pending_Loan_Amt , @Loan_Installment_Amt
	--	Select * From @Loan	
	--	return
	--End
	
									End
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 007'
						
						if (@Is_Subsidy_Loan = 1 and @Pending_Loan_Amt <= @subsidy_Amount and @Pending_Loan_Amt > 0)
						begin
						
							Update @Loan 
							Set 
							subsidy_Amount = @Pending_Loan_Amt
							,Loan_Balance = 0
							Where Loan_Apr_ID = @Loan_Apr_Id And Month(Installment_Date) = Month(@Installment_Date) And Year(Installment_Date) = Year(@Installment_Date)
							set @Pending_Loan_Amt = 0
						end
						
						Set @Paid_Amount = 0
						Set @Loan_Payment_Date = Null
						Set @count = @count + 1
						
						Set @Pre_Installment_Date = @Installment_Date
						If @Deduction_Type = 'Quaterly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,3,@Installment_Date)),YEAR(DATEADD(m,3,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,3,@Installment_Date)),YEAR(DATEADD(m,3,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,3,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,3,@Installment_Date) )as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Half Yearly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,6,@Installment_Date)),YEAR(DATEADD(m,6,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,6,@Installment_Date)),YEAR(DATEADD(m,6,@Installment_Date)))
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,6,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,6,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Yearly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(YY,1,@Installment_Date)),YEAR(DATEADD(YY,1,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
								begin
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(YY,1,@Installment_Date)),YEAR(DATEADD(YY,1,@Installment_Date)))
								end
								else
									Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(YY,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(YY,1,@Installment_Date))as varchar(10)) as smalldatetime)
						Else If @Deduction_Type = 'Monthly'
							--Set @Installment_Date = dbo.GET_MONTH_END_DATE(Month(DATEADD(m,1,@Installment_Date)),YEAR(DATEADD(m,1,@Installment_Date))) 
								If day(@Sal_St_Date) = 1 
									--Set @Installment_Date = cast(cast(day(dateadd(m,1,@Installment_Date))as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
									Set @Installment_Date = dbo.GET_MONTH_END_DATE (Month(DATEADD(m,1,@Installment_Date)),YEAR(DATEADD(m,1,@Installment_Date)))
								else
									--Set @Installment_Date = cast(cast(day(@Installment_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
									Set @Installment_Date = cast(cast(day(@Sal_end_Date)as varchar(5)) + '-' + cast(datename(mm,DATEADD(m,1,@Installment_Date)) as varchar(10)) + '-' +  cast(year(DATEADD(m,1,@Installment_Date))as varchar(10)) as smalldatetime)
						--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 3 : 008'
						End

						
					
					--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 4 '				
				Set @Balance_Loan_Amt = 0
				Set @Pending_Loan_Amt = 0
				Set @Pre_Installment_Date = Null
			fetch next from Cur_Loan into @Emp_Id,@Loan_Id,@Loan_Apr_Id,@Loan_Apr_Code,@Loan_Apr_Date,@Loan_Amount,@Deduction_Type,@Loan_No_Of_Installment,@Loan_Installment_Amt,
								@Interest_Type,@Interest_Percent,@Interest_Amount,@Pending_Loan_AsOn_Date,@Installment_Start_Date,@No_of_Installment_Paid,@Is_Principal_First_than_Int,@subsidy_Amount,@is_Subsidy_loan
		End
	close Cur_Loan
	Deallocate Cur_Loan
	--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : END OF LOOP'
	
	if @Loan_summary = 1  -- Gadriwala Muslim 16072015
		begin
		
			Select  qry.Emp_Id,qry.Loan_ID, (Qry1.Loan_No_Of_Installment + No_of_Installment_Paid),(Qry1.Current_Installment + Qry1.No_of_Installment_Paid) as Current_Installment,qry.Loan_Apr_Id
			From 
			( 
				select COUNT(*) as Total_Installment,Emp_Id,Loan_ID,Loan_Apr_Id from @Loan --where isnull(Paid_Amount,0) > 0 
				Group by Emp_Id ,Loan_Id ,Loan_Apr_Id
			) qry 
			inner join
			(
					select Emp_ID,Loan_ID,Loan_Apr_Id,COUNT(*) as Current_Installment,No_of_Installment_Paid,Loan_No_Of_Installment
					from @loan where Installment_Date <= @To_Date and isnull(Paid_Amount,0) > 0
					Group by Emp_Id,Loan_Id,No_of_Installment_Paid,Loan_Apr_Id,Loan_No_Of_Installment
					
			 )Qry1 on qry.Emp_Id = Qry1.Emp_Id and qry.Loan_Id = qry1.Loan_Id and qry.Loan_Apr_Id = qry1.Loan_Apr_Id	
			
			group by Qry.Emp_Id,Qry.Loan_Id ,Qry.Total_Installment,Qry1.Current_Installment,No_of_Installment_Paid,qry.Loan_Apr_Id,Loan_No_Of_Installment
		end
	else
		begin
			if @Report_Type = ''
			Begin
				
		Select L.*,E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
			Branch_Address, Comp_Name,Loan_Name,Cmp_Name,Cmp_Address,@From_Date As From_Date,@To_Date As To_Date,
			Loan_Apr_Payment_Date,Loan_Apr_Payment_Type,LA.Bank_ID,Loan_Apr_Cheque_No,Bank_Name,BM.BRANCH_ID,
			Case When Isnull(L.Loan_Installment_Amt,0) + ISNULL(L.Interest_Amount,0) < LA.Loan_Apr_Installment_Amount Then
				Isnull(L.Loan_Installment_Amt,0) + ISNULL(L.Interest_Amount,0)
			Else
				LA.Loan_Apr_Installment_Amount
			End As Loan_Apr_Installment_Amount
			,DGM.Desig_Dis_No --added by jimit 18112016
		From @Loan L Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
			INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.TYPE_ID = TM.TYPE_ID Inner Join
			T0040_LOAN_MASTER LM WITH (NOLOCK) On L.Loan_Id = LM.Loan_ID Inner Join
			T0010_COMPANY_MASTER C WITH (NOLOCK) On E.Cmp_ID = C.Cmp_Id Inner Join
			T0120_LOAN_APPROVAL LA WITH (NOLOCK) On L.Loan_Apr_Id = LA.Loan_Apr_ID Left Outer Join
			T0040_BANK_MASTER BMM WITH (NOLOCK) On LA.Bank_ID = BMM.Bank_Id
			order by Loan_apr_id,Installment_Date
	end

	else if @Report_Type = 'Summary'
	begin
		Select E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
			Branch_Address, Comp_Name,Loan_Name,Cmp_Name,Cmp_Address,@From_Date As From_Date,@To_Date As To_Date,
			Loan_Apr_Payment_Date,Loan_Apr_Payment_Type,LA.Bank_ID,Loan_Apr_Cheque_No,Bank_Name,BM.BRANCH_ID,
			Loan_Apr_Installment_Amount,
			La.Installment_Start_Date,
			L.Emp_Id ,
			L.Loan_Id ,
			L.Loan_Apr_Id ,
			L.Loan_Apr_Code ,
			L.Loan_Apr_Date ,
			Loan_Amount,
			L.Deduction_Type,
			Loan_No_Of_Installment ,
			Interest_Type ,
			Interest_Percent ,
				
			SUM(L.Interest_Amount) AS Cumm_Interest_Amount,
			La.Loan_Apr_Deduct_From_Sal
			,DGM.Desig_Dis_No --added jimit 03102015
			,(Select AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) Where AD_ID = Isnull(LA.AD_ID,0)) AS ADName
		From @Loan L Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.TYPE_ID = TM.TYPE_ID Inner Join
			T0040_LOAN_MASTER LM WITH (NOLOCK) On L.Loan_Id = LM.Loan_ID Inner Join
			T0010_COMPANY_MASTER C WITH (NOLOCK) On E.Cmp_ID = C.Cmp_Id Inner Join
			T0120_LOAN_APPROVAL LA WITH (NOLOCK) On L.Loan_Apr_Id = LA.Loan_Apr_ID Left Outer Join
			T0040_BANK_MASTER BMM WITH (NOLOCK) On LA.Bank_ID = BMM.Bank_Id
		Group by
		E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
			Branch_Address, Comp_Name,Loan_Name,Cmp_Name,Cmp_Address,
			Loan_Apr_Payment_Date,Loan_Apr_Payment_Type,LA.Bank_ID,Loan_Apr_Cheque_No,Bank_Name,BM.BRANCH_ID,Loan_Apr_Installment_Amount
		,Installment_Start_Date
		,L.Emp_Id ,
			L.Loan_Id ,
			L.Loan_Apr_Id ,
			L.Loan_Apr_Code ,
			L.Loan_Apr_Date ,
			Loan_Amount,
			L.Deduction_Type,
			Loan_No_Of_Installment ,
			
			Interest_Type ,
			Interest_Percent ,
			
			La.Loan_Apr_Deduct_From_Sal,dgm.Desig_Dis_No,LA.AD_ID
			
	end
	Else if @Report_Type = 'Statement'
	begin
		
		Select L.*,E.Emp_code,E.Alpha_Emp_Code, E.Emp_full_Name, Branch_Name, Dept_Name, Grd_Name, Desig_Name,Type_Name, 
			Branch_Address, Comp_Name,Loan_Name,Cmp_Name,Cmp_Address,@From_Date As From_Date,@To_Date As To_Date,
			Loan_Apr_Payment_Date,Loan_Apr_Payment_Type,LA.Bank_ID,Loan_Apr_Cheque_No,Bank_Name,BM.BRANCH_ID,
			Case When Isnull(L.Loan_Installment_Amt,0) + ISNULL(L.Interest_Amount,0) < LA.Loan_Apr_Installment_Amount Then
				Isnull(L.Loan_Installment_Amt,0) + ISNULL(L.Interest_Amount,0)
			Else
				LA.Loan_Apr_Installment_Amount
			End As Loan_Apr_Installment_Amount
			,DGM.Desig_Dis_No  --added jimit 03102015
		From @Loan L Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			T0040_TYPE_MASTER TM WITH (NOLOCK) ON Q_I.TYPE_ID = TM.TYPE_ID Inner Join
			T0040_LOAN_MASTER LM WITH (NOLOCK) On L.Loan_Id = LM.Loan_ID Inner Join
			T0010_COMPANY_MASTER C WITH (NOLOCK) On E.Cmp_ID = C.Cmp_Id Inner Join
			T0120_LOAN_APPROVAL LA WITH (NOLOCK) On L.Loan_Apr_Id = LA.Loan_Apr_ID Left Outer Join
			T0040_BANK_MASTER BMM WITH (NOLOCK) On LA.Bank_ID = BMM.Bank_Id
		order by Loan_apr_id,Installment_Date
	end
		end
	--PRINT CONVERT(VARCHAR(20), getdate(),114) + ' : STEP 6'
	RETURN
