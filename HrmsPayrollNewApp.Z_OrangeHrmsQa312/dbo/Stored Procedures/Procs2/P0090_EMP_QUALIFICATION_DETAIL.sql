

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_QUALIFICATION_DETAIL]  
	      @Row_ID numeric(18,0) output
	     ,@Emp_ID numeric(18,0)
	     ,@Cmp_ID numeric(18,0)
	     ,@Qual_ID numeric(18,0)
	     ,@Specialization varchar(100)
	     ,@Year numeric(18,0)
	     ,@Score varchar(20)
	     ,@St_Date  varchar(30)
	     ,@End_Date  varchar(30)
	     ,@Comments  varchar(250)	    
		 ,@tran_type varchar(1)
		 ,@Login_Id numeric(18,0)=0 -- Rathod '18/04/2012'
		 ,@attach_doc nvarchar(max) =''  --Mukti 30062015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @St_Date = '' OR @St_Date = '00:00:00'
  SET @St_Date  = NULL
else
	 SET @St_Date  =  convert(date, @St_Date, 104)

if @End_Date = ''  OR @End_Date = '00:00:00'
  SET @End_Date  = NULL
else
  SET @End_Date  =  convert(date, @End_Date, 104)


if @Year = 0
	set @Year=NULL  

		if @tran_type ='i' 
			begin
			If Exists(select  Row_ID from T0090_EMP_QUALIFICATION_DETAIL  WITH (NOLOCK) where emp_id=@Emp_ID And Qual_ID=@Qual_ID)
				Begin 
				set @Row_ID = 0
				Return
				End
			
					select @Row_ID = isnull(max(Row_ID),0) from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
					if @Row_ID is null or @Row_ID = 0
						set @Row_ID =1
					else
						set @Row_ID = @Row_ID + 1			
					INSERT INTO T0090_EMP_QUALIFICATION_DETAIL
					                      (Emp_ID, Row_ID, Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,attach_doc)
					VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,@attach_doc)						
					
					INSERT INTO T0090_EMP_QUALIFICATION_DETAIL_Clone
					                      (Emp_ID, Row_ID, Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,System_Date,Login_Id)
					VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,GETDATE(),@Login_Id)						
			
					
				end 
	else if @tran_type ='u' 
				begin
				If Exists(select  Row_ID from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where emp_id=@Emp_ID And Qual_ID=@Qual_ID And Row_ID <> @Row_ID)
				Begin 
				set @Row_ID = 0
				Return
				End
					UPDATE    T0090_EMP_QUALIFICATION_DETAIL
					SET              Cmp_ID = @Cmp_ID, Qual_ID = @Qual_ID, Specialization = @Specialization, Year = @Year, Score = @Score, St_Date = @St_Date, End_Date = @End_Date, Comments = @Comments, attach_doc=@attach_doc
					where Emp_ID = @Emp_ID and Row_ID = @Row_ID
					
					INSERT INTO T0090_EMP_QUALIFICATION_DETAIL_Clone
					                      (Emp_ID, Row_ID, Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,System_Date,Login_Id)
					VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,GETDATE(),@Login_Id)						
			
				end
	else if @tran_type ='d'
					delete  from T0090_EMP_QUALIFICATION_DETAIL where Row_ID = @Row_ID
	RETURN




