



-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,01022016>
-- Description:	<Description,,Compoff Leave Auto Credit to selected Leave>
-- =============================================
CREATE PROCEDURE [dbo].[P_JOB_GET_COMPOFF_BALANCE_AUTOCREDIT] 
	@Cmp_ID NUMERIC(18,0) = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	
	DECLARE @To_Date		DATETIME
	DECLARE @Curr_Emp_Id	NUMERIC
	DECLARE @Leave_ID		NUMERIC
	DECLARE @Tran_Leave_ID	NUMERIC
	DECLARE @CF_Leave_Days	NUMERIC(18,2)
	DECLARE @Leave_CompOff_Dates	VARCHAR(MAX)
	DECLARE @Apply_Hourly   NUMERIC
	
	SET @To_Date = CONVERT(DATETIME,CONVERT(VARCHAR(10), GETDATE(), 111))
	SET @Curr_Emp_Id = 0
	SET @Leave_ID = 0
	SET @Tran_Leave_ID = 0
	SET @CF_Leave_Days = 0
	SET @Leave_CompOff_Dates = ''
	SET @Apply_Hourly = 0
	
	CREATE TABLE #temp_CompOff
		(
			Leave_opening	DECIMAL(18,2),
			Leave_Used		DECIMAL(18,2),
			Leave_Closing	DECIMAL(18,2),
			Leave_Code		VARCHAR(MAX),
			Leave_Name		VARCHAR(MAX),
			Leave_ID		NUMERIC,
			CompOff_String  VARCHAR(MAX) DEFAULT NULL
		)
	
	SELECT @Leave_ID = Leave_ID , @Tran_Leave_ID = ISNULL(Trans_Leave_ID,0) , @Apply_Hourly = ISNULL(Apply_Hourly,0) FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE ISNULL(Cmp_ID,0) = ISNULL(@Cmp_ID ,ISNULL(Cmp_ID,0))  AND ISNULL(Default_Short_Name,'') = 'COMP'
	
	IF @Leave_ID = 0 OR @Tran_Leave_ID = 0
		RETURN
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )   
 
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID = @Cmp_ID,@From_Date = @To_Date , @To_Date = @To_Date ,@Branch_ID = '',@Cat_ID ='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@constraint=''

	DECLARE Curr_Comp CURSOR FOR
		SELECT DISTINCT LT.emp_id 
		FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON LT.Emp_ID = EC.Emp_ID 
		WHERE Leave_ID = @Leave_ID AND LT.CompOff_Balance > 0
				--AND For_date >= DATEADD(m,-6,@To_Date) AND For_date <= DATEADD(m,-3,@To_Date)	--between Last 3 to 6 month
	OPEN Curr_Comp	
	FETCH NEXT FROM Curr_Comp INTO @Curr_Emp_Id
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM #temp_CompOff
			SET @CF_Leave_Days = 0
			SET @Leave_CompOff_Dates = ''
			
			EXEC GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Curr_Emp_Id,@Leave_ID,0,0,55
			
			IF EXISTS ( SELECT 1 FROM #temp_CompOff )
				BEGIN
					SELECT @CF_Leave_Days = ISNULL(Leave_Closing,0) , @Leave_CompOff_Dates = ISNULL(CompOff_String,'') FROM #temp_CompOff
					
					IF @CF_Leave_Days > 0 
						BEGIN
							IF @Apply_Hourly = 1
								BEGIN
									SET @CF_Leave_Days = @CF_Leave_Days * 0.125
								END
							
							EXEC P0100_LEAVE_CF_DETAIL @Leave_CF_ID=0,@Cmp_ID=@Cmp_ID,@Emp_ID=@Curr_Emp_Id,@Leave_ID=@Tran_Leave_ID,@CF_For_Date=@To_Date,@CF_From_Date=@To_Date,@CF_To_Date=@To_Date,@CF_P_Days=0,@CF_Leave_Days=@CF_Leave_Days,@CF_Type='COMP',@tran_type='Insert',@Leave_CompOff_Dates = @Leave_CompOff_Dates
								
						END 
						
					
				END
			
			FETCH NEXT FROM Curr_Comp INTO @Curr_Emp_Id
		END
	CLOSE Curr_Comp
	DEALLOCATE Curr_Comp

		
		
END

