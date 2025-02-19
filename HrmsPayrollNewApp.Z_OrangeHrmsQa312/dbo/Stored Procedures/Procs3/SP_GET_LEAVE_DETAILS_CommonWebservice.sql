


 ---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_DETAILS_CommonWebservice]
	@Emp_Code varchar(50),
	@Leave_Code varchar(50),
	@From_Date Datetime,
	@To_Date Datetime,
	@Period numeric(18,0) 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Date datetime
DECLARE @From_DateFE datetime
DECLARE @To_DateFE datetime
DECLARE @From_DateLE datetime
DECLARE @To_DateLE datetime
DECLARE @Leave_ID numeric(18,0)
DECLARE @Emp_ID numeric(18,0)


DECLARE @Cmp_ID numeric(18,0)
DECLARE @Leave_Min numeric(18,2)
DECLARE @Leave_Max numeric(18,2)
DECLARE @Leave_Closing numeric(18,2)
DECLARE @Leave_Negative_Allow int
DECLARE @Can_Apply_Fraction int
DECLARE @Leave_Negative_Max_Limit numeric(18,0)
DECLARE @IS_Leave_Clubbed int
DECLARE @ErrorMsg varchar(255)

SELECT @Cmp_ID = Cmp_ID,@Emp_ID = Emp_ID  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @Emp_Code


SELECT @Leave_ID = Leave_ID  FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_Code = @Leave_Code

SET @Date = (SELECT Convert(varchar(20),getdate(),111))
 

SET @From_DateFE = (@From_Date - 1)
SET @To_DateFE = (@From_Date - 1)
SET @From_DateLE = (@To_Date - 1)
SET @To_DateLE = (@To_Date - 1)


	CREATE TABLE #LeaveBalanceData
		   (
			Leave_Opening numeric(18,2),
			Leave_Used numeric(18,2),
			Leave_Closing numeric(18,2),
			Leave_Code varchar(50),
			Leave_Name varchar(50),
			Leave_ID numeric(18,0),
			Leave_Type varchar(50)     
		   )
	CREATE TABLE #LeaveDetails
		   (
			Leave_Min numeric(18,2),
			Leave_Max numeric(18,2),
			Leave_Notice_Period int,
			Leave_Applicable int,
			Leave_Nagative_Allow int,
			Leave_Paid_Unpaid varchar(20),
			Is_Document_required int,
			Apply_Hourly int,
			Can_Apply_Fraction int,
			Default_Short_Name varchar(50),
			Leave_Name varchar(50),
			AllowNightHalt int,
			Half_Paid int,
			Leave_Negative_Max_Limit numeric(18,2)
		   )
	CREATE TABLE #LeaveClubbDetails
		   (
			Emp_ID numeric(18,2),
			Cmp_ID numeric(18,2),
			Emp_Full_Name varchar(50),
			Leave_ID numeric(18,0),
			Leave_Code varchar(20),
			Leave_Name varchar(50),
			Leave_Type varchar(50),
			IS_Leave_Clubbed int,
			Application_Date datetime,
			Application_Status varchar(5),
			From_Date datetime,
			To_Date datetime,
			Leave_Assign_AS varchar(50),
			Half_Leave_Date datetime
		   )     
	INSERT INTO #LeaveBalanceData EXEC SP_LEAVE_CLOSING_AS_ON_DATE @Cmp_ID,@Emp_ID,@Date 
	INSERT INTO #LeaveDetails EXEC P0050_Leave_Details_Get @Cmp_ID,@Emp_ID,@Leave_ID
	INSERT INTO #LeaveClubbDetails EXEC Check_Leave_Clubbing @Emp_ID,@Cmp_Id,@From_DateFE,@To_DateFE,@From_DateLE,@To_DateLE,'LA',@Leave_ID
	 
	
	SELECT @Leave_Closing = Leave_Closing  FROM #LeaveBalanceData WHERE Leave_ID = @Leave_ID
	SELECT @Leave_Min = Leave_Min,@Leave_Max = Leave_Max,@Leave_Negative_Allow =Leave_Nagative_Allow, @Can_Apply_Fraction = Can_Apply_Fraction,@Leave_Negative_Max_Limit=Leave_Negative_Max_Limit  FROM #LeaveDetails
	SELECT @IS_Leave_Clubbed = IS_Leave_Clubbed  FROM #LeaveClubbDetails
	
	 
	
	IF @Can_Apply_Fraction <> 1
		BEGIN
			--RAISERROR ('You Cannot Enter Fraction Value',16,1)
			SELECT 'You Cannot Enter Fraction Value'
			RETURN 
		END
	IF  @Period < @Leave_Min AND @Leave_Min <> '0.0'
		BEGIN 
			SET @ErrorMsg = 'You have to take Min' + @Leave_Min + 'leave for selected leave Type'
			--RAISERROR (@ErrorMsg,16,1)
			SELECT @ErrorMsg
			RETURN 
		END
	IF  @Period > @Leave_Max AND @Leave_Max <> '0.0'
		BEGIN 
			SET @ErrorMsg ='You have to take Max' + @Leave_Max + 'leave for selected leave Type'
			--RAISERROR (@ErrorMsg,16,1)
			SELECT @ErrorMsg
			RETURN 
		END
	IF  @Period >= @Leave_Closing
		BEGIN 
		SELECT 'Ok'
			IF @Leave_Negative_Allow = 0
				BEGIN
					--RAISERROR ('You have not take more leave for selected leave Type',16,1)
					SELECT 'You have not take more leave for selected leave Type'
					RETURN 
				END
		END
	IF @IS_Leave_Clubbed = 1
		BEGIN
			--RAISERROR ('Selected Leave Cannot Club with Previous Leave Approved',16,1)
			SELECT 'Selected Leave Cannot Club with Previous Leave Approved'
			RETURN 
		END
	---SELECT @Leave_Closing,@Leave_Min,@Leave_Max,@Leave_Negative_Allow,@Can_Apply_Fraction,@IS_Leave_Clubbed,@Leave_Negative_Max_Limit 
END
