-- Created By Deepali on 25012022 for [[P0210_Retaining_Datewise_Payment]].
CREATE PROCEDURE [dbo].[P0210_Retaining_Datewise_Payment]
    @Cmp_ID	numeric(18, 0)
    ,@Emp_ID	numeric(18, 0)
	,@Ad_Id numeric(18,0)=0
	,@For_Date	datetime=''
	,@Cal_Month datetime =''
	,@Mon_Start_date	datetime =''
	,@Mon_End_date	datetime=''
	,@Retain_date  datetime=''
	,@Re_Amount	numeric(18, 2) = 0
	,@Days Numeric(18,2) = 0
	,@Month_day numeric=1
	 ,@Tot_Retain_Days integer =0
	,@Mode	Varchar(50) = ''
	,@Slab_Id integer = 0 
    ,@Slab_Per numeric(18,2)=0
    ,@Per_Day_Salary Numeric(18,2) = 0
	,@Retain_Amount	Numeric(18,2) = 0
	,@Tot_Amount	numeric(18,2) = 0
	,@remarks Varchar(500)=''
	,@Modify_Date Datetime =''
	,@tran_type varchar(1)='I'
	,@tran_id numeric(18, 0) =0
	,@tran_D_id numeric(18,0)=0
	,@MonLock_Trans_Id integer =0,
	@Emp_Ret_Count integer = 0
           
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	If @tran_type  = 'I' 
		Begin
				if exists (select emp_id from T0210_Retaining_Datewise_Payment WITH (NOLOCK) where Emp_ID =@Emp_ID and Retain_date =@Retain_date and @tran_id=@tran_id)
				begin	
					delete from T0210_Retaining_Datewise_Payment where Emp_ID =@Emp_ID and Retain_date =@Retain_date  and @tran_id=@tran_id
					end
				INSERT INTO T0210_Retaining_Datewise_Payment(tran_id , cmp_id , Emp_id,  Ad_id , Cal_Month , Mon_Start_date , Mon_End_date , Days , Slab_Id , Slab_Per , Mode , 
					Per_Day_Salary,Retain_Amount,Tot_Amount ,remarks , Modify_Date,Tot_Retain_Days,Month_day, Retain_date, MonLock_Trans_Id, Emp_Ret_Count )
     				VALUES    (@tran_id,@cmp_id,@Emp_id,@Ad_id,@Cal_Month,@Mon_Start_date,@Mon_End_date,@Days,@Slab_Id,@Slab_Per,@Mode,
					@Per_Day_Salary, @Retain_Amount,@Tot_Amount,@remarks,GETDATE(),@Tot_Retain_Days,@Month_day,@Retain_date, @MonLock_Trans_Id,@Emp_Ret_Count)
								
		End
	Else if @Tran_Type = 'U' 
		begin
			UPDATE    T0210_Retaining_Datewise_Payment
			SET
			Mon_End_date= @Mon_End_date,
			Mon_Start_date= @Mon_Start_date,
			Retain_date =@Retain_date ,
			Retain_Amount = @Retain_Amount ,
			Mode = @Mode,
			Tot_Amount= @Tot_Amount,
			Slab_Id=@Slab_Id,
			Slab_Per = @Slab_Per,
			remarks = @remarks,
			Modify_Date = GETDATE(),
			Days = @Days,
			Tot_Retain_Days=@Tot_Retain_Days,
			MonLock_Trans_Id=@MonLock_Trans_Id
			where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Retain_date =@Retain_date and Ad_id=@ad_id     				
		end
	Else if @Tran_Type = 'D' 
		begin
		if exists(SELECT 1 From T0210_Retaining_Datewise_Payment WITH (NOLOCK) Where  Retain_date =@Retain_date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and isnull(Ad_id,0) = @ad_id)
				BEGIN
					RAISERROR ('Final Payment Process Exists So You Can not Delete it.',16,1)
					--set @Tran_ID = -1
					return
				End
			else
			DELETE 	from T0210_Retaining_Datewise_Payment where Emp_ID = @Emp_ID and  Retain_date =@Retain_date and isnull(Ad_id,0) = @ad_id and Cmp_ID = @Cmp_ID 
			
		end

		RETURN

