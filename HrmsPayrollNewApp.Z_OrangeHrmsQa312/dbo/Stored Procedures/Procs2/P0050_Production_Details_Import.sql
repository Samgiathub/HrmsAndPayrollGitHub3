


-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 10032015	
-- Description:	Create For Import file of Production Details 
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Production_Details_Import]  
	@Tran_Id			Numeric(18,0) Output ,
	@Cmp_ID				Numeric(9),
	@Employee_ID		Varchar(100),
	@Production_Month   Numeric(2),
	@Production_Year	Numeric(4),
	@Production_PCS		Numeric(18,2) = 0,
	@Production_Amount	Numeric(18,2) = 0,
	@Incentive_Amount	Numeric(18,2) = 0,
	@Card_Amount		Numeric(18,2) = 0,
	@Gross_Amount		Numeric(18,2) = 0,
	@tran_type			Char(1),
	@GUID Varchar(2000) = '' --Added by nilesh patel on 14062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Max_Tran_Id Numeric(18,0)
Declare @Emp_ID Numeric(18,0)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
		if @tran_type = 'I'
			Begin
				set @Emp_ID = 0
				Set @Tran_Id = 0
				Select @Emp_ID = Emp_ID From T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Employee_ID and Cmp_ID = @Cmp_ID --and EMP_LEFT <> 'Y'

				if @Emp_ID Is NULL
					Set @Emp_ID = 0
				
				if @Emp_ID = 0
					Begin
						Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Employee_ID,'Employee Doesn''t exists',@Employee_ID,'Employee Doesn''t exists',GetDate(),'Production Details',@GUID)
						return
					End
					
				if @Production_Month = 0 or @Production_Month Is Null
					Begin
						Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Employee_ID,'Enter Valid Month Details',@Employee_ID,'Enter Valid Month Details',GetDate(),'Production Details',@GUID)
						return
					End
				
				if @Production_Year = 0 or @Production_Year Is Null
					Begin
						Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Employee_ID,'Enter Valid Year Details',@Employee_ID,'Enter Valid Year Details',GetDate(),'Production Details',@GUID)
						return
					End
				
				if @Emp_ID <> 0
					Begin
						Select @Max_Tran_Id = Isnull(max(Tran_ID),0) + 1 From T0050_Production_Details_Import WITH (NOLOCK)
						Set @Tran_Id = @Max_Tran_Id
						Insert Into T0050_Production_Details_Import
						(
							Tran_ID,
							Cmp_ID,
							Employee_ID,
							Production_Month,
							Production_Year,
							Production_PCS,
							Production_Amount,
							Incentive_Amount,
							Card_Amount,
							Gross_Amount
						)
						Values
						(
							@Max_Tran_Id,
							@Cmp_ID,
							@Emp_ID,
							@Production_Month,
							@Production_Year,
							@Production_PCS,
							@Production_Amount,
							@Incentive_Amount,
							@Card_Amount,
							@Gross_Amount
						)
					End 
				Return @Tran_Id
			End 
END


