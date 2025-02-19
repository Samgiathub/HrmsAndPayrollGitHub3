


-- created by rohit For Get all document upload in resume on 04022017
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_Resume_Document_Get]
  @Cmp_Id	numeric ,
  @resume_id Numeric
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SELECT SUBSTRING( RM.File_Name, dbo.GetLastCharIndex(RM.File_Name,'/')+1,LEN(RM.File_Name)) as Proof,Dm.Doc_ID as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN (select top 1 * from T0040_DOCUMENT_MASTER WITH (NOLOCK) where cmp_id=@cmp_id and Doc_Name='Resume') Dm ON 1 = 1 where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id and isnull(RM.File_Name,'')<>''
		UNION
	SELECT SUBSTRING( Address_Proof , dbo.GetLastCharIndex(Address_Proof ,'/')+1,LEN(Address_Proof )) as Proof,DocumentType_Address_Proof as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN T0040_DOCUMENT_MASTER Dm WITH (NOLOCK) ON RM.DocumentType_Address_Proof = Dm.Doc_ID where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id
		UNION
	SELECT SUBSTRING( Address_Proof2 , dbo.GetLastCharIndex(Address_Proof2 ,'/')+1,LEN(Address_Proof2 )) as Proof,DocumentType_AddressProof2 as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN T0040_DOCUMENT_MASTER Dm WITH (NOLOCK) ON RM.DocumentType_AddressProof2 = Dm.Doc_ID where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id
		UNION	
	SELECT SUBSTRING( Identity_Proof , dbo.GetLastCharIndex(Identity_Proof ,'/')+1,LEN(Identity_Proof )) as Proof,DocumentType_Identity as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN T0040_DOCUMENT_MASTER Dm WITH (NOLOCK) ON RM.DocumentType_Identity = Dm.Doc_ID where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id
		UNION
	SELECT SUBSTRING( Identity_Proof2, dbo.GetLastCharIndex(Identity_Proof2,'/')+1,LEN(Identity_Proof2))  as Proof,DocumentType_Identity2 as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN T0040_DOCUMENT_MASTER Dm WITH (NOLOCK) ON RM.DocumentType_Identity2 = Dm.Doc_ID where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id
		UNION
	SELECT SUBSTRING( Marriage_Proof, dbo.GetLastCharIndex(Marriage_Proof,'/')+1,LEN(Marriage_Proof))  as Proof,DocumentType_Marriage_Proof as Doc_ID ,Dm.Doc_Name,RM.Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN T0040_DOCUMENT_MASTER Dm WITH (NOLOCK) ON RM.DocumentType_Marriage_Proof = Dm.Doc_ID where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id and isnull(rm.Marriage_Proof,'')<>''
		UNION
	SELECT SUBSTRING( RM.PanCardAck_Path, dbo.GetLastCharIndex(RM.PanCardAck_Path,'/')+1,LEN(RM.PanCardAck_Path))  as Proof,Dm.Doc_ID as Id ,Dm.Doc_Name,RM.PanCardAck_No as Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN (select top 1 * from T0040_DOCUMENT_MASTER WITH (NOLOCK) where cmp_id=@Cmp_Id and Doc_Name='PAN Card Acknowledgement') Dm on 1=1 where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id and isnull(PanCardAck_Path,'') <> ''
		UNION
	SELECT SUBSTRING( RM.PanCardProof, dbo.GetLastCharIndex(RM.PanCardProof,'/')+1,LEN(RM.PanCardProof))  as Proof,Dm.Doc_ID as Doc_ID ,Dm.Doc_Name ,RM.PanCardNo as Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN (select top 1 * from T0040_DOCUMENT_MASTER WITH (NOLOCK) where cmp_id=@Cmp_Id and Doc_Name='PAN Card') Dm on 1=1 where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id	and ISNULL(PanCardProof,'') <> ''
		UNION
	SELECT SUBSTRING( RM.Aadhar_CardPath, dbo.GetLastCharIndex(RM.Aadhar_CardPath,'/')+1,LEN(RM.Aadhar_CardPath))  as Proof,Dm.Doc_ID as Doc_ID ,Dm.Doc_Name ,RM.Aadhar_CardNo as Comments from T0055_Resume_Master RM WITH (NOLOCK) INNER JOIN (select top 1 * from T0040_DOCUMENT_MASTER WITH (NOLOCK) where cmp_id=@Cmp_Id and Doc_Name='Aadhar Card') Dm on 1=1 where Rm.cmp_id= @Cmp_Id and Resume_Id = @resume_id	and ISNULL(Aadhar_CardPath,'') <> ''

END
