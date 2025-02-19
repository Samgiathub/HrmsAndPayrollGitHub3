



-- =============================================
-- Author:		Ripal Patel
-- Create date: 05 Jun 2014
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_AR_ApplicationDetail]
	@AR_AppDetail_ID		numeric(18, 0),
	@AR_App_ID				numeric(18, 0),
	@Cmp_ID					numeric(18, 0),
	@AR_ApplicationDetail   XML ,
	@User_ID				NUMERIC(18,0),
	@Tran_Type				CHAR(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


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
	
			IF OBJECT_ID('tempdb..#temp_Table') IS NOT NULL
				BEGIN
					DROP TABLE #temp_Table
				END
			
			CREATE TABLE #TB_AR_ApplicationDetail
			(
				AD_ID numeric(18, 0),
				AD_Flag char(10),
				AD_MODE nvarchar(50),
				AD_PERCENTAGE numeric(18, 2),
				AD_Amount numeric(18, 2),
				E_AD_Max_Limit numeric(18, 2),
				Comments nvarchar(4000),
			)
			
			select TB_AR_ApplicationDetail.detail.value('(AD_ID/text())[1]','numeric(18,0)') as AD_ID, 
				   TB_AR_ApplicationDetail.detail.value('(AD_Flag/text())[1]','char(10)') as AD_Flag,
				   TB_AR_ApplicationDetail.detail.value('(AD_MODE/text())[1]','nvarchar(50)') as AD_MODE, 
				   TB_AR_ApplicationDetail.detail.value('(AD_PERCENTAGE/text())[1]','numeric(18,2)') as AD_PERCENTAGE, 
				   TB_AR_ApplicationDetail.detail.value('(AD_Amount/text())[1]','numeric(18,2)') as AD_Amount, 
				   TB_AR_ApplicationDetail.detail.value('(E_AD_Max_Limit/text())[1]','numeric(18,2)') as E_AD_Max_Limit, 
				   TB_AR_ApplicationDetail.detail.value('(Comments/text())[1]','nvarchar(4000)') as Comments
				into #temp_Table from @AR_ApplicationDetail.nodes('/NewDataSet/Table1') as TB_AR_ApplicationDetail(detail)
		
		
		Declare curAR cursor for                      
		  select  AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_Amount,E_AD_Max_Limit,Comments from #temp_Table                  
		open curAR                        
		 fetch next from curAR into @AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments
		 while @@fetch_status = 0                      
		  begin
		     SELECT @AR_AppDetail_ID = isnull(max(AR_AppDetail_ID),0)+1 from T0100_AR_ApplicationDetail WITH (NOLOCK)
		     
			 INSERT INTO T0100_AR_ApplicationDetail
						   (AR_AppDetail_ID,AR_App_ID,Cmp_ID,AD_ID,AD_Flag,AD_Mode,AD_Percentage
						   ,AD_Amount,E_AD_Max_Limit,Comments,CreatedBy,DateCreated)
					 VALUES
						   (@AR_AppDetail_ID,@AR_App_ID,@Cmp_ID,@AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage
						   ,@AD_Amount,@E_AD_Max_Limit,@Comments,@User_ID,GetDate())
          
			fetch next from curAR into @AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments
		  end                      
		 close curAR                      
		 deallocate curAR 
	End
	else IF @Tran_Type  = 'U'     
	BEGIN	
			
			IF OBJECT_ID('tempdb..#temp_Table_U') IS NOT NULL
				BEGIN
					DROP TABLE #temp_Table
				END
			
			CREATE TABLE #TB_AR_ApplicationDetail_U
			(
				AR_AppDetail_ID numeric(18,0),
				AD_ID numeric(18, 0),
				AD_Flag char(10),
				AD_MODE nvarchar(50),
				AD_PERCENTAGE numeric(18, 2),
				AD_Amount numeric(18, 2),
				E_AD_Max_Limit numeric(18, 2),
				Comments nvarchar(4000),
				trantype char(1),
			)
			
			select TB_AR_ApplicationDetail_U.detail.value('(AR_AppDetail_ID/text())[1]','numeric(18,0)') as AR_AppDetail_ID, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_ID/text())[1]','numeric(18,0)') as AD_ID, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_Flag/text())[1]','char(10)') as AD_Flag,
				   TB_AR_ApplicationDetail_U.detail.value('(AD_MODE/text())[1]','nvarchar(50)') as AD_MODE, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_PERCENTAGE/text())[1]','numeric(18,2)') as AD_PERCENTAGE, 
				   TB_AR_ApplicationDetail_U.detail.value('(AD_Amount/text())[1]','numeric(18,2)') as AD_Amount, 
				   TB_AR_ApplicationDetail_U.detail.value('(E_AD_Max_Limit/text())[1]','numeric(18,2)') as E_AD_Max_Limit, 
				   TB_AR_ApplicationDetail_U.detail.value('(Comments/text())[1]','nvarchar(4000)') as Comments,
				   TB_AR_ApplicationDetail_U.detail.value('(trantype/text())[1]','char(1)') as trantype
				into #temp_Table_U from @AR_ApplicationDetail.nodes('/NewDataSet/Table1') as TB_AR_ApplicationDetail_U(detail)
		
		Declare curAR cursor for                      
		  select  AR_AppDetail_ID,AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_Amount,E_AD_Max_Limit,Comments,trantype from #temp_Table_U                  
		open curAR                        
		 fetch next from curAR into @AR_AppDetail_ID,@AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@trantype
		 while @@fetch_status = 0                      
		  begin
		    
		     if @trantype = 'I'
				 Begin
					SELECT @AR_AppDetail_ID = isnull(max(AR_AppDetail_ID),0)+1 from T0100_AR_ApplicationDetail WITH (NOLOCK)
					INSERT INTO T0100_AR_ApplicationDetail
						   (AR_AppDetail_ID,AR_App_ID,Cmp_ID,AD_ID,AD_Flag,AD_Mode,AD_Percentage
						   ,AD_Amount,E_AD_Max_Limit,Comments,CreatedBy,DateCreated)
					 VALUES
						   (@AR_AppDetail_ID,@AR_App_ID,@Cmp_ID,@AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage
						   ,@AD_Amount,@E_AD_Max_Limit,@Comments,@User_ID,GetDate())
				 end
		     else if @trantype = 'U'
				 Begin
						UPDATE T0100_AR_ApplicationDetail
						   SET AD_Percentage = @AD_Percentage
							  ,AD_Amount = @AD_Amount
							  ,Comments = @Comments
							  ,Modifiedby = @User_ID
							  ,DateModified = GetDate()
						 WHERE AR_AppDetail_ID = @AR_AppDetail_ID
				 End
		     else if @trantype = 'D'
				Begin
					Delete from T0100_AR_ApplicationDetail WHERE AR_AppDetail_ID = @AR_AppDetail_ID
				End
          
			fetch next from curAR into @AR_AppDetail_ID,@AD_ID,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@E_AD_Max_Limit,@Comments,@trantype
		  end                      
		 close curAR                      
		 deallocate curAR 
	End
END


