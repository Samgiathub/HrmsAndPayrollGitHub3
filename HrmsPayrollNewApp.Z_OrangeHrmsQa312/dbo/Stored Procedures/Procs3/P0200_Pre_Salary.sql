


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Pre_Salary]
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
	
	CREATE TABLE #Pre_Salary_Data
	(
		Type nvarchar(50)
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
		,IS_Bond_DEDU  BIT
	)
		
	CREATE TABLE #Pre_Salary_Data_monthly
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
	) 
	
--------------------------------------------------------------------------------------------------
		
	declare @Sal_Param as nvarchar(max)
				 
	  
	declare curPreSalar cursor for                    
		SELECT part from dbo.SplitString2(@Salary_Parameter,'$')
	open curPreSalar                      
	fetch next from curPreSalar into @Sal_Param
	WHILE @@fetch_status = 0                    
		BEGIN
			  
			if @is_Manual = 1
				begin
					insert into #Pre_Salary_Data 
					SELECT  'Manual' as Cnt , [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24] 
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
			
					insert into #Pre_Salary_Data_monthly 
					SELECT  'Monthly' as Cnt , [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25]
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
		 
--------------------------------------------------------------------------------------------------
		
	--Declare @cur_Type as nvarchar(50)
	--Declare @cur_M_Sal_Tran_ID  as nvarchar(50) 
	--Declare @cur_Emp_Id   as  Numeric      
	--Declare @cur_Cmp_ID  as   Numeric      
	--Declare @cur_Sal_Generate_Date as  nvarchar(50) 
	--Declare @cur_Month_St_Date  as  nvarchar(50)
	--Declare @cur_Month_End_Date as  nvarchar(50)
	--Declare @cur_Present_Days  as  Numeric(18,2)      
	--Declare @cur_M_OT_Hours  as  Numeric(18,2)      
	--Declare @cur_Areas_Amount  as  Numeric(18,2)       
	--Declare @cur_M_IT_Tax   as  NUMERIC(18,2)      
	--Declare @cur_Other_Dedu  as  numeric(18,2)      
	--Declare @cur_M_LOAN_AMOUNT  as  NUMERIC      
	--Declare @cur_M_ADV_AMOUNT  as  NUMERIC      
	--Declare @cur_IS_LOAN_DEDU  as  NUMERIC      
	--Declare @cur_Login_ID   as  Numeric    
	--Declare @cur_ErrRaise  as   Varchar(100) 
	--Declare @cur_Is_Negetive  as  Varchar(1)  
	--Declare @cur_Status  as   varchar(10)  
	--Declare @cur_IT_M_ED_Cess_Amount  as numeric(18,2)
	--Declare @cur_IT_M_Surcharge_Amount  as numeric(18,2)
	--Declare @cur_Allo_On_Leave as  numeric(18,0) 
	--Declare @cur_User_Id  as numeric(18,0) 	
	--Declare @cur_IP_Address  as varchar(30)	   

	--declare @cur_Sal_Generate_Date_temp as datetime
	--declare @cur_Sal_Generate_Date_temp1 as datetime
	--declare @cur_Sal_Generate_Date_temp2 as datetime
	
	If (@BackEnd_Salary = 0)
		BEGIN
			Delete From t0200_Pre_Salary_Data Where is_processed=0 
			Delete From t0200_Pre_Salary_Data_Monthly Where is_processed=0 
		END
		
		
	if @is_Manual = 1
		begin
			INSERT INTO t0200_Pre_Salary_Data  ( Type, M_Sal_Tran_ID, Emp_Id, Cmp_ID, Sal_Generate_Date, Month_St_Date, Month_End_Date, Present_Days, M_OT_Hours, Areas_Amount, M_IT_Tax, 
							  Other_Dedu, M_LOAN_AMOUNT, M_ADV_AMOUNT, IS_LOAN_DEDU, Login_ID, ErrRaise, Is_Negetive, Status, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount, 
							  Allo_On_Leave, User_Id, IP_Address,batch_id , IS_Bond_DEDU) 
			 SELECT   Type, M_Sal_Tran_ID, Emp_Id, Cmp_ID, Cast(Sal_Generate_Date as DateTime), convert(datetime,Month_St_Date ,103) , convert(datetime,Month_End_Date ,103), Present_Days, M_OT_Hours, Areas_Amount, M_IT_Tax, Other_Dedu, 
							  M_LOAN_AMOUNT, M_ADV_AMOUNT, IS_LOAN_DEDU, Login_ID, ErrRaise, Is_Negetive, Status, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount, Allo_On_Leave, 
							  User_Id, IP_Address ,@ID,IS_Bond_DEDU
			FROM  #Pre_Salary_Data 

			
			
		end
	else 
		begin

			INSERT INTO t0200_Pre_Salary_Data_Monthly  (Type, M_Sal_Tran_ID, Emp_Id, Cmp_ID, Sal_Generate_Date, Month_St_Date, Month_End_Date, M_OT_Hours, Areas_Amount, M_IT_Tax, Other_Dedu, 
                      M_LOAN_AMOUNT, M_ADV_AMOUNT, IS_LOAN_DEDU, Login_ID, ErrRaise, Is_Negetive, Status, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount, Allo_On_Leave, 
                      W_OT_Hours, H_OT_Hours, User_Id, IP_Address,batch_id, IS_Bond_DEDU) 
			SELECT   Type, M_Sal_Tran_ID, Emp_Id, Cmp_ID,  Cast(Sal_Generate_Date as DateTime), convert(datetime,Month_St_Date ,103),  convert(datetime,Month_End_Date ,103), M_OT_Hours, Areas_Amount, M_IT_Tax, Other_Dedu, 
                      M_LOAN_AMOUNT, M_ADV_AMOUNT, IS_LOAN_DEDU, Login_ID, ErrRaise, Is_Negetive, Status, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount, Allo_On_Leave, 
                      W_OT_Hours, H_OT_Hours, User_Id, IP_Address,@ID,IS_Bond_DEDU
			FROM  #Pre_Salary_Data_monthly 
			
		end
	
	
		
	--declare curExecSalar cursor for                    
	--	select * from #Pre_Salary_Data	
	--open curExecSalar                      
	--fetch next from curExecSalar into @cur_Type,	@cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID , @cur_Sal_Generate_Date, @cur_Month_St_Date, @cur_Month_End_Date,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   
	--WHILE @@fetch_status = 0                    
	--	BEGIN
	--		set @cur_Sal_Generate_Date_temp =  convert(datetime,@cur_Sal_Generate_Date ,103)
	--		set @cur_Sal_Generate_Date_temp1 =  convert(datetime,@cur_Month_St_Date ,103)
	--		set @cur_Sal_Generate_Date_temp2 =  convert(datetime,@cur_Month_End_Date ,103)
	--		--print @cur_Sal_Generate_Date
			
	--		--set @cur_Sal_Generate_Date_temp = cast(@cur_Sal_Generate_Date as DATETIME)
			
	--		--print @cur_Sal_Generate_Date_temp
	--		----print @cur_Emp_Id
			 
	--		exec P0200_MONTHLY_SALARY_GENERATE_MANUAL @cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID ,  @cur_Sal_Generate_Date_temp , @cur_Sal_Generate_Date_temp1, @cur_Sal_Generate_Date_temp2,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   
			 
	--		fetch next from curExecSalar into @cur_Type,	@cur_M_Sal_Tran_ID  , @cur_Emp_Id , @cur_Cmp_ID , @cur_Sal_Generate_Date, @cur_Month_St_Date, @cur_Month_End_Date,  @cur_Present_Days , @cur_M_OT_Hours ,  @cur_Areas_Amount ,  @cur_M_IT_Tax ,  @cur_Other_Dedu  , @cur_M_LOAN_AMOUNT ,  @cur_M_ADV_AMOUNT,  @cur_IS_LOAN_DEDU  ,  @cur_Login_ID  ,  @cur_ErrRaise,  @cur_Is_Negetive  ,  @cur_Status ,  @cur_IT_M_ED_Cess_Amount ,  @cur_IT_M_Surcharge_Amount ,  @cur_Allo_On_Leave,  @cur_User_Id , @cur_IP_Address   
	--	END
	--close curExecSalar        
	--Deallocate curExecSalar  
	
	
	
	--Select * from #Pre_Salary_Data
	--Select * from #Pre_Salary_Data_monthly
	--Select @BackEnd_Salary
	--return
		

	drop TABLE #Pre_Salary_Data	
	drop TABLE #Pre_Salary_Data_monthly	 
	
	Update T0211_Salary_Processing_Status SET SPID=@@SPID 


	if @BackEnd_Salary = 0
		begin	
		
			exec P0200_Generate_Offline_Salary_New @cmp_id ,@from_date,@to_date,@is_Manual,0,0,0,0,0,0,0,0,'',0,0,0,0,@ID
		end
END

