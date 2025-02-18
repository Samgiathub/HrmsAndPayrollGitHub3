using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080GrievHearing
{
    public int GhId { get; set; }

    public int? CmpId { get; set; }

    public int? GAllocationId { get; set; }

    public int? GStatusId { get; set; }

    public DateTime? HearingDate { get; set; }

    public string? HearingLocation { get; set; }

    public string? GhcontactNo { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public string? Log { get; set; }

    public string? Ghcomments { get; set; }

    public string? DocName { get; set; }
}
