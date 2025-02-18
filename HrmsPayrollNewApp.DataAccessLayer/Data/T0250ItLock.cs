using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250ItLock
{
    public decimal LockId { get; set; }

    public decimal CmpId { get; set; }

    public string? FinancialYear { get; set; }

    public byte? IsLock { get; set; }
}
