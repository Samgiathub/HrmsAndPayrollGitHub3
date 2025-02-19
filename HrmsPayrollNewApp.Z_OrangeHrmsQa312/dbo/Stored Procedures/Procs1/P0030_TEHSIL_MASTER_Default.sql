


-- Created by rohit for insert default City on 21082015
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_TEHSIL_MASTER_Default]
	@CMP_ID AS NUMERIC 
	AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	begin
	
	 
		--DELETE FROM T0030_CITY_MASTER WHERE CMP_ID = @CMP_ID
		DECLARE @LOC_ID AS NUMERIC(18,2) 
		
		DECLARE @STATE_ID AS NUMERIC(18,0)
		DECLARE @Dist_ID AS NUMERIC(18,0)
		declare @District_name as varchar(max)

		set @District_name = ''
		SET @LOC_ID = 1 -- DEFAULT 1 FOR INDIA
		
	
	--///////////// Tejas ///////////////////////
	SELECT SM.STATE_ID,DM.Dist_ID, isnull(SDM.SubDist_Name,'') as SubDist_Name,SM.Loc_ID 
	INTO #CITY1
	FROM SubDist_Master SDM inner join T0020_State_Master SM WITH (NOLOCK) on SDM.State_name = SM.state_name
	INNER JOIN T0030_DISTRICT_MASTER DM WITH (NOLOCK) on SDM.Dist_Name = DM.Dist_Name and dm.cmp_id = @cmp_Id
	left join T0030_TEHSIL_MASTER THM WITH (NOLOCK) on SDM.SubDist_Name = THM.T_Name and SM.State_ID = THM.State_ID
	WHERE SM.CMP_ID=@CMP_ID and isnull(THM.T_Name,'') = ''
	--////////////////// Tejas ///////////////////////////////
	
	DECLARE CURCITY CURSOR FOR
	select * from #CITY1
	OPEN CURCITY
		FETCH NEXT FROM CURCITY INTO @STATE_ID,@Dist_ID,@District_name,@LOC_ID
		While @@fetch_status = 0                    
		Begin     						
			EXEC P0030_TEHSIL_MASTER 0,@District_name,@CMP_ID,@STATE_ID,@Dist_ID,@LOC_ID,'I'			

			FETCH NEXT FROM CURCITY INTO @STATE_ID,@Dist_ID,@District_name,@LOC_ID
		END
	CLOSE CURCITY
	DEALLOCATE CURCITY			
	

	return
	end
		
		
		
