

-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE  PROCEDURE [dbo].[P0100_IT_DECLARATION_DELETE]
	@EMP_ID AS NUMERIC
	,@Cmp_ID AS NUMERIC
	,@For_Date AS NUMERIC
	,@FY AS VARCHAR(50)
	,@User_Id AS NUMERIC = 0
	,@IP_Address AS VARCHAR(50) = ''
	,@IsCompare_Flag varchar(50) = ''  --Added by Jaina 1-09-2020
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
				Declare @For_Date1 as numeric
				Set @For_Date1 = @For_Date + 1
				
			
									-- Added for audit trail By Ali 31122013 -- Start						
										Declare @Old_EMP_Name AS varchar(100)
										Declare @OldValue varchar(max)
										
										Set @Old_EMP_Name = ''
										Set @OldValue = ''
									-- Added for audit trail By Ali 31122013 -- End
									
			
				Declare @IT_Name as varchar(150)
				Set @Old_EMP_Name = (Select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @EMP_ID)
				
				Declare @IT_ID int
				Declare @AMOUNT as numeric
				Declare @IT_For_Date Datetime
				Set @IT_ID = 0
				Set @IT_For_Date  = null
				Set @AMOUNT = 0 
				
				DECLARE IT_Declaration CURSOR FOR 
				Select IT_ID,For_Date,Amount from T0100_IT_DECLARATION  WITH (NOLOCK)
				Where Emp_ID = @EMP_ID 
				And Cmp_ID = @Cmp_ID 
				And YEAR(For_Date) In (@For_Date,@For_Date1) 
				And FINANCIAL_YEAR = @FY

				OPEN IT_Declaration

				FETCH NEXT FROM IT_Declaration 
				INTO @IT_ID,@IT_For_Date,@AMOUNT

				WHILE @@FETCH_STATUS = 0
				BEGIN
					
					Set @IT_Name = ''
					Set @IT_Name = (Select IT_Name from T0070_IT_MASTER WITH (NOLOCK) where IT_ID = @IT_ID)
					
					set @OldValue = 'old Value' 
						+ '#' + 'IT Name : ' + ISNULL(@IT_Name,'')
						+ '#' + 'Employee Name : ' + ISNULL(@Old_EMP_Name,'')
						+ '#' + 'For Date : ' + cast(ISNULL(@IT_For_Date,'') as nvarchar(11)) 
						+ '#' + 'Amount : ' + CONVERT(nvarchar(200),ISNULL(@AMOUNT,0))
						+ '#' + 'Financial Year : ' + ISNULL(@FY,'')
									
					exec P9999_Audit_Trail @Cmp_ID,'D','IT Declaration',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
					
					FETCH NEXT FROM IT_Declaration 
					INTO @IT_ID,@IT_For_Date,@AMOUNT
				END 
				CLOSE IT_Declaration;
				DEALLOCATE IT_Declaration;
				
	if @IsCompare_Flag = 'Final'   --Added by Jaina 1-09-2020
	Begin
	
			Delete from T0100_IT_DECLARATION 
			Where Emp_ID = @EMP_ID 
			And Cmp_ID = @Cmp_ID 
			And YEAR(For_Date) In (@For_Date,@For_Date1) 
			And FINANCIAL_YEAR = @FY and IsCompare_Flag = @IsCompare_Flag
			
			Delete from T0110_IT_Emp_Details where IT_ID in 
			(Select IT_ID from  T0070_IT_MASTER WITH (NOLOCK) where IT_Def_ID = 153)
			AND Emp_ID = @EMP_ID and Cmp_ID = @Cmp_ID and Financial_Year = @FY
	End
	Else if  @IsCompare_Flag = 'Temp'   --Added by Deepali 24022023 -start
	Begin
	
			Delete from T0100_IT_DECLARATION 
			Where Emp_ID = @EMP_ID 
			And Cmp_ID = @Cmp_ID 
			And YEAR(For_Date) In (@For_Date,@For_Date1) 
			And FINANCIAL_YEAR = @FY and (IsCompare_Flag = @IsCompare_Flag or IsCompare_Flag is null OR IsCompare_Flag ='')
					

			Delete from T0110_IT_Emp_Details where IT_ID in 
			(Select IT_ID from  T0070_IT_MASTER WITH (NOLOCK) where IT_Def_ID = 153)
			AND Emp_ID = @EMP_ID and Cmp_ID = @Cmp_ID and Financial_Year = @FY
			-----------------------------------------------------Added by Deepali 24022023 -End
	End
	Else
	Begin
			Delete from T0100_IT_DECLARATION 
			Where Emp_ID = @EMP_ID 
			And Cmp_ID = @Cmp_ID 
			And YEAR(For_Date) In (@For_Date,@For_Date1) 
			And FINANCIAL_YEAR = @FY
			
			Delete from T0110_IT_Emp_Details where IT_ID in 
			(Select IT_ID from  T0070_IT_MASTER WITH (NOLOCK) where IT_Def_ID = 153)
			AND Emp_ID = @EMP_ID and Cmp_ID = @Cmp_ID and Financial_Year = @FY

			--Added by Jaina 23-09-2020 
			Delete from T0100_IT_DECLARATION_COMPARE 
			Where Emp_ID = @EMP_ID 
			And Cmp_ID = @Cmp_ID 
			And YEAR(For_Date) In (@For_Date,@For_Date1) 
			And FINANCIAL_YEAR = @FY
			
			Delete from T0110_IT_Emp_Details_Compare where IT_ID in 
			(Select IT_ID from  T0070_IT_MASTER WITH (NOLOCK) where IT_Def_ID = 153)
			AND Emp_ID = @EMP_ID and Cmp_ID = @Cmp_ID and Financial_Year = @FY

			


	END
	
END
