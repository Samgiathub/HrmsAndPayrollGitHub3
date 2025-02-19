



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0010_HR_COMP_REQ]
	@Cmp_Req_ID  numeric(18,0) output,
	@Vacancy_ID  varchar(50),
	@Job_Desc  varchar(50),
	@Experience       numeric(18,0),
	@Qual_ID  numeric(18,0),
	@Type_ID numeric(18,0),
	@Desig_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Loc_ID numeric(18,0),
	@Posted_Date DateTime,
	@Email varchar(50),
	@ContactName varchar(50),
	@City varchar(20),
	@Vacancy_Code varchar(20),
	@tran_type varchar(1)
AS	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @tran_type  = 'I' 
		Begin
				If Exists(select Cmp_Req_ID From T0010_HR_Comp_Req WITH (NOLOCK)  Where Cmp_Req_ID = @Cmp_Req_ID)
									
					Begin
						set @Cmp_Req_ID = 0
						Return 
					end
	
				select @Cmp_Req_ID  = Isnull(max(Cmp_Req_ID ),0) + 1 	From T0010_HR_Comp_Req WITH (NOLOCK) 
				
					select @Vacancy_Code =   cast(isnull(max(substring(Vacancy_Code,8,len(Vacancy_Code))),0) + 1 as varchar)  
						from T0010_HR_Comp_Req WITH (NOLOCK)  where Cmp_Req_ID = @Cmp_Req_ID
						
							If charindex(':',@Vacancy_Code) > 0 
					Begin
						Select @Vacancy_Code = right(@Vacancy_Code,len(@Vacancy_Code) - charindex(':',@Vacancy_Code))
					End
						if @Vacancy_Code is not null
							begin
								while len(@Vacancy_Code) <> 4
										begin
												set @Vacancy_Code = '0' + @Vacancy_Code
											end
										set @Vacancy_Code = 'VAC'+ '000' +':'+ @Vacancy_Code  
							end
						else
						Begin
							SET @Vacancy_Code = 'VAC' + '000' + ':' + '0001' 
						End
				
				INSERT INTO T0010_HR_Comp_Req
				                      (
											Cmp_Req_ID, 
										    Vacancy_ID,  
										    Job_Desc,  
											Experience,
											Qual_ID,  
											Type_ID, 
											Desig_ID, 
											Cmp_ID, 
											Loc_ID, 
											Posted_Date,
											Email, 
											ContactName ,
											City,
											Vacancy_Code
				                      )
								VALUES     
								(
									        @Cmp_Req_ID, 
										    @Vacancy_ID,  
										    @Job_Desc,  
											@Experience,       
											@Qual_ID,  
											@Type_ID, 
											@Desig_ID, 
											@Cmp_ID, 
											@Loc_ID, 
											@Posted_Date, 
											@Email, 
											@ContactName ,
												@City,
											@Vacancy_Code
								)
								
									
	 end
	RETURN




