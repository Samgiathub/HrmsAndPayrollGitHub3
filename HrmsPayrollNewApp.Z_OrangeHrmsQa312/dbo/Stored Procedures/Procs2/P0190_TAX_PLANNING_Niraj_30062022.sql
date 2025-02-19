CREATE PROCEDURE [dbo].[P0190_TAX_PLANNING_Niraj_30062022] 
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
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 -- Add By Mukti 20072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
 -- Add By Mukti 20072016(end)	

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
	VALUES  (@IT_TRAN_ID,@Cmp_ID,@Emp_ID,@From_Date,@To_Date,@For_Date,@Taxable_Amount,@IT_Y_Amount,@IT_Y_Surchege_Amount,@IT_Y_ED_Cess_Amount,@IT_Y_Final_Amount,@IT_Y_Paid_Amount,@Month_Remain_For_Salary,@IT_M_Amount,@IT_M_Surcharge_Amount,0,@IT_M_Final_Amount,@IT_Repeat,@IT_Multiple_Month,@Login_ID,GETDATE(),@IT_Declaration_Calc_On)
				
	  -- Add By Mukti 20072016(start)
			exec P9999_Audit_get @table = 'T0190_TAX_PLANNING' ,@key_column='Tran_ID',@key_Values=@IT_TRAN_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
	  -- Add By Mukti 20072016(end)	
	End

IF @tran_type = 'D'
	BEGIN
		-- Add By Mukti 20072016(start)
			exec P9999_Audit_get @table='T0190_TAX_PLANNING' ,@key_column='Tran_ID',@key_Values=@IT_TRAN_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
		-- Add By Mukti 20072016(end)
			DELETE FROM T0190_TAX_PLANNING WHERE TRAN_ID = @IT_TRAN_ID
	END
	
	 exec P9999_Audit_Trail @CMP_ID,@tran_type,'IT Tax Planning',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN




