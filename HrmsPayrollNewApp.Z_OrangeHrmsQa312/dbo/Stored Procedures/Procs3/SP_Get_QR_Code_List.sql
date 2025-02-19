CREATE PROCEDURE [dbo].[SP_Get_QR_Code_List]
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
    
  DECLARE @Total_Count AS INT = (SELECT COUNT(*) FROM QR_Code_Master where Cmp_ID = @Cmp_ID)
 
  DECLARE @First_Rec int, @Last_Rec int
  SET @First_Rec = @Page_No * @Page_Size + 1;
  SET @Last_Rec = (@Page_No + 1) * @Page_Size;
 
  SET @Search_Value = LTRIM(RTRIM(@Search_Value)) 
 
  ; WITH CTE_Results AS  
  (  
    SELECT ROW_NUMBER() OVER (ORDER BY 
 
   --   CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='asc')  
			--THEN QR.QR_Code_ID  
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='desc')  
			--THEN QR.QR_Code_ID  
   --   END DESC, 
   --   CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='asc')  
			--THEN QR.Cmp_ID 
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='desc')  
   --         THEN QR.Cmp_ID 
   --   END DESC,
	  --CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='asc')  
   --         THEN CMP.Cmp_Name 
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='desc')  
   --         THEN CMP.Cmp_Name
   --   END DESC,
      --CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='asc')  
      --      THEN QR.Branch_ID  
      --END ASC,  
      --CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='desc')  
      --      THEN QR.Branch_ID  
      --END DESC,
	  CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='asc')  
            THEN BR.Branch_Name 
      END ASC,  
      CASE WHEN (@Sort_Column = 0 AND @Sort_Direction='desc')  
            THEN BR.Branch_Name
      END DESC,
	  --CASE WHEN (@Sort_Column = 5 AND @Sort_Direction='asc')  
   --         THEN QR.Department_ID  
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 5 AND @Sort_Direction='desc')  
   --         THEN QR.Department_ID  
   --   END DESC,
	  CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='asc')  
            THEN DR.Dept_Name 
      END ASC,  
      CASE WHEN (@Sort_Column = 1 AND @Sort_Direction='desc')  
            THEN DR.Dept_Name
      END DESC,
	  --CASE WHEN (@Sort_Column = 3 AND @Sort_Direction='asc')  
   --         THEN QR.IO_Flag  
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 3 AND @Sort_Direction='desc')  
   --         THEN QR.IO_Flag  
   --   END DESC,
	  --CASE WHEN (@Sort_Column = 8 AND @Sort_Direction='asc')  
   --         THEN QR.POS_ID  
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 8 AND @Sort_Direction='desc')  
   --         THEN QR.POS_ID  
   --   END DESC,
	  CASE WHEN (@Sort_Column = 2 AND @Sort_Direction='asc')  
            THEN PM.POS_Name 
      END ASC,  
      CASE WHEN (@Sort_Column = 2 AND @Sort_Direction='desc')  
            THEN PM.POS_Name
      END DESC,
	  CASE WHEN (@Sort_Column = 3 AND @Sort_Direction='asc')  
            THEN QR.Latitude  
      END ASC,  
      CASE WHEN (@Sort_Column = 3 AND @Sort_Direction='desc')  
            THEN QR.Latitude  
      END DESC,
	  CASE WHEN (@Sort_Column = 4 AND @Sort_Direction='asc')  
            THEN QR.Longitude  
      END ASC,  
      CASE WHEN (@Sort_Column = 4 AND @Sort_Direction='desc')  
            THEN QR.Longitude  
      END DESC,
	  CASE WHEN (@Sort_Column = 5 AND @Sort_Direction='asc')  
            THEN QR.Meters  
      END ASC,  
      CASE WHEN (@Sort_Column = 5 AND @Sort_Direction='desc')  
            THEN QR.Meters  
      END DESC
	  --CASE WHEN (@Sort_Column = 8 AND @Sort_Direction='asc')  
   --         THEN QR.Is_Active  
   --   END ASC,  
   --   CASE WHEN (@Sort_Column = 8 AND @Sort_Direction='desc')  
   --         THEN QR.Is_Active  
   --   END DESC
    )
    AS Row_Num,
    COUNT(*) OVER() as Filtered_Count,
    QR.QR_Code_ID, 
    QR.Cmp_ID,
	CMP.Cmp_Name,
    QR.Branch_ID,
	BR.Branch_Name,
	QR.Department_ID,
	DR.Dept_Name,
	QR.IO_Flag,
	QR.POS_ID,
	PM.POS_Name,
	QR.Latitude,
	QR.Longitude,
	QR.Meters,
	QR.Is_Active
    FROM QR_Code_Master QR
		LEFT OUTER JOIN T0010_COMPANY_MASTER CMP ON
		CMP.Cmp_Id = QR.Cmp_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BR ON
		BR.Branch_ID = QR.Branch_ID
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DR ON
		DR.Dept_Id = QR.Department_ID
		LEFT OUTER JOIN POS_Master PM ON
		PM.POS_ID = QR.POS_ID
	WHERE (@Cmp_ID = 0 OR QR.Cmp_ID = @Cmp_ID)
		AND (ISNULL(@Search_Value, '') = ''
		OR QR.QR_Code_ID LIKE '%' + @Search_Value + '%'
		OR QR.Cmp_ID LIKE '%' + @Search_Value + '%'
		OR CMP.Cmp_Name LIKE '%' + @Search_Value + '%'
		OR QR.Branch_ID LIKE '%' + @Search_Value + '%'
		OR BR.Branch_Name LIKE '%' + @Search_Value + '%'
		OR QR.Department_ID LIKE '%' + @Search_Value + '%'
		OR DR.Dept_Name LIKE '%' + @Search_Value + '%'
		OR QR.IO_Flag LIKE '%' + @Search_Value + '%'
		OR QR.POS_ID LIKE '%' + @Search_Value + '%'
		OR PM.POS_Name LIKE '%' + @Search_Value + '%'
		OR QR.Latitude LIKE '%' + @Search_Value + '%'
		OR QR.Longitude LIKE '%' + @Search_Value + '%'
		OR QR.Meters LIKE '%' + @Search_Value + '%'
		OR QR.Is_Active LIKE '%' + @Search_Value + '%')
  ) 
 
  SELECT
    QR_Code_ID, 
    Cmp_ID, 
	Cmp_Name,
    Branch_ID,
	Branch_Name,
	Department_ID,
	Dept_Name,
	IO_Flag,
	POS_ID,
	POS_Name,
	Latitude,
	Longitude,
	Meters,
	Is_Active,
    Filtered_Count,
    @Total_Count AS Total_Count
  FROM CTE_Results
  WHERE Row_Num BETWEEN @First_Rec AND @Last_Rec
  --AND (@Cmp_ID = 0 OR Cmp_ID = @Cmp_ID)
    
END