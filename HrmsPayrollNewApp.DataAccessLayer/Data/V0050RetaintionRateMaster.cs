using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050RetaintionRateMaster
{
    public decimal RrateDetailId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal GrdId { get; set; }

    public string GrdName { get; set; } = null!;

    public string GrdDescription { get; set; } = null!;

    public string AdName { get; set; } = null!;

    public decimal AdId { get; set; }

    public string? Mode { get; set; }

    public decimal? FromLimit { get; set; }

    public decimal? ToLimit { get; set; }

    public decimal? Amount { get; set; }

    public decimal? CmpId { get; set; }
}
