using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GrievPriorityMaster
{
    public int GPriorityId { get; set; }

    public string? PriorityCode { get; set; }

    public string PriorityTitle { get; set; } = null!;

    public string? PriorityStatus { get; set; }

    public DateTime? PriorityCdtm { get; set; }

    public DateTime? PriorityUdtm { get; set; }

    public string? PriorityLog { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }
}
