

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0080_KPIObjectives]
	 @KPIObj_Id		numeric(18,0) OUTPUT
	,@Cmp_ID		numeric(18,0)
	,@KpiAtt_Id		numeric(18,0)
	,@Objective		varchar(Max) 
	,@Emp_Id		numeric(18,0)
	,@CreatedBy_Id	numeric(18,0)
	,@AddByFlag		char(1)
	,@Approve_Status char(1)=null
	,@Verify_Status char(1)=null
	,@EmpKPI_Id		numeric(18,0)
	,@Metric		varchar(500)
	,@tran_type		varchar(1) =null
	,@IP_Address	varchar(30)= ''
	,@status		int=null	
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 declare @OldValue as varchar(max)
	 declare @OldKPI_Id as numeric(18,0)
	 declare @oldSubKPI as varchar(500)
	 declare @oldWeightage as  numeric(18,2)
	
	
	 If Upper(@tran_type) ='I'
		Begin	
			--exec P0080_EmpKPI 0,@Cmp_ID,@Emp_Id,@status,@CreatedBy_Id,@tran_type,@IP_Address
			 
			--select @EmpKPI_Id = EmpKPI_Id from T0080_EmpKPI	where Emp_Id=@Emp_Id
			select @KPIObj_ID = isnull(max(KPIObj_ID),0) + 1 from T0080_KPIObjectives WITH (NOLOCK)
			INSERT INTO T0080_KPIObjectives
			(
				KPIObj_ID
				,Cmp_Id
				,KpiAtt_Id
				,Objective
				,Emp_ID
				,CreatedBy_Id
				,AddByFlag
				,Approve_Status
				,Verification_Status
				,EmpKPI_Id
				,Metric
			)
			Values
			(
				@KPIObj_Id
				,@Cmp_ID
				,@KpiAtt_Id
				,@Objective
				,@Emp_Id
				,@CreatedBy_Id
				,@AddByFlag
				,@Approve_Status
				,@Verify_Status
				,@EmpKPI_Id
				,@Metric
			)
			
				
			--set @OldValue = 'New Value' + '#'+ 'SubKPI_Id :' + cast(ISNULL( @SubKPIID,'')as varchar(18)) + '#' + 'Objective :' +  CAST(ISNULL( @Objective,'')AS varchar(max)) + '#'
			--							+ 'Emp_ID :' +  CAST(ISNULL( @Emp_Id,'')AS varchar(18)) + '#' 
										
		End
	Else if UPPER(@tran_type)='U'
		Begin
			--exec P0080_EmpKPI 0,@Cmp_ID,@Emp_Id,@status,@CreatedBy_Id,@tran_type,@IP_Address
			 
			UPDATE  T0080_KPIObjectives
			SET  Objective=@Objective,
					metric = @Metric			
			WHERE KPIObj_ID = @KPIObj_ID 
		End
	else if UPPER(@tran_type)='D'
		Begin
			Delete from T0080_KPIObjectives where KPIObj_ID=@KPIObj_ID
		End
		--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'KPI Objective',@OldValue,@KPIObj_Id,@CreatedBy_Id,@IP_Address
END


