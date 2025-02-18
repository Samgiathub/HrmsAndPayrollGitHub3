using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060ReimQuarterPeriodClone
{
    public decimal TranId { get; set; }

    public decimal? ReimQuarId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FinYear { get; set; }

    public string? QuarterName { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public DateTime? ClaimUptoDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }

    public bool IsTaxableQuarter { get; set; }
}
