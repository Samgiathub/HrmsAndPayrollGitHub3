-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_HRMS_AppTraining]
	   @App_Training_Id				numeric(18,0) output
      ,@Cmp_ID						numeric(18,0)	
      ,@InitiateId					numeric(18,0)	=null
      ,@Emp_Id						numeric(18,0)	=null
      ,@Type						nvarchar(50)		=null  --Changed by Deepali -03Jun22
      ,@Attend_LastYear				varchar(8000)	=null     
      ,@Recommended_ThisYear		varchar(8000)	=null
      ,@ObservableChanges			nvarchar(1000)	=null  --Changed by Deepali -03Jun22
      ,@ReasonForRecommend			nvarchar(1000)	=null  --Changed by Deepali -03Jun22
      ,@tran_type					varchar(1)		
	  ,@User_Id						numeric(18,0)	= 0
	  ,@IP_Address					varchar(30)		= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as nvarchar(max)   --Changed by Deepali -03Jun22
	Declare @Emp_name as Varchar(250)
	Declare @Cmp_name as Varchar(250)
	Declare @Attend_LastYear_Training as Varchar(Max)
	Declare @Recommended_ThisYear_Training as Varchar(Max)
	Declare @OldAttend_LastYear as Varchar(Max)
	Declare @OldRecommended_ThisYear as Varchar(Max)
	Declare @OldObservableChanges as nVarchar(Max)   --Changed by Deepali -03Jun22
	Declare @OldReasonForRecommend as nVarchar(Max)   --Changed by Deepali -03Jun22
	Declare @OldAttend_LastYear_Training as Varchar(Max)
    Declare @OldRecommended_ThisYear_Training as Varchar(Max)

	Declare @OldPerformanceF_ID as varchar(10)
	set @OldValue = ''

	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		Begin
			if @Type = ''
				begin	
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'type is not Properly Inserted',0,'Enter type',GetDate(),'Appraisal')										
					Return
				End
		End
	If Upper(@tran_type) ='I'
		begin
			select @App_Training_Id = isnull(max(App_Training_Id),0) + 1 from T0052_HRMS_AppTraining WITH (NOLOCK)
			Insert into T0052_HRMS_AppTraining
			(
				 App_Training_Id
				,Cmp_ID
				,InitiateId
				,Emp_Id
				,Type
				,Attend_LastYear
				,Recommended_ThisYear
				,ObservableChanges
				,ReasonForRecommend
			)
			values
			(
				 @App_Training_Id
				,@Cmp_ID
				,@InitiateId
				,@Emp_Id
				,@Type
				,@Attend_LastYear
				,@Recommended_ThisYear
				,@ObservableChanges
				,@ReasonForRecommend
			)
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id	
				
				if @Type='Skill'
				BEGIN
					SELECT @Attend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK)
					
					SELECT @Recommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK)
				END
				ELSE
				BEGIN
					set @Type='Training'
					SELECT @Attend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK)
					
					SELECT @Recommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1  WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK)
				END
					
				set @OldValue = 'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Attend Last Year :' +ISNULL(@Attend_LastYear_Training,'') 		
											+ '#'+ 'Recommended This Year :' +ISNULL(@Recommended_ThisYear_Training,'') 		
											+ '#'+ 'Observable Changes :' +ISNULL(@ObservableChanges,'') 		
											+ '#'+ 'Reason For Recommend :' +ISNULL(@ReasonForRecommend,'') 		
			--Added By Mukti(end)10112016 
		End	
	Else If  Upper(@tran_type) ='U' 	
		begin
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK)  where Cmp_Id=@Cmp_ID
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id	
				select @OldAttend_LastYear=Attend_LastYear,@OldRecommended_ThisYear=Recommended_ThisYear,@OldObservableChanges=ObservableChanges,
					   @OldReasonForRecommend=ReasonForRecommend 
				from T0052_HRMS_AppTraining WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
				
				if @Type='Skill'
				BEGIN
					print @OldAttend_LastYear
					SELECT @OldAttend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON  AT.Attend_LastYear=@OldAttend_LastYear  and CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @OldAttend_LastYear_Training
					
					print @OldRecommended_ThisYear
					SELECT @OldRecommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Recommended_ThisYear=@OldRecommended_ThisYear and CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id and AT.Recommended_ThisYear=@OldRecommended_ThisYear
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @OldRecommended_ThisYear_Training
				END
				ELSE
				BEGIN
					set @Type='Training'
					print @OldAttend_LastYear
					SELECT @OldAttend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON  AT.Attend_LastYear=@OldAttend_LastYear  and CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @OldAttend_LastYear_Training
					
					print @OldRecommended_ThisYear
					SELECT @OldRecommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Recommended_ThisYear=@OldRecommended_ThisYear and CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id and AT.Recommended_ThisYear=@OldRecommended_ThisYear
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @OldRecommended_ThisYear_Training
				END
			--Added By Mukti(end)10112016				
				
			 Update T0052_HRMS_AppTraining
			  Set    Attend_LastYear		=	@Attend_LastYear
					,Recommended_ThisYear	=	@Recommended_ThisYear
					,ObservableChanges		=	@ObservableChanges
					,ReasonForRecommend		=	@ReasonForRecommend
			  Where  App_Training_Id = @App_Training_Id and InitiateId = @InitiateId			  
			  
		--Added By Mukti(start)10112016
			if @Type='Skill'
				BEGIN
					print @Attend_LastYear 
					SELECT @Attend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Attend_LastYear=@Attend_LastYear and CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @Attend_LastYear_Training		
						
					print @Recommended_ThisYear 
					SELECT @Recommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Skill_Name 
					FROM	T0040_SKILL_MASTER TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Recommended_ThisYear=@Recommended_ThisYear and CHARINDEX('#' + CAST(TM1.Skill_ID AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK)  where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @Recommended_ThisYear_Training
				END
				ELSE
				BEGIN
					print @Attend_LastYear 
					SELECT @Attend_LastYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Attend_LastYear=@Attend_LastYear and CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Attend_LastYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @Attend_LastYear_Training		
						
					print @Recommended_ThisYear 
					SELECT @Recommended_ThisYear_Training=STUFF((SELECT DISTINCT ',' + TM1.Training_name 
					FROM	T0040_Hrms_Training_master TM1 WITH (NOLOCK)
							INNER JOIN T0052_HRMS_AppTraining AT WITH (NOLOCK) ON AT.Recommended_ThisYear=@Recommended_ThisYear and CHARINDEX('#' + CAST(TM1.Training_id AS VARCHAR(16)) + '#', '#' + AT.Recommended_ThisYear + '#') > 0
					WHERE AT.App_Training_Id=AT1.App_Training_Id 
					FOR XML PATH('')),1,1,'') 
					FROM	T0052_HRMS_AppTraining AT1 WITH (NOLOCK) where App_Training_Id = @App_Training_Id and InitiateId = @InitiateId
					print @Recommended_ThisYear_Training
				END
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Attend Last Year :' +ISNULL(@OldAttend_LastYear_Training,'') 		
											+ '#'+ 'Recommended This Year :' +ISNULL(@OldRecommended_ThisYear_Training,'') 		
											+ '#'+ 'Observable Changes :' +ISNULL(@OldObservableChanges,'') 		
											+ '#'+ 'Reason For Recommend :' +ISNULL(@OldReasonForRecommend,'')
							   +'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 			
											+ '#'+ 'Type :' +ISNULL(@Type,'') 			
											+ '#'+ 'Attend Last Year :' +ISNULL(@Attend_LastYear_Training,'') 		
											+ '#'+ 'Recommended This Year :' +ISNULL(@Recommended_ThisYear_Training,'') 		
											+ '#'+ 'Observable Changes :' +ISNULL(@ObservableChanges,'') 		
											+ '#'+ 'Reason For Recommend :' +ISNULL(@ReasonForRecommend,'') 		
			--Added By Mukti(end)10112016 
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0052_HRMS_AppTraining WHERE App_Training_Id = @App_Training_Id
		End	
		
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'HRMS Appraisal Training',@OldValue,@App_Training_Id,@User_Id,@IP_Address	
END
