


-- Created by rohit for insert default City on 21082015
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_Dist_Master_Default]
	@CMP_ID AS NUMERIC 
	AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	begin
	
	 
		--DELETE FROM T0030_CITY_MASTER WHERE CMP_ID = @CMP_ID
		DECLARE @LOC_ID AS NUMERIC(18,2) 
		
		DECLARE @STATE_ID AS NUMERIC(18,0)
		declare @District_name as varchar(max)

		set @District_name = ''
		SET @LOC_ID = 1 -- DEFAULT 1 FOR INDIA
		
	
	--///////////// Tejas ///////////////////////
	SELECT distinct SM.STATE_ID, CM.Dist_Name,SM.Loc_ID 
	INTO #CITY 
	FROM SubDist_Master CM inner join T0020_State_Master SM WITH (NOLOCK) on Cm.State_name = SM.state_name 	
	left join T0030_DISTRICT_MASTER TCM WITH (NOLOCK) on CM.Dist_Name = TCM.Dist_Name and SM.State_ID = TCM.State_ID
	WHERE SM.CMP_ID=@CMP_ID and isnull(TCM.Dist_Name,'') = ''
	--////////////////// Tejas ///////////////////////////////
	
	DECLARE CURCITY CURSOR FOR
	select * from #CITY
	OPEN CURCITY
		FETCH NEXT FROM CURCITY INTO @STATE_ID,@District_name,@LOC_ID
		While @@fetch_status = 0                    
		Begin     						
			EXEC P0030_DISTRICT_MASTER 0,@District_name,@CMP_ID,@STATE_ID,@LOC_ID,'I'			

			FETCH NEXT FROM CURCITY INTO @STATE_ID,@District_name,@LOC_ID
		END
	CLOSE CURCITY
	DEALLOCATE CURCITY			
	

	return
	end
		
		
		
