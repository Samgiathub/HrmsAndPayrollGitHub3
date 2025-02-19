
--Created by Mehul To get Multiple Hr Document in ESS login Home Page 19052022
CREATE PROCEDURE [dbo].[SP_Get_HRDOC_Details_For_Home]
	
	@emp_id  numeric(18,0) 
   ,@Cmp_ID  numeric (18,0)
   ,@flaggen char(1) = 'A'

AS 

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


Create Table #HR_Doc
(
	Doc_id Numeric(18,0)
	,Gender Char(1)	
)

declare @Doc_id numeric(18,0) = 0
declare @Emp_Gen char(1)

Begin
		Select @Emp_Gen = Gender from T0080_EMP_MASTER where emp_id = @emp_id and Cmp_ID = @Cmp_ID
		
		Insert into #HR_Doc
		select Dm.HR_DOC_ID,Dm.gender from T0040_HR_DOC_MASTER DM 
		inner join 
		T0090_EMP_HR_DOC_Detail DD on DD.HR_DOC_ID = Dm.HR_DOC_ID 
		where DD.cmp_id = @Cmp_ID and Emp_id = @emp_id 

		Select @Doc_id = Doc_id,@flaggen = Gender
		from #HR_Doc

		if @Emp_Gen = 'M'
		begin
			Set @flaggen = 'M'
		end
		else 
		begin
			Set @flaggen = 'F'
		end
		
		if @Doc_id = 0 
		Begin
			select HR_DOC_ID,isnull(Doc_Title,'') as Doc_Title,isnull(Doc_content,'') as Doc_content,isnull(Display_Joinining,0) as Display_Joinining from T0040_HR_DOC_MASTER 
			where Cmp_id = @Cmp_ID and HR_DOC_ID <> @Doc_id and Display_Ess = 1 and gender in (@flaggen,'A') order by Display_Joinining asc	
		End
		Else
		Begin
			select HR_DOC_ID,isnull(Doc_Title,'') as Doc_Title,isnull(Doc_content,'') as Doc_content,isnull(Display_Joinining,0) as Display_Joinining from T0040_HR_DOC_MASTER
			where Cmp_id = @Cmp_ID and Display_Ess = 1 and gender in (@flaggen,'A') and
			HR_DOC_ID not in (select HR_DOC_ID from T0090_EMP_HR_DOC_Detail where Cmp_id = @Cmp_ID and Emp_id = @emp_id) order by Display_Joinining asc	
		End
	    
	Drop Table #HR_Doc
End
	