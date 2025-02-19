

-- =============================================
-- Author:		Mukti Chauhan
-- Create date: 20/04/2017
-- Description:	Employee Slab wise Bonus 
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Bonus_Slabwise]
    @Tran_ID Numeric(18,0) output,
    @From_date datetime,
    @To_date datetime,
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Gross_Salary Numeric(18,2),  
    @Working_Days Numeric(18,2),
    @Eligible_Day Numeric(18,2),
    @Paid_Day Numeric(18,2),
    @Leave_Slab Numeric(18,2),
    @Bonus_Amount Numeric(18,2),
    @Additional_Amount Numeric(18,2),
    @Bonus_Effect_on_Sal	numeric(18, 0),
	@Bonus_Effect_Month	numeric(18, 0),
	@Bonus_Effect_Year	numeric(18, 0),
	@Bonus_Comments	varchar(500),
    @Tran_Type char(1),
    @Extra_Paid_Days Numeric(18,2)
AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	If @Tran_Type = 'I'
		Begin
			--Declare @TranID Numeric(18,0)
			--Set @TranID = 0 
			if not EXISTS(select Emp_ID from T0100_Bonus_Slabwise WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and (from_Date BETWEEN @From_date AND @To_date or To_date BETWEEN @From_date AND @To_date))
				Begin
					Select @Tran_ID =   Isnull(max(Tran_ID),0) + 1 From T0100_Bonus_Slabwise WITH (NOLOCK)			
					Insert INTO T0100_Bonus_Slabwise(Tran_ID,Cmp_ID,Emp_ID,From_date,To_date,Gross_Salary,Working_Days,Eligible_Day,Paid_Day,Leave_Slab,Bonus_Amount,Additional_Amount,Total_Bonus_Amount,for_date,Bonus_Effect_on_Sal,Bonus_Effect_Month,Bonus_Effect_Year,Bonus_Comments,Extra_Paid_Days)
					VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@From_date,@To_date,@Gross_Salary,@Working_Days,@Eligible_Day,@Paid_Day,@Leave_Slab,@Bonus_Amount,@Additional_Amount,(Isnull(@Additional_Amount,0) + Isnull(@Bonus_Amount,0)),getdate(),@Bonus_Effect_on_Sal,@Bonus_Effect_Month,@Bonus_Effect_Year,@Bonus_Comments,@Extra_Paid_Days)
				END	
			ELSE
				BEGIN
					set @Tran_ID = 0
					RAISERROR ('Record Already Exist', 16, 2)
					return  
				END
		End
	Else if  @Tran_Type = 'D'
		Begin
			Delete From T0100_Bonus_Slabwise Where Tran_ID = @Tran_ID
		End 
  RETURN  


