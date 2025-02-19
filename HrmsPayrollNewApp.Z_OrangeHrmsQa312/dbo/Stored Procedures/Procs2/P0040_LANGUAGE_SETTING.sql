

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_LANGUAGE_SETTING]
	@Cmp_ID Numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	

; with Setting_List as ( SELECT ROW_NUMBER() OVER(PARTITION BY Flag ORDER BY Flag,ENGLISH) As RowID,
 * from (
SELECT     LANG_ID, CMP_ID, ENGLISH, LANGUAGES, REMARK
   ,'Static' as Flag,0 as ID, SORTID
FROM         T0040_LANGUAGE_DETAIL WITH (NOLOCK) WHERE  CMP_ID=@Cmp_ID and Active=1
union
SELECT    0 as LANG_ID, CMP_ID, AD_NAME as ENGLISH, Gujarati_Alias as LANGUAGES,'' as REMARK
   ,'Allowance' as Flag,Ad_id as ID, 100 + AD_LEVEL as Sortid
FROM         T0050_AD_MASTER WITH (NOLOCK) WHERE  CMP_ID=@Cmp_ID

union

SELECT    0 as LANG_ID, CMP_ID, LOAN_NAME as ENGLISH, Gujarati_Alias as LANGUAGES,'' as REMARK
   ,'Loan' as Flag,Loan_ID as ID,200 + loan_id as Sortid
FROM         T0040_LOAN_MASTER WITH (NOLOCK) WHERE  CMP_ID=@Cmp_ID

union

SELECT    0 as LANG_ID, CMP_ID, LEAVE_NAME as ENGLISH, Gujarati_Alias as LANGUAGES,'' as REMARK
   ,'Leave' as Flag,Leave_ID as ID,300 +Leave_Sorting_No as sortid
FROM         T0040_LEAVE_MASTER WITH (NOLOCK) WHERE  CMP_ID=@Cmp_ID

) TRL )

select case when RowID = 1 then Flag else '' end as Group_BY,
	(Case When rowID = 1 Then 'True' Else 'False' End) As IsGroup,*
	from Setting_List SL


END

