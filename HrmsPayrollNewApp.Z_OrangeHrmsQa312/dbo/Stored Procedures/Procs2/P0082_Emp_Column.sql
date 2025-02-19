
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0082_Emp_Column]
  @tran_id      Numeric  output
 ,@Emp_id 		numeric
 ,@Cmp_id       Numeric
 ,@Column_id    Numeric
 ,@Column_Value	NVARCHAR(Max) 
  as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 Begin
 Declare @tran_Type as Char
 
	if exists(select 1 from  t0082_emp_Column WITH (NOLOCK) where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and mst_tran_id = @Column_id )
	begin
		set @tran_Type = 'U'
		select @Tran_id = tran_id from  t0082_emp_Column WITH (NOLOCK) where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and mst_tran_id = @Column_id  
	end
	else
	Begin
		set @tran_Type = 'I'
	end
	
	if @tran_Type='I'
	begin
		insert into t0082_emp_Column (mst_Tran_Id,cmp_Id,Emp_Id,Value,sys_Date) values(@Column_id,@Cmp_id,@Emp_id,@Column_Value,GETDATE())
	End
	else if @tran_Type='U'
	begin
		update t0082_emp_Column
		set value = @Column_Value
		where Cmp_Id =@Cmp_id and Emp_id = @Emp_id and mst_tran_id = @Column_id and tran_id=@Tran_id
	end
 end
