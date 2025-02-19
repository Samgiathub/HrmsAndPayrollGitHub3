


-- Created By Rohit on 03042015 for Default_Entry in .
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ===============================================================
CREATE PROCEDURE [dbo].[DefaultPayment_Process_Type] 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
SET ANSI_WARNINGS OFF;
BEGIN

		Declare @Payment_Process_Type Table(Payment_Process_name  varchar(Max),Payment_Allowance varchar(MAX))

		insert into @Payment_Process_Type values ('Salary','Net_Salary')
		insert into @Payment_Process_Type  values ('Bonus','Bonus')
		insert into @Payment_Process_Type values ('Leave Encashment','Leave_Salary_Amount')
		insert into @Payment_Process_Type  values ('Allowance','Allowance')
		insert into @Payment_Process_Type  values ('Advance','Advance')
		insert into @Payment_Process_Type  values ('Travel Amount','Adjust_Amount')
		insert into @Payment_Process_Type  values ('Full and Final','Full and Final')
		insert into @Payment_Process_Type  values ('Travel Advance Amount','Travel_Advance_Amount')
		insert into @Payment_Process_Type  values ('Incentive','Incentive') --Added by Rajput 25072017 For Incentive Process
		insert into @Payment_Process_Type  values ('Bond','Bond') --Added by Ramiz on 25/02/2019
		insert into @Payment_Process_Type  values ('Salary Settlement','Salary Settlement') --Added by Hardik 07/06/2019 as Rohit Patel has not inserted Default Entry

		DECLARE @Payment_Process_name Nvarchar(max), 
				@Payment_Allowance NVARCHAR(MAX)				

		DECLARE L_Master CURSOR FOR SELECT Payment_Process_name,Payment_Allowance FROM @Payment_Process_Type
		OPEN L_Master
		FETCH NEXT FROM L_Master INTO @Payment_Process_name,@Payment_Allowance
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			SET @CNT = 0	
			SET @CNT = (Select COUNT(1) from T0301_Payment_Process_Type WITH (NOLOCK) WHERE UPPER(Payment_Process_name) = UPPER(@Payment_Process_name))
			IF @CNT = 0
			BEGIN
			   INSERT INTO T0301_Payment_Process_Type (Payment_Process_name ,Payment_Allowance) VALUES (@Payment_Process_name,@Payment_Allowance)
			END
		   FETCH NEXT FROM L_Master INTO @Payment_Process_name,@Payment_Allowance
		END

		CLOSE L_Master
		DEALLOCATE L_Master
END

