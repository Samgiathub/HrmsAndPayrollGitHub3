

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_Asset_Installation_Details]
 @InstallationDet_id NUMERIC OUTPUT
,@Installation_id NUMERIC 
,@Cmp_ID		NUMERIC
,@Resume_ID		NUMERIC
,@AssetM_Id	NUMERIC
,@Installation_Details	VARCHAR(max)
,@Asset_Approval_ID NUMERIC
,@Tran_type	CHAR(1) 

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--IF @Tran_type = 'I'
--	BEGIN
--		if not exists(select Asset_Installation_ID from T0090_HRMS_Asset_Installation_Details where Resume_ID=@Resume_ID and Asset_Approval_ID=@Asset_Approval_ID and Asset_Installation_ID=@Installation_id and Cmp_id = @Cmp_id)
--		begin
--			select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0090_HRMS_Asset_Installation_Details	
			
--			insert into T0090_HRMS_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,Resume_ID,Asset_Approval_ID)
--			Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Resume_ID,@Asset_Approval_ID)
--		end
--	end
--else IF @Tran_type = 'U'
	begin
		if exists(select Asset_Installation_ID from T0090_HRMS_Asset_Installation_Details WITH (NOLOCK) where Resume_ID=@Resume_ID and AssetM_Id=@AssetM_Id  and Asset_Installation_ID = @Installation_id and Cmp_id = @Cmp_id)
				begin
					update T0090_HRMS_Asset_Installation_Details 
					set asset_Installation_id = @Installation_id,
					Installation_Details = @Installation_Details
					where Asset_Installation_ID = @Installation_id and Resume_ID=@Resume_ID And Cmp_ID = @Cmp_Id and AssetM_Id=@AssetM_Id
				end	
			else
				begin
					select @InstallationDet_id = isnull(max(Asset_InstallationDet_ID),0) + 1  from T0090_HRMS_Asset_Installation_Details WITH (NOLOCK)	
					insert into T0090_HRMS_Asset_Installation_Details (Asset_InstallationDet_ID,Cmp_ID,AssetM_Id,Asset_Installation_ID,Installation_Details,Resume_ID,Asset_Approval_ID)
					Values(@InstallationDet_id,@Cmp_ID,@AssetM_Id,@Installation_id,@Installation_Details,@Resume_ID,@Asset_Approval_ID)
				end
	END		


RETURN




