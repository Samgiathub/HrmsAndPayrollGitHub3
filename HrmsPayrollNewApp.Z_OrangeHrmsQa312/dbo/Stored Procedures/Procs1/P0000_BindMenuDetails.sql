-- EXEC P0000_BindMenuDetails
-- DROP PROCEDURE P0000_BindMenuDetails
CREATE PROCEDURE P0000_BindMenuDetails
@rCmpId INT,
@rPrivilageId INT,
@rFlagEss VARCHAR(4),
@rVirtualPath VARCHAR(100)
AS
BEGIN
	DECLARE @lResult VARCHAR(MAX) = ''

	SET @rFlagEss = CASE @rFlagEss 
		WHEN 'A' THEN 'AP'
		WHEN 'R' THEN 'AP'
		WHEN 'E' THEN 'EP'
		WHEN 'H' THEN 'HP'
		WHEN 'HM' THEN 'HP'
	END
	
	IF @rVirtualPath <> ''
	BEGIN
		SET @rVirtualPath = '/' + @rVirtualPath
	END

	IF @rPrivilageId = 0
	BEGIN
		SELECT @lResult = @lResult + '<li ' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN 'class="treeview"' ELSE '' END + '>
		<a href="' + CASE WHEN ISNULL(F.Form_url,'') <> '' THEN @rVirtualPath + ISNULL(F.Form_url,'') ELSE 'javascript: return false;' END + '">
		' + ISNULL(F.Form_Image_url,'') + '<span>' + ISNULL(F.Form_Name,'') + '</span>
		' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN '<span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>'
		ELSE '' END + '</a>' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN '<ul class="treeview-menu">' + dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) + '</ul>
		' ELSE '' END + '</li>'
		FROM T0000_DEFAULT_FORM F WITH (NOLOCK)
		LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID
		INNER JOIN T0011_module_detail M WITH (NOLOCK) ON F.Module_name = M.module_name
		WHERE F.Module_name = 'Task' AND PF.Under_Form_ID = -1 AND F.Page_Flag = @rFlagEss
		AND F.IS_ACTIVE_FOR_MENU = 1 AND F.FORM_URL IS NOT NULL AND M.module_status = 1
		AND M.Cmp_id = @rCmpId
	END
	ELSE
	BEGIN
		SELECT @lResult = @lResult + '<li ' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN 'class="treeview"' ELSE '' END + '>
		<a href="' + CASE WHEN ISNULL(F.Form_url,'') <> '' THEN @rVirtualPath + ISNULL(F.Form_url,'') ELSE 'javascript: return false;' END + '">
		' + ISNULL(F.Form_Image_url,'') + '<span>' + ISNULL(F.Form_Name,'') + '</span>
		' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN '<span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span>'
		ELSE '' END + '</a>' + CASE WHEN dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) <> '' THEN '<ul class="treeview-menu">' + dbo.fnc_GetChildForms(F.Form_ID, @rVirtualPath) + '</ul>
		' ELSE '' END + '</li>'
		FROM V0020_PRIVILEGE_MASTER_DETAILS  F WITH (NOLOCK)
		LEFT OUTER JOIN T0000_DEFAULT_FORM PF WITH (NOLOCK) ON F.Under_Form_ID = PF.Form_ID
		INNER JOIN T0011_module_detail M WITH (NOLOCK) ON F.Module_name = M.module_name
		WHERE F.Module_name = 'Task' AND F.Page_Flag = @rFlagEss AND F.Cmp_Id = @rCmpId
		AND F.IS_ACTIVE = 1 AND F.Privilege_ID = @rPrivilageId AND PF.Under_Form_ID = -1
		AND M.module_status = 1 AND F.IS_ACTIVE_FOR_MENU = 1
		AND M.Cmp_id = @rCmpId
	END

	SELECT @lResult AS Result
END