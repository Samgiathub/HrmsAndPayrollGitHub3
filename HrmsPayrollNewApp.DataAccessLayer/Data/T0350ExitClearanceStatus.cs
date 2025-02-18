using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0350ExitClearanceStatus
{
    public decimal StatusId { get; set; }

    public decimal CmpId { get; set; }

    public string Status { get; set; } = null!;
}
