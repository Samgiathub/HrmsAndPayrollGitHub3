using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120GradewiseAllowance
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal? GrdId { get; set; }

    public DateTime SysDate { get; set; }

    public decimal? AdLevel { get; set; }

    public string? AdMode { get; set; }

    public decimal? AdPercentage { get; set; }

    public decimal? AdAmount { get; set; }

    public decimal? AdMaxLimit { get; set; }

    public decimal? AdNonTaxLimit { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040GradeMaster? Grd { get; set; }
}
