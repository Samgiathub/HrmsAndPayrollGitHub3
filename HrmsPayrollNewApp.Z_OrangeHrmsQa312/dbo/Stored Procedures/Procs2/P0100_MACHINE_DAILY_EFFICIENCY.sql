

-- =============================================
-- AUTHOR:		SHAIKH RAMIZ
-- CREATE DATE: 12-FEB-2018
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_MACHINE_DAILY_EFFICIENCY]
	@EfficiencyID		NUMERIC	OUTPUT,
	@Cmp_ID				NUMERIC,
	@For_Date			DATETIME,
	@Machine_ID			VARCHAR(50),
	@Shift_ID			NUMERIC,
	@Assigned_EmpID		NUMERIC,
	@Alternate_EmpID	NUMERIC,
	@Achived_Efficieny	NUMERIC(18,2),
	@Segment_ID			NUMERIC,
	@Tran_type			CHAR(1)	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @WeavingEmpType AS VARCHAR(2)
	SELECT @WeavingEmpType = MachineEmpType FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_ID = @Segment_ID AND Cmp_ID	= @Cmp_ID
	
	
	DECLARE @Emp_Exists_Name as Varchar(100)
	DECLARE @Shift_Exists_Name as Varchar(100)
	DECLARE @ERR_MSG AS VARCHAR(100)
	
	IF EXISTS (	SELECT 1 FROM T0100_MACHINE_DAILY_EFFICIENCY WITH (NOLOCK)
				WHERE FOR_DATE = @FOR_DATE AND SHIFT_ID = @SHIFT_ID AND MACHINE_ID = @MACHINE_ID 
				AND Assigned_Emp_ID = @Assigned_EmpID  AND Alternate_Emp_ID = @Alternate_EmpID and @Achived_Efficieny > 0 and @Tran_type = 'I')
		BEGIN
			SET @Tran_type = 'U'
			
			SELECT	@EfficiencyID = Efficiency_ID
			FROM	T0100_MACHINE_DAILY_EFFICIENCY WITH (NOLOCK)
			WHERE	FOR_DATE = @FOR_DATE AND SHIFT_ID = @SHIFT_ID AND MACHINE_ID = @MACHINE_ID 
					AND Assigned_Emp_ID = @Assigned_EmpID
		END

	
	IF @Tran_type = 'I'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM T0100_Machine_Daily_Efficiency WITH (NOLOCK) WHERE For_Date = @For_Date and Machine_ID = @Machine_ID and Shift_ID = @Shift_ID and Assigned_Emp_ID = @Assigned_EmpID and Alternate_Emp_ID = @Alternate_EmpID )
				BEGIN
				
					IF EXISTS (SELECT Alternate_Emp_ID FROM T0100_MACHINE_DAILY_EFFICIENCY WITH (NOLOCK) WHERE For_Date = @For_Date and Shift_ID = @Shift_ID AND Alternate_Emp_ID = @Alternate_EmpID)
						BEGIN
							SELECT	TOP 1 @Emp_Exists_Name =  (EM.Alpha_Emp_code + ' - ' + EM.Emp_Full_Name) ,
									@Shift_Exists_Name =SM.SHIFT_NAME
							FROM	T0100_MACHINE_DAILY_EFFICIENCY ME WITH (NOLOCK)
									INNER JOIN  T0080_EMP_MASTER EM WITH (NOLOCK) ON ME.Alternate_Emp_ID = EM.Emp_ID
									INNER JOIN  T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = ME.Shift_ID
							WHERE	For_Date = @For_Date and ME.Shift_ID = @Shift_ID 
									AND Alternate_Emp_ID = @Alternate_EmpID
							
							SET @ERR_MSG = '@@' + @Emp_Exists_Name + ' is Already Assigned for ' + REPLACE(CONVERT(VARCHAR , @For_Date , 106) , ' ' , '-') + ' for ' + @Shift_Exists_Name + '.@@'
							
							RAISERROR(@ERR_MSG , 16 ,1)
							RETURN
						END
						
						IF EXISTS (SELECT 1 FROM T0100_Machine_Daily_Efficiency WITH (NOLOCK) WHERE For_Date = @For_Date and Machine_ID = @Machine_ID and Shift_ID = @Shift_ID and Assigned_Emp_ID = @Assigned_EmpID AND WeaverFlag = 'WV')
							BEGIN
								RAISERROR('@@Duplicate Entry is not Allowed for Weaver@@' , 16 , 1)
								RETURN
							END
						ELSE
							BEGIN
								INSERT INTO T0100_MACHINE_DAILY_EFFICIENCY 
									(Cmp_ID, For_Date, Machine_ID, Shift_ID, Assigned_Emp_ID, Alternate_Emp_ID ,Efficiency, Segment_Id, WeaverFlag)
								VALUES 
									(@Cmp_ID, @For_Date , @Machine_ID , @Shift_ID , @Assigned_EmpID , @Alternate_EmpID , @Achived_Efficieny ,@Segment_ID, @WeavingEmpType )
							END
		
				END
		END
	ELSE IF @Tran_type = 'U'
		BEGIN
			UPDATE T0100_MACHINE_DAILY_EFFICIENCY
			SET		Alternate_Emp_ID	= @Alternate_EmpID,
					Efficiency = @Achived_Efficieny
			WHERE	Efficiency_ID = ISNULL(@EfficiencyID,0) and For_Date = @For_Date
		END
	ELSE IF @Tran_type = 'D'
		BEGIN
			IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Alternate_EmpID AND @For_Date BETWEEN Month_St_Date AND Month_End_Date)
				BEGIN
					RAISERROR('Cannot Delete this Record. Salary Exists' , 16 ,1)
					RETURN
				END
			
			DELETE FROM T0100_MACHINE_DAILY_EFFICIENCY WHERE Efficiency_ID = ISNULL(@EfficiencyID,0)
		END
		
	
END


