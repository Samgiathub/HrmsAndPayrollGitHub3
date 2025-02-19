




CREATE VIEW [dbo].[V0065_EMP_DOC_DETAIL]
AS
SELECT     dbo.T0040_DOCUMENT_MASTER.Doc_Name, dbo.T0065_EMP_DOC_DETAIL_APP.Row_ID, dbo.T0065_EMP_DOC_DETAIL_APP.Emp_Tran_ID, 
                      dbo.T0065_EMP_DOC_DETAIL_APP.Emp_Application_ID, dbo.T0065_EMP_DOC_DETAIL_APP.Approved_Emp_ID, dbo.T0065_EMP_DOC_DETAIL_APP.Approved_Date, 
                      dbo.T0065_EMP_DOC_DETAIL_APP.Rpt_Level, dbo.T0065_EMP_DOC_DETAIL_APP.Cmp_ID, dbo.T0065_EMP_DOC_DETAIL_APP.Doc_ID, dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path, 
                      dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Comments, dbo.T0065_EMP_DOC_DETAIL_APP.Date_of_Expiry
					  ,CASE
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.txt%'  THEN '../image_new/text.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.pdf%'  THEN '../image_new/pdf.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.ppt%'  THEN '../image_new/ppt.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.doc%'  THEN '../image_new/word.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.docx%' THEN '../image_new/word.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.png%'  THEN '../images/image_icon.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.jpg%'  THEN '../images/image_icon.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.zip%'  THEN '../image_new/text.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.xlsx%' THEN '../image_new/excel.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.xls%' THEN  '../image_new/excel.png'
						WHEN dbo.T0065_EMP_DOC_DETAIL_APP.Doc_Path like '%.gif%' THEN  '../image_new/jpg_icon.png'
						else ''
						END as imagepath
			FROM   dbo.T0065_EMP_DOC_DETAIL_APP WITH (NOLOCK) LEFT OUTER JOIN 
                      dbo.T0040_DOCUMENT_MASTER WITH (NOLOCK)  ON dbo.T0065_EMP_DOC_DETAIL_APP.Doc_ID = dbo.T0040_DOCUMENT_MASTER.Doc_ID


