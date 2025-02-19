-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 23-10-2020
-- Description:	Get OT QUARTERLY HOURS
-- =============================================
CREATE FUNCTION [dbo].[F_Get_OT_QUARTERLYHOURS_New_Dup]
(
	@cmp_ID numeric,
	@Emp_ID		numeric,
	@For_Date	datetime,
	@salry_Cycle Tinyint = 0,
	@Rpt_level tinyint = 0
)  
RETURNS NUMERIC
AS  
BEGIN 
	DECLARE @TOT_QTR_HOURS	decimal(18,4)
	SET @TOT_QTR_HOURS = 0.0
	Declare @SqlQuery As NVarchar(max)
	Declare @month tinyint
	Declare @monthStDate date
	Declare @Qtr_St_Date date
	Declare @Qtr_End_Date date
	IF @salry_Cycle =1 
	BEGIN
		select @month= MONTH(@For_Date) 
		SELECT @monthStDate =  DATEFROMPARTS(YEAR(GETDATE()),@month,1)
		select @Qtr_St_Date = Month_St_Date,@Qtr_End_Date=Month_End_Date from T0040_Quarter_Details_Salarywise where Cmp_ID=@cmp_ID and @monthStDate between Month_St_Date and Month_End_Date
		SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
		FROM T0160_OT_Approval WITH (NOLOCK) 
		WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND For_Date between @Qtr_St_Date and @Qtr_End_Date
	END
	ELSE IF @salry_Cycle =2
	BEGIN
		IF MONTH(@For_Date) IN(1,2,3)
			BEGIN			
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) 
				WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(1,2,3) and YEAR(FOR_DATE)=YEAR(@For_Date)  and Rpt_Level=@Rpt_level
			END
		ELSE IF MONTH(@For_Date) IN(4,5,6)
			BEGIN	
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) 
				WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(4,5,6) and YEAR(FOR_DATE)=YEAR(@For_Date) and Rpt_Level=@Rpt_level
				
			END
		ELSE IF MONTH(@For_Date) IN(7,8,9)
			BEGIN					
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
				WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(7,8,9) and YEAR(FOR_DATE)=YEAR(@For_Date) and Rpt_Level=@Rpt_level
			END		
		ELSE IF MONTH(@For_Date) IN(10,11,12)
			BEGIN				
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) 
				WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(10,11,12) and YEAR(FOR_DATE)=YEAR(@For_Date) and Rpt_Level=@Rpt_level
			END	
	END
	ELSE
	BEGIN
		IF MONTH(@For_Date) IN(1,2,3)
			BEGIN				
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(1,2,3) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END
		ELSE IF MONTH(@For_Date) IN(4,5,6)
			BEGIN				
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(4,5,6) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END
		ELSE IF MONTH(@For_Date) IN(7,8,9)
			BEGIN					
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(7,8,9) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END		
		ELSE IF MONTH(@For_Date) IN(10,11,12)
			BEGIN				
				SELECT @TOT_QTR_HOURS=SUM(CAST(CAST(Approved_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_WO_OT_Hours AS FLOAT)as decimal(10,2)))+SUM(CAST(CAST(Approved_HO_OT_Hours AS FLOAT)as decimal(10,2)))
				FROM T0160_OT_Approval WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Is_Approved=1 AND MONTH(FOR_DATE) IN(10,11,12) and YEAR(FOR_DATE)=YEAR(@For_Date)
			END	
	END
	return dbo.f_return_sec(cast(@TOT_QTR_HOURS as numeric(18,2)))
	--return  isnull(dbo.f_return_sec(@TOT_QTR_HOURS),0.0)
END
