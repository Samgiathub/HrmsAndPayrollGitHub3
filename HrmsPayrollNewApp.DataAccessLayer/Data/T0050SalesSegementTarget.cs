using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SalesSegementTarget
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? SegmentId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? Mp { get; set; }

    public decimal? Kyc { get; set; }

    public decimal? Sip { get; set; }

    public decimal? Insurance { get; set; }

    public decimal? Other { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? ModifyBy { get; set; }
}
