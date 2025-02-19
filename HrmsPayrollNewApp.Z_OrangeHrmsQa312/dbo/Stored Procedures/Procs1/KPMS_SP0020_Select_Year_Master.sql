-- exec KPMS_SP0020_Select_Goal_Master 67,0,'','',1,2,''  
-- drop proc KPMS_SP0020_Select_Goal_Master  
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Year_Master]   
(  
@Cmp_ID INT,  
@Batch_Detail_Id INT,  
@Title varchar(100)= NULL,  
@Fromdate VARCHAR(50),  
@Todate VARCHAR(50),  
@rPageIndex INT,  
@rPageSize INT  
)  
as  
 SELECT @Fromdate = CASE ISNULL(@Fromdate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Fromdate, 105), 23) END  
 SELECT @Todate = CASE ISNULL(@Todate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Todate, 105), 23) END  
   
BEGIN  
 IF @Batch_Detail_Id = 0  
 BEGIN  
  DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''  
  DECLARE @lTotalRecords INT = 0  
  SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end  
  
  CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)  
   
  INSERT INTO #Temp  
  SELECT Batch_Detail_Id FROM KPMS_T0020_BatchYear_Detail WITH(NOLOCK)  
  WHERE IsActive < 2 --and Cmp_ID=@Cmp_ID  
  AND (From_Date LIKE @FromDate + '%' OR @FromDate = '')  
  AND (To_Date LIKE @Todate + '%' OR @Todate = '')  
  AND (Batch_Title LIKE @Title + '%' OR @Title = '')ORDER BY Batch_Detail_Id desc  
  
  select @lTotalRecords = COUNT(1) from #Temp  
  SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)  
  
  select @lResult = @lResult + '<tr>  
  <td>' + isnull(Batch_Title,'') + '</td>  
<td>' + isnull(convert(varchar,From_Date,103),'') + '</td>  
<td>' + isnull(convert(varchar,To_Date,103),'') + '</td>  
<td>' + CASE IsDefault WHEN 1 THEN '<b>Default</b>'else '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- ' END + '</td>  
  <td>  
  <a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Batch_Detail_Id) +')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>  
  <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Batch_Detail_Id) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>  
  <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Batch_Detail_Id) + ',' + CONVERT(varchar,IsActive) + ')">   
  ' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'  
  </a></td></tr>' from KPMS_T0020_BatchYear_Detail ,#Temp where Batch_Detail_Id = rId  
  and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid --CONVERT(VARCHAR(10), CONVERT(DATE, @Fromdate, 105), 23)  
   
DECLARE @lScheme VARCHAR(MAX)=''
 SELECT @lScheme = '<option value="0"> -- Select -- </option>'  
 SELECT @lScheme = @lScheme + '<option value="' + CONVERT(VARCHAR,Scm_Id) + '">' + Scheme + '</option>'  
 FROM T0001_SCHEME_MASTER WITH(NOLOCK)
  select @lResult as Result,@lPaging as Paging ,@lScheme AS Scheme 
 END  
 ELSE  
 BEGIN  
  SELECT ISNULL(Batch_Detail_Id,0) AS b_Id,ISNULL([Batch_Title],'') as Title,  
  CONVERT(VARCHAR, CONVERT(varchar, From_Date, 103)) as From_Date ,  
  CONVERT(VARCHAR, CONVERT(varchar, To_Date, 103)) as To_Date  
  ,ISNULL([IsDefault],0) as IsDefault   
  from KPMS_T0020_BatchYear_Detail as GM   
  Where (@Batch_Detail_Id = 0 Or Batch_Detail_Id=@Batch_Detail_Id)  
 END  
END