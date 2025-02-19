



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_Appraisal_Setting]
@Appr_id numeric(18) output
,@cmp_id numeric(18)
,@branch_id numeric(18)
,@dept_id numeric(18)
,@desig_id numeric(18)
,@Grade_id numeric(18)
,@Actual_CTC numeric(18,2)
,@Experience numeric(18,2)
,@Min_Appraisal numeric(18,2)
,@Max_Appraisal numeric(18,2)
,@Appraisal_Duration numeric(18,2)
,@tran_type as char(1)            
           
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @cmp_id = 0 
	 set @cmp_id  = null
	if @dept_id=0
	 set @dept_id =null
	if @branch_id =0 
	 set @branch_id = null
	if @Grade_id = 0 
	 set @Grade_id = null
	if @desig_id = 0
	  set @desig_id = null
	  
	if Upper(@tran_type) ='I' 
		Begin		
			If exists (Select Appr_id  from dbo.T0050_HRMS_APPRAISAL_SETTING WITH (NOLOCK) Where cmp_id=@CMP_ID AND branch_id=@branch_id AND dept_id = @dept_id AND desig_id=@desig_id AND Grade_id=@Grade_id)
				Begin
					set @Appr_id=0
					RAISERROR('Duplicate Setting',16,2)
					RETURN 					
				End	
		/*	Else			
				Begin
					If exists (Select Appr_id from dbo.T0050_HRMS_APPRAISAL_SETTING Where cmp_id=@CMP_ID AND branch_id=@branch_id AND Grade_id=@Grade_id And Dept_Id=@Dept_Id)
						Begin
							set @Appr_id=0
							RAISERROR('Duplicate Setting',16,2)
							RETURN 								
						End
					Else
						Begin
							If exists (Select Appr_id from dbo.T0050_HRMS_APPRAISAL_SETTING Where cmp_id=@CMP_ID AND branch_id=@branch_id AND Grade_id=@Grade_id)
									Begin
										set @Appr_id=0
										RAISERROR('Duplicate Setting',16,2)
										RETURN 				
									End		
						End	
				End*/
			
			
				
					select @Appr_id = isnull(max(Appr_id),0) + 1 from dbo.T0050_HRMS_APPRAISAL_SETTING WITH (NOLOCK)
						
					insert into dbo.T0050_HRMS_APPRAISAL_SETTING(
											Appr_id
											,cmp_id
											,branch_id
											,dept_id
											,desig_id
											,Grade_id
											,Actual_CTC
											,Experience
											,Min_Appraisal
											,Max_Appraisal
											,Appraisal_Duration
											,For_Date
										) 
											
								values(      @Appr_id
											,@cmp_id
											,@branch_id
											,@dept_id
											,@desig_id
											,@Grade_id
											,@Actual_CTC
											,@Experience
											,@Min_Appraisal
											,@Max_Appraisal
											,@Appraisal_Duration
											,getdate()
										
										)
		End 
	Else If upper(@tran_type) ='U' 
		Begin					
				Update dbo.T0050_HRMS_APPRAISAL_SETTING 
				Set      Actual_CTC=@Actual_CTC
						,Experience=@Experience
						,Min_Appraisal=@Min_Appraisal
						,Max_Appraisal=@Max_Appraisal
						,Appraisal_Duration=@Appraisal_Duration					
				where Appr_id = @Appr_id  
		End	
	Else If upper(@tran_type) ='D'
		Begin
			If Exists (select Appr_id from dbo.T0055_HRMS_Appr_FeedBack_Question WITH (NOLOCK) where Appr_id=@Appr_id)
				Begin
					Delete	from dbo.T0055_HRMS_Appr_FeedBack_Question Where Appr_id=@Appr_id 
				End
			delete  from dbo.T0050_HRMS_APPRAISAL_SETTING where Appr_id=@Appr_id 
		End
   RETURN




