



CREATE VIEW [dbo].[V0090_HRMS_RESUME_DOCUMENT]
AS
SELECT     DM.Doc_Name, RD.Resume_Id, RD.Doc_Id, RD.DocType_Id, RD.Cmp_Id, RD.File_Name, RD.Resume_Final_Id
FROM         dbo.t0090_HRMS_RESUME_DOCUMENT AS RD WITH (NOLOCK) INNER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS DM WITH (NOLOCK) ON RD.DocType_Id = DM.Doc_ID



