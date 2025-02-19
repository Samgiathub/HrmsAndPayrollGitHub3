
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_KPIRating]
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
	  ,@KPIPMS_FinalRating	    numeric(18,0)=null --added on 20 aug 2014
	  ---details of KPI Rating
	  ,@KPI_RatingID		numeric(18,0) 
      ,@SubKPIId			numeric(18,0)
      ,@Metric				varchar(500)
      ,@Rating				numeric(18,0)
      ,@AchievedWeight		numeric(18,2) = null --added on 20 aug 2014
      ,@Rating_Manager		numeric(18,0) = null --added on 19 Mar 2015
      ,@Rating_Employee		numeric(18,0) = null --added on 19 Mar 2015
      ,@Metric_Manager		varchar(500) = null --added on 19 Mar 2015
      ,@Metric_Employee		varchar(500) = null --added on 19 Mar 2015
      ,@AchievedWeight_Manager numeric(18,2) = null --added on 23 Mar 2015
      ,@AchievedWeight_Emp	numeric(18,2) = null --added on 23 mar 2015
      ,@KPIPMS_AdditionalAchievement varchar(500) --added on 4 apr 2015
      ,@tran_type			varchar(1) 
	  ,@User_Id				numeric(18,0) = 0
	  ,@IP_Address			varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Rating = 0
		set @Rating= null
	if @Rating_Manager = 0
		set @Rating_Manager = null
	if @Rating_Employee = 0
		set @Rating_Employee = null

	exec P0080_KPIPMS_EVAL @kpipms_id OUTPUT,@cmp_id,@emp_id,@kpipms_type,@kpipms_name,@kpipms_FinancialYr,@kpipms_Status,null,null,null,null,null,null,null,@KPIPMS_EmpEarlyComment,@KPIPMS_SupEarlyComment,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,@KPIPMS_AdditionalAchievement,@tran_type,@User_Id,@IP_Address
	If Upper(@tran_type) ='I'
		Begin			--exec P0080_KPIPMS_EVAL @KPIPMS_ID OUTPUT,@Cmp_Id,@Emp_ID,@KPIPMS_Type,@KPIPMS_Name,@KPIPMS_FinancialYr,@KPIPMS_Status,null,null,null,null,null,null,null,@KPIPMS_EmpEarlyComment,@KPIPMS_SupEarlyComment,null,null,null,null,null,null,null,null,@tran_type,@User_Id,@IP_Address
			
			if Not exists(select 1 from T0080_KPIRating WITH (NOLOCK) where emp_id=@emp_id and SubKPIId= @SubKPIId  and KPIPMS_ID = @kpipms_id)
			begin
			select @KPI_RatingID = isnull(max(KPI_RatingID),0) + 1 from T0080_KPIRating WITH (NOLOCK)
			Insert Into T0080_KPIRating
			(
				 KPI_RatingID
				,Cmp_Id
				,KPIPMS_ID
				,SubKPIId
				,Emp_ID
				,Metric
				,Rating
				,AchievedWeight
				,Rating_Manager		 --added on 19 Mar 2015
				,Rating_Employee	--added on 19 Mar 2015
				,Metric_Manager		 --added on 19 Mar 2015
				,Metric_Employee	--added on 19 Mar 2015
				,AchievedWeight_Manager --added on 23 MAR 2015
				,AchievedWeight_Emp  -- added on 23 Mar 2015
			)
			Values
			(
				 @KPI_RatingID
				,@Cmp_Id
				,@KPIPMS_ID
				,@SubKPIId
				,@Emp_ID
				,@Metric
				,@Rating
				,@AchievedWeight
				,@Rating_Manager		 --added on 19 Mar 2015
				,@Rating_Employee	--added on 19 Mar 2015
				,@Metric_Manager		 --added on 19 Mar 2015
				,@Metric_Employee	--added on 19 Mar 2015
				,@AchievedWeight_Manager --added on 23 MAR 2015
				,@AchievedWeight_Emp  -- added on 23 Mar 2015
			)
			END
			ELSE
				begin
					UPDATE    T0080_KPIRating
					SET		  KPIPMS_ID	= @KPIPMS_ID
							  ,SubKPIId		= @SubKPIId
							  ,Emp_ID		= @Emp_ID
							  ,Metric		= @Metric
							  ,Rating		= @Rating
							  ,AchievedWeight = @AchievedWeight
							  ,Rating_Manager =@Rating_Manager		--added on 19 Mar 2015
							  ,Rating_Employee= @Rating_Employee	--added on 19 Mar 2015
							  ,Metric_Manager	= @Metric_Manager	--added on 19 Mar 2015
							  ,Metric_Employee =@Metric_Employee	--added on 19 Mar 2015
							  ,AchievedWeight_Manager = @AchievedWeight_Manager --added on 23 MAR 2015
							  ,AchievedWeight_Emp= @AchievedWeight_Emp-- added on 23 Mar 2015
					Where	  emp_id=@emp_id and SubKPIId= @SubKPIId and KPIPMS_ID = @kpipms_id
				end
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0080_KPIRating
			SET		  KPIPMS_ID	= @KPIPMS_ID
					  ,SubKPIId		= @SubKPIId
					  ,Emp_ID		= @Emp_ID
					  ,Metric		= @Metric
					  ,Rating		= @Rating
					  ,AchievedWeight = @AchievedWeight
					  ,Rating_Manager =@Rating_Manager		--added on 19 Mar 2015
					  ,Rating_Employee= @Rating_Employee	--added on 19 Mar 2015
					  ,Metric_Manager	= @Metric_Manager	--added on 19 Mar 2015
					  ,Metric_Employee =@Metric_Employee	--added on 19 Mar 2015
					  ,AchievedWeight_Manager = @AchievedWeight_Manager --added on 23 MAR 2015
					  ,AchievedWeight_Emp= @AchievedWeight_Emp-- added on 23 Mar 2015
			Where	  KPI_RatingID	= @KPI_RatingID  and Emp_ID=@Emp_ID
		End
	Else if Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0080_KPIRating WHERE  KPI_RatingID = @KPI_RatingID 
		End
END
