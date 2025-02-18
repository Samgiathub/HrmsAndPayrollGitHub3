using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052IncrementUtilityBaseAmount
{
    public decimal BaseAmtId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? Amount { get; set; }

    public decimal? Percentage { get; set; }
}
