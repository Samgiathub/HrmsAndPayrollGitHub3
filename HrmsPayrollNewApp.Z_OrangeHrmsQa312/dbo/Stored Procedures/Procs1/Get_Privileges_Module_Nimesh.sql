

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Privileges_Module_Nimesh] 
	@cmp_id Numeric = 0,
	@Flag_ESS tinyint=0,
	@Language varchar(20) = 'en'
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Form_ID	Numeric(18,0),
			@Sort_Order	Varchar(40),
			@Row_ID		BigInt,
			@Row_ID_Temp BigInt;
	SET	@Sort_Order = '';	
	SET @Form_ID = 0;		
		
	SELECT	TOP 0 ROW_NUMBER() OVER(ORDER BY SORT_ID,Sort_Id_Check,FORM_ID) AS ROW_ID, Form_ID, Under_Form_ID	
	INTO	#TMP
	FROM	T0000_DEFAULT_FORM WITH (NOLOCK)
	
	IF (@Flag_ESS = 1) 
		BEGIN --ESS Panel	
		 print 1  ---mansi
			INSERT	INTO #TMP
			SELECT	ROW_NUMBER() OVER(ORDER BY SORT_ID,F.Sort_Id_Check,FORM_ID) AS ROW_ID, Form_ID, Under_Form_ID	
			FROM	T0000_DEFAULT_FORM F WITH (NOLOCK)
			WHERE	
			--((Form_Id > 7000 AND Form_Id <= 9000) OR (Form_ID > 9200))
				Page_Flag in ('EP','ER','DE')
			 AND Is_Active_For_menu = 1
					AND (F.Module_name IN (
													SELECT	DISTINCT module_name 
													FROM	T0011_module_detail WITH (NOLOCK)
													WHERE	module_status=1 AND Cmp_id=@Cmp_ID
												) OR F.Module_name IS NUll and F.Alias <>'Company Consolidate Details')
		
		END 
	ELSE IF (@Flag_ESS = 0) 
		BEGIN --Admin/Ess Panel
		 print 2  ---mansi
			INSERT	INTO #TMP
			SELECT	ROW_NUMBER() OVER(ORDER BY SORT_ID,F.Sort_Id_Check,FORM_ID) AS ROW_ID, Form_ID, Under_Form_ID	
			FROM	T0000_DEFAULT_FORM F WITH (NOLOCK)
			WHERE	Is_Active_For_menu = 1
					AND (F.Module_name IN (
													SELECT	DISTINCT module_name 
													FROM	T0011_module_detail WITH (NOLOCK)
													WHERE	module_status=1 AND Cmp_id=@Cmp_ID
												) OR F.Module_name IS NUll and F.Alias <>'Company Consolidate Details')
		END 
	ELSE 
		BEGIN
		 print 3  ---mansi
			INSERT	INTO #TMP
			SELECT	ROW_NUMBER() OVER(ORDER BY SORT_ID,F.Sort_Id_Check,FORM_ID) AS ROW_ID, Form_ID, Under_Form_ID	
			FROM	T0000_DEFAULT_FORM F WITH (NOLOCK)
			WHERE	(F.Module_name IN (
													SELECT	DISTINCT module_name 
													FROM	T0011_module_detail WITH (NOLOCK)
													WHERE	module_status=1 AND Cmp_id=@Cmp_ID
												) OR F.Module_name IS NUll  and  F.Alias <>'Company Consolidate Details')
		END

	
	;WITH R(ROW_ID,Form_ID,Under_Form_ID,Sort_Order,Chk_ID) AS
	(
		SELECT	ROW_ID, Form_ID, Under_Form_ID, CAST((RIGHT('000' + CAST(ROW_ID AS VARCHAR),4)) AS VARCHAR(512)) AS Sort_Order, CAST((RIGHT('00000' + CAST(ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) AS Chk_ID
		FROM	#TMP T1
		WHERE	Under_Form_ID < 1
		UNION ALL
		SELECT	T2.ROW_ID, T2.Form_ID,T2.Under_Form_ID,CAST((R.Sort_Order + RIGHT('000' + CAST(T2.ROW_ID AS VARCHAR),4)) AS VARCHAR(512)) As Sort_Order,CAST((R.Chk_ID + ' ' + RIGHT('00000' + CAST(T2.ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) As Chk_ID
		FROM	#TMP T2 INNER JOIN R ON T2.Under_Form_ID=R.Form_ID
	)
	SELECT	(SPACE(LEN(R.SORT_ORDER)) + case when @Language = 'ch' then M.chinese_alias else M.Alias end ) As Menu,R.Chk_ID,
			case when @Language = 'ch' then M.chinese_alias else M.Alias end as alias,M.*,
			'treegrid-' + Cast(M.Form_ID As Varchar(20)) + ' ' + 
			CASE WHEN M.Under_Form_ID <> -1 Then 
					'treegrid-parent-' + Cast(M.Under_Form_ID as Varchar(20)) 
				Else '' 
			End + ' node-' + Cast(len(Chk_ID)/5 as varchar(10)) 
				+
			Case When C.Under_Form_ID Is Null 
			Then '' 
			Else 
				' has-child'	
			End
			As TreeClass			
	FROM	T0000_DEFAULT_FORM M WITH (NOLOCK) INNER JOIN R ON M.Form_ID=R.Form_ID
			LEFT OUTER JOIN (SELECT distinct Under_Form_ID from T0000_DEFAULT_FORM C WITH (NOLOCK)) c ON M.Form_ID=C.Under_Form_ID
			where M.Alias  <>'Company Consolidate Details'
	ORDER BY R.Sort_Order
END



