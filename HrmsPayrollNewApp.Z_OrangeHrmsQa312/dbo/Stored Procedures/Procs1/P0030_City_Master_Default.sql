


-- Created by rohit for insert default City on 21082015
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_City_Master_Default]
	@CMP_ID AS NUMERIC 
	AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	begin
	
	 
		--DELETE FROM T0030_CITY_MASTER WHERE CMP_ID = @CMP_ID
		DECLARE @LOC_ID AS NUMERIC(18,2) 
		
		DECLARE @STATE_ID AS NUMERIC(18,0)
		DECLARE @CITYCATID AS NUMERIC(18,0)
		declare @City_name as varchar(max)
		declare @District_name as varchar(max)
		declare @Tehsil_name as varchar(max)

		set @CITYCATID =0
		set @City_name = ''
		set @District_name = ''
		set @Tehsil_name = ''
		SET @LOC_ID = 1 -- DEFAULT 1 FOR INDIA
		
	IF NOT EXISTS(SELECT CITY_CAT_NAME FROM T0040_CITY_CATEGORY_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND UPPER(CITY_CAT_NAME) LIKE UPPER('%Other%'))
	BEGIN
		EXEC P0040_CITY_CATEGORY_MASTER 0,@CMP_ID,0,'Other','','I'
		SELECT @CITYCATID=CITY_CAT_ID FROM T0040_CITY_CATEGORY_MASTER WITH (NOLOCK) WHERE UPPER(CITY_CAT_NAME)=UPPER('OTHER') AND CMP_ID=@CMP_ID
	END
	
	SELECT SM.STATE_ID,CM.City_Name,SM.Loc_ID 
	INTO #CITY 
	FROM City_Master CM inner join T0020_State_Master SM WITH (NOLOCK) on Cm.State_name = SM.state_name 	
	left join T0030_CITY_MASTER TCM WITH (NOLOCK) on CM.City_name = TCM.City_name and SM.State_ID = TCM.State_ID
	WHERE SM.CMP_ID=@CMP_ID and isnull(TCM.City_name,'') = ''
	--///////////// Tejas ///////////////////////
	--SELECT distinct SM.STATE_ID, CM.Dist_Name,SM.Loc_ID 
	--FROM SubDist_Master CM inner join T0020_State_Master SM WITH (NOLOCK) on Cm.State_name = SM.state_name 	
	--left join T0030_DISTRICT_MASTER TCM WITH (NOLOCK) on CM.Dist_Name = TCM.Dist_Name and SM.State_ID = TCM.State_ID
	--WHERE SM.CMP_ID=2 and isnull(TCM.Dist_Name,'') = ''
	--////////////////// Tejas ///////////////////////////////
	DECLARE CURCITY CURSOR FOR
	select * from #CITY
	OPEN CURCITY
		FETCH NEXT FROM CURCITY INTO @STATE_ID,@City_name,@LOC_ID
		While @@fetch_status = 0                    
		Begin     						
			EXEC P0030_CITY_MASTER 0,@City_name,@CMP_ID,@CITYCATID,@STATE_ID,@LOC_ID,'','I'			

			FETCH NEXT FROM CURCITY INTO @STATE_ID,@City_name,@LOC_ID
		END
	CLOSE CURCITY
	DEALLOCATE CURCITY			
	
	/*Code added by Sumit on 19012017 for Inserting Travel Mode details from designation master for first time show designation selected in Travel Mode Master form when Open any Mode*/
		if not Exists(select 1 from T0040_Travel_Mode_Details WITH (NOLOCK))
			Begin
				
					if(OBJECT_ID('tempdb..#tmpMode') is null)
							Begin
									create table #tmpMode
									(
										mode_ID numeric(18,0),
										CmpID numeric(18,0),
										DesigID numeric(18,0)
									)
							End
							
							insert into #tmpMode	
									select		TC.data,Cmp_ID,E.Desig_ID
									from		T0040_DESIGNATION_MASTER as E WITH (NOLOCK)
												cross apply (
														select		TM.*,Desig_ID
														from		dbo.[Split](Mode_Of_Travel,'#') as TM
												where isnull(TM.Data,'') <> ''
										) as TC
									where		E.Desig_ID=TC.Desig_ID

							insert into T0040_Travel_Mode_Details
								select mode_ID,DesigID,GETDATE(),CmpID from #tmpMode


							drop table #tmpMode
			End			
	/*-----Ended----------------------------------------*/
	
	/* ////////Added by Tejas at 27052024 insert Travel_Type on cmpany Creation time ///////////////////////////// */
	

	if not Exists(select 1 from T0040_Travel_Type  WITH (NOLOCK) where Cmp_Id=@CMP_ID)
			BEGIN
				insert into T0040_Travel_Type values('Local Tour','Local Tour',1,7696,@CMP_ID)
				insert into T0040_Travel_Type values('Within Block','Within Block',1,7696,@CMP_ID)
				insert into T0040_Travel_Type values('Within District','Within District',1,7696,@CMP_ID)
				insert into T0040_Travel_Type values('Within State','Within State',1,7696,@CMP_ID)

			END
	--///////////////////// End By Tejas  ////////////////////////////////////////////////////////////////////
	return
	end
		
		
		
