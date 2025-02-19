-- exec prc_BindAgeWiseLimit
-- drop proc prc_BindAgeWiseLimit
CREATE procedure [dbo].[prc_BindAgeWiseLimit]
@rClaimId int
as
begin
	declare @lResult varchar(max) = '',@lXML varchar(max) = ''

	select @lResult = @lResult + '<tr class="gridrow_alt"><td align="left"><input type="text" class="input txtMinAge" onkeypress="return isDecimalKey(event, this);" value="' + CONVERT(varchar,isnull(Age_Min,0)) + '"
	style="width:70px;" onblur="getValues(this);" /><asp:HiddenField ID="hdnMinAge" runat="server" ' + CONVERT(varchar,isnull(Age_Min,0)) + ' /></td><td align="right">
	<input type="text" onkeypress="return isDecimalKey(event, this);" class="input txtMaxAge" style="width:70px;" value="' + CONVERT(varchar,isnull(Age_Max,0)) + '" onblur="getValues(this);" />
	<asp:HiddenField ID="hdnMaxAge" runat="server" value="' + CONVERT(varchar,isnull(Age_Max,0)) + '" /></td><td align="right"><input type="text" onkeypress="return isDecimalKey(event, this);"
	style="width:100px;" value="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" class="input txtAmount" onblur="getValues(this);" />
	<asp:HiddenField ID="hdnAmount" runat="server" value="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" /></td><td><a href="javascript:;" onclick="RemoveRow(this);"><i class="fa fa-trash fa-2x" aria-hidden="true"></i></a></td></tr>'
	from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId

	select @lXML = @lXML + '<Permission MinAge="' + CONVERT(varchar,isnull(Age_Min,0)) + '" MaxAge="' + CONVERT(varchar,isnull(Age_Max,0)) + '" Amount="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" />'
	from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId

	select @lResult as Result,'<Permissions>' + @lXML + '</Permissions>' as XMLSTR
end