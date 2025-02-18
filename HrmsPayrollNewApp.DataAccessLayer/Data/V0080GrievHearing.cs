using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievHearing
{
    public int GhId { get; set; }

    public string? AppNo { get; set; }

    public int? CmpId { get; set; }

    public int? GAllocationId { get; set; }

    public string HearingDate { get; set; } = null!;

    public string HearingLocation { get; set; } = null!;

    public string GhcontactNo { get; set; } = null!;

    public string? AppSubline { get; set; }

    public string? ComName { get; set; }

    public string? GrievanceTypeTitle { get; set; }

    public string? CategoryTitle { get; set; }

    public string? PriorityTitle { get; set; }

    public string? SName { get; set; }

    public string Ghcomments { get; set; } = null!;

    public int? GStatusId { get; set; }

    public DateTime? Hdate { get; set; }
}
