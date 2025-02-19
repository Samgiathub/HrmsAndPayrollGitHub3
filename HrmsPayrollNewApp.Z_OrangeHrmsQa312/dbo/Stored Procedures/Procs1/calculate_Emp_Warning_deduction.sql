


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <15/04/2014>
-- Description:	<employee Assign Warning deduction amount>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[calculate_Emp_Warning_deduction]
@cmp_Id numeric(18,0),
@emp_Id numeric(18,0),
@Month_st_date datetime,
@Month_End_date datetime,
@Sal_Day_rate numeric(18,2),
@Warning_Deduct_Amount numeric(18,2) output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	/* Commented By Ramiz on 24/07/2017 , as New Provision of Amount Deduction is Added now		
	SELECT @Warning_Deduct_Amount = SUM(ISNULL(Deduct_Days,0) * ISNULL(@Sal_Day_rate,0))    
	FROM  T0050_Warning_Slab WS 
		INNER JOIN
			(			
				SELECT Emp_ID,War_ID,count(war_Id) as War_count  
				FROM T0100_WARNING_DETAIL 
				WHERE Warr_Date>=@Month_st_date and Warr_Date <=@Month_End_date and Emp_Id = @emp_Id and Cmp_ID = @cmp_Id
				GROUP BY Emp_ID,War_ID 
			) qry on qry.war_ID = WS.warning_id
	WHERE WS.From_Hours <= Qry.War_count and WS.To_Hours >= Qry.War_count 
	and qry.Emp_Id = @emp_Id and ws.cmp_id = @cmp_Id
	GROUP BY qry.Emp_Id
	
	*/
	
	SELECT @Warning_Deduct_Amount = SUM(isnull(Qry_Final.WARNING_AMT,0))
	FROM
			(
				SELECT	CASE WHEN ISNULL(WM.DEDUCT_TYPE , 'DAY') = 'DAY' THEN  
							SUM(ISNULL(Deduct_Days,0) * ISNULL(@Sal_Day_rate,0)) 
						ELSE SUM(ISNULL(Deduct_Days,0)) 
						END AS WARNING_AMT
				FROM  T0050_Warning_Slab WS WITH (NOLOCK)
					INNER JOIN
						(			
							SELECT Emp_ID,War_ID,count(war_Id) as War_count  
							FROM T0100_WARNING_DETAIL  WITH (NOLOCK)
							WHERE Warr_Date >= @Month_st_date and Warr_Date <= @Month_End_date and Emp_Id = @emp_Id and Cmp_ID = @cmp_Id
							GROUP BY Emp_ID,War_ID 
						) QRY on qry.war_ID = WS.warning_id
					INNER JOIN T0040_WARNING_MASTER WM WITH (NOLOCK) ON WM.Cmp_ID = WS.CMP_ID AND WM.War_ID = WS.WARNING_ID
					WHERE WS.From_Hours <= Qry.War_count and WS.To_Hours >= Qry.War_count 
					and qry.Emp_Id = @emp_Id and ws.cmp_id = @cmp_Id
					GROUP BY QRY.EMP_ID , WM.DEDUCT_TYPE
			) Qry_Final
	
	
    
END

