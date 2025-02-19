


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_WO_Application] 
	@WO_Application_Id as numeric(18,0) Output
	,@Cmp_Id as numeric(18,0)
	,@Emp_Id as numeric(18,0)
	,@WoDate as datetime
	,@WoDay as varchar(30)
	,@No_Of_Days as nvarchar(5)
	,@NewWoDate as datetime
	,@NewWoDay as varchar(30)	
	,@Status as varchar(1) = 'P'
	,@Login_Id as numeric(18,0)
	,@Month as numeric(18,0)
	,@Year as numeric(18,0)
	,@TRAN_TYPE VARCHAR(1)    --ADDED BY JAINA 13-09-2016
	,@System_Date as datetime = null	--Added By Jaina 14-09-2016
	,@Sup_Emp_Id as numeric(18,0) = 0  --Added By Jaina 19-09-2016
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		--Declare @Wo_App_Id as numeric
		--select @Wo_App_Id = WO_Application_Id from T0100_WO_Application_Main 
		--where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and CONVERT(Varchar(30),Application_Date,103) = CONVERT(Varchar(30),GETDATE(),103)
		
		
	--	IF EXISTS (select WO_Application_Id from T0110_WO_Application where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = @WoDate AND WO_Application_Id = @Wo_App_Id) 
	--		BEGIN
	--				Update T0110_WO_Application 
	--				SEt No_Of_Days = @No_Of_Days,
	--				New_WO_Date	= @NewWoDate,
	--				New_WO_Day = datename(dw,@NewWoDate),
	--				Status = @Status
	--				where WO_Application_Id = @Wo_App_Id
	--		END
	--	ELSE
	--		BEGIN	
	--				INSERT INTO T0110_WO_Application (WO_Application_Id,Cmp_Id,Emp_Id,WO_Date,WO_Day,No_Of_Days,New_WO_Date,New_WO_Day,Status,Login_Id,Month,Year)
	--				VALUES (@Wo_App_Id,@Cmp_Id,@Emp_Id,@WoDate,@WoDay,@No_Of_Days,@NewWoDate,datename(dw,@NewWoDate),@Status,@Login_Id,@Month,@Year)
	--		END
	
	--Set @WO_Application_Id = @Wo_App_Id 	

	IF EXISTS(SELECT 1 FROM T0100_CompOff_Application WITH (NOLOCK) where EMP_ID=@Emp_Id AND Extra_Work_Date = @WoDate AND Application_Status In ('A','P'))
		BEGIN
			DECLARE @E VARCHAR(70)
			SET @E = '@@Compoff Application already exists on ' +  convert(varchar, @WoDate, 103) + '@@'
			RAISERROR(@E ,16,2)
			RETURN
		END

	IF @TRAN_TYPE = 'I'
	BEGIN
			IF EXISTS (select WO_Application_Id from T0110_WO_Application WITH (NOLOCK) where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and WO_Date = @WoDate AND WO_Application_Id = @WO_Application_Id) 
				BEGIN
						Update T0110_WO_Application 
								SEt No_Of_Days = @No_Of_Days,
									New_WO_Date	= @NewWoDate,
									New_WO_Day = datename(dw,@NewWoDate),
									Status = @Status,
									System_Date = @System_Date  --Added By Jaina 14-09-2016
						where WO_Application_Id = @WO_Application_Id
		
				END
			ELSE
				BEGIN	
						
						Select @WO_Application_Id =  ISNULL(MAX(WO_Application_Id),0) + 1 from T0110_WO_Application	WITH (NOLOCK)			
			
						INSERT INTO T0110_WO_Application (WO_Application_Id,Cmp_Id,Emp_Id,WO_Date,WO_Day,No_Of_Days,New_WO_Date,New_WO_Day,Status,Login_Id,Month,Year,System_Date,Sup_Emp_Id)
						VALUES (@WO_Application_Id,@Cmp_Id,@Emp_Id,@WoDate,@WoDay,@No_Of_Days,@NewWoDate,datename(dw,@NewWoDate),@Status,@Login_Id,@Month,@Year,@System_Date,@Sup_Emp_Id)
			
				END
	
			
	END
	
	IF @TRAN_TYPE = 'U'
	BEGIN
		Update T0110_WO_Application 
		SEt No_Of_Days = @No_Of_Days,
			New_WO_Date	= @NewWoDate,
			New_WO_Day = datename(dw,@NewWoDate),
			Status = @Status,
			System_Date = @System_Date  --Added By Jaina 14-09-2016
		where WO_Application_Id = @WO_Application_Id
	END
	IF @TRAN_TYPE = 'D'
	BEGIN
		delete FROM T0110_WO_Application where Cmp_Id = @Cmp_Id and WO_Application_Id = @WO_Application_Id
		
		--delete FROM T0100_WO_Application_Main where Cmp_Id = @Cmp_Id and WO_Application_Id = @WO_Application_Id
		
	END
		
RETURN		
END



