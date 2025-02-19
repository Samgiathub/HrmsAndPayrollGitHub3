
CREATE PROCEDURE [dbo].[P0190_Monthly_AD_Detail_DepSett]
@Cmp_Id numeric(18,0)
,@Emp_ID numeric(18,0)
,@Increment_ID numeric(18,0)
,@Dep_Amount numeric(22,2)
,@Dep_Month numeric(18,0)
,@Dep_Year numeric(18,0)
,@Set_Amount numeric(22,2)
,@Set_Month numeric(18,0)
,@Set_Year numeric(18,0)
AS
SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Emp_Code as numeric(22,0)
Declare @AD_Sort_Name_Dep as varchar(10)
Declare @Ad_Id Numeric(18,0)
	select @Emp_Code= Emp_Code from t0080_Emp_Master Where Emp_ID=@Emp_ID
		
		if @Dep_Amount >0 And @Dep_Month > 0 And @Dep_Year>0
						Begin
							select @Ad_Id=isnull(Ad_Id,0) from t0050_Ad_Master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Ad_Sort_Name='DA'
							if @Ad_Id >0
								Exec P0190_MONTHLY_AD_DETAIL_IMPORT @Cmp_Id,@Emp_Code,@Dep_Month,@Dep_Year,'DA',@Dep_Amount,'',@Increment_ID
						End
		if @Set_Amount >0 And @Set_Month > 0 And @Set_Year>0
						Begin
							select @Ad_Id=isnull(Ad_Id,0) from t0050_Ad_Master WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Ad_Sort_Name='SA'
							if @Ad_Id >0
							Exec P0190_MONTHLY_AD_DETAIL_IMPORT @Cmp_Id,@Emp_Code,@Set_Month,@Set_Year,'SA',@Set_Amount,'',@Increment_ID
						End
			
RETURN




