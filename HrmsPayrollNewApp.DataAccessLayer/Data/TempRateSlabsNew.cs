using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempRateSlabsNew
{
    public decimal? CmpId { get; set; }

    public decimal? RrateId { get; set; }

    public decimal? Amount { get; set; }

    public decimal? FromLimit { get; set; }

    public decimal? ToLimit { get; set; }

    public string? Mode { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public DateTime? EffectiveFromDate { get; set; }

    public DateTime? EffectiveEndDate { get; set; }
}
