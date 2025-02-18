using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060ReimTaxablePeriodClone
{
    public decimal TranId { get; set; }

    public decimal? ReimTaxId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? CmpId { get; set; }

    public string? FinYear { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }
}
