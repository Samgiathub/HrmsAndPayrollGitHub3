using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020BatchYearDetail
{
    public int BatchDetailId { get; set; }

    public string? BatchTitle { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public int? CmpId { get; set; }

    public int? IsActive { get; set; }

    public bool? IsDefault { get; set; }

    public int? GoalSchemeId { get; set; }
}
