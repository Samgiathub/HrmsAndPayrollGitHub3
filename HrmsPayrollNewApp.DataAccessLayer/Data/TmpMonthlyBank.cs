using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpMonthlyBank
{
    public decimal? NetAmount { get; set; }

    public string ProcessType { get; set; } = null!;
}
