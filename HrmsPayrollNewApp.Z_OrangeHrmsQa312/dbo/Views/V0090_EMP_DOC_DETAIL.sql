

CREATE VIEW [dbo].[V0090_EMP_DOC_DETAIL]
AS
SELECT     dbo.T0040_DOCUMENT_MASTER.Doc_Name, dbo.T0090_EMP_DOC_DETAIL.Row_ID, dbo.T0090_EMP_DOC_DETAIL.Emp_ID, 
                      dbo.T0090_EMP_DOC_DETAIL.Cmp_ID, dbo.T0090_EMP_DOC_DETAIL.Doc_ID, dbo.T0090_EMP_DOC_DETAIL.Doc_Path, 
                      dbo.T0090_EMP_DOC_DETAIL.Doc_Comments
                      ,dbo.T0090_EMP_DOC_DETAIL.Date_of_Expiry
					  ,CASE
    WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.txt%'  THEN '../image_new/text.png'
    WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.pdf%'  THEN '../image_new/pdf.png'
    WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.ppt%'  THEN '../image_new/ppt.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.doc%'  THEN '../image_new/word.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.docx%' THEN '../image_new/word.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.png%'  THEN '../images/image_icon.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.jpg%'  THEN '../images/image_icon.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.zip%'  THEN '../image_new/text.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.xlsx%' THEN '../image_new/excel.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.xls%' THEN  '../image_new/excel.png'
	WHEN dbo.T0090_EMP_DOC_DETAIL.Doc_Path like '%.gif%' THEN  '../image_new/jpg_icon.png'
--	else ''
END as imagepath
FROM         dbo.T0090_EMP_DOC_DETAIL WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_DOC_DETAIL.Doc_ID = dbo.T0040_DOCUMENT_MASTER.Doc_ID
