CREATE PROCEDURE [dbo].[P0190_TAX_PLANNING] 
@IT_TRAN_ID				NUMERIC output
,@Cmp_ID					NUMERIC
,@Emp_ID                    NUMERIC
,@From_Date					DATETIME
,@To_Date					DATETIME
,@For_Date					DATETIME
,@Taxable_Amount			NUMERIC
,@IT_Y_Amount				NUMERIC
,@IT_Y_Surchege_Amount		NUMERIC
,@IT_Y_ED_Cess_Amount		NUMERIC	
,@IT_Y_Final_Amount			NUMERIC
,@IT_Y_Paid_Amount			NUMERIC
,@Month_Remain_For_Salary	NUMERIC
,@IT_M_Amount				NUMERIC
,@IT_M_Surcharge_Amount		NUMERIC
,@IT_M_ED_Cess_Amount		NUMERIC
,@IT_M_Final_Amount			NUMERIC
,@IT_Repeat					TINYINT
,@IT_Multiple_Month			VARCHAR(50)
,@Login_ID					NUMERIC
,@tran_type					CHAR
,@User_Id numeric(18,0) = 0 -- Add By Mukti 20072016
,@IP_Address varchar(30)= '' -- Add By Mukti 20072016
,@IT_Declaration_Calc_On	VARCHAR(20) --Hardik 22/03/2019
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	-- Add By Mukti 20072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	-- Add By Mukti 20072016(end)	
 
	DECLARE @SAL_TRAN_EMP_ID varchar(max)
	DECLARE @Salary_Params nvarchar(max)
	DECLARE @ID varchar(100) = NEWID()
	DECLARE @GUID varchar(100) = NEWID()
	DECLARE @Sal_Tran_ID int = 0
	DECLARE @Salary_Setting int = 0
	DECLARE @Is_Monthly int = 0
	DECLARE @P_Days numeric(18,2) = 0.00

	Select @Salary_Setting = Isnull(Setting_Value,0) From dbo.T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='Enable Auto Re-Process Salary with Tax Planning'
	--Select @Is_Monthly = is_Monthly_Salary
	Truncate Table T0211_Salary_Processing_Status
	Truncate Table Salary_Temp_Table

	if @tran_type = 'I'
	Begin
		IF EXISTS(SELECT TRAN_ID From T0190_TAX_PLANNING WITH (NOLOCK) WHERE FROM_DATE = @From_Date AND TO_DATE = @To_Date AND FOR_DATE = @For_Date AND Emp_ID = @Emp_ID)
		BEGIN
			
			SET @IT_TRAN_ID = 0
			RETURN 
		END
		SELECT @IT_TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0190_TAX_PLANNING WITH (NOLOCK)		
		
		INSERT INTO T0190_TAX_PLANNING 
		(Tran_ID,Cmp_ID,Emp_Id,From_Date,To_Date,For_Date,Taxable_Amount,IT_Y_Amount,IT_Y_Surcharge_Amount,IT_Y_ED_Cess_Amount,IT_Y_Final_Amount,IT_Y_Paid_Amount,Month_Remain_For_Salary,IT_M_Amount,IT_M_Surcharge_Amount,IT_M_ED_Cess_Amount,IT_M_Final_Amount,Is_Repeat,IT_Multiple_Month,Login_ID,System_Date,IT_Declaration_Calc_On)
		VALUES  (@IT_TRAN_ID,@Cmp_ID,@Emp_ID,@From_Date,@To_Date,@For_Date,@Taxable_Amount,@IT_Y_Amount,@IT_Y_Surchege_Amount,@IT_Y_ED_Cess_Amount,@IT_Y_Final_Amount,@IT_Y_Paid_Amount,@Month_Remain_For_Salary,@IT_M_Amount,@IT_M_Surcharge_Amount,@IT_M_ED_Cess_Amount,@IT_M_Final_Amount,@IT_Repeat,@IT_Multiple_Month,@Login_ID,GETDATE(),@IT_Declaration_Calc_On)
		
		-- Add By Mukti 20072016(start)
		exec P9999_Audit_get @table = 'T0190_TAX_PLANNING' ,@key_column='Tran_ID',@key_Values=@IT_TRAN_ID,@String=@String output
		set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 20072016(end)	
		--Start Added by Niraj (09062022)

		IF (@Salary_Setting = 1)
		Begin
			SET @GUID = format(getdate(), 'HHmmss') + SUBSTRING(@GUID, 1, 6)
			SET @ID = REPLACE(@ID, RIGHT(@ID, CHARINDEX('-',REVERSE(@ID))-1),'') + @GUID
			DECLARE @EO_Date datetime = EOMONTH(@For_Date)
			DECLARE @Cons varchar(10) = @Emp_ID
			Select @Sal_Tran_ID = isnull(Sal_Tran_ID,0), @Is_Monthly = is_Monthly_Salary, @P_Days = Present_Days from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Month_St_Date between @For_Date and @EO_Date

			insert into Salary_Temp_Table
			values(ISNULL(@Sal_Tran_ID,0),ISNULL(@Emp_ID,0), 0)
			
			--exec SP_EMP_SALARY_RECORD_GET1 @Cmp_ID=@Cmp_ID, @From_Date=@For_Date, @To_Date=@EO_Date, @Branch_ID=0,@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID = @Emp_ID, @Constraint='',@Salary_Status='All',@Salary_Cycle_id=0,@Branch_Constraint='',@Segment_ID='',@Vertical='',@SubVertical='',@SubBranch='',@FilterType='0'
			exec SP_IT_TAX_PREPARATION @Cmp_ID= @Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=@Emp_ID,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name='',@Form_ID=89,@Sp_Call_For='Tax Planning',@Month_En_Date=@EO_Date,@Month_St_Date=@For_Date,@Salary_Cycle_id=0,@Segment_ID='',@Vertical='',@SubVertical='',@subBranch='',@IT_Declaration_Calc_On=@IT_Declaration_Calc_On
			
			--exec SP_IT_TAX_PREPARATION @Cmp_ID=121,@From_Date='2022-04-01 00:00:00',@To_Date='2023-03-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID =21583,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name='',@Form_ID=89,@Sp_Call_For='Tax Planning',@Month_En_Date='31-May-2022',@Month_St_Date='01-May-2022',@Salary_Cycle_id=0,@Segment_ID='',@Vertical='',@SubVertical='',@subBranch='',@IT_Declaration_Calc_On='On_Approved'	
			
			IF (@Sal_Tran_ID) > 0 --AND MONTH(@For_Date) = 3
			Begin
				--Select @SAL_TRAN_EMP_ID = CAST(Sal_Tran_ID as varchar(50))+'-'+CAST(EMP_ID as varchar(50))+',' , @IT_M_Amount = IT_M_Amount, @Sal_Tran_ID = Sal_Tran_ID FROM Salary_Temp_Table
				--exec P0200_MONTHLY_SALARY_DELETE_NEW1 @SAL_TRAN_ID_EMP_ID=@SAL_TRAN_EMP_ID,@CMP_ID=@Cmp_ID,@From_Date=@For_Date,@to_date=@To_Date,@User_Id=@User_Id,@IP_Address=@IP_Address
		
				Select @IT_M_Amount = IT_M_Amount, @Sal_Tran_ID = Sal_Tran_ID FROM Salary_Temp_Table where EMP_ID = @Emp_ID
				
				Truncate Table T0211_Salary_Processing_Status
				Insert Into T0211_Salary_Processing_Status(GUID_Part,TotalCount)
				Values(@GUID,1)
				
				IF(@Is_Monthly = 1)
					BEGIN
						SET @Salary_Params = CAST(@Sal_Tran_ID as varchar(20)) + '#'+CAST(@EMP_ID as varchar(50))+'#'+CAST(@Cmp_ID as varchar(50))+'#'+CAST(GETDATE() as varchar(50))+'#'+cast(@For_Date as varchar(50))+'#'+CAST(@EO_Date as varchar(50))+'#0#0#'+CAST(@IT_M_Amount as varchar(50))+'#0#0#0#1#'+CAST(@User_Id as varchar(50))+'#Yes#1#Done#0#0#1#0#0#'+CAST(@User_Id as varchar(50))+'#'+@IP_Address+'#1'
						SET @Is_Monthly = 0
					END
				ELSE
					BEGIN
						SET @Salary_Params = CAST(@Sal_Tran_ID as varchar(20)) + '#'+CAST(@EMP_ID as varchar(50))+'#'+CAST(@Cmp_ID as varchar(50))+'#'+CAST(GETDATE() as varchar(50))+'#'+cast(@For_Date as varchar(50))+'#'+CAST(@EO_Date as varchar(50))+'#'+CAST(@P_Days as varchar(50))+'#0#0#'+CAST(@IT_M_Amount as varchar(50))+'#0#0#0#1#'+CAST(@User_Id as varchar(50))+'#Yes#Y#Done#0#0#1#'+CAST(@User_Id as varchar(50))+'#'+@IP_Address+'#1'
						SET @Is_Monthly = 1
					END
				exec P0200_Pre_Salary @Salary_Parameter= @Salary_Params, @is_Manual= @Is_Monthly, @cmp_id= @Cmp_ID, @from_date= @For_Date, @to_date=@EO_Date, @ID=@ID,@BackEnd_Salary=0	
				Truncate Table T0211_Salary_Processing_Status
			End
		End
		--End Added by Niraj (09062022)
	End

	IF @tran_type = 'D'
	BEGIN
		-- Add By Mukti 20072016(start)
		exec P9999_Audit_get @table='T0190_TAX_PLANNING' ,@key_column='Tran_ID',@key_Values=@IT_TRAN_ID,@String=@String output
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add By Mukti 20072016(end)

		Select @Emp_ID = EMP_ID, @From_Date = From_Date, @To_Date = To_Date, @For_Date = For_Date FROM T0190_TAX_PLANNING WHERE TRAN_ID = @IT_TRAN_ID
		DELETE FROM T0190_TAX_PLANNING WHERE TRAN_ID = @IT_TRAN_ID

		exec P9999_Audit_Trail @CMP_ID,@tran_type,'IT Tax Planning',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
		--Start Added by Niraj (09062022)
		IF (@Salary_Setting = 1)
		Begin
			SET @GUID = format(getdate(), 'HHmmss') + SUBSTRING(@GUID, 1, 6)
			SET @ID = REPLACE(@ID, RIGHT(@ID, CHARINDEX('-',REVERSE(@ID))-1),'') + @GUID
			DECLARE @EOD_Date datetime = EOMONTH(@For_Date)

			Select @Sal_Tran_ID = isnull(Sal_Tran_ID,0), @Is_Monthly = is_Monthly_Salary, @P_Days = Present_Days from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Month_St_Date between @For_Date and @EOD_Date
			--exec SP_EMP_SALARY_RECORD_GET1 @Cmp_ID=@Cmp_ID, @From_Date=@For_Date, @To_Date=@EOD_Date, @Branch_ID=0,@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID = @Emp_ID, @Constraint='',@Salary_Status='All',@Salary_Cycle_id=0,@Branch_Constraint=@Cons,@Segment_ID='',@Vertical='',@SubVertical='',@SubBranch='',@FilterType='0'
			--exec SP_IT_TAX_PREPARATION @Cmp_ID= @Cmp_ID,@From_Date=@For_Date,@To_Date=@To_Date,@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=@Emp_ID,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name='',@Form_ID=89,@Sp_Call_For='Tax Planning',@Month_En_Date=@EOD_Date,@Month_St_Date=@For_Date,@Salary_Cycle_id=0,@Segment_ID='',@Vertical='',@SubVertical='',@subBranch='',@IT_Declaration_Calc_On='On_Regular'	
			insert into Salary_Temp_Table
			values(ISNULL(@Sal_Tran_ID,0),ISNULL(@Emp_ID,0), 0)
			
			IF (@Sal_Tran_ID) > 0 --AND MONTH(@For_Date) = 3
			Begin
				Select @SAL_TRAN_EMP_ID = CAST(Sal_Tran_ID as varchar(50))+'-'+CAST(EMP_ID as varchar(50))+',' FROM Salary_Temp_Table where EMP_ID = @Emp_ID
				exec P0200_MONTHLY_SALARY_DELETE_NEW1 @SAL_TRAN_ID_EMP_ID=@SAL_TRAN_EMP_ID,@CMP_ID=@Cmp_ID,@From_Date=@For_Date,@to_date=@EOD_Date,@User_Id=@User_Id,@IP_Address=@IP_Address
				
				--exec SP_IT_TAX_PREPARATION @Cmp_ID= @Cmp_ID,@From_Date=@For_Date,@To_Date=@To_Date,@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID =@Emp_ID,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name='',@Form_ID=89,@Sp_Call_For='Tax Planning',@Month_En_Date=@EOD_Date,@Month_St_Date=@For_Date,@Salary_Cycle_id=0,@Segment_ID='',@Vertical='',@SubVertical='',@subBranch='',@IT_Declaration_Calc_On='On_Regular'	
				Select @IT_M_Amount = 0, @Sal_Tran_ID = Sal_Tran_ID FROM Salary_Temp_Table where EMP_ID = @Emp_ID
				
				Truncate Table T0211_Salary_Processing_Status
				Insert Into T0211_Salary_Processing_Status(GUID_Part,TotalCount)
				Values(@GUID,1)

				IF(@Is_Monthly = 1)
					BEGIN
						SET @Salary_Params = '0#'+CAST(@EMP_ID as varchar(50))+'#'+CAST(@Cmp_ID as varchar(50))+'#'+CAST(GETDATE() as varchar(50))+'#'+cast(@For_Date as varchar(50))+'#'+CAST(@EOD_Date as varchar(50))+'#0#0#'+CAST(@IT_M_Amount as varchar(50))+'#0#0#0#1#'+CAST(@User_Id as varchar(50))+'#Yes#1##0#0#1#0#0#'+CAST(@User_Id as varchar(50))+'#'+@IP_Address+'#1'
						SET @Is_Monthly = 0
					END
				ELSE
					BEGIN
						SET @Salary_Params = '0#'+CAST(@EMP_ID as varchar(50))+'#'+CAST(@Cmp_ID as varchar(50))+'#'+CAST(GETDATE() as varchar(50))+'#'+cast(@For_Date as varchar(50))+'#'+CAST(@EOD_Date as varchar(50))+'#'+CAST(@P_Days as varchar(50))+'#0#0#'+CAST(@IT_M_Amount as varchar(50))+'#0#0#0#1#'+CAST(@User_Id as varchar(50))+'#Yes#Y##0#0#1#'+CAST(@User_Id as varchar(50))+'#'+@IP_Address+'#1'
						SET @Is_Monthly = 1
					END
				--SET @Salary_Params = '0#'+CAST(@EMP_ID as varchar(50))+'#'+CAST(@Cmp_ID as varchar(50))+'#'+CAST(GETDATE() as varchar(50))+'#'+cast(@For_Date as varchar(50))+'#'+CAST(@EOD_Date as varchar(50))+'#0#0#'+CAST(@IT_M_Amount as varchar(50))+'#0#0#0#1#'+CAST(@User_Id as varchar(50))+'#Yes#1#Done#0#0#1#0#0#'+CAST(@User_Id as varchar(50))+'#'+@IP_Address+'#1'
				exec P0200_Pre_Salary @Salary_Parameter= @Salary_Params, @is_Manual=@Is_Monthly, @cmp_id= @Cmp_ID, @from_date= @For_Date, @to_date=@EOD_Date, @ID=@ID,@BackEnd_Salary=0
				Truncate Table T0211_Salary_Processing_Status
			End
		End
	END
	Truncate Table T0211_Salary_Processing_Status
	Truncate Table Salary_Temp_Table
	--End Added by Niraj (09062022)
	RETURN
END