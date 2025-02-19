
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_QUALIFICATION_DETAIL_APP]  
	      @Row_ID int output
	      ,@Emp_Tran_ID bigint
		 ,@Emp_Application_ID int
	     ,@Cmp_ID int
	     ,@Qual_ID int
	     ,@Specialization varchar(100)
	     ,@Year int
	     ,@Score varchar(20)
	     ,@St_Date datetime
	     ,@End_Date datetime
	     ,@Comments  varchar(250)	    
		 ,@tran_type varchar(1)
		 ,@Login_Id int=0 -- Rathod '18/04/2012'
		 ,@attach_doc nvarchar(max) =''  --Mukti 30062015
		 ,@Approved_Emp_ID int
		 ,@Approved_Date datetime = Null
	     ,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @St_Date = ''  
  SET @St_Date  = NULL
if @End_Date = ''  
  SET @End_Date  = NULL
if @Year = 0
	set @Year=NULL  

		if @tran_type ='i' 
			begin
			If Exists(select  Row_ID from T0065_EMP_QUALIFICATION_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And Qual_ID=@Qual_ID)
				Begin 
				set @Row_ID = 0
				Return
				End
			
					select @Row_ID = isnull(max(Row_ID),0) from T0065_EMP_QUALIFICATION_DETAIL_APP WITH (NOLOCK)
					if @Row_ID is null or @Row_ID = 0
						set @Row_ID =1
					else
						set @Row_ID = @Row_ID + 1			
					INSERT INTO T0065_EMP_QUALIFICATION_DETAIL_APP
					                      (Row_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID, Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments,attach_doc,Approved_Emp_ID,Approved_Date,Rpt_Level)
					VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,@attach_doc,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)						
					
					
			
				end 
	else if @tran_type ='u' 
				begin
				If Exists(select  Row_ID from T0065_EMP_QUALIFICATION_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And Qual_ID=@Qual_ID And Row_ID <> @Row_ID)
				Begin 
				set @Row_ID = 0
				Return
				End
					UPDATE    T0065_EMP_QUALIFICATION_DETAIL_APP
					SET              Cmp_ID = @Cmp_ID, Qual_ID = @Qual_ID, Specialization = @Specialization, Year = @Year, Score = @Score, St_Date = @St_Date, End_Date = @End_Date, Comments = @Comments, attach_doc=@attach_doc,Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
					where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Row_ID = @Row_ID
					
					
			
				end
	else if @tran_type ='d'
					delete  from T0065_EMP_QUALIFICATION_DETAIL_APP where Row_ID = @Row_ID
	RETURN


