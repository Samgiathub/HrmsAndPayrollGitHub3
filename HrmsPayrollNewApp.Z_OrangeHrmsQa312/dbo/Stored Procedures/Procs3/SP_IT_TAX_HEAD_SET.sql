



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_HEAD_SET]
 @Company_ID	numeric
,@From_date		datetime
,@To_Date		datetime
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @L_Def_ID				numeric
	Declare @Lable_Name			varchar(100)
	
	DECLARE @CONT_BASIC			NUMERIC 
	DECLARE @CONT_SUB_TOTAL_A	NUMERIC 
	DECLARE @CONT_BONUS			NUMERIC
	dECLARE @CONT_OT				NUMERIC
	DECLARE @CONT_LTA			NUMERIC
	DECLARE @CONT_SUB_TOTAL_B	NUMERIC
	DECLARE @CONT_TOTAL_A_B		NUMERIC
	DECLARE @CONT_FREE_ACCO		NUMERIC
	DECLARE @CONT_GROSS_SAL		NUMERIC
	DECLARE @CONT_NET_SAL_TAX	NUMERIC
	DECLARE @CONT_IT_UNDER_SAL	NUMERIC
	DECLARE @CONT_GROSS_IT		NUMERIC
	DECLARE @CONT_AGG_DEDU			NUMERIC
	DECLARE @CONT_TOTAL_TAXABLE_AMT	NUMERIC
	DECLARE @CONT_TOTAL_TAX		NUMERIC
	DECLARE @CONT_SURCHARGE			NUMERIC
	DECLARE @CONT_TOTAL_TAX_LIAB	NUMERIC
	DECLARE @CONT_CD_CESS			NUMERIC
	DECLARE @CONT_NET_LIAB			NUMERIC
	DECLARE @CONT_IT_AMT			NUMERIC
	DECLARE @CONT_PAID_IT_AMT		NUMERIC
	DECLARE @CONT_DUE_IT_AMT			NUMERIC
	DECLARE @CONT_HRA_EXEMPT			NUMERIC
	DECLARE @CONT_ANNUAL_SAL			NUMERIC
	DECLARE @CONT_HRA_RECEIVED			NUMERIC
	DECLARE @CONT_HRA_RECEIVED_A			NUMERIC
	DECLARE @CONT_ACTAUL_RENT_PAID			NUMERIC
	DECLARE @CONT_LESS_1_10_SAL			NUMERIC
	DECLARE @CONT_HRA_EXEM_DIFF			NUMERIC
	DECLARE @CONT_HRA_TWO_FIFTH			NUMERIC
	DECLARE @CONT_HRA_EXEMPTION			NUMERIC
	
	
	SET @CONT_BASIC				=3
	SET @CONT_SUB_TOTAL_A		=4
	SET @CONT_BONUS				=5
	SET @CONT_OT				=6
	SET @CONT_LTA				=7
	SET @CONT_SUB_TOTAL_B		=8
	SET @CONT_TOTAL_A_B			=9
	SET @CONT_FREE_ACCO			=10
	SET @CONT_GROSS_SAL			=11
	SET @CONT_NET_SAL_TAX		=12
	SET @CONT_IT_UNDER_SAL		=13
	SET @CONT_GROSS_IT			=14
	SET @CONT_AGG_DEDU			=15
	SET @CONT_TOTAL_TAXABLE_AMT	=16
	SET @CONT_TOTAL_TAX			=17
	SET @CONT_SURCHARGE			=18
	SET @CONT_TOTAL_TAX_LIAB	=19
	SET @CONT_CD_CESS			=20
	SET @CONT_NET_LIAB			=21
	SET @CONT_IT_AMT			=22
	SET @CONT_PAID_IT_AMT		=23
	SET @CONT_DUE_IT_AMT		=24
	SET @CONT_HRA_EXEMPT		=25
	SET @CONT_ANNUAL_SAL		=26
	SET @CONT_HRA_RECEIVED		=27
	SET @CONT_HRA_RECEIVED_A	=28
	SET @CONT_ACTAUL_RENT_PAID	=29
	SET @CONT_LESS_1_10_SAL		=30
	SET @CONT_HRA_EXEM_DIFF		=31
	SET @CONT_HRA_TWO_FIFTH		=32
	SET @CONT_HRA_EXEMPTION		=33
	
	/*		

 	INSERT INTO #Report_Lable
						  (L_Def_ID, Lable_Name)
	select @CONT_BASIC,'Basic Salary' 
	
	INSERT INTO #Report_Lable (Lable_Name,Allow_Dedu_ID,AD_Def_ID)
	select  Alias ,Allow_Dedu_ID,AD_IT_Def_ID from Allowance_Deduction_Master where Company_ID = @Company_ID and Earn_Dedu_Flag = 'E'  
		order by Sorting_no


	INSERT INTO #Report_Lable (Lable_Name)
	select REIMB_NAME from REIMBURSEMENT  where  Company_ID = @Company_ID and Reimb_Type= 'E' 
		order by Reimb_Display_level

 		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_SUB_TOTAL_A,'Sub Total - A'
		INSERT INTO #Report_Lable(Lable_Name) select ''
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_BONUS,'Add : Bonus/Ex-gratia' 
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_OT,'Over Time' 
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_LTA,'L.T.A.'
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) Select @CONT_SUB_TOTAL_B,'Sub Total - B' 
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_TOTAL_A_B,'Total A+B'
		INSERT INTO #Report_Lable(Lable_Name) select ''
		INSERT INTO #Report_Lable(Lable_Name) select	'Add :Perquisites' 
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_FREE_ACCO,'Free Accommodation'
		INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_GROSS_SAL,'Gross Salary'
		
		
		DECLARE @IT_ID		NUMERIC
		DECLARE @IT_NAME	VARCHAR(100)
		DECLARE @IS_FIRST	VARCHAR(1)	
		DECLARE @IS_third	VARCHAR(1)	
		DECLARE @INCOME_tAX_MAX_LIMIT  NUMERIC
		Declare @Level		numeric
		Declare @Income_TaX_flag char(1)
		
		
		SET @IS_FIRST = 'N'
		set @IS_third = 'N'
		SET @INCOME_tAX_MAX_LIMIT  = 0
		
		declare CUR_TAX_MASTER   cursor for
			SELECT INCOME_tAX_ID,INCOME_TAX_NAME,Income_Tax_Level ,INCOME_tAX_MAX_LIMIT,Income_TaX_flag FROM INCOME_TAX_MASTER 
			WHERE COMPANY_ID = @COMPANY_ID and Income_Tax_Flag <> 'N'
			ORDER BY INCOME_TAX_LEVEL
		open CUR_TAX_MASTER
		fetch next from CUR_TAX_MASTER into @IT_ID,@IT_NAME,@Level,@INCOME_tAX_MAX_LIMIT ,@Income_TaX_flag
		while @@fetch_status = 0
			begin
			if @level = 2  AND @IS_fIRST = 'N'
				begin
					SET @IS_FIRST = 'Y'
					INSERT INTO #Report_Lable (L_DEF_ID,Lable_Name) select @CONT_NET_SAL_TAX,'NET TOTAL SAL(TAXABLE)'
					INSERT INTO #Report_Lable (Lable_Name) select ' '
					INSERT INTO #Report_Lable (L_DEF_ID,Lable_Name) select @CONT_IT_UNDER_SAL,'Income Charge Under Salary'
					INSERT INTO #Report_Lable (Lable_Name) select ' '
				end 
			else if @level = 3  AND @IS_third = 'N'
				begin
					SET @IS_third = 'Y'
					INSERT INTO #Report_Lable(Lable_Name) select ' '
					INSERT INTO #Report_Lable(L_DEF_ID,Lable_Name) select @CONT_GROSS_IT ,'Gross Total Income'
					INSERT INTO #Report_Lable(Lable_Name) select ' '
				end 
			
			INSERT INTO #Report_Lable(Lable_Name) select @IT_NAME
			INSERT INTO #Report_Lable(Lable_Name,INCOME_TAX_ID,IT_SUB_DEF_ID,IT_Sub_ID) 
			
			SELECT IT_SUB_NAME ,@IT_ID ,IT_SUB_DEF_ID,IT_Sub_ID FROM INCOME_TAX_DETAIL WHERE COMPANY_ID = @COMPANY_ID AND INCOME_TAX_ID = @IT_ID
												ORDER BY IT_SUB_level


			IF @INCOME_TAX_MAX_LIMIT = 0
				INSERT INTO #Report_Lable(Income_tax_ID_Total,Lable_Name,Income_TaX_flag,IT_Max_Limit,Is_Eligible_Amt) select @IT_ID, 'Total ' + '' + @IT_NAME,@Income_TaX_flag,@INCOME_tAX_MAX_LIMIT,1
			else
				INSERT INTO #Report_Lable(Income_tax_ID_Total,Lable_Name,Income_TaX_flag,IT_Max_Limit,Is_Eligible_Amt) select @IT_ID, 'Total ' + '' + @IT_NAME,@Income_TaX_flag,@INCOME_tAX_MAX_LIMIT,0	
			
			IF @INCOME_TAX_MAX_LIMIT > 0
				BEGIN
					INSERT INTO #Report_Lable(Lable_Name,income_tax_ID,IT_Max_Limit) select '      MAX LIMIT',@it_ID,@INCOME_tAX_MAX_LIMIT
					INSERT INTO #Report_Lable(Income_tax_ID_Total,Lable_Name,Income_Tax_ID,Is_Eligible_Amt,Income_TaX_flag)	select @IT_ID,'     Eligible Deduction',@It_ID,1,@Income_TaX_flag
				END
								
			fetch next from CUR_TAX_MASTER into @IT_ID,@IT_NAME,@level,@INCOME_tAX_MAX_LIMIT ,@Income_TaX_flag
		end
		close CUR_TAX_MASTER
		deallocate CUR_TAX_MASTER

			
		INSERT INTO #Report_Lable(Lable_Name) select ''
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_AGG_DEDU, 'Aggregate Deduction'
		INSERT INTO #Report_Lable(Lable_Name) select ''
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_TOTAL_TAXABLE_AMT,'Total Taxable Amount'
			
	----------------------------------
		Declare @count as numeric 
		Declare @from_limit as numeric(18,2)
		Declare @To_limit as numeric(18,2)
		declare @IT_Percentage as numeric(18,2)
		declare @it_Round as numeric(18,2)
		Declare @Actual_IT_Amount as numeric(18,2)
		declare @Pre_To_Limit as numeric(18,2)
		DEclare @Temp_L_Def_ID as numeric 
		Declare @Temp_Name as varchar(100)
		Declare @Temp_IT_Amount as numeric ( 27,2)
		Declare @Name as varchar(100)
		Declare @Temp_Count as numeric 
				
		set @count =0
		set @from_limit =0
		set @To_limit = 0 
		set @IT_Percentage =0
		set @it_Round =0
		set @Actual_IT_Amount =0
		set @Pre_To_Limit =0
		set @Temp_IT_Amount = 0
		set @Temp_Count = 0
				
				
		INSERT INTO #Report_Lable (Lable_Name) select ''
	
		select @Count = count(from_limit)  from Income_Tax_Setting where company_id = @company_id 
			
		declare curIncomeTax cursor for
		select from_limit,to_limit,Percentage , Row_ID from Income_Tax_Setting where company_id = @company_id 
		and For_Date = (select Max(For_Date)  from Income_Tax_Setting Where Company_ID = @Company_ID
											and For_Date <=@To_Date )
		order by Row_ID
		open curIncomeTax
		fetch next from curIncomeTax into @From_Limit,@To_Limit,@IT_Percentage,@Temp_Count 
			while @@fetch_status = 0
				begin
					set @Name = cast(@From_Limit as varchar(10)) + ' To ' +  cast(@to_Limit as varchar(10))
					
					INSERT INTO #Report_Lable(Lable_Name)	select @Name

					set @Temp_Name = cast(@From_Limit as varchar(10)) + ' To ' +  cast(@to_Limit as varchar(10)) + ' Per.  ' + cast(@IT_Percentage as varchar(10))
					
					set @Temp_L_Def_ID  = @L_Def_ID +  @Count + 1
					
					if @Temp_count = 1
						begin
							INSERT INTO #Report_Lable (Lable_Name) select ''
							
							INSERT INTO #Report_Lable (Lable_Name) select 'Tax Liabilities'

							INSERT INTO #Report_Lable (Lable_Name) select ''
						end
					
					INSERT INTO #Report_Lable (Lable_Name) select @Temp_Name

					fetch next from curIncomeTax into @From_Limit,@To_Limit,@IT_Percentage,@Temp_Count 
				end
		close curIncomeTax
		deallocate curIncomeTax

		INSERT INTO #Report_Lable(Lable_Name) select ''
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_TOTAL_TAX,'Total Tax'
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_SURCHARGE,'Surcharge @10% on Tax'
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_TOTAL_TAX_LIAB,'Total Tax Liabilities'
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_CD_CESS,'Ed. Cess 2%'
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_NET_LIAB,'Net Tax Liabilities'
			
	-------------- 	

		INSERT INTO #Report_Lable(Lable_Name) select '' 
		INSERT INTO #Report_Lable(Lable_Name) select '' 
		INSERT INTO #Report_Lable(l_Def_Id,Lable_Name) select @CONT_IT_AMT,'Income Tax'
		INSERT INTO #Report_Lable(Lable_Name) select ''
 

		DECLARE @MONTH_NAME VARCHAR(20)
		Declare @Temp_Date	Datetime 
		Declare @Month numeric 
		set @Temp_Date = @From_Date
		While @Temp_Date <=@To_DAte
			begin
				set @Month = Month(@Temp_DaTE)
				EXEC GETMONTHNAME @Month,@MONTH_NAME OUTPUT
				INSERT INTO #Report_Lable(Lable_Name) select @MONTH_NAME	
					
				set @Temp_Date = dateadd(m,1,@Temp_Date)
			end

			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_PAID_IT_AMT,'Total Paid Income Tax'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_DUE_IT_AMT,'Due Income Tax' 
			INSERT INTO #Report_Lable(Lable_Name)	select '' 
			INSERT INTO #Report_Lable(Lable_Name)	select '' 
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_EXEMPT,'HOUSE RENT ALLOWANCE EXEMPT'
			INSERT INTO #Report_Lable(Lable_Name)	select ''
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_ANNUAL_SAL,'Annual Salary ( Exclusive benefits and Perquisites)'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_RECEIVED,'House Rent Allowance Received'
			INSERT INTO #Report_Lable(Lable_Name)	select 'Less : Exemption u/s 10 (13A) read with rule 2 A'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_RECEIVED_A,'A ) House rent allowance Received'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_ACTAUL_RENT_PAID,'B ) Actual Rent Paid'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_LESS_1_10_SAL,'Less : 1/10 of Salary'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_EXEM_DIFF,'Different Amount'
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_TWO_FIFTH,'C ) Two Fifth of Salary'
			INSERT INTO #Report_Lable(Lable_Name)	select ''
			INSERT INTO #Report_Lable(l_Def_Id,Lable_Name)	select @CONT_HRA_EXEMPTION,'House rent Allow. Exempted ( least of a,b or c )'
			

		
		*/


	RETURN
	
			
			

