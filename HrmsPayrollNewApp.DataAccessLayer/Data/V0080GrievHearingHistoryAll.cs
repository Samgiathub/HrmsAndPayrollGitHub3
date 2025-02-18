using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievHearingHistoryAll
{
    public int GhhId { get; set; }

    public string? AppNo { get; set; }

    public int? CmpId { get; set; }

    public int? GhId { get; set; }

    public string? LastHearingDate { get; set; }

    public string NextHearingDate { get; set; } = null!;

    public string? HearingLocation { get; set; }

    public decimal? GhcontactNo { get; set; }

    public string? ComName { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? CategoryTitle { get; set; }

    public string? PriorityTitle { get; set; }

    public string? SName { get; set; }

    public string? AppSubline { get; set; }

    public string? GhhdocName { get; set; }

    public string? Ghhcomments { get; set; }

    public string? NewLoc { get; set; }

    public string? NewContact { get; set; }
}
