

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 14/04/2017
-- Description:	Employee Slab wise Increment 
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_Increment_Slabwise]
    @Tran_ID Numeric(18,0) output,
    @From_date datetime,
    @To_date datetime,
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@Gross_Amount Numeric(18,2),
    @Increment_Cal_On Numeric(18,2),
    @Increment_Cal_Amt Numeric(18,2),
    @Working_Days Numeric(18,2),
    @Eligible_Day Numeric(18,2),
    @Actual_Increment_Amt Numeric(18,2),
    @Additional_Increment Numeric(18,2),
    @Tran_Type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Tran_Type = 'I'
		Begin
			--Declare @TranID Numeric(18,0)
			--Set @TranID = 0 
			if not EXISTS(select Emp_ID from T0100_Increment_Slabwise WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and (from_Date BETWEEN @From_date AND @To_date or To_date BETWEEN @From_date AND @To_date))
				Begin
					Select @Tran_ID =   Isnull(max(Tran_ID),0) + 1 From T0100_Increment_Slabwise WITH (NOLOCK)			
					Insert INTO T0100_Increment_Slabwise(Tran_ID,Cmp_ID,Emp_ID,Gross_Salary,Wages_Calculate_On,Wages_Amount,Working_Days,Eligible_Day,Increment_Amount,Additional_Increment,Total_Increment,from_date,to_date,for_date)
					VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@Gross_Amount,@Increment_Cal_On,@Increment_Cal_Amt,@Working_Days,@Eligible_Day,@Actual_Increment_Amt,@Additional_Increment,(Isnull(@Actual_Increment_Amt,0) + Isnull(@Additional_Increment,0)),@from_date,@to_date,getdate())
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
			Delete From T0100_Increment_Slabwise Where Tran_ID = @Tran_ID
		End 
  RETURN  


