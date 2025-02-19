



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_PROJECT_ALLOCATION]
		 @Row_ID numeric(18,0) output
		,@Emp_ID numeric(18,0)
		,@Cmp_ID numeric(18,0)
		,@Prj_ID numeric(18,0) 
		,@Eff_date datetime
		,@Emp_Active char(1)
		,@tran_type varchar(1)
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If @tran_type ='I' 
			begin
				If exists (Select Row_ID  from T0100_PROJECT_ALLOCATION WITH (NOLOCK) Where Emp_ID = @Emp_ID and Prj_ID=  @Prj_ID and Cmp_ID = @Cmp_ID) 
					begin
						set @Row_ID=0
						return
					end
						select @Row_ID = isnull(max(Row_ID),0)+1 from T0100_PROJECT_ALLOCATION WITH (NOLOCK)
						
						Insert into T0100_PROJECT_ALLOCATION(Row_ID,Cmp_ID,Emp_ID,Prj_ID,Eff_date,Emp_Active) values(@Row_ID,@Cmp_ID,@Emp_ID,@Prj_ID,@Eff_date,@Emp_Active)
			end 
		Else if @tran_type ='U' 
			begin
				--if @Eff_date = 'N'
					--begin
						--Update T0100_PROJECT_ALLOCATION
					--set Emp_ID=@Emp_ID,
						--Emp_Active=@Emp_Active
					--where Row_ID=@ROW_ID
					
					--end
				--else
					--begin
						if @Emp_Active = 'R'
							begin
								Update T0100_PROJECT_ALLOCATION
								set Emp_ID=@Emp_ID,
								Eff_date=@Eff_date,
								Emp_Active='Y',
								Prj_ID=@Prj_ID
								where Row_ID=@ROW_ID
							end
						ELSE if @Emp_Active='Y'
							BEGIN			
							  Update T0100_PROJECT_ALLOCATION
							  set Emp_ID=@Emp_ID,
								Eff_date=@Eff_date,
								Emp_Active='R',
								Prj_ID=@Prj_ID 
							  where Row_ID=@ROW_ID
					
								--UPDATE T0100_PROJECT_ALLOCATION
							--SET Eff_date ='N'
							--Where  Emp_ID <> @Emp_ID and Prj_ID  = @Prj_ID
						--end
					END
			end
		
	else if @tran_type ='d' or @tran_type ='D'
			delete  from T0100_PROJECT_ALLOCATION where Row_ID=@Row_ID
			

	RETURN




