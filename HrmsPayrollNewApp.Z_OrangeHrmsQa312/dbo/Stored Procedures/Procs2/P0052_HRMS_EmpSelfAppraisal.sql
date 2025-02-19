

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_HRMS_EmpSelfAppraisal]
	 @ESA_ID numeric(18,0) output,  
	 @Cmp_ID  numeric(18,0),  
	 @Emp_ID  numeric(18,0),  
	 @Initiateid numeric(18,0),  
	 @SApparisal_ID numeric(18, 0),
	 @Emp_weightage numeric(18, 2),
	 @Emp_Rating numeric(18, 2),
     @Final_Emp_Score numeric(18, 2),
     @RM_weightage numeric(18, 2),
     @RM_Rating numeric(18, 2),
	 @Final_RM_Score numeric(18, 2),
	 @RM_Comments varchar(Max),
	 @HOD_weightage numeric(18, 2),
	 @HOD_Rating numeric(18, 2),
	 @Final_HOD_Score numeric(18, 2),
     @HOD_Comments varchar(Max),
     @GH_weightage numeric(18, 2),
	 @GH_Rating numeric(18, 2),
	 @Final_GH_Score numeric(18, 2),
     @GH_Comments varchar(Max),
	 @User_Id	numeric(18,0)	= 0,
	 @IP_Address	varchar(30)	= '', 
	 @tran_type			varchar(1) 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
if @RM_Weightage	= 0
	set	@RM_Weightage=null
if @HOD_Weightage		= 0
	set	@HOD_Weightage=null
if @GH_Weightage		= 0
	set	@GH_Weightage=null
	
BEGIN	
	declare @SendToHOD as int
	declare @SendToRM as int

	select @SendToHOD=isnull(SendToHOD,0),@SendToRM=ISNULL(Rm_Required,0)
	from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@InitiateId
	
	If Upper(@tran_type) ='I'
		Begin
			if not exists(select 1 from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where SApparisal_ID=@SApparisal_ID and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid)
				BEGIN
				print 'm'
					select @ESA_ID = isnull(max(ESA_ID),0) + 1 from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK)
					Insert into T0052_HRMS_EmpSelfAppraisal
					(
						 ESA_ID,  
						 Cmp_ID , 
						 Emp_ID,
						 InitiateId, 
						 SApparisal_ID ,
						 Emp_Weightage,
						 Emp_Rating ,
						 Final_Emp_Score,
						 RM_Weightage,
						 RM_Rating,
						 Final_RM_Score,
						 RM_Comments,
						 HOD_Weightage,
						 HOD_Rating ,
						 Final_HOD_Score, 				
						 HOD_Comments, 
						 GH_Weightage,
						 GH_Rating ,
						 Final_GH_Score, 				
						 GH_Comments 
					)
					values
					(
						 @ESA_ID,  
						 @Cmp_ID ,  
						 @Emp_ID,
						 @Initiateid,   
						 @SApparisal_ID ,
						 @Emp_weightage,
						 @Emp_Rating ,
						 @Final_Emp_Score,
						 @RM_Weightage,
						 @RM_Rating,
						 @Final_RM_Score,
						 @RM_Comments,
						 @HOD_Weightage,
						 @HOD_Rating ,
						 @Final_HOD_Score, 						 
						 @HOD_Comments,
						 @GH_Weightage,
						 @GH_Rating ,
						 @Final_GH_Score, 				
						 @GH_Comments 
						)
				END
			ELSE
				Begin	
				print 'k'		
				  Update T0052_HRMS_EmpSelfAppraisal
				  Set				 
					 Emp_Weightage = @Emp_weightage,
					 Emp_Rating = @Emp_Rating,
					 Final_Emp_Score = @Final_Emp_Score,
					 RM_Weightage=@RM_Weightage,
					 RM_Rating = @RM_Rating,
					 Final_RM_Score = @Final_RM_Score,
					 RM_Comments = @RM_Comments,
					 HOD_Weightage=@HOD_Weightage,
					 HOD_Rating = @HOD_Rating,
					 Final_HOD_Score = @Final_HOD_Score, 	
					 HOD_Comments = @HOD_Comments, 
					 GH_Weightage=@GH_Weightage,
					 GH_Rating = @GH_Rating,
					 Final_GH_Score = @Final_GH_Score, 	
					 GH_Comments = @GH_Comments 
				  Where SApparisal_ID=@SApparisal_ID and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid
				 				 
				End		
		End
	Else If  Upper(@tran_type) ='U' 	
		Begin
			
			  Update T0052_HRMS_EmpSelfAppraisal
			  Set				 
				 Emp_Weightage = @Emp_weightage,
				 Emp_Rating = @Emp_Rating,
				 Final_Emp_Score = @Final_Emp_Score,
				 RM_Weightage=@RM_Weightage,
				 RM_Rating = @RM_Rating,
				 Final_RM_Score = @Final_RM_Score,
				 RM_Comments = @RM_Comments,
				 HOD_Weightage=@HOD_Weightage,
				 HOD_Rating = @HOD_Rating,
				 Final_HOD_Score = @Final_HOD_Score, 	
				 HOD_Comments = @HOD_Comments, 
				 GH_Weightage=@GH_Weightage,
				 GH_Rating = @GH_Rating,
				 Final_GH_Score = @Final_GH_Score, 	
				 GH_Comments = @GH_Comments 
			  Where SApparisal_ID=@SApparisal_ID and cmp_id=@Cmp_ID and Emp_ID=@Emp_ID and InitiateId=@Initiateid		
		End
	Else If  Upper(@tran_type) ='D'
		Begin		
			DELETE FROM T0052_HRMS_EmpSelfAppraisal WHERE ESA_ID = @ESA_ID		
		END
		
	if @SendToHOD =0
		begin
			update 	T0052_HRMS_EmpSelfAppraisal set
				HOD_Rating=null,
				HOD_Weightage=null,
				HOD_Comments=null,
				Final_HOD_Score=null
			Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id
		end	

	if @SendToRM =0
		begin
			update 	T0052_HRMS_EmpSelfAppraisal set
				RM_Rating=null,
				RM_Weightage=null,
				RM_Comments=null,
				Final_RM_Score=null
			Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id
		end	
END
