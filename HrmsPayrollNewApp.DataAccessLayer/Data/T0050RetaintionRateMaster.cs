using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050RetaintionRateMaster
{
    public decimal RrateId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? AdId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? BranchId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
