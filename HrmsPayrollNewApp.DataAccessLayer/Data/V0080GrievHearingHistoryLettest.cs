using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080GrievHearingHistoryLettest
{
    public int GhhId { get; set; }

    public int? CmpId { get; set; }

    public string HearingDate { get; set; } = null!;

    public string? Ghcomments { get; set; }

    public string? SName { get; set; }

    public string? HearingLocation { get; set; }

    public string? GhcontactNo { get; set; }

    public int? GhId { get; set; }

    public int? GAllocationId { get; set; }

    public DateTime? NextHearingDate { get; set; }

    public int? HearingCount { get; set; }
}
