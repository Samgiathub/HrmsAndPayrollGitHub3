
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_HR_DOC_Detail]
	 @Emp_doc_ID numeric(18,0)output
	,@HR_DOC_ID numeric(18,0)
	,@accetpeted int
	,@cmp_id numeric(18,0)
	,@Emp_id numeric(18,0)
	,@Doc_content nvarchar(max)
	,@login_id numeric(18,0)
	,@tran_type varchar(1)
	,@type int = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @HR_DOC_ID=0	
	   set @HR_DOC_ID=null
	if @cmp_id=0
	   set @cmp_id = null
	if @Emp_id=0
	   set @Emp_id = null
	if @login_id=0
	  set @login_id=null
	
	declare @for_date varchar(11)
	set @for_date = getdate()
	declare @todate varchar(11)
	set @todate = cast(dateadd(dd,30,getdate()) as varchar(11))
	
	If @tran_type  = 'I'
		Begin
				If Exists(Select Emp_doc_ID From T0090_EMP_HR_DOC_Detail WITH (NOLOCK) Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate and isnull(type,0)=@type)
					begin
						Update T0090_EMP_HR_DOC_Detail
						set 
							 Doc_content=@Doc_content
							,accetpeted=@accetpeted
							,accepted_date=@for_date
							,login_id=@login_id
						where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID
						Select @Emp_doc_ID=Emp_doc_ID From T0090_EMP_HR_DOC_Detail WITH (NOLOCK) Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate
						Return 
					end
				
				select @Emp_doc_ID= Isnull(max(Emp_doc_ID),0) + 1 	From T0090_EMP_HR_DOC_Detail WITH (NOLOCK)
				
				INSERT INTO T0090_EMP_HR_DOC_Detail
				                      ( Emp_doc_ID
										,HR_DOC_ID
										,accetpeted
										,accepted_date
										,cmp_id
										,Emp_id
										,Doc_content
										,login_id
										,Type
									  )
							VALUES     (@Emp_doc_ID
										,@HR_DOC_ID
										,@accetpeted
										,@for_date
										,@cmp_id
										,@Emp_id
										,@Doc_content
										,@login_id
										,@type
									   )
										
		End
	Else if @Tran_Type = 'U'
		begin
						Update T0090_EMP_HR_DOC_Detail
						set 
							accetpeted=@accetpeted
							,Doc_content=@Doc_content
							,accepted_date=@for_date
							,login_id=@login_id
						where Emp_doc_ID = @Emp_doc_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0090_EMP_HR_DOC_Detail Where Emp_doc_ID= @Emp_doc_ID
		end

	RETURN




