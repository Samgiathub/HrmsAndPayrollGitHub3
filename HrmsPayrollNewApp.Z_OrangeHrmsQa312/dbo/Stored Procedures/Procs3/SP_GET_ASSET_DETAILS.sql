


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_ASSET_DETAILS]
	 @Cmp_ID 		numeric,
	 @allocation1 varchar(20)
	 
AS
	BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		--select * from T0040_Asset_Details
	IF @allocation1='Allocated'
	begin
			SELECT   @allocation1 as allocation1, dbo.T0040_Asset_Details.*, dbo.T0040_BRAND_MASTER.BRAND_Name,dbo.T0040_ASSET_MASTER.Asset_Name,T0010_COMPANY_MASTER.Cmp_Name,T0010_COMPANY_MASTER.Cmp_Address,
			CASE when T0040_Asset_Details.Asset_Status = 'W' then 'Working' else 'Damage' end as [Asset_Status]  
			FROM         dbo.T0040_Asset_Details WITH (NOLOCK) INNER JOIN
						  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID and T0040_BRAND_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID INNER JOIN
						  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID and T0040_ASSET_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID inner join 
						  Dbo.T0010_COMPANY_MASTER WITH (NOLOCK) on Dbo.T0010_COMPANY_MASTER.Cmp_Id=T0040_Asset_Details.Cmp_ID
						  where T0040_Asset_Details.Cmp_ID=@Cmp_ID and allocation=1 Order By asset_code			
	 end
	 else IF @allocation1='UnAllocated'
	 begin
	 		SELECT     @allocation1 as allocation1,dbo.T0040_Asset_Details.*, dbo.T0040_BRAND_MASTER.BRAND_Name,dbo.T0040_ASSET_MASTER.Asset_Name,T0010_COMPANY_MASTER.Cmp_Name,T0010_COMPANY_MASTER.Cmp_Address,
	 		CASE when T0040_Asset_Details.Asset_Status = 'W' then 'Working' else 'Damage' end as [Asset_Status]  
			FROM         dbo.T0040_Asset_Details WITH (NOLOCK) INNER JOIN
						  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID and T0040_BRAND_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID INNER JOIN
						  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID and T0040_ASSET_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID inner join 
						  Dbo.T0010_COMPANY_MASTER WITH (NOLOCK) on Dbo.T0010_COMPANY_MASTER.Cmp_Id=T0040_Asset_Details.Cmp_ID
						  where T0040_Asset_Details.Cmp_ID=@Cmp_ID and allocation=0 Order By asset_code	
						  
	end		
			
	else IF @allocation1='All'
	 begin
			SELECT     @allocation1 as allocation1,dbo.T0040_Asset_Details.*, dbo.T0040_BRAND_MASTER.BRAND_Name,dbo.T0040_ASSET_MASTER.Asset_Name,T0010_COMPANY_MASTER.Cmp_Name,T0010_COMPANY_MASTER.Cmp_Address,
			CASE when T0040_Asset_Details.Asset_Status = 'W' then 'Working' else 'Damage' end as [Asset_Status]  
			FROM         dbo.T0040_Asset_Details WITH (NOLOCK) INNER JOIN
						  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID and T0040_BRAND_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID INNER JOIN
						  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID  and T0040_ASSET_MASTER.Cmp_ID=T0040_Asset_Details.Cmp_ID inner join 
						  Dbo.T0010_COMPANY_MASTER WITH (NOLOCK) on Dbo.T0010_COMPANY_MASTER.Cmp_Id=T0040_Asset_Details.Cmp_ID
						  where T0040_Asset_Details.Cmp_ID=@Cmp_ID Order By asset_code	
	 end
    
	END






























