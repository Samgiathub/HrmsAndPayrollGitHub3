

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_Asset_Title_Details]
@Asset_Title_ID NUMERIC output
,@Asset_Installation_id NUMERIC 
,@Cmp_ID		NUMERIC
,@AssetM_Id	NUMERIC
,@Asset_Title	VARCHAR(250)
,@Tran_type	CHAR(1) 

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Tran_type = 'I'
	BEGIN
		--if not exists(select Asset_Title_ID from T0110_Asset_Title_Details where AssetM_Id=@Asset_Id and Cmp_id = @Cmp_id)
			select @Asset_Title_ID = isnull(max(Asset_Title_ID),0) + 1  from T0110_Asset_Title_Details	WITH (NOLOCK)
			insert into T0110_Asset_Title_Details (Asset_Title_ID,Cmp_ID,Asset_Installation_ID,Asset_Title,AssetM_Id)
			Values(@Asset_Title_ID,@Cmp_ID,@Asset_Installation_id,@Asset_Title,@AssetM_Id)
	END	
else IF @Tran_type = 'U'
	begin
	--delete from T0110_Asset_Title_Details where AssetM_Id = @AssetM_Id And Cmp_ID = @Cmp_Id
	if exists(select Asset_Title_ID from T0110_Asset_Title_Details WITH (NOLOCK) where AssetM_Id=@AssetM_Id and Asset_Installation_id=@Asset_Installation_id and Cmp_id = @Cmp_id)
		begin
			update T0110_Asset_Title_Details 
			set Asset_Installation_id = @Asset_Installation_id,
				Asset_Title = @Asset_Title
			where AssetM_Id=@AssetM_Id  And Cmp_ID = @Cmp_Id and Asset_Installation_id=@Asset_Installation_id
		end
	else
		begin		
			select @Asset_Title_ID = isnull(max(Asset_Title_ID),0) + 1  from T0110_Asset_Title_Details	WITH (NOLOCK)
			
			insert into T0110_Asset_Title_Details (Asset_Title_ID,Cmp_ID,Asset_Installation_ID,Asset_Title,AssetM_Id)
			Values(@Asset_Title_ID,@Cmp_ID,@Asset_Installation_id,@Asset_Title,@AssetM_Id)
		end
	end
RETURN




