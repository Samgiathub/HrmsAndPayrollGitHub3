-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 23-10-2020
-- Description:	Get OT QUARTERLY HOURS
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OT_QUARTERLYHOURS]
(
	@Emp_ID		numeric,
	@For_Date	datetime
)  
RETURNS NUMERIC(18,2)
AS  
BEGIN 
	DECLARE @TOT_QTR_HOURS	NUMERIC(18,2)
	SET @TOT_QTR_HOURS = 0.0
	Declare @SqlQuery As NVarchar(max)

		IF MONTH(@For_Date) IN(1,2,3)
			BEGIN				
				SELECT @TOT_QTR_HOURS=CAST(SUM(dbo.f_return_sec(REPLACE(Approved_OT_Hours,'.',':' )))+SUM(dbo.f_return_sec(REPLACE(Approved_WO_OT_Hours,'.',':')))+SUM(dbo.f_return_sec(REPLACE(Approved_HO_OT_Hours,'.',':')))as numeric(18,2)) FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(1,2,3) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END
		ELSE IF MONTH(@For_Date) IN(4,5,6)
			BEGIN				
				SELECT @TOT_QTR_HOURS=CAST((SUM(dbo.f_return_sec(REPLACE(Approved_OT_Hours,'.',':' )))+SUM(dbo.f_return_sec(REPLACE(Approved_WO_OT_Hours,'.',':')))+SUM(dbo.f_return_sec(REPLACE(Approved_HO_OT_Hours,'.',':'))))as numeric(18,2)) FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(4,5,6) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END
		ELSE IF MONTH(@For_Date) IN(7,8,9)
			BEGIN					
				SELECT @TOT_QTR_HOURS=CAST(SUM(dbo.f_return_sec(REPLACE(Approved_OT_Hours,'.',':' )))+SUM(dbo.f_return_sec(REPLACE(Approved_WO_OT_Hours,'.',':')))+SUM(dbo.f_return_sec(REPLACE(Approved_HO_OT_Hours,'.',':')))as numeric(18,2)) FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(7,8,9) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END		
		ELSE IF MONTH(@For_Date) IN(10,11,12)
			BEGIN				
				SELECT @TOT_QTR_HOURS=CAST(SUM(dbo.f_return_sec(REPLACE(Approved_OT_Hours,'.',':' )))+SUM(dbo.f_return_sec(REPLACE(Approved_WO_OT_Hours,'.',':')))+SUM(dbo.f_return_sec(REPLACE(Approved_HO_OT_Hours,'.',':')))as numeric(18,2)) FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(10,11,12) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END	
	Return isnull(CAST(Replace(Dbo.F_Return_Hours(isnull(@TOT_QTR_HOURS,0)),':','.') AS NUMERIC(18,2)),0.0)
	--Return isnull(CAST(Dbo.F_Return_Hours(isnull(@TOT_QTR_HOURS,0))AS NUMERIC(18,2)),0.0)
END
