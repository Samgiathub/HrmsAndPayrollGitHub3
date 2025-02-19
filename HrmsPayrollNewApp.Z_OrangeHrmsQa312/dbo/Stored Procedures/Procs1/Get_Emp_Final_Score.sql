



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Final_Score]
	@Emp_ID As Numeric(18),
	@Cmp_ID As Numeric(18)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 Declare @Zero table
	 (
		Emp_ID numeric(18,0),
		Eval_Score_0   Numeric(18,2),
		Eval_Score_1   Numeric(18,2),
		Title_Name varchar(100),
		Total_Score numeric(22,2)		
	 )	 
	 
	 Declare @Emp_ID_Cur As Numeric(18)
	 Declare @Title_Name As Varchar(50)
	 Declare @Total_Score As Numeric(18,2)
	 Declare @Eval_Score As Numeric(18,2)	 
	 Declare @Emp_Status As Int

Declare Cur_Emp_Score Cursor For

	  Select Emp_Id,Title_Name,Eval_Score,Emp_Status,Total_Score From dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where Emp_Id=@Emp_Id and Cmp_Id=@Cmp_Id order by Emp_Status		
	  Open Cur_Emp_Score
	  Fetch Next From Cur_Emp_Score Into @Emp_ID_Cur,@Title_Name,@Eval_Score,@Emp_Status,@Total_Score
	  While @@Fetch_Status = 0
	  Begin	  
	  if isnull(@Emp_Status,0) = 0
				 Begin
					insert into @Zero values(@Emp_ID_Cur,@Eval_Score,0,@Title_Name,@Total_Score)
				End			
		else if isnull(@Emp_Status,0) = 1
		BEgin
			Update @Zero set Eval_Score_1=@Eval_Score where Title_Name=@Title_Name And Emp_ID=@Emp_ID_Cur 
		End
	  
      Fetch Next From Cur_Emp_Score Into @Emp_ID_Cur,@Title_Name,@Eval_Score,@Emp_Status,@Total_Score
	  End                      
	  Close Cur_Emp_Score
	Deallocate Cur_Emp_Score 
	
	if Exists(Select Emp_ID From @Zero) 
	Begin
		select Emp_ID,Eval_Score_0,Eval_Score_1,Title_Name,Total_Score from @Zero Group By Emp_ID,Eval_Score_0,Eval_Score_1,Title_Name,Total_Score 	
	End
	Else
	Begin
	Print'No Records Found'
	End		
	RETURN


	

