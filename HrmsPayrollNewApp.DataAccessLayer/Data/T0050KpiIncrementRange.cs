using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050KpiIncrementRange
{
    public decimal KpiIncrementRangeId { get; set; }

    public decimal CmpId { get; set; }

    public string RangeName { get; set; } = null!;

    public string RangeValue { get; set; } = null!;

    public DateTime EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
