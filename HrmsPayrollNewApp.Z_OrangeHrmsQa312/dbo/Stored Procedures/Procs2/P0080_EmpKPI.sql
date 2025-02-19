


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0080_EmpKPI]
	 @EmpKPI_Id		numeric(18,0) output
	,@Cmp_Id		numeric(18,0)
	,@Emp_Id		numeric(18,0)
	,@Status		int
	,@FinancialYr	int
	,@Emp_Comments	varchar(500)=''
	,@Mgr_Comments	varchar(500)=''
	,@HR_Comments	varchar(500)=''
	,@CreatedBy		numeric(18,0) = 0
	,@tran_type		 varchar(1) 
    --,@User_Id		 numeric(18,0) = 0
	,@IP_Address	 varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		Begin
			If Not exists(select 1 from T0080_EmpKPI WITH (NOLOCK) where Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id and FinancialYr=@FinancialYr)
				Begin					
					Select @EmpKPI_Id = isnull(max(EmpKPI_Id),0) + 1 from T0080_EmpKPI WITH (NOLOCK)
					Insert Into T0080_EmpKPI
					(
						 EmpKPI_Id
						,Cmp_Id
						,Emp_Id
						,Status
						,FinancialYr
						,CreatedDate
						,CreatedBy
						,Emp_Comments
						,Mgr_Comments
						,HR_Comments
					)
					Values
					(
						 @EmpKPI_Id
						,@Cmp_Id
						,@Emp_Id
						,@Status
						,@FinancialYr
						,GETDATE()
						,@CreatedBy
						,@Emp_Comments
						,@Mgr_Comments
						,@HR_Comments
					)
				End
		End
	Else If Upper(@tran_type) ='U' 
		Begin
			Update T0080_EmpKPI
			set   [Status] = @Status,
				  LastEditDate = GETDATE(),
				  Emp_Comments = @Emp_Comments,
				  Mgr_Comments = @Mgr_Comments,
				  HR_Comments  = @HR_Comments
			Where EmpKPI_Id=@EmpKPI_Id and Emp_Id=@Emp_Id 
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			--added on 12 mar 2015 sneha
			declare @tranlevl as numeric(18,0)
			
			declare cur cursor
				for 
					select  Tran_Id from T0090_EmpKPI_Approval WITH (NOLOCK) where EmpKPI_Id = @EmpKPI_Id
				open cur
					fetch next from cur into @tranlevl
					WHILE @@FETCH_STATUS = 0
					begin 
						delete from T0100_KPIObjectives_Level  where Tran_Id = @tranlevl
								
						fetch next from cur into @tranlevl		
					End
					close cur
	
					open cur
					fetch next from cur into @tranlevl
					WHILE @@FETCH_STATUS = 0
					begin  
						delete from T0100_EMpKPI_Master_Level  where Tran_Id = @tranlevl							
						fetch next from cur into @tranlevl		
					End
					close cur
	
					open cur
					fetch next from cur into @tranlevl
					WHILE @@FETCH_STATUS = 0
					begin  
						delete from T0090_SubKPI_Master_Level  where Tran_Id = @tranlevl		
						fetch next from cur into @tranlevl		
					end
				close cur
				deallocate cur		
			delete from T0090_EmpKPI_Approval where EmpKPI_Id=@EmpKPI_Id
			--ended on 12 mar 2015 sneha	
			Delete from T0080_KPIObjectives where EmpKPI_Id=@EmpKPI_Id
			Delete from T0040_EmpKPI_Master where EmpKPI_Id=@EmpKPI_Id
			Delete from T0080_SubKPI_Master where EmpKPI_Id=@EmpKPI_Id  
			Delete from T0080_EmpKPI where EmpKPI_Id=@EmpKPI_Id 
		End
	--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'KPI Objective Employee','',@EmpKPI_Id,@CreatedBy,@IP_Address
END


