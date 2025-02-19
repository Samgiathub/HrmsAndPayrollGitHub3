-- exec P0200_MONTHLY_SALARY_DELETE_NEW1
-- drop proc P0200_MONTHLY_SALARY_DELETE_NEW1
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_DELETE_NEW1]
@SAL_TRAN_ID_EMP_ID varchar(max),
@CMP_ID numeric,
@From_Date datetime,
@to_date datetime,
@User_Id numeric(18,3) = 0,
@IP_Address varchar(30) = '',
@ErrString varchar(30) = null
as
begin	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @i int,@cnt int

	create table #tbltmp
	(
		tid int identity(1,1),t_SalTranId numeric,t_EmpId numeric,t_RaisedError varchar(max),t_Severity int,t_State int,
		t_EmpName varchar(max)
	)
	insert into #tbltmp
	select val1,val2,'',0,0,'' from dbo.Split(@SAL_TRAN_ID_EMP_ID,',') cross apply dbo.fnc_BifurcateString(isnull(data,''),'-') where data <> ''

	update w set t_EmpName = ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from #tbltmp w inner join T0080_EMP_MASTER on Emp_ID = t_EmpId

	select @i = 1,@cnt = count(1) from #tbltmp
	while @i <= @cnt
	begin
		declare @lSalTransId numeric,@lEmpId numeric
		select @lSalTransId = t_SalTranId,@lEmpId = t_EmpId from #tbltmp where tid = @i
		
		BEGIN TRY
			exec P0200_MONTHLY_SALARY_DELETE @lSalTransId,@lEmpId,@CMP_ID,@From_Date,@to_date,'',@User_Id,@IP_Address
		END TRY
		BEGIN CATCH
			update #tbltmp set t_RaisedError = ERROR_MESSAGE(),t_Severity = ERROR_SEVERITY(),t_State = ERROR_STATE() where tid = @i
		END CATCH

		select @i = @i + 1
	end

	select t_EmpId as EmpId,t_RaisedError as RaisedError,t_Severity as Severity,
	t_State as ErrorState,t_EmpName as EmpName from #tbltmp where t_State > 0	
end