

-- =============================================
-- AUTHOR:		SHAIKH RAMIZ
-- CREATE DATE: 05-Apr-2018
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_MACHINE_DAILY_EFFICIENCY_IMPORT]
	@Cmp_ID						NUMERIC,
	@For_Date					DATETIME,
	@Machine_Name				VARCHAR(100),
	@First_Shift_Name			VARCHAR(50),
	@First_Shift_Efficiency		NUMERIC(18,2),
	@Second_Shift_Name			VARCHAR(50),
	@Second_Shift_Efficiency	NUMERIC(18,2),
	@Third_Shift_Name			VARCHAR(50),
	@Third_Shift_Efficiency		NUMERIC(18,2),
	@Tran_type					CHAR(1),
	@User_Id					NUMERIC(18,0)	= 0,
    @IP_Address					VARCHAR(30)		= '',
	@Log_Status					INT = 0	OUTPUT,
	@Row_No						NUMERIC(18,0)	= 0,
	@GUID						VARCHAR(2000)	= '',
	@Delete_Tran_ID				VARCHAR(MAX)	= ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	DECLARE @MACHINE_ID AS NUMERIC
	SET @MACHINE_ID = 0
	DECLARE @CONSTRAINT AS VARCHAR(MAX)
	SET @CONSTRAINT = NULL
		
		SELECT @MACHINE_ID = MACHINE_ID FROM T0040_Machine_Master WITH (NOLOCK) WHERE Machine_Name = ISNULL(@Machine_Name,'')
		
		
		IF @Machine_Name = ''  
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Machine_Name ,'Machine Name Cannot be Blank',@Machine_Name,'Enter Machine Name',@For_Date,'Machine Daily Efficiency Import',@GUID)			
				RETURN
			END
			
		IF @MACHINE_ID = 0  
			BEGIN
				Set @Log_Status = 1
				INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Machine_Name ,'Machine does not Exists',@Machine_Name,'Enter Proper Machine Name',@For_Date,'Machine Daily Efficiency Import',@GUID)			
				RETURN
			END	
		IF OBJECT_ID('#tempdb..#EMP_SHIFT') IS NULL
			BEGIN
				CREATE TABLE #EMP_SHIFT
				(
					Emp_Id numeric(18,0),
					For_date datetime,
					Shift_ID numeric(18,0),
					Shift_St_Time varchar(10),
					Shift_End_Time varchar(10)
				)
			END
				
		IF OBJECT_ID('#tempdb..#DAILY_EFFICIENCY') IS NULL
			BEGIN
				CREATE TABLE #DAILY_EFFICIENCY
				(
					For_date	DATETIME,
					Cmp_ID		NUMERIC(18,0),
					Emp_Id		NUMERIC(18,0),
					Machine_ID	VARCHAR(20),
					Shift_ID	NUMERIC(18,0)
				)
			END
		
		
		INSERT INTO #DAILY_EFFICIENCY
			(FOR_DATE , CMP_ID , Emp_Id , MACHINE_ID , Shift_ID)
		SELECT @For_Date ,T.Cmp_ID , T.Emp_ID , T.Machine_ID , t.Shift_ID
		FROM
		(
			SELECT MAX(Effective_Date) AS Effective_Date ,Cmp_ID , Emp_ID , Machine_ID , Shift_ID
			FROM T0040_Machine_Allocation_Master WITH (NOLOCK)
			WHERE Cmp_ID  = @Cmp_ID and Machine_ID = CAST(@MACHINE_ID AS VARCHAR(20)) and Effective_Date <= @For_Date
			GROUP BY Cmp_ID , Emp_ID , Shift_ID , Machine_ID
		 )T
					
		EXEC P_GET_EMP_SHIFT_DETAIL @Cmp_ID = @Cmp_ID,@FROM_DATE = @For_Date,@To_Date = @For_Date,@Constraint = @constraint
		
		INSERT INTO T0100_MACHINE_DAILY_EFFICIENCY 
			(Cmp_ID, For_Date, Machine_ID, Shift_ID, Assigned_Emp_ID, Alternate_Emp_ID ,Efficiency, Segment_Id, WeaverFlag)
		SELECT DE.Cmp_ID ,DE.For_date ,DE.Machine_ID ,ES.Shift_ID , ES.Emp_Id ,ES.Emp_Id , 
		CASE WHEN SM.Shift_Name = @First_Shift_Name THEN @First_Shift_Efficiency 
			 WHEN SM.Shift_Name = @Second_Shift_Name THEN @Second_Shift_Efficiency
			 WHEN SM.Shift_Name = @Third_Shift_Name THEN @Third_Shift_Efficiency ELSE 0 END ,I.Segment_ID , BS.MachineEmpType
		FROM #EMP_SHIFT ES
			INNER JOIN #DAILY_EFFICIENCY DE ON ES.Emp_Id = DE.Emp_Id
			INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = ES.Shift_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = ES.Emp_Id
			INNER JOIN 
					( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
						FROM T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN 
						(
								SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								FROM T0095_INCREMENT I3 WITH (NOLOCK)
								WHERE I3.Increment_effective_Date <= @For_Date
								GROUP BY I3.EMP_ID  
							) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
					   where I.INCREMENT_EFFECTIVE_DATE <= @For_Date and I.Cmp_ID = @Cmp_ID 
					   group by I.emp_ID  
					) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
			INNER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID = I.Segment_ID
		WHERE DE.Cmp_ID = @Cmp_ID and DE.For_date = @For_Date
		
	DROP TABLE #EMP_SHIFT
	DROP TABLE #DAILY_EFFICIENCY

END


