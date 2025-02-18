using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190ProductionBonusVariableImport
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public int Month { get; set; }

    public int Year { get; set; }

    public decimal? AmountPerc { get; set; }

    public string? Comment { get; set; }

    public DateTime SystemDate { get; set; }

    public string UserId { get; set; } = null!;

    public string IpAddress { get; set; } = null!;

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
