using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052IncrementUtility
{
    public DateTime EffectiveDate { get; set; }

    public decimal? SegmentId { get; set; }

    public string? SegmentName { get; set; }

    public decimal CmpId { get; set; }
}
