create PROCEDURE [dbo].SQL_JOB_SET_FromDate_ToDate
@Cmp_ID numeric
AS
declare @From_Date datetime
declare @To_Date datetime
set @To_Date = CAST(GETDATE() AS varchar(11))
set @From_Date = dateadd(day,-5,@To_Date)

--select @From_Date,@To_Date

exec SP_EMP_INOUT_SYNCHRONIZATION_FromDate_ToDate @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID='0',@Cat_ID='0',@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=6,@constraint='6',@Check_Regularization_Flag=0,@PBranch_ID='0',@PVertical_ID='0',@PSubVertical_ID='0',@PDept_ID='0',@User_Id='1',@IPAddress=''