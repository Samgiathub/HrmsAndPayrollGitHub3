
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--exec [dbo].[P0200_Pre_Multi_salary_Process]
CREATE PROCEDURE [dbo].[P0200_Pre_Multi_salary_Process]
	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--select * from T0080_Pre_Multi_Salary_Data_monthly

Declare @MultiEmp as numeric(18,0)

IF OBJECT_ID(N'tempdb..#tm') IS NOT NULL
BEGIN
DROP TABLE #tm
END

SELECT [USER_ID] into #tm FROM T0080_Pre_Multi_Salary_Data_monthly where Processed = 0 group by [USER_ID]

select @MultiEmp = count([USER_ID]) from #tm
--WITH A
--AS (SELECT 
--	[USER_ID]
--	FROM T0080_Pre_Multi_Salary_Data_monthly
--	group by [USER_ID])
--SELECT @MultiEmp = count(1) FROM A

--	IF ((SELECT COUNT(1) FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0) > 0 )
--	BEGIN 
--			INSERT INTO T0200_Pre_Multi_Salary
--			SELECT Salary_Parameter,is_Manual,emp_id,Cmp_ID,Sal_Generate_Date,from_date,To_date,ID,BackEnd_Salary,0,[User_Id] 
--			FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0
	

--	END
--	else 
--		return
--END
--ELSE
--BEGIN
--	IF ((SELECT COUNT(1) FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0) > 0 )
--	BEGIN 
--			INSERT INTO T0200_Pre_Multi_Salary
--			SELECT Salary_Parameter,is_Manual,emp_id,Cmp_ID,Sal_Generate_Date,from_date,To_date,ID,BackEnd_Salary,0,[User_Id] 
--			FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0
--			ORDER BY NEWID();
--	END
--END

IF ((SELECT COUNT(1) FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0) > 0 )
BEGIN 
		select distinct  WSQ.ID into #CheckID from T0200_Pre_Multi_Salary WSQ inner join T0080_Pre_Multi_Salary_Data_monthly SQ on 
				WSQ.ID!=sq.ID 
				and WSQ.Emp_id!=Sq.Emp_Id and WSQ.For_date!=sq.Sal_Generate_Date
				--select * from #CheckID
		if @MultiEmp = 1
			
			INSERT INTO T0200_Pre_Multi_Salary 
			SELECT Salary_Parameter,is_Manual,emp_id,Cmp_ID,Sal_Generate_Date,from_date,To_date,ID,BackEnd_Salary,0,[User_Id],Getdate(),Getdate(),getdate()
				FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0 and ID not in (Select * from #CheckId)
	
		else

			INSERT INTO T0200_Pre_Multi_Salary
			SELECT Salary_Parameter,is_Manual,emp_id,Cmp_ID,Sal_Generate_Date,from_date,To_date,ID,BackEnd_Salary,0,[User_Id] ,Getdate() ,Getdate(),getdate()
			FROM T0080_Pre_Multi_Salary_Data_monthly where processed = 0   and ID not in (Select * from #CheckId)
			ORDER BY NEWID();
			
END

ELSE
BEGIN
		return
END



Declare @query as Varchar(MAX) = ''
Declare @RowNum as numeric(18,0) = 0
Declare @RowId as numeric(18,0) = 0
Declare @EmpId as numeric(18,0) = 0
Declare @For_Date as  DateTime 
Declare @SalPar as Varchar(2000) = ''
Declare @isMan as TinyInt = 0
Declare @Cmpid	as Numeric(18,0) = 0
Declare @FromDate	as DateTime 
Declare @ToDate	as DateTime 
Declare @ID	as Varchar(200) 
Declare @BackEndSal	as tinyInt = 0
Declare @Cnt as int 

--set @Cnt = 1 --Deepal  19092022 Commented
select @Cnt = Min(Row_Id) from T0200_Pre_Multi_Salary where Processed=0

--select @RowNum = count(1) from T0200_Pre_Multi_Salary where Processed=0  --Deepal  19092022 Commented
select @RowNum = Max(Row_Id) from T0200_Pre_Multi_Salary where Processed=0 

While (@Cnt <= @RowNum)
BEGIN
	
	select @SalPar=Salary_Parameter ,@isMan = is_Manual ,@EmpId=Emp_id , @For_Date=For_date ,@Cmpid=Cmp_id ,@FromDate=From_date
	,@ToDate=To_Date , @ID=Id , @BackEndSal = BackEnd_Salary
	from T0200_Pre_Multi_Salary where Row_id = @Cnt
	Select @Cmpid
	--select @SalPar,@isMan,@Cmpid,@FromDate,@ToDate,@ID,@BackEndSal
	exec P0200_Pre_Salary @SalPar,@isMan,@Cmpid,@FromDate,@ToDate,@ID,@BackEndSal
	--select @Cnt
	
	update T0200_Pre_Multi_Salary set Processed = 1 ,EndTime = GetDate() where Row_id = @Cnt and Processed=0 and Emp_id=@EmpId
	update T0080_Pre_Multi_Salary_Data_monthly set Processed = 1 where emp_id = @EmpId and CMp_id = @Cmpid and Sal_Generate_Date =  @For_Date and ID = @ID
	--return
	set @Cnt = @Cnt + 1
END
--update T0200_PRE_SALARY set Processed = 0
--select * from T0200_PRE_SALARY 
--Truncate Table T0200_Pre_Multi_Salary
Drop Table #CheckID

END
