using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050CanteenDetail
{
    public decimal CmpId { get; set; }

    public decimal CntId { get; set; }

    public decimal TranId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal? Amount { get; set; }

    public decimal GrdId { get; set; }

    public decimal SubsidyAmount { get; set; }

    public decimal TotalAmount { get; set; }

    public int? ExemptionCount { get; set; }

    public virtual T0050CanteenMaster Cnt { get; set; } = null!;
}
