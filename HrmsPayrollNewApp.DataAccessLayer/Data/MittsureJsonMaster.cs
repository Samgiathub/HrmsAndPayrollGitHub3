using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class MittsureJsonMaster
{
    public string PkPid { get; set; } = null!;

    public string FkStaffId { get; set; } = null!;

    public string? StaffName { get; set; }

    public string? StartDateTime { get; set; }

    public string? EndDateTime { get; set; }

    public string? StartLat { get; set; }

    public string? StartLog { get; set; }

    public string? EndLat { get; set; }

    public string? EndLog { get; set; }

    public string EmpId { get; set; } = null!;

    public bool? IsSync { get; set; }
}
