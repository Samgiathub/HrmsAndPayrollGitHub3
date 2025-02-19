

-- =============================================
-- Author:			Nimesh Parmar
-- Create date:		23 April, 2015
-- Description:		This stored procedure will get executed in Schedule Job Process. 
--					It is build to assign Shift Rotation autoamtically to the employee according to sorting_no 
--					as per the existing assigned Rotation sorting no.
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_AUTO_ASSIGN_SHIFT_ROTATION]	
	@Day INT = 1,
	@For_Next_Month Bit = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	
	DECLARE @CmpID Numeric(18,0),
			@EmpID Numeric(18,0),
			@RotationID Numeric(18,0),
			@TranID Numeric(18,0),
			@EffectiveDate DateTime;
	
	--Generating Effective Date	
	SET @EffectiveDate = Cast(Cast(Year(GETDATE()) AS Varchar) + '-01-' + Cast(@Day As Varchar) As Varchar)
	--if the flag for next month is true then it should take date of next month of current date.
	--we are deducting -1 in case of flag is false. for example if the date is 2015-01-31 then 
	--adding current month (April) in this date will give the next month result 2015-(01 + 4)-31 = 2015-05-31
	IF (@For_Next_Month = 1)
		SET @EffectiveDate = DATEADD(MM, MONTH(GETDATE()),@EffectiveDate);
	ELSE
		SET @EffectiveDate = DATEADD(MM, MONTH(GETDATE()-1),@EffectiveDate);
	
	--Creating Table to hold employee id and their current rotation detail
	CREATE TABLE #EMP(
			CmpID Numeric(18,0),
			EmpID Numeric(18,0), 			
			CurrentRotationID numeric(18,0), 
			CurrentSortingNo Numeric(18,0), 
			NextRotationID numeric(18,0)
			);
	
	--Generating records from masters
	INSERT	INTO #EMP (CmpID,EmpID)
    SELECT	DISTINCT I.Cmp_ID,I.Emp_Id from (dbo.T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_effective_Date) as For_Date , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)
			where Increment_Effective_date <= @EffectiveDate
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date)
			INNER JOIN T0050_Emp_Monthly_Shift_Rotation R WITH (NOLOCK) ON 
				R.Emp_ID=I.Emp_ID AND R.Cmp_ID=I.Cmp_ID
	Where	I.Emp_ID IN (SELECT EMP_ID FROM
			(SELECT EMP_ID, Cmp_ID, JOIN_DATE, isnull(left_Date, @EffectiveDate) as left_Date 
				FROM dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE ((@EffectiveDate >= join_Date  and  @EffectiveDate <= left_date ) 										
					or left_date is null and @EffectiveDate >= Join_Date)) 

	--Deleting employee detail whose AutoRotation flag is disabled.
	DELETE	FROM #EMP
	WHERE	EmpID IN (SELECT Emp_ID FROM T0080_EMP_MASTER E WITH (NOLOCK)
					WHERE	E.Cmp_ID=CmpID And IsNull(E.Auto_Rotation,0)=0)

					
	--Deleting employee detail who has already assigned rotation
	--For example if employee has already assigned the shift rotation for affective date 
	--which is later than current date then the rotation should not be assigned for them.
	DELETE	FROM #EMP
	WHERE	EmpID = (SELECT Emp_ID FROM T0050_Emp_Monthly_Shift_Rotation R WITH (NOLOCK)
					WHERE	R.Cmp_ID=CmpID And R.Emp_ID=EmpID AND R.Effective_Date >= GETDATE())

					
	--Getting current Rotation ID and Sorting No
	Update	#EMP
	SET		CurrentRotationID  = R.Rotation_ID, CurrentSortingNo=SR.Sorting_No
	FROM	T0050_Emp_Monthly_Shift_Rotation R INNER JOIN T0050_Shift_Rotation_Master SR 
			ON R.Rotation_ID=SR.Tran_ID AND R.Cmp_ID=SR.Cmp_ID
	WHERE	R.Emp_ID=EmpID AND 
			R.Effective_Date = (SELECT	MAX(Effective_Date) FROM T0050_Emp_Monthly_Shift_Rotation R1 WITH (NOLOCK)
								WHERE	R1.Cmp_ID=R.Cmp_ID AND R1.Emp_ID=R.Emp_ID) AND
			R.Emp_ID NOT IN (Select Emp_ID FROM T0050_Emp_Monthly_Shift_Rotation R2 WITH (NOLOCK)
							WHERE	R2.Effective_Date > GETDATE() AND R2.Cmp_ID=R.Cmp_ID)

			
	--Retrieving Next Rotation id according to current Sorting No.
	Update	#EMP 
	SET		NextRotationID=(Select Top 1 Tran_ID From T0050_Shift_Rotation_Master R WITH (NOLOCK)
							Where R.Sorting_No > CurrentSortingNo AND CmpID=R.Cmp_ID
							Order By R.Sorting_No)
						
	--The above query does not fetch next rotation id when the rotation is last.
	--for example if the there are 10 rotations are available and the last rotation's sorting no is 10 then
	--it cannot find the 11th rotation id and it will update NULL value instead of rotation id.
	
	--In this case we are updating First Rotation ID to all employee having NextRotationID null to complete the cycle.
	Update	#EMP
	SET		NextRotationID=(SELECT TOP 1 Tran_ID 
							FROM T0050_Shift_Rotation_Master R WITH (NOLOCK)
							WHERE R.Cmp_ID=CmpID
							ORDER BY Sorting_No )
	WHERE	NextRotationID IS NULL			

	
	--Declaring cursor for Temporary table
	DECLARE curEmp CURSOR FOR
	SELECT CmpID,EmpID,NextRotationID FROM #EMP
	
	OPEN curEmp
	FETCH NEXT FROM curEMP INTO @CmpID,@EmpID,@RotationID
	WHILE (@@FETCH_STATUS = 0) BEGIN
		--We are executing store procedure to assign new rotation to each employee.
		EXEC P0050_Emp_Monthly_Shift_Rotation @CmpID, @TranID, @EmpID, @RotationID, @EffectiveDate, 'I'
		
		FETCH NEXT FROM curEMP INTO @CmpID,@EmpID,@RotationID
	END
	CLOSE curEmp;
	DEALLOCATE curEmp;
END


