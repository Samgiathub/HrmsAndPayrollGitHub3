

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_Asset_Installation_Details]
 @InstallationDet_id NUMERIC OUTPUT
,@Installation_id NUMERIC 
,@Cmp_ID		NUMERIC
,@Emp_ID		NUMERIC
,@AssetM_Id	NUMERIC
,@Installation_Details	VARCHAR(max)
,@Asset_Approval_ID NUMERIC
,@Tran_type	CHAR(1) 
,@Branch_Id int
,@Dept_Id int

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


if @Emp_ID =0
	set @Emp_ID = NULL

if @Branch_Id =0
	set @Branch_Id = NULL

if @Dept_Id =0
	set @Dept_Id = NULL

IF @Tran_type = 'I'
	BEGIN
		if not exists(select Asset_Installation_ID from T0110_Asset_Installation_Details WITH (NOLOCK) where emp_id=@emp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_Id=@AssetM_Id and Asset_Installation_ID=@Installation_id and Cmp_id = @Cmp_id)
		begin
			select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0110_Asset_Installation_Details WITH (NOLOCK)	
			
			insert into T0110_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,emp_Id,Asset_Approval_ID,Branch_Id,Dept_Id)
			Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Emp_ID,@Asset_Approval_ID,@Branch_Id,@Dept_Id)
		end
	end
else IF @Tran_type = 'U'
	begin
		if exists(select Asset_Installation_ID from T0110_Asset_Installation_Details WITH (NOLOCK) where emp_id=@emp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_Id=@AssetM_Id  and Asset_Installation_ID = @Installation_id and Cmp_id = @Cmp_id)
				begin
				--delete from T0110_Asset_Installation_Details where Asset_InstallationDet_ID = @InstallationDet_id and emp_Id=@emp_Id And Cmp_ID = @Cmp_Id
				--	select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0110_Asset_Installation_Details	
				--	insert into T0110_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,emp_Id,Asset_Approval_ID)
				--	Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Emp_ID,@Asset_Approval_ID)
					update T0110_Asset_Installation_Details 
					set asset_Installation_id = @Installation_id,
					Installation_Details = @Installation_Details
					where Asset_Installation_ID = @Installation_id and emp_Id=@emp_Id And Cmp_ID = @Cmp_Id and AssetM_Id=@AssetM_Id
				end	
			else if exists(select Asset_Installation_ID from T0110_Asset_Installation_Details WITH (NOLOCK) where Branch_Id=@Branch_Id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_Id=@AssetM_Id  and Asset_Installation_ID = @Installation_id and Cmp_id = @Cmp_id)
				begin
				--delete from T0110_Asset_Installation_Details where Asset_InstallationDet_ID = @InstallationDet_id and emp_Id=@emp_Id And Cmp_ID = @Cmp_Id
				--	select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0110_Asset_Installation_Details	
				--	insert into T0110_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,emp_Id,Asset_Approval_ID)
				--	Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Emp_ID,@Asset_Approval_ID)
					update T0110_Asset_Installation_Details 
					set asset_Installation_id = @Installation_id,
					Installation_Details = @Installation_Details
					where Asset_Installation_ID = @Installation_id and Branch_Id=@Branch_Id And Cmp_ID = @Cmp_Id and AssetM_Id=@AssetM_Id
				end	
			else if exists(select Asset_Installation_ID from T0110_Asset_Installation_Details WITH (NOLOCK) where Dept_Id=@Dept_Id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_Id=@AssetM_Id  and Asset_Installation_ID = @Installation_id and Cmp_id = @Cmp_id)
				begin
				--delete from T0110_Asset_Installation_Details where Asset_InstallationDet_ID = @InstallationDet_id and emp_Id=@emp_Id And Cmp_ID = @Cmp_Id
				--	select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0110_Asset_Installation_Details	
				--	insert into T0110_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,emp_Id,Asset_Approval_ID)
				--	Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Emp_ID,@Asset_Approval_ID)
					update T0110_Asset_Installation_Details 
					set asset_Installation_id = @Installation_id,
					Installation_Details = @Installation_Details
					where Asset_Installation_ID = @Installation_id and Dept_Id=@Dept_Id And Cmp_ID = @Cmp_Id and AssetM_Id=@AssetM_Id
				end	
			else
				begin
					select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0110_Asset_Installation_Details	WITH (NOLOCK)
					insert into T0110_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,emp_Id,Asset_Approval_ID,Branch_Id,Dept_Id)
					Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Emp_ID,@Asset_Approval_ID,@Branch_Id,@Dept_Id)
				end
	END		


RETURN




