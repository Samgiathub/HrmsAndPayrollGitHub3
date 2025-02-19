



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_AR_ApprovalDetail]
	@AR_App_ID              numeric(18, 0),
	@AR_Apr_ID				numeric(18, 0),
	@Cmp_ID					numeric(18, 0),
	@Emp_ID					numeric(18,0),
	@Increment_ID			numeric(18,0),
	@For_Date			    DateTime, 		
	@AR_ApprovalDetail		XML ,
	@Tran_Type				CHAR(1),
	@UserID					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @AR_AprDetaill_ID numeric(18,0)

Declare @AD_ID numeric(18, 0)
Declare @AD_Flag char(10)
Declare @AD_Mode nvarchar(50)
Declare @AD_Percentage numeric(18, 2)
Declare @AD_Amount numeric(18, 2)
Declare @E_AD_Max_Limit numeric(18, 2)
Declare @Comments nvarchar(4000)
Declare @trantype char(1)

	IF @Tran_Type  = 'I'     
	BEGIN	
			
			IF OBJECT_ID('tempdb..#temp_Table_U') IS NOT NULL
				BEGIN
					DROP TABLE #temp_Table
				END
			
			CREATE TABLE #TB_AR_ApplicationDetail_U
			(
				AD_ID numeric(18, 0),
				AD_Flag char(10),
				AD_MODE nvarchar(50),
				AD_PERCENTAGE numeric(18, 2),
				AD_Amount numeric(18, 2),
				E_AD_Max_Limit numeric(18, 2),
				Comments nvarchar(4000),
				trantype char(1),
			)
			
			select TB_AR_ApplicationDetail_U.detail.value('(AD_ID/text())[1]','numeric(18,0)') as AD_ID, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_Flag/text())[1]','char(10)') as AD_Flag,
				   TB_AR_ApplicationDetail_U.detail.value('(AD_MODE/text())[1]','nvarchar(50)') as AD_MODE, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_PERCENTAGE/text())[1]','numeric(18,2)') as AD_PERCENTAGE, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_Amount/text())[1]','numeric(18,2)') as AD_Amount, 
				   TB_AR_ApplicationDetail_U.detail.value('(E_AD_Max_Limit/text())[1]','numeric(18,2)') as E_AD_Max_Limit, 
				   TB_AR_ApplicationDetail_U.detail.value('(Comments/text())[1]','nvarchar(4000)') as Comments,
				   TB_AR_ApplicationDetail_U.detail.value('(trantype/text())[1]','char(1)') as trantype
				into #temp_Table_U from @AR_ApprovalDetail.nodes('/NewDataSet/Table1') as TB_AR_ApplicationDetail_U(detail)
		
		Declare curAR cursor for                      
		  select  AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_Amount,E_AD_Max_Limit,Comments,trantype from #temp_Table_U                  
		open curAR                        
		 fetch next from curAR into @AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@trantype
		 while @@fetch_status = 0                      
		  begin
				 -- IF EXISTS(SELECT 1 FROM T0130_AR_Approval_Detail WHERE Cmp_ID=@CMP_id AND eMP_id=@EMP_id AND ad_id=@AD_id AND For_Date=@fOR_dATE)
					--BEGIN
					--	Raiserror('Data are already Exists',16,2)
					--	 return -1
					--END
				  
				  SELECT @AR_AprDetaill_ID = isnull(max(AR_AprDetaill_ID),0)+1 from T0130_AR_Approval_Detail WITH (NOLOCK)					 					
				  if @AR_App_ID = 0
					  Begin
							INSERT INTO T0130_AR_Approval_Detail
							(AR_AprDetaill_ID,AR_Apr_ID,Cmp_ID,Emp_ID,Increment_ID,For_Date,AD_ID,
							 AD_Flag,AD_Mode,AD_Percentage,AD_Amount,E_AD_Max_Limit,Comments,CreatedBy,DateCreated)
							values
							(@AR_AprDetaill_ID,@AR_Apr_ID,@Cmp_ID,@Emp_ID,@INcrement_ID,@For_Date,@AD_ID,
							 @AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@UserID,getdate())
					  End
				  Else
					  Begin
							INSERT INTO T0130_AR_Approval_Detail
							(AR_AprDetaill_ID,AR_App_ID,AR_Apr_ID,Cmp_ID,Emp_ID,Increment_ID,For_Date,AD_ID,
							 AD_Flag,AD_Mode,AD_Percentage,AD_Amount,E_AD_Max_Limit,Comments,CreatedBy,DateCreated)
							values
							(@AR_AprDetaill_ID,@AR_App_ID,@AR_Apr_ID,@Cmp_ID,@Emp_ID,@INcrement_ID,@For_Date,@AD_ID,
							 @AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@UserID,getdate())
					  End
			
			fetch next from curAR into @AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@trantype
		  end                      
		 close curAR                      
		 deallocate curAR 
	End
END




