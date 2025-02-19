

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Loan_Grade_Wise]
	@Cmp_ID			numeric,
	@Emp_Id			numeric,
	@Subsidy_Flag   numeric = 0
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Begin
		Declare @Grd_ID Numeric(5,0)
		Declare @Cur_Loan_ID Numeric(5,0)
		Declare @Cur_Loan_Name Varchar(500)
		Declare @Cur_Grade_Details Varchar(500)
		
		Create Table #Loan_Details
		(
			Loan_ID Numeric(5,0),
			Loan_Name Varchar(500)
		)
		
		Select @Grd_ID = I.Grd_ID from T0095_INCREMENT I WITH (NOLOCK)
		Inner JOIN(SELECT MAX(Increment_Effective_Date) as Effetive_Date,Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)
		where Emp_ID = @Emp_Id 
		Group BY Emp_ID) as qry
		ON I.Emp_ID = qry.Emp_ID and I.Increment_Effective_Date = qry.Effetive_Date 
		where I.Cmp_ID = @Cmp_ID and I.Emp_ID = @Emp_Id
		
		Declare Cur_Grade_Wise_Loan Cursor
		for Select Loan_ID,Loan_Name,Grade_Details from T0040_LOAN_MASTER WITH (NOLOCK) where is_Grade_wise = 1 and Is_Interest_Subsidy_Limit = (CASE WHEN @Subsidy_Flag = 1 then 1 Else 0 END)
		open Cur_Grade_Wise_Loan
		fetch next from Cur_Grade_Wise_Loan into @Cur_Loan_ID,@Cur_Loan_Name,@Cur_Grade_Details
		
		while @@fetch_status = 0
			Begin
				if charindex(Cast(@Grd_ID as Varchar),@Cur_Grade_Details) > 0
					Begin
						insert INTO #Loan_Details(Loan_ID,Loan_Name)VALUES(@Cur_Loan_ID,@Cur_Loan_Name)
					End
				fetch next from Cur_Grade_Wise_Loan into @Cur_Loan_ID,@Cur_Loan_Name,@Cur_Grade_Details
			End 
		Close Cur_Grade_Wise_Loan
		deallocate Cur_Grade_Wise_Loan
		Select * From #Loan_Details
	End
	

Return




