

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec GetKPIPMS_ObjStatus 3068,2015,0,0
-- exec GetKPIPMS_ObjStatus 3068,2015,0,24
-- exec GetKPIPMS_ObjStatus 3068,2015,11,27
-- exec GetKPIPMS_ObjStatus 3068,2015,11,0
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GetKPIPMS_ObjStatus]
	 @emp_id		numeric(18,0)
	,@finyear		int
	,@kpipms_id		numeric(18,0) = 0
	,@kpiobj		numeric(18,0) = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	create table #KPI_Temp
	(
		 KPIObj_ID		numeric(18,0)
		,oStatus		varchar(250)
		,KPIPMS_Name	varchar(50)	
	)

declare @KPIObj_ID numeric(18,0)
	
	if @kpiobj = 0
		begin
			--check whether the emp and fin exists in eval table
			if exists(select * from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_ID = @emp_id and KPIPMS_FinancialYr=@finyear)
		begin
			Insert into #KPI_Temp (KPIObj_ID) 
			select KPIObj_ID from T0080_KPIObjectives ob WITH (NOLOCK) inner join T0080_EmpKPI k WITH (NOLOCK) on k.EmpKPI_Id = ob.EmpKPI_Id 
			where k.FinancialYr = @finyear and k.Emp_Id= @emp_id
			
			declare cur cursor
			for 
				select KPIObj_ID from #KPI_Temp
			open cur
			fetch next from cur into @KPIObj_ID
				while @@FETCH_STATUS = 0
				begin
					
					if @kpipms_id =0
						begin							
							update #KPI_Temp set oStatus=obj.[Status],KPIPMS_Name=obj.KPIPMS_Name from
							(select [Status],e.KPIPMS_Name from T0090_KPIPMS_Objective po WITH (NOLOCK) inner join T0080_KPIPMS_EVAL e WITH (NOLOCK) on e.KPIPMS_ID = po.KPIPMS_ID
							 where KPIPMS_FinancialYr = @finyear and e.Emp_ID = @emp_id and KPIObj_ID=@KPIObj_ID)obj
							where KPIObj_ID = @KPIObj_ID
						End
					Else
						Begin
							update #KPI_Temp set oStatus=obj.[Status],KPIPMS_Name=obj.KPIPMS_Name from
							(select [Status],e.KPIPMS_Name from T0090_KPIPMS_Objective po WITH (NOLOCK) inner join T0080_KPIPMS_EVAL e WITH (NOLOCK) on e.KPIPMS_ID = po.KPIPMS_ID
							 where KPIPMS_FinancialYr = @finyear and e.Emp_ID = @emp_id and KPIObj_ID=@KPIObj_ID and  e.KPIPMS_ID <> @kpipms_id and e.KPIPMS_ID < @kpipms_id )obj
							where KPIObj_ID = @KPIObj_ID
						End
					fetch next from cur into @KPIObj_ID
				End
			close cur
			deallocate cur
		End
		end
	Else
		Begin
			if @kpipms_id =0
				begin
					Insert into #KPI_Temp (KPIObj_ID,oStatus,KPIPMS_Name) 
						select KPIObj_ID,[Status],e.KPIPMS_Name from T0090_KPIPMS_Objective po WITH (NOLOCK)  inner join T0080_KPIPMS_EVAL e WITH (NOLOCK) on e.KPIPMS_ID = po.KPIPMS_ID
						where KPIPMS_FinancialYr = @finyear and e.Emp_ID = @emp_id and KPIObj_ID=@kpiobj
				end
			Else
				Begin
					Insert into #KPI_Temp (KPIObj_ID,oStatus,KPIPMS_Name) 
						select KPIObj_ID,[Status],e.KPIPMS_Name from T0090_KPIPMS_Objective po WITH (NOLOCK) inner join T0080_KPIPMS_EVAL e WITH (NOLOCK) on e.KPIPMS_ID = po.KPIPMS_ID
						where KPIPMS_FinancialYr = @finyear and e.Emp_ID = @emp_id and KPIObj_ID=@kpiobj and  e.KPIPMS_ID <> @kpipms_id and e.KPIPMS_ID < @kpipms_id
				End
		End
		
	select * from #KPI_Temp
	
	Drop TABLE #KPI_Temp
END

