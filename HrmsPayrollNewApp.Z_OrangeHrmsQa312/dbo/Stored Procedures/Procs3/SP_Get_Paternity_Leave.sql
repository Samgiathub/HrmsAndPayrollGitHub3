

-- =============================================
-- Author:		<Jaina>
-- Create date: <08-05-2018>
-- Description:	<Laps Paternity Leave>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_Paternity_Leave]
	@Cmp_Id numeric(18,0),
	@Emp_Id numeric(18,0) = 0
	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    Create table #Paternity_Leave
	(
		Leave_Tran_Id numeric(18,0),
		Emp_id numeric(18,0),
		For_Date datetime,
		Leave_Opening numeric(18,2),
		Leave_Closing numeric(18,2),
		Laps_Days numeric(18,2),
		From_Date datetime,
		To_Date datetime
	)
	insert INTO #Paternity_Leave
	exec P_Reset_Paternity_Leave @Cmp_Id = @Cmp_Id,@Emp_Id = 0	
			
	update #Paternity_Leave SET To_Date = DATEADD(d,1,To_date)	  
	
	
	if exists(select 1 from #Paternity_Leave PT inner JOIN 
				  T0135_Paternity_Leave_Detail PL WITH (NOLOCK) ON PT.Emp_id = PL.Emp_Id
			  where PT.To_Date <= GETDATE())
	BEGIN
		
		
		UPDATE PL SET PL.LAPS_STATUS = 'Done'
		FROM #PATERNITY_LEAVE PT INNER JOIN 
				  T0135_PATERNITY_LEAVE_Detail PL ON PT.EMP_ID = PL.EMP_ID
		where PT.To_Date <= GETDATE()
	END
	
	
END


