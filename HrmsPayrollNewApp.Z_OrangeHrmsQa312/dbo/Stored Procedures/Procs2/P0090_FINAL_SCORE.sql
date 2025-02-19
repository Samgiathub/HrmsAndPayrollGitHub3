
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_FINAL_SCORE]
	@Row_ID             NUMERIC(18,0) output,
	@Emp_ID		        NUMERIC(18,0), 	
	@S_EMP_ID           NUMERIC(18,0),
	@Cmp_ID             NUMERIC(18,0),
	@For_Date           DateTime,
	@Title_Name         nVarchar(50),  --Changed by Deepali -04Jun22
	@Total_Score        Numeric(18,2), 
	@Eval_Score	        Numeric(18,2),  
	@Percentage	        Numeric(18,2),
	@tran_type          Char(1),
	@Emp_Status         Numeric(18,2),
	@Appr_Int_Id		Numeric(18,0),
	@Inspection_Status  Numeric(18,2)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @for_date1 as DateTime
	Declare @Appr_Detail_Id As Numeric(18,0)
	set @for_date1 =Convert(varchar(15),getdate(),106)
	
	--if Exists(Select Row_ID from dbo.T0090_HRMS_Final_Score where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Title_Name=@Title_Name and Emp_Status=@Emp_Status)
	--Begin	
	--	Set @tran_type='U'	
	--End	
	
	--print @for_date1
	if @tran_type ='I' 
	 begin		
	       if Exists(Select Row_ID from dbo.T0090_HRMS_Final_Score WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Title_Name=@Title_Name and Emp_Status=@Emp_Status and Inspection_Status=1)
		 Begin			
			--set @ErrorString='Already Exits'
			--print @ErrorString
			Return -1
		 End	
			
				select @Row_ID = Isnull(max(Row_ID),0) + 1 From dbo.T0090_HRMS_Final_Score  WITH (NOLOCK)
		
				insert into dbo.T0090_HRMS_Final_Score
					(Row_ID,Emp_ID,S_EMP_ID,Cmp_ID,For_Date,Title_Name,Total_Score,Eval_Score,Percentage,Emp_Status,Inspection_Status,Appr_Int_Id)
					Values(@Row_ID,@Emp_ID,@S_EMP_ID,@Cmp_ID,@for_date1,@Title_Name,@Total_Score,@Eval_Score,@Percentage,@Emp_Status,@Inspection_Status,@Appr_Int_Id)
										
		If @Inspection_Status = 1
		Begin  				
			Select @Appr_Detail_Id = Appr_Detail_Id From dbo.T0090_hrms_Appraisal_Initiation_detail WITH (NOLOCK) where Emp_Id=@Emp_Id And Appr_Int_Id=@Appr_Int_Id				
			
		If @Emp_Status=1
			Begin
				Update dbo.T0090_hrms_Appraisal_Initiation_detail set Is_Sup_Submit=1,Sup_Submit_Date=getDate() where Appr_Int_ID=@Appr_Int_ID And Emp_Id=@Emp_Id
			End
		Else If	@Emp_Status=0
			Begin
				Update dbo.T0090_hrms_Appraisal_Initiation_detail set Is_Emp_Submit=1,Emp_Submit_Date=getDate() where Appr_Int_ID=@Appr_Int_ID And Emp_Id=@Emp_Id
			End						
		
			Update dbo.T0091_Employee_Goal_Score Set Goal_Status=1 where Appr_Detail_Id=@Appr_Detail_Id And Emp_Status=@Emp_Status 
			
			Update dbo.T0090_Hrms_Employee_Introspection Set Inspection_Status=1 where Appr_Detail_Id=@Appr_Detail_Id And Emp_Status=@Emp_Status
			
		End				
   END	 	 	 
	Else If @tran_type ='U' 
	  begin
                  Update dbo.T0090_HRMS_Final_Score	
			set Row_ID =@Row_ID,
			    Emp_ID= @Emp_ID,S_EMP_ID =@S_EMP_ID,Cmp_ID=@Cmp_ID,For_Date=@for_date1,Title_Name=@Title_Name,
			  	Total_Score = @Total_Score,Eval_Score=@Eval_Score,Percentage=@Percentage,
				Emp_Status = @Emp_Status , Inspection_Status = @Inspection_Status,Appr_Int_Id=@Appr_Int_Id
			where Row_ID=@Row_ID
			
						
			If @Inspection_Status = 1
		Begin  				
			Select @Appr_Detail_Id = Appr_Detail_Id From dbo.T0090_hrms_Appraisal_Initiation_detail WITH (NOLOCK) where Emp_Id=@Emp_Id And Appr_Int_Id=@Appr_Int_Id				
			
		If @Emp_Status=1
			Begin
				Update dbo.T0090_hrms_Appraisal_Initiation_detail set Is_Sup_Submit=1,Sup_Submit_Date=getDate() where Appr_Int_ID=@Appr_Int_ID And Emp_Id=@Emp_Id
			End
		Else If	@Emp_Status=0
			Begin
				Update dbo.T0090_hrms_Appraisal_Initiation_detail set Is_Emp_Submit=1,Emp_Submit_Date=getDate() where Appr_Int_ID=@Appr_Int_ID And Emp_Id=@Emp_Id
			End								
			Update dbo.T0091_Employee_Goal_Score Set Goal_Status=1 where Appr_Detail_Id=@Appr_Detail_Id And Emp_Status=@Emp_Status 
			
			Update dbo.T0090_Hrms_Employee_Introspection Set Inspection_Status=1 where Appr_Detail_Id=@Appr_Detail_Id And Emp_Status=@Emp_Status			
		End				
	   End				
	else if @tran_type ='D'
		Begin
			Delete from dbo.T0090_HRMS_Final_Score where Row_ID=@Row_ID
		End	
	RETURN

