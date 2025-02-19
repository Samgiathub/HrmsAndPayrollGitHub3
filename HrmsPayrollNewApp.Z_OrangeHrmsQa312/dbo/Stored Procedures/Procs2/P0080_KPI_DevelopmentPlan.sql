
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_KPI_DevelopmentPlan]
	 ---details of main table
	   @KPIPMS_ID				numeric(18,0) 	output
	  ,@Cmp_Id					numeric(18,0)
	  ,@Emp_ID					numeric(18,0)
	  ,@KPIPMS_Type				int
	  ,@KPIPMS_Name				varchar(50)
	  ,@KPIPMS_FinancialYr		numeric(18,0)=null
	  ,@KPIPMS_Status			int=null
	  ,@KPIPMS_EmpEarlyComment	varchar(500)=null
	  ,@KPIPMS_SupEarlyComment	varchar(500)=null
	  ,@KPIPMS_AdditionalAchievement varchar(500) --added on 4 apr 2015
	  ---details of KPI Development Plan
	  ,@KPI_DevelopmentID	numeric(18,0) 
      ,@Strengths			varchar(200)
      ,@DevelopmentAreas	varchar(200)
      ,@ImprovementAction	varchar(200)
      ,@Timeline			varchar(200)
      ,@Status				varchar(200)
      ,@tran_type			varchar(1) 
	  ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		Begin
			if Not exists(select 1 from T0080_KPIPMS_EVAL WITH (NOLOCK) where kpiPMS_Id = @KPIPMS_ID)
				begin
					exec P0080_KPIPMS_EVAL @KPIPMS_ID OUTPUT,@Cmp_Id,@Emp_ID,@KPIPMS_Type,@KPIPMS_Name,@KPIPMS_FinancialYr,@KPIPMS_Status,null,null,null,null,null,null,null,@KPIPMS_EmpEarlyComment,@KPIPMS_SupEarlyComment,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,0,@KPIPMS_AdditionalAchievement,@tran_type,@User_Id,@IP_Address
				End
		
			select @KPI_DevelopmentID = isnull(max(KPI_DevelopmentID),0) + 1 from T0080_KPI_DevelopmentPlan WITH (NOLOCK)
			Insert Into T0080_KPI_DevelopmentPlan
			(
				   KPI_DevelopmentID
				  ,Cmp_Id	
				  ,Emp_ID	
				  ,KPIPMS_ID
				  ,Strengths				
				  ,DevelopmentAreas		
				  ,ImprovementAction		
				  ,Timeline				
				  ,[Status]					
			)
			Values
			(
				   @KPI_DevelopmentID
				  ,@Cmp_Id		
				  ,@Emp_ID	
				  ,@KPIPMS_ID			
				  ,@Strengths			
				  ,@DevelopmentAreas	
				  ,@ImprovementAction	
				  ,@Timeline			
				  ,@Status				
			)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0080_KPI_DevelopmentPlan
			SET		  KPIPMS_ID	= @KPIPMS_ID
					 ,Strengths	= @Strengths			
					 ,DevelopmentAreas	= @DevelopmentAreas		
					 ,ImprovementAction	= @ImprovementAction	
					 ,Timeline			= @Timeline				
					 ,Status			= @Status 
			Where	  KPI_DevelopmentID	= @KPI_DevelopmentID  and Emp_ID=@Emp_ID
		End
	Else if Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0080_KPI_DevelopmentPlan WHERE  KPI_DevelopmentID = @KPI_DevelopmentID 
		End
END
