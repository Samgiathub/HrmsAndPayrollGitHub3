CREATE PROCEDURE [dbo].[PRC_LOCATION_ASSIGN_TO_EMP]
 @CMP_ID NUMERIC(18,0)
,@FROM_DATE DATETIME
,@TO_DATE DATETIME

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

CREATE TABLE #TEMP(
Alpha_Emp_Code varchar(100) 
,Emp_name varchar(200)
,EFFECTTIVE_DATE date
,GEO_LOCATION VARCHAR(200)
,METER INT
)

	--Insert into #TEMP
	
	Select Alpha_Emp_Code,Emp_Full_Name,CONVERT(VARCHAR(10),Effective_Date,105) as  Effective_Date ,
	Geo_Location,LAD.Meter from T0095_EMP_GEO_LOCATION_ASSIGN LA 
	inner join T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL LAD on LAd.Emp_Geo_Location_ID = LA.Emp_Geo_Location_ID
	LEFT OUTER JOIN T0040_Geo_Location_Master GL ON GL.Geo_Location_ID = LAD.Geo_Location_ID
	Left outer join T0010_COMPANY_MASTER Cm on cm.Cmp_Id = la.Cmp_ID
	left outer join T0080_EMP_MASTER Em on em.Emp_ID = la.Emp_ID
	where LA.Cmp_ID = @CMP_ID and Effective_Date between @FROM_DATE and @TO_DATE

	--Select * from #TEMP

--drop table #TEMP
