



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_QUALIFICATION]
		@Row_ID			numeric(18,0) output
		,@Cmp_id		numeric(18,0)
	    ,@Resume_ID		numeric(18,0)
	    ,@Qual_ID		numeric(18,0)
	    ,@Spec_Detail  varchar(100)
	    ,@Year			numeric(18,0)
	    ,@Score			numeric(18,2)
	    ,@St_Date		Datetime= null
	    ,@End_Date		Datetime = null
	    ,@Comments		Varchar(250)
	    ,@EduCertificate_path varchar(max)
	    ,@University     varchar(200)
	    ,@Division		 varchar(50)	    
	    ,@Trans_Type	char(1) 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @St_Date = ''
		set @St_Date = null
	if @End_Date = ''
		set @End_Date = null
	
	 if @Trans_Type = 'I'
	   Begin 
	        
		 if exists(Select Row_ID from T0090_HRMS_RESUME_QUALIFICATION WITH (NOLOCK) where Qual_ID=@Qual_ID and Resume_ID=@Resume_ID)
					Begin
						set @Row_ID = 0
						return 
					End 
					
					
					select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_HRMS_RESUME_QUALIFICATION WITH (NOLOCK)
				
					Insert into T0090_HRMS_RESUME_QUALIFICATION (
													Row_ID,
													Cmp_id ,
													Resume_ID ,
													Qual_ID   ,
													Specialization,
													[Year]  ,
													Score,
													St_Date,
													End_Date,
													Comments,
													EduCertificate_path,
													University,
													Division
													)
								values	(
												@Row_ID,
												@Cmp_id ,
												@Resume_ID ,
												@Qual_ID   ,
												@Spec_Detail ,
												@Year  ,
												@Score,
												@St_Date,
												@End_Date,
												@Comments,
												@EduCertificate_path,
												@University,
												@Division
										 )
					
      End					
	    
	 Else if  @Trans_Type = 'U'   
	 
	   Begin
	         Update t0090_HRMS_RESUME_QUALIFICATION 
	         
	               set Row_ID	  = @Row_ID
	                  ,Cmp_id 	  = @Cmp_id
	                 --,Resume_ID   = @Resume_ID --commented by aswini 07/09/2023
	                 ,Qual_ID     = @Qual_ID
	                 ,Specialization  =@Spec_Detail
	                 ,[Year]       =@Year
	                 ,Score=@Score 
	                 ,St_Date = @St_Date
	                 ,End_Date = @End_Date
	                 ,Comments = @Comments
	                 ,EduCertificate_path = @EduCertificate_path
	                 ,University = @University
	                 ,Division = @Division	               
	                 where Row_ID =@Row_ID
	   
	   
	   
	   End
	   
	    Else if  @Trans_Type = 'D'   
	      Begin 
	          
	           Delete from T0090_HRMS_RESUME_QUALIFICATION where Row_ID =@Row_ID
				
	      End
	 
	   
	   
	RETURN




