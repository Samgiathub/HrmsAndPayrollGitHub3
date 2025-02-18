using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LateExtraAmount
{
    public decimal LateAmtId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AllowanceId { get; set; }

    public decimal FromDays { get; set; }

    public decimal ToDays { get; set; }

    public string CalculateOn { get; set; } = null!;

    public string LateMode { get; set; } = null!;

    public decimal Limit { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
