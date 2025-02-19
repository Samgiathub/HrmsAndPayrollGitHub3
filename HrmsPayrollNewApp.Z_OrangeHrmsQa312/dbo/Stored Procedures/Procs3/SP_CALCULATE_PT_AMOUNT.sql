

CREATE PROCEDURE [dbo].[SP_CALCULATE_PT_AMOUNT]
	@CMP_ID					NUMERIC ,
	@EMP_ID					NUMERIC ,
	@FOR_DATE				DATETIME ,
	@PT_CALCULATED_AMOUNT	NUMERIC,
	@PT_AMOUNT				NUMERIC(16,2) OUTPUT ,
	@PT_F_T_LIMIT			VARCHAR(20) OUTPUT,
	@Branch_ID				numeric = 0,
	@Is_Fnf					numeric = 0
AS
	 SET NOCOUNT ON;    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SET ARITHABORT ON  

	declare @From_Limit as numeric(27,0)
	declare @To_Limit as numeric(27,0)
	declare @PT_Amt as numeric(16,2)
	declare @PT_Deduction_Type as varchar(100) -- Added by nilesh patel on 09102014
	declare @PT_Deduction_Month as varchar(100) -- Added by nilesh patel on 09102014
	declare @For_date_month as varchar(50) -- Added by nilesh patel on 09102014
	declare @PT_Amount_Calaculate_Qutertly as numeric(27,0) -- Added by nilesh patel on 31102014

	-- Added by Hardik 28/01/2021 for HMP as Gujarat State employee if Age is above 65 then PT should not deduct
	DECLARE @Date_Of_Birth DATETIME
	DECLARE @Age NUMERIC(18,2)

	SELECT @Date_Of_Birth = Date_Of_Birth, @Age = DBO.F_GET_AGE (Date_Of_Birth,@For_date,'N','N')
	From T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_Id = @Emp_Id

	
	set @PT_Amount = 0
	set @From_Limit = 0
	set @To_Limit = 0
	set @PT_Amt = 0 
	--Set @PT_Amount_Calaculate_Qutertly = 0
	if @Branch_ID = 0
		set @Branch_ID = null
	
	-----'' For PT Applicable MALE/FEMALE ''------Ankit 20052015
	
	DECLARE @Applicable_PT_Male_Female		Varchar(10)
	DECLARE @Emp_Gender			Varchar(5)
	DECLARE @State_ID			NUMERIC(18,0)
	DECLARE @Applicable_PT_Male_Female_State	NUMERIC(18,0)
	DECLARE @STATE_NAME varchar(50)
	
	SET @Applicable_PT_Male_Female = 'ALL'
	SET @Emp_Gender = 'M'
	SET @State_ID = 0
	SET @Applicable_PT_Male_Female_State = 0
	
	SELECT @State_ID = ISNULL(State_ID,0) FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Branch_ID = @Branch_ID AND Cmp_ID = @CMP_ID
		
	IF @State_ID > 0
		BEGIN
			SELECT @Applicable_PT_Male_Female_State = ISNULL(Applicable_PT_Male_Female,0), @STATE_NAME = Upper(State_Name)
			FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE State_ID = @State_ID AND Cmp_ID = @CMP_ID

			-- Added by Hardik 28/01/2021 for HMP as Gujarat State employee if Age is above 65 then PT should not deduct
			IF UPPER(@STATE_NAME) = 'GUJARAT' AND @AGE > 65
				BEGIN
					SET @PT_AMOUNT = 0
					SET @PT_F_T_LIMIT = 0
					SET @PT_CALCULATED_AMOUNT = 0
					RETURN
				END

			IF @Applicable_PT_Male_Female_State = 1
				BEGIN
					SELECT @Emp_Gender = Gender FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @EMP_ID AND Cmp_ID = @CMP_ID
					IF @Emp_Gender = 'M'
						SET @Applicable_PT_Male_Female = 'MALE'
					Else IF @Emp_Gender = 'F'
						SET @Applicable_PT_Male_Female = 'FEMALE'
					Else
						SET @Applicable_PT_Male_Female = 'ALL'
						
				END
		END
		
	-----'' For PT Applicable MALE/FEMALE ''------

