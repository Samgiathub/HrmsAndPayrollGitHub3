
CREATE PROCEDURE [dbo].[P0100_Employee_ESOP_Detail]
	 @Tran_ID		Numeric output
	,@Cmp_ID		Numeric
	,@Emp_ID		Numeric
	,@tran_type		varchar(1)
	,@NoOfShare		varchar(5) 
	,@EffectiveDate datetime2
	,@EmpPrice		numeric(18,2)
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		
		DECLARE @Increment_Id as NUMERIC
		DECLARE @Date_Of_Join as DATETIME
		
		if @tran_type ='I' 
			begin
				Declare  @EmployeePrice as numeric(18,2) = 0
				Declare  @MarketPrice as numeric(18,2) = 0
				Select @EmployeePrice = EmployeePrice,@MarketPrice = MarketPrice 
				From  T0020_ESOP_SharePrice_Master where Tran_Id = @EmpPrice
				
				If NOT EXISTS (Select 1 From T0040_Emp_ESOP_Allocation WITH (NOLOCK) where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID And Effective_Date =  @EffectiveDate )  
					BEGIN
						INSERT INTO T0040_Emp_ESOP_Allocation (Effective_date,NoOfShare,SystemDate,Emp_Id,Cmp_Id,Emp_Price,PerquisiteValue,TaxablePerqValue)
						VALUES (@EffectiveDate,@NoOfShare,GETDATE(),@Emp_ID,@Cmp_ID,@EmployeePrice,(@EmployeePrice*@NoOfShare),((@MarketPrice * @NoOfShare) - (@EmployeePrice*@NoOfShare)))
					END
				ELSE 
					BEGIN
						UPDATE T0040_Emp_ESOP_Allocation
						SET	NoOfShare = @NoOfShare, Effective_date = @EffectiveDate,EMP_Price = @EmpPrice
						WHERE	Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID And Effective_Date = @EffectiveDate
					END
			END	
			else if @tran_type ='D'
			begin
				DELETE FROM T0040_Emp_ESOP_Allocation where Esop_Id = @Tran_Id					
			end
	RETURN




