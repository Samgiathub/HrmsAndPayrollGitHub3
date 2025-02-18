using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050RateMaster
{
    public decimal RateDetailId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? ProductName { get; set; }

    public string? SubProductName { get; set; }

    public decimal? FromLimit { get; set; }

    public decimal? ToLimit { get; set; }

    public decimal? Rate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ProductId { get; set; }

    public decimal? SubProductId { get; set; }
}
