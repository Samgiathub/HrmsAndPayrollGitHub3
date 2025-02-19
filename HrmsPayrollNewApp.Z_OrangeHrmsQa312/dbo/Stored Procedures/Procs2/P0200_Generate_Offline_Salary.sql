

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Generate_Offline_Salary]
	 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Pre_Salary_Data_Exe
	(
		Tran_id numeric(18,0)
		,Type nvarchar(50)
		,M_Sal_Tran_ID nvarchar(50) 
		,Emp_Id   Numeric      
		,Cmp_ID   Numeric      
		,Sal_Generate_Date nvarchar(50) 
		,Month_St_Date  nvarchar(50)
		,Month_End_Date nvarchar(50)
		,Present_Days  Numeric(18,2)      
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
		,User_Id numeric(18,0) 	
		,IP_Address varchar(30) 
		,Is_processed tinyint
	)
	
	
	CREATE TABLE #Pre_Salary_Data_monthly_Exe
	(
		Tran_id numeric(18,0)
		,Type nvarchar(50)
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
		 ,Is_processed tinyint
	) 
	
	declare @cur_Tran_id as numeric(18,0)
	Declare @cur_Type as nvarchar(50)
	Declare @cur_M_Sal_Tran_ID  as nvarchar(50) 
	Declare @cur_Emp_Id   as  Numeric      
	Declare @cur_Cmp_ID  as   Numeric      
	Declare @cur_Sal_Generate_Date as  nvarchar(50) 
	Declare @cur_Month_St_Date  as  nvarchar(50)
	Declare @cur_Month_End_Date as  nvarchar(50)
	Declare @cur_Present_Days  as  Numeric(18,2)      
	Declare @cur_M_OT_Hours  as  Numeric(18,2)      
	Declare @cur_Areas_Amount  as  Numeric(18,2)       
	Declare @cur_M_IT_Tax   as  NUMERIC(18,2)      
	Declare @cur_Other_Dedu  as  numeric(18,2)      
	Declare @cur_M_LOAN_AMOUNT  as  NUMERIC      
	Declare @cur_M_ADV_AMOUNT  as  NUMERIC      
	Declare @cur_IS_LOAN_DEDU  as  NUMERIC      
	Declare @cur_Login_ID   as  Numeric    
	Declare @cur_ErrRaise  as   Varchar(100) 
	Declare @cur_Is_Negetive  as  Varchar(1)  
	Declare @cur_Status  as   varchar(10)  
	Declare @cur_IT_M_ED_Cess_Amount  as numeric(18,2)
	Declare @cur_IT_M_Surcharge_Amount  as numeric(18,2)
	Declare @cur_Allo_On_Leave as  numeric(18,0) 
	Declare @cur_User_Id  as numeric(18,0) 	
	Declare @cur_IP_Address  as varchar(30)	  
	declare @Cur_Is_processed as tinyint
	
	
	declare @cur_mon_Tran_id as numeric(18,0)
	declare @Cur_mon_Type as nvarchar(50)
	declare @Cur_mon_M_Sal_Tran_ID  as nvarchar(50) 
	declare @Cur_mon_Emp_Id    as Numeric      
	declare @Cur_mon_Cmp_ID    as Numeric      
	declare @Cur_mon_Sal_Generate_Date  as nvarchar(50) 
	declare @Cur_mon_Month_St_Date   as nvarchar(50)
	declare @Cur_mon_Month_End_Date  as nvarchar(50)
	declare @Cur_mon_M_OT_Hours   as Numeric(18,2)      
	declare @Cur_mon_Areas_Amount   as Numeric(18,2)       
	declare @Cur_mon_M_IT_Tax    as NUMERIC(18,2)      
	declare @Cur_mon_Other_Dedu   as numeric(18,2)      
	declare @Cur_mon_M_LOAN_AMOUNT   as NUMERIC      
	declare @Cur_mon_M_ADV_AMOUNT   as NUMERIC      
	declare @Cur_mon_IS_LOAN_DEDU   as NUMERIC      
	declare @Cur_mon_Login_ID    as Numeric    
	declare @Cur_mon_ErrRaise  as Varchar(100) 
	declare @Cur_mon_Is_Negetive   as Varchar(1)  
	declare @Cur_mon_Status    as varchar(10)  
	declare @Cur_mon_IT_M_ED_Cess_Amount  as numeric(18,2)
	declare @Cur_mon_IT_M_Surcharge_Amount  as numeric(18,2)
	declare @Cur_mon_Allo_On_Leave  as numeric(18,0) 
	declare @Cur_mon_W_OT_Hours   as Numeric(18,2)
	declare @Cur_mon_H_OT_Hours  as Numeric(18,2)
	declare @Cur_mon_User_Id  as numeric(18,0) 	
	declare @Cur_mon_IP_Address  as varchar(30) 
	declare @Cur_mon_Is_processed as tinyint
	
	Declare @LogDesc	nvarchar(max)
	Declare @Error nvarchar(max)
	
	insert INTO #Pre_Salary_Data_Exe 
	select TOP 1000 * from t0200_Pre_Salary_Data WITH (NOLOCK) where is_processed = 0
	
	 insert INTO #Pre_Salary_Data_monthly_Exe 
	select TOP 1000 * from t0200_Pre_Salary_Data_monthly WITH (NOLOCK) where is_processed = 0
	
	
	declare curExecSalar cursor for                    
		select * from #Pre_Salary_Data_Exe
	open curExecSalar                      
	fetch next from curExecSalar into @cur_Tran_id, @cur_Type,	@cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID , @cur_Sal_Generate_Date, @cur_Month_St_Date, @cur_Month_End_Date,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   ,@Cur_Is_processed
	WHILE @@fetch_status = 0                    
		BEGIN
			Set @LogDesc = ''
			Set @Error = ''
			BEGIN TRY
				
				exec P0200_MONTHLY_SALARY_GENERATE_MANUAL @cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID ,  @cur_Sal_Generate_Date , @cur_Month_St_Date, @cur_Month_End_Date,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   
		
				update t0200_Pre_Salary_Data SET is_processed = 1 where Tran_ID = @cur_Tran_id
				
			END TRY
			
			BEGIN CATCH
				set @LogDesc = 'Emp_ID='+@cur_Emp_Id+', Month='+cast(MONTH(@cur_Month_End_Date) as varchar)+', Year='+cast(year(@cur_Month_End_Date) as varchar)
				set @Error = ERROR_MESSAGE()
				exec Event_Logs_Insert 0,@cur_Cmp_ID,@cur_Emp_Id,@cur_User_Id,'Salary Manual',@Error,@LogDesc,1,''			 		
			END CATCH
			 
			fetch next from curExecSalar into @cur_Tran_id, @cur_Type,	@cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID , @cur_Sal_Generate_Date, @cur_Month_St_Date, @cur_Month_End_Date,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   ,@Cur_Is_processed
		END
	close curExecSalar        
	Deallocate curExecSalar
	  
	 
	declare curExecSalarMon cursor for                    
		select * from #Pre_Salary_Data_monthly_Exe
	open curExecSalarMon                      
	fetch next from curExecSalarMon into @cur_mon_Tran_id, @Cur_mon_Type,@Cur_mon_M_Sal_Tran_ID,@Cur_mon_Emp_Id ,@Cur_mon_Cmp_ID    ,@Cur_mon_Sal_Generate_Date ,@Cur_mon_Month_St_Date , @Cur_mon_Month_End_Date , @Cur_mon_M_OT_Hours , @Cur_mon_Areas_Amount  , @Cur_mon_M_IT_Tax , @Cur_mon_Other_Dedu , @Cur_mon_M_LOAN_AMOUNT , @Cur_mon_M_ADV_AMOUNT , @Cur_mon_IS_LOAN_DEDU , @Cur_mon_Login_ID ,@Cur_mon_ErrRaise   , @Cur_mon_Is_Negetive  , @Cur_mon_Status , @Cur_mon_IT_M_ED_Cess_Amount , @Cur_mon_IT_M_Surcharge_Amount , @Cur_mon_Allo_On_Leave , @Cur_mon_W_OT_Hours , @Cur_mon_H_OT_Hours , @Cur_mon_User_Id , @Cur_mon_IP_Address  ,@Cur_mon_Is_processed
	WHILE @@fetch_status = 0                   
		BEGIN
			Set @LogDesc = ''
			Set @Error = ''
			BEGIN TRY
				exec P0200_MONTHLY_SALARY_GENERATE_PRORATA @Cur_mon_M_Sal_Tran_ID,@Cur_mon_Emp_Id ,@Cur_mon_Cmp_ID    ,@Cur_mon_Sal_Generate_Date ,@Cur_mon_Month_St_Date , @Cur_mon_Month_End_Date , @Cur_mon_M_OT_Hours , @Cur_mon_Areas_Amount  , @Cur_mon_M_IT_Tax , @Cur_mon_Other_Dedu , @Cur_mon_M_LOAN_AMOUNT , @Cur_mon_M_ADV_AMOUNT , @Cur_mon_IS_LOAN_DEDU , @Cur_mon_Login_ID ,@Cur_mon_ErrRaise   , @Cur_mon_Is_Negetive  , @Cur_mon_Status , @Cur_mon_IT_M_ED_Cess_Amount , @Cur_mon_IT_M_Surcharge_Amount , @Cur_mon_Allo_On_Leave , @Cur_mon_W_OT_Hours , @Cur_mon_H_OT_Hours , @Cur_mon_User_Id , @Cur_mon_IP_Address
				 
				update t0200_Pre_Salary_Data_monthly SET is_processed = 1 where Tran_ID = @cur_mon_Tran_id

			END TRY
			
			BEGIN CATCH
				set @LogDesc = 'Emp_ID='+@cur_Emp_Id+', Month='+cast(MONTH(@cur_Month_End_Date) as varchar)+', Year='+cast(year(@cur_Month_End_Date) as varchar)
				set @Error = ERROR_MESSAGE()
				exec Event_Logs_Insert 0,@cur_Cmp_ID,@cur_Emp_Id,@cur_User_Id,'Salary Monthly',@Error,@LogDesc,1,''			 		
			END CATCH
			 
			fetch next from curExecSalarMon into  @cur_mon_Tran_id, @Cur_mon_Type,@Cur_mon_M_Sal_Tran_ID,@Cur_mon_Emp_Id ,@Cur_mon_Cmp_ID    ,@Cur_mon_Sal_Generate_Date ,@Cur_mon_Month_St_Date , @Cur_mon_Month_End_Date , @Cur_mon_M_OT_Hours , @Cur_mon_Areas_Amount  , @Cur_mon_M_IT_Tax , @Cur_mon_Other_Dedu , @Cur_mon_M_LOAN_AMOUNT , @Cur_mon_M_ADV_AMOUNT , @Cur_mon_IS_LOAN_DEDU , @Cur_mon_Login_ID ,@Cur_mon_ErrRaise   , @Cur_mon_Is_Negetive  , @Cur_mon_Status , @Cur_mon_IT_M_ED_Cess_Amount , @Cur_mon_IT_M_Surcharge_Amount , @Cur_mon_Allo_On_Leave , @Cur_mon_W_OT_Hours , @Cur_mon_H_OT_Hours , @Cur_mon_User_Id , @Cur_mon_IP_Address  ,@Cur_mon_Is_processed
		END
	close curExecSalarMon        
	Deallocate curExecSalarMon
	
	drop TABLE #Pre_Salary_Data_Exe  
	drop TABLE #Pre_Salary_Data_monthly_Exe
	
END

