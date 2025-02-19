



CREATE VIEW [dbo].[v0040_DOCUMENT_MASTER]
AS
select TM.*,
isnull(DTM.doc_type_name,'') as doc_type_name
from T0040_DOCUMENT_MASTER TM WITH (NOLOCK) left join 
t0030_document_type_master DTM WITH (NOLOCK)  on TM.document_type_Id = DTM.doc_type_id
