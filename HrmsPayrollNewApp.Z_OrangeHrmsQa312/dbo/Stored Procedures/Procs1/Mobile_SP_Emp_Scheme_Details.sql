CREATE PROCEDURE [dbo].[Mobile_SP_Emp_Scheme_Details]
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
			DECLARE @SCHEME_ID AS NUMERIC,@TRAVEL_TYPE VARCHAR(500), @Travel_Type_Name VARCHAR(500)

			SELECT  @SCHEME_ID =  Scheme_ID 
			FROM T0095_EMP_SCHEME E 
			WHERE Cmp_ID = @CMP_ID AND EMP_ID = @EMP_ID AND E.Type = 'Travel'
			order by Tran_ID desc

			CREATE TABLE #ttY 
			(      
			  Traveltype varchar(500),
			  Scheme_id numeric
			) 

			SELECT @TRAVEL_TYPE = Leave FROM T0050_Scheme_Detail 
			WHERE Cmp_Id = @CMP_ID AND Scheme_Id = @SCHEME_ID


			If @TRAVEL_TYPE <> ''
			Begin
				Insert into #ttY
				Select Cast(data as numeric) ,@SCHEME_ID
				from dbo.Split (@TRAVEL_TYPE,'#')	
			End

			Select @Travel_Type_Name = Travel_Type_Name 
			from #ttY  sd
			inner join T0095_EMP_SCHEME es on es.Scheme_ID = sd.Scheme_id
			inner join T0040_Travel_Type TT on TT.Travel_Type_Id = sd.Traveltype
			where sd.Scheme_Id = @SCHEME_ID and emp_id	= @EMP_ID	AND es.Cmp_Id = @CMP_ID

			Select * from T0095_EMP_SCHEME WITH (NOLOCK) where Type = @Loan_ID  and Cmp_Id = @Cmp_ID and emp_Id = @Emp_ID and Effective_Date <= @From_Date  
			--select @Travel_Type_Name as Travel_Type_Name
			exec SP_GET_TRAVEL_TYPE @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID
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
	 select distinct* from #tmpScheme
	 select 'data1'
	end 
    
END
