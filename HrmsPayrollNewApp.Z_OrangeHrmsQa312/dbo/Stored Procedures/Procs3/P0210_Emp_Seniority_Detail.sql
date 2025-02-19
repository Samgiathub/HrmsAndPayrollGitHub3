


-- Created By rohit on 04062015 for Seniority Calculation.
CREATE PROCEDURE [dbo].[P0210_Emp_Seniority_Detail]
    @Cmp_ID	numeric(18, 0)
    ,@Emp_ID	numeric(18, 0)
	,@Ad_Id numeric(18,0)=0
	,@For_Date	datetime
	,@Calculation_Amount	numeric(18, 2) = 0
	,@period Numeric(18,2) = 0
	,@Mode	Varchar(50) = ''
	,@Amount	Numeric(18,2) = 0
	,@Net_Amount	numeric(18,2) = 0
	,@remarks Varchar(500)=''
	,@Modify_Date Datetime =''
	,@tran_type varchar(1)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	If @tran_type  = 'I' 
		Begin
			
			if exists (select emp_id from T0210_Emp_Seniority_Detail WITH (NOLOCK) where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id)
				begin	
					delete from T0210_Emp_Seniority_Detail where Emp_ID =@Emp_ID and month(For_Date) = month(@For_Date) and YEAR(For_date) = YEAR(@For_Date) and isnull(Ad_id,0) = @ad_id
				end
			
				
					INSERT INTO T0210_Emp_Seniority_Detail (cmp_id,Emp_id,Ad_id,for_date,Calculation_Amount,Period,Mode,Amount,Net_Amount,remarks,Modify_Date)
					VALUES    (@cmp_id,@Emp_id,@Ad_id,@for_date,@Calculation_Amount,@period,@Mode,@Amount,@Net_Amount,@remarks,@Modify_Date)
								
		End
	Else if @Tran_Type = 'U' 
		begin
			UPDATE    T0210_Emp_Seniority_Detail
			SET  Calculation_Amount = @Calculation_Amount ,
			Mode = @Mode,
			Amount= @Amount,
			Net_Amount = @Net_Amount,
			remarks = @remarks,
			Modify_Date = @Modify_Date,
			period = @period
			where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID And For_Date = @For_Date  and Ad_id=@ad_id     				
		end
	Else if @Tran_Type = 'D' 
		begin
		
			DELETE 	from T0210_Emp_Seniority_Detail where Emp_ID = @Emp_ID and For_Date = @For_Date and isnull(Ad_id,0) = @ad_id and Cmp_ID = @Cmp_ID 
			
		end


	RETURN




