

---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Bind_Abstract_details] 
	@Cmp_ID Numeric,
	@Search_Text Varchar(50) = NULL
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	IF OBJECT_ID('tempdb..#Temp_Allow_Name') IS NOT NULL
		DROP TABLE #Temp_Allow_Name
	
     Create Table #Temp_Allow_Name
     (
		Trans_ID Numeric,
		Cmp_ID Numeric,
		Earning_Name Varchar(max)
     )
     
     Declare @TransID As Numeric(18,0)
     Declare @CmpID As Numeric(18,0)
     Declare @Earning_Name As Varchar(Max)
     Declare @Deduction_Name As Varchar(Max)
     Declare @Loan_Name As Varchar(max)
     
     Set @TransID = 0
     Set @CmpID = 0
     
     
     Declare Cur_Allow_Name Cursor For Select Trans_ID,Cmp_ID,Earning_Component_ID,Deduction_Component_ID,Loan_ID From T0100_Abstract_Report_Details WITH (NOLOCK)
     open Cur_Allow_Name
		Fetch Next From Cur_Allow_Name Into @TransID,@CmpID,@Earning_Name,@Deduction_Name,@Loan_Name
		 while @@fetch_status = 0
			Begin
			   
			    declare @strsql nvarchar(max)
			    
			    set @strsql = 'declare @str varchar(max);'
			    set @strsql = @strsql + 'select @str = coalesce(@str + '','','''') + T.AD_NAME FROM (SELECT isnull(CASE WHEN 8000 IN (' + REPLACE(isnull(@Earning_Name,0),'#',',') +') THEN ''Basic'' End,'''') as AD_Name Union All Select Distinct AD_NAME From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = ' + Cast(@CmpID AS varchar(50)) + ' and AD_FLAG = ''I'' And AD_ID IN (' + REPLACE(isnull(@Earning_Name,0),'#',',') +') union ALL SELECT isnull(CASE WHEN 9000 IN (' + REPLACE(isnull(@Deduction_Name,0),'#',',') +') THEN ''Prof.Tax'' End,'''') as AD_Name union ALL Select Distinct AD_NAME From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = ' + Cast(@CmpID AS varchar(50)) + ' and AD_FLAG = ''D'' And AD_ID IN (' + REPLACE(isnull(@Deduction_Name,0),'#',',') +') Union all Select Distinct Loan_Name as AD_NAME From T0040_LOAN_MASTER WITH (NOLOCK) Where CMP_ID = ' + Cast(@CmpID AS varchar(50)) + ' And Loan_ID IN (' + REPLACE(isnull(@Loan_Name,0),'#',',') +')) T;'
				set @strsql = @strsql + 'insert into #Temp_Allow_Name(Trans_ID,Cmp_ID,Earning_Name) Select '+ Cast(@TransID AS varchar(10)) +','+ Cast(@CmpID AS varchar(10))  +', @str;'
				
				Print @strsql
				exec(@strsql);
				
				Fetch Next From Cur_Allow_Name Into @TransID,@CmpID,@Earning_Name,@Deduction_Name,@Loan_Name
			End
	 Close Cur_Allow_Name 
	 deallocate Cur_Allow_Name
	 
	 if @Search_Text Is Null
		Begin
			Select T.Trans_ID as App_Code, M.Report_Header_Name,(CASE WHEN T.Employee_Type = 24 THEN 'Regular' WHEN T.Employee_Type = 23 THEN 'Deputation' END) as Employee_Type,
			Replace(Temp.Earning_Name,',,','') as Earning_Name,
			(CASE WHEN T.Abstract_Report_ID = 1 THEN 'Cash Voucher Report' WHEN T.Abstract_Report_ID = 2 THEN 'Journal Voucher Report' WHEN T.Abstract_Report_ID = 3 THEN 'Monthly Report' WHEN T.Abstract_Report_ID = 4 THEN 'Paybill Report' WHEN T.Abstract_Report_ID = 5 THEN 'Consolidate Report' End) as Abstract_Report_ID,
			(CASE WHEN T.Typeid = 1 THEN 'Earning' WHEN T.Typeid = 2 THEN 'Deduction' END) as Typeid
			From #Temp_Allow_Name Temp Inner JOIN T0100_Abstract_Report_Details T WITH (NOLOCK) ON Temp.Trans_ID = T.Trans_ID
			inner join T0030_Report_Header_Master M WITH (NOLOCK) on M.Report_Id = T.Report_ID 
			where T.Cmp_ID = @Cmp_ID
		End
	Else
		Begin
		
			Select T.Trans_ID as App_Code, M.Report_Header_Name,(CASE WHEN T.Employee_Type = 24 THEN 'Regular' WHEN T.Employee_Type = 23 THEN 'Deputation' END) as Employee_Type,
			Replace(Temp.Earning_Name,',,','') as Earning_Name,
			(CASE WHEN T.Abstract_Report_ID = 1 THEN 'Cash Voucher Report' WHEN T.Abstract_Report_ID = 2 THEN 'Journal Voucher Report' WHEN T.Abstract_Report_ID = 3 THEN 'Monthly Report' WHEN T.Abstract_Report_ID = 4 THEN 'Paybill Report' WHEN T.Abstract_Report_ID = 5 THEN 'Consolidate Report' End) as Abstract_Report_ID,
			(CASE WHEN T.Typeid = 1 THEN 'Earning' WHEN T.Typeid = 2 THEN 'Deduction' END) as Typeid
			From #Temp_Allow_Name Temp Inner JOIN T0100_Abstract_Report_Details T WITH (NOLOCK) ON Temp.Trans_ID = T.Trans_ID
			inner join T0030_Report_Header_Master M WITH (NOLOCK) on M.Report_Id = T.Report_ID 
			where T.Cmp_ID = @Cmp_ID and M.Report_Header_Name LIKE '%'+ @Search_Text +'%'
		End 
	 
	  
		 
END

