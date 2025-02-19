


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0080_KPIPMS_EVAL]
	 @KPIPMS_ID					numeric(18,0) Output
	,@Cmp_ID					numeric(18,0)
	,@Emp_ID					numeric(18,0)
	,@KPIPMS_Type				int
	,@KPIPMS_Name				varchar(50)
	,@KPIPMS_FinancialYr		numeric(18,0)=null
	,@KPIPMS_Status				int=null
	,@KPIPMS_FinalRating		numeric(18,0)=null
	,@KPIPMS_EmProcessFair		int=null
	,@KPIPMS_EmpAgree			int=null
	,@KPIPMS_EmpComments		varchar(500)=null
	,@KPIPMS_ProcessFairSup		int=null
	,@KPIPMS_SupAgree			int=null
	,@KPIPMS_SupComments		varchar(500)=null
	--
	,@KPIPMS_EmpEarlyComment	varchar(500)=null
	,@KPIPMS_SupEarlyComment	varchar(500)=null
	,@KPIPMS_EarlyComment		varchar(500)=null
	,@KPIMPS_StartedOn			datetime=null
	,@KPIMPS_EmpAppOn			datetime=null
	,@KPIMPS_SupAppOn			datetime=null
	,@KPIPMS_FinalApproved		datetime=null
	,@Final_Training			varchar(max) =null  --added on Oct 13 2014
	,@Final_Training_Emp        varchar(max) =null  --added on Mar 13 2015
	--
	,@Final_Score				numeric(18,2)=null
	,@SignOff_EmpDate		    datetime=null
	,@SignOff_SupDate			datetime=null
	,@Final_Close				int=null
	,@Final_ClosedOn			datetime=null
	,@Final_ClosedBy			numeric(18,0)=null
	,@Final_ClosingComment		varchar(500)=null
	,@KPIPMS_ManagerScore		NUMERIC(18,2)		--added on Mar 19 2015
	,@KPIPMS_EmpScore			Numeric(18,2)       --added on mar 19 2015
	,@KPIPMS_AdditionalAchivement varchar(1000) = null --added on 4 Apr 2015      
	,@tran_type					varchar(1) 
    ,@User_Id					numeric(18,0) = 0
	,@IP_Address				varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If Upper(@tran_type) ='I'
		Begin
			if NOT exists(select 1 from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_ID=@Emp_ID and KPIPMS_Type=@KPIPMS_Type and KPIPMS_Name=@KPIPMS_Name and KPIPMS_FinancialYr=@KPIPMS_FinancialYr)
			begin
				select @KPIPMS_ID = isnull(max(KPIPMS_ID),0) + 1 from T0080_KPIPMS_EVAL WITH (NOLOCK)
				Insert Into T0080_KPIPMS_EVAL
			   (
				 KPIPMS_ID					
				,Cmp_ID					
				,Emp_ID					
				,KPIPMS_Type				
				,KPIPMS_Name				
				,KPIPMS_FinancialYr		
				,KPIPMS_Status				
				,KPIPMS_FinalRating		
				,KPIPMS_EmProcessFair		
				,KPIPMS_EmpAgree			
				,KPIPMS_EmpComments		
				,KPIPMS_ProcessFairSup		
				,KPIPMS_SupAgree			
				,KPIPMS_SupComments	
				,KPIPMS_EmpEarlyComment	
				,KPIPMS_SupEarlyComment	
				,KPIPMS_EarlyComment
				,KPIMPS_StartedOn	
				,KPIMPS_EmpAppOn	
				,KPIMPS_SupAppOn
				,KPIPMS_FinalApproved
				,Final_Score					
				,SignOff_EmpDate				
				,SignOff_SupDate				
				,Final_Close					
				,Final_ClosedOn				
				,Final_ClosedBy				
				,Final_ClosingComment	
				,Final_Training		
				,Final_Training_Emp   -- 13 Mar 2015
				,KPIPMS_ManagerScore	-- 19 Mar 2015
				,KPIPMS_EmpScore		-- 19 Mar 2015
				,KPIPMS_AdditionalAchivement	--4 Apr 2015
			)
			values
			(
				 @KPIPMS_ID					
				,@Cmp_ID					
				,@Emp_ID					
				,@KPIPMS_Type				
				,@KPIPMS_Name				
				,@KPIPMS_FinancialYr		
				,@KPIPMS_Status				
				,@KPIPMS_FinalRating		
				,@KPIPMS_EmProcessFair		
				,@KPIPMS_EmpAgree			
				,@KPIPMS_EmpComments		
				,@KPIPMS_ProcessFairSup		
				,@KPIPMS_SupAgree			
				,@KPIPMS_SupComments
				,@KPIPMS_EmpEarlyComment	
				,@KPIPMS_SupEarlyComment	
				,@KPIPMS_EarlyComment	
				,GETDATE()
				,case when @KPIMPS_EmpAppOn = '1753-01-01' then null else @KPIMPS_EmpAppOn end  
				,case when @KPIMPS_SupAppOn = '1753-01-01' then null else @KPIMPS_SupAppOn end 
				,case when @KPIPMS_FinalApproved = '1753-01-01' then null else @KPIPMS_FinalApproved end
				,@Final_Score					
				,case when @SignOff_EmpDate = '1753-01-01' then null else @SignOff_EmpDate end		
				,case when @SignOff_SupDate = '1753-01-01' then null else @SignOff_SupDate end				
				,@Final_Close					
				,case when @Final_ClosedOn = '1753-01-01' then null else @Final_ClosedOn end 				
				,@Final_ClosedBy				
				,@Final_ClosingComment
				,@Final_Training	
				,@Final_Training_Emp  --13 Mar 2015
				,@KPIPMS_ManagerScore	-- 19 Mar 2015
				,@KPIPMS_EmpScore		-- 19 Mar 2015
				,@KPIPMS_AdditionalAchivement	--4 apr 2015
			)
			End
		else
			begin 
				select @KPIPMS_ID=KPIPMS_ID from T0080_KPIPMS_EVAL WITH (NOLOCK) where Emp_ID=@Emp_ID and KPIPMS_Type=@KPIPMS_Type and KPIPMS_Name=@KPIPMS_Name and KPIPMS_FinancialYr=@KPIPMS_FinancialYr
				select @KPIPMS_ID
			ENd
		END
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0080_KPIPMS_EVAL		
			Set		  KPIPMS_Type			=@KPIPMS_Type		
					 ,KPIPMS_Name			=@KPIPMS_Name
					 ,KPIPMS_FinancialYr	=@KPIPMS_FinancialYr
					 ,KPIPMS_Status			=@KPIPMS_Status
					 ,KPIPMS_FinalRating	=@KPIPMS_FinalRating
					 ,KPIPMS_EmProcessFair	=@KPIPMS_EmProcessFair
					 ,KPIPMS_EmpAgree		=@KPIPMS_EmpAgree
					 ,KPIPMS_EmpComments	=@KPIPMS_EmpComments
					 ,KPIPMS_ProcessFairSup	=@KPIPMS_ProcessFairSup
					 ,KPIPMS_SupAgree		=@KPIPMS_SupAgree
					 ,KPIPMS_SupComments	=@KPIPMS_SupComments
					 ,KPIPMS_EmpEarlyComment=@KPIPMS_EmpEarlyComment
					 ,KPIPMS_SupEarlyComment=@KPIPMS_SupEarlyComment	
					 ,KPIPMS_EarlyComment	=@KPIPMS_EarlyComment
					 ,KPIMPS_EmpAppOn		=case when @KPIMPS_EmpAppOn = '1753-01-01' then null else @KPIMPS_EmpAppOn end  
					 ,KPIMPS_SupAppOn		=case when @KPIMPS_SupAppOn = '1753-01-01' then null else @KPIMPS_SupAppOn end  
					 ,KPIPMS_FinalApproved	= case when @KPIMPS_SupAppOn = '1753-01-01' then null else @KPIPMS_FinalApproved end 
					 ,Final_Score			=@Final_Score			
					 ,SignOff_EmpDate		=@SignOff_EmpDate
					 ,SignOff_SupDate		=@SignOff_SupDate
					 ,Final_Close			=@Final_Close
					 ,Final_ClosedOn		=case when @Final_ClosedOn = '1753-01-01' then null else @Final_ClosedOn end  
					 ,Final_ClosedBy		=@Final_ClosedBy
					 ,Final_ClosingComment	=@Final_ClosingComment 
					 ,Final_Training		=@Final_Training
					 ,Final_Training_Emp	=@Final_Training_Emp  --13 Mar 2015
					 ,KPIPMS_ManagerScore	=@KPIPMS_ManagerScore  -- 19 mar 2015
					 ,KPIPMS_EmpScore		=@KPIPMS_EmpScore	   -- 19 Mar 2015	
					 ,KPIPMS_AdditionalAchivement =@KPIPMS_AdditionalAchivement  --4 Apr 2015
			Where    KPIPMS_ID = @KPIPMS_ID  and Emp_ID=@Emp_ID
		End
	Else if Upper(@tran_type) ='D'
		Begin
		
			--added on 26 mar 2015 sneha
			declare @tranlevl as numeric(18,0)
			
			declare cur cursor
				for 
					select  Tran_Id from T0090_KPIPMS_EVAL_Approval WITH (NOLOCK) where kpipms_Id = @KPIPMS_ID
				open cur
					fetch next from cur into @tranlevl
					WHILE @@FETCH_STATUS = 0
					begin 
						DELETE FROM T0100_KPIPMS_Objective_Level WHERE TRAN_ID = @tranlevl	
						delete from T0100_KPI_DevelopmentPlan_Level  where Tran_Id = @tranlevl
								
						fetch next from cur into @tranlevl		
					End
					close cur
	
					open cur
					fetch next from cur into @tranlevl
					WHILE @@FETCH_STATUS = 0
					begin  
						delete from T0100_KPIRating_Level  where Tran_Id = @tranlevl							
						fetch next from cur into @tranlevl		
					End
					close cur
	
					open cur
					fetch next from cur into @tranlevl					
				close cur
				deallocate cur	
				
			
			delete from T0090_KPIPMS_EVAL_Approval where KPIPMS_ID=@KPIPMS_ID--end
		
			DELETE FROM T0090_KPIPMS_Objective WHERE KPIPMS_ID = @KPIPMS_ID
			DELETE FROM T0080_KPIRating WHERE  KPIPMS_ID = @KPIPMS_ID 
			Delete from T0080_KPI_DevelopmentPlan where KPIPMS_ID = @KPIPMS_ID
			DELETE FROM T0080_KPIPMS_EVAL WHERE  KPIPMS_ID = @KPIPMS_ID --and  emp_id=@Emp_ID
		End
END


