CREATE PROCEDURE [dbo].[KPMS_SP0020_Delete_Role_Master]	
(
@Role_ID Int,
@rStatus int,
@Cmp_ID int
)
as
begin
Declare @lrid varchar(MAX)=''
select @lrid =  @lrid + Role_Id from KPMS_T0100_Emp_Role_Assign where Role_Id = @Role_ID and IsActive = 1 and Cmp_Id = @Cmp_ID
	if @rStatus = 2
	begin
		if(@lrid!= '')
		begin
			select -105
			return
		end
		else
		begin
				--SELECT 1
				update KPMS_T0020_Role_Master set IsActive = 2 where Role_ID = @Role_ID
		end			
	end
	else
	begin
		update KPMS_T0020_Role_Master set IsActive = case @rStatus when 1 then 0 else 1 end where Role_ID = @Role_ID and Cmp_ID = @Cmp_ID
	end
	select 1 as res
end

