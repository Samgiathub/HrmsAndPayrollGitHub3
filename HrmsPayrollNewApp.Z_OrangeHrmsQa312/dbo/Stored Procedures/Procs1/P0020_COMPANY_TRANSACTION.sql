



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0020_COMPANY_TRANSACTION]
	@Tran_ID numeric(9)
   ,@Cmp_ID  numeric(9)
   ,@Tran_From_Date datetime
   ,@Tran_To_Date datetime
   ,@Tran_Lock as varchar(1)
   ,@Tran_Year_End as varchar(1)
   ,@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Tran_Year as VArchar(10)
	set @Tran_Year = Cast(Year(@Tran_From_date) as varchar(5) ) + '_' + cast(Year(@Tran_To_date) as varchar(5))
	 
	If @tran_type  = 'I'
		Begin
				select @Tran_ID = Isnull(max(Tran_ID),0) + 1 	From T0020_COMPANY_TRANSACTION WITH (NOLOCK)
				
				INSERT INTO T0020_COMPANY_TRANSACTION
				                      (Tran_ID, Cmp_ID, Tran_Year, Tran_From_Date, Tran_To_Date, Tran_Lock, Tran_Year_End)
				VALUES     (@Tran_ID, @Cmp_ID, @Tran_Year, @Tran_From_Date, @Tran_To_Date, 'N', 'N')
				
		End
	Else if @Tran_Type = 'U'
		begin
				UPDATE    T0020_COMPANY_TRANSACTION
				SET       Tran_From_Date = @Tran_From_Date, 
						  Tran_To_Date = @Tran_To_Date, 
						  Tran_Lock = @Tran_Lock, 
						  Tran_Year_End =@Tran_Year_End,
						  Tran_Year = @Tran_Year
				Where Tran_ID = @Tran_ID
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0020_COMPANY_TRANSACTION Where Tran_ID = @Tran_ID
		end

	RETURN




