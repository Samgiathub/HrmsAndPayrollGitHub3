


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0040_VACANCY_MASTER]
	  @Vacancy_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Vacancy_Name varchar(50)
	 ,@tran_type char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type ='I' 
		begin
		
			if exists (Select Vacancy_ID  from T0040_Vacancy_Master WITH (NOLOCK) Where  Vacancy_Name = @Vacancy_Name and Cmp_ID = @Cmp_ID) 
				begin
					set @Vacancy_ID = 0
				end
			else
				begin
					select @Vacancy_ID = isnull(max(Vacancy_ID ),0) from T0040_Vacancy_Master WITH (NOLOCK)
					if @Vacancy_ID is null or @Vacancy_ID = 0
						set @Vacancy_ID =1
					else
						set @Vacancy_ID = @Vacancy_ID + 1			
						
					insert into T0040_Vacancy_Master(Vacancy_ID,Vacancy_Name,Cmp_ID) values(@Vacancy_ID,@Vacancy_Name,@Cmp_ID)
					
				end
		end 
	else if @tran_type ='U' 
		
			
				begin
					Update T0040_Vacancy_Master
					Set Vacancy_Name = @Vacancy_Name
						where Vacancy_ID = @Vacancy_ID

	end
	else if @tran_type ='D'
		begin
			delete  from T0040_Vacancy_Master where Vacancy_ID=@Vacancy_ID 
		end
	RETURN




