-- =============================================
-- Author:		<Author,,Yogesh Patel>
-- Create date: <29-08-2022,,>
-- Description:	<Description,To Gate Date count and Time taken,>
-- =============================================
-- exec [dbo].[P0200_Get_Salary_Count_Time] 121,7021
CREATE PROCEDURE [dbo].[P0200_Get_Salary_Count_Time]
	-- Add the parameters for the stored procedure here
	 @Cmp_ID as integer
	,@User_ID as integer
	
AS
BEGIN
--Declare @Totalcnt as int,@TotalProcessed as int
--set @Totalcnt=(Select top 1 Count(*) as 'Total' From T0080_Pre_Multi_Salary_Data_monthly where  User_ID=@User_ID and Cmp_ID = @Cmp_ID Group by ID)
--set @TotalProcessed=(Select Top 1 Count(*) as 'Total Processed' From T0080_Pre_Multi_Salary_Data_monthly where  Sal_Generate_Date=(select Max(Sal_Generate_Date) from T0080_Pre_Multi_Salary_Data_monthly where USER_ID=@User_ID) and User_ID=@User_ID and  Processed = 1 and Cmp_ID = @Cmp_ID Group by ID)

--if @Totalcnt=@TotalProcessed
--begin

	--create Table #FinalTable (Date Varchar(10),Count integer,ProcessTime  Varchar(10))
	--select distinct top 5  ROW_NUMBER() OVER(ORDER BY id ASC) AS RNo,Id
	--into #SalaryID from T0200_Pre_Multi_Salary where USERID=@User_ID and Cmp_id=@Cmp_ID and Processed=1 and Convert(date,date,103)=Convert(date,getdate(),103) Group by ID order by ID 
	--Declare @Countter as integer=1
	--While (select Count(*) from #SalaryID)>= @Countter
	--begin
	-- insert into #FinalTable (Date,Count,ProcessTime)
	--Values
	--((Select top 1 FORMAT(DATE,'dd-MM-yyyy') from T0200_Pre_Multi_Salary Where  USERID=@User_ID and Cmp_id=@Cmp_ID and Processed=1 and Convert(date,date,103)=Convert(date,getdate(),103) and ID=(Select id from #SalaryID where RNo=@Countter)),
	--(Select Count(*) from T0200_Pre_Multi_Salary Where  USERID=@User_ID and Cmp_id=@Cmp_ID and Processed=1 and Convert(date,date,103)=Convert(date,getdate(),103) and ID=(Select id from #SalaryID where RNo=@Countter)),
	-- convert(char(8),dateadd(s,datediff(s,(Convert(Varchar(8),( select top 1 StartTime from T0200_Pre_Multi_Salary where id=(Select id from #SalaryID where RNo=@Countter) order by Row_Id asc ),108) )
	--,(Convert(Varchar(8),( select top 1 EndTime from T0200_Pre_Multi_Salary where id=(Select id from #SalaryID where RNo=@Countter) order by Row_Id desc ),108))),'1900-1-1'),8))

	--set @Countter=@Countter+1
	--end
 --Select top 5 * from #FinalTable
	--Drop table #SalaryID,#FinalTable
	--End
	create Table #FinalTable (Batch Varchar(50),DDate datetime,TotalProcessed int,Count int,ProcessTime  Varchar(10))

	--select distinct  ROW_NUMBER() OVER(ORDER BY id ASC) AS RNo,Id,Concat('Batch-',+ row_number() over (partition by Convert(date,date,103), Convert(date,date,103) order by date)) AS 'Batch No'
	select distinct  ROW_NUMBER() OVER(ORDER BY id ASC) AS RNo,Id,(select Login_Name from T0011_LOGIN where Login_ID=@User_ID and Cmp_id=@Cmp_ID) as 'User'--Concat('Batch-',+ row_number() over (partition by Convert(date,date,103), Convert(date,date,103) order by date)) AS 'Batch No'
	into #SalaryID from T0200_Pre_Multi_Salary where USERID=@User_ID and Cmp_id=@Cmp_ID --and Processed=1 
	and Convert(date,date,103) between Convert(date,getdate()-1,103) and Convert(date,getdate(),103) Group by ID,Date order by ID 
	Declare @Countter as integer=1
--select * from #SalaryID



	While (select Count(*) from #SalaryID)>= @Countter
	begin
	 insert into #FinalTable (Batch,DDate,TotalProcessed,Count,ProcessTime)
	Values
	((Select distinct [User] from #SalaryID where RNo=@Countter), 
	(Select top 1 Convert(varchar,Date,100) from T0200_Pre_Multi_Salary Where  USERID=@User_ID and Cmp_id=@Cmp_ID and Processed=1 and Convert(date,date,103)between Convert(date,getdate()-1,103) and Convert(date,getdate(),103) and ID=(Select id from #SalaryID where RNo=@Countter)),
	(Select Count(*) from T0200_Pre_Multi_Salary Where  USERID=@User_ID and Cmp_id=@Cmp_ID and Processed=1 and Convert(date,date,103)between Convert(date,getdate()-1,103) and Convert(date,getdate(),103) and ID=(Select id from #SalaryID where RNo=@Countter)),
	(Select Count(*) from T0200_Pre_Multi_Salary Where  USERID=@User_ID and Cmp_id=@Cmp_ID  and Convert(date,date,103)between Convert(date,getdate()-1,103) and Convert(date,getdate(),103) and ID=(Select id from #SalaryID where RNo=@Countter)),
	 convert(char(8),dateadd(s,datediff(s,(Convert(Varchar(8),( select top 1 StartTime from T0200_Pre_Multi_Salary where id=(Select id from #SalaryID where RNo=@Countter) order by Row_Id asc ),108) )
	,(Convert(Varchar(8),( select top 1 EndTime from T0200_Pre_Multi_Salary where id=(Select id from #SalaryID where RNo=@Countter)AND Processed=1 order by Row_Id desc ),108))),'1900-1-1'),8))

	set @Countter=@Countter+1
	end
 Select  Batch,Convert(Varchar,DDate,100) as 'Date_Time',TotalProcessed AS 'Successfully_Processed',Count as 'Out_of_Total_Process',ProcessTime as 'Process_Time' from #FinalTable order by DDate
	Drop table #SalaryID,#FinalTable
	End