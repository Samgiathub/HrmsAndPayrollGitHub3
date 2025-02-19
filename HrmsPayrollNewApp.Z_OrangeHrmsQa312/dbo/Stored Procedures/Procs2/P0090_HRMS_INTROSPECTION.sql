


--exec P0090_HRMS_INTROSPECTION 9,2028,0,1,8


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_INTROSPECTION]
	@Cmp_Id Numeric(18,0),
	@Emp_Id Numeric(18,0),
	@Branch_ID numeric(18,0),
	@Emp_Status numeric(18,0),
	@Appr_Int_Id numeric(18,0)
  AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 declare @Ins_Status as numeric(18,0)
 Declare @Desig_Id as numeric(18,0) 
 Declare @Appr_detail_Id as numeric(18,0)
 Declare @Grd_Id as numeric(18,0) 
 Declare @Dept_Id as numeric(18,0) 
 Declare @Appr_Id as numeric(18,0)
 Declare @Emp_Id1 as numeric(18,0)
 Declare @Emp_Inspection_Id as numeric(18,0)
 Declare @Que_Id as numeric(18,0)
 Declare @Question as Varchar(100)
 Declare @Que_Description as Varchar(100)
 Declare @Answer as varchar(1000)
 Declare @Que_Rate as numeric(18,0)
 Declare @Inspection_Status as numeric(18,0)
 
 set nocount on
 
 --if @Branch_ID=0
 --begin
	--Select @Branch_ID=Branch_ID from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Emp_ID=@Emp_Id
 --End
 
 CREATE table #Appr_ID
 (
  Appr_ID numeric(18,0)
 ) 
 
 Declare @Que_Detail table
 (
   Emp_Inspection_Id numeric(18,0),
   Que_Id numeric(18,0),
   Question varchar(100),
   Que_Description varchar(500),
   Answer varchar(1000),
   Que_Rate numeric(18,0),
   Inspection_Status numeric(18,0),
   Appr_Detail_Id numeric(18,0),
   Flag numeric(18,0)
  )
  
  Declare @Que_Detail_1 table
  (
    Que_Id numeric(18,0),
    Question Varchar(500),
    Que_Description Varchar(500),
    Flag  numeric(18,0),
    Appr_Detail_Id numeric(18,0),
    Appr_Id numeric(18,0)
  )
 
 set  @Ins_Status = null

        select @Emp_Id1 = count(Emp_Id) from dbo.V0090_Hrms_Employee_Introspection Where Emp_ID=@Emp_ID and appr_int_id=@Appr_Int_Id and Emp_Status=@Emp_Status   Group By Inspection_Status
        --And Emp_Status=@Emp_Status
        
If @Emp_Id1 <> 0
	Begin
	
		--select @Appr_Detail_Id=isnull(Appr_Detail_Id,0),@Grd_Id=isnull(Grd_Id,0),@Branch_ID=isnull(@Branch_ID,0),@Dept_Id=isnull(Dept_Id,0),@Desig_Id=isnull(Desig_Id,0) from dbo.V0090_Hrms_Emp_Dash_Board where Appr_Int_Id=@Appr_Int_Id And Cmp_ID=@Cmp_ID And Emp_ID=@Emp_ID
		select @Appr_Detail_Id=isnull(Appr_Detail_Id,0),@Branch_Id=isnull(Branch_Id,0),@Grd_Id=isnull(Grd_Id,0),@Dept_Id=isnull(Dept_Id,0),@Desig_Id=isnull(Desig_Id,0) from dbo.V0090_Hrms_Emp_Dash_Board where Appr_Int_Id=@Appr_Int_Id And Cmp_ID=@Cmp_ID And Emp_ID=@Emp_ID		
		exec P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,@Dept_Id,@Desig_Id,@Grd_Id,@Emp_Id,'I'
		select @Appr_Id = Appr_Id from #Appr_ID
		If @Appr_id Is Null		
			Begin
				exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,0,@Desig_Id,@Grd_Id,@Emp_Id,'I'
				select @Appr_Id = Appr_Id from #Appr_ID																				
						If @Appr_id Is Null		
							Begin
								exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,@Dept_Id,0,@Grd_Id,@Emp_Id,'I'
								select @Appr_Id = Appr_Id from #Appr_ID																								
							End							
					If @Appr_Id Is Null
						Begin 
							exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,0,0,@Grd_Id,@Emp_Id,'I'							
							select @Appr_Id = Appr_Id from #Appr_ID																							
						End
			End			
		
		insert into @Que_Detail		
		Select Emp_Inspection_Id,Que_Id,Question,Que_Description,Answer,Que_Rate,Inspection_Status,@Appr_Detail_Id,0 From dbo.V0090_HRMS_Employee_Question where Emp_Status= @Emp_Status And Emp_Id = @Emp_ID And Appr_Detail_Id = @Appr_Detail_Id		 --Appr_Id = @Appr_ID And 
		--insert into @Que_Detail(Emp_Inspection_Id,Que_Id,Question,Que_Description,Answer,Que_Rate,Inspection_Status,Appr_Detail_Id,Flag)values(@Emp_Inspection_Id,@Que_Id,@Question,@Que_Description,@Answer,@Que_Rate,@Inspection_Status,@Appr_Detail_Id,0)				
		select * from @Que_Detail
		
        Drop Table #Appr_ID        
	End
Else
	Begin	
		select @Appr_Detail_Id=isnull(Appr_Detail_Id,0),@Branch_Id=isnull(Branch_Id,0),@Grd_Id=isnull(Grd_Id,0),@Dept_Id=isnull(Dept_Id,0),@Desig_Id=isnull(Desig_Id,0) from dbo.V0090_Hrms_Emp_Dash_Board where Appr_Int_Id=@Appr_Int_Id And Cmp_ID=@Cmp_ID And Emp_ID=@Emp_ID		
		-- Add New Parameter Form_Name which consider from which form request comes
		--I--Introspection Form 
		--A--Appraisal_Effection_Form		
		exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,@Dept_Id,@Desig_Id,@Grd_Id,@Emp_Id,'I'		
		select @Appr_Id = Appr_Id from #Appr_ID	-- if we pass all parameter and then we get null appr id then we check with Null Desig Id and Dept Id.because in table it is possible to department and designation is null.'Nikunj 26-July-2010					
			If @Appr_id Is Null		
			Begin
				exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,0,@Desig_Id,@Grd_Id,@Emp_Id,'I'
				select @Appr_Id = Appr_Id from #Appr_ID																				
						If @Appr_id Is Null		
							Begin
								exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,@Dept_Id,0,@Grd_Id,@Emp_Id,'I'
								select @Appr_Id = Appr_Id from #Appr_ID																								
							End							
					If @Appr_Id Is Null
						Begin 
							exec dbo.P0055_HRMS_Appr_FeedBack_Question_get @Cmp_ID,@Branch_ID,0,0,@Grd_Id,@Emp_Id,'I'							
							select @Appr_Id = Appr_Id from #Appr_ID																							
						End
			End			
        insert into @Que_Detail_1
        Select isnull(Que_Id,0),Question,Que_Description,1,@Appr_Detail_Id,Appr_Id From dbo.T0055_HRMS_APPR_FEEDBACK_QUESTION WITH (NOLOCK) where Appr_Id = @Appr_Id And Emp_Status = @Emp_Status        
        select * from @Que_Detail_1                
        Drop Table #Appr_ID        
	End	
	RETURN




