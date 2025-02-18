using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ProjectStatus
{
    public decimal ProjectStatusId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ProjectStatus { get; set; }

    public string? Remarks { get; set; }

    public string Color { get; set; } = null!;

    public string StatusType { get; set; } = null!;
}
