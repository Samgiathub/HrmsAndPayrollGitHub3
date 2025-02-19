-- Created By Deepali on 25012022 for [P0210_Retaining_Payment_Detail].
CREATE PROCEDURE [dbo].[P0210_Retaining_Payment_Detail]
    @Cmp_ID	numeric(18, 0)
    ,@Emp_ID	numeric(18, 0)
	,@Ad_Id numeric(18,0)=0
	,@For_Date	datetime=''
	,@Start_Date	datetime =''
	,@End_Date	datetime=''
	,@Calculation_Amount	numeric(18, 2) = 0
	,@period Numeric(18,2) = 0
	,@Mode	Varchar(50) = ''
	,@Amount	Numeric(18,2) = 0
	,@Net_Amount	numeric(18,2) = 0
	,@remarks Varchar(500)=''
	,@Modify_Date Datetime =''
	,@tran_type varchar(1)
	,@tran_id integer =0
	,@Ret_Tran_Id integer =0
AS
        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON	
	If @tran_type  = 'I' 
		Begin			
			if exists (select emp_id from T0210_Retaining_Payment_Detail WITH (NOLOCK) where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id and Ret_Tran_Id =@Ret_Tran_Id )
				begin	
					delete from T0210_Retaining_Payment_Detail where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id and Ret_Tran_Id =@Ret_Tran_Id
					delete from T0210_Retaining_Monthwise_Payment where remarks ='FINAL' and tran_id = @Ret_Tran_Id and Emp_ID =@Emp_ID
				end
					INSERT INTO T0210_Retaining_Payment_Detail (cmp_id,Emp_id,Ad_id,for_date,Start_date,End_date,Calculation_Amount,Period,Mode,Amount,Net_Amount,remarks,Modify_Date,Ret_Tran_Id)
					VALUES    (@cmp_id,@Emp_id,@Ad_id,@for_date,@Start_date,@End_date,@Calculation_Amount,@period,@Mode,@Amount,@Net_Amount,@remarks,@Modify_Date,@Ret_Tran_Id)
					update T0210_Retaining_Monthwise_Payment set remarks ='FINAL' where tran_id = @Ret_Tran_Id and Emp_ID =@Emp_ID

								
		End
	Else if @Tran_Type = 'U' 
		begin
			UPDATE    T0210_Retaining_Payment_Detail
			SET  Calculation_Amount = @Calculation_Amount ,
			Mode = @Mode,
			Amount= @Amount,
			Net_Amount = @Net_Amount,
			remarks = @remarks,
			Modify_Date = @Modify_Date,
			period = @period
			where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID And  Ad_id=@ad_id  and tran_id=@tran_id  
		end
	Else if @Tran_Type = 'D' 
		begin
		if exists(SELECT 1 From T0210_Final_Retaining_Payment WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and isnull(Ad_id,0) = @ad_id  and ret_Tran_ID = @Ret_Tran_Id)  
				BEGIN
					RAISERROR ('Final Payment Process Exists So You Can not Delete it.',16,1)
					--set @Tran_ID = -1
					return
				End
			else
			DELETE 	from T0210_Retaining_Payment_Detail where Emp_ID = @Emp_ID  and isnull(Ad_id,0) = @ad_id and Cmp_ID = @Cmp_ID  and tran_id = @tran_id
			
		end


	RETURN




