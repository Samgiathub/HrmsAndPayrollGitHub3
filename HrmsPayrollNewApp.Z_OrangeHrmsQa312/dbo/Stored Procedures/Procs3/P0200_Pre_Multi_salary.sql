

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Pre_Multi_salary]
	 @Salary_Parameter nvarchar(max)
	,@is_Manual tinyint = 0
	,@cmp_id numeric(18)
	,@from_date datetime
	,@to_date datetime
	,@ID varchar(100) = ''
	,@BackEnd_Salary TINYINT = 0
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	CREATE TABLE #Pre_Multi_Salary_Data_monthly
	(
		Type nvarchar(50)
		,M_Sal_Tran_ID nvarchar(50) 
		,Emp_Id   Numeric      
		,Cmp_ID   Numeric      
		,Sal_Generate_Date nvarchar(50) 
		,Month_St_Date  nvarchar(50)
		,Month_End_Date nvarchar(50)
		,M_OT_Hours  Numeric(18,2)      
		,Areas_Amount  Numeric(18,2)       
		,M_IT_Tax   NUMERIC(18,2)      
		,Other_Dedu  numeric(18,2)      
		,M_LOAN_AMOUNT  NUMERIC      
		,M_ADV_AMOUNT  NUMERIC      
		,IS_LOAN_DEDU  NUMERIC      
		,Login_ID   Numeric    
		,ErrRaise   Varchar(100) 
		,Is_Negetive  Varchar(1)  
		,Status   varchar(10)  
		,IT_M_ED_Cess_Amount numeric(18,2)
		,IT_M_Surcharge_Amount numeric(18,2)
		,Allo_On_Leave numeric(18,0) 
		,W_OT_Hours  Numeric(18,2)
		,H_OT_Hours Numeric(18,2)
		,User_Id numeric(18,0) 	
		,IP_Address varchar(30) 
		,IS_Bond_DEDU  BIT 
		,Salary_Parameter varchar(MAX)
		,is_Manual TinyInt
		,from_date DateTime
		,To_date DateTime
		,ID varchar(2000)
		,BackEnd_Salary tinyInt
		,Processed tinyInt
		,StartTime datetime
		
	) 

	--CREATE TABLE  T0080_Pre_Multi_Salary_Data_monthly
	--(
	--	Type nvarchar(50)
	--	,M_Sal_Tran_ID nvarchar(50) 
	--	,Emp_Id   Numeric      
	--	,Cmp_ID   Numeric      
	--	,Sal_Generate_Date nvarchar(50) 
	--	,Month_St_Date  nvarchar(50)
	--	,Month_End_Date nvarchar(50)
	--	,M_OT_Hours  Numeric(18,2)      
	--	,Areas_Amount  Numeric(18,2)       
	--	,M_IT_Tax   NUMERIC(18,2)      
	--	,Other_Dedu  numeric(18,2)      
	--	,M_LOAN_AMOUNT  NUMERIC      
	--	,M_ADV_AMOUNT  NUMERIC      
	--	,IS_LOAN_DEDU  NUMERIC      
	--	,Login_ID   Numeric    
	--	,ErrRaise   Varchar(100) 
	--	,Is_Negetive  Varchar(1)  
	--	,Status   varchar(10)  
	--	,IT_M_ED_Cess_Amount numeric(18,2)
	--	,IT_M_Surcharge_Amount numeric(18,2)
	--	,Allo_On_Leave numeric(18,0) 
	--	,W_OT_Hours  Numeric(18,2)
	--	,H_OT_Hours Numeric(18,2)
	--	,User_Id numeric(18,0) 	
	--	,IP_Address varchar(30) 
	--	,IS_Bond_DEDU  BIT 
	--	,Salary_Parameter varchar(MAX)
	--	,is_Manual TinyInt
	--	,from_date DateTime
	--	,To_date DateTime
	--	,ID varchar(2000)
	--	,BackEnd_Salary tinyInt
	--	,Processed tinyInt
	--) 
	
--------------------------------------------------------------------------------------------------

	IF OBJECT_ID('tempdb..#Pre_Salary_Data') IS NOT NULL 
		DROP TABLE #Pre_Salary_Data

	--IF OBJECT_ID('tempdb..#Pre_Salary_Data_monthly') IS NOT NULL 
	--	DROP TABLE #Pre_Salary_Data_monthly

	declare @Sal_Param as nvarchar(max)
	declare curPreSalar cursor for                    
		SELECT part from dbo.SplitString2(@Salary_Parameter,'$')
	open curPreSalar                      
	fetch next from curPreSalar into @Sal_Param
	WHILE @@fetch_status = 0                    
		BEGIN
		select @Sal_Param
			if @is_Manual = 1
				begin
					insert into #Pre_Salary_Data 
					SELECT  'Manual' as Cnt , [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],@Sal_Param 
					 from 
					 (
					 SELECT ID, part from  
					 dbo.SplitString2(@Sal_Param,'#') 
					 ) as Table1
					 PIVOT
					 (
					 MAX(Part)
					 FOR ID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24])
					 ) as PIVOTData
				end
			else
				begin
					insert into #Pre_Multi_Salary_Data_monthly
					SELECT  'Monthly' as Cnt , [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],@Sal_Param,@is_Manual,@from_date,@to_date,@ID,@BackEnd_Salary,0,GETDATE()
					 from 
					 (
					 SELECT ID, part from  
					 dbo.SplitString2(@Sal_Param,'#') 
					 ) as Table1
					 PIVOT
					 (
					 MAX(Part)
					 FOR ID in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])
					 ) as PIVOTData
				end
			fetch next from curPreSalar into @Sal_Param		
		END
	close curPreSalar        
	Deallocate curPreSalar  

	--select * from T0080_Pre_Multi_Salary_Data_monthly
	
	IF ((SELECT COUNT(1) FROM #Pre_Multi_Salary_Data_monthly) > 0 )
	BEGIN 
		INSERT INTO T0080_Pre_Multi_Salary_Data_monthly
		SELECT *
		FROM #Pre_Multi_Salary_Data_monthly --where Processed = 0
		--ORDER BY NEWID();
	END
	--SELECT * FROM T0200_PRE_SALARY

	

END



