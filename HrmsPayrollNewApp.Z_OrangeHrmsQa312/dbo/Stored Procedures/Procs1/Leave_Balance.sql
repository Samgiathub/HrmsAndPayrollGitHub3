


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Leave_Balance]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FOR_DATE	numeric = null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 Declare @Leave_ID numeric(18,0)
	 
	 Declare @Leave_Detail table
	 (
		Leave_Id          Numeric(18,0),
		Leave_name       varchar(50),
		Leave_OPening   Numeric(18,2),
		Leave_used   Numeric(18,2),
		Leave_closing numeric(18,2)
		
	 )	 
	 
	 if Isnull(@For_Date,0) = 0 
			begin
				select @For_Date = year(getdate())
			end 
			
			insert into @Leave_Detail 
			select leave_id, leave_name , Leave_op_days , 0 , 0 from v0095_leave_opening where cmp_id = @cmp_id and emp_id =@Emp_id and year(for_date) = (@for_date)

			
	Declare curDesgi_sub cursor for  
       select Leave_ID from @Leave_Detail 
        open curDesgi_sub  
         fetch next from curDesgi_sub into  @Leave_ID  
          while @@fetch_status = 0  
           Begin  
           
            update @Leave_Detail
			set Leave_used = (Select isnull(count(leave_used),0) from v0140_Leave_Transaction where emp_id = @emp_id  and cmp_id = @cmp_id and leave_used <> 0 and leave_Id = @leave_Id) where Leave_Id = @Leave_Id
			
			update @Leave_Detail
			set leave_closing = Leave_OPening - leave_used where Leave_Id = @Leave_Id
			
	      fetch next from curDesgi_sub into  @Leave_ID 
          end   
        close curDesgi_sub  
        deallocate curDesgi_sub   
		
			select * from @Leave_Detail
			
	RETURN




