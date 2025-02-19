



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0230_TDS_CHALLAN_DETAIL]


@Challan_Id	numeric(18, 0)
,@Emp_Id	numeric(18, 0)	
,@TDS_Amount	numeric(18, 2)	
,@Ed_Cess	numeric(18, 2)	
,@Tran_Type varchar(1) = 'I'
,@Additional_Amount numeric(18,2) = 0 --Added by Jaina 16-02-2019		
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @tran_id as numeric
	set @tran_id = 0
	 
	IF @TRAN_TYPE = 'I'
		BEGIN
					
			--select  @tran_id = isnull(max(Tran_Id),0) + 1	from T0230_TDS_CHALLAN_DETAIL			
			--Added by Jaina 05-03-2019
			--DECLARE @TOTAL NUMERIC(18,0)
			--SET @TOTAL = @TDS_AMOUNT + @ED_CESS + @ADDITIONAL_AMOUNT
			
			--IF @Total <> 0
			begin	
				INSERT INTO T0230_TDS_CHALLAN_DETAIL
						  ( Challan_Id, Emp_Id, TDS_Amount, Ed_Cess,Additional_Amount)
				VALUES     (@Challan_Id,@Emp_Id,@TDS_Amount,@Ed_Cess,@Additional_Amount)	
			END
		END
	
	ELSE IF @TRAN_TYPE = 'D'
		BEGIN
			
			DELETE FROM T0220_TDS_CHALLAN WHERE CHALLAN_ID = @CHALLAN_ID
				
		END
	ELSE IF @TRAN_TYPE = 'S'
		BEGIN
			
			SELECT     Challan_Id, cmp_id, Month, Year, Payment_Date, Bank_ID, Bank_Name, Bank_BSR_Code, Paid_By, Cheque_No, CIN_No, Cheque_Date, Tax_Amount, ED_Cess, 
								  Interest_Amount, Penalty_Amount, Other_Amount, Total_Amount
			FROM         T0220_TDS_CHALLAN WITH (NOLOCK)
			WHERE Challan_Id = @Challan_Id
			
			SELECT     Tran_Id, Challan_Id, Emp_Id, TDS_Amount, Ed_Cess
			FROM         T0230_TDS_CHALLAN_DETAIL WITH (NOLOCK)
			WHERE Challan_Id = @Challan_Id
			
		END
	
RETURN