-- Added by nilesh patel on 09102014 --Start	
	--Changes below query to inner join Deepal 03072020
	--Select @PT_Deduction_Month = ISNULL(PT_Deduction_Month,'0'),@PT_Deduction_Type = ISNULL(PT_Deduction_Type,'Monthly') 
	--From T0020_STATE_MASTER S , t0030_branch_master B where S.State_ID = B.State_ID and B.branch_id = @Branch_ID
	--End Changes below query to inner join Deepal 03072020
	Select @PT_Deduction_Month = ISNULL(PT_Deduction_Month,'0'),@PT_Deduction_Type = ISNULL(PT_Deduction_Type,'Monthly') 
	From T0020_STATE_MASTER S WITH (NOLOCK) INNER JOIN t0030_branch_master B WITH (NOLOCK) on S.State_ID = B.State_ID 
	where B.branch_id = @Branch_ID
	
	if @Is_Fnf = 1 
		Begin
			if @PT_Deduction_Month <> '0' and @PT_Deduction_Type <> 'Monthly'
				Set @For_date_month = 1
				--Select @For_date_month =  charindex('#' + Cast(month(@For_Date) as Varchar(50)) + '#','#' + @PT_Deduction_Month + '#') -- Comment by nilesh patel on 20092016
			Else
				Set @For_date_month = 0
		End 
	Else
		Begin
			Select @For_date_month =  charindex('#' + Cast(month(@For_Date) as Varchar(50)) + '#','#' + @PT_Deduction_Month + '#')
		End
	
	-- Added by nilesh patel on 09102014 --End	
	
		-- Added by nilesh patel on 31102014 --Start -- For Calculation Net Salary 
		Declare @For_Date_PT AS DATETIME	
		Declare @To_Date_PT AS DATETIME	
		Declare @Last_PT_Deduction_Date AS DATETIME
		
		if @For_date_month <> '0'
		Begin
			if @Is_Fnf = 1 --Added by nilesh patel on 19112015 For FNF PT Calculation
				Begin
					Select @Last_PT_Deduction_Date = Isnull(MAX(Month_End_Date),'') From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Cmp_ID = @CMP_ID and Emp_ID = @EMP_ID and Month_St_Date <= @FOR_DATE and PT_Amount <> 0
				End
						   	  
			if @PT_Deduction_Type = 'Quaterly'
			  Begin
				if @Is_Fnf = 1 
					Begin
						Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						if Month(@Last_PT_Deduction_Date) = 12
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(1)),(year(@Last_PT_Deduction_Date)+1))
							End
						Else
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(@Last_PT_Deduction_Date)+1),year(@Last_PT_Deduction_Date))
							End
					End 
				Else
					Begin
						Set @To_Date_PT =  dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						Set @For_Date_PT = dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-1,@To_Date_PT)),Year(DATEADD(MM,-1,@To_Date_PT)))
					End
					
				Select @PT_Amount_Calaculate_Qutertly = Isnull(SUM(Gross_Salary),0) From T0200_MONTHLY_SALARY  WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID  and Month_St_Date >= @For_Date_PT and Month_End_Date <= @To_Date_PT
				set @PT_CALCULATED_AMOUNT = @PT_CALCULATED_AMOUNT + @PT_Amount_Calaculate_Qutertly
			  End
			else if  @PT_Deduction_Type = 'Half Yearly'
			  Begin
			  
				--Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)- 1),year(@For_Date))
				--Set @To_Date_PT =  DATEADD(month,-1,dbo.GET_MONTH_END_DATE((Month(@For_Date)),year(@For_Date)))
				if @Is_Fnf = 1 
					Begin
						Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						if Month(@Last_PT_Deduction_Date) = 12
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(1)),(year(@Last_PT_Deduction_Date)+1))
							End
						Else
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(@Last_PT_Deduction_Date)+1),year(@Last_PT_Deduction_Date))
							End
					End 
				Else
					Begin
						Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						Set @For_Date_PT = dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-4,@To_Date_PT)),Year(DATEADD(MM,-4,@To_Date_PT)))
					End
				
				Select @PT_Amount_Calaculate_Qutertly = Isnull(SUM(Gross_Salary),0) From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID  and Month_St_Date >= @For_Date_PT and Month_End_Date <= @To_Date_PT
				set @PT_CALCULATED_AMOUNT = @PT_CALCULATED_AMOUNT + @PT_Amount_Calaculate_Qutertly
				
			  End
			else if  @PT_Deduction_Type = 'Yearly'
			  Begin
			  
				--Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)- 1),year(@For_Date))
				--Set @To_Date_PT =  DATEADD(month,-1,dbo.GET_MONTH_END_DATE((Month(@For_Date)),year(@For_Date)))
				if @Is_Fnf = 1 
					Begin
						Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						
						if Month(@Last_PT_Deduction_Date) = 12
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(1)),(year(@Last_PT_Deduction_Date)+1))
							End
						Else
							Begin
								Set @For_Date_PT = dbo.GET_MONTH_ST_DATE((Month(@Last_PT_Deduction_Date)+1),year(@Last_PT_Deduction_Date))
							End
					End 
				Else
					Begin
						Set @To_Date_PT = dbo.GET_MONTH_END_DATE((Month(@For_Date)-1),year(@For_Date))
						Set @For_Date_PT = dbo.GET_MONTH_ST_DATE(Month(DATEADD(MM,-10,@To_Date_PT)),Year(DATEADD(MM,-10,@To_Date_PT)))
					End
				Select @PT_Amount_Calaculate_Qutertly = ISNULL(SUM(Gross_Salary),0) From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID  and  Month_St_Date >= @For_Date_PT and Month_End_Date <= @To_Date_PT
				set @PT_CALCULATED_AMOUNT = @PT_CALCULATED_AMOUNT + @PT_Amount_Calaculate_Qutertly
			  End
		End
	-- Added by nilesh patel on 31102014 --End
		
		
	if exists(select Cmp_ID from dbo.T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date And isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) And Applicable_PT_Male_Female = @Applicable_PT_Male_Female)
			And @STATE_NAME IN ('MAHARASHTRA', 'MADHYA PRADESH')
		begin		
				DECLARE curPT CURSOR FOR
				select from_limit,to_limit,Amount from dbo.T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0))
				And Applicable_PT_Male_Female = @Applicable_PT_Male_Female
				and For_date = (
				select max(For_Date) from dbo.T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and For_Date <=@For_Date And isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) And Applicable_PT_Male_Female = @Applicable_PT_Male_Female)
				order by row_id
				-- remove from the AVALON  and month(for_date) <= month(@for_date) 28998
		end
	-- Comment by nilesh patel on 09102014 as per discuss with Hardik bhai 
	/*Else if exists(select Cmp_ID from dbo.T0040_professional_setting where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)))
		begin		
			declare curPT cursor for
				select from_limit,to_limit,Amount from dbo.T0040_professional_setting where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0))
				and For_date = (
				select max(For_Date) from dbo.T0040_professional_setting where Cmp_ID = @Cmp_ID and For_Date <=@For_Date and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) and month(for_date) <= month(@for_date))
				order by row_id
		end*/
	else
	--select @To_Limit,@PT_CALCULATED_AMOUNT,@from_limit,@PT_AMOUNT,@PT_Amt
	--return
		begin	
				DECLARE curPT CURSOR FOR
				select from_limit,to_limit,Amount from dbo.T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID And Applicable_PT_Male_Female = @Applicable_PT_Male_Female 
				and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) and For_date = (
				select max(For_Date) from dbo.T0040_professional_setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and isnull(Branch_ID,0) = isnull(@Branch_ID,isnull(Branch_ID,0)) and For_Date <=@For_Date And Applicable_PT_Male_Female = @Applicable_PT_Male_Female )
				order by row_id
		end
	 
	Begin	
	open curPT
	fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt
		while @@fetch_status = 0
			begin
				if @PT_Deduction_Type = 'Monthly'
					BEGIN			
						if @To_Limit = 0 
							begin
								if @PT_CALCULATED_AMOUNT >= @from_limit 
									BEGIN
										set @PT_Amount = @Pt_Amt
										SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
									END
							end 
						else	
							begin
								if @PT_CALCULATED_AMOUNT >= @from_limit  and @PT_CALCULATED_AMOUNT < (@To_Limit + 1)
									BEGIN
										set @PT_Amount = @Pt_Amt
										SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
									END 
							end
					End
				Else
					BEGIN
						if @For_date_month <> '0' 
							Begin		
							   if @To_Limit = 0 
								begin
								 if @PT_CALCULATED_AMOUNT >= @from_limit 
									BEGIN
										set @PT_Amount = @Pt_Amt
										SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
									END
								end 
							   else	
								begin
								if @PT_CALCULATED_AMOUNT >= @from_limit  and @PT_CALCULATED_AMOUNT < (@To_Limit + 1)
									BEGIN
										set @PT_Amount = @Pt_Amt
										SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
									END 
								end
							end
						Else
							Begin
							  set @PT_Amount = 0
							  SET @PT_F_T_LIMIT = '0'
							End					
					End
			
				fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt					
			end
		-- close curPT
	 End
	--Else
	--Begin
	-- open curPT
	--   fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt
	--	while @@fetch_status = 0
	--		begin
	--			if @For_date_month <> '0' 
	--				Begin		
	--			       if @To_Limit = 0 
	--				    begin
	--					 if @PT_CALCULATED_AMOUNT >= @from_limit 
	--						BEGIN
	--							set @PT_Amount = @Pt_Amt
	--							SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
	--						END
	--				    end 
	--			       else	
	--				    begin
	--					if @PT_CALCULATED_AMOUNT >= @from_limit  and @PT_CALCULATED_AMOUNT < (@To_Limit + 1)
	--						BEGIN
	--							set @PT_Amount = @Pt_Amt
	--							SET @PT_F_T_LIMIT 	 = CAST(@from_limit  AS VARCHAR(10)) + '-'+ CAST(@TO_LIMIT AS VARCHAR(10))
	--						END 
	--				    end
	--				end
	--			Else
	--				Begin
	--				  set @PT_Amount = 0
	--				  SET @PT_F_T_LIMIT = '0'
	--			    End
	--			fetch next from curPT into @From_Limit,@To_Limit,@Pt_Amt					
	--		end
	
	--End
	close curPT
	deallocate curPT
	
	RETURN



