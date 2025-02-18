using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210RetainingMonthLockDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? RetainStartDate { get; set; }

    public DateTime? RetainEndDate { get; set; }

    public decimal? Days { get; set; }

    public decimal? SlabId { get; set; }

    public decimal? SlabPer { get; set; }

    public string? Mode { get; set; }

    public DateTime? RetainSlabStartDate { get; set; }

    public DateTime? RetainSlabEndDate { get; set; }

    public DateTime? MnlockStDate { get; set; }

    public DateTime? MnlockEndDate { get; set; }

    public int? MnlockId { get; set; }
}
