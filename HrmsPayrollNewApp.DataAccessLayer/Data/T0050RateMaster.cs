using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050RateMaster
{
    public decimal RateId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ProductId { get; set; }

    public decimal? SubProductId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
