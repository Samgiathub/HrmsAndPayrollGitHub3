

CREATE PROCEDURE [dbo].[SP_RPT_Home_Holiday_Detail] 
	@Cmp_ID		NUMERIC,
	@From_Date  DATETIME,
	@To_date	DATETIME,	
	--@Branch_Id  NUMERIC 
	@Branch_Id  Varchar(Max) 
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	IF @Branch_Id = 0 or @Branch_Id = ''
		set @Branch_Id = null
	
	Declare @holiday table
	(
	   Hday_Name varchar(100),
	   Holiday_From_date DateTime,
	   Holiday_To_date Datetime,
	   Branch_ID numeric(18,0),
	   Repeat varchar(100),	 
	   Cmp_Name varchar(150),
	   Cmp_Address varchar(max),
	   Cmp_State_Name varchar(50),	--ADDED BY RAMIZ ON 01/03/2017
	   Is_Optional varchar(500),
	   Is_National varchar(500) 
	)	 	
	
			Insert into @holiday(Hday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat,Cmp_Name,Cmp_Address,Cmp_State_Name,Is_Optional,Is_National)
			Select  Hday_Name,H_From_Date,H_To_Date,Branch_ID,Is_Fix,Cmp_Name,Cmp_Address,cm.Cmp_State_Name, isnull(Is_Optional,0), isnull(HM.is_National_Holiday,0)
			   From T0040_Holiday_Master HM WITH (NOLOCK) INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON HM.cmp_Id = CM.Cmp_Id where 
			    H_From_Date>=@From_Date and H_To_Date<=@To_date and HM.Cmp_id=@Cmp_ID  
			    --and (isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0 ) 
			    and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )
    
			if  month(@From_Date)=month(@To_date)
				Begin
					Insert into @holiday(Hday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat,Cmp_Name,Cmp_Address,Cmp_State_Name,Is_Optional,Is_National)
					Select  Hday_Name,convert(varchar(11), dateadd(yy,(year(@From_Date) - year(H_From_Date) ),H_From_Date), 106),convert(varchar(11), dateadd(yy,(year(@to_date) - year(H_To_Date)),H_To_Date), 106),
					Branch_ID,Is_Fix,Cmp_Name,Cmp_Address,cm.Cmp_State_Name, Is_Optional,isnull(HM.is_National_Holiday,0)  
				    From T0040_Holiday_Master HM WITH (NOLOCK) INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON HM.cmp_Id = CM.Cmp_Id where 
				    H_From_Date < @From_Date and H_To_Date < @To_date And Month(H_From_Date)= Month(@From_Date) And Month(H_To_Date)=Month(@To_date)and HM.Cmp_id=@Cmp_ID and is_Fix='Y' 
				    --and (isnull(Branch_ID,0) = isnull(@Branch_Id ,0)  or isnull(Branch_ID,0) = 0 )
				    and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )
				    
				    
				End
			else
				Begin
				
					Insert into @holiday(Hday_Name,Holiday_From_date,Holiday_To_date,Branch_ID,Repeat,Cmp_Name,Cmp_Address,Cmp_State_Name,Is_Optional,Is_National)
					Select  Hday_Name,convert(varchar(11), dateadd(yy,(year(@From_Date) - year(H_From_Date) ),H_From_Date), 106),convert(varchar(11), dateadd(yy,(year(@to_date) - year(H_To_Date)),H_To_Date), 106),
					Branch_ID,Is_Fix,Cmp_Name,Cmp_Address,cm.Cmp_State_Name, isnull(Is_Optional,0),isnull(HM.is_National_Holiday,0)
				    From T0040_Holiday_Master HM WITH (NOLOCK) INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON HM.cmp_Id = CM.Cmp_Id where 
				    H_From_Date < @From_Date and H_To_Date < @To_date and HM.Cmp_id=@Cmp_ID and is_Fix='Y'
				    --and (isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))   or isnull(Branch_ID,0) = 0 )
				    and (ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_Id,ISNULL(Branch_ID,0)),'#') ) or isnull(Branch_ID,0) = 0 )
					
				End	
							   			 	  	  	     			    
	 Select  Hday_Name,DATENAME(DW,Holiday_From_date)+' '+convert(varchar(20), Holiday_From_date, 106) AS H_From_Date,
			 DATENAME(DW,Holiday_To_date)+' '+convert(varchar(11), Holiday_To_date, 106) AS H_To_Date,
			 Holiday_From_date,Holiday_To_date,isnull(Branch_Name,'All Branch') as BranchName,
			 Case when Repeat='N' then 'No' ELSE 'Yes' END as Repeat ,@From_Date AS From_Date, @To_date As To_Date, 
			 Cmp_Name, Cmp_Address, H.Cmp_State_Name ,isnull(H.Branch_ID,0) as Branch_Id,CASE when Is_Optional = 1 then 'Yes' else 'No' end as Optional,CASE when H.Is_National = 1 then 'Yes' else 'No' end as [National]  
	 from @holiday H left outer join t0030_branch_master BM WITH (NOLOCK) on H.Branch_ID=BM.Branch_ID  order by Month(Holiday_From_date),Day(Holiday_From_date),Year(Holiday_From_date)
   
END
RETURN




