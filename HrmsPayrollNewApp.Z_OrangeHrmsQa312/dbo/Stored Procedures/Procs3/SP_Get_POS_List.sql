CREATE PROCEDURE [dbo].[SP_Get_POS_List]
(  
  @Search_Value NVARCHAR(255) = NULL,  
  @Page_No INT = 0,
  @Page_Size INT = 10,
  @Sort_Column INT = 0,
  @Sort_Direction NVARCHAR(10) = 'ASC',
  @Cmp_ID INT = 0
)
AS
BEGIN
  SET NOCOUNT ON;
    
  DECLARE @Total_Count AS INT = (SELECT COUNT(*) FROM POS_Master)
 
  DECLARE @First_Rec int, @Last_Rec int
  SET @First_Rec = @Page_No * @Page_Size + 1;
  SET @Last_Rec = (@Page_No + 1) * @Page_Size;
 
  SET @Search_Value = LTRIM(RTRIM(@Search_Value)) 
 
  ; WITH CTE_Results AS  
  (  
    SELECT ROW_NUMBER() OVER (ORDER BY 
 
      CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='asc')  
            THEN POS_ID  
      END ASC,  
      CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='desc')  
          THEN POS_ID  
      END DESC, 
      CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='asc')  
            THEN POS_Name 
      END ASC,  
      CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='desc')  
            THEN POS_Name 
      END DESC,  
      CASE WHEN (@Sort_Column = 2 AND @Sort_Direction='asc')  
            THEN Cmp_ID  
      END ASC,  
      CASE WHEN (@Sort_Column = 2 AND @Sort_Direction='desc')  
            THEN Cmp_ID  
      END DESC
    )
    AS Row_Num,
    COUNT(*) OVER() as Filtered_Count,
    POS_ID, 
    POS_Name, 
    Cmp_ID
    FROM POS_Master
    WHERE (@Cmp_ID = 0 OR Cmp_ID = @Cmp_ID)
	AND (ISNULL(@Search_Value, '') = ''
    OR POS_ID LIKE '%' + @Search_Value + '%'
    OR POS_Name LIKE '%' + @Search_Value + '%'
    OR Cmp_ID LIKE '%' + @Search_Value + '%')
  ) 
	
  SELECT
    POS_ID, 
    POS_Name, 
    Cmp_ID,
    Filtered_Count,
    @Total_Count AS Total_Count
  FROM CTE_Results
  WHERE Row_Num BETWEEN @First_Rec AND @Last_Rec
  --AND (@Cmp_ID = 0 OR Cmp_ID = @Cmp_ID)
    
END