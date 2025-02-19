

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0100_KPIObjectives_Level]
	 @Row_Id		numeric(18,0) OUTPUT
	,@Cmp_ID		numeric(18,0)
	,@Tran_Id		numeric(18,0)
	,@Objective		varchar(Max) 
	,@KpiAtt_Id		numeric(18,0)	
	,@Metric		varchar(500)
	,@tran_type		varchar(1) =null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	 If Upper(@tran_type) ='I'
		Begin	
			--exec P0080_EmpKPI 0,@Cmp_ID,@Emp_Id,@status,@CreatedBy_Id,@tran_type,@IP_Address
			 
			--select @EmpKPI_Id = EmpKPI_Id from T0080_EmpKPI	where Emp_Id=@Emp_Id
			if @Tran_Id=0
					begin 
						select @Tran_Id = max(tran_id)  from T0090_EmpKPI_Approval WITH (NOLOCK)
					end
			
			select @Row_Id = isnull(max(Row_Id),0) + 1 from T0100_KPIObjectives_Level WITH (NOLOCK)
			INSERT INTO T0100_KPIObjectives_Level
			(
				 Row_Id
				,Cmp_Id
				,KpiAtt_Id
				,Objective
				,Tran_Id
				,Metric
			)
			Values
			(
				 @Row_Id
				,@Cmp_Id
				,@KpiAtt_Id
				,@Objective
				,@Tran_Id
				,@Metric
			)
										
		End
	Else if UPPER(@tran_type)='U'
		Begin
			 
			UPDATE  T0100_KPIObjectives_Level
			SET  Objective=@Objective,
					metric = @Metric			
			WHERE Row_Id = @Row_Id
		End
	else if UPPER(@tran_type)='D'
		Begin
			Delete from T0100_KPIObjectives_Level where Row_Id=@Row_Id
		End
		--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'KPI Objective',@OldValue,@KPIObj_Id,@CreatedBy_Id,@IP_Address
END


