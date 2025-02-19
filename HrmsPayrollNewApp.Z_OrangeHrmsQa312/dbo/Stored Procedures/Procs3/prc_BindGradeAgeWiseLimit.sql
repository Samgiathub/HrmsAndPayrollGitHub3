-- exec prc_BindGradeAgeWiseLimit
-- drop proc prc_BindGradeAgeWiseLimit
create procedure prc_BindGradeAgeWiseLimit
@rClaimId int
as
begin
	declare @lCmpId INT
	declare @lResult varchar(max) = '',@lXML varchar(max) = ''

	select @lCmpId = Cmp_ID from T0040_CLAIM_MASTER where Claim_ID = @rClaimId

	select @lResult = @lResult + '<tr class="gridrow_alt"><td align="left"><select id="drpGrade" class="input drpGrade">' + dbo.fnc_BindGrade(@lCmpId,GradeId) + '</select>
	<asp:HiddenField ID="hdnGradeId" runat="server" value="' + convert(varchar,GradeId) + '" /></td><td align="left">
	<input type="text" class="input txtMinAge" onkeypress="return isDecimalKey(event, this);" onblur="getGradeAgeValues(this);" value="' + CONVERT(varchar,isnull(Age_Min,0)) + '" />
	<asp:HiddenField ID="hdnGradeMinAge" runat="server" value="' + CONVERT(varchar,isnull(Age_Min,0)) + '" /></td><td align="right">
	<input type="text" class="input txtMaxAge" onkeypress="return isDecimalKey(event, this);" onblur="getGradeAgeValues(this);" value="' + CONVERT(varchar,isnull(Age_Max,0)) + '" />
	<asp:HiddenField ID="hdnGradeMaxAge" runat="server" value="' + CONVERT(varchar,isnull(Age_Max,0)) + '" /></td>
	<td align="right"><input type="text" class="input txtAmount" onkeypress="return isDecimalKey(event, this);" onblur="getGradeAgeValues(this);" value="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" />
	<asp:HiddenField ID="hdnGradeAmount" runat="server" value="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" /></td><td width="10%">&nbsp;</td></tr>'
	from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and GradeId > 0

	select @lXML = @lXML + '<Permission GradeId="' + convert(varchar,GradeId) + '" MinAge="' + CONVERT(varchar,isnull(Age_Min,0)) + '" MaxAge="' + CONVERT(varchar,isnull(Age_Max,0)) + '" Amount="' + CONVERT(varchar,isnull(Age_Amount,0)) + '" />'
	from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and GradeId > 0

	select @lResult as Result,'<Permissions>' + @lXML + '</Permissions>' as XMLSTR
end