

CREATE PROCEDURE [dbo].[SP_GET_TRAVEL_TYPE_Test]
@CMP_ID NUMERIC
,@EMP_ID NUMERIC
,@TTypeName Varchar(50)=''

AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @SCHEME_ID AS NUMERIC,@TRAVEL_TYPE VARCHAR(500)	

	CREATE TABLE #ttY 
	 (      
	   Traveltype varchar(500),
	   Scheme_id numeric
	 ) 

	SELECT @SCHEME_ID = Scheme_ID 
	FROM T0095_EMP_SCHEME E 
	WHERE Cmp_ID = @CMP_ID AND EMP_ID = @EMP_ID AND E.Type = 'Travel'
	order by Tran_ID desc
	
	SELECT @TRAVEL_TYPE = Leave FROM T0050_Scheme_Detail 
	WHERE Cmp_Id = @CMP_ID AND Scheme_Id = @SCHEME_ID
	
	If @TRAVEL_TYPE <> ''
	Begin
		Insert into #ttY
		Select Cast(data as numeric) ,@SCHEME_ID
		from dbo.Split (@TRAVEL_TYPE,'#')
	
	End
	--select  * From #ttY
	--Select Travel_Type_Name 
	--from T0050_Scheme_Detail  sd
	--inner join T0095_EMP_SCHEME es on es.Scheme_ID = sd.Scheme_Id
	--inner join T0040_Travel_Type TT on TT.Travel_Type_Id = sd.Leave
	--where sd.Scheme_Id = @SCHEME_ID and emp_id	= @EMP_ID	AND SD.Cmp_Id = @CMP_ID

	--Select Travel_Type_Name 
	--from #ttY  sd
	--inner join T0095_EMP_SCHEME es on es.Scheme_ID = sd.Scheme_id
	--inner join T0040_Travel_Type TT on TT.Travel_Type_Id = sd.Traveltype
	--where sd.Scheme_Id = @SCHEME_ID and emp_id	= @EMP_ID	AND es.Cmp_Id = @CMP_ID
	
	Select distinct TT.Travel_Type_Id,Travel_Type_Name 
	into  #FinalData  from #ttY  sd
	inner join T0095_EMP_SCHEME es on es.Scheme_ID = sd.Scheme_id
	--inner join (SELECT Max(Effective_Date) AS EffDate, emp_id FROM T0095_EMP_SCHEME 
	--			WHERE Effective_Date <= getdate() AND cmp_id = @CMP_ID GROUP BY Emp_id
	--			) Qry on es.Emp_ID = Qry.Emp_ID AND es.Effective_Date = Qry.EffDate 
    inner join T0040_Travel_Type TT on TT.Travel_Type_Id = sd.Traveltype
	where sd.Scheme_Id = @SCHEME_ID and es.Emp_ID	= @EMP_ID	AND es.Cmp_Id = @CMP_ID and Travel_Type_Name=@TTypeName

	if ((select Count(*) from #FinalData) > 0 )
	begin

	select Travel_Type_Id,Travel_Type_Name from #FinalData
	end
	else
	begin
	select 0 as Travel_Type_Id, 'No Data' as Travel_Type_Name
	end


	
	drop table #ttY,#FinalData

END

