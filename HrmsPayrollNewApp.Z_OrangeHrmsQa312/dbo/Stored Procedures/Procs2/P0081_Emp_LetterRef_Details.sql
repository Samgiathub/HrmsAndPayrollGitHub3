
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0081_Emp_LetterRef_Details]
  @tran_id      Numeric  output
 ,@Emp_id 		numeric
 ,@Cmp_id       Numeric
 ,@Letter_Name  varchar(200)
 ,@Reference_No  varchar(100)
 ,@Issue_date  datetime
 ,@tran_type Char
 as 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 Begin
	--if exists(select 1 from  T0081_Emp_LetterRef_Details where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and mst_tran_id = @Column_id )
	--	begin
	--		set @tran_Type = 'U'
	--		select @Tran_id = tran_id from  T0081_Emp_LetterRef_Details where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and mst_tran_id = @Column_id  
	--	end
		
	if @tran_Type='I'
		begin
			select @Tran_id= Isnull(max(tran_id),0) + 1 	From T0081_Emp_LetterRef_Details WITH (NOLOCK) 
			
			insert into T0081_Emp_LetterRef_Details (tran_id,cmp_Id,Emp_Id,Letter_Name,Reference_No,Issue_Date)
			values(@Tran_id,@Cmp_id,@Emp_id,@Letter_Name,@Reference_No,@Issue_date)
		End
	else if @tran_Type='U'
		begin
			update T0081_Emp_LetterRef_Details
			set Letter_Name=@Letter_Name,
			Reference_No=@Reference_No,
			Issue_Date=@Issue_date		
			where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and tran_id=@Tran_id
		end
	else if @tran_Type='D'
		begin
			delete from T0081_Emp_LetterRef_Details	where Cmp_Id =@Cmp_id and tran_id=@Tran_id
		end
 end




