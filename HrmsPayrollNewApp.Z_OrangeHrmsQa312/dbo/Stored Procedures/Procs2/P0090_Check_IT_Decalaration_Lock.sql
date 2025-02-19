

-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,22012014>
-- Description:	<Description,,Check IT Declaration Slab>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_Check_IT_Decalaration_Lock] 
	@Cmp_Id as numeric(18,0)
	,@Emp_Id as numeric(18,0) = 0
	,@FY as Varchar(50) 
	,@From_Date as datetime = null
	,@To_Date as datetime = null
	,@Tran_Id as numeric(18,0) = 0
	,@Op as tinyint = 0
	--,@Current_Date as datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Op = 0
		BEGIN
			Declare @Enable_Days as numeric(18,0)
			Set @Enable_Days = 0
			SET @Enable_Days = (Select Setting_Value from T0040_SETTING WITH (NOLOCK) where Setting_Name = 'Enable IT Declaration for mid join employee upto days' and Cmp_ID = @Cmp_Id)
		
			IF @Enable_Days <> 0
				BEGIN
					
					IF EXISTS (Select Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Date_Of_Join > GETDATE() - @Enable_Days AND Date_Of_Join < GETDATE() and Cmp_ID = @Cmp_Id AND Emp_ID = @Emp_Id)
						BEGIN
							
							Select Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Date_Of_Join > GETDATE() - @Enable_Days AND Date_Of_Join < GETDATE() and Cmp_ID = @Cmp_Id AND Emp_ID = @Emp_Id	
						END
					ELSE
						BEGIN
							
							Select Tran_Id from T0090_IT_Declaration_Lock_Setting WITH (NOLOCK) where Financial_Year = @FY And From_Date <= GETDATE() AND To_Date >= GETDATE() And Cmp_Id = @Cmp_Id	
						END
				END
			ELSE
				BEGIN
					
					--Select Tran_Id from T0090_IT_Declaration_Lock_Setting where From_Date <= GETDATE() AND To_Date >= GETDATE() and Financial_Year = @FY and Cmp_Id = @Cmp_Id
					Select Tran_Id from T0090_IT_Declaration_Lock_Setting WITH (NOLOCK) where Financial_Year = @FY and Cmp_Id = @Cmp_Id and (CONVERT(varchar(30),GETDATE(),106) between From_Date AND To_Date )
				END 
		END
	Else
	BEGIN
			Select * from (      
		    Select * from T0090_IT_Declaration_Lock_Setting WITH (NOLOCK) Where Cmp_Id = @Cmp_Id  
		    AND (((From_Date >= @From_Date) AND (From_Date <= @To_Date)) OR ((To_Date >= @From_Date) AND (To_Date <= @To_Date )))
		    AND Financial_Year = @FY ) as t where t.Tran_Id <> @Tran_Id
	END
END


