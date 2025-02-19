

-- =============================================
-- Create by  : Nilesh Patel 
-- Create date: 28102014
-- Description:	Put Validation of scheme is not assign to the Employee.
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Emp_Scheme_Details]
	-- Add the parameters for the stored procedure here
	@Cmp_ID Numeric,
	@Emp_ID Numeric ,
	@Loan_ID Varchar(500),
	@Leave_Type Numeric = 0,
	@From_Date Datetime ,
	@TravelType varchar(100) = ''
AS
Declare @LeaveType varchar(max)
Declare @Leave_Type_Scheme varchar(50)
Declare @Qry varchar(max) 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Leave_Type = 0
	begin
		if  @TravelType <> ''and @Loan_ID = 'Travel' 
		Begin 
		--,Travel,Scheme_name 
		set @Qry = 'Select Tran_ID,	s.Cmp_ID, s.Emp_ID,	s.Scheme_ID,Type,Effective_Date 
					from T0095_EMP_SCHEME S WITH (NOLOCK) 
					inner join (SELECT Max(Effective_Date) AS EffDate, emp_id FROM T0095_EMP_SCHEME WHERE Effective_Date <= getdate() AND cmp_id = '+ cast(@Cmp_ID as varchar(10)) +' GROUP BY Emp_id
					) Qry on s.Emp_ID = Qry.Emp_ID AND S.Effective_Date = Qry.EffDate inner join V0050_Scheme_Detail VS on S.Scheme_ID = vs.Scheme_Id
					where Type = ''' + @Loan_ID + '''  and s.Cmp_Id = ' + cast(@Cmp_ID as varchar(10)) + ' and s.Emp_ID = ' +  cast(@Emp_ID as varchar(10)) + '
					and Effective_Date <= getdate() and Travel like ''%' + @TravelType + '%'''
			select @Qry
			exec(@Qry)

		END
		ELSe
		Begin 
			Select * from T0095_EMP_SCHEME WITH (NOLOCK) where Type = @Loan_ID  and Cmp_Id = @Cmp_ID and emp_Id = @Emp_ID and Effective_Date <= @From_Date 
		END
	 end
	else
	begin
	
	  set @LeaveType = '0'
	  --Select @LeaveType = D.Leave from T0095_EMP_SCHEME S inner JOIN T0050_Scheme_Detail D ON D.Scheme_Id = S.Scheme_ID and S.Cmp_ID = D.Cmp_Id where Type = @Loan_ID  and S.Cmp_Id = @Cmp_ID and S.emp_Id = @Emp_ID and D.Rpt_Level = 1 
	  --and S.Effective_Date <= @From_Date  and S.Effective_Date In(Select MAX(M.Effective_Date) FROM T0095_EMP_SCHEME M where M.Type = @Loan_ID  and M.Cmp_Id = @Cmp_ID and M.emp_Id = @Emp_ID)	 
	  Select @LeaveType = COALESCE(@LeaveType + '#', '') + CAST(D.Leave AS VARCHAR(MAX)) from T0095_EMP_SCHEME S WITH (NOLOCK) inner JOIN T0050_Scheme_Detail D WITH (NOLOCK) ON D.Scheme_Id = S.Scheme_ID and S.Cmp_ID = D.Cmp_Id where Type = @Loan_ID  and S.Cmp_Id = @Cmp_ID and S.emp_Id = @Emp_ID and D.Rpt_Level = 1 
	  --and S.Effective_Date <= @From_Date  comment by chetan 070717
	  and S.Effective_Date In(Select MAX(M.Effective_Date) FROM T0095_EMP_SCHEME M WITH (NOLOCK)
	  where M.Type = @Loan_ID  and M.Cmp_Id = @Cmp_ID and M.emp_Id = @Emp_ID  AND M.Effective_Date <= @From_Date )	 
	  
	 -- select @LeaveType C1

	   if (OBJECT_ID('tempdb..#tmpScheme') IS NULL)
			create table #tmpScheme(scheme Varchar(128))
	  
		
	  if @LeaveType <> '0' -- For Check Leave type is availble or not in selected Scheme 
		begin
		
			Select @Leave_Type_Scheme =  charindex('#' + Cast( @Leave_Type as Varchar(50)) + '#','#' + @LeaveType + '#')
			
			
			insert into #tmpScheme
			select charindex('#' + Cast( @Leave_Type as Varchar(50)) + '#','#' + @LeaveType + '#')
			--select @Leave_Type_Scheme
		End 
	  if @Leave_Type_Scheme <> '0' -- If Leave type availble then retun inder else return null 
		begin
		insert into #tmpScheme
			Select @Leave_Type_Scheme
		end
		--If Exist(Select @Loan_ID from #tmpScheme)
	 select * from #tmpScheme	 
	end 
    
END

