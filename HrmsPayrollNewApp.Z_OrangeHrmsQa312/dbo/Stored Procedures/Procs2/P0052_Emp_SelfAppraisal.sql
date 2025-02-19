
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_Emp_SelfAppraisal]
	@SelfApp_Id  numeric(18) output  
   ,@Cmp_ID   numeric(18)   
   ,@SAppraisal_ID numeric(18) 
   ,@InitiateId  numeric(18)  =null
   ,@Emp_Id  numeric(18)  =null
   ,@Answer  nvarchar(4000) =null  --Changed by Deepali -04Jun22
   ,@Weightage numeric(18,2) =null
   ,@tran_type  varchar(1) 
   ,@User_Id numeric(18,0) = 0
   ,@IP_Address varchar(30)= '' 
   ,@Emp_Score numeric(18,2) = null --Mukti(14092016)
   ,@Comments nvarchar(4000)= null  --Mukti(14092016)  --Changed by Deepali -04Jun22
   ,@Manager_Score numeric(18,2) = null --23 Sep 2016 sneha
   ,@Manager_comments nvarchar(4000)= null --23 Sep 2016 sneha  --Changed by Deepali -04Jun22
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
	declare @OldValue as nvarchar(max)
	declare @OldSAppraisal_ID as numeric(18,0)
	declare @OldAnswer as nvarchar(2000)  --Changed by Deepali -04Jun22
	declare @SApparisal_Content as nvarchar(1000)  --Changed by Deepali -04Jun22
	declare @Empname as nvarchar(100)
	declare @OldEmpname as nvarchar(100)
	declare @OldSApparisal_Content as nvarchar(1000)  --Changed by Deepali -04Jun22
	declare @OldWeightage as numeric(18,2)
	declare @OldEmp_Id as numeric(18,0)
	Declare @Emp_name as nVarchar(250)
	Declare @Cmp_name as nVarchar(250)
	Declare @oldEmp_Score as Varchar(10)
	Declare @OldComments as nvarchar(4000)   --Changed by Deepali -04Jun22
	Declare @OldManager_Score as Varchar(10)
	Declare @OldManager_comments as nvarchar(4000)  --Changed by Deepali -04Jun22
	
	set @OldValue = ''
	set @OldSAppraisal_ID = 0
	set @OldEmp_Id = 0
	set @OldAnswer = ''
	set @SApparisal_Content = ''
	set @Empname = ''
	set @OldWeightage = 0
	
	-------------
	If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
		BEGIN
			If @Answer = ''
				BEGIN
					set @SelfApp_Id=0
					--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Answer is not Properly Inserted',0,'Enter Answer Vertical Name',GetDate(),'Appraisal')						
					Return
				END
		END	
	If Upper(@tran_type) ='I'
		Begin
			select @SelfApp_Id = isnull(max(SelfApp_Id),0) + 1 from T0052_Emp_SelfAppraisal	WITH (NOLOCK)
				
			Insert Into T0052_Emp_SelfAppraisal 
			(
				 SelfApp_Id
				,Cmp_ID
				,SAppraisal_ID
				,InitiateId
				,Emp_Id
				,Answer
				,Weightage
				,Emp_Score--Mukti(14092016)
				,Comments--Mukti(14092016)
				,Manager_Score --23 Sep 2016 sneha
				,Manager_comments --23 Sep 2016 sneha
			)
			VALUES  
			(
				 @SelfApp_Id
				,@Cmp_ID
				,@SAppraisal_ID
				,@InitiateId
				,@Emp_Id
				,@Answer
				,@Weightage
				,@Emp_Score--Mukti(14092016)
				,@Comments--Mukti(14092016)
				,@Manager_Score --23 Sep 2016 sneha
				,@Manager_comments --23 Sep 2016 sneha
			)
			
			--Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
				
			set @OldValue = 'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Answer :' +ISNULL(@Answer,'') 
										+ '#'+ 'Weightage :' + CONVERT(nvarchar(10),ISNULL(@Weightage,0)) 
										+ '#'+ 'Employee Score :' +CONVERT(nvarchar(10),ISNULL(@Emp_Score,0)) 
										+ '#'+ 'Comments :' +ISNULL(@Comments,'') 
										+ '#'+ 'Manager Score :' + CONVERT(nvarchar(10),ISNULL(@Manager_Score,0)) 
										+ '#'+ 'Manager comments :' + ISNULL(@Manager_comments,'') 										
			--Added By Mukti(end)08112016							
			--select @SApparisal_Content = SApparisal_Content from T0040_SelfAppraisal_Master where SApparisal_ID = @SAppraisal_ID			
			--select @Empname = Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = @Emp_Id			
			--set @OldValue = 'New Value' + '#'+ 'Answer :' +ISNULL( @Answer,'') + '#' + 'SApparisal_Content :' + @SApparisal_Content + '#' + 'Weightage :' + ISNULL( @Weightage,'') + '#' + 'Empname :' + ISNULL(@Empname,'')  + '#' 
			
			--------
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
		  --Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
			
			  select @OldSAppraisal_ID = SAppraisal_ID  , @OldAnswer = ISNULL(Answer,''),
					 @OldWeightage  =ISNULL(Weightage,0),@OldEmp_Id  =isnull(Emp_Id,0),@oldEmp_Score=ISNULL(Emp_Score,0),
					 @OldComments=ISNULL(Comments,''),@OldManager_Score=ISNULL(Manager_Score,0),@OldManager_comments=ISNULL(Manager_comments,'')
			  From T0052_Emp_SelfAppraisal WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SelfApp_Id =@SelfApp_Id		
			  select @OldEmpname=Emp_Full_Name  from T0080_EMP_MASTER WITH (NOLOCK) where  Emp_ID = @Emp_Id
			  select @OldSApparisal_Content = SApparisal_Content from T0040_SelfAppraisal_Master WITH (NOLOCK) where SApparisal_ID = @SAppraisal_ID	
		  --Added By Mukti(end)08112016  
			  
			  Update T0052_Emp_SelfAppraisal
			  Set    Answer = @Answer,
					 Weightage = @Weightage,
					 Emp_Score = @Emp_Score,--Mukti(14092016)
					 Comments = @Comments--Mukti(14092016)
					 ,Manager_Score =@Manager_Score --23 Sep 2016 sneha
					 ,Manager_comments = @Manager_comments--23 Sep 2016 sneha
			  Where  SelfApp_Id = @SelfApp_Id
			  
			 --Added By Mukti(start)08112016
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Answer :' +ISNULL(@OldAnswer,'') 
										+ '#'+ 'Weightage :' + CONVERT(nvarchar(10),ISNULL(@OldWeightage,0)) 
										+ '#'+ 'Employee Score :' +CONVERT(nvarchar(10),ISNULL(@OldEmp_Score,0)) 
										+ '#'+ 'Comments :' +ISNULL(@OldComments,'') 
										+ '#'+ 'Manager Score :' + CONVERT(nvarchar(10),ISNULL(@OldManager_Score,0)) 
										+ '#'+ 'Manager comments :' + ISNULL(@OldManager_comments,'') 	
						   +'New Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
									    + '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Answer :' +ISNULL(@Answer,'') 
										+ '#'+ 'Weightage :' + CONVERT(nvarchar(10),ISNULL(@Weightage,0)) 
										+ '#'+ 'Employee Score :' +CONVERT(nvarchar(10),ISNULL(@Emp_Score,0)) 
										+ '#'+ 'Comments :' +ISNULL(@Comments,'') 
										+ '#'+ 'Manager Score :' + CONVERT(nvarchar(10),ISNULL(@Manager_Score,0)) 
										+ '#'+ 'Manager comments :' + ISNULL(@Manager_comments,'') 										
			--Added By Mukti(end)08112016	
			
			  --select @SApparisal_Content = SApparisal_Content from T0040_SelfAppraisal_Master where SApparisal_ID = @SAppraisal_ID
			  --select @Empname = Emp_Full_Name from T0080_EMP_MASTER where Emp_ID = @Emp_Id
			  --set @OldValue = 'old Value' + '#'+ 'Answer :' + @OldAnswer  + '#' + 'SApparisal_Content :' + @OldSApparisal_Content + '#' + 'Weightage:' + @OldWeightage  + '#' + 'Empname :' + @OldEmpname   + '#' +
     --          + 'New Value' + '#'+ 'Answer :' +ISNULL( @Answer,'') + '#' + 'SApparisal_Content :' + @SApparisal_Content + '#' + 'Weightage :' + ISNULL( @Weightage,'') + '#' + 'Empname :' + ISNULL(@Empname,'')  + '#' 
			  
			  ----------
		End
	Else If  Upper(@tran_type) ='D'
		Begin
		 --Added By Mukti(start)08112016
			select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
			select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id
			
			  select @OldSAppraisal_ID = SAppraisal_ID  , @OldAnswer = ISNULL(Answer,''),
					 @OldWeightage  =ISNULL(Weightage,''),@OldEmp_Id  =isnull(Emp_Id,''),@oldEmp_Score=ISNULL(Emp_Score,0),
					 @OldComments=ISNULL(Comments,''),@OldManager_Score=ISNULL(Manager_Score,0),@OldManager_comments=ISNULL(Manager_comments,'')
			  From T0052_Emp_SelfAppraisal WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SelfApp_Id = @SelfApp_Id		
			  select @OldEmpname=Emp_Full_Name  from T0080_EMP_MASTER WITH (NOLOCK) where  Emp_ID = @Emp_Id
			  select @OldSApparisal_Content = SApparisal_Content from T0040_SelfAppraisal_Master WITH (NOLOCK) where SApparisal_ID = @SAppraisal_ID	
		  --Added By Mukti(end)08112016 
			DELETE FROM T0052_Emp_SelfAppraisal WHERE SelfApp_Id = @SelfApp_Id
		
			 --Added By Mukti(start)08112016
			set @OldValue = 'old Value' + '#' +'Company Name :' + ISNULL(@Cmp_name,'') 
										+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
										+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
										+ '#'+ 'Answer :' +ISNULL(@OldAnswer,'') 
										+ '#'+ 'Weightage :' + CONVERT(nvarchar(10),ISNULL(@OldWeightage,0)) 
										+ '#'+ 'Employee Score :' +CONVERT(nvarchar(10),ISNULL(@OldEmp_Score,0)) 
										+ '#'+ 'Comments :' +ISNULL(@OldComments,'') 
										+ '#'+ 'Manager Score :' + CONVERT(nvarchar(10),ISNULL(@OldManager_Score,0)) 
										+ '#'+ 'Manager comments :' + ISNULL(@OldManager_comments,'') 	
			--Added By Mukti(end)08112016
			--set @OldValue = 'old Value' + '#'+ 'Answer :' +ISNULL( @Answer,'') +'#' +'SApparisal_Content :' + @OldSApparisal_Content + '#' + 'Weightage :' + ISNULL( @OldWeightage,'') + '#' + 'Empname :' + ISNULL(@OldEmpname,'')  + '#' 	  
			--------------
		End
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Self-Appraisal',@OldValue,@SelfApp_Id,@User_Id,@IP_Address	
			--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'SubVertical Master',@OldValue,@SubVertical_ID,@User_Id,@IP_Address	
END

