using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0220CompanyTransaction
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string TranYear { get; set; } = null!;

    public DateTime TranFromDate { get; set; }

    public DateTime TranToDate { get; set; }

    public string TranLock { get; set; } = null!;

    public string TranYearEnd { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string CmpName { get; set; } = null!;
}
